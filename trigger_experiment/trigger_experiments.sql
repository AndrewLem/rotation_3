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

CREATE TABLE agdc.extra_dataset_info as
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
                (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision) as lon_greatest
from agdc.dataset;

CREATE TABLE agdc.extra_dataset_info
(
  base_id uuid PRIMARY KEY,
  dataset_type_ref smallint,
  lat_least double precision,
  lat_greatest double precision,
  lon_least double precision,
  lon_most double precision
);


select * from agdc.extra_dataset_info;