-- Monthly transactions per customer
WITH monthly_txns AS (
    SELECT 
        owner_id, 
        DATE_FORMAT(transaction_date, '%Y-%m-01') AS txn_month, 
        COUNT(*) AS txn_count
    FROM savings_savingsaccount
    WHERE transaction_status IN (
            'success', 'monnify_success', 'successful', 'usd_index_redemption', 'supportcredit', 'redemption',
            'reward', 'support credit', 'earnings', 'circle', 'New Card Initialization Redemption.'
        )
    GROUP BY owner_id, txn_month
),

-- Average monthly transaction per customer
avg_txn_per_customer AS (
    SELECT 
        owner_id,
        ROUND(AVG(txn_count), 2) AS avg_monthly_txn
    FROM monthly_txns
    GROUP BY owner_id
),

-- Categorization of customers based on their average transaction per month
categorized_customers AS (
    SELECT
        owner_id,
        avg_monthly_txn,
        CASE
            WHEN avg_monthly_txn >= 10 THEN 'High Frequency'
            WHEN avg_monthly_txn >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM avg_txn_per_customer
)

SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_monthly_txn), 1) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
