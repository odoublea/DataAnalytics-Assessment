
# Cowrywise Data Analytics Assessment

_by Abdulqudus Oladega_

---

## Question-by-Question Approach

### **1: High-Value Customers with Multiple Products**

**Objective:**  
Identify customers who have at least one **funded savings plan** and one **funded investment plan** (Cross-selling opportunity), Sorted by total deposits.

1. **`funded_savings`**:
   - Filters for plans marked as `is_regular_savings = 1`, and joins with `savings_savingsaccount`.
   - Compute number of savings plans per customer and,
   - Total deposits (in kobo), including only positively confirmed transactions with valid statuses/messages.
2. **`funded_investments`**:
   - Filters for plans marked as `is_a_fund = 1 OR is_managed_portfolio = TRUE`,  and joins with `savings_savingsaccount`.
   - Compute number of investment plans per customer and,
   - Total deposits (in kobo), including only positively confirmed transactions with valid statuses/messages.
3. **Final SELECT**:
   - Joins users to both CTEs.
   - Concatenates first and last name.
   - Sums deposits from both product types.
   - Orders by `total_deposits` in descending order.

**Challenges & Resolutions:**

- **Challenge**: Occurrence of empty or null values in customers' first and/or last names
  - **Resolution**: First and last names were checked for emptiness or null values; where present, they were replaced with `N/A`
- **Challenge**: The deposit validation involved multiple filters across three columns (`verification_call_message`, `transaction_status`, and `gateway_response_message`) with numerous string values.
  - **Resolution**: Consolidated all valid transaction criteria based on known success messages, while preserving logic and ensuring only positively confirmed deposit transactions were aggregated.
- **Challenge**: Handling logical operator precedence in `funded_investments` CTE for the `OR` clause.
  - **Resolution**: Added parentheses around `p.is_a_fund = 1 OR p.is_managed_portfolio` to avoid unintended filtering.
- **Challenge**: Identifying all investment plans
  - **Resolution**: In addtion to identfying investments with `is_a_fund = 1`, `is_managed_portfolio = 1` was used to pick out investments not handled by the customer

---

### Assessment_Q2: Transaction Frequency Analysis

**Objective:**  
Ranking customers based on the average number of savings transactions they perform monthly into frequency tiers: High, Medium, or Low.

**Approach:**

1. **`monthly_txns`**:  
   - Extracts the year-month from each `transaction_date`.
   - Counts how many transactions each customer made in each month.

2. **`avg_txn_per_customer`**:  
   - Computes the **average number of monthly transactions** for each customer across all months they transacted.

3. **`categorized_customers`**:  
   - Categorizes each customer using the following logic:
     - `High Frequency`: 10 or more average monthly transactions.
     - `Medium Frequency`: Between 3 and 10.
     - `Low Frequency`: Below 3.

4. **Final SELECT**:  
   - Groups the results by frequency category.
   - Returns the number of customers and average transactions per category.
   - Uses `ORDER BY FIELD(...)` to preserve a logical tier ordering in the output.

**Challenges & Resolutions:**

- **Challenge**: Grouping transactions properly by month for later averaging.
  - **Resolution**: Used `DATE_FORMAT(transaction_date, '%Y-%m-01')` to standardize date to the first of the month and ensure consistent grouping.
- **Challenge**: Correct segmentation logic and presentation.
  - **Resolution**: Applied a `CASE` statement in a dedicated CTE to isolate logic and make categorization transparent and testable.

---

### Assessment_Q3: Long-Term Inactive Accounts

**Objective:**  
Identify all savings and investment plans that have had no inflow activity for over **365 days**.

**Approach:**

1. **Savings inflows**: For all savings accounts, get the **latest date of inflow** using `confirmed_amount > 0`.
2. **Investment inflows**: For all active and non-archived investment plans, use the `last_returns_date` as the last inflow.
3. **Combine both** inflow sources (`UNION ALL`) and get the **most recent inflow per account**.
4. **Join back to plans** to classify plan type (`Savings`, `Investment`, `Stash`, or `Other`).
5. **Filter for inactivity** where `DATEDIFF` exceeds 365 days.

**Challenges & Resolutions:**

- **Challenge**: Occurrence of empty or null values in customers' first and/or last names
  - **Resolution**: First and last names were checked for emptiness or null values; where present, they were replaced with `N/A`
- **Challenge**: Handling different data sources (savings vs. investment) with different inflow date fields.
  - **Resolution**: Created two separate CTEs and normalized both to a common `last_inflow_date` format.
- **Challenge**: Accurate inactivity calculation across product types.
  - **Resolution**: Consolidated accounts using `UNION ALL` and grouped for most recent inflow per plan before filtering with `DATEDIFF`.

---

### Assessment_Q4: Customer Lifetime Value (CLV) Estimation

**Objective:**  
Estimate a customer’s CLV using their tenure and total confirmed transaction volume.

**Approach:**

1. **Tenure**: Calculates the number of months since the user account was created.
2. **Transaction**: Sums confirmed transactions based on a whitelist of successful `verification_call_message`, `transaction_status`, and `gateway_response_message` values.
3. **Final CLV formula**:  
   \[
   \text{CLV} = \left(\frac{\text{Total Transaction}}{\text{Tenure in Months}} \right) \times 12 \times 0.001
   \]
   - Multiplied by 12 to annualize.
   - Multiplied by 0.001 to simulate a business-specific monetization factor (e.g., 0.1% margin or retention projection).

**Challenges & Safeguards:**

- **Zero-tenure protection**: Used `CASE` logic to prevent division by zero.
- **Data accuracy**: Ensured only valid inflows were included using a combination of 3 fields for robust transaction filtering.

---

## Challenges & Learnings

- **Data Quality:** Assumed data cleanliness based on schema. In real-world cases, data profiling and cleansing would be essential.
- **Edge Case Handling:** Implemented safe-guards for division by zero, NULL transactions, and undefined activity spans.
- **Interpretability:** Prioritized readable aliasing, clear filtering logic, and descriptive comments to aid future reviews or audits.

---

I appreciate the opportunity to work on this assessment. It has been a wonderful experience!
Thank you for reviewing my submission. I welcome feedback and am happy to elaborate further on any query logic or assumptions made.
