SELECT indexrelname, pg_size_pretty(pg_relation_size(indexrelid)) AS index_size, pg_relation_size(indexrelid) AS index_bytes FROM pg_stat_user_indexes
ORDER BY index_bytes DESC;