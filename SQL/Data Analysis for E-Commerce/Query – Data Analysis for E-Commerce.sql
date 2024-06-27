/* Data Analysis for E-Commerce Challenge
by Fitria Dwi Wulandari (wulan391@sci.ui.ac.id) - October, 2021.
This notebook was made using PostgreSQL */


-- Q1: TRANSACTION STATUS

-- #1 Total Unpaid Transaction
SELECT 
    COUNT(1) AS unpaid
FROM 
    orders 
WHERE 
    paid_at = 'NA'
;

-- #2 Total Paid Transaction But Not Shipped Yet
SELECT 
    COUNT(1) AS paid_not_sent
FROM 
    orders 
WHERE 
    paid_at != 'NA' AND delivery_at = 'NA'
;

-- #3 Pending Orders Awaiting Shipment
SELECT 
    COUNT(1) AS not_sent_yet
FROM 
    orders 
WHERE 
    delivery_at = 'NA' AND 
    (paid_at != 'NA' OR paid_at = 'NA')
;

-- #4 Same-Day Orders
SELECT 
    COUNT(1) AS same_day_order
FROM 
    orders 
WHERE 
    paid_at = delivery_at
;


-- Q2: USER ACTIVITIES

-- #1 Total Users
SELECT 
    COUNT(DISTINCT user_id) AS all_user 
FROM 
    users
;

-- #2 Total Users Who Have Transacted As Buyers
SELECT 
    COUNT(DISTINCT buyer_id) AS as_buyer 
FROM 
    orders
;

-- #3 Total Users Who Have Transacted As Sellers
SELECT 
    COUNT(DISTINCT seller_id) AS as_seller
FROM 
    orders
;

-- #4 Total Users Who Have Transacted As Buyers and Sellers
SELECT 
    COUNT(DISTINCT seller_id) AS buyer_seller 
FROM 
    orders 
WHERE 
    seller_id IN (
        SELECT 
            buyer_id 
        FROM 
            orders
        )
;

-- #5 Total Users Who Have Never Transacted As Buyers or Sellers
SELECT 
    COUNT(DISTINCT user_id) AS not_buyer_seller
FROM 
    users
WHERE
    user_id NOT IN (
        SELECT 
            buyer_id 
        FROM 
            orders 
        UNION 
        SELECT 
            seller_id 
         FROM 
             orders
         )
;


-- Q3: SELLER DOMAIN EMAIL
SELECT
    DISTINCT SUBSTR(email, instr(email, '@') + 1) AS email_domain,
    COUNT(user_id) AS cnt_seller
FROM
    users
WHERE
    user_id IN (
        SELECT 
            seller_id 
        FROM 
            orders )
GROUP BY 1
ORDER BY 2 DESC
;


-- Q4: MONTHLY TRANSACTIONS BY YEAR
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(1) AS cnt_transaction
FROM
    orders
GROUP BY 1
ORDER BY 1
;


-- Q5: PAYMENT PROCESSING TIME
SELECT
    EXTRACT(YEAR_MONTH FROM created_at) AS year_month,
    COUNT(1) AS num_order,
    AVG(DATEDIFF(paid_at, created_at)) AS avg_payment_length,
    MIN(DATEDIFF(paid_at, created_at)) AS min_payment_length,
    MAX(DATEDIFF(paid_at, created_at)) AS max_payment_length
FROM
    orders
WHERE
    paid_at IS NOT NULL
GROUP BY 1
ORDER BY 1
;


-- Q6: MAJOR TRANSACTIONS IN DECEMBER 2019
SELECT
    nama_user AS buyer_name,
    total AS transaction_value,
    created_at AS transaction_date
FROM
    orders
INNER JOIN 
    users 
ON buyer_id = user_id
WHERE
    created_at >= '2019-12-01' AND 
    created_at < '2020-01-01' AND 
    total >= 20000000
ORDER BY 2 DESC
LIMIT  5
;


-- Q7: TOP 5 PRODUCTS IN DECEMBER 2019
SELECT
    SUM(quantity) AS total_qty,
    desc_product AS product_name
FROM
    order_details od
JOIN
    products p 
ON od.product_id = p.product_id
JOIN 
    orders o 
