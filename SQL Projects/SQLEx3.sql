-- Title: SQL Practice Exercises
-- Made by Valerie Lim
-- Date: 28 July 2017
-- Contents: Aggregate functions GROUP BY, HAVING, CASE

# ------------------------------- EXERCISE 3 ------------------------------- #

-- Qn1
-- Display number of rows in Employees table.
SELECT COUNT(*)
FROM EMPLOYEES;

-- Qn2 & Qn3 together
-- Display the number of values (excluding NULLs) in commission_pct column.
-- Display the number of NULL values in commission_pct column. 
SELECT 
	COUNT(*) as "All Rows",
    COUNT(CASE WHEN COMMISSION_PCT IS NULL THEN 1 ELSE NULL END) as "NULL",
    COUNT(CASE WHEN COMMISSION_PCT IS NOT NULL then 1 ELSE NULL END) as "NOT NULL"
from EMPLOYEES;

-- Qn4 
-- Display the lowest, highest, and average salary.
SELECT MAX(SALARY), MIN(SALARY), AVG(SALARY)
FROM EMPLOYEES;

-- Qn5a
-- Display the average salary per department with the dept number.
SELECT AVG(SALARY)
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID;

-- Qn5b
-- Display the average salary per dept for dept 50 and 80. 
SELECT AVG(SALARY)
FROM EMPLOYEES
WHERE DEPARTMENT_ID = ('50', '80')
GROUP BY DEPARTMENT_ID;

-- Qn6a
-- Display the job ID and number of employees for each job ID.
SELECT COUNT(JOB_ID)
FROM EMPLOYEES
GROUP BY JOB_ID;

-- Qn6b
-- Display only for employees whose salary is greater than 10000. 
SELECT COUNT(JOB_ID)
FROM EMPLOYEES
WHERE SALARY > 10000
GROUP BY JOB_ID;

-- Qn6c
-- Modify your query to include results with jobs with more than 2 people. 
SELECT COUNT(JOB_ID) AS num_employees
FROM EMPLOYEES
WHERE SALARY > 10000
HAVING num_employees > 2
GROUP BY JOB_ID;

-- Qn7a
-- Display the manager ID and the highest salary for each manager ID. 
SELECT MANAGER_ID, MAX(SALARY)
FROM EMPLOYEES
GROUP BY MANAGER_ID;

-- Qn7b
-- Display the manager ID, highest salary for that manager ID, for employees
-- whose salary is greater than 10,000.
SELECT MANAGER_ID, MAX(SALARY)
FROM EMPLOYEES
WHERE SALARY > 10000 
GROUP BY MANAGER_ID;

-- Qn8 
-- Display the job ID and minimum salary for each ID, for all jobs whose
-- minimum salary is greater than 7000.
SELECT JOB_ID, MIN(SALARY)
FROM EMPLOYEES
HAVING MIN(SALARY) > 7000
GROUP BY JOB_ID;

-- Qn9
-- Display the dept ID, average salary for each dept, for all depts whose number 
-- is in range of 20 and 80, and has an average salary greater than 9000.
SELECT DEPARTMENT_ID, AVG(SALARY)
FROM EMPLOYEES
WHERE DEPARTMENT_ID BETWEEN 20 AND 80
HAVING AVG(SALARY) > 9000
GROUP BY DEPARTMENT_ID;

-- Qn10 
-- For each employee, display the first name, last name, salary and salary grade
-- based on these conditions (see table).
SELECT FIRST_NAME, LAST_NAME, SALARY, 
	CASE
	WHEN SALARY BETWEEN 0 AND 5000 THEN A 
	WHEN SALARY BETWEEN 5001 AND 150000 THEN B
	WHEN SALARY BETWEEN 150001 AND 20000 THEN C
	ELSE D 
	END AS "Grade Level"
FROM EMPLOYEES;


