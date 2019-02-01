------
-- Q1
------
EXPLAIN ANALYSE
  SELECT agdc.dataset.id,
         agdc.dataset.metadata_type_ref,
         agdc.dataset.dataset_type_ref,
         agdc.dataset.metadata,
         agdc.dataset.archived,
         agdc.dataset.added,
         agdc.dataset.added_by,
         array(
             (SELECT selected_dataset_location.uri_scheme || ':' ||
                     selected_dataset_location.uri_body AS anon_1
              FROM agdc.dataset_location AS selected_dataset_location
              WHERE selected_dataset_location.dataset_ref = agdc.dataset.id
                AND selected_dataset_location.archived IS NULL
              ORDER BY selected_dataset_location.added DESC,
                       selected_dataset_location.id DESC)) AS uris
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]')
    && agdc.float8range(152.3, 152.34, '[)'))
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]')
    && agdc.float8range(-24.89, -24.85, '[)'))
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('2017-06-01 00:00:00+00', '2017-09-01 00:00:00+00', '[)')
    )
    AND agdc.dataset.dataset_type_ref = 21;
-- [2019-01-18 09:26:18] 5 rows retrieved starting from 1 in 3 m 21 s 755 ms (execution: 3 m 21 s 443 ms, fetching: 312 ms)
/*
Index Scan using dix_ls7_nbar_albers_time_lat_lon on dataset  (cost=0.41..17.04 rows=1 width=1380) (actual time=140.867..350.567 rows=5 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range))
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=29.031..29.031 rows=1 loops=5)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=28.995..28.997 rows=1 loops=5)
                Index Cond: (dataset_ref = dataset.id)
                Filter: (archived IS NULL)
Planning time: 8506.647 ms
Execution time: 350.769 ms
 */


EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND dataset_type_ref = 21
    AND (agdc.float8range(lat_least, lat_greatest, '[]') &&
         agdc.float8range(-24.89, -24.85, '[)'))
    AND (agdc.float8range(lon_least, lon_greatest, '[]') &&
         agdc.float8range(152.3, 152.34, '[)'))
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('2017-06-01 00:00:00+00', '2017-09-01 00:00:00+00', '[)'))
;
-- [2019-01-18 09:27:16] 5 rows retrieved starting from 1 in 23 s 478 ms (execution: 23 s 462 ms, fetching: 16 ms)
/*
Bitmap Heap Scan on extra_dataset_info  (cost=26737.08..317122.76 rows=1 width=16) (actual time=22439.489..23333.866 rows=5 loops=1)
  Recheck Cond: (dataset_type_ref = 21)
  Filter: ((archived IS NULL) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange))
  Rows Removed by Filter: 1364300
  Heap Blocks: exact=54833
  ->  Bitmap Index Scan on dix_extra_dataset_info_dataset_type_ref  (cost=0.00..26737.08 rows=1447552 width=0) (actual time=1019.572..1019.572 rows=1364305 loops=1)
        Index Cond: (dataset_type_ref = 21)
Planning time: 0.263 ms
Execution time: 23334.458 ms

----------------
with gist index:
----------------
Index Scan using eo_1_time_lat_lon on eo_1_data  (cost=0.42..68.82 rows=1 width=16) (actual time=427.945..1706.958 rows=5 loops=1)
  Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range))
  Filter: (dataset_type_ref = 21)
  Rows Removed by Filter: 59
Planning time: 10424.085 ms
Execution time: 1712.598 ms

Index Scan using eo_1_time_lat_lon on eo_1_data  (cost=0.42..68.82 rows=1 width=16) (actual time=398.320..783.550 rows=5 loops=1)
  Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range))
  Filter: (dataset_type_ref = 21)
  Rows Removed by Filter: 59
Planning time: 0.222 ms
Execution time: 783.593 ms

Bitmap Heap Scan on eo_1_data  (cost=13.91..485.46 rows=10 width=16) (actual time=19724.235..19805.859 rows=5 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range) AND (archived IS NULL))
  Filter: (dataset_type_ref = 21)
  Rows Removed by Filter: 59
  Heap Blocks: exact=58
  ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..13.91 rows=119 width=0) (actual time=19670.986..19670.986 rows=64 loops=1)
        Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range))
Planning time: 0.258 ms
Execution time: 19919.863 ms

 */

------
-- Q2
------

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -36.18348132582486, -35.22313291663772)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[137.19710243283376,138.4442681122013)')
    AND agdc.dataset.dataset_type_ref = 92
;
--[2019-01-18 10:30:10] 1575 rows retrieved starting from 1 in 5 m 12 s 951 ms (execution: 5 m 12 s 861 ms, fetching: 90 ms)
/*
Index Scan using tix_active_dataset_type on dataset  (cost=0.44..1371425.50 rows=59 width=16) (actual time=33797.312..315466.925 rows=1575 loops=1)
  Index Cond: (dataset_type_ref = 92)
  Filter: ((agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range))
  Rows Removed by Filter: 600500
Planning time: 3.225 ms
Execution time: 315467.500 ms

Index Scan using tix_active_dataset_type on dataset  (cost=0.44..1315397.23 rows=58 width=16) (actual time=34966.910..316952.921 rows=1575 loops=1)
  Index Cond: (dataset_type_ref = 92)
  Filter: ((agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range))
  Rows Removed by Filter: 600500
Planning time: 5.879 ms
Execution time: 316953.547 ms

Index Scan using tix_active_dataset_type on dataset  (cost=0.44..1315397.23 rows=58 width=16) (actual time=34165.118..310677.070 rows=1575 loops=1)
  Index Cond: (dataset_type_ref = 92)
  Filter: ((agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range))
  Rows Removed by Filter: 600500
Planning time: 2.948 ms
Execution time: 310677.691 ms

 */

EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND dataset_type_ref = 92
    AND (agdc.float8range(lat_least, lat_greatest, '[]') &&
         '[ -36.18348132582486, -35.22313291663772)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') &&
         '[137.19710243283376,138.4442681122013)')
;
--[2019-01-18 12:57:37] 1575 rows retrieved starting from 1 in 1 s 667 ms (execution: 1 s 634 ms, fetching: 33 ms)
/*
Bitmap Heap Scan on extra_dataset_info  (cost=10762.39..274450.22 rows=56 width=16) (actual time=1412.798..5125.438 rows=1575 loops=1)
  Recheck Cond: (dataset_type_ref = 92)
  Filter: ((archived IS NULL) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range))
  Rows Removed by Filter: 600500
  Heap Blocks: exact=19301
  ->  Bitmap Index Scan on dix_extra_dataset_info_dataset_type_ref  (cost=0.00..10762.38 rows=582659 width=0) (actual time=669.307..669.307 rows=602075 loops=1)
        Index Cond: (dataset_type_ref = 92)
Planning time: 0.236 ms
Execution time: 5126.022 ms

----------------
with gist index:
----------------
Bitmap Heap Scan on eo_1_data  (cost=13524.65..18234.37 rows=1238 width=16) (actual time=225290.756..226020.039 rows=1575 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range) AND (dataset_type_ref = 92) AND (archived IS NULL))
  Heap Blocks: exact=779
  ->  BitmapAnd  (cost=13524.65..13524.65 rows=1238 width=0) (actual time=225282.001..225282.001 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..2347.05 rows=33863 width=0) (actual time=224843.147..224843.147 rows=82999 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..11176.73 rows=604840 width=0) (actual time=431.762..431.762 rows=602075 loops=1)
              Index Cond: (dataset_type_ref = 92)
Planning time: 0.491 ms
Execution time: 226021.306 ms


 */

