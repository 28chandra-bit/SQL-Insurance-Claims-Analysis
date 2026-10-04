# Data Dictionary

## customers

| Column | Type | Description |
|---|---|---|
| customer_id | INT | Unique customer identifier |
| customer_name | VARCHAR | Synthetic customer name |
| email | VARCHAR | Synthetic email |
| gender | VARCHAR | Synthetic gender value |
| date_of_birth | DATE | Synthetic date of birth |
| state | CHAR(2) | Synthetic US state code |

## policies

| Column | Type | Description |
|---|---|---|
| policy_id | INT | Unique policy identifier |
| customer_id | INT | Foreign key to customers |
| policy_number | VARCHAR | Synthetic policy number |
| policy_type | VARCHAR | Health, Dental, Vision, Life or Disability |
| start_date | DATE | Policy start date |
| policy_status | VARCHAR | Active, Expired or Cancelled |
| annual_premium | DECIMAL | Synthetic annual premium |

## claims

| Column | Type | Description |
|---|---|---|
| claim_id | INT | Unique claim identifier |
| policy_id | INT | Foreign key to policies |
| customer_id | INT | Foreign key to customers |
| claim_number | VARCHAR | Synthetic claim number |
| claim_date | DATE | Claim date |
| claim_type | VARCHAR | Synthetic claim category |
| claim_status | VARCHAR | Claim processing status |
| claim_amount | DECIMAL | Requested claim amount |
| settled_amount | DECIMAL | Amount marked as settled |

## payments

| Column | Type | Description |
|---|---|---|
| payment_id | INT | Unique payment identifier |
| claim_id | INT | Foreign key to claims |
| payment_reference | VARCHAR | Synthetic payment reference |
| payment_amount | DECIMAL | Payment amount |
| payment_date | DATE | Payment date |
| payment_status | VARCHAR | Payment status |
