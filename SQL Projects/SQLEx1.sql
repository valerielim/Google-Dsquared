-- Title: SQL Practice Exercises
-- Made by Valerie Lim
-- Date: 28 July 2017
-- Contents: Intro to SQL with basic select

# ------------------------------- EXERCISE 1 ------------------------------- #

-- Qn1
-- Create a query to display all the data from the EMPLOYEES table.
SELECT *
FROM EMPLOYEES;

-- Qn2
-- Create a query to display the unique manager numbers from EMPLOYEES table.
SELECT DISTINCT MANAGER_ID
FROM EMPLOYEES;

-- Qn3
-- Create a query to display the first name, last name, hire date, salary, and 
-- salary after a raise of 20%. Name the last column heading as ANNUAL_SAL. 
SELECT FIRST_NAME, LAST_NAME, HIRE_DATE, SALARY, 
		(SALARY*1.2) AS ANNUAL_SAL
FROM EMPLOYEES;

-- Qn4
-- Display all data from EMPLOYEES table for all employees who was hired before 
-- January 1st, 1992. 
SELECT * 
FROM EMPLOYEES
WHERE HIRE_DATE < '1992-01-01'; -- Assume YYYY-MM-DD format

-- Qn5
-- Display the employee number, first name, job ID and department number for 
-- all employees whose department number is not equal to 20, 60, 80.
SELECT EMPLOYEE_ID, FIRST_NAME, JOB_ID, DEPARTMENT_ID,
FROM EMPLOYEES
WHERE DEPARTMENT_ID NOT IN (20, 60, 80);

-- Qn6
-- Display the first name and salary for all employees whose first names ends
-- with an e (from EMPLOYEES table) 
SELECT FIRST_NAME, SALARY
FROM EMPLOYEES
WHERE FIRST_NAME LIKE '%e'; -- Assume data stored in small letters

-- Qn7
-- Display all data from Employees table for all employees who have the letters
-- L J H in their last name. Sort the query in descending order by salary.
SELECT *
FROM EMPLOYEES
WHERE LAST_NAME LIKE '%l%' OR '%j%' OR '%k%'OR '%L%' OR '%J' OR '%K%'
ORDER BY SALARY DESC;

-- Qn8
-- Display all data for all employees whose salary is in the range of 6,000 and 
-- 8,000 AND their commission is not null OR department number is not equal to 
-- 80, 90, 100 AND their hire date is before Jan 1, 1990.
SELECT *
FROM EMPLOYEES
WHERE (SALARY >= 6000 AND SALARY <= 8000 AND COMMISSION_PCT IS NOT NULL) 
	OR (DEPARTMENT_ID =! (80, 90, 100) AND HIRE_DATE < (1990-01-01));

-- Qn9
-- Display the last name, job ID and hire date for all employees who was hired
-- during Dec 12 1995 and Apr 17 1998. 
SELECT LAST_NAME, JOB_ID, HIRE_DATE
FROM EMPLOYEES
WHERE HIRE_DATE BETWEEN (1990-12-12) AND (1998-04-17); 
-- Assume hiredate only stores DATE info, no TIME info

-- Qn10
-- Display the first name concatenated with last name, hire date, commission
-- percentage, telephone and salary for all employees whose salary is greater
-- than 10,000 or the third digit in their phone number equals 5. Sort the
-- query in a descending order by teh first name. 
SELECT FIRST_NAME||''||LAST_NAME AS FULL_NAME, -- CONCAT
		HIRE_DATE, COMMISSION_PCT, PHONE_NUMBER, SALARY
FROM EMPLOYEES
WHERE SALARY > 10000 OR PHONE_NUMBER LIKE '__5%' -- NUMB
ORDER BY FIRST_NAME DESC;

-- Qn11
-- Display the last name and department number for all employees whose 
-- department is equal to 50 or 80. Perform this exercise once by using the 
-- IN operator and again using the OR operator.  
SELECT LAST_NAME, DEPARTMENT_ID
FROM EMPLOYEES
WHERE DEPARTMENT_ID IN (50, 80);

SELECT LAST_NAME, DEPARTMENT_ID
FROM EMPLOYEES
WHERE DEPARTMENT_ID = 50 OR DEPARTMENT_ID = 80;





