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
where (archived is null) and dataset_type_ref = 69;

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
where (archived is null) and dataset_type_ref = 69;


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
where (archived is null) and dataset_type_ref = 70;

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