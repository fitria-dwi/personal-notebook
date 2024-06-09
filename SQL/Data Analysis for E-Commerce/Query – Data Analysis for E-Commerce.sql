/* Data Analysis for E-Commerce Challenge
Author: Fitria Dwi Wulandari (wulan391@sci.ui.ac.id) - October, 2021.
This notebook was made using PostgreSQL */

-- Monthly Transactions in 2020
-- 2019
SELECT
	EXTRACT(MONTH FROM created_at) as month,
	count(1) AS number_of_transaction
FROM
	orders
WHERE 
	created_at >= '2019-01-01'
GROUP BY
	 1
ORDER BY
	 1;
 
-- 2020
SELECT
	EXTRACT(MONTH FROM created_at) as month,
	count(1) AS number_of_transaction
FROM
	orders
WHERE 
	created_at >= '2020-01-01'
GROUP BY
	1
ORDER BY
	1;

-- Transactions Status
-- The number of unpaid transactions
SELECT 
	count(1) AS unpaid_transaction
FROM 
	orders 
WHERE 
	paid_at = 'NA';
	
-- The number of transactions that have been paid but not sent
SELECT 
	count(1) AS paid_not_sent_transaction 
FROM 
	orders 
WHERE 
	paid_at != 'NA' AND delivery_at = 'NA';
	
-- The number of transactions that were not sent, whether paid or not
SELECT 
	count(1) AS transaction_not_sent
FROM 
	orders 
WHERE 
	delivery_at = 'NA' 
	AND (paid_at != 'NA' OR paid_at = 'NA');
	
-- The number of transactions sent on the same day as the payment date
SELECT 
	count(1) AS same_day_transaction
FROM 
	orders 
WHERE 
	paid_at = delivery_at;

-- Transaction Users
-- Total all users
SELECT 
	count(DISTINCT user_id) AS total_all_users 
FROM 
	users;
	
-- The number of users who have transacted as buyers
SELECT 
	count(DISTINCT buyer_id) AS number_of_buyers 
FROM 
	orders;
	
-- The number of users who have transacted as a seller
SELECT 
	count(DISTINCT seller_id) AS number_of_seller
FROM 
	orders;
	
-- The number of users who have transacted as buyers and sellers
SELECT 
	count(DISTINCT seller_id) AS buyer_and_seller 
FROM 
	orders 
WHERE 
	seller_id IN (
		SELECT 
			buyer_id 
		FROM 
			orders
	);
	
-- The number of users who have never transacted as buyers or sellers
SELECT 
	count(DISTINCT user_id) AS user_never_made_transaction 
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
	);
 
SELECT 
	count(DISTINCT user_id) AS user_never_made_transaction 
FROM 
	users
WHERE
	user_id NOT IN (
  		SELECT 
			buyer_id 
		FROM 
			orders
 	)
 AND
 	user_id NOT IN (
  	SELECT 
		seller_id 
	FROM 
		orders
	);
 
-- Top Buyer All Time
SELECT
	buyer_id,
	nama_user AS user_name,
	SUM(total) AS total_transaction
FROM
	orders o
JOIN users u ON o.buyer_id = u.user_id
GROUP BY
	 1,2
ORDER BY
 	3 DESC
LIMIT
 	5;

-- Frequent Buyer
SELECT
	buyer_id,
	nama_user AS user_name,
 	count(order_id) AS number_of_transaction
FROM
 	orders o
JOIN users u ON o.buyer_id = u.user_id
WHERE 
 	discount = 0
GROUP BY
 	1,2
ORDER BY
 	3 DESC, 2
LIMIT
 	5;

-- Big Frequent Buyer 2020
SELECT
	buyer_id,
	email,
	rata_rata,
	month_count
FROM (
	SELECT
  		trx.buyer_id,
  		rata_rata,
  		jumlah_order,
  		month_count
	FROM (
		SELECT
			buyer_id,
			ROUND(AVG(total),2) AS rata_rata
		FROM
    		orders
		WHERE
			DATE_FORMAT(created_at, '%Y') = '2020'
		HAVING 
			rata_rata > 1000000
		GROUP BY
			1
		ORDER BY
			1
	) AS trx
	JOIN (
		SELECT
			buyer_id,
			count(order_id) AS jumlah_order,
			count(DISTINCT to_char(created_at, '%m')) AS month_count
		FROM
			orders
		WHERE     
			DATE_FORMAT(created_at, '%Y') = '2020'
		GROUP BY
			1
		HAVING
			month_count >= 5
		AND
			jumlah_order >= month_count
		ORDER BY
			1
	) AS months
	ON trx.buyer_id = months.buyer_id
) AS bfq
JOIN users ON buyer_id = user_id;
 
-- Email Domain from Seller
SELECT
	DISTINCT substr(email, instr(email, '@') + 1) AS email_domain,
	count(user_id) AS number_of_seller
FROM
	users
WHERE
	user_id IN (
		SELECT 
			seller_id 
		FROM 
			orders
	)
GROUP BY
	1
ORDER BY
	2 DESC;

-- Top 5 Product in December 2019
SELECT
	sum(quantity) AS total_quantity,
	desc_product
