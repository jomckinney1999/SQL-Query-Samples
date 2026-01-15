-- 1) Order status distribution by client tier
SELECT
  c.client_tier,
  o.order_status,
  COUNT(*) AS orders
FROM orders o
JOIN clients c ON c.client_id = o.client_id
GROUP BY c.client_tier, o.order_status
ORDER BY c.client_tier, orders DESC;


-- 2) Workflow fallout points: fail rate by step
SELECT
  ws.step_group,
  ws.step_name,
  COUNT(*) AS total_events,
  SUM(CASE WHEN oe.event_status = 'FAIL' THEN 1 ELSE 0 END) AS failed_events,
  ROUND(
    1.0 * SUM(CASE WHEN oe.event_status = 'FAIL' THEN 1 ELSE 0 END) / COUNT(*),
    4
  ) AS fail_rate
FROM order_events oe
JOIN workflow_steps ws ON ws.step_id = oe.step_id
GROUP BY ws.step_group, ws.step_name
HAVING COUNT(*) >= 25
ORDER BY fail_rate DESC, total_events DESC;


-- 3) Simple funnel view using UNION ALL (readable)
WITH step_counts AS (
  SELECT
    ws.step_group,
    COUNT(DISTINCT oe.order_id) AS orders_reaching_step
  FROM order_events oe
  JOIN workflow_steps ws ON ws.step_id = oe.step_id
  GROUP BY ws.step_group
)
SELECT 'VALIDATION' AS step_group, orders_reaching_step
FROM step_counts WHERE step_group = 'VALIDATION'
UNION ALL
SELECT 'FULFILLMENT', orders_reaching_step
FROM step_counts WHERE step_group = 'FULFILLMENT'
UNION ALL
SELECT 'SHIPPING', orders_reaching_step
FROM step_counts WHERE step_group = 'SHIPPING'
ORDER BY orders_reaching_step DESC;
