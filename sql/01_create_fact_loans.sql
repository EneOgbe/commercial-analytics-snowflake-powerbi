-- 01_create_fact_loans.sql
-- Purpose: Create a clean loan-level fact table for partnership ROI analysis
-- Grain: One row per funded loan
-- Source: lending_club_raw (loaded from a sampled Lending Club dataset)

USE DATABASE LOOKER_DEMO;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE TABLE FACT_LOANS AS
SELECT
  TRY_TO_NUMBER(TO_VARCHAR(id)) AS loan_id,

  -- issue_d appears as MON-YY in the dataset (e.g., Dec-15)
  TRY_TO_DATE(
    '01-' || TO_VARCHAR(issue_d),
    'DD-MON-YY'
  ) AS issue_date,

  TRY_TO_NUMBER(TO_VARCHAR(loan_amnt)) AS loan_amount,
  TRY_TO_NUMBER(REPLACE(TO_VARCHAR(int_rate), '%', '')) / 100 AS interest_rate,

  TO_VARCHAR(term) AS term,
  TO_VARCHAR(grade) AS grade,
  TO_VARCHAR(purpose) AS purpose,
  TO_VARCHAR(loan_status) AS loan_status,

  TRY_TO_NUMBER(TO_VARCHAR(annual_inc)) AS annual_income,
  TO_VARCHAR(addr_state) AS state,
  TRY_TO_NUMBER(TO_VARCHAR(dti)) AS dti,

  CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 ELSE 0 END AS performing_flag,
  CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END AS default_flag

FROM LENDING_CLUB_RAW
WHERE issue_d IS NOT NULL;

