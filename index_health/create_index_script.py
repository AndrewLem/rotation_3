import psycopg2


def main():
    # connect to database to retrieve index templates, and identify missing indexes
    with psycopg2.connect(host="localhost",
                          database="datacube",
                          port=9999,
                          user='al6701') as conn:
        templates_to_collect, products_missing_indexes = identify_template_targets_and_missing_indexes(conn)
        templates_dict = collect_templates(conn, templates_to_collect)

    # for each product missing one or more indexes
    for product_missing_indexes in products_missing_indexes:
        product_name = product_missing_indexes['product_name']
        dataset_type_ref = product_missing_indexes['dataset_type_ref']
        metadata_type_ref = product_missing_indexes['metadata_type_ref']
        missing_indexes = product_missing_indexes['missing_indexes']

        # for each missing index for the product
        for missing_index in missing_indexes:
            create_sql_statement(templates_dict, metadata_type_ref, missing_index, product_name, dataset_type_ref)


# populates templates_to_collect list and products_missing_indexes list
def identify_template_targets_and_missing_indexes(connection):
    """
    This function queries the database to identify which:
     - index definitions to use as the base templates for missing indexes
     - products are missing indexes by comparing it to other products of the same metadata_type_ref

    :param connection: database connection
    :return: templates_to_collect, products_missing_indexes
    """
    templates_to_collect = []
    products_missing_indexes = []
    with connection.cursor() as cur:
        cur.execute("""
                with for_counting as (
                    with index_info as (
                        select indexname,
                            to_number(substring(indexdef from 'dataset_type_ref = (.*)\)\)'), '000') 
                            as "dataset_type_ref"
                        from pg_indexes
                        where schemaname = 'agdc'
                        and tablename = 'dataset'
                        and indexname like 'dix%'
                    ),
                    dataset_type_info as (
                        select id, name, metadata_type_ref
                        from agdc.dataset_type
                    )
                    select dataset_type_ref, name, metadata_type_ref,
                        substring(indexname from 'dix_'||name||'_(.*)') as "index_attributes"
                    from index_info i
                           left outer join dataset_type_info t
                                           on i.dataset_type_ref = t.id
                    order by index_attributes
                )
                select 
                    dataset_type_ref, 
                    name, 
                    metadata_type_ref, 
                    count(*) as "count", 
                    array_agg(index_attributes) as "index_attributes"
                from for_counting
                group by dataset_type_ref, name, metadata_type_ref
                order by metadata_type_ref, count desc, index_attributes;
            """)

        current_metadata_type_ref = -1
        current_index_count_max = -1
        current_index_types = []

        # for each result in the query
        for dataset_type_ref, product_name, metadata_type_ref, index_type_count, index_types in cur:

            # identify and assign the "current_metadata_type_ref"
            if current_metadata_type_ref != metadata_type_ref:
                current_metadata_type_ref = metadata_type_ref
                # because count order is descending the first product of each metadata_type should have all indexes
                current_index_count_max = index_type_count
                # store the index types for this metadata_type
                current_index_types = index_types
                # flag this first product as the template to be used for missing indexes
                templates_to_collect.append({'product_name': product_name,
                                             'metadata_type_ref': metadata_type_ref,
                                             'index_types': index_types,
                                             'dataset_type_ref': dataset_type_ref})

            # if the product is of the same "metadata_type" and has less indexes than it should
            elif index_type_count < current_index_count_max:
                # flag which indexes are missing for this product based on what is missing in index_types
                missing_indexes = [index for index in current_index_types if index not in index_types]
                products_missing_indexes.append({'product_name': product_name,
                                                 'dataset_type_ref': dataset_type_ref,
                                                 'metadata_type_ref': metadata_type_ref,
                                                 'missing_indexes': missing_indexes})
    return templates_to_collect, products_missing_indexes


# collect templates from database using templates_to_collect list
def collect_templates(connection, templates_to_collect):
    """
    This function queries the database to collect index definitions to use as templates for missing indexes
    :param connection: database connection
    :param templates_to_collect: list of products and indexes to use a templates
    :return: templates_dict
    """

    templates_dict = {}

    for index_details in templates_to_collect:
        product_name = index_details['product_name']
        metadata_type_ref = index_details['metadata_type_ref']
        index_types = index_details['index_types']
        dataset_type_ref = index_details['dataset_type_ref']
        for index_type in index_types:
            with connection.cursor() as cur:
                cur.execute(f"""
                                select indexdef from pg_indexes
                                where indexname = 'dix_{product_name}_{index_type}'
                            """)
                index_example_string, = cur.fetchone()

                # function modifies index definition into a template and adds it to templates_dict
                add_index_template(templates_dict, metadata_type_ref, index_type,
                                   product_name, dataset_type_ref, index_example_string)

    return templates_dict


# adds an index template to a templates dictionary
def add_index_template(templates_dict, metadata_type_ref, index_type,
                       product_name, dataset_type_ref, index_example_string):
    """
    This function uses index_example_string and replaces the product_name, index_type and dataset_type_ref with
    Python placeholders to create an index template
    :param templates_dict: dictionary of templates to add the template to
    :param metadata_type_ref: integer value
    :param index_type: string of which index the template is for
    :param product_name: string of the product_name that needs to be replaced with a placeholder in the template
    :param dataset_type_ref: integer value of the product that needs to be replaced with a placeholder
    :param index_example_string: index definition retrieved from database
    :return: no return object, the function directly adds the template to templates_dict
    """
    template = index_example_string.replace('_' + product_name + '_' + index_type,
                                            '_%s_' + index_type)
    template = template.replace(str(dataset_type_ref) + '))', '%d))')
    templates_dict[(metadata_type_ref, index_type)] = template


# inserts a product name and its id into a template and generates a *.sql file
def create_sql_statement(templates_dict, metadata_type_ref, index_type, product_name, dataset_type_ref):
    """
    This function creates an *.sql file that will create an index
    Potential to modify this function to run a create index database command instead
    :param templates_dict: dictionary of index templates
    :param metadata_type_ref: integer - of the product missing an index
    :param index_type: string - the index type that is missing
    :param product_name: string - name of the product missing an index
    :param dataset_type_ref: integer - product dataset_type_ref
    :return: no return object, creates a file
    """

    # retrieve specific template using metadata_type_ref and index_type
    template = templates_dict[(metadata_type_ref, index_type)]

    # insert the product_name and dataset_type_ref into the template
    sql_statement = template % (product_name, dataset_type_ref)

    f = open(f"create_index_{metadata_type_ref}_{product_name}_{index_type}.sql", 'w')
    f.write(sql_statement)
    f.close()


if __name__ == '__main__':
    main()