ON od.order_id = o.order_id
WHERE
    created_at BETWEEN '2019-12-01' AND '2019-12-31'
GROUP BY 2
ORDER BY 1 DESC
LIMIT 5
;


-- Q8: USERS WITH THE HIGHEST AVERAGE TRANSACTION VALUE IN JANUARY 2020
SELECT
    buyer_id,
    nama_user AS user_name,
    COUNT(1) AS cnt_transaction,
    AVG(total) AS avg_amount_spent
FROM
    orders AS o
LEFT JOIN
    users AS u
ON o.buyer_id = u.user_id
WHERE
    created_at >= '2020-01-01' AND 
    created_at < '2020-02-01'
GROUP BY 1, 2
HAVING
    COUNT(1) >= 2
ORDER BY 4 DESC
LIMIT 5
;


-- Q9: TOP-SELLING PRODUCT CATEGORIES IN 2020
SELECT
    category,
    SUM(quantity) AS qty_sold,
    SUM(price) AS total_sales
FROM
    orders
INNER JOIN 
    order_details USING(order_id)
INNER JOIN
    products USING(product_id)
WHERE
    created_at >= '2020-01-01' AND 
    delivery_at IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
;


-- Q10: TOP BUYERS
SELECT
    buyer_id,
    nama_user AS user_name,
    SUM(total) AS amount_spent
FROM
    orders o
JOIN 
    users u 
ON o.buyer_id = u.user_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5
;


-- Q11: FREQUENT BUYERS
SELECT
    buyer_id,
    nama_user AS user_name,
    COUNT(order_id) AS cnt_transaction
FROM
   orders o
JOIN 
    users u
ON o.buyer_id = u.user_id
WHERE 
    discount = 0
GROUP BY 1, 2
ORDER BY 3 DESC, 2
LIMIT 5
;


-- Q12: HIGH-VALUE BUYERS
SELECT
    nama_user AS buyer_name,
    COUNT(1) AS cnt_transaction,
    SUM(total) AS amount_spent,
    MIN(total) AS min_spent
FROM
    orders
INNER JOIN 
    users 
ON buyer_id = user_id
GROUP BY 1
HAVING 
    COUNT(1) > 5 AND 
    MIN(total) > 2000000
ORDER BY 3 DESC
;


-- Q13: DROPSHIPPERS
SELECT
    nama_user AS buyer_name,
    COUNT(1) AS cnt_transaction,
    COUNT(DISTINCT orders.kodepos) AS cnt_postalcode,
    SUM(total) AS total_order_value,
    AVG(total) AS avg_order_value
FROM
    orders
INNER JOIN 
    users 
ON buyer_id = user_id
GROUP BY user_id, nama_user
HAVING
    COUNT(1) >= 10 AND 
    COUNT(1) = COUNT(DISTINCT orders.kodepos)
ORDER BY 2 DESC
;


-- Q14: OFFLINE RESELLERS
SELECT
    nama_user AS buyer_name,
    COUNT(1) AS cnt_order,
    SUM(total) AS total_order_value,
    AVG(total) AS avg_order_value,
    AVG(total_qty) AS avg_qty_per_order
FROM
    orders
INNER JOIN 
    users 
ON buyer_id = user_id
INNER JOIN (
    SELECT 
        order_id,
        SUM(quantity) AS total_qty
    FROM
        order_details
    GROUP BY 1
) AS summary USING(order_id)
WHERE
    orders.kodepos = users.kodepos
GROUP BY user_id, nama_user
HAVING
    COUNT(1) >= 8 AND AVG(total_qty) > 10
ORDER BY 3 desc
;


-- Q15: BUYER-SELLER DYNAMIC
SELECT
    nama_user AS user_name,
    cnt_buy,
    cnt_sell
FROM
    users
INNER JOIN (
       SELECT
            buyer_id,
            COUNT(1) AS cnt_buy
        FROM
            orders
        GROUP BY 1
    ) AS as_buyer 
ON buyer_id = user_id
INNER JOIN (
        SELECT
            seller_id,
            COUNT(1) AS cnt_sell
        FROM
            orders
        GROUP BY 1
    ) AS as_seller 
ON seller_id = user_id
WHERE cnt_buy >= 7
ORDER BY 1
;