import psycopg2


# populates templates_to_collect list and missing_indexes list
def identify_template_targets_and_missing_indexes(connection, templates_to_collect, missing_indexes_list):
    with connection.cursor() as cur:
        cur.execute("""
                with for_counting as (
                    with index_info as (
                        select indexname,
                            to_number(substring(indexdef from 'dataset_type_ref = (.*)\)\)'), '000') as "dataset_type_ref"
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
                select dataset_type_ref, name, metadata_type_ref, count(*) as "count", array_agg(index_attributes) as "index_attributes"
                from for_counting
                group by dataset_type_ref, name, metadata_type_ref
                order by metadata_type_ref, count desc, index_attributes;
            """)

        current_metadata_type_ref = -1
        current_index_count_max = -1
        current_index_types = []
        for dataset_type_ref, product_name, metadata_type_ref, index_type_count, index_types in cur:
            if current_metadata_type_ref != metadata_type_ref:
                current_metadata_type_ref = metadata_type_ref
                current_index_count_max = index_type_count
                current_index_types = index_types
                templates_to_collect.append({'product_name': product_name, 'metadata_type_ref': metadata_type_ref,
                                             'index_types': index_types, 'dataset_type_ref': dataset_type_ref})
            elif index_type_count < current_index_count_max:
                missing_indexes = [index for index in current_index_types if index not in index_types]
                missing_indexes_list.append({'product_name': product_name, 'dataset_type_ref': dataset_type_ref,
                                             'metadata_type_ref': metadata_type_ref,
                                             'missing_indexes': missing_indexes})


# collect templates from database
def collect_templates(connection, templates_to_collect, templates_dict):

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

                add_index_template(templates_dict, metadata_type_ref, index_type,
                                   product_name, dataset_type_ref, index_example_string)


# adds index templates to a templates dictionary
def add_index_template(templates_dict, metadata_type_ref, index_type,
                       product_name, dataset_type_ref, index_example_string):
    template = index_example_string.replace('_' + product_name + '_' + index_type,
                                            '_%s_' + index_type)
    template = template.replace(str(dataset_type_ref) + '))', '%d))')
    templates_dict[(metadata_type_ref, index_type)] = template


# inserts a product name and its id into a template
def create_sql_statement(templates_dict, metadata_type_ref, index_type, product_name, dataset_type_ref):
    template = templates_dict[(metadata_type_ref, index_type)]

    sql_statement = template % (product_name, dataset_type_ref)

    f = open(f"create_index_{metadata_type_ref}_{product_name}_{index_type}.sql", 'w')
    f.write(sql_statement)
    f.close()


templates_to_collect = []
missing_indexes_list = []
templates_dict = {}

with psycopg2.connect(host="localhost",
                      database="datacube",
                      port=9999,
                      user='al6701') as conn:
    identify_template_targets_and_missing_indexes(conn, templates_to_collect, missing_indexes_list)
    collect_templates(conn, templates_to_collect, templates_dict)

for missing_indexes in missing_indexes_list:
    product_name = missing_indexes['product_name']
    dataset_type_ref = missing_indexes['dataset_type_ref']
    metadata_type_ref = missing_indexes['metadata_type_ref']
    missing_indexes = missing_indexes['missing_indexes']

    for missing_index in missing_indexes:
        create_sql_statement(templates_dict, metadata_type_ref, missing_index, product_name, dataset_type_ref)

