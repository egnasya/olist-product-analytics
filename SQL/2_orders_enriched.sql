--CREATE VIEW orders_enriched AS
WITH payments_agg AS (
    SELECT 
        order_id,
        SUM(payment_value) AS payment_received,
        MAX(payment_type) AS payment_type
    FROM order_payments
    GROUP BY order_id
),
reviews_agg AS (
    SELECT 
        order_id,
        AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
),
items_agg AS (
    SELECT 
        order_id,
        SUM(price) AS product_revenue,
        SUM(freight_value) AS total_freight,
        SUM(price + freight_value) AS order_total_value
    FROM order_items
    GROUP BY order_id
),
orders_base AS (
    SELECT 
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        approval_time_hours,
        delivered_time_days,
        is_delay
    FROM orders
),
orders_customers AS (
    SELECT 
        o.*,
        c.customer_city,
        c.customer_state
    FROM orders_base o
    LEFT JOIN customers c 
        ON o.customer_id = c.customer_id
),
final_orders AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.customer_city,
        o.customer_state,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        o.approval_time_hours,
        o.delivered_time_days,
        o.is_delay,
        p.payment_type,
        p.payment_received,
        i.product_revenue,
        i.total_freight,
        i.order_total_value,
        r.review_score
    FROM orders_customers o
    LEFT JOIN payments_agg p 
        ON o.order_id = p.order_id
    LEFT JOIN reviews_agg r 
        ON o.order_id = r.order_id
    LEFT JOIN items_agg i 
        ON o.order_id = i.order_id
)
SELECT *
FROM final_orders;