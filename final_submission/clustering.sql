-- clustering on this index improved performance in general

CREATE INDEX dataset_archived_dataset_type_ref_index
  ON agdc.dataset
    (archived, dataset_type_ref);

CLUSTER agdc.dataset USING dataset_archived_dataset_type_ref_index;

ANALYSE agdc.dataset;



-- clustering on this index severely negatively impacted just time queries

CREATE INDEX eo_1_data_cluster_index
  ON agdc.eo_1_data
    USING gist (archived,
                dataset_type_ref,
                agdc.float8range(lat_least, lat_greatest, '[]'::text),
                agdc.float8range(lon_least, lon_greatest, '[]'::text),
                tstzrange(from_dt, to_dt, '[]'::text));

CLUSTER agdc.eo_1_data USING eo_1_data_cluster_index;

ANALYSE agdc.eo_1_data;

