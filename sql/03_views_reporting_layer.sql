-- 03_views_reporting_layer.sql
-- Purpose: Create reusable reporting views for BI (Power BI now, Looker later)

USE DATABASE LOOKER_DEMO;
USE SCHEMA ANALYTICS;

-- Partner performance view (monthly)
CREATE OR REPLACE VIEW VW_PARTNER_PERFORMANCE AS
SELECT
  DATE_TRUNC('month', issue_date) AS month,
  partner_channel,

  COUNT(*) AS loans,

  -- Risk
  AVG(default_flag) AS default_rate,

  -- Commercial totals
  SUM(loan_amount) AS total_loan_amount,
  SUM(est_interest_revenue) AS est_revenue,
  SUM(commission_cost) AS partner_cost,
  SUM(est_interest_revenue) - SUM(commission_cost) AS est_margin,

  -- ROI (margin / cost)
  CASE
    WHEN SUM(commission_cost) = 0 THEN NULL
    ELSE (SUM(est_interest_revenue) - SUM(commission_cost)) / SUM(commission_cost)
  END AS roi

FROM FACT_LOANS
GROUP BY 1, 2;

-- Funnel / quality view (monthly)
CREATE OR REPLACE VIEW VW_PARTNER_FUNNEL AS
SELECT
  DATE_TRUNC('month', issue_date) AS month,
  partner_channel,

  COUNT(*) AS funded_loans,
  SUM(CASE WHEN performing_flag = 1 THEN 1 ELSE 0 END) AS performing_loans,
  SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS defaulted_loans,

  AVG(interest_rate) AS avg_interest_rate,
  AVG(loan_amount) AS avg_loan_amount

FROM FACT_LOANS
GROUP BY 1, 2;

