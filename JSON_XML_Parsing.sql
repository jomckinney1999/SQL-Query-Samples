-- JSON + XML functions vary across engines.
-- Below are common patterns you can keep in GitHub as “real-world knowledge.”

-- =========================
-- JSON parsing (Postgres)
-- =========================
-- SELECT
--   order_id,
--   payload_json::jsonb ->> 'failure_code' AS failure_code,
--   (payload_json::jsonb -> 'metrics' ->> 'retries')::int AS retries
-- FROM order_events
-- WHERE event_status = 'FAIL';

-- =========================
-- JSON parsing (BigQuery)
-- =========================
-- SELECT
--   order_id,
--   JSON_VALUE(payload_json, '$.failure_code') AS failure_code,
--   CAST(JSON_VALUE(payload_json, '$.metrics.retries') AS INT64) AS retries
-- FROM order_events
-- WHERE event_status = 'FAIL';

-- =========================
-- JSON parsing (SQL Server)
-- =========================
-- SELECT
--   order_id,
--   JSON_VALUE(payload_json, '$.failure_code') AS failure_code,
--   TRY_CAST(JSON_VALUE(payload_json, '$.metrics.retries') AS INT) AS retries
-- FROM order_events
-- WHERE event_status = 'FAIL';

-- =========================
-- XML parsing (SQL Server)
-- =========================
-- SELECT
--   order_id,
--   payload_xml.value('(/event/code/text())[1]', 'varchar(50)') AS code,
--   payload_xml.value('(/event/message/text())[1]', 'varchar(255)') AS message
-- FROM order_events;

-- =========================
-- XML parsing (Postgres)
-- =========================
-- SELECT
--   order_id,
--   (xpath('/event/code/text()', payload_xml::xml))[1]::text AS code,
--   (xpath('/event/message/text()', payload_xml::xml))[1]::text AS message
-- FROM order_events;
