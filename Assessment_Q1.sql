-- Funded savings plans per customer and total deposits
WITH funded_savings AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS savings_count,
        SUM(sa.confirmed_amount) AS savings_deposits
    FROM 
        plans_plan AS p
    JOIN 
        (SELECT plan_id, confirmed_amount FROM savings_savingsaccount WHERE transaction_status IN (
            'success', 'monnify_success', 'successful'
        )
        AND confirmed_amount > 0) AS sa -- only transactions with any of the three values are genuine inflows (success, monnify_success, successful)
    ON sa.plan_id = p.id
    WHERE 
        p.is_regular_savings = 1
    GROUP BY 
        p.owner_id
),

-- Funded investment plans per customer and total deposits
funded_investments AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS investment_count,
        SUM(inv.confirmed_amount) AS investment_deposits
    FROM 
        plans_plan AS p
    JOIN 
        (SELECT plan_id, confirmed_amount FROM savings_savingsaccount WHERE transaction_status IN (
            'success', 'monnify_success', 'successful'
        )
        AND confirmed_amount > 0) AS inv -- only transactions with any of the three values are genuine inflows (success, monnify_success, successful)
    ON inv.plan_id = p.id
    WHERE 
        p.is_a_fund = 1
    GROUP BY 
        p.owner_id
)

-- Aggregating users with both savings and investment plans 
SELECT 
    u.id AS owner_id,
    COALESCE(nullif(trim(u.name), ''), concat(TRIM(first_name), ' ', TRIM(last_name))) AS name,
    fs.savings_count,
    fi.investment_count,
    ROUND((fs.savings_deposits + fi.investment_deposits) / 100, 2) AS total_deposits -- Conversion of total deposits from Kobo to Naira
FROM 
    users_customuser u
JOIN 
    funded_savings fs ON u.id = fs.owner_id
JOIN 
    funded_investments fi ON u.id = fi.owner_id
ORDER BY 
    total_deposits DESC;