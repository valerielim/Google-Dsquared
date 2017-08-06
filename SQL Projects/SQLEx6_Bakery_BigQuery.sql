-- Title: BIGQUERY Business Case Qns
-- Made by Valerie Lim & Grace Chow
-- Date: 31 July 2017
-- Contents: Advanced SQL via BigQuery

# ------------------------------- EXERCISE 5 ------------------------------- #

-- 1. Find all chocolate-flavoured items on the menu whose price is under $5.00.
-- For each item, output the flavour, food type and price of the item. Sort your 
-- output in descending order by price. 

SELECT Flavor, Food, Price 
FROM goods
WHERE Flavor = 'Chocolate' AND Price < 5
ORDER BY Price DESC;

-- 2. Report the prices of the following items: 
-- a. Any cookie priced above $1.10
-- b. Any lemon-flavoured items
-- c. Any apple-flavoured item except for the pie

SELECT Flavor, Food, Price
FROM goods
WHERE (Flavor = 'Lemon')
	OR (Food = 'Cookie' AND Price > 1.10)
	OR (Flavor = 'Apple' AND Food != 'Pie')
ORDER BY Flavor ASC, Food ASC;

-- 3. Find all customers who made a purchase on October 3 2007. Report the 
-- name of the customer (first, last). Sort the output in alphabetical order by 
-- the customer's last name. Each customer name must appear at most once. 

SELECT C.FirstName, C.LastName, C.Id
FROM customers C
JOIN (
	SELECT * 
	FROM Receipts 
	WHERE Date = '3-Oct-07') grace  
	ON grace.CustomerId = C.Id
GROUP BY C.FirstName, C.LastName, C.Id
ORDER BY C.LastName ASC

-- 4. Find all different cakes purchased on October 4, 2007. Each cake (flavour, 
-- food) is to be listed once. Sort output in alphabetical order by the cake 
-- flavor.

SELECT Flavor, Food, 
	COUNT(*) AS Num_Cakes_Sold -- Cos I'm curious about number of cakes sold
FROM goods G 
	JOIN items i 
		ON g.ID = i.ID 
	JOIN receipts r 
		ON r.Receipt = r.ReceiptNumber 
WHERE r.Date = '4-Oct-07' 
GROUP BY Flavor, Food
ORDER BY Flavor ASC;

-- 5. List all pastries purchased by ARIANE CRUZEN on 25 October, 2007. For 
-- each pastry, specify its flavour and type, as well as the price. Output the 
-- pastries in the order in which they apepar on the receipt (aka the number of
-- times it was purchased).

SELECT g.Flavor, g.Food, g.Price, r.Date,
	c.FirstName, c.LastName, r.ReceiptNumber, i.Receipt -- For checking
FROM customers C
	JOIN receipts r
		ON c.Id=r.CustomerId
	JOIN items i
		ON r.ReceiptNumber = i.Receipt
	JOIN goods g 
		ON i.Item = g.Id
WHERE r.Date = '25-Oct-07'
	AND c.FirstName = 'ARIANE'
	AND c.LastName = 'CRUZEN'
ORDER BY r.ReceiptNumber, i.ReceiptNumber ASC 

-- 6. Find all types of cookies purchased by KIP ARNN during the month of 
-- October of 2007. Report each cookie type (flavor, food type) exactly once in 
-- alphabetical order by flavor.

SELECT g.Flavor, g.Food, 
	r.Date, c.FirstName, c.LastName -- For checking
FROM customers C
	JOIN receipts r
		ON c.Id=r.CustomerId
	JOIN items i
		ON r.ReceiptNumber = i.Receipt
	JOIN goods g 
		ON i.Item = g.Id
WHERE r.Date LIKE '%Oct%'
	AND c.FirstName = 'KIP'
	AND c.LastName = 'ARNN'
	AND g.Food = 'Cookie'
ORDER BY g.Flavor ASC;

-- 7. Find all the dates in the first 7 days of October 2007 
-- (ie. October 1, 2, 3... 7) on which one customer made more than one purchase 
-- within the same day. Report each date exactly once, output dates sorted in 
-- ascending order with the total number of customers who made the repeat 
-- purchase on that day. 

SELECT Date, Count(Date)
FROM (
	SELECT Date, Count(CustomerId)
	FROM receipts 
	WHERE Date IN ('1-Oct-07', '2-Oct-07', '3-Oct-07', '4-Oct-07',
					'5-Oct-07', '6-Oct-07', '7-Oct-07')
	GROUP BY CustomerId, Date
	HAVING COUNT(CustomerId)>1
	ORDER BY Date)
GROUP BY Date

-- 8. Find all customers who purchased two different croissants on the same trip 
-- to the Bakery. Report their first and last names in alphabetical order by 
-- their last name.

SELECT PAINFUL_BUNS.FirstName AS First_Name, 
       PAINFUL_BUNS.LastName AS Last_Name,
       PAINFUL_BUNS.ReceiptNumber AS Receipt_num,
       COUNT(PAINFUL_BUNS.ReceiptNumber) AS Num_bun_types -- To check
FROM 
    (SELECT c.FirstName, c.LastName, -- Returns names, bun types, number of bun per type
          g.Flavor, g.Food,  
          r.ReceiptNumber, -- Same date purchase
      FROM [sparkline-squared:BAKERY_dataset.customers] c
        JOIN [sparkline-squared:BAKERY_dataset.receipts] r
          ON c.Id = r.CustomerID
        JOIN [sparkline-squared:BAKERY_dataset.items] i
          ON r.ReceiptNumber = i.Receipt
        JOIN [sparkline-squared:BAKERY_dataset.goods] g
          ON i.Item = g.Id 
      WHERE g.Food = 'Croissant'
      GROUP BY c.FirstName, c.LastName, g.Flavor, g.Food, r.ReceiptNumber
      ORDER BY c.LastName ASC) PAINFUL_BUNS
GROUP BY First_Name, Last_Name, Receipt_num
HAVING Num_bun_types > 1
ORDER BY Last_Name ASC 

-- 9. Find all custoemrs who did not make a purchase between Oct 14 and Oct 19.
-- Report their first and last names sorted alphabetically by last name.

SELECT g.Food, SUM(ROUND((g.Price*i.SQn), 2)) AS Rev
FROM (
	SELECT Item, SUM(Quantity) AS SQn
	FROM items 
	GROUP BY Item) AS i
JOIN goods g 
	ON g.Id = i.Item
WHERE g.Food = 'Eclair'
GROUP BY g.Food 

-- 10. Find the total amount of money the bakery earned from selling eclairs. 
-- Report just the final amount.

SELECT FirstName, LastName
FROM customers
WHERE Id NOT IN (
	SELECT r.CustomerId
	FROM receipts r 
	WHERE r.Date IN ('14-Oct-07', '15-Oct-07',
		'16-Oct-07', '17-Oct-07',
		'18-Oct-07', '19-Oct-07'))






