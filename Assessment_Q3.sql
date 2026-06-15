SET @ref_date = CURRENT_DATE; -- snapshot anchor date is '2025-07-16'

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
    li.last_txn_date,
    -- Days since last deposit;
    DATEDIFF(@ref_date, li.last_txn_date) AS inactivity_days
FROM plans_plan AS p
LEFT JOIN last_inflow AS li
       ON li.plan_id = p.id
WHERE (p.is_regular_savings = 1 OR p.is_a_fund = 1) 
-- Filter all active accounts, but the most recent one was over a year (365 Days) ago
  AND p.is_deleted  = 0
  AND p.is_archived = 0                       -- active accounts only
  AND DATEDIFF(@ref_date, li.last_txn_date) > 365
ORDER BY inactivity_days DESC;