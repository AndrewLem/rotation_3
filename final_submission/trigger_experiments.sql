-- these statements experimented with using triggers


CREATE TABLE agdc.row_counts
AS
SELECT dataset_type_ref,
       count(*) AS product_count
FROM agdc.dataset
GROUP BY dataset_type_ref;


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
    EXECUTE create_update_count(OLD.dataset_type_ref, -1);
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
