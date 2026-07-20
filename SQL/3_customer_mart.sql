--DROP VIEW customer_mart;
--CREATE VIEW customer_mart AS
WITH delivered_orders AS (
	SELECT *
	FROM orders
	WHERE order_status = 'delivered'
),
payments_stats AS (
	SELECT 
		c.customer_unique_id, 
		op.payment_type,
		COUNT(op.payment_type) AS payment_type_count
	FROM delivered_orders d
	JOIN customers c 
		ON c.customer_id = d.customer_id
	JOIN order_payments op 
		ON op.order_id = d.order_id 
	GROUP BY 
		c.customer_unique_id, 
		op.payment_type
),
payment_rank AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY customer_unique_id
			ORDER BY payment_type_count DESC, payment_type
		) AS rn
	FROM payments_stats
),
top_payment_type AS (
	SELECT *
	FROM payment_rank 
	WHERE rn = 1
),
last_date_in_dataset AS (
	SELECT DATE(MAX(order_purchase_timestamp)) AS snapshot_date
	FROM orders
),
cancelled_orders_agg AS (
	SELECT 
		c.customer_unique_id, 
		COUNT(DISTINCT o.order_id) AS order_canceled_count
	FROM orders o
	JOIN customers c 
		ON c.customer_id = o.customer_id
	WHERE o.order_status = 'canceled'
	GROUP BY c.customer_unique_id
),
popular_product_category AS (
	SELECT 
		c.customer_unique_id, 
		pc.product_category_name_english,
		COUNT(DISTINCT d.order_id) AS product_category_count
	FROM delivered_orders d
	JOIN customers c 
		ON c.customer_id = d.customer_id
	JOIN order_items oi 
		ON oi.order_id = d.order_id
	JOIN products p 
		ON p.product_id = oi.product_id
	JOIN product_category pc 
		ON pc.product_category_name = p.product_category_name
	GROUP BY 
		c.customer_unique_id,
		pc.product_category_name_english
),
popular_product_category_rank AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY customer_unique_id
			ORDER BY product_category_count DESC,
					 product_category_name_english
		) AS rn_category
	FROM popular_product_category
),
top_category AS (
	SELECT *
	FROM popular_product_category_rank
	WHERE rn_category = 1
),
full_customers_features AS (
	SELECT 
		c.customer_unique_id,
		COUNT(DISTINCT o.order_id) AS total_orders,
		COUNT(DISTINCT d.order_id) AS delivered_orders,
		MIN(o.order_purchase_timestamp) AS first_order_date,
		MAX(o.order_purchase_timestamp) AS last_order_date,
		JULIANDAY(DATE(MAX(o.order_purchase_timestamp))) - JULIANDAY(DATE(MIN(o.order_purchase_timestamp))) AS lifetime_days,
		CASE
			WHEN COUNT(DISTINCT d.order_id) > 1
			THEN ROUND((JULIANDAY(MAX(d.order_purchase_timestamp)) - JULIANDAY(MIN(d.order_purchase_timestamp))) / (COUNT(DISTINCT d.order_id)-1), 0)
			ELSE NULL
		END AS avg_days_between_orders,
		JULIANDAY(ld.snapshot_date) - JULIANDAY(DATE(MAX(d.order_purchase_timestamp))) AS recency_days,
		CASE
			WHEN COUNT(DISTINCT d.order_id) > 1
			THEN 1
			ELSE 0
		END AS is_repeat_customer,
		SUM(d.order_cost) AS customer_revenue,
		ROUND(SUM(d.order_cost) / COUNT(DISTINCT d.order_id), 2) AS avg_order_value,
		tpt.payment_type AS most_popular_payment_type,
		ROUND(AVG(d.delivered_time_days), 0) AS avg_delivery_time_days,
		ROUND(AVG(d.delivery_delay_days), 0) AS avg_delivery_delay_days,
		COALESCE(coagg.order_canceled_count, 0) AS canceled_count,
		ROUND(CAST(COALESCE(coagg.order_canceled_count, 0) AS FLOAT) / COUNT(DISTINCT o.order_id), 3) AS share_of_cancelled_orders,
		tc.product_category_name_english AS most_popular_category,
		c.customer_city AS city,
		c.customer_state AS state
	FROM orders o
	JOIN customers c 
		ON c.customer_id = o.customer_id
	LEFT JOIN delivered_orders d
		ON d.customer_id = c.customer_id
	CROSS JOIN last_date_in_dataset ld
	LEFT JOIN top_payment_type tpt
		ON tpt.customer_unique_id = c.customer_unique_id
	LEFT JOIN cancelled_orders_agg coagg
		ON coagg.customer_unique_id = c.customer_unique_id
	LEFT JOIN top_category tc
		ON tc.customer_unique_id = c.customer_unique_id
	GROUP BY c.customer_unique_id
)
SELECT
	customer_unique_id,
	total_orders,
	delivered_orders,
	first_order_date,
	last_order_date,
	lifetime_days,
	avg_days_between_orders,
	recency_days,
	is_repeat_customer,
	customer_revenue,
	avg_order_value,
	most_popular_payment_type,
	avg_delivery_time_days,
	avg_delivery_delay_days,
	canceled_count,
	share_of_cancelled_orders,
	most_popular_category,
	city,
	state
FROM full_customers_features;