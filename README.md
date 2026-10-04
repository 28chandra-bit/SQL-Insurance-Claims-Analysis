# SQL Insurance Claims Analysis

## Project Overview

This project demonstrates SQL-based analysis of a simulated US insurance claims dataset using **MySQL**.

The dataset contains related information across customers, insurance policies, claims, and payments. The project focuses on analyzing claim activity, settlement patterns, customer and policy performance, payment gaps, and data quality.

> **Note:** All data used in this project is synthetic and self-created for learning and portfolio purposes. It does not contain real client, employer, or customer information.

---

## Business Objective

The objective of this project is to use SQL to answer common insurance business questions such as:

* How many claims are being raised?
* What is the total and average claim amount?
* Which policy types have the highest claim volume?
* Which customers have high claim activity?
* What are the settlement trends?
* Which claims do not have payment records?
* Are there payment amounts exceeding claim amounts?
* Are there duplicate or incomplete records?
* Are customer and policy relationships consistent?

---

## Dataset

The project contains four relational tables:

| Table       | Records | Description                  |
| ----------- | ------: | ---------------------------- |
| `customers` |     100 | Customer information         |
| `policies`  |     150 | Insurance policy information |
| `claims`    |     250 | Insurance claim transactions |
| `payments`  |     188 | Claim payment information    |

### Database Relationship

```text
Customers
    │
    │ 1 : Many
    ▼
Policies
    │
    │ 1 : Many
    ▼
Claims
    │
    │ 1 : Many
    ▼
Payments
```

The relationships allow analysis across the customer, policy, claim, and payment levels.

---

## SQL Skills Demonstrated

### Data Retrieval & Aggregation

* `SELECT`
* `WHERE`
* `GROUP BY`
* `HAVING`
* `ORDER BY`
* `COUNT()`
* `SUM()`
* `AVG()`
* `MIN()`
* `MAX()`

### Joins

* `INNER JOIN`
* `LEFT JOIN`
* Multi-table joins
* Customer → Policy → Claims analysis
* Claims → Payments reconciliation

### Advanced SQL

* Common Table Expressions (CTEs)
* Subqueries
* `CASE WHEN`
* `ROW_NUMBER()`
* `RANK()`
* `DENSE_RANK()`
* `LAG()`

### Data Quality

* Duplicate record checks
* Missing-value checks
* Invalid claim amount checks
* Customer-policy mismatch checks
* Claims without payments
* Payment reconciliation checks

---

## Key Analysis Areas

### 1. Claim Analysis

Analyzed:

* Total claim amount
* Average claim amount
* Claim volume
* Claim status
* Claim type
* High-value claims

### 2. Policy Analysis

Analyzed claim activity across:

* Policy types
* Policy status
* Customer policies
* Policy-level claim activity

### 3. Customer Analysis

Identified:

* Customers with multiple claims
* High-value claim customers
* Customer-level claim amounts
* Customer policy activity

### 4. Settlement & Payment Analysis

Analyzed:

* Settled vs pending claims
* Claims without payment records
* Total payment amounts
* Claim-to-payment reconciliation
* Potential payment discrepancies

### 5. Data Quality Analysis

Performed checks for:

* Duplicate records
* Missing values
* Invalid claim amounts
* Unmatched customer/policy records
* Claims without payments
* Payments exceeding claim amounts

---

## Sample SQL Analysis

### Total Claim Amount

```sql
SELECT 
    ROUND(SUM(claim_amount), 2) AS total_claim_amount
FROM claims;
```

### Claim Analysis by Status

```sql
SELECT 
    claim_status,
    COUNT(*) AS claim_count,
    ROUND(SUM(claim_amount), 2) AS total_claim_amount,
    ROUND(AVG(claim_amount), 2) AS average_claim_amount
FROM claims
GROUP BY claim_status
ORDER BY total_claim_amount DESC;
```

### Highest Claim for Each Customer

```sql
SELECT *
FROM (
    SELECT 
        customer_id,
        claim_id,
        claim_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY claim_amount DESC
        ) AS rn
    FROM claims
) x
WHERE rn = 1;
```

---

## Project Structure

```text
SQL-Insurance-Claims-Analysis/
│
├── README.md
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   ├── 03_analysis_queries.sql
│   └── 04_data_quality_checks.sql
│
└── data/
    └── data_dictionary.md
```

---

## Tools Used

* **MySQL**
* **MySQL Workbench**
* SQL

---

## Key Learning Outcomes

Through this project, I practiced:

* Working with relational databases
* Understanding primary and foreign keys
* Joining multiple related tables
* Performing business-oriented SQL analysis
* Using CTEs and subqueries
* Applying SQL window functions
* Performing data-quality validation
* Translating business questions into SQL queries

---

## Disclaimer

This is a **self-created portfolio project using simulated insurance data**. It is intended solely for educational and demonstration purposes and does not represent real company or client data.
