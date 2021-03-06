CREATE TABLE agdc.eo_1_data
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
       agdc.common_timestamp(metadata #>> '{extent,to_dt}'::text[])               as to_dt,
       metadata #>> '{platform,code}'::text[]                                     as platform
from agdc.dataset
where metadata_type_ref = 1;

CREATE OR REPLACE FUNCTION insert_into_eo_1_data(_id uuid, _dataset_type_ref smallint,
                                                 _archived timestamp with time zone, _metadata jsonb)
  RETURNS void AS
$$
DECLARE
BEGIN
  INSERT INTO agdc.eo_1_data(id, dataset_type_ref, archived,
                             lat_least, lat_greatest, lon_least, lon_greatest,
                             from_dt, to_dt,
                             platform)
  VALUES (_id, _dataset_type_ref, _archived,
          LEAST((_metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                (_metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                (_metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                (_metadata #>> '{extent,coord,ll,lat}'::text[])::double precision),
          GREATEST((_metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                   (_metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                   (_metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                   (_metadata #>> '{extent,coord,ll,lat}'::text[])::double precision),
          LEAST((_metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                (_metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                (_metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                (_metadata #>> '{extent,coord,lr,lon}'::text[])::double precision),
          GREATEST((_metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                   (_metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                   (_metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                   (_metadata #>> '{extent,coord,lr,lon}'::text[])::double precision),
          agdc.common_timestamp(_metadata #>> '{extent,from_dt}'::text[]),
          agdc.common_timestamp(_metadata #>> '{extent,to_dt}'::text[]),
          _metadata #>> '{platform,code}'::text[]);
END;
$$
  LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION dataset_info_update()
  RETURNS TRIGGER AS
$$
DECLARE
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.metadata_type_ref = 1 THEN
      EXECUTE insert_into_eo_1_data(NEW.id, NEW.dataset_type_ref, NEW.archived, NEW.metadata);
      RETURN NEW;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    EXECUTE 'DELETE FROM agdc.extra_dataset_info WHERE id = ''' || OLD.id || '''';
    RETURN OLD;
  END IF;
END;
$$
  LANGUAGE 'plpgsql';


CREATE TRIGGER dataset_info_trigger
  BEFORE INSERT
  ON agdc.dataset
  FOR EACH ROW
EXECUTE PROCEDURE dataset_info_update();


create unique index eo_1_data_id_uindex
  on agdc.eo_1_data (id);

alter table agdc.eo_1_data
  add constraint eo_1_data_pk
    primary key (id);


CREATE INDEX eo_1_lat_least_index
  ON agdc.eo_1_data
    (lat_least);

CREATE INDEX eo_1_lat_greatest_index
  ON agdc.eo_1_data
    (lat_greatest);

CREATE INDEX eo_1_lon_least_index
  ON agdc.eo_1_data
    (lon_least);

CREATE INDEX eo_1_lon_greatest_index
  ON agdc.eo_1_data
    (lon_greatest);

CREATE INDEX eo_1_from_dt_index
  ON agdc.eo_1_data
    (from_dt);

CREATE INDEX eo_1_to_dt_index
  ON agdc.eo_1_data
    (to_dt);

CREATE INDEX eo_1_platform_index
  ON agdc.eo_1_data
    (platform);

CREATE INDEX eo_1_dataset_type_ref_index
  ON agdc.eo_1_data
    (dataset_type_ref);

CREATE INDEX eo_1_archived_index
  ON agdc.eo_1_data
    (archived);

CREATE INDEX eo_1_dataset_type_ref_not_archived_index
  ON agdc.eo_1_data
    (dataset_type_ref)
  WHERE archived IS NULL;

/*
May potentially need to create a btree_gist extension if the following error occurs:
[42704] ERROR: data type smallint has no default operator class for access method "gist"
CREATE EXTENSION btree_gist;
*/

CREATE INDEX cluster_index
  ON agdc.eo_1_data
    USING gist (archived,
                dataset_type_ref,
                agdc.float8range(lat_least, lat_greatest, '[]'::text),
                agdc.float8range(lon_least, lon_greatest, '[]'::text),
                tstzrange(from_dt, to_dt, '[]'::text));

CREATE INDEX eo_1_lat_lon_time
  ON agdc.eo_1_data
    USING gist (dataset_type_ref,
                agdc.float8range(lat_least, lat_greatest, '[]'::text),
                agdc.float8range(lon_least, lon_greatest, '[]'::text),
                tstzrange(from_dt, to_dt, '[]'::text))
  WHERE ((archived IS NULL));

CREATE INDEX eo_1_time_lat_lon
  ON agdc.eo_1_data
    USING gist (dataset_type_ref,
                tstzrange(from_dt, to_dt, '[]'::text),
                agdc.float8range(lat_least, lat_greatest, '[]'::text),
                agdc.float8range(lon_least, lon_greatest, '[]'::text))
  WHERE ((archived IS NULL));

CREATE INDEX eo_1_platform
  ON agdc.eo_1_data
    (dataset_type_ref,
     platform)
  WHERE ((archived IS NULL));



CREATE INDEX eo_1_pure_lat_lon_ranges
  ON agdc.eo_1_data
    USING gist (agdc.float8range(lat_least, lat_greatest, '[]'::text),
                agdc.float8range(lon_least, lon_greatest, '[]'::text));

CREATE INDEX eo_1_pure_time_range
  ON agdc.eo_1_data
    USING gist (tstzrange(from_dt, to_dt, '[]'::text));


CREATE INDEX eo_1_pure_lat_range
  ON agdc.eo_1_data
    USING gist (agdc.float8range(lat_least, lat_greatest, '[]'::text));

CREATE INDEX eo_1_pure_lon_range
  ON agdc.eo_1_data
    USING gist (agdc.float8range(lon_least, lon_greatest, '[]'::text));



CREATE INDEX cluster_index
  ON agdc.eo_1_data
    USING gist (archived,
                dataset_type_ref,
                agdc.float8range(lat_least, lat_greatest, '[]'::text),
                agdc.float8range(lon_least, lon_greatest, '[]'::text),
                tstzrange(from_dt, to_dt, '[]'::text));


CLUSTER agdc.eo_1_data USING cluster_index;

analyse agdc.eo_1_data;




