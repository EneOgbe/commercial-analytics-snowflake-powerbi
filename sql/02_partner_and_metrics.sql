-- 02_partner_and_metrics.sql
-- Purpose: Add partner channel attribution and commercial metrics for ROI analysis

USE DATABASE LOOKER_DEMO;
USE SCHEMA ANALYTICS;

-- Add partner channel (simulated partnerships attribution)
ALTER TABLE FACT_LOANS ADD COLUMN IF NOT EXISTS partner_channel STRING;

UPDATE FACT_LOANS
SET partner_channel =
  CASE
    WHEN purpose IN ('small_business', 'business') THEN 'Embedded Partner'
    WHEN purpose IN ('debt_consolidation', 'credit_card') THEN 'Comparison Site'
    WHEN purpose IN ('home_improvement', 'major_purchase') THEN 'Broker Network'
    ELSE 'Direct / Other'
  END;

-- Add commercial metrics
ALTER TABLE FACT_LOANS ADD COLUMN IF NOT EXISTS est_interest_revenue NUMBER(18,2);
ALTER TABLE FACT_LOANS ADD COLUMN IF NOT EXISTS commission_cost NUMBER(18,2);

UPDATE FACT_LOANS
SET
  est_interest_revenue = loan_amount * interest_rate,
  commission_cost =
    CASE
      WHEN partner_channel = 'Embedded Partner' THEN loan_amount * 0.025
      WHEN partner_channel = 'Comparison Site' THEN loan_amount * 0.030
      WHEN partner_channel = 'Broker Network' THEN loan_amount * 0.035
      ELSE loan_amount * 0.010
    END;

