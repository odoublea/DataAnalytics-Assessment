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
        AND sa.verification_call_message IN (
            'Verification successful', 'Verified', 'Gift redemption', 'Fund Redemption Paid',
            'Fund Returns Paid', 'Managed Portfolio Redemption for Balanced Portfolio',
            'Managed Portfolio Redemption for Conserv', 'Managed Portfolio Redemption for Conservative Portfolio',
            'Managed Portfolio Redemption for Conservative Portfolio 2', 'Managed Portfolio Redemption for Growth',
            'Managed Portfolio Redemption for Growth Portfolio', 'Payout for Arhat fruit (Cowrywise Investment Portfolio)',
            'Reward Paid', 'successful', 'USD Index Redemption Paid'
        )
        AND sa.transaction_status IN (
            'success', 'monnify_success', 'successful', 'usd_index_redemption', 'supportcredit', 'redemption',
            'reversal', 'reward', 'support credit', 'earnings'
        )
        AND gateway_response_message IN (
			'Successful', 'Approved by Financial Institution', 'Approved', 'Payment successful'
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
        p.is_a_fund = 1 OR p.is_managed_portfolio
        AND sa.verification_call_message IN (
            'Verification successful', 'Verified', 'Gift redemption', 'Fund Redemption Paid',
            'Fund Returns Paid', 'Managed Portfolio Redemption for Balanced Portfolio',
            'Managed Portfolio Redemption for Conserv', 'Managed Portfolio Redemption for Conservative Portfolio',
            'Managed Portfolio Redemption for Conservative Portfolio 2', 'Managed Portfolio Redemption for Growth',
            'Managed Portfolio Redemption for Growth Portfolio', 'Payout for Arhat fruit (Cowrywise Investment Portfolio)',
            'Reward Paid', 'successful', 'USD Index Redemption Paid'
        )
        AND sa.transaction_status IN (
            'success', 'monnify_success', 'successful', 'usd_index_redemption', 'supportcredit', 'redemption',
            'reversal', 'reward', 'support credit', 'earnings'
        )
        AND gateway_response_message IN (
			'Successful', 'Approved by Financial Institution', 'Approved', 'Payment successful'
        )
        AND sa.confirmed_amount > 0
    GROUP BY 
        p.owner_id
)

-- Aggregate users with both savings and investment plans and returns counts and total deposits across both.
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    fs.savings_count,
    fi.investment_count,
    (fs.savings_deposits + fi.investment_deposits) AS total_deposits
FROM 
    users_customuser u
JOIN 
    funded_savings fs ON u.id = fs.owner_id
JOIN 
    funded_investments fi ON u.id = fi.owner_id
ORDER BY 
    total_deposits DESC;