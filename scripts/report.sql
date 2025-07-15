/*
=======================================================================================================
SQL View Creation Script – Financial Client Analytics
=======================================================================================================

Overview:
---------
This script defines a suite of SQL views to support a Tableau dashboard for exploring and analyzing
a bank’s client financial behavior. These views transform raw transactional and demographic data into
structured summaries tailored for business analysis.

Objectives:
-----------
1) Client Segmentation:
   - Build detailed client profiles with demographics, account/card status, loan behavior, and engagement.
   - Distinguish clients based on loan risk and recent activity.

2) Customer Insight:
   - Aggregate client attributes by age group, gender, and district.
   - Analyze account longevity, transaction patterns, and card usage.

3) Strategic Decision Support:
   - Examine loan distribution and repayment trends across socioeconomic groups.
   - Detect behavioral changes before and after loan issuance.
   - Enable data-driven targeting for marketing and risk management.

Views Created:
--------------
- vw_ClientProfiles:
    Merges demographics, account info, loan details, activity metrics, and churn labels per client.

- vw_DemographicsSummary:
    Aggregates clients by gender, age group (retired/active), district, and card ownership.

- vw_LoanStatusOverTime:
    Tracks monthly loan issuance volumes and average amounts by status.

- vw_LoanAmountsByStatus:
    Summarizes loan amounts and frequency grouped by repayment status.

- vw_LoanStatsByDistrict:
    Analyzes loan distributions by district and includes average local salary.

- vw_TransactionTypesByMonth:
    Breaks down transaction operations over time (monthly trend by operation type).

- vw_CardUsageByDistrict:
    Measures card adoption, usage, and transaction behavior by district and card type.

- vw_BehavioralChange:
    Compares client transaction behavior 6 months before and after loan issuance to detect shifts.

Dependencies:
-------------
- Assumes access to core tables: client, account, disp, card, loan, trans, district, order (in schema `fin`).

=======================================================================================================
*/


-- Choose the database
USE FinancialDataAnalytics
GO

-- Create the client View
CREATE VIEW vw_ClientProfiles AS
WITH client_details AS (
    SELECT 
        c.client_id,
        DATEDIFF(year, c.birth_date, GETDATE()) AS client_age,
        c.gender,
        c.district_id,
        d.account_id,
        DATEDIFF(year, a.date, GETDATE()) AS account_age,
        ca.card_id,
        CASE 
            WHEN ca.card_id IS NOT NULL THEN 'card_owner'
            ELSE 'not_card_owner'
        END AS card_ownership,
        ca.type AS card_type
    FROM fin.client c
    LEFT JOIN fin.disp d ON c.client_id = d.client_id
    LEFT JOIN fin.card ca ON ca.disp_id = d.disp_id
    LEFT JOIN fin.account a ON a.account_id = d.account_id
) , loan_details AS (
    SELECT
        a.account_id,
        AVG(l.amount) as avg_loan_amount,
        COUNT(l.loan_id) as loan_count 
    FROM fin.account a
    LEFT JOIN fin.loan l ON l.account_id = a.account_id
    GROUP BY  a.account_id
) , loan_status AS (
    SELECT
        a.account_id,
        CASE
            WHEN l.status IN ('A','C') THEN 'good'
            WHEN l.status IN ('B','D') THEN 'bad'
            ELSE 'undefined'
        END AS loan_status
    FROM fin.account a
    LEFT JOIN fin.loan l ON l.account_id = a.account_id
), activity_metrics AS (
    SELECT
        a.account_id,
        AVG(t.amount) as avg_trans_amount ,
        COUNT(t.trans_id) as transaction_count,
        AVG(o.amount) as avg_order_amount ,
        COUNT(o.order_id) as order_count
    FROM fin.account a
    LEFT JOIN fin.trans t ON t.account_id = a.account_id
    LEFT JOIN fin.[order] o ON o.account_id = a.account_id
    GROUP BY a.account_id
) , recent_activity_window AS (
    SELECT
        a.account_id,
        DATEADD(month, -2, MAX(t.date)) AS activity_cutoff_date
    FROM fin.account a
    LEFT JOIN fin.trans t ON a.account_id = t.account_id
    GROUP BY a.account_id
),

