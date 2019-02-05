-- these commands create the indexes used to test extent queries

create index dataset_type_ul_lat
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision))
  where (archived IS NULL);

create index dataset_type_ur_lat
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision))
  where (archived IS NULL);

create index dataset_type_ll_lat
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision))
  where (archived IS NULL);

create index dataset_type_lr_lat
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision))
  where (archived IS NULL);

create index dataset_type_ll_lon
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision))
  where (archived IS NULL);

create index dataset_type_lr_lon
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision))
  where (archived IS NULL);

create index dataset_type_ul_lon
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision))
  where (archived IS NULL);

create index dataset_type_ur_lon
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision))
  where (archived IS NULL);

create index dataset_type_to_dt
  on agdc.dataset (dataset_type_ref, agdc.common_timestamp(metadata #>> '{extent,from_dt}'::text[]))
  where (archived IS NULL);

create index dataset_type_from_dt
  on agdc.dataset (dataset_type_ref, agdc.common_timestamp(metadata #>> '{extent,to_dt}'::text[]))
  where (archived IS NULL);