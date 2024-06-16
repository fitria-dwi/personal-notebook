/* 
 Superstore Data Analysis
 by Fitria Dwi Wulandari (wulan391@sci.ui.ac.id) - July, 2022
 This notebook was made using PostgreSQL
 */


-- CS1: TOTAL NUMBER OF DELAYED SAME-DAY ORDERS

SELECT 
    COUNT(order_id) AS total_delayed_delivery
FROM 
    orders
WHERE 
    ship_mode = 'Same Day' AND
    order_date != ship_date
;


-- CS2: AVERAGE PROFIT FOR EACH DISCOUNT LEVEL

SELECT
    CASE 
        WHEN discount < 0.2 THEN 'LOW'
        WHEN discount >= 0.2 AND discount < 0.4 THEN 'MODERATE'
        ELSE 'HIGH'
    END AS grp_discount,
    AVG(profit) AS avg_profit
FROM 
    orders
GROUP BY 1
ORDER BY 1 DESC
;


-- CS3: AVERAGE PROFIT AND DISCOUNTS BY CATEGORY AND SUBCATEGORY PRODUCT PAIR

SELECT 
    p.category,
    p.subcategory,
    AVG(o.discount) AS avg_discount,
    AVG(o.profit) AS avg_profit
FROM 
    orders AS o
LEFT JOIN 
    product AS p
ON o.product_id = p.product_id
GROUP BY 1, 2
ORDER BY 1, 2
;


-- CS4: SEGMENT PERFORMANCE IN CALIFORNIA, TEXAS, AND GEORGIA IN 2016

SELECT
    c.segment,
    SUM(o.sales) AS total_sales,
    AVG(o.profit) AS average_profit
FROM 
    orders AS o
LEFT JOIN 
    customer AS c
ON o.customer_id = c.customer_id
WHERE 
    c.state IN ('California', 'Texas', 'Georgia') AND
    date_part('year', o.order_date) = 2016
GROUP BY 1
;


-- CS5: NUMBER OF DISCOUNT-LOVING CUSTOMER BY REGION

WITH base AS (
    SELECT 
        customer_id,
        AVG(discount) AS avg_discount
    FROM 
       orders
    GROUP BY 1
    HAVING AVG(discount) > 0.4
)
SELECT 
    c.region,
    COUNT(1) AS cust_love_discount
FROM 
    base
LEFT JOIN
    customer AS c
ON o.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC
;


-- Q1: AVERAGE TIME TO SHIP FOR EACH SHIP MODE

SELECT 
    ship_mode,
    AVG(ABS(DATE_PART('day', ship_date) - DATE_PART('day', order_date))) AS time_to_ship
FROM
    orders
GROUP BY 1
;


-- Q2: SALES PERFORMANCE THROUGHOUT THE YEARS

SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    COUNT(1) AS total_order,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit
FROM 
    orders
GROUP BY 1
ORDER BY 2, 3 DESC
;


-- Q3: NUMBER OF ITEMS SOLD AND PROFIS FOR EACH REGION

SELECT 
    c.region,
    EXTRACT(YEAR FROM o.order_date) AS year,
    SUM(o.quantity) AS total_quantity,
    ROUND(SUM(o.Profit),2) AS total_profit
FROM 
    orders o
LEFT JOIN 
    customer c
ON o.customer_id = c.customer_id
GROUP BY 1, 2
ORDER BY 1, 2, 3, 4
;


-- Q4: THE CITY WITH THE HIGHEST PROFITS

SELECT 
    c.country,
    c.city,
    SUM(o.Profit) AS total_profit
FROM 
    orders o
LEFT JOIN 
    customer c
ON o.customer_id = c.customer_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1
;


-- Q5: MOST PROFITABLE PRODUCT

SELECT 
	p.category,
	p.subcategory,
	SUM(o.profit) AS total_profit
FROM 
	orders o
LEFT JOIN 
	product p
	ON o.product_id = p.product_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5
;