------
-- Q3
------

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(least(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                         agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, center_dt}'))),
                   greatest(
                       agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                       agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, center_dt}'))),
                   '[]') &&
         tstzrange('2013-01-01T00:00:00+00:00'::timestamptz,
                   '2018-12-31T23:59:59.999999+00:00'::timestamptz,
                   '[)'))
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -31.341862288997746, -31.340612711002255)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[121.64698252709579,121.64870963957088)')
    AND agdc.dataset.dataset_type_ref = 16;
-- [2019-01-18 13:38:15] 374 rows retrieved starting from 1 in 1 s 189 ms (execution: 1 s 161 ms, fetching: 28 ms)
/*
Index Scan using dix_ls8_nbart_scene_time_lat_lon on dataset  (cost=0.28..8.30 rows=1 width=16) (actual time=69.885..1816.279 rows=374 loops=1)
  Index Cond: ((tstzrange(LEAST(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,center_dt}'::text[]))), GREATEST(agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,center_dt}'::text[]))), '[]'::text) && '["2013-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-31.341862288997746,-31.340612711002255)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[121.64698252709579,121.64870963957088)'::agdc.float8range))
Planning time: 3.534 ms
Execution time: 1816.463 ms

Index Scan using dix_ls8_nbart_scene_time_lat_lon on dataset  (cost=0.28..8.30 rows=1 width=16) (actual time=98.659..3067.662 rows=374 loops=1)
  Index Cond: ((tstzrange(LEAST(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,center_dt}'::text[]))), GREATEST(agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,center_dt}'::text[]))), '[]'::text) && '["2013-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-31.341862288997746,-31.340612711002255)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[121.64698252709579,121.64870963957088)'::agdc.float8range))
Planning time: 3.449 ms
Execution time: 3067.853 ms

 */

EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]')
    && tstzrange('2013-01-01T00:00:00+00:00'::timestamptz,
                 '2018-12-31T23:59:59.999999+00:00'::timestamptz,
                 '[)'))
    AND (agdc.float8range(lat_least, lat_greatest, '[]') &&
         '[ -31.341862288997746, -31.340612711002255)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') &&
         '[121.64698252709579,121.64870963957088)')
    AND dataset_type_ref = 16;
-- [2019-01-18 13:42:16] 374 rows retrieved starting from 1 in 5 s 190 ms (execution: 5 s 177 ms, fetching: 13 ms)
/*
Index Scan using dix_extra_dataset_info_dataset_type_ref on extra_dataset_info  (cost=0.44..119200.64 rows=1 width=16) (actual time=570.700..4856.767 rows=374 loops=1)
  Index Cond: (dataset_type_ref = 16)
  Filter: ((archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["2013-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-31.341862288997746,-31.340612711002255)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[121.64698252709579,121.64870963957088)'::agdc.float8range))
  Rows Removed by Filter: 70991
Planning time: 0.199 ms
Execution time: 4856.852 ms

----------------
with gist index:
----------------
Index Scan using eo_1_time_lat_lon on eo_1_data  (cost=0.42..68.82 rows=1 width=16) (actual time=38663.924..38663.924 rows=0 loops=1)
  Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2013-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-31.341862288997746,-31.340612711002255)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[121.64698252709579,121.64870963957088)'::agdc.float8range))
  Filter: (dataset_type_ref = 16)
  Rows Removed by Filter: 2515
Planning time: 0.166 ms
Execution time: 38663.981 ms

Bitmap Heap Scan on eo_1_data  (cost=447.48..455.52 rows=2 width=16) (actual time=301.669..301.669 rows=0 loops=1)
  Recheck Cond: ((dataset_type_ref = 16) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["2013-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-31.341862288997746,-31.340612711002255)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[121.64698252709579,121.64870963957088)'::agdc.float8range) AND (archived IS NULL))
  ->  BitmapAnd  (cost=447.48..447.48 rows=2 width=0) (actual time=301.666..301.666 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_dataset_type_ref  (cost=0.00..187.58 rows=10019 width=0) (actual time=301.663..301.663 rows=0 loops=1)
              Index Cond: (dataset_type_ref = 16)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..259.66 rows=3139 width=0) (never executed)
              Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2013-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-31.341862288997746,-31.340612711002255)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[121.64698252709579,121.64870963957088)'::agdc.float8range))
Planning time: 0.231 ms
Execution time: 301.723 ms


 */

