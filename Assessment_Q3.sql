SET @ref_date = '2025-07-16'; -- snapshot anchor date is '2025-07-16'

-- Last confirmed deposit per plan
WITH last_inflow AS (
    SELECT
        plan_id,
        MAX(DATE(transaction_date)) AS last_txn_date
    FROM savings_savingsaccount
        WHERE
        confirmed_amount > 0  AND transaction_status IN (
            'success', 'monnify_success', 'successful'
        )
    GROUP BY plan_id
)

SELECT
    p.id       AS plan_id,
    p.owner_id AS owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund          = 1 THEN 'Investment'
    END        AS type,
    COALESCE(li.last_txn_date, DATE(p.created_on)) AS last_transaction_date,
    -- Days since last deposit; if no deposit, default to days since account creation
    DATEDIFF(@ref_date, COALESCE(li.last_txn_date, p.created_on)) AS inactivity_days
FROM plans_plan AS p
LEFT JOIN last_inflow AS li
       ON li.plan_id = p.id
WHERE (p.is_regular_savings = 1 OR p.is_a_fund = 1) 
-- Filter all active accounts, but the most recent one was over a year (365 Days) ago
  AND p.is_deleted  = 0
  AND p.is_archived = 0                       -- active accounts only
  AND DATEDIFF(@ref_date, COALESCE(li.last_txn_date, p.created_on)) > 365
ORDER BY inactivity_days DESC;