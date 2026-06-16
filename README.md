
# Cowrywise Data Analytics Assessment
>
> SQL Proficiency Assessment

_by Abdulqudus Oladega_
---

## Repository structure

```
DataAnalytics-Assessment/
├── Assessment_Q1.sql High-value customers with multiple products
├── Assessment_Q2.sql Transaction frequency analysis
├── Assessment_Q3.sql Account inactivity alert
├── Assessment_Q4.sql Customer lifetime value (CLV) estimation
└── README.md
```

## Shared conventions and assumptions

These hold across every query:
  
1. **Amounts are in kobo.** Every monetary field is divided by 100 to report Naira (100 kobo = 1 Naira).

2. **Deposit validation:** A `savings_savingsaccount` row with `confirmed_amount > 0`. When a status filter is applied, it is limited to actual successful inflows (`success`, `monnify_success`, `successful`), excluding failed, pending, reversal, and redemption events.

3. **Customer name can be blank.** A handful of users have an empty `name`, so every query falls back to `first_name + last_name` using `COALESCE(NULLIF(TRIM(u.name), ''), CONCAT(TRIM(first_name), ' ', TRIM(last_name))) AS name`.

---

## Question-by-Question Approach

### **1: High-Value Customers with Multiple Products**

**Objective:**

Identify customers who have at least one **funded savings plan** and one **funded investment plan** (Cross-selling opportunity), sorted by total deposits.

1. **`funded_savings` CTE**:

- Filters for plans marked as `is_regular_savings = 1`, and joins with `savings_savingsaccount`.

- Compute the number of savings plans per customer and,

- Total deposits (in kobo), including only positively confirmed transactions with valid statuses/messages.

1. **`funded_investments` CTE**:

- Filters for plans marked as `is_a_fund = 1 OR is_managed_portfolio = TRUE`, and joins with `savings_savingsaccount`.

- Compute the number of investment plans per customer and,

- Total deposits (in kobo), including only positively confirmed transactions with valid statuses/messages.

1. **Final SELECT**:

- Joins users to both CTEs.

- Concatenates first and last name.

- Sums deposits from both product types.

- Orders by `total_deposits` in descending order.
  
---

### Assessment_Q2: Transaction Frequency Analysis

**Objective:**

Ranking customers based on the average number of savings transactions they perform monthly into frequency tiers: High, Medium, or Low.

**Approach:**

1. **`monthly_txns` CTE**:

- Extracts the year-month from each `transaction_date` with `DATE_FORMAT(transaction_date, '%Y-%m')`.

- Counts how many transactions each customer made in each month.

1. **`avg_txn_per_customer` CTE**:

- Computes the **average number of monthly transactions** for each customer across all months they transacted.  

1. **`categorized_customers` CTE**:

- Categorizes each customer using the following logic:

- `High Frequency`: 10 or more average monthly transactions.

- `Medium Frequency`: Between 3 and 10.

- `Low Frequency`: Below 3.

1. **Final SELECT**:

- Groups the results by frequency category.

- Returns the number of customers and average transactions per category.

- Uses `ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency')` to preserve a logical tier ordering in the output.

---
  
### Assessment_Q3: Long-Term Inactive Accounts

**Objective:**

Identify all savings and investment plans that have had no inflow activity for over **365 days**.

**Approach:**  

1. **`last_inflow`** CTE: Gets the **latest date of inflow** across all savings and investment plans .

2. **Final SELECT**: The final SELECT statement LEFT JOINs `last_inflow` CTE, so the scope filter  
`(is_regular_savings = 1 OR is_a_fund = 1)` and the active filter  `(is_deleted = 0 AND is_archived = 0)` apply to the whole population exactly once. The `inactivity_days` metric only tracks active accounts (those that have been funded at least once) whose most recent deposit was more than 365 days ago.

---

### Assessment_Q4: Customer Lifetime Value (CLV) Estimation

**Objective:**

Estimate a customer’s CLV using their tenure and total confirmed transaction volume.  

**Approach:**

1. **`Tenure` CTE**: Calculates the number of months since the user account was created.

2. **Transaction**: Sums confirmed transactions based on a whitelist of successful `transaction_status` values.

3. **Final CLV formula**:

$$\text{CLV} = \left( \frac{\text{total transactions}}{\text{tenure}} \right) \times 12 \times \text{avg profit per transaction}$$

where `avg profit per transaction` = 0.1%, so the formula expands to:

$$\text{CLV} = \left( \frac{\text{total transactions}}{\text{tenure}} \right) \times 12 \times 0.001$$

---

## Challenges & Learnings

- **Data Quality:** Assumed data cleanliness based on the schema. In real-world cases, data profiling and cleansing would be essential.

- **Edge Case Handling:** Implemented safeguards against division by zero, NULL transactions, and undefined activity spans.

- **Interpretability:** Emphasized readable aliasing, straightforward filtering logic, and added descriptive comments to facilitate future reviews or audits.

---

I appreciate the opportunity to work on this assessment. It has been a wonderful experience!

Thank you for reviewing my submission. I welcome feedback and am happy to elaborate further on any query logic or assumptions made.
