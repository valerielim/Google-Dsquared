-- Title: SQL Practice Exercises
-- Made by Valerie Lim
-- Date: 28 July 2017
-- Contents: SUBQUERIES

# ------------------------------- EXERCISE 5 ------------------------------- #

-- Qn1
-- Display the first name and salary for all employees who earn more than 
-- employee number 103.

SELECT E1.EMPLOYEE_ID
FROM EMPLOYEES E1 
WHERE E1.SALARY > (
	SELECT E2.SALARY
	FROM EMPLOYEES E2
	WHERE E2.EMPLOYEE_ID = 103)

-- Qn2
-- Display the department number and department name for all departments whose
-- location number is equal to the locaiton number of department 90.

SELECT D1.DEPARTMENT_ID, D1.DEPARTMENT_NAME
FROM DEPARTMENTS D1 
WHERE D1.LOCATION_ID = (
	SELECT D2.LOCATION_ID
	FROM DEPARTMENTS D2
	WHERE E2.DEPARTMENT_ID = 90)

-- Qn3
-- Display the first name, last name and department number for all employees who 
-- work in the Sales department.

SELECT E.FIRST_NAME, E.LAST_NAME, E.DEPARTMENT_ID
FROM EMPLOYEES E 
	LEFT JOIN DEPARTMENTS D 
		ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
WHERE D.DEPARTMENT_NAME = "Sales" -- Assume format is correct. 

-- Qn4
-- Display the first name, salary and department number for all employees who 
-- work in the same department as employee number 124. 

SELECT E1.FIRST_NAME, E1.SALARY, E1.DEPARTMENT_ID
FROM EMPLOYEES E1
WHERE E1.DEPARTMENT_ID = (
	SELECT E2.DEPARTMENT_ID
	FROM EMPLOYEES E2
	WHERE E2.EMPLOYEE_ID = 124)
AND EMPLOYEE_ID <> 124 -- you don't want to select 124 itself

-- Qn7
-- Display the first name, salary, and department number for all employees whose
-- salary equals one of the salaries in department 20.

SELECT E1.FIRST_NAME, E1.SALARY, E1.DEPARTMENT_ID
FROM EMPLOYEES E1
WHERE E1.SALARY IN ( -- select IN to group entire salary bracket
	SELECT E2.SALARY
	FROM EMPLOYEES E2
	WHERE E2.DEPARTMENT_ID = 20)

-- Qn8 
-- Display the first name, salary and department number for all employees who 
-- earn more than the maximum salary in department 50. 

SELECT E1.FIRST_NAME, E1.SALARY, E1.DEPARTMENT_ID
FROM EMPLOYEES E1
WHERE E1.SALARY > (
	SELECT MAX(E2.SALARY)
	FROM EMPLOYEES E2
	WHERE E2.DEPARTMENT_ID = 50)

-- Qn9
-- Display the first name, salary and department number for all employees who 
-- earn more than the minimum salary in department 60.

SELECT E1.FIRST_NAME, E1.SALARY, E1.DEPARTMENT_ID
FROM EMPLOYEES E1
WHERE E1.SALARY > (
	SELECT MIN(E2.SALARY)
	FROM EMPLOYEES E2
	WHERE E2.DEPARTMENT_ID = 60)

-- Qn10
-- Display the first, salary and department number for all employees who earn
-- less than the average salary, and also work at the same department as 
-- employee whose first name is 'Kevin'. 

SELECT E1.FIRST_NAME, E1.SALARY, E1.DEPARTMENT_ID
FROM EMPLOYEES E1
WHERE E1.DEPARTMENT_ID = (
		SELECT E2.DEPARTMENT_ID
		FROM EMPLOYEES E2 
		WHERE E2.FIRST_NAME = "Kevin")
HAVING SALARY < AVG(SALARY)


