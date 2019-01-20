ALTER TABLE agdc.dataset
  ADD COLUMN lat_least DOUBLE PRECISION;
ALTER TABLE agdc.dataset
  ADD COLUMN lat_greatest DOUBLE PRECISION;
ALTER TABLE agdc.dataset
  ADD COLUMN lon_least DOUBLE PRECISION;
ALTER TABLE agdc.dataset
  ADD COLUMN lon_greatest DOUBLE PRECISION;
ALTER TABLE agdc.dataset
  ADD COLUMN from_dt TIMESTAMP WITH TIME ZONE;
ALTER TABLE agdc.dataset
  ADD COLUMN center_dt TIMESTAMP WITH TIME ZONE;
ALTER TABLE agdc.dataset
  ADD COLUMN to_dt TIMESTAMP WITH TIME ZONE;

UPDATE agdc.dataset
SET lat_least = LEAST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                      (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                      (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                      (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision);
UPDATE agdc.dataset
SET lat_greatest = GREATEST((metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                            (metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                            (metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                            (metadata #>> '{extent,coord,ll,lat}'::text[])::double precision);
UPDATE agdc.dataset
SET lon_least = LEAST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                      (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                      (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                      (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision);
UPDATE agdc.dataset
SET lon_greatest = GREATEST((metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                            (metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                            (metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                            (metadata #>> '{extent,coord,lr,lon}'::text[])::double precision);
UPDATE agdc.dataset
SET from_dt = agdc.common_timestamp(metadata #>> '{extent,from_dt}'::text[]);
UPDATE agdc.dataset
SET center_dt = agdc.common_timestamp(metadata #>> '{extent,center_dt}'::text[]);
UPDATE agdc.dataset
SET to_dt = agdc.common_timestamp(metadata #>> '{extent,to_dt}'::text[]);

CREATE OR REPLACE FUNCTION dataset_info_update()
  RETURNS TRIGGER AS
$$
DECLARE
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.lat_least = LEAST((NEW.metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                          (NEW.metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                          (NEW.metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                          (NEW.metadata #>> '{extent,coord,ll,lat}'::text[])::double precision);
    NEW.lat_greatest = GREATEST((NEW.metadata #>> '{extent,coord,ur,lat}'::text[])::double precision,
                                (NEW.metadata #>> '{extent,coord,lr,lat}'::text[])::double precision,
                                (NEW.metadata #>> '{extent,coord,ul,lat}'::text[])::double precision,
                                (NEW.metadata #>> '{extent,coord,ll,lat}'::text[])::double precision);
    NEW.lon_least = LEAST((NEW.metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                          (NEW.metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                          (NEW.metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                          (NEW.metadata #>> '{extent,coord,lr,lon}'::text[])::double precision);
    NEW.lon_greatest = GREATEST((NEW.metadata #>> '{extent,coord,ul,lon}'::text[])::double precision,
                                (NEW.metadata #>> '{extent,coord,ur,lon}'::text[])::double precision,
                                (NEW.metadata #>> '{extent,coord,ll,lon}'::text[])::double precision,
                                (NEW.metadata #>> '{extent,coord,lr,lon}'::text[])::double precision);
    NEW.from_dt = agdc.common_timestamp(NEW.metadata #>> '{extent,from_dt}'::text[]);
    NEW.center_dt = agdc.common_timestamp(metadata #>> '{extent,center_dt}'::text[]);
    NEW.to_dt = agdc.common_timestamp(NEW.metadata #>> '{extent,to_dt}'::text[]);
    RETURN NEW;
  END IF;
END;
$$
  LANGUAGE 'plpgsql';


