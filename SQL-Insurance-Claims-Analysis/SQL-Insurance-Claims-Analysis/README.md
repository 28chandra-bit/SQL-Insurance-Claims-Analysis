# SQL Insurance Claims Analysis

## Project Overview

This portfolio project demonstrates end-to-end SQL analysis using a synthetic insurance claims dataset.

The project models a simplified insurance environment containing customers, policies, claims, and payments. It uses MySQL 8.0+ and focuses on business-oriented analysis rather than only SQL syntax.

> **Data note:** All records in this repository are synthetic and created for portfolio/learning purposes. No real customer, policy, or claims information is used.

## Business Objective

Analyze insurance claims and policy activity to identify:

- Claim volume and claim value trends
- Settlement performance
- High-value claims
- Customer-level claim behavior
- Policy-level claim activity
- Payment and outstanding amounts
- Data-quality issues
- Business patterns by policy and claim type

## Data Model

```text
customers
    |
    | 1-to-many
    v
policies
    |
    | 1-to-many
    v
claims
    |
    | 1-to-many
    v
payments
```

### Tables

| Table | Purpose |
|---|---|
| `customers` | Customer demographic and contact information |
| `policies` | Policy type, status, premium and customer relationship |
| `claims` | Claim dates, types, statuses and financial amounts |
| `payments` | Payments made against claims |

## SQL Skills Demonstrated

- SELECT / WHERE / ORDER BY
- GROUP BY and HAVING
- INNER JOIN and LEFT JOIN
- CASE expressions
- Aggregations
- Subqueries
- CTEs
- Window functions
- `ROW_NUMBER()`
- `RANK()`
- `DENSE_RANK()`
- `LAG()`
- Date functions
- `COALESCE()`
- Data-quality validation
- Primary and foreign keys
- Business KPI calculations

## Project Structure

```text
SQL-Insurance-Claims-Analysis/
│
├── README.md
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   ├── 03_analysis_queries.sql
│   └── 04_data_quality_checks.sql
│
├── data/
│   └── data_dictionary.md
```

## How to Run

### 1. Install MySQL 8.0+

Open MySQL Workbench or another MySQL client.

### 2. Create the schema

Run:

```sql
SOURCE sql/01_schema.sql;
```

### 3. Load the synthetic data

Run:

```sql
SOURCE sql/02_seed_data.sql;
```

### 4. Run the analysis

Run:

```sql
SOURCE sql/03_analysis_queries.sql;
```

### 5. Run data-quality checks

Run:

```sql
SOURCE sql/04_data_quality_checks.sql;
```

If `SOURCE` is not supported by your client, open each `.sql` file in MySQL Workbench and execute it.

## Example Business Questions

### 1. What is the total claim amount?

```sql
SELECT ROUND(SUM(claim_amount), 2) AS total_claim_amount
FROM claims;
```

### 2. Which customers have the highest claim amounts?

```sql
SELECT customer_id,
       ROUND(SUM(claim_amount),2) AS total_claim_amount
FROM claims
GROUP BY customer_id
ORDER BY total_claim_amount DESC;
```

### 3. What are the top 3 claims within each policy type?

The project uses `ROW_NUMBER()` with `PARTITION BY` to answer this question.

### 4. How are claim volumes changing month over month?

The project uses a CTE and `LAG()` to compare each month's claim count with the previous month.

## Key Business Insights

After running the queries, use the actual result set to report the final numbers. Suggested insight categories include:

1. Which policy type has the highest claim activity?
2. Which customers have unusually high claim values?
3. What percentage of claims are settled?
4. How much claim value remains outstanding?
5. Which claim types have the highest average claim amount?
6. Which policies have multiple claims?
7. Which claims have no corresponding payment?
8. Are there customer-policy mismatches or other data-quality exceptions?








