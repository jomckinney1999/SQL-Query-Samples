-- 1) INSERT example
INSERT INTO products (product_id, product_name, category, unit_cost, unit_price, active_flag, created_at)
VALUES (999, 'Sample Product', 'Samples', 10.00, 19.99, 1, CURRENT_TIMESTAMP);

-- 2) UPDATE example (soft change)
UPDATE products
SET active_flag = 0
WHERE product_id = 999;

-- 3) DELETE + INSERT refresh pattern (common in reporting snapshots)
DELETE FROM rpt_client_monthly;

INSERT INTO rpt_client_monthly
SELECT
  c.client_id,
  c.client_name,
  c.client_tier,
  DATE_TRUNC('month', o.order_date) AS month_start,
  COUNT(*) AS orders,
  SUM(o.total_amount) AS gross_sales
FROM orders o
JOIN clients c ON c.client_id = o.client_id
GROUP BY c.client_id, c.client_name, c.client_tier, DATE_TRUNC('month', o.order_date);

-- 4) HARD DELETE example (use carefully)
DELETE FROM products
WHERE product_id = 999;