------
-- Q4
------

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('2017-01-01T00:00:00+00:00'::timestamptz,
                   '2018-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND agdc.dataset.dataset_type_ref = 19;
--[2019-01-18 14:24:32] 112381 rows retrieved starting from 1 in 4 m 45 s 930 ms (execution: 4 m 45 s 10 ms, fetching: 920 ms)
/*
Index Scan using dix_ls8_nbar_albers_time_lat_lon on dataset  (cost=0.41..28643.17 rows=7015 width=16) (actual time=136.989..283446.958 rows=112381 loops=1)
  Index Cond: (tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange)
Planning time: 3.975 ms
Execution time: 283468.574 ms

Index Scan using dix_ls8_nbar_albers_time_lat_lon on dataset  (cost=0.41..25445.31 rows=6223 width=16) (actual time=416.428..286950.513 rows=112381 loops=1)
  Index Cond: (tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange)
Planning time: 2.346 ms
Execution time: 286973.741 ms

 */

EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('2017-01-01T00:00:00+00:00'::timestamptz,
                   '2018-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND dataset_type_ref = 19;
--[2019-01-18 14:29:34] 112381 rows retrieved starting from 1 in 8 s 456 ms (execution: 7 s 863 ms, fetching: 593 ms)
/*
Bitmap Heap Scan on extra_dataset_info  (cost=11956.43..273861.46 rows=6182 width=16) (actual time=1475.462..16599.671 rows=112381 loops=1)
  Recheck Cond: (dataset_type_ref = 19)
  Filter: ((archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange))
  Rows Removed by Filter: 584593
  Heap Blocks: exact=32919
  ->  Bitmap Index Scan on dix_extra_dataset_info_dataset_type_ref  (cost=0.00..11954.88 rows=647259 width=0) (actual time=516.249..516.249 rows=696974 loops=1)
        Index Cond: (dataset_type_ref = 19)
Planning time: 0.245 ms
Execution time: 16605.596 ms

----------------
with gist index:
----------------
Bitmap Heap Scan on eo_1_data  (cost=25793.24..50427.58 rows=7095 width=16) (actual time=23042.319..28174.769 rows=112381 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange) AND (archived IS NULL) AND (dataset_type_ref = 19))
  Heap Blocks: exact=11593
  ->  BitmapAnd  (cost=25793.24..25793.24 rows=7095 width=0) (actual time=23040.532..23040.532 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..12179.27 rows=159314 width=0) (actual time=22924.222..22924.223 rows=1152077 loops=1)
              Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange)
        ->  Bitmap Index Scan on eo_1_dataset_type_ref_all  (cost=0.00..13610.17 rows=736765 width=0) (actual time=104.644..104.644 rows=696974 loops=1)
              Index Cond: (dataset_type_ref = 19)
Planning time: 0.281 ms
Execution time: 28181.943 ms

Bitmap Heap Scan on eo_1_data  (cost=25793.24..50427.58 rows=7095 width=16) (actual time=6090.656..6359.286 rows=112381 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange) AND (archived IS NULL) AND (dataset_type_ref = 19))
  Heap Blocks: exact=11593
  ->  BitmapAnd  (cost=25793.24..25793.24 rows=7095 width=0) (actual time=6088.877..6088.877 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..12179.27 rows=159314 width=0) (actual time=6009.285..6009.285 rows=1152077 loops=1)
              Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange)
        ->  Bitmap Index Scan on eo_1_dataset_type_ref_all  (cost=0.00..13610.17 rows=736765 width=0) (actual time=67.763..67.763 rows=696974 loops=1)
              Index Cond: (dataset_type_ref = 19)
Planning time: 0.267 ms
Execution time: 6362.658 ms

Bitmap Heap Scan on eo_1_data  (cost=58263.89..181317.02 rows=48782 width=16) (actual time=57503.125..64742.900 rows=112381 loops=1)
  Recheck Cond: ((dataset_type_ref = 19) AND (archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange))
  Heap Blocks: exact=11593
  ->  BitmapAnd  (cost=58263.89..58263.89 rows=48782 width=0) (actual time=57483.447..57483.447 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..12322.72 rows=666971 width=0) (actual time=694.606..694.606 rows=582244 loops=1)
              Index Cond: (dataset_type_ref = 19)
        ->  Bitmap Index Scan on eo_1_pure_time  (cost=0.00..45916.53 rows=1210148 width=0) (actual time=56778.259..56778.259 rows=1174301 loops=1)
              Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange)
Planning time: 0.210 ms
Execution time: 64749.292 ms


 */

------
-- Q5
------

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('2018-01-01T00:00:00+00:00'::timestamptz,
                   '2018-12-31T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND agdc.dataset.dataset_type_ref = 77;
--[2019-01-18 14:37:30] 129669 rows retrieved starting from 1 in 4 m 16 s 566 ms (execution: 4 m 16 s 36 ms, fetching: 530 ms)
/*
Bitmap Heap Scan on dataset  (cost=48895.22..4816291.12 rows=26470 width=16) (actual time=2394.379..259430.552 rows=129669 loops=1)
  Recheck Cond: ((dataset_type_ref = 77) AND (archived IS NULL))
  Filter: (tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
  Rows Removed by Filter: 2637408
  Heap Blocks: exact=664025
  ->  Bitmap Index Scan on tix_active_dataset_type  (cost=0.00..48888.61 rows=2646956 width=0) (actual time=2152.454..2152.454 rows=2767077 loops=1)
        Index Cond: (dataset_type_ref = 77)
Planning time: 2.682 ms
Execution time: 259444.848 ms

Index Scan using dix_wofs_albers_time_lat_lon on dataset  (cost=0.41..104983.32 rows=25766 width=16) (actual time=44.865..267677.015 rows=129669 loops=1)
  Index Cond: (tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
Planning time: 836.768 ms
Execution time: 267703.443 ms

 */

EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('2018-01-01T00:00:00+00:00'::timestamptz,
                   '2018-12-31T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND dataset_type_ref = 77;
--[2019-01-18 14:39:30] 129669 rows retrieved starting from 1 in 29 s 422 ms (execution: 28 s 860 ms, fetching: 562 ms)
/*
Bitmap Heap Scan on extra_dataset_info  (cost=49966.89..347883.55 rows=25837 width=16) (actual time=171.359..1261.711 rows=129669 loops=1)
  Recheck Cond: (dataset_type_ref = 77)
  Filter: ((archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange))
  Rows Removed by Filter: 2637762
  Heap Blocks: exact=81977
  ->  Bitmap Index Scan on dix_extra_dataset_info_dataset_type_ref  (cost=0.00..49960.43 rows=2705066 width=0) (actual time=155.854..155.854 rows=2767431 loops=1)
        Index Cond: (dataset_type_ref = 77)
Planning time: 0.230 ms
Execution time: 1264.222 ms

----------------
with gist index:
----------------
Bitmap Heap Scan on eo_1_data  (cost=63048.42..140524.75 rows=26515 width=16) (actual time=36946.103..40582.296 rows=129669 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (archived IS NULL) AND (dataset_type_ref = 77))
  Heap Blocks: exact=9302
  ->  BitmapAnd  (cost=63048.42..63048.42 rows=26515 width=0) (actual time=36944.796..36944.796 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..12179.27 rows=159314 width=0) (actual time=36715.050..36715.050 rows=1172237 loops=1)
              Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
        ->  Bitmap Index Scan on eo_1_dataset_type_ref_all  (cost=0.00..50855.64 rows=2753494 width=0) (actual time=222.194..222.194 rows=2767431 loops=1)
              Index Cond: (dataset_type_ref = 77)
Planning time: 0.185 ms
Execution time: 40589.104 ms


--
Bitmap Heap Scan on eo_1_data  (cost=52947.29..331763.90 rows=220715 width=16) (actual time=35466.247..52931.692 rows=129669 loops=1)
  Recheck Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
  Filter: ((archived IS NULL) AND (dataset_type_ref = 77))
  Rows Removed by Filter: 1241677
  Heap Blocks: exact=44619
  ->  Bitmap Index Scan on eo_1_pure_time  (cost=0.00..52892.11 rows=1394092 width=0) (actual time=35282.094..35282.094 rows=1371346 loops=1)
        Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
Planning time: 0.225 ms
Execution time: 52938.966 ms

 */

------
-- Q6
------

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                   '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[140.70680860879938,140.90732842760332)')
    AND agdc.dataset.dataset_type_ref = 29;
/*
Index Scan using dix_ls7_nbart_albers_time_lat_lon on dataset  (cost=0.41..8.43 rows=1 width=16) (actual time=0.488..14614.146 rows=1520 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
Planning time: 3.141 ms
Execution time: 14615.800 ms

Index Scan using dix_ls7_nbart_albers_time_lat_lon on dataset  (cost=0.41..8.43 rows=1 width=16) (actual time=193.991..35751.329 rows=1520 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
Planning time: 3.445 ms
Execution time: 35752.087 ms


 */


EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]')
    && tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                 '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND (agdc.float8range(lat_least, lat_greatest, '[]') &&
         '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') &&
         '[140.70680860879938,140.90732842760332)')
    AND dataset_type_ref = 29;
