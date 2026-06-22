/*==================================================
    ПРОВЕРКА КАЧЕСТВА ДАННЫХ
==================================================*/

-- Кол-во строк в каждой таблице --
SELECT 'sellers' AS table_name, COUNT(*) AS total_rows
FROM sellers 

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'product_category', COUNT(*)
FROM product_category 

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders 

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM order_reviews 

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM order_payments

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM geolocation

UNION ALL

SELECT 'customers', COUNT(*)
FROM customers;


-- Дубли по первичным ключам --
SELECT 'sellers' AS table_name, COUNT(*) - COUNT(DISTINCT seller_id) AS duplicates_pk
FROM sellers 

UNION ALL

SELECT 'products', COUNT(*) - COUNT(DISTINCT product_id)
FROM products

UNION ALL

SELECT 'product_category', COUNT(*) - COUNT(DISTINCT product_category_name)
FROM product_category 

UNION ALL

SELECT 'orders', COUNT(*) - COUNT(DISTINCT order_id)
FROM orders 

UNION ALL

SELECT 'order_reviews', COUNT(*) - COUNT(DISTINCT order_id || '_' || review_id)
FROM order_reviews 

UNION ALL

SELECT 'order_payments', COUNT(*) - COUNT(DISTINCT order_id || '_' || payment_sequential)
FROM order_payments

UNION ALL

SELECT 'order_items', COUNT(*) - COUNT(DISTINCT order_id || '_' || order_item_id)
FROM order_items

UNION ALL

SELECT 'customers', COUNT(*) - COUNT(DISTINCT customer_id)
FROM customers;


-- Кол-во пропущенных значений --
SELECT 'sellers' AS table_name, COUNT(*) AS rows_with_missing_values
FROM sellers 
WHERE seller_id IS NULL 
	OR seller_zip_code_prefix IS NULL 
	OR seller_city IS NULL 
	OR seller_state IS NULL

UNION ALL

SELECT 'products', COUNT(*)
FROM products
WHERE product_id IS NULL 
	OR product_category_name IS NULL 
	OR product_name_lenght  IS NULL 
	OR product_description_lenght IS NULL 
	OR product_photos_qty IS NULL 
	OR product_weight_g IS NULL 
	OR product_length_cm IS NULL 
	OR product_height_cm IS NULL 
	OR product_width_cm IS NULL 

UNION ALL

SELECT 'product_category', COUNT(*)
FROM product_category 
WHERE product_category_name IS NULL OR product_category_name_english IS NULL

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders 
WHERE order_id IS NULL
	OR customer_id IS NULL
	OR order_status IS NULL
	OR order_purchase_timestamp IS NULL

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM order_reviews 
WHERE order_id IS NULL 
	OR review_id IS NULL 
	OR review_score IS NULL 
	OR review_creation_date IS NULL 
	OR review_answer_timestamp IS NULL 

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM order_payments
WHERE order_id IS NULL 
	OR payment_sequential IS NULL 
	OR payment_type IS NULL 
	OR payment_installments IS NULL 
	OR payment_value IS NULL 

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items
WHERE order_id IS NULL 
	OR order_item_id IS NULL 
	OR product_id IS NULL 
	OR seller_id IS NULL 
	OR shipping_limit_date IS NULL 
	OR price IS NULL 
	OR freight_value IS NULL 

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM geolocation
WHERE geolocation_zip_code_prefix IS NULL 
	OR geolocation_lat IS NULL 
	OR geolocation_lng IS NULL 
	OR geolocation_city IS NULL 
	OR geolocation_state IS NULL 

UNION ALL

SELECT 'customers', COUNT(*)
FROM customers
WHERE customer_id IS NULL 
	OR customer_unique_id IS NULL 
	OR customer_zip_code_prefix IS NULL 
	OR customer_city IS NULL 
	OR customer_state IS NULL;


-- Проверка допустимых диапазонов --
SELECT 'order_items' AS table_name, 'price, freight_value' AS checked_fields, COUNT(*) AS number_of_invalid_values
FROM order_items 
WHERE price < 0 OR freight_value < 0

UNION ALL
	
SELECT 'order_reviews', 'review_score', COUNT(*)
FROM order_reviews 
WHERE review_score NOT BETWEEN 1 AND 5;


-- Проверка бизнес логики --
SELECT 'Доставка раньше оформления' AS checked_anomaly, COUNT(*) AS incorrect_business_logic
FROM orders 
WHERE order_delivered_customer_date < order_purchase_timestamp

UNION ALL

SELECT 'Подтверждение раньше оформления', COUNT(*)
FROM orders 
WHERE order_approved_at < order_purchase_timestamp

UNION ALL

SELECT 'Передача в доставку позже доставки заказа', COUNT(*)
FROM orders 
WHERE order_delivered_customer_date < order_delivered_carrier_date

UNION ALL

SELECT 'Передача в доставку раньше оформления', COUNT(*)
FROM orders 
WHERE order_delivered_carrier_date < order_purchase_timestamp

UNION ALL

SELECT 'Ответ на отзыв раньше, чем отзыв был оставлен', COUNT(*)
FROM order_reviews 
WHERE review_answer_timestamp < review_creation_date

UNION ALL

SELECT 'Отзыв раньше заказа', COUNT(*)
FROM orders o
JOIN order_reviews t ON o.order_id = t.order_id 
WHERE t.review_creation_date < o.order_purchase_timestamp;

