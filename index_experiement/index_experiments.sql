explain select (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision as ul_lats,
               (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision as ur_lats,
               (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision as ll_lats,
               (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision as lr_lats
        from agdc.dataset
        where dataset_type_ref = 23;


-- [2018-12-13 12:41:57] 500 rows retrieved starting from 1 in 5 m 25 s 581 ms (execution: 5 m 25 s 503 ms, fetching: 78 ms)
select (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision as ul_lats,
       (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision as ur_lats,
       (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision as ll_lats,
       (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision as lr_lats
from agdc.dataset
where dataset_type_ref = 69;


-- [2018-12-13 12:46:38] 500 rows retrieved starting from 1 in 609 ms (execution: 562 ms, fetching: 47 ms)
select (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision as ul_lats
from agdc.dataset
where dataset_type_ref = 6;

explain
  select
    min((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as ul_lats
  from agdc.dataset
  where (archived is null)
    and dataset_type_ref = 69;

/*
Result  (cost=55.94..55.95 rows=1 width=8)
  InitPlan 1 (returns $0)
    ->  Limit  (cost=0.44..55.94 rows=1 width=8)
          ->  Index Scan using dix_69_ul_lat on dataset  (cost=0.44..61530491.64 rows=1108685 width=8)
"                Index Cond: (((metadata #>> '{{extent,coord,ul,lat}}'::text[]))::double precision IS NOT NULL)"
                Filter: (dataset_type_ref = 69)


[2018-12-13 13:28:22] 1 row retrieved starting from 1 in 52 s 464 ms (execution: 52 s 448 ms, fetching: 16 ms)

after creating index: dataset_type_ref, ul_lat
[2018-12-13 14:08:03] 1 row retrieved starting from 1 in 93 ms (execution: 62 ms, fetching: 31 ms)
 */


explain
  select
    min((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as ur_lats
  from agdc.dataset
  where (archived is null)
    and dataset_type_ref = 69;


/*
Aggregate  (cost=2313148.93..2313148.94 rows=1 width=8)
  ->  Index Scan using tix_active_dataset_type on dataset  (cost=0.44..2302006.37 rows=1114256 width=1257)
        Index Cond: (dataset_type_ref = 69)

[2018-12-13 13:30:42] 1 row retrieved starting from 1 in 1 m 45 s 523 ms (execution: 1 m 45 s 507 ms, fetching: 16 ms)

[2018-12-13 14:10:27] 1 row retrieved starting from 1 in 1 m 44 s 354 ms (execution: 1 m 44 s 342 ms, fetching: 12 ms)

after creating index: dataset_type_ref, ur_lat
[2018-12-13 14:47:08] 1 row retrieved starting from 1 in 125 ms (execution: 109 ms, fetching: 16 ms)
 */


select
  max((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as ul_lats,
  max((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as ur_lats
from agdc.dataset
where (archived is null)
  and dataset_type_ref = 70;

/*

sql> create index dix_0dataset_type_ur_lat
       on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision))
       where (archived IS NULL)
[2018-12-13 14:42:55] completed in 27 m 24 s 797 ms
sql> select
            min((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as ur_lats
     from agdc.dataset
     where (archived is null) and dataset_type_ref = 69
[2018-12-13 14:47:08] 1 row retrieved starting from 1 in 125 ms (execution: 109 ms, fetching: 16 ms)
sql> select
            min((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as ul_lats,
            min((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as ur_lats
     from agdc.dataset
     where (archived is null) and dataset_type_ref = 69
[2018-12-13 14:50:29] 1 row retrieved starting from 1 in 78 ms (execution: 47 ms, fetching: 31 ms)
sql> select
            max((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as ul_lats,
            max((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as ur_lats
     from agdc.dataset
     where (archived is null) and dataset_type_ref = 69
[2018-12-13 14:51:44] 1 row retrieved starting from 1 in 110 ms (execution: 94 ms, fetching: 16 ms)
sql> select
            max((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as ul_lats,
            max((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as ur_lats
     from agdc.dataset
     where (archived is null) and dataset_type_ref = 6
[2018-12-13 14:52:45] 1 row retrieved starting from 1 in 93 ms (execution: 78 ms, fetching: 15 ms)
sql> select
            max((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as ul_lats,
            max((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as ur_lats
     from agdc.dataset
     where (archived is null) and dataset_type_ref = 70
[2018-12-13 14:53:16] 1 row retrieved starting from 1 in 359 ms (execution: 328 ms, fetching: 31 ms)

 */


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
70.5 GB (75,719,622,656 bytes) on disk
 */

create index dix_0dataset_type_ll_lat
  on agdc.dataset (dataset_type_ref, ((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision))
  where (archived IS NULL);

/*
file size after index:
71.0 GB (76,259,614,981 bytes)
71.0 GB (76,285,714,432 bytes) on disk
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

create index dix_0dataset_type_to_dt
  on agdc.dataset (dataset_type_ref, agdc.common_timestamp(metadata #>> '{extent,from_dt}'::text[]))
  where (archived IS NULL);

create index dix_0dataset_type_from_dt
  on agdc.dataset (dataset_type_ref, agdc.common_timestamp(metadata #>> '{extent,to_dt}'::text[]))
  where (archived IS NULL);


---------------------------------------------------------------------------------------------------

explain SELECT agdc.dataset.id,
               agdc.dataset.metadata_type_ref,
               agdc.dataset.dataset_type_ref,
               agdc.dataset.metadata,
               agdc.dataset.archived,
               agdc.dataset.added,
               agdc.dataset.added_by,
               array(
                   (SELECT selected_dataset_location.uri_scheme || ':' || selected_dataset_location.uri_body AS anon_1
                    FROM agdc.dataset_location AS selected_dataset_location
                    WHERE selected_dataset_location.dataset_ref = agdc.dataset.id
                      AND selected_dataset_location.archived IS NULL
                    ORDER BY selected_dataset_location.added DESC, selected_dataset_location.id DESC)) AS uris
        FROM agdc.dataset
        WHERE agdc.dataset.archived IS NULL
          AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                                greatest(
                                    CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                    CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                    CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                    CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                                '[]')
          && agdc.float8range(152.3, 152.34, '[)'))
          AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)
                                  ),
                                greatest(
                                    CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                    CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                    CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                    CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)
                                  ),
                                '[]')
          && agdc.float8range(-24.89, -24.85, '[)'))
          AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                         agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                         '[]') &&
               tstzrange('2017-06-01 00:00:00+00', '2017-09-01 00:00:00+00', '[)')
          )
          AND agdc.dataset.dataset_type_ref = 21;

/*
agdc.dataset.dataset_type_ref = 19
[2018-12-17 11:41:57] 5 rows retrieved starting from 1 in 11 m 42 s 21 ms (execution: 11 m 41 s 895 ms, fetching: 126 ms)

added index: ix_agdc_dataset_location_dataset_ref

[2018-12-17 12:18:33] 7 rows retrieved starting from 1 in 132 ms (execution: 101 ms, fetching: 31 ms)
[2018-12-17 13:06:53] 5 rows retrieved starting from 1 in 531 ms (execution: 484 ms, fetching: 47 ms)

agdc.dataset.dataset_type_ref = 20
[2018-12-17 13:26:03] 5 rows retrieved starting from 1 in 406 ms (execution: 359 ms, fetching: 47 ms)

agdc.dataset.dataset_type_ref = 21
[2018-12-17 13:26:46] 5 rows retrieved starting from 1 in 639 ms (execution: 592 ms, fetching: 47 ms)


deleting dix_ls7_nbar_albers_time_lat_lon
deleting dix_ls7_nbar_albers_lat_lon_time
[2018-12-17 13:32:54] 5 rows retrieved starting from 1 in 3 m 15 s 642 ms (execution: 3 m 15 s 627 ms, fetching: 15 ms)
[2018-12-17 13:39:55] 5 rows retrieved starting from 1 in 3 m 12 s 697 ms (execution: 3 m 12 s 666 ms, fetching: 31 ms)
 */

-- auto-generated definition
create index dix_ls7_nbar_albers_time_lat_lon
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
  where ((archived IS NULL) AND (dataset_type_ref = 21));

-- auto-generated definition
create index dix_ls7_nbar_albers_lat_lon_time
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
  where ((archived IS NULL) AND (dataset_type_ref = 21));


-- creating new index
create index dix_0_ls7_nbar_albers_ur_lat
  on agdc.dataset (((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision))
  where ((archived IS NULL) AND (dataset_type_ref = 21));


-----------------------------------------------------------------------------------------------

explain WITH prelim_query AS (
  SELECT
    max((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as max_ul_lat,
    max((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as max_ur_lat,
    max((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision) as max_ll_lat,
    max((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision) as max_lr_lat,
    min((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as min_ul_lat,
    min((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as min_ur_lat,
    min((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision) as min_ll_lat,
    min((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision) as min_lr_lat,
    max((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision) as max_ul_lon,
    max((metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision) as max_ur_lon,
    max((metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision) as max_ll_lon,
    max((metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision) as max_lr_lon,
    min((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision) as min_ul_lon,
    min((metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision) as min_ur_lon,
    min((metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision) as min_ll_lon,
    min((metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision) as min_lr_lon
  FROM agdc.dataset
  WHERE (archived IS NULL)
    AND dataset_type_ref = 21
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('2017-06-01 00:00:00+00', '2017-09-01 00:00:00+00', '[)'))
)
        SELECT agdc.dataset.id,
               agdc.dataset.metadata_type_ref,
               agdc.dataset.dataset_type_ref,
               agdc.dataset.metadata,
               agdc.dataset.archived,
               agdc.dataset.added,
               agdc.dataset.added_by,
               array(
                   (SELECT selected_dataset_location.uri_scheme || ':' || selected_dataset_location.uri_body AS anon_1
                    FROM agdc.dataset_location AS selected_dataset_location
                    WHERE selected_dataset_location.dataset_ref = agdc.dataset.id
                      AND selected_dataset_location.archived IS NULL
                    ORDER BY selected_dataset_location.added DESC, selected_dataset_location.id DESC)) AS uris
        FROM agdc.dataset
        WHERE agdc.dataset.archived IS NULL
          AND (agdc.float8range(least(prelim_query.min_ul_lon,
                                      prelim_query.min_ur_lon,
                                      prelim_query.min_ll_lon,
                                      prelim_query.min_lr_lon
                                  ),
                                greatest(prelim_query.max_ul_lon,
                                         prelim_query.max_ur_lon,
                                         prelim_query.max_ll_lon,
                                         prelim_query.max_lr_lon
                                  ),
                                '[]')
          && agdc.float8range(152.3, 152.34, '[)'))
          AND (agdc.float8range(least(prelim_query.min_ur_lat,
                                      prelim_query.min_lr_lat,
                                      prelim_query.min_ul_lat,
                                      prelim_query.min_ll_lat
                                  ),
                                greatest(prelim_query.max_ur_lat,
                                         prelim_query.max_lr_lat,
                                         prelim_query.max_ul_lat,
                                         prelim_query.max_ll_lat
                                  ),
                                '[]')
          && agdc.float8range(-24.89, -24.85, '[)')
          );


----------------------------------------------------------------

explain SELECT agdc.dataset.id,
               agdc.dataset.metadata_type_ref,
               agdc.dataset.dataset_type_ref,
               agdc.dataset.metadata,
               agdc.dataset.archived,
               agdc.dataset.added,
               agdc.dataset.added_by,
               array(
                   (SELECT selected_dataset_location.uri_scheme || ':' || selected_dataset_location.uri_body AS anon_1
                    FROM agdc.dataset_location AS selected_dataset_location
                    WHERE selected_dataset_location.dataset_ref = agdc.dataset.id
                      AND selected_dataset_location.archived IS NULL
                    ORDER BY selected_dataset_location.added DESC, selected_dataset_location.id DESC)) AS uris
        FROM agdc.dataset
        WHERE agdc.dataset.archived IS NULL
          AND (agdc.float8range(least(SELECT (MIN(
            CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION) FROM agdc.dataset)),
                                      MIN(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS
                                               DOUBLE PRECISION)),
                                      MIN(CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS
                                               DOUBLE PRECISION)),
                                      MIN(CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS
                                               DOUBLE PRECISION))),
                                greatest(MAX(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS
                                                  DOUBLE PRECISION)),
                                         MAX(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS
                                                  DOUBLE PRECISION)),
                                         MAX(CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS
                                                  DOUBLE PRECISION)),
                                         MAX(CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS
                                                  DOUBLE PRECISION))),
                                '[]')
          && agdc.float8range(152.3, 152.34, '[)'))
          AND (agdc.float8range(
                   least(MIN(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION)),
                         MIN(CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION)),
                         MIN(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION)),
                         MIN(CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION))
                     ),
                   greatest(MAX(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION)),
                            MAX(CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION)),
                            MAX(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION)),
                            MAX(CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION))
                     ),
                   '[]')
          && agdc.float8range(-24.89, -24.85, '[)'))
          AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                         agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                         '[]') &&
               tstzrange('2017-06-01 00:00:00+00', '2017-09-01 00:00:00+00', '[)')
          )
          AND agdc.dataset.dataset_type_ref = 21;


/*
creating 8 partial indexes on data_type_ref 21
size before:
74.2 GB (79,684,031,277 bytes)
74.2 GB (79,710,130,176 bytes) on disk
size after:
74.4 GB (79,915,791,363 bytes)
74.4 GB (79,941,890,048 bytes) on disk
*/
create index dix_ul_lat_21 on agdc.dataset (((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = 21;
create index dix_ur_lat_21 on agdc.dataset (((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = 21;
create index dix_ll_lat_21 on agdc.dataset (((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = 21;
create index dix_lr_lat_21 on agdc.dataset (((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = 21;
create index dix_ul_lon_21 on agdc.dataset (((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = 21;
create index dix_ur_lon_21 on agdc.dataset (((metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = 21;
create index dix_ll_lon_21 on agdc.dataset (((metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = 21;
create index dix_lr_lon_21 on agdc.dataset (((metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision)) where (archived IS NULL) and dataset_type_ref = 21;

drop index agdc.dix_ul_lat_21;
drop index agdc.dix_ur_lat_21;
drop index agdc.dix_ll_lat_21;
drop index agdc.dix_lr_lat_21;
drop index agdc.dix_ul_lon_21;
drop index agdc.dix_ur_lon_21;
drop index agdc.dix_ll_lon_21;
drop index agdc.dix_lr_lon_21;



select
  max((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as ul_lat,
  max((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as ur_lat,
  max((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision) as ll_lat,
  max((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision) as lr_lat,
  min((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision) as ul_lat,
  min((metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision) as ur_lat,
  min((metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision) as ll_lat,
  min((metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision) as lr_lat,
  max((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision) as ul_lon,
  max((metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision) as ur_lon,
  max((metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision) as ll_lon,
  max((metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision) as lr_lon,
  min((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision) as ul_lon,
  min((metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision) as ur_lon,
  min((metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision) as ll_lon,
  min((metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision) as lr_lon
from agdc.dataset
where (archived is null)
  and dataset_type_ref = 21;


explain select
          greatest((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision,
                   (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision,
                   (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision,
                   (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision) as max_lat
        from agdc.dataset
        where (archived is null)
          and dataset_type_ref = 21;


select greatest(val, val2, val3)
from agdc.testing_table;


-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
explain select *
FROM agdc.dataset
WHERE agdc.dataset.archived IS NULL
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        '[]')
  && agdc.float8range(152.3, 152.34, '[)'))
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)
                          ),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)
                          ),
                        '[]')
  && agdc.float8range(-24.89, -24.85, '[)'))
  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                 '[]') &&
       tstzrange('2017-06-01 00:00:00+00', '2017-09-01 00:00:00+00', '[)')
  )
  AND agdc.dataset.dataset_type_ref = 21;

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

select dataset_type_ref, count(*) as count
from agdc.dataset
where archived is null
group by dataset_type_ref
order by count desc;

select *
from agdc.dataset_type
where id = 77;

select *
from agdc.dataset
where dataset_type_ref = 77
  and archived is null;


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
  and
      (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision >
      (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision
   or
    (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision >
    (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision
   or
    (metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision <
    (metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision
   or
    (metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision <
    (metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision
;


select *
from agdc.dataset
where greatest((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision,
               (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision,
               (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision,
               (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision) > 33.87
  and least((metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision,
            (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision,
            (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision,
            (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision) < 33.87
  and greatest((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision,
               (metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision,
               (metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision,
               (metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision) > 151.21
  and least((metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision,
            (metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision,
            (metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision,
            (metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision) < 151.21;


select *
from agdc.dataset
where (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision > 33.87
  and (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision > 33.87
  and (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision < 33.87
  and (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision < 33.87
  and (metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision < 151.21
  and (metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision > 151.21
  and (metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision < 151.21
  and (metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision > 151.21;



select dataset_type_ref,count(*)
from agdc.dataset
where (archived is null)
  and
      (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision <
      (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision
   or
    (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision <
    (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision
   or
    (metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision >
    (metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision
   or
    (metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision >
    (metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision
group by dataset_type_ref
;

select *
from agdc.dataset
where (archived is null)
  and
    (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision <
    (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision
;


select dataset_type_ref,count(*)
from agdc.dataset
where (archived is null)
  and
    (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision <
    (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision
group by dataset_type_ref
;


select dataset_type_ref,count(*)
from agdc.dataset
where (archived is null)
  and
    (metadata #>> '{{extent,coord,ul,lon}}'::text[])::double precision <
    (metadata #>> '{{extent,coord,ll,lon}}'::text[])::double precision
group by dataset_type_ref
;


select dataset_type_ref,count(*)
from agdc.dataset
where (archived is null)
  and
    (metadata #>> '{{extent,coord,ur,lon}}'::text[])::double precision <
    (metadata #>> '{{extent,coord,lr,lon}}'::text[])::double precision
group by dataset_type_ref
;


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
;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
-- slow queries
explain SELECT agdc.dataset.id,
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
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
                        '[]') && '[ -36.18348132582486, -35.22313291663772)')
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        '[]') && '[137.19710243283376,138.4442681122013)')
  AND agdc.dataset.dataset_type_ref = 92;


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
  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')), '[]') &&
       tstzrange('2018-01-01T00:00:00+00:00'::timestamptz, '2018-12-01T23:59:59.999999+00:00'::timestamptz, '[)'))
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
                        '[]') @> CAST(-35.77 AS DOUBLE PRECISION))
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        '[]') && '[44.27,144.27)')
  AND agdc.dataset.dataset_type_ref = 92;


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
       tstzrange('2013-01-01T00:00:00+00:00'::timestamptz, '2018-12-31T23:59:59.999999+00:00'::timestamptz, '[)'))
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
                        '[]') && '[ -31.341862288997746, -31.340612711002255)')
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        '[]') && '[121.64698252709579,121.64870963957088)')
  AND agdc.dataset.dataset_type_ref = 16;


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
       tstzrange('2013-01-01T00:00:00+00:00'::timestamptz, '2018-12-31T23:59:59.999999+00:00'::timestamptz, '[)'))
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
                        '[]') && '[ -30.58522062233108, -30.58383437766892)')
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        '[]') && '[115.154974564771,115.15649043522902)')
  AND agdc.dataset.dataset_type_ref = 16;



--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-- trying to get local to use the correct index for simple query

----------------------


--- temporarily disable using an index in query:
select * from pg_index where indisvalid = false;

update pg_index set indisvalid = true where indisvalid = false; --

update pg_index set indisvalid = false where indexrelid = 3356677; -- where indisvalid = false; --

select indexrelid from pg_statio_all_indexes where indexrelname = 'dix_0dataset_type_ul_lat';


-----


explain select *
FROM agdc.dataset
WHERE (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)
                          ),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)
                          ),
                        '[]')
  && agdc.float8range(-24.89, -24.85, '[)'))
  AND (agdc.float8range(least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                              CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
                        '[]')
  && agdc.float8range(152.3, 152.34, '[)'))
  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                 '[]') &&
       tstzrange('2017-06-01 00:00:00+00', '2017-09-01 00:00:00+00', '[)')
  )
  AND agdc.dataset.archived IS NULL
  AND agdc.dataset.dataset_type_ref = 21
limit 5;



---

analyze;

show search_path ;

vacuum;

show default_statistics_target ;  -- default value is 100

analyse agdc.dataset;

set default_statistics_target = 1000; -- default 100

set enable_seqscan = off; -- default on
set enable_bitmapscan = off; -- default on

show enable_seqscan;

select * from pg_stats;

reindex index agdc.dix_ls7_nbar_albers_lat_lon_time;

show enable_indexscan;

SET seq_page_cost = 2;


-- auto-generated definition
create index tix_active_dataset_type
  on agdc.dataset (dataset_type_ref)
  where (archived IS NULL);



select * from pg_index where indisvalid = false;

show seq_page_cost ;

show random_page_cost ;

set random_page_cost = 2;


-- using dix_0greatest_lon time: > 30 min

-- finally using expected index: > 25 min

-- todo: vacuum analyze

vacuum analyze;

show work_mem;

set work_mem = '64MB';

show temp_file_limit;

set temp_file_limit = '8GB';

show shared_buffers;


-- todo:

VACUUM FULL ANALYZE;