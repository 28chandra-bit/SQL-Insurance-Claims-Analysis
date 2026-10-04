-- Analysis queries: SQL Insurance Claims Analysis
USE insurance_claims_db;

-- ============================================================
-- 1. Basic KPIs
-- ============================================================
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_policies FROM policies;
SELECT COUNT(*) AS total_claims FROM claims;
SELECT ROUND(SUM(claim_amount),2) AS total_claim_amount FROM claims;
SELECT ROUND(AVG(claim_amount),2) AS average_claim_amount FROM claims;

-- ============================================================
-- 2. Claims by status and type
-- ============================================================
SELECT claim_status, COUNT(*) AS claim_count,
       ROUND(SUM(claim_amount),2) AS total_claim_amount
FROM claims
GROUP BY claim_status
ORDER BY total_claim_amount DESC;

SELECT claim_type, COUNT(*) AS claim_count,
       ROUND(AVG(claim_amount),2) AS avg_claim_amount
FROM claims
GROUP BY claim_type
ORDER BY claim_count DESC;

-- ============================================================
-- 3. Policy activity
-- ============================================================
SELECT policy_type, policy_status,
       COUNT(*) AS policy_count,
       ROUND(SUM(annual_premium),2) AS annual_premium
FROM policies
GROUP BY policy_type, policy_status
ORDER BY policy_type, policy_status;

-- Customers with multiple policies
SELECT customer_id, COUNT(*) AS policy_count
FROM policies
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY policy_count DESC;

-- ============================================================
-- 4. Customer-level claims
-- ============================================================
SELECT c.customer_id, c.customer_name,
       COUNT(cl.claim_id) AS claim_count,
       ROUND(SUM(cl.claim_amount),2) AS total_claim_amount,
       ROUND(AVG(cl.claim_amount),2) AS avg_claim_amount
FROM customers c
JOIN claims cl ON c.customer_id = cl.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_claim_amount DESC;

-- ============================================================
-- 5. High-value claims
-- ============================================================
SELECT claim_number, customer_id, policy_id, claim_type,
       claim_status, claim_amount
FROM claims
WHERE claim_amount > (SELECT AVG(claim_amount) FROM claims)
ORDER BY claim_amount DESC;

-- Top 10 claims
SELECT *
FROM claims
ORDER BY claim_amount DESC
LIMIT 10;

