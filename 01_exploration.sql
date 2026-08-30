-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- ============================================================

-- ============================================================
-- 01 - DATA EXPLORATION
-- ============================================================

-- ------------------------------------------------------------
-- 1. TABLES
-- ------------------------------------------------------------

SELECT name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;

-- ------------------------------------------------------------
-- 2. NUMBER OF RECORDS
-- ------------------------------------------------------------

SELECT 'customers' AS table_name, COUNT(*) AS rows FROM customers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'items', COUNT(*) FROM items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'product_category_name_translation',
       COUNT(*)
FROM product_category_name_translation;

-- ------------------------------------------------------------
-- 3. SAMPLE OF EACH TABLE
-- ------------------------------------------------------------

SELECT * FROM customers LIMIT 5;

SELECT * FROM geolocation LIMIT 5;

SELECT * FROM items LIMIT 5;

SELECT * FROM orders LIMIT 5;

SELECT * FROM payments LIMIT 5;

SELECT * FROM reviews LIMIT 5;

SELECT * FROM products LIMIT 5;

SELECT * FROM sellers LIMIT 5;

SELECT * FROM product_category_name_translation LIMIT 5;

-- ============================================================
-- 2 - DATA QUALITY CHECK
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 MISSING VALUES
-- ------------------------------------------------------------

-- Orders

SELECT
    COUNT(*) AS total_orders,
    COUNT(order_approved_at) AS approved_not_null,
    COUNT(order_delivered_carrier_date) AS carrier_not_null,
    COUNT(order_delivered_customer_date) AS delivered_not_null,
    COUNT(order_estimated_delivery_date) AS estimated_not_null
FROM orders;


-- Products

SELECT
    COUNT(*) AS total_products,
    COUNT(product_category_name) AS category_not_null,
    COUNT(product_weight_g) AS weight_not_null,
    COUNT(product_length_cm) AS length_not_null,
    COUNT(product_height_cm) AS height_not_null,
    COUNT(product_width_cm) AS width_not_null
FROM products;


-- ------------------------------------------------------------
-- 2.2 DUPLICATES
-- ------------------------------------------------------------

-- Orders

SELECT
    order_id,
    COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Customers

SELECT
    customer_id,
    COUNT(*) AS occurrences
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Products

SELECT
    product_id,
    COUNT(*) AS occurrences
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- 3. CATEGORICAL VALUES
-- ------------------------------------------------------------

-- Order status

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Payment type

SELECT
    payment_type,
    COUNT(*) AS total_payments
FROM payments
GROUP BY payment_type
ORDER BY total_payments DESC;


-- Review score

SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM reviews
GROUP BY review_score
ORDER BY review_score;


-- ------------------------------------------------------------
-- 4. NUMERICAL VALUES
-- ------------------------------------------------------------

-- Product price

SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price
FROM items;


-- Negative or zero prices

SELECT *
FROM items
WHERE price <= 0;

-- ------------------------------------------------------------
-- 5. DATE CONSISTENCY
-- ------------------------------------------------------------

-- Delivery before purchase

SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date < order_purchase_timestamp;


-- Delivery before carrier shipment

SELECT
    order_id,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date < order_delivered_carrier_date;

-- ------------------------------------------------------------
-- 6. REFERENTIAL INTEGRITY
-- ------------------------------------------------------------

-- Orders without a matching customer

SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Items without a matching product

SELECT
    i.order_id,
    i.product_id
FROM items i
LEFT JOIN products p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Items without a matching seller

SELECT
    i.order_id,
    i.seller_id
FROM items i
LEFT JOIN sellers s
    ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- ------------------------------------------------------------
-- 7. análisis detallado de los errores o incosistencias hallados
-- en los apartados 2.1 a 2.6
-- ------------------------------------------------------------

SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date < order_delivered_carrier_date
ORDER BY order_delivered_customer_date;

SELECT
    order_status,
    COUNT(*) AS total_orders,
    COUNT(order_delivered_customer_date) AS delivered_date,
    COUNT(order_estimated_delivery_date) AS estimated_date
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

---

-- 8. DATA QUALITY FINDINGS

---

-- 1. Inconsistent delivery timestamps
-- 23 orders (0.023% of all orders) have a customer delivery
-- date earlier than the carrier delivery date.
-- These records will be retained in the raw dataset and
-- excluded from delivery-time calculations where appropriate.

-- 2. Missing delivery dates
-- 8 orders are marked as "delivered" but have no customer
-- delivery date.
-- These records will be retained but excluded from metrics
-- requiring a valid customer delivery timestamp.

-- 3. Expected missing values
-- Missing delivery dates for non-delivered orders are
-- consistent with their order status and are therefore
-- not considered data quality errors.
