create index dix_69_ul_lat
  on agdc.dataset (((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0dataset_type_ul_lat
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0dataset_type_ur_lat
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision))
  where (archived IS NULL);

/*
file size before index:
70.4 GB (75,693,523,158 bytes)
70.5 GB (75,719,622,656 bytes)
 */

create index dix_0dataset_type_ll_lat
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision))
  where (archived IS NULL);

/*
file size after index:
71.0 GB (76,259,614,981 bytes)
71.0 GB (76,285,714,432 bytes)
 */

create index dix_0dataset_type_lr_lat
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0dataset_type_ll_lon
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0dataset_type_lr_lon
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0dataset_type_ul_lon
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0dataset_type_ur_lon
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision))
  where (archived IS NULL);

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------


create index dix_0dataset_least_lat
  on agdc.dataset (dataset_type_ref, LEAST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0dataset_greatest_lat
  on agdc.dataset (dataset_type_ref, GREATEST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0dataset_least_lon
  on agdc.dataset (dataset_type_ref, LEAST((metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0dataset_greatest_lon
  on agdc.dataset (dataset_type_ref, GREATEST((metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision))
  where (archived IS NULL);





create index dix_0least_lat
  on agdc.dataset (dataset_type_ref, LEAST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0greatest_lat
  on agdc.dataset (dataset_type_ref, GREATEST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0least_lon
  on agdc.dataset (dataset_type_ref, LEAST((metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                           (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision))
  where (archived IS NULL);

create index dix_0greatest_lon
  on agdc.dataset (dataset_type_ref, GREATEST((metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                              (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision))
  where (archived IS NULL);



create index dix_s2a_level1c_granule_lat_range
  on agdc.dataset (agdc.float8range(LEAST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                                     (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                                     (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                                     (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision),
                               GREATEST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                                        (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                                        (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                                        (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision), '[]'::text))
  where ((archived IS NULL) AND (dataset_type_ref = 92));

create index dix_s2a_level1c_granule_lon_range
  on agdc.dataset (agdc.float8range(LEAST((metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                     (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision,
                                     (metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                     (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision),
                               GREATEST((metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                        (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision,
                                        (metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                        (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision), '[]'::text))
  where ((archived IS NULL) AND (dataset_type_ref = 92));