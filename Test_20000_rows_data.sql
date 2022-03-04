# Build a 10,000 table with clustered index and secondary INDEX 
# 1. check DATABASES 
SHOW DATABASES;
# 2. CREATE a new DATABASE called Large_data_100000 and USE it
CREATE DATABASE Large_data_100000;
USE Large_data_100000;
# 3. CREATE two new TABLE named students and courses with INDEX
#	 3.0 PRIMARY KEY id, secondary INDEX(name, course_id),FOREIGN KEY course_id 
#	 3.1 student (id, name, course_id, score)
#	 3.2 course (id, name, teacher)
CREATE TABLE courses (
	id INT(10) AUTO_INCREMENT NOT NULL,
	name VARCHAR(30),
	teacher VARCHAR (30),
	PRIMARY KEY (id),
	INDEX name_teacher(name, teacher)
)ENGINE=INNODB CHARSET=utf8;
CREATE TABLE students (
	id INT(10) AUTO_INCREMENT NOT NULL,
	name VARCHAR(30),
	course_id INT(10) NOT NULL,
	score DOUBLE,
	PRIMARY KEY (id),
	FOREIGN KEY (course_id) REFERENCES courses (id),
	INDEX name_course(name, course_id),
	INDEX course_score(course_id ASC, score DESC)
) ENGINE=INNODB CHARSET=utf8;
SHOW CREATE TABLE courses;
# DROP will remove all tables, if only DELETE data use DELETE 
DROP TABLE courses ;
SHOW TABLES;
# 如此添加，在表后面排列
INSERT INTO courses(name, teacher) VALUES ("FQT", "Lily");
# 如此添加，在表前面排列!少用!!
INSERT INTO courses VALUES (1, "FQT", "Cooties");
INSERT INTO courses VALUES (2, "FQT", "Abscess");
DELETE FROM courses WHERE id=2;
SELECT * FROM courses c ;

# 4. CREATE a function for making random data (random number, random string)
#	 check log_bin
SELECT @@log_bin_trust_function_creators;
SET GLOBAL log_bin_trust_function_creators = 1;
#select substring(MD5(RAND()),1,20);
DELIMITER $
CREATE FUNCTION RandomIntNumber(minNum INT, maxNum INT)
RETURNS INT
BEGIN
	DECLARE num INT;
	SET num = FLOOR(RAND()*(maxNum - minNum + 1)+minNum);
	RETURN num;
END $
DELIMITER ;
SELECT RandomIntNumber (2, 4);


DELIMITER $
CREATE FUNCTION RandomDoubleNumber(minNum INT, maxNum INT)
RETURNS DOUBLE 
BEGIN
	DECLARE num DOUBLE ;
	SET num = RAND()*(maxNum - minNum + 1)+minNum;
	RETURN num;
END $
DELIMITER ;
DROP FUNCTION RandomDoubleNumber ;
DROP FUNCTION RandomIntNumber ;
SELECT RandomDoubleNumber (0,150);

DELIMITER $
CREATE FUNCTION RandomName(len INT)
RETURNS VARCHAR(255)
BEGIN
	DECLARE name VARCHAR(255) DEFAULT CHAR(ROUND(RAND()*25)+65);
	DECLARE i INT DEFAULT 0;
	WHILE i<len DO
		SET name = CONCAT(name, CHAR(ROUND(RAND()*25)+97));
		SET i = i+1;
	END WHILE;
	RETURN name;
END $
DELIMITER ;
DROP FUNCTION RandomName;
SELECT RandomName (10);
SELECT CONCAT('',CHAR(ROUND(RAND()*25)+97));
# 5. CREATE a PROCEDURE to put random data to tables
DELIMITER $
CREATE PROCEDURE LoadData(IN num_stus INT, IN num_course INT)
BEGIN
	DECLARE j INT DEFAULT 1;
	DECLARE i INT DEFAULT 1;
	DECLARE score DOUBLE DEFAULT 0;

	WHILE j<=num_course DO
		INSERT INTO courses(name, teacher) VALUES (
				RandomName (20),RandomName (10));
		SET j = j + 1;
	END WHILE;

	WHILE i<num_stus DO
		INSERT INTO students(name, course_id, score) VALUES(
				RandomName(10), RandomIntNumber(1,num_course), 
				RandomDoubleNumber(0, 150)) ;
		SET i = i + 1;
	END WHILE;
END $
DELIMITER ;

DELIMITER $
CREATE PROCEDURE insert_data(IN num_stus INT, IN num_course INT)
BEGIN
	DECLARE j INT DEFAULT 1;
	DECLARE i INT DEFAULT 1;
	DECLARE score DOUBLE DEFAULT 0;

	WHILE j<=num_course DO
		INSERT INTO courses(name, teacher) VALUES (
				RandomName (9),RandomName (3));
		SET j = j + 1;
	END WHILE;
	
-- 	SET total_course = SELECT DISTINCT (id) FROM courses c ;
	WHILE i<=num_stus DO
-- 		SET cid = SELECT (SELECT DISTINCT (id) FROM courses c 
-- 					ORDER BY RAND() LIMIT 1);
		INSERT INTO students(name, course_id, score) VALUES(
				RandomName(6), (SELECT DISTINCT (id) FROM courses c 
					ORDER BY RAND() LIMIT 1), 
				RandomDoubleNumber(0, 150));
		SET i = i + 1;
	END WHILE;
END $
DELIMITER ;

DROP PROCEDURE insert_data ;
CALL insert_data(10000,100);
SELECT DISTINCT (id) FROM courses c ORDER BY RAND() LIMIT 1;
DROP PROCEDURE LoadData ;
CALL LoadData (200,10);
SHOW CREATE TABLE courses ;
EXPLAIN SELECT SQL_NO_CACHE s.course_id, score FROM students s
		WHERE s.course_id =10 OR s.score = 100;
EXPLAIN SELECT SQL_NO_CACHE name, course_id FROM students s 
		WHERE s.name LIKE "Ab%" AND s.course_id = 88;
EXPLAIN SELECT s.course_id  FROM students s UNION SELECT id FROM courses c2 ;
EXPLAIN SELECT c.name, c.teacher FROM courses c ORDER BY id;
SELECT s.id, s.name, c.name, c.teacher FROM students s JOIN courses c  
		WHERE s.course_id =c.id 
		ORDER BY s.id;
SHOW STATUS LIKE "last_query_cost";
SHOW VARIABLES LIKE "profiling";
SET profiling = 'ON';
SHOW PROFILES;
DELETE FROM students ;
DELETE FROM courses ;
DROP TABLE students ;
DROP TABLE courses ;

# 6. Modify rows:
ALTER TABLE courses MODIFY name VARCHAR(30) NOT NULL;