/*
Bitmap Heap Scan on extra_dataset_info  (cost=25634.21..314381.35 rows=1 width=16) (actual time=90.584..957.972 rows=1520 loops=1)
  Recheck Cond: (dataset_type_ref = 29)
  Filter: ((archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
  Rows Removed by Filter: 1355830
  Heap Blocks: exact=44367
  ->  Bitmap Index Scan on dix_extra_dataset_info_dataset_type_ref  (cost=0.00..25634.21 rows=1387969 width=0) (actual time=79.841..79.841 rows=1357350 loops=1)
        Index Cond: (dataset_type_ref = 29)
Planning time: 0.182 ms
Execution time: 958.458 ms

----------------
with gist index:
----------------
Index Scan using eo_1_time_lat_lon on eo_1_data  (cost=0.42..68.82 rows=1 width=16) (actual time=207.984..295584.248 rows=1520 loops=1)
  Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
  Filter: (dataset_type_ref = 29)
  Rows Removed by Filter: 26521
Planning time: 124.705 ms
Execution time: 295584.801 ms

Bitmap Heap Scan on eo_1_data  (cost=25069.28..28770.05 rows=954 width=16) (actual time=162734.529..185033.199 rows=1520 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 29) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1443
  ->  BitmapAnd  (cost=25069.28..25069.28 rows=964 width=0) (actual time=162726.914..162726.914 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..841.82 rows=12140 width=0) (actual time=156176.210..156176.210 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..24226.74 rows=1313374 width=0) (actual time=6544.607..6544.607 rows=1288777 loops=1)
              Index Cond: (dataset_type_ref = 29)
Planning time: 89.167 ms
Execution time: 185034.896 ms

--
Bitmap Heap Scan on eo_1_data  (cost=25656.09..29345.61 rows=951 width=16) (actual time=183072.856..184421.631 rows=1520 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 29) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1443
  ->  BitmapAnd  (cost=25656.09..25656.09 rows=961 width=0) (actual time=183064.957..183064.957 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..822.70 rows=11828 width=0) (actual time=182132.245..182132.245 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..24832.67 rows=1344031 width=0) (actual time=927.301..927.301 rows=1288777 loops=1)
              Index Cond: (dataset_type_ref = 29)
Planning time: 0.225 ms
Execution time: 184422.665 ms

 */

------
-- Q7
------

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('2018-01-01T00:00:00+00:00'::timestamptz,
                   '2018-12-31T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND agdc.dataset.dataset_type_ref = 77;
/*
Bitmap Heap Scan on dataset  (cost=48895.22..5043933.12 rows=26470 width=1380) (actual time=2121.113..935482.731 rows=129669 loops=1)
  Recheck Cond: ((dataset_type_ref = 77) AND (archived IS NULL))
  Filter: (tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
  Rows Removed by Filter: 2637408
  Heap Blocks: exact=664025
  ->  Bitmap Index Scan on tix_active_dataset_type  (cost=0.00..48888.61 rows=2646956 width=0) (actual time=1912.266..1912.266 rows=2767077 loops=1)
        Index Cond: (dataset_type_ref = 77)
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=5.077..5.077 rows=1 loops=129669)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=5.056..5.065 rows=1 loops=129669)
                Index Cond: (dataset_ref = dataset.id)
                Filter: (archived IS NULL)
Planning time: 2.701 ms
Execution time: 935521.206 ms

Bitmap Heap Scan on dataset  (cost=48895.22..4816291.12 rows=26470 width=16) (actual time=2058.480..254296.947 rows=129669 loops=1)
  Recheck Cond: ((dataset_type_ref = 77) AND (archived IS NULL))
  Filter: (tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
  Rows Removed by Filter: 2637408
  Heap Blocks: exact=664025
  ->  Bitmap Index Scan on tix_active_dataset_type  (cost=0.00..48888.61 rows=2646956 width=0) (actual time=1852.155..1852.155 rows=2767077 loops=1)
        Index Cond: (dataset_type_ref = 77)
Planning time: 2.367 ms
Execution time: 254311.442 ms

 */


EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('2018-01-01T00:00:00+00:00'::timestamptz,
                   '2018-12-31T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND dataset_type_ref = 77;
/*
Bitmap Heap Scan on extra_dataset_info  (cost=49966.89..347883.55 rows=25837 width=16) (actual time=2013.564..31066.559 rows=129669 loops=1)
  Recheck Cond: (dataset_type_ref = 77)
  Filter: ((archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange))
  Rows Removed by Filter: 2637762
  Heap Blocks: exact=81977
  ->  Bitmap Index Scan on dix_extra_dataset_info_dataset_type_ref  (cost=0.00..49960.43 rows=2705066 width=0) (actual time=1877.401..1877.401 rows=2767431 loops=1)
        Index Cond: (dataset_type_ref = 77)
Planning time: 0.209 ms
Execution time: 31071.451 ms

----------------
with gist index:
----------------
Bitmap Heap Scan on eo_1_data  (cost=50567.84..328285.94 rows=218086 width=16) (actual time=36067.354..53910.148 rows=129669 loops=1)
  Recheck Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
  Filter: ((archived IS NULL) AND (dataset_type_ref = 77))
  Rows Removed by Filter: 1241677
  Heap Blocks: exact=44619
  ->  Bitmap Index Scan on eo_1_pure_time  (cost=0.00..50513.32 rows=1331320 width=0) (actual time=35901.078..35901.078 rows=1371346 loops=1)
        Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
Planning time: 1842.031 ms
Execution time: 53916.836 ms

 */

------
-- Q8
------

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                   '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[140.70680860879938,140.90732842760332)')
    AND agdc.dataset.dataset_type_ref = 23;
/*
Index Scan using dix_ls5_pq_albers_time_lat_lon on dataset  (cost=0.41..8.43 rows=1 width=16) (actual time=431.298..33334.859 rows=1416 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
Planning time: 3.468 ms
Execution time: 33335.666 ms
--
Index Scan using dix_ls5_pq_albers_time_lat_lon on dataset  (cost=0.41..8.43 rows=1 width=16) (actual time=427.614..32217.692 rows=1416 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
Planning time: 3.534 ms
Execution time: 32218.437 ms

 */


EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                   '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND (agdc.float8range(lat_least, lat_greatest, '[]') &&
         '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') &&
         '[140.70680860879938,140.90732842760332)')
    AND dataset_type_ref = 23;
