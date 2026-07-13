--CREATE VIEW product_mart AS 
WITH base AS (
    SELECT 
        oi.product_id,
        oi.order_id,
        o.customer_id,
        oi.price,
        oi.seller_id,
        oi.freight_value
    FROM order_items oi
    JOIN orders o 
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
)
SELECT 
    b.product_id,
    COUNT(DISTINCT b.order_id) AS total_orders,
    SUM(b.price) AS product_revenue,
    SUM(b.price + b.freight_value) AS product_total_value,
    COUNT(DISTINCT b.customer_id) AS unique_customers_count,
    COUNT(DISTINCT b.seller_id) AS unique_sellers_count
FROM base b
GROUP BY b.product_id;