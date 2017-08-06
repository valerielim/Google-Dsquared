-- Title: SQL Practice Exercises
-- Made by Valerie Lim
-- Date: 28 July 2017
-- Contents: CONCAT, BOOLEAN, DATE MANIPULATION, STRING MANIPULATION

# ------------------------------- EXERCISE 2 ------------------------------- #

-- Qn1
-- Create a query to display the last name concatenated with the first name, 
-- separated by space, and the telephone number concatenated with the email 
-- address,separated by hyphen. Name the colum nheadings "FULL_NAME" and 
-- "CONTACT_DETAILS" respectively (Employees tables).
SELECT LAST_NAME+' '+FIRST_NAME AS FULL_NAME,
		PHONE_NUMBER+-+EMAIL AS CONTACT_DETAILS
FROM EMPLOYEES;

-- Qn2
-- Create a query to display the last name concatenated with job_id column, 
-- separated by space. Name this column heading as "EMPLOYEE_AND_TITLE".
-- Note the data type for jobID.

SELECT LAST_NAME+' '+JOB_ID AS EMPLOYEE_AND_TITLE
FROM EMPLOYEES;

-- Qn3 
-- Display the first name in lower case and the lat name in upper case, for all 
-- employees whose employee number is in the range between 80 and 150.
SELECT LOWER(FIRST_NAME)+' '+UPPER(LAST_NAME)
FROM EMPLOYEES
WHERE EMPLOYEE_ID BETWEEN 80 AND 150;

--Qn4
-- Display the first name and last name for all employees whose family name is 
-- King, perform this exercise with a case-insensitive search (regardless of the
-- capitalisation used for the values within last name column).
SELECT FIRST_NAME, LAST_NAME
FROM EMPLOYEES
WHERE LAST_NAME LIKE LOWER(king); -- case insensitive search

-- Qn5a
-- Using the CONCAT function, display the first name concatenated with the last 
-- name. 
SELECT CONCAT(FIRST_NAME , LAST_NAME)
FROM EMPLOYEES;

-- Qn5b
-- Using the CONCAT function, display the first name + last name + hire date
SELECT CONCAT(FIRST_NAME , CONCAT(LAST_NAME , CAST(HIRE_DATE AS VARCHAR))
FROM EMPLOYEES; -- note the space behind the "first name"

-- Qn6
-- Display the last name for all employees where the last name's length is 
-- greater than 8 characters.
SELECT LAST_NAME
FROM EMPLOYEES
WHERE LEN(LAST_NAME) > 8;

-- Qn7
-- For each employee, display the first name, last name, phone number and a new 
-- phone number using the REPLACE function. The new phone number replaces all 
-- occurences of 515 with 815.
SELECT FIRST_NAME, LAST_NAME,
	PHONE_NUMBER, REPLACE(PHONE_NUMBER, 515, 815) AS NEW_NUM
FROM EMPLOYEES; 

-- Qn8
-- For each employee, display: (long winded stuff here)
SELECT FIRST_NAME, SALARY, 
	(SALARY*1.12) AS SAL_12, 
	ROUND(SAL_12),
	FLOOR(SAL_12)
FROM EMPLOYEES;

-- Qn9
-- For each employee, display the first name, hire date, hire date minus 10  
-- days, hire date plus one month, and the day difference between the current 
-- date and the hire date.
SELECT FIRST_NAME, HIRE_DATE, 
	DATEADD(DAY, -10, HIRE_DATE) AS DAY_10,
	DATEADD(MONTH, 1, HIRE_DATE) AS MONTH_1,
	DATEDIFF(DAY, HIRE_DATE, GETDATE()) AS DIFF
FROM EMPLOYEES;

-- Qn10
-- For each employee, display the first name, day of his first hire, 
-- and the year of his hire date.
SELECT FIRST_NAME, DAY(HIRE_DATE), YEAR(HIRE_DATE)
FROM EMPLOYEES;

-- Qn11a
-- For each employee, display the first name ... 
SELECT FIRST_NAME, LAST_NAME, SALARY, 
	IF(ISNULL(COMMISSION_PCT), 0, COMMISSION_PCT) AS COM
FROM EMPLOYEES;

-- Qn11b
-- For each employee, display the first name, last name, salary and commission 
-- percentage. If an employee doesn't earn a commission, display "No Commission"
-- instead of NULL.
SELECT FIRST_NAME, LAST_NAME, SALARY, 
	ISNULL(CAST(COMMISSION_PCT AS VARCHAR, 'No Commission') AS COM 
FROM EMPLOYEES;