/*
Bitmap Heap Scan on extra_dataset_info  (cost=21490.20..304062.66 rows=1 width=16) (actual time=951.098..15078.858 rows=1416 loops=1)
  Recheck Cond: (dataset_type_ref = 23)
  Filter: ((archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
  Rows Removed by Filter: 1131615
  Heap Blocks: exact=43975
  ->  Bitmap Index Scan on dix_extra_dataset_info_dataset_type_ref  (cost=0.00..21490.20 rows=1163435 width=0) (actual time=835.787..835.787 rows=1133031 loops=1)
        Index Cond: (dataset_type_ref = 23)
Planning time: 0.203 ms
Execution time: 15079.824 ms

----------------
with gist index:
----------------
Bitmap Heap Scan on eo_1_data  (cost=20452.57..23347.28 rows=742 width=16) (actual time=182692.171..184387.191 rows=1416 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 23) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1377
  ->  BitmapAnd  (cost=20452.57..20452.57 rows=750 width=0) (actual time=182678.115..182678.115 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..809.07 rows=11665 width=0) (actual time=181884.253..181884.253 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..19642.89 rows=1063260 width=0) (actual time=789.090..789.090 rows=1126844 loops=1)
              Index Cond: (dataset_type_ref = 23)
Planning time: 428.821 ms
Execution time: 184388.114 ms

--
--

Bitmap Heap Scan on eo_1_data  (cost=20021.91..22890.13 rows=736 width=16) (actual time=1592.454..3309.975 rows=1416 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 23) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1377
  ->  BitmapAnd  (cost=20021.91..20021.91 rows=743 width=0) (actual time=1584.454..1584.454 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..822.70 rows=11828 width=0) (actual time=510.438..510.438 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..19198.59 rows=1039221 width=0) (actual time=1067.636..1067.636 rows=1126844 loops=1)
              Index Cond: (dataset_type_ref = 23)
Planning time: 0.227 ms
Execution time: 3310.775 ms

 */

------
-- Q9
------

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                   '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[140.70680860879938,140.90732842760332)')
    AND agdc.dataset.dataset_type_ref = 26;
/*
Index Scan using dix_ls5_nbart_albers_time_lat_lon on dataset  (cost=0.41..8.43 rows=1 width=16) (actual time=247.772..31542.876 rows=1414 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
Planning time: 3.319 ms
Execution time: 31543.627 ms

--

Index Scan using dix_ls5_nbart_albers_time_lat_lon on dataset  (cost=0.41..8.43 rows=1 width=16) (actual time=490.661..31761.114 rows=1414 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
Planning time: 3.404 ms
Execution time: 31761.855 ms


 */

EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                   '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND (agdc.float8range(lat_least, lat_greatest, '[]') &&
         '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') &&
         '[140.70680860879938,140.90732842760332)')
    AND dataset_type_ref = 26;
/*
Bitmap Heap Scan on extra_dataset_info  (cost=21247.42..303457.68 rows=1 width=16) (actual time=1339.828..7547.701 rows=1414 loops=1)
  Recheck Cond: (dataset_type_ref = 26)
  Filter: ((archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
  Rows Removed by Filter: 1176414
  Heap Blocks: exact=24129
  ->  Bitmap Index Scan on dix_extra_dataset_info_dataset_type_ref  (cost=0.00..21247.42 rows=1150264 width=0) (actual time=903.406..903.406 rows=1177828 loops=1)
        Index Cond: (dataset_type_ref = 26)
Planning time: 0.171 ms
Execution time: 7548.421 ms

----------------
with gist index:
----------------
Bitmap Heap Scan on eo_1_data  (cost=21938.58..25086.41 rows=809 width=16) (actual time=1580.627..2928.749 rows=1414 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 26) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1371
  ->  BitmapAnd  (cost=21938.58..21938.58 rows=817 width=0) (actual time=1561.626..1561.626 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..822.70 rows=11828 width=0) (actual time=506.196..506.196 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..21115.23 rows=1142772 width=0) (actual time=1052.534..1052.535 rows=1171328 loops=1)
              Index Cond: (dataset_type_ref = 26)
Planning time: 0.295 ms
Execution time: 2929.513 ms

--

Bitmap Heap Scan on eo_1_data  (cost=21938.58..25086.41 rows=809 width=16) (actual time=1564.440..3112.143 rows=1414 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 26) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1371
  ->  BitmapAnd  (cost=21938.58..21938.58 rows=817 width=0) (actual time=1549.066..1549.066 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..822.70 rows=11828 width=0) (actual time=474.276..474.276 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..21115.23 rows=1142772 width=0) (actual time=1070.264..1070.264 rows=1171328 loops=1)
              Index Cond: (dataset_type_ref = 26)
Planning time: 0.284 ms
Execution time: 3113.055 ms

 */

------
-- Q10
------

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                   '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[140.70680860879938,140.90732842760332)')
    AND agdc.dataset.dataset_type_ref = 22;
/*
Index Scan using dix_ls7_pq_albers_time_lat_lon on dataset  (cost=0.41..8.43 rows=1 width=16) (actual time=170.630..37042.046 rows=1520 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
Planning time: 3.123 ms
Execution time: 37042.889 ms

--

Index Scan using dix_ls7_pq_albers_time_lat_lon on dataset  (cost=0.41..8.43 rows=1 width=16) (actual time=172.399..36309.261 rows=1520 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
Planning time: 4.106 ms
Execution time: 36310.004 ms

 */

EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                   '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
    AND (agdc.float8range(lat_least, lat_greatest, '[]') &&
         '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') &&
         '[140.70680860879938,140.90732842760332)')
    AND dataset_type_ref = 22;
/*
Bitmap Heap Scan on extra_dataset_info  (cost=24429.00..311382.37 rows=1 width=16) (actual time=947.834..12518.480 rows=1520 loops=1)
  Recheck Cond: (dataset_type_ref = 22)
  Filter: ((archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
  Rows Removed by Filter: 1315326
  Heap Blocks: exact=47421
  ->  Bitmap Index Scan on dix_extra_dataset_info_dataset_type_ref  (cost=0.00..24428.99 rows=1322741 width=0) (actual time=908.811..908.811 rows=1316846 loops=1)
        Index Cond: (dataset_type_ref = 22)
Planning time: 0.215 ms
Execution time: 12519.420 ms

----------------
with gist index:
----------------
Bitmap Heap Scan on eo_1_data  (cost=25584.21..29262.48 rows=949 width=16) (actual time=1351.730..3148.224 rows=1520 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 22) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1382
  ->  BitmapAnd  (cost=25584.21..25584.21 rows=958 width=0) (actual time=1351.438..1351.438 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..822.70 rows=11828 width=0) (actual time=463.915..463.915 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..24760.79 rows=1340314 width=0) (actual time=883.827..883.827 rows=1240589 loops=1)
              Index Cond: (dataset_type_ref = 22)
Planning time: 0.251 ms
Execution time: 3149.131 ms

--

Bitmap Heap Scan on eo_1_data  (cost=25584.21..29262.48 rows=949 width=16) (actual time=1388.494..3354.546 rows=1520 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 22) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1382
  ->  BitmapAnd  (cost=25584.21..25584.21 rows=958 width=0) (actual time=1374.878..1374.879 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..822.70 rows=11828 width=0) (actual time=460.287..460.288 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..24760.79 rows=1340314 width=0) (actual time=909.349..909.349 rows=1240589 loops=1)
              Index Cond: (dataset_type_ref = 22)
Planning time: 0.326 ms
Execution time: 3355.517 ms

 */

-----
-- 11
-----

explain analyse
  SELECT agdc.dataset.id,
         agdc.dataset.metadata_type_ref,
         agdc.dataset.dataset_type_ref,
         agdc.dataset.metadata,
         agdc.dataset.archived,
         agdc.dataset.added,
         agdc.dataset.added_by,
         array(
             (SELECT selected_dataset_location.uri_scheme || ':' ||
                     selected_dataset_location.uri_body AS anon_1
              FROM agdc.dataset_location AS selected_dataset_location
              WHERE selected_dataset_location.dataset_ref = agdc.dataset.id
                AND selected_dataset_location.archived IS NULL
              ORDER BY selected_dataset_location.added DESC,
                       selected_dataset_location.id DESC)) AS uris
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                   '2019-01-01T23:59:59.999999+00:00'::timestamptz,
                   '[)'))
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[140.70680860879938,140.90732842760332)')
    AND agdc.dataset.dataset_type_ref = 22;

