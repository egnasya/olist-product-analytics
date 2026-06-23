SELECT c.customer_id,
	COUNT(DISTINCT order_id) AS total_orders
FROM customers c 
JOIN orders_enriched oe