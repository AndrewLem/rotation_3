explain select (metadata #>> '{{extent,coord,ul,lat}}'::text[])::double precision as ul_lats,
               (metadata #>> '{{extent,coord,ur,lat}}'::text[])::double precision as ur_lats,
               (metadata #>> '{{extent,coord,ll,lat}}'::text[])::double precision as ll_lats,
               (metadata #>> '{{extent,coord,lr,lat}}'::text[])::double precision as lr_lats
        from agdc.dataset
        where dataset_type_ref = 23;