/*
Index Scan using dix_ls7_pq_albers_time_lat_lon on dataset  (cost=0.41..17.04 rows=1 width=1389) (actual time=71.081..19311.136 rows=1520 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=12.462..12.462 rows=1 loops=1520)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=12.445..12.449 rows=1 loops=1520)
                Index Cond: (dataset_ref = dataset.id)
                Filter: (archived IS NULL)
Planning time: 837.986 ms
Execution time: 19312.046 ms

 */

explain analyse
  SELECT agdc.eo_1_data.id,
         1                                                 as metadata_type_ref,
         agdc.eo_1_data.dataset_type_ref,
         --metadata,
         agdc.eo_1_data.archived,
         --added,
         --added_by,
         array(
             (SELECT selected_dataset_location.uri_scheme || ':' ||
                     selected_dataset_location.uri_body AS anon_1
              FROM agdc.dataset_location AS selected_dataset_location
              WHERE selected_dataset_location.dataset_ref = agdc.eo_1_data.id
                AND selected_dataset_location.archived IS NULL
              ORDER BY selected_dataset_location.added DESC,
                       selected_dataset_location.id DESC)) AS uris
  FROM agdc.eo_1_data
  WHERE agdc.eo_1_data.archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                   '2019-01-01T23:59:59.999999+00:00'::timestamptz,
                   '[)'))
    AND (agdc.float8range(lat_least, lat_greatest, '[]') && '[ -17.5544592474921, -17.361457459231584)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') && '[140.70680860879938,140.90732842760332)')
    AND agdc.eo_1_data.dataset_type_ref = 22;

/*
Bitmap Heap Scan on eo_1_data  (cost=25584.21..37423.88 rows=949 width=62) (actual time=524.140..566.105 rows=1520 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 22) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1382
  ->  BitmapAnd  (cost=25584.21..25584.21 rows=958 width=0) (actual time=523.895..523.895 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..822.70 rows=11828 width=0) (actual time=449.315..449.315 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..24760.79 rows=1340314 width=0) (actual time=71.117..71.117 rows=1240589 loops=1)
              Index Cond: (dataset_type_ref = 22)
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=0.008..0.009 rows=1 loops=1520)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=0.005..0.006 rows=1 loops=1520)
                Index Cond: (dataset_ref = eo_1_data.id)
                Filter: (archived IS NULL)
Planning time: 0.337 ms
Execution time: 566.529 ms

Bitmap Heap Scan on eo_1_data  (cost=25584.21..37423.88 rows=949 width=62) (actual time=634.979..655.101 rows=1520 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 22) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1382
  ->  BitmapAnd  (cost=25584.21..25584.21 rows=958 width=0) (actual time=634.709..634.709 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..822.70 rows=11828 width=0) (actual time=526.434..526.434 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..24760.79 rows=1340314 width=0) (actual time=104.209..104.209 rows=1240589 loops=1)
              Index Cond: (dataset_type_ref = 22)
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=0.009..0.009 rows=1 loops=1520)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=0.005..0.006 rows=1 loops=1520)
                Index Cond: (dataset_ref = eo_1_data.id)
                Filter: (archived IS NULL)
Planning time: 0.300 ms
Execution time: 655.453 ms

Bitmap Heap Scan on eo_1_data  (cost=25584.21..37423.88 rows=949 width=62) (actual time=528.694..547.280 rows=1520 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range) AND (dataset_type_ref = 22) AND (archived IS NULL))
  Filter: (tstzrange(from_dt, to_dt, '[]'::text) && '["1986-01-01 00:00:00+00","2019-01-01 23:59:59.999999+00")'::tstzrange)
  Heap Blocks: exact=1382
  ->  BitmapAnd  (cost=25584.21..25584.21 rows=958 width=0) (actual time=528.398..528.398 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..822.70 rows=11828 width=0) (actual time=452.178..452.178 rows=60316 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-17.554459247492101,-17.361457459231584)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[140.70680860879938,140.90732842760332)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..24760.79 rows=1340314 width=0) (actual time=72.604..72.604 rows=1240589 loops=1)
              Index Cond: (dataset_type_ref = 22)
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=0.008..0.008 rows=1 loops=1520)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=0.005..0.005 rows=1 loops=1520)
                Index Cond: (dataset_ref = eo_1_data.id)
                Filter: (archived IS NULL)
Planning time: 0.297 ms
Execution time: 547.681 ms

 */

-----
-- 12
-----
EXPLAIN ANALYSE
  SELECT agdc.dataset.id,
         agdc.dataset.metadata_type_ref,
         agdc.dataset.dataset_type_ref,
         agdc.dataset.metadata,
         agdc.dataset.archived,
         agdc.dataset.added,
         agdc.dataset.added_by,
         array((SELECT selected_dataset_location.uri_scheme || ':' ||
                       selected_dataset_location.uri_body AS anon_1
                FROM agdc.dataset_location AS selected_dataset_location
                WHERE selected_dataset_location.dataset_ref = agdc.dataset.id
                  AND selected_dataset_location.archived IS NULL
                ORDER BY selected_dataset_location.added DESC,
                         selected_dataset_location.id DESC)) AS uris
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') && tstzrange('2018-01-01T00:00:00+00:00'::timestamptz,
                                      '2019-01-01T00:00:00.999999+00:00'::timestamptz, '[)'))
    AND agdc.dataset.dataset_type_ref = 28;

/*
Index Scan using dix_ls8_nbart_albers_time_lat_lon on dataset  (cost=0.41..86862.90 rows=6851 width=1389) (actual time=0.410..145340.921 rows=101081 loops=1)
  Index Cond: (tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2018-01-01 00:00:00+00","2019-01-01 00:00:00.999999+00")'::tstzrange)
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=1.040..1.040 rows=1 loops=101081)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=1.030..1.035 rows=1 loops=101081)
                Index Cond: (dataset_ref = dataset.id)
                Filter: (archived IS NULL)
Planning time: 2.244 ms
Execution time: 145348.470 ms

 */

EXPLAIN ANALYSE
  SELECT id,
         1                                                   as metadata_type_ref,
         dataset_type_ref,
         --metadata,
         archived,
         --added,
         --added_by,
         array((SELECT selected_dataset_location.uri_scheme || ':' ||
                       selected_dataset_location.uri_body AS anon_1
                FROM agdc.dataset_location AS selected_dataset_location
                WHERE selected_dataset_location.dataset_ref = agdc.eo_1_data.id
                  AND selected_dataset_location.archived IS NULL
                ORDER BY selected_dataset_location.added DESC,
                         selected_dataset_location.id DESC)) AS uris
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]')
    && tstzrange('2018-01-01T00:00:00+00:00'::timestamptz,
                 '2019-01-01T00:00:00.999999+00:00'::timestamptz, '[)'))
    AND dataset_type_ref = 28;

