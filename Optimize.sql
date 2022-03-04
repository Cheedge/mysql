# 调优参数指标监控
# 1. SHOW TABLE and COLUMNS /DESCRIBE /ANALYZE/CHECK/OPTIMIZE 
SHOW COLUMNS FROM students;
DESCRIBE students;
SHOW CREATE TABLE students;
CHECK TABLE students ;
ANALYZE TABLE students ;
OPTIMIZE TABLE students ;

# 2. VARIABLES:
# 	2.1 profiling 
SHOW VARIABLES LIKE "profiling";
SET @@profiling = "ON";
SHOW PROFILES;
# 	2.2 optimizer
SHOW variables LIKE "%optimizer%";
SELECT @@optimizer_switch;
SET @@optimizer_switch = "index_condition_pushdown=on";
# 	2.3 slow query
SHOW VARIABLES LIKE "%slow%";
SELECT @@slow_query_log_file;
SELECT @@slow_query_log;
SET @@slow_query_log="ON";
# 	2.4 buffer
SHOW VARIABLES LIKE "%buffer%";
# 	2.5 cache
SHOW VARIABLES LIKE "%cache%";

# 	2.6 add functions
SHOW VARIABLES LIKE "%function%";

# 3. STATUS:
FLUSH STATUS;
# 	3.0 TABLE 
SHOW TABLE STATUS LIKE "students";
# 	3.1 Handler 
SHOW STATUS LIKE "Handler%";# Handler_read_next
# 	3.2 Thread
SHOW STATUS LIKE "Thread%";
#当 Threads_cached 越来越少,但 Threads_connected 始终不降,且 Threads_created 持续升高,可
#适当增加 thread_cache_size 的大小。
SET @@thread_cache_size = 64;

# 4. PROCESSLIST 
SHOW PROCESSLIST ;

# 5. information_schema
SELECT * FROM information_schema.`COLUMNS` c WHERE TABLE_NAME = "students";
SELECT * FROM information_schema.PROCESSLIST p WHERE COMMAND LIKE "Sleep";
