--CREATE VIEW seller_mart AS
WITH seller_orders AS (
    SELECT
        oi.seller_id,
        oi.order_id,
        o.order_purchase_timestamp,
        SUM(oi.price) AS seller_order_revenue,
        SUM(oi.price + oi.freight_value ) AS seller_order_total_value,
        COUNT(*) AS seller_order_items_cnt
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        oi.seller_id,
        oi.order_id,
        o.order_purchase_timestamp
),
dataset_dates AS (
    SELECT DATE(MAX(order_purchase_timestamp)) AS max_order_dt
    FROM orders
    WHERE order_status = 'delivered'
)
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(so.order_id) AS total_orders,
    COALESCE(SUM(so.seller_order_revenue), 0) AS total_revenue,
    COALESCE(SUM(so.seller_order_revenue), 0) AS total_value,
    ROUND(AVG(so.seller_order_revenue), 2) AS avg_order_value,
    COALESCE(SUM(so.seller_order_items_cnt), 0) AS total_items_sold,
    MIN(so.order_purchase_timestamp) AS first_order_date,
    MAX(so.order_purchase_timestamp) AS last_order_date,
    JULIANDAY(d.max_order_dt) - JULIANDAY(DATE(MAX(so.order_purchase_timestamp))) AS recency_days
FROM sellers s
LEFT JOIN seller_orders so
    ON s.seller_id = so.seller_id
CROSS JOIN dataset_dates d
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state;