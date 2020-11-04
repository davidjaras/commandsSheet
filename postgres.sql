-- Show slow queries in the describe
SELECT substring(query, 1, 50) AS short_query,
              round(total_time::numeric, 2) AS total_time,
              calls,
              round(mean_time::numeric, 2) AS mean,
              round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM  pg_stat_statements
ORDER BY total_time DESC;

-- Show backend connections that starts since 1 minutes (Long running connections)
SELECT
  pid,
  now() - pg_stat_activity.query_start AS duration,
  state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '1 minutes';

-- Show backend connections with queries that takes more that 5 seconds (Long running queries)
SELECT
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state
FROM 
    pg_stat_activity
WHERE 
    state != 'idle' AND 
    pid != pg_backend_pid() AND
    datname = current_database() AND
    (now() - pg_stat_activity.query_start) > interval '5 seconds';

-- Show backend connection with transactions that takes more that 5 seconds (Long running transactions)
SELECT
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state
FROM 
    pg_stat_activity
WHERE 
    state != 'idle' AND 
    pid != pg_backend_pid() AND
    datname = current_database() AND
    (now() - pg_stat_activity.xact_start) > interval '5 seconds';

-- Kill a query with pid caceling it
SELECT pg_cancel_backend(<pid>);

-- Kill the backend session(connection)
SELECT pg_terminate_backend(<pid>);

-- Show locks in the DB
SELECT 
    locktype,
    relation::regclass, mode, 
    transactionid AS tid,
    virtualtransaction AS vtid, 
    pid, 
    granted
FROM 
    pg_locks l LEFT JOIN pg_database db ON (db.oid = l.database) 
WHERE 
    pid != pg_backend_pid() AND
    db.datname = current_database();

-- Show anomalies
-- commit_ratio aprox > 95%
-- rollback_ratio aprox < 5%
-- deadlocks cercano a 0
-- conflicts cercano a 0
-- You can restart this stats doing SELECT pg_stat_reset();
SELECT
    datname,
    (xact_commit * 100) / (xact_commit + xact_rollback) AS commit_ratio,
    (xact_rollback * 100) / (xact_commit + xact_rollback) AS rollback_ratio,
    deadlocks,
    conflicts,
    temp_files,
    pg_size_pretty(pg_database_size(datname)) AS db_size
FROM
    pg_stat_database
WHERE
    xact_commit + xact_rollback != 0;

-- Show autovacum it means that the query shows the tables that needs autovacum sorting by priority
SELECT
    relname AS table_name,
    n_live_tup AS estimate_live_rows,
    n_dead_tup AS estimate_dead_rows,
    last_vacuum, 
    last_autovacuum, 
    last_analyze, 
    last_autoanalyze
FROM 
    pg_stat_user_tables
WHERE
    schemaname = 'public' AND
    n_live_tup != 0
ORDER BY 
    n_dead_tup / (n_live_tup * current_setting('autovacuum_vacuum_scale_factor')::float8 + current_setting('autovacuum_vacuum_threshold')::float8) DESC
LIMIT 10;

-- Show which tables needs vacuuming
SELECT datname, age(datfrozenxid) FROM pg_database
ORDER BY age(datfrozenxid) desc
LIMIT 20;

-- Show IO Statistics
SELECT 
	t.relname AS table_name, 
	heap_blks_hit * 100 / (heap_blks_hit + heap_blks_read) AS heap_ratio,
	idx_blks_hit * 100 / (idx_blks_hit + idx_blks_read) AS idx_ratio
FROM 
	pg_statio_user_tables t
WHERE 
	t.heap_blks_read > 0 AND
	t.idx_blks_read > 0;

-- Show unused indexes
SELECT
    relid::regclass AS table_name, 
    indexrelid::regclass AS index_name, 
    pg_size_pretty(pg_relation_size(indexrelid::regclass)) AS index_size
FROM
    pg_stat_user_indexes 
    JOIN pg_index USING (indexrelid) 
