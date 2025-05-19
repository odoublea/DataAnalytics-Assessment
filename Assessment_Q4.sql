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
    WHERE verification_call_message IN (
        'Verification successful', 'Verified', 'Gift redemption', 'Fund Redemption Paid', 'Fund Returns Paid',
        'Managed Portfolio Redemption for Balanced Portfolio', 'Managed Portfolio Redemption for Conserv',
        'Managed Portfolio Redemption for Conservative Portfolio', 'Managed Portfolio Redemption for Conservative Portfolio 2',
        'Managed Portfolio Redemption for Growth', 'Managed Portfolio Redemption for Growth Portfolio',
        'Payout for Arhat fruit (Cowrywise Investment Portfolio)', 'Reward Paid', 'successful',
        'USD Index Redemption Paid'
    )
    AND transaction_status IN (
        'success', 'monnify_success', 'successful', 'usd_index_redemption', 'supportcredit', 'redemption',
        'reversal', 'reward', 'support credit', 'earnings'
    )
    AND gateway_response_message IN (
        'Successful', 'Approved by Financial Institution', 'Approved', 'Payment successful'
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