transaction_behavior_labels AS (
    SELECT
        raw_window.account_id,
        COUNT(t.trans_id) AS transaction_count_last_2_months,
        CASE 
            WHEN COUNT(t.trans_id) = 0 THEN 'churned'
            WHEN COUNT(t.trans_id) BETWEEN 1 AND 20 THEN 'at_risk'
            ELSE 'active'
        END AS churn_flag
    FROM recent_activity_window raw_window
    LEFT JOIN fin.trans t 
        ON raw_window.account_id = t.account_id 
        AND t.date >= raw_window.activity_cutoff_date
    GROUP BY raw_window.account_id
)
SELECT 
    c.client_id,
    c.client_age,
    c.gender,
    c.district_id,
    l.account_id,
    c.account_age,
    c.card_id,
    c.card_ownership,
    c.card_type,
    avg_loan_amount,
    l.loan_count , 
    ls.loan_status ,
    m.avg_trans_amount ,
    m.transaction_count ,
    m.avg_order_amount ,
    m.order_count,
    tbl.transaction_count_last_2_months,
    tbl.churn_flag
FROM client_details c
LEFT JOIN loan_details l ON l.account_id = c.account_id
LEFT JOIN loan_status ls ON ls.account_id = c.account_id
LEFT JOIN activity_metrics m ON m.account_id = c.account_id
LEFT JOIN transaction_behavior_labels tbl ON tbl.account_id = c.account_id;
GO

CREATE VIEW vw_DemographicsSummary AS
WITH base AS (
    SELECT 
        c.client_id,
        c.gender,
        c.district_id,
        d.account_id,
        DATEDIFF(year, c.birth_date, GETDATE()) AS client_age,
        DATEDIFF(year, a.date, GETDATE()) AS account_age,
        ca.card_id
    FROM fin.client c
    LEFT JOIN fin.disp d ON c.client_id = d.client_id
    LEFT JOIN fin.account a ON a.account_id = d.account_id
    LEFT JOIN fin.card ca ON ca.disp_id = d.disp_id
    WHERE d.type = 'OWNER'
),
labeled AS (
    SELECT 
        b.client_id,
        b.gender,
        b.district_id,
        b.account_id,
        b.client_age,
        b.account_age,
        b.card_id,
        CASE 
            WHEN DATEDIFF(YEAR, birth_date, GETDATE()) < 60 THEN 'active'
            ELSE 'retired'
        END AS age_group
    FROM fin.client c
    JOIN base b ON c.client_id = b.client_id
)
SELECT
    gender,
    age_group,
    district_id,
    COUNT(DISTINCT client_id) AS client_count,
    ROUND(AVG(account_age), 1) AS avg_account_age,
    ROUND(100.0 * COUNT(card_id) / COUNT(DISTINCT client_id), 2) AS card_ownership_rate
FROM labeled
GROUP BY gender, age_group, district_id;
GO

CREATE VIEW vw_LoanStatusOverTime AS
SELECT
    FORMAT(l.[date], 'yyyy-MM') AS loan_month,
    [status],
    AVG(amount) as avg_loan_amount,
    COUNT(loan_id) as loan_count
FROM fin.loan l
LEFT JOIN fin.account a ON a.account_id = l.account_id
GROUP BY FORMAT(l.[date], 'yyyy-MM') ,[status]
GO

CREATE VIEW vw_LoanAmountsByStatus AS
SELECT
    [status],
    AVG(amount) as avg_loan_amount,
    COUNT(loan_id) as loan_count
FROM fin.loan l
LEFT JOIN fin.account a ON a.account_id = l.account_id
GROUP BY [status]
GO

CREATE VIEW vw_LoanStatsByDistrict AS
SELECT
    di.district_id ,
    A2 as district_name,
    [status],
    AVG(amount) as avg_loan_amount,
    COUNT(loan_id) as loan_count ,
    AVG(A11) as avg_district_salary
