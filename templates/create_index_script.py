import psycopg2

# with psycopg2.connect(host="agdc-db.nci.org.au", database="datacube") as conn:


# adds index templates to a templates dictionary
def add_index_template(templates_dict, metadata_type_ref, index_types,
                       product_name, dataset_type_ref, index_string):
    template = str(index_string).replace('_' + product_name + '_' + index_types,
                                         '_%s_' + index_types)
    template = template.replace(str(dataset_type_ref)+'))', '%d))')
    templates_dict[(metadata_type_ref, index_types)] = template


# inserts a product name and its id into a template
def create_sql_statement(templates_dict, metadata_type_ref, index_types,
                         product_name, dataset_type_ref):
    template = templates_dict[(metadata_type_ref, index_types)]

    sql_statement = template % (product_name, dataset_type_ref)

    f = open("create_index_" + metadata_type_ref + product_name + "_"
             + index_types + '.sql', 'w')
    f.write(sql_statement)
    f.close()


templates_dict = {}

print('Connecting to database...')
with psycopg2.connect(host="localhost",
                      database="datacube",
                      port=9999,
                      user='al6701') as conn:
    print('Connected!')
    #     fsdetails = cur.fetchall()
    #     print(cur.fetchall())
    #
    # fscount = 0
    # total_free = 0
    # total_used = 0
    # for device, blocks, used, available, percent_use, mount in fsdetails:

    print('Running query...')
    with conn.cursor() as cur:
        cur.execute("""
        SELECT * FROM pg_indexes;
        """)
        print('Query complete!')
        print(cur.fetchall())
        print('laptop test works!')

        #
        # current_metadata_type_ref = -1
        # current_index_count_max = -1
        # current_index_types = []
        # for dataset_type_ref, product_name, metadata_type_ref, index_type_count, index_types in cur:
        #     if current_metadata_type_ref != metadata_type_ref:
        #         current_metadata_type_ref = metadata_type_ref
        #         current_index_count_max = index_type_count
        #         current_index_types = str(index_types)[1:-1].split(',')
        #     elif index_type_count < current_index_count_max:
        #         index_types = str(index_types)[1:-1].split(',')
        #         missing_indexes = [index for index in current_index_types if index not in index_types]
        #
        #

# metadata_type_ref = 1
# index_attributes = 'time_lat_lon'
# product_name = 'prod'
# dataset_type_ref = 99
# filename = 'test'
# create_sql_statement(metadata_type_ref, index_attributes, product_name, dataset_type_ref, filename)
