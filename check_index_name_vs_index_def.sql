with indexes_info as (
  select indexname,
         substring(indexdef from 'CREATE INDEX (.*) ON') as "def_name",
         to_number(substring(indexdef from 'dataset_type_ref = (.*)\)\)'), '000') as "dataset_type_ref"
  from pg_indexes
  where schemaname = 'agdc'
    and tablename = 'dataset'
    and indexname like 'dix%'
),
product_info as (
  select id, name
  from agdc.dataset_type
)
select i.indexname, i.def_name,
       case
         when i.indexname = i.def_name then 'TRUE'
         else 'FALSE'
       end as "name_match_def",
       i.dataset_type_ref,
       p.name,
       case
         when position(p.name in i.indexname) > 0 then 'TRUE'
         else 'FALSE'
       end as "index_match_name"
from indexes_info i
left outer join product_info p
on i.dataset_type_ref = p.id;