/*
Bitmap Heap Scan on eo_1_data  (cost=64674.88..657050.91 rows=53602 width=62) (actual time=35240.993..39271.716 rows=101081 loops=1)
  Recheck Cond: ((dataset_type_ref = 28) AND (archived IS NULL) AND (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2019-01-01 00:00:00.999999+00")'::tstzrange))
  Heap Blocks: exact=6392
  ->  BitmapAnd  (cost=64674.88..64674.88 rows=53602 width=0) (actual time=35223.334..35223.334 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..11755.72 rows=636171 width=0) (actual time=424.119..424.119 rows=588528 loops=1)
              Index Cond: (dataset_type_ref = 28)
        ->  Bitmap Index Scan on eo_1_pure_time  (cost=0.00..52892.11 rows=1394092 width=0) (actual time=34787.695..34787.695 rows=1371346 loops=1)
              Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2019-01-01 00:00:00.999999+00")'::tstzrange)
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=0.009..0.009 rows=1 loops=101081)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=0.005..0.005 rows=1 loops=101081)
                Index Cond: (dataset_ref = eo_1_data.id)
                Filter: (archived IS NULL)
Planning time: 0.296 ms
Execution time: 39276.525 ms

 */

-----
-- 13
-----

EXPLAIN ANALYSE
  SELECT agdc.dataset.id,
         agdc.dataset.metadata_type_ref,
         agdc.dataset.dataset_type_ref,
         agdc.dataset.metadata,
         agdc.dataset.archived,
         agdc.dataset.added,
         agdc.dataset.added_by,
         array(
             (SELECT selected_dataset_location.uri_scheme || ':' ||
                     selected_dataset_location.uri_body AS anon_1
              FROM agdc.dataset_location AS selected_dataset_location
              WHERE selected_dataset_location.dataset_ref = agdc.dataset.id
                AND selected_dataset_location.archived IS NULL
              ORDER BY selected_dataset_location.added DESC,
                       selected_dataset_location.id DESC)) AS uris
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
                   '[]') &&
         tstzrange('1990-01-01T00:00:00+00:00'::timestamptz,
                   '2010-01-01T00:00:00.999999+00:00'::timestamptz,
                   '[)'))
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -36.93427801793563, -35.93892563592589)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[145.33805252515648,146.56658225464042)')
    AND agdc.dataset.dataset_type_ref = 23;

/*
Index Scan using dix_ls5_pq_albers_time_lat_lon on dataset  (cost=0.41..17.03 rows=1 width=1389) (actual time=150.015..98273.950 rows=6520 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["1990-01-01 00:00:00+00","2010-01-01 00:00:00.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-36.934278017935632,-35.938925635925891)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[145.33805252515648,146.56658225464042)'::agdc.float8range))
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=4.288..4.288 rows=1 loops=6520)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=4.268..4.274 rows=1 loops=6520)
                Index Cond: (dataset_ref = dataset.id)
                Filter: (archived IS NULL)
Planning time: 3.495 ms
Execution time: 98276.134 ms

 */

EXPLAIN ANALYSE
  SELECT id,
         --metadata_type_ref,
         dataset_type_ref,
         --metadata,
         archived,
         --added,
         --added_by,
         array(
             (SELECT selected_dataset_location.uri_scheme || ':' ||
                     selected_dataset_location.uri_body AS anon_1
              FROM agdc.dataset_location AS selected_dataset_location
              WHERE selected_dataset_location.dataset_ref = agdc.eo_1_data.id
                AND selected_dataset_location.archived IS NULL
              ORDER BY selected_dataset_location.added DESC,
                       selected_dataset_location.id DESC)) AS uris
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('1990-01-01T00:00:00+00:00'::timestamptz,
                   '2010-01-01T00:00:00.999999+00:00'::timestamptz,
                   '[)'))
    AND (agdc.float8range(lat_least, lat_greatest, '[]') && '[ -36.93427801793563, -35.93892563592589)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') && '[145.33805252515648,146.56658225464042)')
    AND dataset_type_ref = 23;

/*
Bitmap Heap Scan on eo_1_data  (cost=20989.67..31460.60 rows=841 width=58) (actual time=599014.535..604916.079 rows=6520 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["1990-01-01 00:00:00+00","2010-01-01 00:00:00.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-36.934278017935632,-35.938925635925891)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[145.33805252515648,146.56658225464042)'::agdc.float8range) AND (archived IS NULL) AND (dataset_type_ref = 23))
  Heap Blocks: exact=5512
  ->  BitmapAnd  (cost=20989.67..20989.67 rows=841 width=0) (actual time=599013.380..599013.381 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..1053.54 rows=12890 width=0) (actual time=598187.568..598187.568 rows=65395 loops=1)
              Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["1990-01-01 00:00:00+00","2010-01-01 00:00:00.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-36.934278017935632,-35.938925635925891)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[145.33805252515648,146.56658225464042)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_pure_dataset_type_ref  (cost=0.00..19935.46 rows=1079336 width=0) (actual time=818.325..818.326 rows=1133031 loops=1)
              Index Cond: (dataset_type_ref = 23)
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=0.024..0.025 rows=1 loops=6520)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=0.014..0.015 rows=1 loops=6520)
                Index Cond: (dataset_ref = eo_1_data.id)
                Filter: (archived IS NULL)
Planning time: 0.332 ms
Execution time: 604976.533 ms

 */

-----
-- 14
-----

EXPLAIN ANALYSE
  SELECT agdc.dataset.id,
         agdc.dataset.metadata_type_ref,
         agdc.dataset.dataset_type_ref,
         agdc.dataset.metadata,
         agdc.dataset.archived,
         agdc.dataset.added,
         agdc.dataset.added_by,
         array(
             (SELECT selected_dataset_location.uri_scheme || ':' ||
                     selected_dataset_location.uri_body AS anon_1
              FROM agdc.dataset_location AS selected_dataset_location
              WHERE selected_dataset_location.dataset_ref = agdc.dataset.id
                AND selected_dataset_location.archived IS NULL
              ORDER BY selected_dataset_location.added DESC, selected_dataset_location.id DESC)) AS uris
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                   agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')), '[]') &&
         tstzrange('2013-01-01T00:00:00+00:00'::timestamptz, '2017-12-31T23:59:59.999999+00:00'::timestamptz,
                   '[)'))
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -18.297260057849503, -17.809563875664207)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                      CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[142.38512915573506,142.89511234985517)')
    AND agdc.dataset.dataset_type_ref = 28;

/*
Index Scan using dix_ls8_nbart_albers_time_lat_lon on dataset  (cost=0.41..17.03 rows=1 width=1389) (actual time=260.080..29452.837 rows=1471 loops=1)
  Index Cond: ((tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2013-01-01 00:00:00+00","2017-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-18.297260057849503,-17.809563875664207)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[142.38512915573506,142.89511234985517)'::agdc.float8range))
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=5.360..5.360 rows=1 loops=1471)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=5.343..5.344 rows=1 loops=1471)
                Index Cond: (dataset_ref = dataset.id)
                Filter: (archived IS NULL)
Planning time: 3.356 ms
Execution time: 29453.347 ms

 */

