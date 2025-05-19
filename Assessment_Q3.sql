-- Step 1: Identify active savings accounts with their last inflow date
WITH savings_last_inflow AS (
    SELECT
        plan_id,
        owner_id,
        MAX(DATE(transaction_date)) AS last_inflow_date
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0  -- Inflow transactions
    GROUP BY plan_id, owner_id
),

-- Step 2: Identify active investment plans with their last returns date
active_plans AS (
    SELECT 
        id AS plan_id,
        owner_id,
        DATE(last_returns_date) AS last_inflow_date
    FROM plans_plan
    WHERE is_deleted = 0 
      AND is_archived = 0
      AND last_returns_date IS NOT NULL
),

-- Step 3: Combine all accounts (savings and investments) with their last inflow date
all_accounts_last_inflow AS (
    SELECT plan_id, owner_id, last_inflow_date FROM savings_last_inflow
    UNION ALL
    SELECT plan_id, owner_id, last_inflow_date FROM active_plans
),

-- Step 4: Get the most recent inflow date for each account
account_last_inflow AS (
    SELECT
        plan_id,
        owner_id,
        MAX(last_inflow_date) AS last_inflow_date
    FROM all_accounts_last_inflow
    GROUP BY plan_id, owner_id
),

-- Final step: Filter for accounts with inactivity over 365 days
Inactive_plans AS (
SELECT
    ali.plan_id,
    ali.owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 OR p.is_managed_portfolio THEN 'Investment'
        WHEN p.is_a_wallet = 1 THEN 'Stash'
        ELSE 'Other'
    END AS type,
    ali.last_inflow_date as last_transaction_date,
    DATEDIFF(CURRENT_DATE, ali.last_inflow_date) AS inactivity_days
FROM account_last_inflow ali
JOIN plans_plan p ON p.id = ali.plan_id
)
SELECT
	*
FROM
	inactive_plans
WHERE
	inactivity_days > 365
ORDER BY
	inactivity_days;