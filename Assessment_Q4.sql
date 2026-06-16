SET @ref_date = CURRENT_DATE; -- snapshot anchor date is '2025-07-16'
SET @profit_rate = 0.001;

WITH tenure AS (
    SELECT 
        id AS owner_id, 
        COALESCE(nullif(trim(name), ''), concat(TRIM(first_name), ' ', TRIM(last_name))) AS name,
        DATE(date_joined) AS date_joined,
        TIMESTAMPDIFF(MONTH, date_joined, @ref_date) AS tenure_months 
    FROM users_customuser
    GROUP BY id
),
transactions AS (
    SELECT 
        owner_id,
        COUNT(id) AS total_txn, -- count of transactions
        SUM(confirmed_amount) / 100 AS total_txn_value -- total transaction value in Naira
    FROM savings_savingsaccount 
    WHERE 
    confirmed_amount > 0  AND transaction_status IN (
            'success', 'monnify_success', 'successful'
        )
    GROUP BY owner_id
)

-- Final CLV Calculation with division-safe logic
SELECT 
    t.owner_id AS customer_id, 
    t.name,
    t.tenure_months, 
    COALESCE(txn.total_txn, 0) AS total_transactions,
   CASE 
		WHEN t.tenure_months > 0 AND txn.total_txn > 0 THEN ROUND(((txn.total_txn_value / t.tenure_months) * 12 * @profit_rate ), 2)
        ELSE 0
	END AS estimated_clv
FROM tenure t 
LEFT JOIN transactions txn ON t.owner_id = txn.owner_id
ORDER BY estimated_clv DESC;