WHERE
    idx_scan = 0 AND 
    indisunique IS FALSE
ORDER BY
    pg_relation_size(indexrelid::regclass) DESC;

-- Show cache hit ratio
SELECT 
    SUM(blks_hit) * 100/ SUM(blks_hit+blks_read) AS hit_ratio 
FROM
    pg_stat_database;

-- Show blocked queries
SELECT
    pid,
    usename,
    pg_blocking_pids(pid) AS blocked_by,
    query AS blocked_query
FROM 
    pg_stat_activity
WHERE 
    cardinality(pg_blocking_pids(pid)) > 0;

-- Show invalid indexes
SELECT
    t.relname AS index_name
FROM 
    pg_class t, pg_index idx
WHERE 
    idx.indisvalid = false AND 
    idx.indexrelid = t.oid;

-- Show Statistics of the tables
SELECT
    relname AS table_name,
    n_live_tup AS estimate_live_rows,
    n_dead_tup AS estimate_dead_rows,
    seq_scan AS total_seq_scan,
    seq_tup_read AS total_fetch_seq_scan,
    idx_scan AS total_index_scan,
    idx_tup_fetch AS total_fetch_idx_scan,
    n_tup_ins AS inserted_rows,
    n_tup_del AS deleted_rows,
    n_tup_upd AS updated_rows,
    n_tup_hot_upd AS updated_rows_hot,
    COALESCE(n_tup_ins,0) + COALESCE(n_tup_upd,0) - COALESCE(n_tup_hot_upd,0) + COALESCE(n_tup_del,0) AS total,
    (COALESCE(n_tup_hot_upd,0)::float * 100/(CASE WHEN n_tup_upd > 0 THEN n_tup_upd ELSE 1 END)::float)::numeric(10,2) AS hot_rate,
    pg_size_pretty(pg_relation_size(relname::regclass)) AS table_size
FROM 
    pg_stat_user_tables
WHERE
    schemaname = 'public';

-- Show the duplicated indexes
SELECT
    pg_size_pretty(SUM(pg_relation_size(idx))::BIGINT) AS index_size,
    (array_agg(idx))[1] AS idx1, 
    (array_agg(idx))[2] AS idx2,
    (array_agg(idx))[3] AS idx3, 
    (array_agg(idx))[4] AS idx4
FROM (SELECT 
        indexrelid::regclass AS idx, 
        (indrelid::text ||E'\n'|| indclass::text ||E'\n'|| indkey::text ||E'\n'|| COALESCE(indexprs::text,'')||E'\n' || COALESCE(indpred::text,'')) AS KEY
    FROM 
        pg_index) sub
GROUP BY
    KEY HAVING COUNT(*)>1
ORDER BY
    SUM(pg_relation_size(idx)) DESC;

-- Show indexes use in percentage
SELECT 
    relname, 
    100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used, 
    n_live_tup estime_rows 
FROM 
    pg_stat_user_tables 
WHERE
    schemaname = 'public' AND
    idx_scan != 0 
ORDER BY 
    n_live_tup DESC;

-- Show tables that doesn't have configurations
SELECT 
    reloptions 
FROM 
    pg_class 
WHERE 
    reloptions != null;

-- Query that indicates if a index is needed
SELECT
    relname AS table_name,
    seq_scan - idx_scan AS too_much_seq,
    CASE
    WHEN
        seq_scan - COALESCE(idx_scan, 0) > 0
    THEN
        'Missing Index?'
    ELSE
        'OK'
    END AS result,
    pg_size_pretty(pg_relation_size(relname::regclass)) AS table_size,
    seq_scan AS sequential_scans, 
    idx_scan AS indexes_scans
FROM
    pg_stat_user_tables
WHERE
    schemaname = 'public' AND
    n_live_tup != 0
ORDER BY
    too_much_seq DESC;

-- Show connections per host
SELECT 
    client_addr,count(client_addr)