-- ============================================================
-- 6. CTE: customer claim summary
-- ============================================================
WITH customer_claims AS (
    SELECT customer_id,
           COUNT(*) AS claim_count,
           SUM(claim_amount) AS total_claim_amount
    FROM claims
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name,
       cc.claim_count,
       ROUND(cc.total_claim_amount,2) AS total_claim_amount
FROM customers c
JOIN customer_claims cc
  ON c.customer_id = cc.customer_id
WHERE cc.total_claim_amount > 20000
ORDER BY cc.total_claim_amount DESC;

-- ============================================================
-- 7. Window functions: rank customers
-- ============================================================
WITH customer_claims AS (
    SELECT customer_id,
           SUM(claim_amount) AS total_claim_amount
    FROM claims
    GROUP BY customer_id
)
SELECT customer_id,
       ROUND(total_claim_amount,2) AS total_claim_amount,
       RANK() OVER (ORDER BY total_claim_amount DESC) AS claim_amount_rank,
       DENSE_RANK() OVER (ORDER BY total_claim_amount DESC) AS dense_rank_value
FROM customer_claims
ORDER BY claim_amount_rank;

-- ============================================================
-- 8. Top 3 claims within each policy type
-- ============================================================
WITH ranked_claims AS (
    SELECT p.policy_type,
           cl.claim_number,
           cl.customer_id,
           cl.claim_amount,
           ROW_NUMBER() OVER (
               PARTITION BY p.policy_type
               ORDER BY cl.claim_amount DESC
           ) AS rn
    FROM claims cl
    JOIN policies p ON cl.policy_id = p.policy_id
)
SELECT *
FROM ranked_claims
WHERE rn <= 3
ORDER BY policy_type, rn;

-- ============================================================
-- 9. Month-over-month claim trend
-- ============================================================
WITH monthly_claims AS (
    SELECT DATE_FORMAT(claim_date, '%Y-%m') AS claim_month,
           COUNT(*) AS claim_count,
           SUM(claim_amount) AS total_claim_amount
    FROM claims
    GROUP BY DATE_FORMAT(claim_date, '%Y-%m')
)
SELECT claim_month,
       claim_count,
       ROUND(total_claim_amount,2) AS total_claim_amount,
       LAG(claim_count) OVER (ORDER BY claim_month) AS previous_month_claims,
       claim_count - LAG(claim_count) OVER (ORDER BY claim_month) AS month_over_month_change
FROM monthly_claims
ORDER BY claim_month;

-- ============================================================
-- 10. Settlement analysis
-- ============================================================
SELECT
    COUNT(*) AS total_claims,
    SUM(CASE WHEN claim_status = 'Settled' THEN 1 ELSE 0 END) AS settled_claims,
    ROUND(
        100.0 * SUM(CASE WHEN claim_status = 'Settled' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS settlement_rate_pct,
    ROUND(SUM(claim_amount),2) AS total_claim_amount,
    ROUND(SUM(settled_amount),2) AS total_settled_amount,
    ROUND(SUM(claim_amount - settled_amount),2) AS outstanding_amount
FROM claims;

-- ============================================================
-- 11. Claims with no payments
-- ============================================================
SELECT cl.claim_id, cl.claim_number, cl.claim_status, cl.claim_amount
FROM claims cl
LEFT JOIN payments p ON cl.claim_id = p.claim_id
WHERE p.claim_id IS NULL
ORDER BY cl.claim_amount DESC;

-- ============================================================
-- 12. Payment summary by claim
-- ============================================================
SELECT cl.claim_number,
       cl.claim_amount,
       ROUND(COALESCE(SUM(p.payment_amount),0),2) AS total_payments,
       ROUND(cl.claim_amount - COALESCE(SUM(p.payment_amount),0),2) AS unpaid_amount
FROM claims cl
LEFT JOIN payments p ON cl.claim_id = p.claim_id
GROUP BY cl.claim_id, cl.claim_number, cl.claim_amount
ORDER BY unpaid_amount DESC;

-- ============================================================
-- 13. Policy-level claims analysis
-- ============================================================
SELECT p.policy_number, p.policy_type, p.policy_status,
       COUNT(cl.claim_id) AS claim_count,
       ROUND(COALESCE(SUM(cl.claim_amount),0),2) AS total_claim_amount
FROM policies p
LEFT JOIN claims cl ON p.policy_id = cl.policy_id
GROUP BY p.policy_id, p.policy_number, p.policy_type, p.policy_status
ORDER BY total_claim_amount DESC;

-- ============================================================
-- 14. Data-quality checks
-- ============================================================

-- Duplicate customer emails
SELECT email, COUNT(*) AS duplicate_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Missing critical customer fields
SELECT *
FROM customers
WHERE customer_name IS NULL
   OR email IS NULL
   OR state IS NULL;

-- Invalid claim amounts
SELECT *
FROM claims
WHERE claim_amount <= 0
   OR settled_amount < 0
   OR settled_amount > claim_amount;

-- Claims whose customer does not match the policy owner
SELECT cl.claim_id, cl.customer_id AS claim_customer,
       p.customer_id AS policy_customer
FROM claims cl
JOIN policies p ON cl.policy_id = p.policy_id
WHERE cl.customer_id <> p.customer_id;

-- Orphan payments
SELECT p.*
FROM payments p
LEFT JOIN claims c ON p.claim_id = c.claim_id
WHERE c.claim_id IS NULL;

-- ============================================================
-- 15. Business insight: claim ratio by policy type
-- ============================================================
SELECT p.policy_type,
       COUNT(DISTINCT p.policy_id) AS policies,
       COUNT(cl.claim_id) AS claims,
       ROUND(SUM(COALESCE(cl.claim_amount,0)),2) AS claim_amount,
       ROUND(
           SUM(COALESCE(cl.claim_amount,0)) /
           NULLIF(COUNT(DISTINCT p.policy_id),0), 2
       ) AS claim_amount_per_policy
FROM policies p
LEFT JOIN claims cl ON p.policy_id = cl.policy_id
GROUP BY p.policy_type
ORDER BY claim_amount_per_policy DESC;

-- ============================================================
-- 16. Customers with claims above overall average
-- ============================================================
SELECT c.customer_id, c.customer_name,
       cl.claim_number, cl.claim_amount
FROM customers c
JOIN claims cl ON c.customer_id = cl.customer_id
WHERE cl.claim_amount > (SELECT AVG(claim_amount) FROM claims)
ORDER BY cl.claim_amount DESC;