EXPLAIN ANALYSE
  SELECT id/*,
         --metadata_type_ref,
         dataset_type_ref,
         --metadata,
         archived,
         --added,
         --added_by,
         array(
             (SELECT selected_dataset_location.uri_scheme || ':' ||
                     selected_dataset_location.uri_body AS anon_1
              FROM agdc.dataset_location AS selected_dataset_location
              WHERE selected_dataset_location.dataset_ref = agdc.eo_1_data.id
                AND selected_dataset_location.archived IS NULL
              ORDER BY selected_dataset_location.added DESC, selected_dataset_location.id DESC)) AS uris
*/
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND (tstzrange(from_dt, to_dt, '[]') &&
         tstzrange('2013-01-01T00:00:00+00:00'::timestamptz, '2017-12-31T23:59:59.999999+00:00'::timestamptz,
                   '[)'))
    AND (agdc.float8range(lat_least, lat_greatest, '[]') && '[ -18.297260057849503, -17.809563875664207)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') && '[142.38512915573506,142.89511234985517)')
    AND dataset_type_ref = 28;

/*
Bitmap Heap Scan on eo_1_data  (cost=12922.68..17315.82 rows=351 width=58) (actual time=393660.251..395246.744 rows=1471 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2013-01-01 00:00:00+00","2017-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-18.297260057849503,-17.809563875664207)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[142.38512915573506,142.89511234985517)'::agdc.float8range) AND (archived IS NULL) AND (dataset_type_ref = 28))
  Heap Blocks: exact=1239
  ->  BitmapAnd  (cost=12922.68..12922.68 rows=351 width=0) (actual time=393642.275..393642.275 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..718.36 rows=8795 width=0) (actual time=393085.518..393085.518 rows=14506 loops=1)
              Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2013-01-01 00:00:00+00","2017-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-18.297260057849503,-17.809563875664207)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[142.38512915573506,142.89511234985517)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_pure_dataset_type_ref  (cost=0.00..12203.89 rows=660728 width=0) (actual time=554.359..554.359 rows=679506 loops=1)
              Index Cond: (dataset_type_ref = 28)
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=0.024..0.024 rows=1 loops=1471)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=0.014..0.015 rows=1 loops=1471)
                Index Cond: (dataset_ref = eo_1_data.id)
                Filter: (archived IS NULL)
Planning time: 0.625 ms
Execution time: 395247.821 ms

 */

-----
-- 15
-----

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -35, -34)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[136, 137)')
    AND agdc.dataset.dataset_type_ref = 92;

/*
Index Scan using tix_active_dataset_type on dataset  (cost=0.44..1209814.43 rows=52 width=16) (actual time=52547.750..324818.476 rows=711 loops=1)
  Index Cond: (dataset_type_ref = 92)
  Filter: ((agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-35,-34)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[136,137)'::agdc.float8range))
  Rows Removed by Filter: 601364
Planning time: 3.141 ms
Execution time: 324818.797 ms

 */

EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND dataset_type_ref = 92
    AND (agdc.float8range(lat_least, lat_greatest, '[]') &&
         '[ -35, -34)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') &&
         '[136, 137)');

/*
Bitmap Heap Scan on eo_1_data  (cost=13777.10..18979.01 rows=1371 width=16) (actual time=231999.459..232438.015 rows=711 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-35,-34)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[136,137)'::agdc.float8range) AND (dataset_type_ref = 92) AND (archived IS NULL))
  Heap Blocks: exact=398
  ->  BitmapAnd  (cost=13777.10..13777.10 rows=1371 width=0) (actual time=231983.530..231983.530 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..2599.43 rows=37501 width=0) (actual time=231543.298..231543.298 rows=83373 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-35,-34)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[136,137)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..11176.73 rows=604840 width=0) (actual time=431.572..431.572 rows=602075 loops=1)
              Index Cond: (dataset_type_ref = 92)
Planning time: 1282.229 ms
Execution time: 232440.141 ms

 */

-----
-- 16
-----

EXPLAIN ANALYSE
  SELECT agdc.dataset.id
  FROM agdc.dataset
  WHERE agdc.dataset.archived IS NULL
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             greatest(
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
             '[]') && '[ -34, -33)')
    AND (agdc.float8range(
             least(CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                   CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             greatest(
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lon}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lon}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lon}') AS DOUBLE PRECISION),
                 CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lon}') AS DOUBLE PRECISION)),
             '[]') && '[136, 137)')
    AND agdc.dataset.dataset_type_ref = 92;

/*
Index Scan using tix_active_dataset_type on dataset  (cost=0.44..1209814.43 rows=52 width=16) (actual time=51973.502..318342.430 rows=563 loops=1)
  Index Cond: (dataset_type_ref = 92)
  Filter: ((agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-34,-33)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[136,137)'::agdc.float8range))
  Rows Removed by Filter: 601512
Planning time: 31.615 ms
Execution time: 318342.772 ms

 */

EXPLAIN ANALYSE
  SELECT id
  FROM agdc.eo_1_data
  WHERE archived IS NULL
    AND dataset_type_ref = 92
    AND (agdc.float8range(lat_least, lat_greatest, '[]') &&
         '[ -31, -30)')
    AND (agdc.float8range(lon_least, lon_greatest, '[]') &&
         '[132, 133)');

/*
turned off a bunch of indexes
Bitmap Heap Scan on eo_1_data  (cost=11176.75..279205.65 rows=60 width=16) (actual time=1813.232..5027.602 rows=563 loops=1)
  Recheck Cond: ((dataset_type_ref = 92) AND (archived IS NULL))
  Filter: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-34,-33)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[136,137)'::agdc.float8range))
  Rows Removed by Filter: 601512
  Heap Blocks: exact=17962
  ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..11176.73 rows=604840 width=0) (actual time=443.059..443.059 rows=602075 loops=1)
        Index Cond: (dataset_type_ref = 92)
Planning time: 0.882 ms
Execution time: 5027.812 ms

****
turned on lat_lon index
****
Bitmap Heap Scan on eo_1_data  (cost=15380.93..23645.73 rows=2217 width=16) (actual time=242604.627..242605.261 rows=787 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-32,-31)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[134,135)'::agdc.float8range) AND (dataset_type_ref = 92) AND (archived IS NULL))
  Heap Blocks: exact=459
  ->  BitmapAnd  (cost=15380.93..15380.93 rows=2217 width=0) (actual time=242604.498..242604.498 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_pure_lat_lon  (cost=0.00..4202.84 rows=60642 width=0) (actual time=242550.269..242550.269 rows=90923 loops=1)
              Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-32,-31)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[134,135)'::agdc.float8range))
        ->  Bitmap Index Scan on eo_1_dataset_type_ref  (cost=0.00..11176.73 rows=604840 width=0) (actual time=49.168..49.168 rows=602075 loops=1)
              Index Cond: (dataset_type_ref = 92)
Planning time: 1.083 ms
Execution time: 242605.805 ms

***
testing pure lat and pure lon indexes
***
 */

