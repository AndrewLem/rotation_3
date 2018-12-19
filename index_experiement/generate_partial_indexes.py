data_type_refs = [26, 78, 66, 95, 96, 57, 65, 68, 83, 84, 88, 97, 67, 98, 69, 70, 71, 19, 21, 60, 61, 28, 29, 20, 23, 22, 77, 56, 85, 79, 53, 63, 80, 81, 6, 82, 86, 87, 89, 64, 92, 93, 36, 32, 94]

templates = [
    "create index dix_%d_ul_lat on agdc.dataset (((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_%d_ur_lat on agdc.dataset (((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_%d_ll_lat on agdc.dataset (((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_%d_lr_lat on agdc.dataset (((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_%d_ul_lon on agdc.dataset (((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_%d_ur_lon on agdc.dataset (((metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_%d_ll_lon on agdc.dataset (((metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_%d_lr_lon on agdc.dataset (((metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;"
]

with open("create_partial_indexes.sql", 'w') as f:
    for data_type_ref in data_type_refs:
        for x in range(0, len(templates)):
            f.write((templates[x] + '\n') % (data_type_ref, data_type_ref))
