-- Dedicated data-quality checks
USE insurance_claims_db;

-- 1. Duplicate emails
SELECT email, COUNT(*) AS duplicate_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- 2. Duplicate policy numbers
SELECT policy_number, COUNT(*) AS duplicate_count
FROM policies
GROUP BY policy_number
HAVING COUNT(*) > 1;

-- 3. Duplicate claim numbers
SELECT claim_number, COUNT(*) AS duplicate_count
FROM claims
GROUP BY claim_number
HAVING COUNT(*) > 1;

-- 4. Missing customer attributes
SELECT *
FROM customers
WHERE customer_name IS NULL
   OR email IS NULL
   OR date_of_birth IS NULL
   OR state IS NULL;

-- 5. Invalid claim amounts
SELECT *
FROM claims
WHERE claim_amount <= 0
   OR settled_amount < 0
   OR settled_amount > claim_amount;

-- 6. Customer-policy mismatch
SELECT cl.claim_id, cl.customer_id AS claim_customer_id,
       p.customer_id AS policy_customer_id
FROM claims cl
JOIN policies p ON cl.policy_id = p.policy_id
WHERE cl.customer_id <> p.customer_id;

-- 7. Payments exceeding claim amount
WITH payment_totals AS (
    SELECT claim_id, SUM(payment_amount) AS total_paid
    FROM payments
    GROUP BY claim_id
)
SELECT c.claim_id, c.claim_number, c.claim_amount,
       pt.total_paid
FROM claims c
JOIN payment_totals pt ON c.claim_id = pt.claim_id
WHERE pt.total_paid > c.claim_amount;

-- 8. Claims without payments
SELECT c.claim_id, c.claim_number, c.claim_status
FROM claims c
LEFT JOIN payments p ON c.claim_id = p.claim_id
WHERE p.claim_id IS NULL;
