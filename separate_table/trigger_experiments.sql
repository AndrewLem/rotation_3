CREATE TABLE agdc.row_counts
(
  dataset_type_ref smallint PRIMARY KEY,
  product_count    bigint
);

CREATE FUNCTION create_update_count(key smallint, data bigint) RETURNS VOID AS
$$
BEGIN
  LOOP
    -- first try to update the key
    -- note that "a" must be unique
    UPDATE agdc.row_counts SET product_count = product_count + data WHERE dataset_type_ref = key;
    IF found THEN
      RETURN;
    END IF;
    -- not there, so try to insert the key
    -- if someone else inserts the same key concurrently,
    -- we could get a unique-key failure
    BEGIN
      INSERT INTO agdc.row_counts(dataset_type_ref, product_count) VALUES (key, data);
      RETURN;
      EXCEPTION WHEN unique_violation THEN
      -- do nothing, and loop to try the UPDATE again
    END;
  END LOOP;
END;
$$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION adjust_count()
  RETURNS TRIGGER AS
$$
DECLARE
BEGIN
  IF TG_OP = 'INSERT' THEN
    EXECUTE create_update_count(NEW.dataset_type_ref, +1);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    EXECUTE 'UPDATE agdc.row_counts set product_count = product_count - 1 where dataset_type_ref = '''
      || OLD.dataset_type_ref || '''';
    RETURN OLD;
  END IF;
END;
$$
  LANGUAGE 'plpgsql';

CREATE TRIGGER product_count
  BEFORE INSERT OR DELETE
  ON agdc.dataset
  FOR EACH ROW
EXECUTE PROCEDURE adjust_count();


CREATE TABLE agdc.extra_dataset_info
as
select id,
       dataset_type_ref,
       archived,
       LEAST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
             (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
             (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
             (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision)    as lat_least,
       GREATEST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision) as lat_greatest,
       LEAST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
             (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
             (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
             (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision)    as lon_least,
       GREATEST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision) as lon_greatest,
       agdc.common_timestamp(metadata #>> '{extent,from_dt}'::text[])             as from_dt,
       agdc.common_timestamp(metadata #>> '{extent,to_dt}'::text[])               as to_dt
from agdc.dataset;


create index dix_extra_dataset_info
  on agdc.extra_dataset_info (archived,
                              dataset_type_ref,
                              agdc.float8range(lat_least, lat_greatest, '[]'::text),
                              agdc.float8range(lon_least, lon_greatest, '[]'::text),
                              tstzrange(from_dt, to_dt, '[]'::text))
;


create index dix_extra_dataset_info_lat_extents
  on agdc.extra_dataset_info (archived,
                              dataset_type_ref,
                              agdc.float8range(lat_least, lat_greatest, '[]'::text))
;


create index dix_extra_dataset_info_lon_extents
  on agdc.extra_dataset_info (archived,
                              dataset_type_ref,
                              agdc.float8range(lon_least, lon_greatest, '[]'::text))
;


create index dix_extra_dataset_info_time_extents
  on agdc.extra_dataset_info (archived,
                              dataset_type_ref,
                              tstzrange(from_dt, to_dt, '[]'::text))
;


create index dix_extra_dataset_info_archived
  on agdc.extra_dataset_info (archived)
;


create index dix_extra_dataset_info_dataset_type_ref
  on agdc.extra_dataset_info (dataset_type_ref)
;


create index dix_extra_dataset_info_lat_pure_extents
  on agdc.extra_dataset_info (agdc.float8range(lat_least, lat_greatest, '[]'::text))
;


create index dix_extra_dataset_info_lon_pure_extents
  on agdc.extra_dataset_info (agdc.float8range(lon_least, lon_greatest, '[]'::text))
;


create index dix_extra_dataset_info_time_pure_extents
  on agdc.extra_dataset_info (tstzrange(from_dt, to_dt, '[]'::text))
;


create unique index extra_dataset_info_id_index
  on agdc.extra_dataset_info (id);

alter table agdc.extra_dataset_info
  add constraint extra_dataset_info_pk
    primary key (id);



CREATE TABLE agdc.extra_dataset_info
(
  base_id          uuid PRIMARY KEY,
  dataset_type_ref smallint,
  lat_least        double precision,
  lat_greatest     double precision,
  lon_least        double precision,
  lon_most         double precision
);


select *
from agdc.extra_dataset_info;



CREATE OR REPLACE FUNCTION extra_dataset_info_update()
  RETURNS TRIGGER AS
$$
DECLARE
BEGIN
  IF TG_OP = 'INSERT' THEN
    EXECUTE 'INSERT INTO agdc.extra_dataset_info(id, dataset_type_ref, ' ||
            'lat_least, lat_greatest, lon_least, lon_greatest, from_dt, to_dt)' ||
            'VALUES (''' || NEW.id || ''',' || NEW.dataset_type_ref || ',' ||
            LEAST((NEW.metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                  (NEW.metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                  (NEW.metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                  (NEW.metadata #>> '{extent,coord,ll,lat}'::text[])::double precision) || ',' ||
            GREATEST((NEW.metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                     (NEW.metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                     (NEW.metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                     (NEW.metadata #>> '{extent,coord,ll,lat}'::text[])::double precision) || ',' ||
            LEAST((NEW.metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                  (NEW.metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                  (NEW.metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                  (NEW.metadata #>> '{extent,coord,lr,lon}'::text[])::double precision) || ',' ||
            GREATEST((NEW.metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                     (NEW.metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                     (NEW.metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                     (NEW.metadata #>> '{extent,coord,lr,lon}'::text[])::double precision) || ',' ||
            '''' || agdc.common_timestamp(NEW.metadata #>> '{extent,from_dt}'::text[]) || ''',' ||
            '''' || agdc.common_timestamp(NEW.metadata #>> '{extent,to_dt}'::text[]) || ''')';
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    EXECUTE 'DELETE FROM agdc.extra_dataset_info WHERE id = ''' || OLD.id || '''';
    RETURN OLD;
  END IF;
END;
$$
  LANGUAGE 'plpgsql';

CREATE TRIGGER product_extra_info
  BEFORE INSERT OR DELETE
  ON agdc.dataset
  FOR EACH ROW
EXECUTE PROCEDURE extra_dataset_info_update();

select id,
       dataset_type_ref,
       LEAST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
             (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
             (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
             (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision)    as lat_least,
       GREATEST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision) as lat_greatest,
       LEAST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
             (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
             (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
             (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision)    as lon_least,
       GREATEST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision) as lon_greatest,
       agdc.common_timestamp(metadata #>> '{extent,from_dt}'::text[])             as from_dt,
       agdc.common_timestamp(metadata #>> '{extent,to_dt}'::text[])               as to_dt
from agdc.dataset;



--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

EXPLAIN ANALYSE SELECT agdc.dataset.id,
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
                           '[]')
                  && agdc.float8range(152.3, 152.34, '[)'))
                  AND (agdc.float8range(
                           least(CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
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
-- [2019-01-18 09:26:18] 5 rows retrieved starting from 1 in 3 m 21 s 755 ms (execution: 3 m 21 s 443 ms, fetching: 312 ms)
/*
Bitmap Heap Scan on dataset  (cost=23592.84..3363818.93 rows=1 width=1380) (actual time=185774.156..194537.080 rows=5 loops=1)
  Recheck Cond: ((dataset_type_ref = 21) AND (archived IS NULL))
  Filter: ((agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange))
  Rows Removed by Filter: 1288550
  Heap Blocks: exact=420962
  ->  Bitmap Index Scan on tix_active_dataset_type  (cost=0.00..23592.84 rows=1277387 width=0) (actual time=1260.114..1260.114 rows=1290555 loops=1)
        Index Cond: (dataset_type_ref = 21)
  SubPlan 1
    ->  Sort  (cost=8.60..8.60 rows=1 width=44) (actual time=46.147..46.148 rows=1 loops=5)
          Sort Key: selected_dataset_location.added DESC, selected_dataset_location.id DESC
          Sort Method: quicksort  Memory: 25kB
          ->  Index Scan using ix_agdc_dataset_location_dataset_ref on dataset_location selected_dataset_location  (cost=0.56..8.59 rows=1 width=44) (actual time=46.122..46.124 rows=1 loops=5)
                Index Cond: (dataset_ref = dataset.id)
                Filter: (archived IS NULL)
Planning time: 3.706 ms
Execution time: 194542.958 ms

 */


EXPLAIN ANALYSE SELECT id
                FROM agdc.eo_1_data
                WHERE archived IS NULL
                  AND dataset_type_ref = 21
                  AND (agdc.float8range(lat_least, lat_greatest, '[]') && agdc.float8range(-24.89, -24.85, '[)'))
                  AND (agdc.float8range(lon_least, lon_greatest, '[]') && agdc.float8range(152.3, 152.34, '[)'))
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

Index Scan using eo_1_time_lat_lon on eo_1_data  (cost=0.42..68.82 rows=1 width=16) (actual time=13.672..48.723 rows=5 loops=1)
  Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range))
  Filter: (dataset_type_ref = 21)
  Rows Removed by Filter: 59
Planning time: 0.236 ms
Execution time: 48.762 ms

Index Scan using eo_1_time_lat_lon on eo_1_data  (cost=0.42..68.82 rows=1 width=16) (actual time=398.320..783.550 rows=5 loops=1)
  Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range))
  Filter: (dataset_type_ref = 21)
  Rows Removed by Filter: 59
Planning time: 0.222 ms
Execution time: 783.593 ms

Index Scan using eo_1_time_lat_lon on eo_1_data  (cost=0.42..68.82 rows=1 width=16) (actual time=17.069..51.492 rows=5 loops=1)
  Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-06-01 00:00:00+00","2017-09-01 00:00:00+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-24.890000000000001,-24.850000000000001)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[152.30000000000001,152.34)'::agdc.float8range))
  Filter: (dataset_type_ref = 21)
  Rows Removed by Filter: 59
Planning time: 0.256 ms
Execution time: 51.527 ms

 */


EXPLAIN ANALYSE SELECT agdc.dataset.id
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
                           '[]') && '[ -36.18348132582486, -35.22313291663772)')
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

 */

EXPLAIN ANALYSE SELECT id
                FROM agdc.eo_1_data
                WHERE archived IS NULL
                  AND dataset_type_ref = 92
                  AND (agdc.float8range(lat_least, lat_greatest, '[]') && '[ -36.18348132582486, -35.22313291663772)')
                  AND (agdc.float8range(lon_least, lon_greatest, '[]') && '[137.19710243283376,138.4442681122013)')
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
Bitmap Heap Scan on eo_1_data  (cost=128.36..6143.47 rows=59 width=16) (actual time=2794.197..2817.340 rows=1575 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range) AND (archived IS NULL))
  Filter: (dataset_type_ref = 92)
  Rows Removed by Filter: 79477
  Heap Blocks: exact=30016
  ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..128.35 rows=1593 width=0) (actual time=2778.482..2778.482 rows=81052 loops=1)
        Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range))
Planning time: 0.158 ms
Execution time: 2817.856 ms

Bitmap Heap Scan on eo_1_data  (cost=128.36..6143.47 rows=59 width=16) (actual time=2796.303..2819.355 rows=1575 loops=1)
  Recheck Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range) AND (archived IS NULL))
  Filter: (dataset_type_ref = 92)
  Rows Removed by Filter: 79477
  Heap Blocks: exact=30016
  ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..128.35 rows=1593 width=0) (actual time=2780.455..2780.455 rows=81052 loops=1)
        Index Cond: ((agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-36.183481325824857,-35.223132916637717)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[137.19710243283376,138.44426811220131)'::agdc.float8range))
Planning time: 0.157 ms
Execution time: 2819.939 ms

 */

EXPLAIN ANALYSE SELECT agdc.dataset.id
                FROM agdc.dataset
                WHERE agdc.dataset.archived IS NULL
                  AND (tstzrange(least(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                                       agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, center_dt}'))),
                                 greatest(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')),
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
                           greatest(
                               CAST((agdc.dataset.metadata #>> '{extent, coord, ur, lat}') AS DOUBLE PRECISION),
                               CAST((agdc.dataset.metadata #>> '{extent, coord, lr, lat}') AS DOUBLE PRECISION),
                               CAST((agdc.dataset.metadata #>> '{extent, coord, ul, lat}') AS DOUBLE PRECISION),
                               CAST((agdc.dataset.metadata #>> '{extent, coord, ll, lat}') AS DOUBLE PRECISION)),
                           '[]') && '[ -31.341862288997746, -31.340612711002255)')
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
                           '[]') && '[121.64698252709579,121.64870963957088)')
                  AND agdc.dataset.dataset_type_ref = 16;
-- [2019-01-18 13:38:15] 374 rows retrieved starting from 1 in 1 s 189 ms (execution: 1 s 161 ms, fetching: 28 ms)
/*
Index Scan using dix_ls8_nbart_scene_time_lat_lon on dataset  (cost=0.28..8.30 rows=1 width=16) (actual time=69.885..1816.279 rows=374 loops=1)
  Index Cond: ((tstzrange(LEAST(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,center_dt}'::text[]))), GREATEST(agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,center_dt}'::text[]))), '[]'::text) && '["2013-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ur,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ul,lat}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lat}'::text[]))::double precision), '[]'::text) && '[-31.341862288997746,-31.340612711002255)'::agdc.float8range) AND (agdc.float8range(LEAST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), GREATEST(((metadata #>> '{extent,coord,ul,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ur,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,ll,lon}'::text[]))::double precision, ((metadata #>> '{extent,coord,lr,lon}'::text[]))::double precision), '[]'::text) && '[121.64698252709579,121.64870963957088)'::agdc.float8range))
Planning time: 3.534 ms
Execution time: 1816.463 ms

 */

EXPLAIN ANALYSE SELECT id
                FROM agdc.eo_1_data
                WHERE archived IS NULL
                  AND (tstzrange(from_dt, to_dt, '[]')
                  && tstzrange('2013-01-01T00:00:00+00:00'::timestamptz,
                               '2018-12-31T23:59:59.999999+00:00'::timestamptz,
                               '[)'))
                  AND (agdc.float8range(lat_least, lat_greatest, '[]') && '[ -31.341862288997746, -31.340612711002255)')
                  AND (agdc.float8range(lon_least, lon_greatest, '[]') && '[121.64698252709579,121.64870963957088)')
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

Index Scan using eo_1_time_lat_lon on eo_1_data  (cost=0.42..68.82 rows=1 width=16) (actual time=1474.849..1474.849 rows=0 loops=1)
  Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2013-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-31.341862288997746,-31.340612711002255)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[121.64698252709579,121.64870963957088)'::agdc.float8range))
  Filter: (dataset_type_ref = 16)
  Rows Removed by Filter: 2515
Planning time: 0.202 ms
Execution time: 1474.899 ms

Index Scan using eo_1_time_lat_lon on eo_1_data  (cost=0.42..68.82 rows=1 width=16) (actual time=1453.621..1453.621 rows=0 loops=1)
  Index Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2013-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (agdc.float8range(lat_least, lat_greatest, '[]'::text) && '[-31.341862288997746,-31.340612711002255)'::agdc.float8range) AND (agdc.float8range(lon_least, lon_greatest, '[]'::text) && '[121.64698252709579,121.64870963957088)'::agdc.float8range))
  Filter: (dataset_type_ref = 16)
  Rows Removed by Filter: 2515
Planning time: 0.174 ms
Execution time: 1480.290 ms

 */

EXPLAIN ANALYSE SELECT agdc.dataset.id
                FROM agdc.dataset
                WHERE agdc.dataset.archived IS NULL
                  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')), '[]') &&
                       tstzrange('2017-01-01T00:00:00+00:00'::timestamptz,
                                 '2018-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
                  AND agdc.dataset.dataset_type_ref = 19;
--[2019-01-18 14:24:32] 112381 rows retrieved starting from 1 in 4 m 45 s 930 ms (execution: 4 m 45 s 10 ms, fetching: 920 ms)
/*
Index Scan using dix_ls8_nbar_albers_time_lat_lon on dataset  (cost=0.41..28643.17 rows=7015 width=16) (actual time=136.989..283446.958 rows=112381 loops=1)
  Index Cond: (tstzrange(agdc.common_timestamp((metadata #>> '{extent,from_dt}'::text[])), agdc.common_timestamp((metadata #>> '{extent,to_dt}'::text[])), '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange)
Planning time: 3.975 ms
Execution time: 283468.574 ms
 */

EXPLAIN ANALYSE SELECT id
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

Bitmap Heap Scan on eo_1_data  (cost=25793.24..50427.58 rows=7095 width=16) (actual time=376.618..400.313 rows=112381 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange) AND (archived IS NULL) AND (dataset_type_ref = 19))
  Heap Blocks: exact=11593
  ->  BitmapAnd  (cost=25793.24..25793.24 rows=7095 width=0) (actual time=374.725..374.725 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..12179.27 rows=159314 width=0) (actual time=318.169..318.169 rows=1152077 loops=1)
              Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange)
        ->  Bitmap Index Scan on eo_1_dataset_type_ref_all  (cost=0.00..13610.17 rows=736765 width=0) (actual time=42.331..42.331 rows=696974 loops=1)
              Index Cond: (dataset_type_ref = 19)
Planning time: 0.166 ms
Execution time: 402.813 ms

Bitmap Heap Scan on eo_1_data  (cost=25793.24..50427.58 rows=7095 width=16) (actual time=344.340..367.939 rows=112381 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange) AND (archived IS NULL) AND (dataset_type_ref = 19))
  Heap Blocks: exact=11593
  ->  BitmapAnd  (cost=25793.24..25793.24 rows=7095 width=0) (actual time=342.469..342.469 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..12179.27 rows=159314 width=0) (actual time=288.590..288.590 rows=1152077 loops=1)
              Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2017-01-01 00:00:00+00","2018-01-01 23:59:59.999999+00")'::tstzrange)
        ->  Bitmap Index Scan on eo_1_dataset_type_ref_all  (cost=0.00..13610.17 rows=736765 width=0) (actual time=39.944..39.944 rows=696974 loops=1)
              Index Cond: (dataset_type_ref = 19)
Planning time: 0.165 ms
Execution time: 370.456 ms

 */

EXPLAIN ANALYSE SELECT agdc.dataset.id
                FROM agdc.dataset
                WHERE agdc.dataset.archived IS NULL
                  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')), '[]') &&
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

 */

EXPLAIN ANALYSE SELECT id
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

Bitmap Heap Scan on eo_1_data  (cost=63048.42..140524.75 rows=26515 width=16) (actual time=600.708..628.033 rows=129669 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (archived IS NULL) AND (dataset_type_ref = 77))
  Heap Blocks: exact=9302
  ->  BitmapAnd  (cost=63048.42..63048.42 rows=26515 width=0) (actual time=599.256..599.256 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..12179.27 rows=159314 width=0) (actual time=422.807..422.807 rows=1172237 loops=1)
              Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
        ->  Bitmap Index Scan on eo_1_dataset_type_ref_all  (cost=0.00..50855.64 rows=2753494 width=0) (actual time=167.572..167.572 rows=2767431 loops=1)
              Index Cond: (dataset_type_ref = 77)
Planning time: 0.609 ms
Execution time: 630.743 ms

Bitmap Heap Scan on eo_1_data  (cost=63048.42..140524.75 rows=26515 width=16) (actual time=440.634..462.819 rows=129669 loops=1)
  Recheck Cond: ((tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange) AND (archived IS NULL) AND (dataset_type_ref = 77))
  Heap Blocks: exact=9302
  ->  BitmapAnd  (cost=63048.42..63048.42 rows=26515 width=0) (actual time=439.220..439.220 rows=0 loops=1)
        ->  Bitmap Index Scan on eo_1_time_lat_lon  (cost=0.00..12179.27 rows=159314 width=0) (actual time=267.686..267.686 rows=1172237 loops=1)
              Index Cond: (tstzrange(from_dt, to_dt, '[]'::text) && '["2018-01-01 00:00:00+00","2018-12-31 23:59:59.999999+00")'::tstzrange)
        ->  Bitmap Index Scan on eo_1_dataset_type_ref_all  (cost=0.00..50855.64 rows=2753494 width=0) (actual time=157.475..157.475 rows=2767431 loops=1)
              Index Cond: (dataset_type_ref = 77)
Planning time: 0.271 ms
Execution time: 465.426 ms

 */


EXPLAIN ANALYSE SELECT agdc.dataset.id
                FROM agdc.dataset
                WHERE agdc.dataset.archived IS NULL
                  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')), '[]') &&
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
 */


EXPLAIN ANALYSE SELECT id
                FROM agdc.eo_1_data
                WHERE archived IS NULL
                  AND (tstzrange(from_dt, to_dt, '[]')
                  && tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                               '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
                  AND (agdc.float8range(lat_least, lat_greatest, '[]') && '[ -17.5544592474921, -17.361457459231584)')
                  AND (agdc.float8range(lon_least, lon_greatest, '[]') && '[140.70680860879938,140.90732842760332)')
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


 */

EXPLAIN ANALYSE SELECT agdc.dataset.id
                FROM agdc.dataset
                WHERE agdc.dataset.archived IS NULL
                  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')), '[]') &&
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


EXPLAIN ANALYSE SELECT id
                FROM agdc.extra_dataset_info
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
 */

EXPLAIN ANALYSE SELECT agdc.dataset.id
                FROM agdc.dataset
                WHERE agdc.dataset.archived IS NULL
                  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')), '[]') &&
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
 */


EXPLAIN ANALYSE SELECT id
                FROM agdc.extra_dataset_info
                WHERE archived IS NULL
                  AND (tstzrange(from_dt, to_dt, '[]') &&
                       tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                                 '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
                  AND (agdc.float8range(lat_least, lat_greatest, '[]') && '[ -17.5544592474921, -17.361457459231584)')
                  AND (agdc.float8range(lon_least, lon_greatest, '[]') && '[140.70680860879938,140.90732842760332)')
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
 */

EXPLAIN ANALYSE SELECT agdc.dataset.id
                FROM agdc.dataset
                WHERE agdc.dataset.archived IS NULL
                  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')), '[]') &&
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
 */

EXPLAIN ANALYSE SELECT id
                FROM agdc.extra_dataset_info
                WHERE archived IS NULL
                  AND (tstzrange(from_dt, to_dt, '[]') &&
                       tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                                 '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
                  AND (agdc.float8range(lat_least, lat_greatest, '[]') && '[ -17.5544592474921, -17.361457459231584)')
                  AND (agdc.float8range(lon_least, lon_greatest, '[]') && '[140.70680860879938,140.90732842760332)')
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
 */

EXPLAIN ANALYSE SELECT agdc.dataset.id
                FROM agdc.dataset
                WHERE agdc.dataset.archived IS NULL
                  AND (tstzrange(agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, from_dt}')),
                                 agdc.common_timestamp((agdc.dataset.metadata #>> '{extent, to_dt}')), '[]') &&
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
 */

EXPLAIN ANALYSE SELECT id
                FROM agdc.extra_dataset_info
                WHERE archived IS NULL
                  AND (tstzrange(from_dt, to_dt, '[]') &&
                       tstzrange('1986-01-01T00:00:00+00:00'::timestamptz,
                                 '2019-01-01T23:59:59.999999+00:00'::timestamptz, '[)'))
                  AND (agdc.float8range(lat_least, lat_greatest, '[]') && '[ -17.5544592474921, -17.361457459231584)')
                  AND (agdc.float8range(lon_least, lon_greatest, '[]') && '[140.70680860879938,140.90732842760332)')
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
 */

