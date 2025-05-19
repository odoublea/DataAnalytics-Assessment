-- Identify users with funded regular savings plans, along with the count of such plans and total deposits.
WITH funded_savings AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS savings_count,
        SUM(sa.confirmed_amount) AS savings_deposits
    FROM 
        plans_plan p
    JOIN 
        savings_savingsaccount sa ON sa.plan_id = p.id
    WHERE 
        p.is_regular_savings = 1
        AND sa.transaction_status IN (
            'success', 'monnify_success', 'successful', 'usd_index_redemption', 'supportcredit', 'redemption',
            'reversal', 'reward', 'support credit', 'earnings', 'circle'
        )
        AND sa.confirmed_amount > 0
    GROUP BY 
        p.owner_id
	order by savings_deposits desc
),

-- Identify users with funded investment plans, including count of investment plans and their total deposits.
funded_investments AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS investment_count,
        SUM(sa.confirmed_amount) AS investment_deposits
    FROM 
        plans_plan p
    JOIN 
        savings_savingsaccount sa ON sa.plan_id = p.id
    WHERE 
        (p.is_a_fund = 1 OR p.is_managed_portfolio = 1)
        AND sa.transaction_status IN (
            'success', 'monnify_success', 'successful', 'usd_index_redemption', 'supportcredit', 'redemption',
            'reversal', 'reward', 'support credit', 'earnings', 'circle'
        )
        AND sa.confirmed_amount > 0
    GROUP BY 
        p.owner_id
)

-- Aggregate users with both savings and investment plans and returns counts and total deposits across both.
SELECT 
    u.id AS owner_id,
    CONCAT(
			COALESCE(NULLIF(TRIM(first_name), ''), 'N/A'), -- Handling null or empty first_name values with N/A, Not Available
				" ",
			COALESCE(NULLIF(TRIM(last_name), ''), 'N/A')  -- Handling null or empty last_name values with N/A, Not Available
	) AS name,
    fs.savings_count,
    fi.investment_count,
    ROUND((fs.savings_deposits + fi.investment_deposits) / 100, 2) AS total_deposits -- Calculate total deposits and convert the value from Kobo to Naira
FROM 
    users_customuser u
JOIN 
    funded_savings fs ON u.id = fs.owner_id
JOIN 
    funded_investments fi ON u.id = fi.owner_id
ORDER BY 
    total_deposits DESC;