FROM  fin.district di
LEFT JOIN fin.account a ON  di.district_id = a.district_id
LEFT JOIN fin.loan l ON a.account_id = l.account_id
GROUP BY di.district_id , A2 ,[status]
GO

CREATE VIEW vw_TransactionTypesByMonth AS
SELECT
    FORMAT([date], 'yyyy-MM') AS transaction_month,
    operation,
    AVG(amount) as avg_loan_amount
FROM fin.trans t
GROUP BY FORMAT([date], 'yyyy-MM') , operation
GO

CREATE VIEW vw_CardUsageByDistrict AS
WITH client_card_details  AS (
SELECT 
    c.client_id,
    d.account_id,
    ca.card_id ,
    ca.type as card_type,
    CASE 
        WHEN ca.card_id IS NOT NULL THEN 'card_owner'
        ELSE 'not_card_owner'
    END AS card_ownership 
FROM fin.client c
LEFT JOIN fin.disp d ON c.client_id = d.client_id
LEFT JOIN fin.card ca on ca.disp_id = d.disp_id
WHERE d.type = 'OWNER')

SELECT
    di.district_id,
    di.A2 AS district_name,
    cc.card_type,
    COUNT(t.trans_id) AS transaction_count,
    100.0 * COUNT(t.trans_id) / SUM(COUNT(t.trans_id)) OVER(PARTITION BY di.district_id) AS pct_of_district_transactions
FROM fin.district di
LEFT JOIN fin.account a ON a.district_id = di.district_id
LEFT JOIN client_card_details cc ON cc.account_id = a.account_id
LEFT JOIN fin.trans t ON t.account_id = a.account_id
GROUP BY di.district_id, di.A2, cc.card_type;
GO

CREATE VIEW vw_BehavioralChange AS
WITH date_infos AS (
-- step 1 : Calculate the cutoff dates before and after (6 months)
    SELECT
        loan_id ,
        account_id ,
        DATEADD(month , -6 , date) as before_date,
        DATEADD(month , 6 , date) as after_date,
        [date] as loan_date
    FROM fin.loan
),
-- step 2 calculate the number of transactions and average amount of those transaction before the loan
previous_metrics AS (
    SELECT
        d.account_id ,
        d.loan_id,
        COUNT(trans_id) as prv_trans_count ,
        AVG(t.amount) as prv_avg_trans_amount 
    FROM date_infos d
    LEFT JOIN fin.trans t
    ON t.account_id = d.account_id AND t.[date] BETWEEN before_date AND loan_date
    GROUP BY d.account_id ,  d.loan_id) ,
-- step 3 calculate the number of transactions and average amount of those transaction after the loan
    after_metrics AS(
    SELECT
        d.account_id ,
         d.loan_id,
        COUNT(trans_id) as aft_trans_count ,
        AVG(t.amount) as aft_avg_trans_amount 
    FROM date_infos d
    LEFT JOIN fin.trans t
    ON t.account_id = d.account_id AND t.[date] BETWEEN loan_date AND after_date
    GROUP BY d.account_id ,  d.loan_id
    )
SELECT
    p.account_id,
    p.loan_id,
    p.prv_avg_trans_amount,
    a.aft_avg_trans_amount,
    p.prv_trans_count,
    a.aft_trans_count,
    CASE 
        WHEN p.prv_avg_trans_amount = 0 THEN 'undefined'
        WHEN (a.aft_avg_trans_amount / p.prv_avg_trans_amount) BETWEEN 0.9 AND 1.1 THEN 'no significant change'
        WHEN (a.aft_avg_trans_amount / p.prv_avg_trans_amount) > 1.1 THEN 'increased average amount'
        WHEN (a.aft_avg_trans_amount / p.prv_avg_trans_amount) < 0.9 THEN 'decreased average amount'
    END AS avg_transaction_behavior

FROM previous_metrics p
JOIN after_metrics a on p.account_id = a.account_id
GO


