select count(id)
from agdc.dataset;

select count(id)
from agdc.dataset
where (archived IS NULL)
  and dataset_type_ref = 69;

create index tix_active_dataset_type
  on agdc.dataset (dataset_type_ref)
  where (archived IS NULL);

select *
from agdc.dataset
where dataset_type_ref = 21
limit 5;

select *
from agdc.dataset_type
where id = 21;

-- auto-generated definition
create index tix_landsat_scene_id
  on agdc.dataset ((metadata #>> '{usgs,scene_id}'::text[]))
  where ((metadata #>> '{usgs,scene_id}'::text[]) IS NOT NULL);

-- auto-generated definition
create index ix_agdc_dataset_dataset_type_ref
  on agdc.dataset (dataset_type_ref);

-- auto-generated definition
create index ix_agdc_dataset_location_dataset_ref
  on agdc.dataset_location (dataset_ref);


select dataset_type_ref,
       (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision as ul_lat,
       (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision as ur_lat,
       (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision as ll_lat,
       (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision as lr_lat,
       (metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision as ul_lon,
       (metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision as ur_lon,
       (metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision as ll_lon,
       (metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision as lr_lon
from agdc.dataset
where (archived is null)
limit 5;

-- auto-generated definition
create index dix_s2a_level1c_granule_lat_lon_time
  on agdc.dataset (agdc.float8range(LEAST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                                          (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                                          (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                                          (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision),
                                    GREATEST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                                             (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                                             (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                                             (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision),
                                    '[]'::text),
                   agdc.float8range(LEAST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                          (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                          (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                                          (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision),
                                    GREATEST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                             (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                             (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                                             (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision),
                                    '[]'::text),
                   tstzrange(agdc.common_timestamp(metadata #>> '{extent,from_dt}'::text[]),
                             agdc.common_timestamp(metadata #>> '{extent,to_dt}'::text[]), '[]'::text))
  where ((archived IS NULL) AND (dataset_type_ref = 92));

-- auto-generated definition
create index dix_s2a_level1c_granule_time_lat_lon
  on agdc.dataset (tstzrange(agdc.common_timestamp(metadata #>> '{extent,from_dt}'::text[]),
                             agdc.common_timestamp(metadata #>> '{extent,to_dt}'::text[]), '[]'::text),
                   agdc.float8range(
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
                                             (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision),
                                    '[]'::text))
  where ((archived IS NULL) AND (dataset_type_ref = 92));


----------------------


explain select *
        FROM agdc.dataset
        WHERE (agdc.float8range(least(CAST((metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                      CAST((metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                      CAST((metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                      CAST((metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)
                                  ),
                                greatest(CAST((metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                         CAST((metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                         CAST((metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                         CAST((metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)
                                  ),
                                '[]')
          && agdc.float8range(-24.89, -24.85, '[)'))
          AND (agdc.float8range(least(CAST((metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                      CAST((metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                      CAST((metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                      CAST((metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                                greatest(CAST((metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                         CAST((metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                         CAST((metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                         CAST((metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                                '[]')
          && agdc.float8range(152.3, 152.34, '[)'))
          AND (tstzrange(agdc.common_timestamp((metadata #>> '{extent, from_dt}')),
                         agdc.common_timestamp((metadata #>> '{extent, to_dt}')),
                         '[]') &&
               tstzrange('2017-06-01 00:00:00+00', '2017-09-01 00:00:00+00', '[)')
          )
          AND ((archived IS NULL) AND (dataset_type_ref = 21));

analyze;

show search_path;

vacuum;

show default_statistics_target; -- default value is 100

analyse agdc.dataset;

set default_statistics_target = 1000;

set enable_seqscan = off;
set enable_bitmapscan = off;

show enable_seqscan;

select *
from pg_stats;

reindex index agdc.dix_ls7_nbar_albers_lat_lon_time;

show enable_indexscan;

SET seq_page_cost = 2;

--- temporarily disable using an index in query:
update pg_index
set indisvalid = false
where indexrelid = 3356681; -- where indisvalid = false; --

select *
from pg_index
where indexrelid = 3357420;

select *
from pg_statio_all_indexes
where indexrelname = 'ix_agdc_dataset_dataset_type_ref';


-- auto-generated definition
create index tix_active_dataset_type
  on agdc.dataset (dataset_type_ref)
  where (archived IS NULL);



select *
from pg_index
where indisvalid = false;

show seq_page_cost;

show random_page_cost;

set random_page_cost = 2;


-- using dix_0greatest_lon time:

show autovacuum;

vacuum analyse;

select *
from pg_stat_all_tables;

SELECT t.*
FROM agdc.dataset t;
SELECT count(t.*)
FROM agdc.dataset t;

select *
from agdc.dataset_type
where id in (2, 9, 10, 11, 12, 14, 15, 16, 17, 19, 20, 21, 22, 23, 26, 28, 29, 69, 70, 71, 73, 76, 77, 90, 91, 92);
select *
from agdc.dataset_type
where id in (10, 11, 12, 15, 16, 17, 19, 20, 21, 22, 23, 26, 28, 29, 69, 70, 71, 73, 76, 77, 90, 91, 92);

SELECT agdc.dataset.id,
       agdc.dataset.metadata_type_ref,
       agdc.dataset.dataset_type_ref,
       agdc.dataset.metadata,
       agdc.dataset.archived,
       agdc.dataset.added,
       agdc.dataset.added_by,
       array((SELECT selected_dataset_location.uri_scheme || ':' || selected_dataset_location.uri_body AS anon_1
              FROM agdc.dataset_location AS selected_dataset_location
              WHERE selected_dataset_location.dataset_ref = agdc.dataset.id
                AND selected_dataset_location.archived IS NULL
              ORDER BY selected_dataset_location.added DESC, selected_dataset_location.id DESC)) AS uris
FROM agdc.dataset
WHERE agdc.dataset.archived IS NULL
  AND (tstzrange(least(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                       agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, center_dt}'))),
                 greatest(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                          agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, center_dt}'))), '[]') &&
       tstzrange('2018-01-01T00:00:00+00:00'::timestamptz, '2019-01-01T00:00:00.999999+00:00'::timestamptz, '[)'))
  AND agdc.dataset.dataset_type_ref = 10;


