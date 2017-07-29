-- Title: SQL Practice Exercises
-- Made by Valerie Lim
-- Date: 28 July 2017
-- Contents: JOINS, 2-way, 3-way

# ------------------------------- EXERCISE 4 ------------------------------- #

-- Qn1a
-- For each department, display the department name, city, and state province. 
SELECT D.DEPARTMENT_NAME, L.CITY, L.STATE_PROVINCE
FROM DEPARTMENTS D 
	JOIN LOCATIONS L
		ON D.LOCATION_ID = L.LOCATION_ID;

-- Qn1b
-- For each employee, display the full name, department name, city, and 
-- state province. 
SELECT CONCAT(E.FIRST_NAME , E.LAST_NAME) AS FULLNAME,
	D.DEPARTMENT_NAME, L.CITY, L.STATE_PROVINCE
FROM EMPLOYEES E 
	LEFT JOIN DEPARTMENTS D 
		ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
	LEFT JOIN LOCATIONS L 
		ON D.LOCATION_ID = L.LOCATION_ID;

-- Qn1c
-- Display the full name, department name, city and state province, for all 
-- employees whose last name contains the letter a. 
SELECT CONCAT(E.FIRST_NAME , E.LAST_NAME) AS FULLNAME,
	D.DEPARTMENT_NAME, L.CITY, L.STATE_PROVINCE
FROM EMPLOYEES E 
	LEFT JOIN DEPARTMENTS D 
		ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
	LEFT JOIN LOCATIONS L 
		ON D.LOCATION_ID = L.LOCATION_ID	 
WHERE LOWER(E.LAST_NAME) LIKE '%a%';

-- Qn2a
-- Display the first name, last name, department number and department name, 
-- for all employees INCLUDING THOSE WITHOUT ANY DEPARTMENTS.
SELECT E.FIRST_NAME, E.LAST_NAME, D.DEPARTMENT_ID, D.DEPARTMENT_NAME
FROM EMPLOYEES E 
	LEFT JOIN DEPARTMENTS D 
		ON E.DEPARTMENT_ID = E.DEPARTMENT_ID;

-- Qn2b
-- Modify your query to display all departments including departments without 
-- any employees. 
SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME, E.FIRST_NAME, E.LAST_NAME
FROM DEPARTMENTS D  
	LEFT JOIN EMPLOYEES E 
		ON E.DEPARTMENT_ID = E.DEPARTMENT_ID
WHERE E.EMPLOYEE_ID IS NULL;
-- Assume employee ID is primary key; cannot be NULL

-- Qn3a
-- For each employee, display the last name, and the manager's last name. 
SELECT E1.LAST_NAME AS 'Employee Last Name', 
	E2.LAST_NAME AS 'Manager Last Name'
FROM EMPLOYEES E1 
	LEFT JOIN EMPLOYEES E2 
		ON E1.MANAGER_ID=E2.EMPLOYEE_ID;

-- Qn3b
-- Modify your query to display all employees including those WITHOUT managers.
SELECT E1.LAST_NAME AS 'Employee Last Name', 
	E2.LAST_NAME AS 'Manager Last Name'
FROM EMPLOYEES E1 
	LEFT JOIN EMPLOYEES E2 
		ON E1.MANAGER_ID=E2.EMPLOYEE_ID
WHERE E1.MANAGER_ID IS NULL;
