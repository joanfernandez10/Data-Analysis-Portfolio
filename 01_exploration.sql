-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
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
