# WHERE GROUP BY HAVING ORDER BY IN EXISTS

# 0. CREATE DATABASE for test and INSERT DATA 
CREATE DATABASE group_order_explain;
USE group_order_explain ;
CREATE TABLE teamers(
	id INT AUTO_INCREMENT NOT NULL,
	name VARCHAR(10) NOT NULL,
	age INT NOT NUll,
	city VARCHAR(20) NOT NULL,
	join_time DATE NOT NULL,
	PRIMARY KEY (id)
)engine=INNODB CHARSET=utf8;
INSERT INTO teamers(name, age, city, join_time) 
	VALUES("Alex", 26, "Ames", "2005-03-27");
SELECT * FROM teamers;
SHOW VARIABLES LIKE "secure_file_priv";
LOAD DATA LOCAL INFILE 'teamers.txt' INTO TABLE teamers (
	name, age, city, join_time 
);
TRUNCATE TABLE teamers; 

# 0. GROUP & ORDER 可能存在问题:temporary表，filesort.
#		解决: 对GROUP&ORDER后字段建立 INDEX
SHOW VARIABLES LIKE "tmp_table_size";# 16K 尽量只使用内存临时表
SHOW VARIABLES LIKE "max_length_for_sort_data";# use rowid回表/全字段排序

# 1. GROUP BY 
# Using WHERE, temporary; add index Using WHERE 
EXPLAIN SELECT city, COUNT(*)  FROM teamers WHERE age>60 GROUP BY city;
EXPLAIN SELECT join_time, COUNT(*)  FROM teamers WHERE age>60 GROUP BY join_time;
# Using WHERE, filesort; add index Using WHERE ; or use ORDER BY NULL
EXPLAIN SELECT GROUP_CONCAT(id,":",name), city  FROM teamers WHERE age>30 GROUP BY city ;
EXPLAIN SELECT GROUP_CONCAT(id,":",name), join_time FROM teamers WHERE age>30 GROUP BY join_time;
-- EXPLAIN SELECT GROUP_CONCAT(id,":",name), join_time FROM teamers
EXPLAIN SELECT city FROM teamers 
	GROUP BY city;
	ORDER BY NULL;
# Using temporary; add index Using INDEX
# HAVING后字段与GROUP一致，WHERE随意
EXPLAIN SELECT city, COUNT(*)  FROM teamers GROUP BY city HAVING city LIKE "%t%";
EXPLAIN SELECT join_time, COUNT(*)  FROM teamers GROUP BY join_time HAVING join_time > 1989;

SHOW VARIABLES LIKE "sql_mode";
#SET @@ONLY_FULL_GROUP_BY="";规避提示ONLY_FULL_GROUP_BY，先不要用

# 2. ORDER BY
EXPLAIN SELECT name, age, city FROM teamers WHERE city='Seattle' ORDER BY age;
EXPLAIN SELECT name, age, city FROM teamers WHERE city='Seattle' ORDER BY NULL;
# 覆盖索引

# group by 后面的字段加索引
DESCRIBE teamers;
ALTER TABLE teamers ADD INDEX idx_city(city);
ALTER TABLE teamers DROP INDEX idx_city;
ALTER TABLE teamers ADD INDEX age_city(age, city);
ALTER TABLE teamers DROP INDEX age_city;

# IN or EXISTS
USE Large_data_100000;
SHOW TABLES;
SELECT * FROM courses c ;
# 7ms
EXPLAIN SELECT name FROM students WHERE course_id IN (
	SELECT course_id FROM courses);
# 1ms
EXPLAIN SELECT name FROM students WHERE EXISTS (
	SELECT course_id FROM courses WHERE students.course_id=courses.id);
# 2ms
EXPLAIN SELECT students.name FROM students JOIN courses;

# IN 不走索引:
# 	1. IN (数据大)
EXPLAIN SELECT "name" FROM students WHERE course_id IN (
1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,
27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,
50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72);
#	2. IN(子查询、格式化函数)
#	3. 查询的列是char类型没有加引号，mysql优化器会自动给填充引号
EXPLAIN SELECT name FROM students WHERE course_id IN (
1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,
27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,
50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72);