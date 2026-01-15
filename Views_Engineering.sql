-- 1) View: daily order KPIs
CREATE VIEW vw_daily_orders AS
SELECT
  order_date,
  COUNT(*) AS orders,
  SUM(total_amount) AS gross_sales,
  AVG(total_amount) AS avg_order_value,
  SUM(CASE WHEN order_status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_orders
FROM orders
GROUP BY order_date;


-- 2) Engineered reporting table (CTAS-style)
-- Postgres / BigQuery: CREATE TABLE rpt_client_monthly AS SELECT ...
-- SQL Server: SELECT ... INTO rpt_client_monthly FROM ...
CREATE TABLE rpt_client_monthly AS
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