FROM
 	order_details od
JOIN products p ON od.product_id = p.product_id
JOIN orders o ON od.order_id = o.order_id
WHERE
	created_at BETWEEN '2019-12-01' AND '2019-12-31'
GROUP BY
	2
ORDER BY
 	1 DESC
LIMIT
 	5;

---------------------------------------------------------------

-- 10 Biggest Transactions User 12476
SELECT
    seller_id,
    buyer_id,
    total AS transaction_value,
    created_at AS transaction_date
FROM
    orders
WHERE
    buyer_id = 12476
ORDER BY
    3 DESC
LIMIT
    10;

-- User with Biggest Transaction Average in January 2020
SELECT
    buyer_id,
    COUNT(1) AS number_of_transaction,
    AVG(total) AS avg_transaction_value
FROM
    orders
WHERE
    created_at >= '2020-01-01'
    AND created_at < '2020-02-01'
GROUP BY
    1
HAVING
    count(1) >= 2
ORDER BY
    3 DESC
LIMIT
    10;
 
-- The Biggest Transactions in December 2019 (min 20000000)
SELECT
    nama_user AS buyer_name,
    total AS transaction_value,
    created_at AS transaction_date
FROM
    orders
    INNER JOIN users ON buyer_id = user_id
WHERE
    created_at >= '2019-12-01'
    AND created_at < '2020-01-01'
    AND total >= 20000000
ORDER BY
    1;

-- Best Selling Product Category in 2020
SELECT
    category,
    SUM(quantity) AS total_quantity,
    SUM(price) AS total_price
FROM
    orders
    INNER JOIN order_details USING(order_id)
    INNER JOIN products USING(product_id)
WHERE
    created_at >= '2020-01-01'
    AND delivery_at IS NOT NULL
GROUP BY
    1
ORDER BY
    2 DESC
LIMIT
    5;

-- High Value Buyer (Buyers Having Transacted more than 5 Times and Minimum Transaction is 2000000)
SELECT
    nama_user AS buyer_name,
    COUNT(1) AS number_of_transaction,
    SUM(total) AS total_transaction_value,
    MIN(total) AS min_transaction_value
FROM
    orders
    INNER JOIN users ON buyer_id = user_id
GROUP BY
    user_id,
    nama_user
HAVING
    COUNT(1) > 5
    AND MIN(total) > 2000000
ORDER BY
    3 DESC;

-- Discovering Dropshipper
SELECT
    nama_user AS buyer_name,
    COUNT(1) AS number_of_transaction,
    COUNT(DISTINCT orders.kodepos) AS distinct_postalcode,
    SUM(total) AS total_transaction_value,
    AVG(total) AS avg_transaction_value
FROM
    orders
    INNER JOIN users ON buyer_id = user_id
GROUP BY
    user_id,
    nama_user
HAVING
    COUNT(1) >= 10
    AND COUNT(1) = COUNT(DISTINCT orders.kodepos)
ORDER BY
    2 DESC;

-- Discovering Offline Reseller
SELECT
    nama_user AS buyer_name,
    COUNT(1) AS number_of_transaction,
    SUM(total) AS total_transaction_value,
    AVG(total) AS avg_transaction_value,
    AVG(total_quantity) AS avg_quantity_per_transaction
FROM
    orders
    INNER join users ON buyer_id = user_id
    INNER JOIN (
        SELECT
            order_id,
            SUM(quantity) AS total_quantity
        FROM
            order_details
        GROUP BY
            1
    ) AS summary_order USING(order_id)
WHERE
    orders.kodepos = users.kodepos
GROUP BY
    user_id,
    nama_user
HAVING
    COUNT(1) >= 8
    AND AVG(total_quantity) > 10
ORDER BY
    3 DESC;

-- Discovering Buyers who are Seller (more than 7x)
SELECT
    nama_user AS user_name,
    jumlah_transaksi_beli AS number_of_purchase_transactions,
    jumlah_transaksi_jual AS number_of_sales_transactions
FROM
    users
    INNER JOIN (
        SELECT
            buyer_id,
            COUNT(1) AS jumlah_transaksi_beli
        FROM
            orders
        GROUP BY
            1
    ) AS buyer ON buyer_id = user_id
    INNER JOIN (
        SELECT
            seller_id,
            COUNT(1) AS jumlah_transaksi_jual
        FROM
            orders
        GROUP BY
            1
    ) AS seller ON seller_id = user_id
WHERE
    jumlah_transaksi_beli >= 7
ORDER BY
    1;

-- Time of Paid Transaction
SELECT
    EXTRACT(
        YEAR_MONTH
        FROM
            created_at
    ) AS year_month,
    COUNT(1) AS number_of_transactions,
    AVG(DATEDIFF(paid_at, created_at)) AS avg_length_of_payment,
    MIN(DATEDIFF(paid_at, created_at)) min_length_of_payment,
    MAX(DATEDIFF(paid_at, created_at)) max_length_of_payment
FROM
    orders
WHERE
    paid_at IS NOT NULL
GROUP BY
    1
ORDER BY
    1;