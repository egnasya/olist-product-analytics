-- ИССЛЕДОВАНИЕ ПОКАЗАТЕЛЕЙ ЗАКАЗОВ --
-- Выручка, оборот, количество заказов и средний чек
SELECT 
	COUNT(*) as number_of_orders, 
	SUM(oe.product_revenue) as revenue, 
	ROUND(SUM(oe.product_revenue) / COUNT(*), 2) as avg_order_revenue, 
	SUM(oe.order_total_value) as GMV, 
	ROUND(SUM(oe.order_total_value) / COUNT(*), 2) as avg_order_value
FROM orders_enriched oe

-- Среднее время доставки, доля задержанных
SELECT ROUND(AVG(oe.delivered_time_days), 0) as avg_delivery_time_days, ROUND(AVG(CASE WHEN oe.is_delay = 1 THEN 1.0 ELSE 0.0 END) * 100, 2) as share_of_delays
FROM orders_enriched oe

-- Доля доставленных/недоставленных заказов 
SELECT ROUND(AVG(CASE WHEN oe.order_status = 'delivered' THEN 1.0 ELSE 0.0 END) * 100, 2) as share_of_delivered,
	   100 - ROUND(AVG(CASE WHEN oe.order_status = 'delivered' THEN 1.0 ELSE 0.0 END) * 100, 2) as share_of_undelivered
FROM orders_enriched oe

-- Средняя оценка заказов
SELECT ROUND(AVG(oe.review_score), 2) as avg_reviews
FROM orders_enriched oe


-- ИССЛЕДОВАНИЕ ПОКАЗАТЕЛЕЙ ПО ПОКУПАТЕЛЯМ --
-- Количество покупателей, доля покупателей с повторными покупками, среднее число заказов на клиента
SELECT 
	COUNT() as number_of_customers, 
	ROUND(SUM(CASE WHEN cm.total_orders > 1 THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100, 2) as repeat_purchase_rate, 
	ROUND(AVG(cm.total_orders), 2) as avg_orders
FROM customer_mart cm

-- Топ-5 покупателей по количеству заказов
WITH ranked_customers AS (
	SELECT customer_unique_id, total_orders,
		DENSE_RANK() OVER (ORDER BY total_orders DESC) as customer_rank
	FROM customer_mart
)
SELECT rc.customer_unique_id, rc.total_orders 
FROM ranked_customers rc
WHERE rc.customer_rank <= 5;

-- Топ-10 покупателей по сумме совершенных покупок
SELECT cm.customer_unique_id, cm.customer_payment_received 
FROM customer_mart cm 
ORDER BY cm.customer_payment_received DESC LIMIT 10


-- ИССЛЕДОВАНИЕ ПОКАЗАТЕЛЕЙ ПО ТОВАРАМ --
-- Количество товаров
SELECT COUNT(*) as number_of_products
FROM product_mart pm 

-- Топ-10 товаров по заказам
SELECT pm.product_id, pm.total_orders 
FROM product_mart pm 
ORDER BY pm.total_orders DESC LIMIT 10

-- Топ-10 товаров по выручке
SELECT pm.product_id, pm.product_revenue  
FROM product_mart pm 
ORDER BY pm.product_revenue DESC LIMIT 10

-- Топ-10 товаров по количеству уникальных покупателей
SELECT pm.product_id, pm.unique_customers_count 
FROM product_mart pm 
ORDER BY pm.unique_customers_count DESC LIMIT 10


-- ИССЛЕДОВАНИЕ ПОКАЗАТЕЛЕЙ ПО ПРОДАВЦАМ --
-- Количество продавцов
SELECT COUNT(*) as number_of_sellers
FROM seller_mart sm 

-- Топ-10 продавцов по количеству закзов
WITH ranked_sellers AS (
	SELECT sm.seller_id, sm.total_orders,
		DENSE_RANK() OVER (ORDER BY sm.total_orders DESC) as seller_rank
	FROM seller_mart sm 
)
SELECT rs.seller_id, rs.total_orders 
FROM ranked_sellers rs
WHERE rs.seller_rank <= 10

-- Топ-10 продавцов по выручке
SELECT sm.seller_id, sm.sellers_revenue   
FROM seller_mart sm 
ORDER BY sm.sellers_revenue DESC LIMIT 10

-- Топ-10 продавцов по количеству проданных товаров
SELECT sm.seller_id, sm.total_items_sold    
FROM seller_mart sm 
ORDER BY sm.total_items_sold DESC LIMIT 10


-- ИССЛЕДОВАНИЕ ВРЕМЕННЫХ ТРЕНДОВ --
-- Количество заказов, выручка и средний чек по месяцам по каждому году
SELECT 
    strftime('%m.%Y', oe.order_purchase_timestamp) AS order_month, 
    COUNT(*) as number_of_orders, 
	SUM(oe.product_revenue) as revenue, 
	ROUND(SUM(oe.product_revenue) / COUNT(*), 2) as avg_order_revenue, 
	SUM(oe.order_total_value) as GMV, 
	ROUND(SUM(oe.order_total_value) / COUNT(*), 2) as avg_order_value
FROM orders_enriched oe
GROUP BY strftime('%Y', oe.order_purchase_timestamp), strftime('%m', oe.order_purchase_timestamp)
ORDER BY strftime('%Y', oe.order_purchase_timestamp) ASC, strftime('%m', oe.order_purchase_timestamp) ASC

-- Количество заказов по дням недели
SELECT 
	CASE strftime('%w', oe.order_purchase_timestamp)
        WHEN '1' THEN 'Понедельник'
        WHEN '2' THEN 'Вторник'
        WHEN '3' THEN 'Среда'
        WHEN '4' THEN 'Четверг'
        WHEN '5' THEN 'Пятница'
        WHEN '6' THEN 'Суббота'
        WHEN '0' THEN 'Воскресенье'
    END as weekday_name,
    COUNT(*) as number_of_orders, 
	SUM(oe.product_revenue) as revenue, 
	ROUND(SUM(oe.product_revenue) / COUNT(*), 2) as avg_order_revenue, 
	SUM(oe.order_total_value) as GMV, 
	ROUND(SUM(oe.order_total_value) / COUNT(*), 2) as avg_order_value
FROM orders_enriched oe
GROUP BY weekday_name 
ORDER BY strftime('%w', oe.order_purchase_timestamp) 

-- Количество заказов по времени 
SELECT 
	strftime('%H', oe.order_purchase_timestamp) as order_hour,
	CASE 
        WHEN strftime('%H', oe.order_purchase_timestamp) BETWEEN '06' AND '12' THEN 'Утро'
        WHEN strftime('%H', oe.order_purchase_timestamp) BETWEEN '12' AND '18' THEN 'День'
        WHEN strftime('%H', oe.order_purchase_timestamp) BETWEEN '18' AND '23' THEN 'Вечер'
        ELSE 'Ночь' 
    END as time_of_day,
    COUNT(*) as number_of_orders, 
	SUM(oe.product_revenue) as revenue, 
	ROUND(SUM(oe.product_revenue) / COUNT(*), 2) as avg_order_revenue, 
	SUM(oe.order_total_value) as GMV, 
	ROUND(SUM(oe.order_total_value) / COUNT(*), 2) as avg_order_value
FROM orders_enriched oe
GROUP BY order_hour 
