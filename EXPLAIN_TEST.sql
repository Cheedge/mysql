# EXPLAIN 
# 1. key_len: useful for multicol index
# varchar(len)=len*(character set:utf8=3,gbk=2,latin1=1)+1(NULL)+2(变长)
EXPLAIN SELECT name FROM students;# VARCHAR(30)=30*3+1+2=93 + INT=4 =97

# 2. type:
# const: 单一查找任意，限定条件主键索引
EXPLAIN SELECT * FROM students WHERE id = 30;
# ref: 单一查找任意，限定条件联合索引
EXPLAIN SELECT * FROM students WHERE course_id = 60;
EXPLAIN SELECT * FROM students WHERE name = 'Ass';
# range: 范围查找
EXPLAIN SELECT course_id FROM students WHERE course_id < 60;
EXPLAIN SELECT * FROM students WHERE students.name = 'Aaa' AND course_id < 60;
EXPLAIN SELECT course_id FROM students WHERE course_id < 60;
EXPLAIN SELECT course_id FROM students WHERE score < 100;
# 范围查找field+限定条件field NOT IN 联合索引: ALL
EXPLAIN SELECT * FROM students WHERE course_id < 10;
EXPLAIN SELECT id FROM students WHERE score < 100; 
# index: 与ALL区别为:ALL(遍历全表); index(遍历索引树)
EXPLAIN SELECT name, course_id FROM students WHERE course_id < 60;
# mySQL可自主优化，所以不一定都遵循上述原则
EXPLAIN SELECT name FROM students WHERE course_id < 60; # index
EXPLAIN SELECT name FROM students WHERE course_id < 10; # range

# 3. rows(越小好，加载页少) & filtered(WHERE|HAVING后，剩余/全部)


# 4. Extra:
#	a. Using index condition:
#	b. Using where
#	c. Using TEMPORARY
#	d. Using join buffer
#	e. Using index condition (index condition pushdown)ICP
#		索引下推: 指将部分上层（服务层）负责的事情WHERE，提前交给了下层（引擎层）去处理
#		下推->WHERE(service层)->回表->联合索引
SHOW VARIABLES LIKE "optimizer_switch";# index_condition_pushdown=on
EXPLAIN SELECT * FROM students WHERE name LIKE 'Rjuupob';
EXPLAIN SELECT score FROM students WHERE name LIKE 'R%';
EXPLAIN SELECT course_id FROM students WHERE score>10 AND name LIKE "B%";
#	不需要回表，不用ICP
EXPLAIN SELECT course_id FROM students WHERE name LIKE 'R%';# range
#	range/ref/eq_ref/ref_or_null访问方法
EXPLAIN SELECT name FROM students WHERE name LIKE '%R';# index

# 5. 相关指标监控
SHOW VARIABLES LIKE "optimizer_switch";# index_condition_pushdown=on
SET @@optimizer_switch = "index_condition_pushdown=on";
FLUSH STATUS;
SHOW STATUS LIKE "%handler%";
SHOW VARIABLES LIKE "profiling";
SET @@profiling = "ON";
SHOW PROFILES;