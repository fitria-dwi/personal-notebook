/* B2B Retail Customer Analytics Report
Author: Fitria Dwi Wulandari (wulan391@sci.ui.ac.id) - November 05, 2021.
This notebook was made using PostgreSQL */

-- Data understanding
SELECT
    *
FROM
    orders_1
LIMIT
    5;

SELECT
    *
FROM
    orders_2
LIMIT
    5;

SELECT
    *
FROM
    customer
LIMIT
    5;
	
	
--- Total sales and revenue on quarter-1 (Jan, Feb, Mar) and quarter-2 (Apr,May,Jun)?
SELECT
    SUM(quantity) AS total_penjualan,
    SUM(quantity * priceeach) AS revenue
FROM
    orders_1
WHERE
    status = 'Shipped';

SELECT
    SUM(quantity) AS total_penjualan,
    SUM(quantity * priceeach) AS revenue
FROM
    orders_2
WHERE
    status = 'Shipped';
	
	
-- Calculate the percentage of overall sales!
SELECT
    quarter,
    SUM(quantity) AS total_penjualan,
    SUM(quantity * priceeach) AS revenue
FROM
    (
        SELECT
            orderNumber,
            status,
            quantity,
            priceeach,
            '1' as quarter
        FROM
            orders_1
        UNION
        SELECT
            orderNumber,
            status,
            quantity,
            priceeach,
            '2' as quarter
        FROM
            orders_2
    ) AS tabel_a
WHERE
    status = 'Shipped'
GROUP BY
    quarter;


-- Is the number of xyz.com customers increasing?
SELECT
    quarter,
    COUNT(DISTINCT customerID) AS total_customers
FROM
    (
        SELECT
            customerID,
            createDate,
            QUARTER(createDate) AS quarter
        FROM
            customer
        WHERE
            createDate BETWEEN '2004-01-01'
            AND '2004-06-30'
    ) AS tabel_b
GROUP BY
    quarter;

-- How many of these customers have made transactions?
SELECT
    quarter,
    COUNT(DISTINCT customerID) AS total_customers
FROM
    (
        SELECT
            customerID,
            createDate,
            QUARTER(createDate) AS quarter
        FROM
            customer
        WHERE
            createDate BETWEEN '2004-01-01'
            AND '2004-06-30'
    ) AS tabel_b
WHERE
    customerID IN (
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
GROUP BY
    quarter;


-- What product categories are most ordered by customers in quarter-2?
SELECT
    *
FROM
    (
        SELECT
            categoryID,
            COUNT(DISTINCT orderNumber) AS total_order,
            SUM(quantity) AS total_penjualan
        FROM
            (
                SELECT
                    productCode,
                    orderNumber,
                    quantity,
                    status,
                    LEFT(productCode, 3) AS categoryID
                FROM
                    orders_2
                WHERE
                    status = 'Shipped'
            ) tabel_c
        GROUP BY
            categoryID
    ) a
ORDER BY
    total_order DESC;


-- Calculate the total unique customers who made transactions in quarter_1!
SELECT
    COUNT(DISTINCT customerID) as total_customers
FROM
    orders_1;


-- How many customers remain active in transactions after their first transaction?
SELECT
    '1' AS quarter,
    (COUNT(DISTINCT customerID) * 100) / 25 AS Q2
FROM
    orders_1
WHERE
    customerID IN(
        SELECT
            DISTINCT customerID
        FROM
            orders_2
    );