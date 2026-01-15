-- 1) Error rate by service and endpoint
SELECT
  service_name,
  endpoint,
  COUNT(*) AS hits,
  SUM(CASE WHEN error_flag = 1 OR status_code >= 500 THEN 1 ELSE 0 END) AS errors,
  ROUND(
    1.0 * SUM(CASE WHEN error_flag = 1 OR status_code >= 500 THEN 1 ELSE 0 END) / COUNT(*),
    4
  ) AS error_rate
FROM app_metrics
GROUP BY service_name, endpoint
HAVING COUNT(*) >= 100
ORDER BY error_rate DESC, hits DESC;


-- 2) Rolling 7-day average latency (OVER / PARTITION BY)
WITH daily AS (
  SELECT
    service_name,
    CAST(metric_ts AS DATE) AS day,
    AVG(latency_ms) AS avg_latency_ms
  FROM app_metrics
  WHERE status_code = 200
  GROUP BY service_name, CAST(metric_ts AS DATE)
)
SELECT
  service_name,
  day,
  avg_latency_ms,
  AVG(avg_latency_ms) OVER (
    PARTITION BY service_name
    ORDER BY day
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS rolling_7d_avg_latency_ms
FROM daily
ORDER BY service_name, day;
