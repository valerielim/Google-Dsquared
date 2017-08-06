# Differences in SQL, BigQuery

* SELECT DISTINCT command
* Strings in Bigquery is case sensitive 

# Others

### Syntax matching

* ``LIKE`` clause
* Underscore as wildcard string character

```
SELECT *
FROM movies
WHERE name LIKE se_en;
```

* % as "begin with" or "end with

```
SELECT *
FROM movies
WHERE name LIKE Man%; -- MAN OF STEEL
```
```
SELECT *
FROM movies
WHERE name LIKE %man; -- BATMAN
```
* Using the IN command

```
SELECT *
FROM movies
WHERE name IN ('Man%', '%man'); 
-- MAN OF STEEL, BATMAN
```

### Date Time

* ``DATE()`` returns only the date
* ``TIME()`` extracts only the time
* ``DATETIME()`` extracts both in syntax ``YYYY-MM-DD hh:mm:ss``

* Can manipulate *dateparts* too: 

``DATETIME(time1, '+3 hours', '40 minutes', '2 days')``

* Manipulate data type with ``SELECT CAST(number1 AS REAL)``

### String manipulation

* Concatename strings with

``SELECT string1 || '' || string2; -- db specific``

* Replace strings with

``REPLACE(string, from_string, to_string)``
