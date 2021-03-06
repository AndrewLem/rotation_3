-- auto-generated definition
-- variables required: (product_name, dataset_type_ref)
create index dix_prod_time_lat_lon
  on dataset (tstzrange(agdc.common_timestamp(metadata #>> '{extent,from_dt}'::text[]),
                        agdc.common_timestamp(metadata #>> '{extent,to_dt}'::text[]), '[]'::text), agdc.float8range(
                  LEAST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                        (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                        (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                        (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision),
                  GREATEST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                           (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                           (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                           (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision), '[]'::text),
              agdc.float8range(LEAST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                     (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                     (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                                     (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision),
                               GREATEST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                        (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                        (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                                        (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision), '[]'::text))
  where ((archived IS NULL) AND (dataset_type_ref = 99));

