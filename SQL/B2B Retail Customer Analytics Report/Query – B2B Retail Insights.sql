/* 
 B2B Retail Customer Analytics Report
 by Fitria Dwi Wulandari (wulan391@sci.ui.ac.id) - November 05, 2021
 This notebook was made using PostgreSQL
 */


-- Q1: TOTAL SALES AND REVENUE IN FIRST AND SECOND QUARTER

SELECT
	quarter,
	SUM(quantity) AS total_sales,
	SUM(quantity * priceeach) AS total_revenue
FROM (
	SELECT
		*,
		'1' AS quarter
	FROM
		orders_1
	UNION
	SELECT
		*,
		'2' AS quarter
	FROM
		orders_2
	) AS base
WHERE
	status = 'Shipped'
GROUP BY 1
;



-- Q2: NEW CUSTOMERS GROWTH

SELECT
	quarter,
	COUNT(DISTINCT customerID) AS total_customer
FROM (
	SELECT
		customerID,
		createDate,
		QUARTER(createDate) AS quarter
	FROM
		customer
	WHERE
		createDate BETWEEN '2004-01-01' AND '2004-06-30'
	) AS base
GROUP BY 1
;



-- Q3: TOTAL ACTIVE CUSTOMERS IN FIRST AND SECOND QUARTER

SELECT
	quarter,
	COUNT(DISTINCT customerID) AS total_customer
FROM (
	SELECT
		customerID,
		createDate,
		QUARTER(createDate) AS quarter
	FROM
		customer
	WHERE
		createDate BETWEEN '2004-01-01' AND '2004-06-30'
	) AS base
WHERE
	customerID IN 
	(
	SELECT 
		DISTINCT customerID
	FROM
		orders_1
	UNION
	SELECT 
		DISTINCT customerID
	FROM
		orders_2 
	)
GROUP BY 1
;



-- Q4: MOST POPULAR PRODUCTS

SELECT
	DISTINCT quarter,
	COUNT(customerName) AS total_customer
FROM (
	SELECT
		customerName,
		customerDate,
		QUARTER(createDate) AS quarter
	FROM 
		customer
	WHERE
		createDate BETWEEN '2004-01-01' AND '2004-06-30'
	) AS base
GROUP BY 1
;



-- Q5: TOTAL NUMBER OF REPEAT CUSTOMERS IN SECOND QUARTER

-- calculate the total unique customers who made transactions in first quarter
SELECT
	COUNT(DISTINCT customerID) AS active_cust_q1
FROM
	orders_1
;

-- how many customers remain active in transactions after their first transaction?
SELECT
	'1' AS quarter,
	(COUNT(DISTINCT customerID) * 100) / 25 AS pct_active_cust_q2
FROM
	orders_1
WHERE
	customerID IN
	(
	SELECT
		DISTINCT customerID
	FROM
		orders_2
	)
;
