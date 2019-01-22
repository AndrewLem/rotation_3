with index_info as (
    select indexname,
        to_number(substring(indexdef from 'dataset_type_ref = (.*)\)\)'), '000') as "dataset_type_ref"
    from pg_indexes
    where schemaname = 'agdc'
    and tablename = 'dataset'
    and indexname like 'dix%'
),
dataset_type_info as (
    select id, name, metadata_type_ref
    from agdc.dataset_type
)
select dataset_type_ref, name, metadata_type_ref,
    substring(indexname from 'dix_'||name||'_(.*)') as "index_attributes"
from index_info i
       left outer join dataset_type_info t
                       on i.dataset_type_ref = t.id
order by index_attributes;



---------------------------------------------------------------------------------

-- todo: test this on local database checking left and right outer join
with for_counting as (
  with index_info as (
    select indexname,
           to_number(substring(indexdef from 'dataset_type_ref = (.*)\)\)'), '000') as "dataset_type_ref"
    from pg_indexes
    where schemaname = 'agdc'
      and tablename = 'dataset'
      and indexname like 'dix%'
    ),
    dataset_type_info as (
      select id, name, metadata_type_ref
      from agdc.dataset_type
      )
    select dataset_type_ref, name, metadata_type_ref,
           substring(indexname from 'dix_'||name||'_(.*)') as "index_attributes"
    from index_info i
           right outer join dataset_type_info t
                           on i.dataset_type_ref = t.id
    order by index_attributes
)
select dataset_type_ref, name, metadata_type_ref, count(*) as "count", array_agg(index_attributes) as "index_attributes"
from for_counting
group by dataset_type_ref, name, metadata_type_ref
order by metadata_type_ref, count desc, index_attributes;


-----------------------------------------------------------------------------------


with for_counting as (
  with use_ratio_calc as (
    with table_stats as (
      select psut.relname,
             psut.n_live_tup,
             1.0 * psut.idx_scan / greatest(1, psut.seq_scan + psut.idx_scan) as index_use_ratio
      from pg_stat_user_tables psut
      order by psut.n_live_tup desc
      ),
      table_io as (
        select psiut.relname,
               sum(psiut.heap_blks_read) as table_page_read,
               sum(psiut.heap_blks_hit) as table_page_hit,
               sum(psiut.heap_blks_hit) /
               greatest(1, sum(psiut.heap_blks_hit) + sum(psiut.heap_blks_read)) as table_hit_ratio
        from pg_statio_user_tables psiut
        group by psiut.relname
        order by table_page_read desc
        ),
      index_io as (
        select psiui.relname,
               psiui.indexrelname,
               sum(psiui.idx_blks_read) as idx_page_read,
               sum(psiui.idx_blks_hit)                                                                           as idx_page_hit,
               1.0 * sum(psiui.idx_blks_hit) /
               greatest(1.0, sum(psiui.idx_blks_hit) + sum(psiui.idx_blks_read))                                 as idx_hit_ratio
        from pg_statio_user_indexes psiui
        group by psiui.relname, psiui.indexrelname
        order by sum(psiui.idx_blks_read) desc
        )
      select ts.relname,
             ts.n_live_tup,
             ts.index_use_ratio,
             ti.table_page_read,
             ti.table_page_hit,
             ti.table_hit_ratio,
             ii.indexrelname,
             ii.idx_page_read,
             ii.idx_page_hit,
             ii.idx_hit_ratio
      from table_stats ts
             left outer join table_io ti
                             on ti.relname = ts.relname
             left outer join index_io ii
                             on ii.relname = ts.relname
      order by ti.table_page_read desc, ii.idx_page_read desc
    ),
    index_info as (
      select indexname,
             to_number(substring(indexdef from 'dataset_type_ref = (.*)\)\)'), '000') as "dataset_type_ref"
      from pg_indexes
      where schemaname = 'agdc'
        and tablename = 'dataset'
        and indexname like 'dix%'
      ),
    dataset_type_info as (
      select id, name, metadata_type_ref
      from agdc.dataset_type
      )
    select dataset_type_ref,
           name,
           metadata_type_ref,
           substring(indexname from 'dix_' || name || '_(.*)') as "index_attributes",
           to_char(idx_hit_ratio * 100, '990.00%')             as "idx_hit_ratio",
           to_char(idx_page_read, '0.99 EEEE')                 as idx_page_read
    from index_info i
           left outer join use_ratio_calc u
                           on i.indexname = u.indexrelname
           left outer join dataset_type_info t
                           on i.dataset_type_ref = t.id
    order by metadata_type_ref, index_attributes, name
)
select name,
       metadata_type_ref,
       count(*)                    as "count",
       array_agg(index_attributes) as "index_attributes",
       array_agg(idx_hit_ratio)    as "hit_ratios",
       array_agg(idx_page_read)    as "idx_page_reads"
from for_counting
group by name, metadata_type_ref
order by metadata_type_ref, count, index_attributes, name;
;