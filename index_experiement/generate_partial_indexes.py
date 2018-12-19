templates = [
    "create index dix_ul_lat_%d on agdc.dataset (((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_ur_lat_%d on agdc.dataset (((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_ll_lat_%d on agdc.dataset (((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_lr_lat_%d on agdc.dataset (((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_ul_lon_%d on agdc.dataset (((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_ur_lon_%d on agdc.dataset (((metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_ll_lon_%d on agdc.dataset (((metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;",
    "create index dix_lr_lon_%d on agdc.dataset (((metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = %d;"
]

for x in range(0, len(templates)):
    print(templates[x] % (21, 21))
