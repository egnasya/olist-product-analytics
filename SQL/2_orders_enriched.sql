--CREATE VIEW orders_enriched AS
WITH 
-- 1. АГРЕГАЦИЯ ПЛАТЕЖЕЙ (order-level)
payments_agg AS (
    SELECT 
        order_id,
        SUM(payment_value) AS payment_value,
        MAX(payment_type) AS payment_type
    FROM order_payments
    GROUP BY order_id
),
-- 2. АГРЕГАЦИЯ ОТЗЫВОВ (order-level)
reviews_agg AS (
    SELECT 
        order_id,
        AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
),
-- 3. АГРЕГАЦИЯ ТОВАРОВ (order-level)
items_agg AS (
    SELECT 
        order_id,
        SUM(price) AS items_price,
        SUM(freight_value) AS items_freight,
        SUM(price + freight_value) AS item_total_amount
    FROM order_items
    GROUP BY order_id
),
-- 4. БАЗОВЫЙ ORDER LEVEL (основная таблица заказов)
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
-- 5. ДОБАВЛЯЕМ КЛИЕНТОВ
orders_customers AS (
    SELECT 
        o.*,
        c.customer_city,
        c.customer_state
    FROM orders_base o
    LEFT JOIN customers c 
        ON o.customer_id = c.customer_id
),
-- 6. ДОБАВЛЯЕМ ITEM + PAYMENT + REVIEW
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
        p.payment_value,
        i.items_price,
        i.items_freight,
        i.item_total_amount,
        r.review_score
    FROM orders_customers o
    LEFT JOIN payments_agg p 
        ON o.order_id = p.order_id
    LEFT JOIN reviews_agg r 
        ON o.order_id = r.order_id
    LEFT JOIN items_agg i 
        ON o.order_id = i.order_id
)
-- 7. СОЗДАНИЕ ПРЕДСТАВЛЕНИЯ И ФИНАЛЬНЫЙ SELECT
SELECT *
FROM final_orders;