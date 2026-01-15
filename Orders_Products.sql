-- 1) Revenue by product category (aggregation + joins)
SELECT
  p.category,
  COUNT(DISTINCT o.order_id) AS order_count,
  SUM(oi.quantity)          AS units_sold,
  ROUND(SUM(oi.line_amount), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
WHERE o.order_status IN ('SHIPPED', 'PROCESSING')
GROUP BY p.category
ORDER BY revenue DESC;


-- 2) Average order value by channel (AVG + derived columns)
SELECT
  channel,
  COUNT(*) AS orders,
  ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE currency = 'USD'
GROUP BY channel
ORDER BY avg_order_value DESC;


-- 3) Top products per category (ROW_NUMBER / ranking)
WITH product_sales AS (
  SELECT
    p.category,
    p.product_name,
    SUM(oi.quantity) AS units_sold
  FROM order_items oi
  JOIN products p ON p.product_id = oi.product_id
  GROUP BY p.category, p.product_name
)
SELECT category, product_name, units_sold
FROM (
  SELECT
    category,
    product_name,
    units_sold,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY units_sold DESC) AS rn
  FROM product_sales
) ranked
WHERE rn <= 3
ORDER BY category, units_sold DESC;


-- 4) Product cancellation rate vs overall (SUM(CASE WHEN...) + subquery)
WITH overall AS (
  SELECT
    1.0 * SUM(CASE WHEN order_status = 'CANCELLED' THEN 1 ELSE 0 END) / COUNT(*) AS cancel_rate
  FROM orders
),
by_product AS (
  SELECT
    p.product_name,
    COUNT(DISTINCT o.order_id) AS orders,
    1.0 * SUM(CASE WHEN o.order_status = 'CANCELLED' THEN 1 ELSE 0 END) / COUNT(DISTINCT o.order_id) AS cancel_rate
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p     ON p.product_id = oi.product_id
  GROUP BY p.product_name
)
SELECT
  bp.product_name,
  bp.orders,
  ROUND(bp.cancel_rate, 4) AS product_cancel_rate,
  ROUND(o.cancel_rate, 4)  AS overall_cancel_rate
FROM by_product bp
CROSS JOIN overall o
WHERE bp.orders >= 10
  AND bp.cancel_rate >= o.cancel_rate * 1.5
ORDER BY bp.cancel_rate DESC;
