WITH tenure AS (
    SELECT 
        id AS owner_id, 
        CONCAT(
			COALESCE(NULLIF(TRIM(first_name), ''), 'N/A'),  -- Handling null or empty first_name values with N/A, Not Available
				" ",
			COALESCE(NULLIF(TRIM(last_name), ''), 'N/A')  -- Handling null or empty last_name values with N/A, Not Available
            ) AS name, 
        TIMESTAMPDIFF(MONTH, created_on, CURRENT_DATE) AS tenure_months 
    FROM users_customuser
),
total_transactions AS (
    SELECT 
        owner_id, 
        SUM(confirmed_amount) / 100 AS total_transaction -- Convert total transaction value to Naira
    FROM savings_savingsaccount 
    WHERE 
    transaction_status IN (
        'success', 'monnify_success', 'successful', 'usd_index_redemption', 'supportcredit', 'redemption',
        'reversal', 'reward', 'support credit', 'earnings', 'circle'
    )
    GROUP BY owner_id
)

-- Final CLV Calculation with division-safe logic
SELECT 
    t.owner_id AS customer_id, 
    t.name, 
    t.tenure_months, 
    ROUND(tt.total_transaction, 2) AS total_transactions,
    CASE 
        WHEN t.tenure_months = 0 THEN 0
        ELSE ROUND(((tt.total_transaction / t.tenure_months) * 12 * 0.001), 2)
    END AS estimated_clv
FROM tenure t 
JOIN total_transactions tt ON t.owner_id = tt.owner_id 
ORDER BY estimated_clv DESC;
