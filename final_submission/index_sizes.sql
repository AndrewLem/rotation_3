-- this query results in a table that shows index sizes

SELECT indexrelname as index_name,
       pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
       pg_relation_size(indexrelid)                 AS index_bytes
FROM pg_stat_user_indexes
ORDER BY index_bytes DESC;


-- this query results in the named table size

SELECT pg_size_pretty(pg_total_relation_size('agdc.dataset')) as table_size,
       pg_total_relation_size('agdc.dataset') as table_bytes;