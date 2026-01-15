-- 1) Active accounts by institution type
SELECT
  i.institution_type,
  COUNT(*) AS active_accounts
FROM bank_accounts a
JOIN institutions i ON i.institution_id = a.institution_id
WHERE a.status = 'ACTIVE'
GROUP BY i.institution_type
ORDER BY active_accounts DESC;


-- 2) Clients with multiple active institutions (control / risk style check)
SELECT
  c.client_id,
  c.client_name,
  COUNT(DISTINCT a.institution_id) AS active_institutions
FROM bank_accounts a
JOIN clients c ON c.client_id = a.client_id
WHERE a.status = 'ACTIVE'
GROUP BY c.client_id, c.client_name
HAVING COUNT(DISTINCT a.institution_id) >= 2
ORDER BY active_institutions DESC;


-- 3) Rank institutions by active client count (DENSE_RANK)
WITH counts AS (
  SELECT
    institution_id,
    COUNT(DISTINCT client_id) AS clients
  FROM bank_accounts
  WHERE status = 'ACTIVE'
  GROUP BY institution_id
)
SELECT
  i.institution_name,
  c.clients,
  DENSE_RANK() OVER (ORDER BY c.clients DESC) AS institution_rank
FROM counts c
JOIN institutions i ON i.institution_id = c.institution_id
ORDER BY institution_rank, c.clients DESC;