FROM
    pg_stat_ssl JOIN pg_stat_activity ON 
        pg_stat_ssl.pid = pg_stat_activity.pid
GROUP BY
    client_addr
ORDER BY 
    count;

-- Show CPU usage of a query
-- Disclaimer: to run this query we must have installed the extension pg_stat_statements
SELECT
    substring(query, 1, 50) AS short_query,
    round(total_time::numeric, 2) AS total_time,
    calls,
    round(mean_time::numeric, 2) AS mean,
    round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM
    pg_stat_statements
ORDER BY 
    total_time DESC;

-- Show pg_stat_stataments
-- Disclaimer: to run this query we must have installed the extension pg_stat_statements
SELECT
    (total_time / 1000 / 60) AS total_minutes,
    (total_time/calls) AS average_time,
    calls,
    temp_blks_read,
    temp_blks_written,
    query
FROM
    pg_stat_statements
ORDER BY 
    temp_blks_written DESC,
    temp_blks_read DESC
LIMIT 100;

-- Show DB size information
SELECT 
    *, 
    pg_size_pretty(table_bytes) AS table_size,
    pg_size_pretty(index_bytes) AS index_size, 
    pg_size_pretty(toast_bytes) AS toast_size,
    pg_size_pretty(total_bytes) AS total_size
FROM (
    SELECT 
        *, 
        total_bytes - index_bytes - COALESCE(toast_bytes,0) AS table_bytes 
    FROM (
        SELECT 
            c.oid,nspname AS table_schema, 
            relname AS table_name, 
            c.reltuples AS row_estimate, 
            pg_total_relation_size(c.oid) AS total_bytes, 
            pg_indexes_size(c.oid) AS index_bytes, 
            pg_total_relation_size(reltoastrelid) AS toast_bytes
        FROM 
            pg_class c 
                LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE
            relkind = 'r'
  ) temp1
) temp2
ORDER BY 
    total_bytes DESC;

-- Show total ratio of the DB
SELECT
    SUM(idx_blks_read) AS index_block_read, 
    SUM(idx_blks_hit) AS index_block_hit, 
    (SUM(idx_blks_hit) - SUM(idx_blks_read)) / SUM(idx_blks_hit) AS ratio
FROM 
    pg_statio_user_indexes;

-- Show total ratio per index
SELECT
    relname,
    indexrelname,
    SUM(idx_blks_read) AS index_block_read,
    SUM(idx_blks_hit) AS index_block_hit,
    (SUM(idx_blks_hit) - SUM(idx_blks_read)) / SUM(idx_blks_hit) AS ratio
FROM 
    pg_statio_user_indexes
WHERE
    idx_blks_hit > 0
GROUP BY
    relname,
    indexrelname
ORDER BY
    ratio;

-- Show unused indexes
SELECT
    relid::regclass AS table_name, 
    indexrelid::regclass AS index_name, 
    pg_size_pretty(pg_relation_size(indexrelid::regclass)) AS index_size
FROM
    pg_stat_user_indexes 
    JOIN pg_index USING (indexrelid) 
WHERE
    idx_scan = 0 AND 
    indisunique IS FALSE
ORDER BY
    pg_relation_size(indexrelid::regclass) DESC;

-- Show the wait events
SELECT 
    wait_event,
    count(*)
FROM 
    pg_stat_activity
WHERE
    wait_event != null 
GROUP BY
    wait_event;

-- Check table statistics about the number of dead tuples
SELECT relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%",
    to_char(last_autovacuum, 'YYYY-MM-DD HH24:MI:SS') as autovacuum_date, 
    to_char(last_autoanalyze, 'YYYY-MM-DD HH24:MI:SS') as autoanalyze_date
FROM pg_stat_all_tables 
ORDER BY last_autovacuum;

-- Check sessions querying a specific table
SELECT datname, usename, pid, current_timestamp - xact_start AS xact_runtime, state, query
FROM pg_stat_activity 
WHERE query LIKE '%table1%'
ORDER BY xact_start;