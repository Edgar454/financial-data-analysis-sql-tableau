/*
=======================================================================================================
EDA 
=======================================================================================================
Our goals for our analysis is:

1) Segment the clients , differantiate the bad  (whom to watch carefully to minimize the bank loses)
 from the good (whom to offer more bank service/to target)

2) Improve their understanding of customers

3) Seek specific actions to improve services

There are 3 facts tables : the order table  , the transaction table and the loan table 

Purpose :
	- Explore the database and derive insights and leads that can be useful to analyze further
========================================================================================================
*/

-- Choose the database
USE FinancialDataAnalytics
GO

-- Number of overall clients
SELECT
    COUNT(client_id) as number_of_clients
FROM fin.client;

-- Age distribution of clients
WITH clients_ages AS (
    SELECT 
        client_id,
        DATEDIFF(YEAR, birth_date, GETDATE()) AS age
    FROM fin.client
), 
percentiles AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY age) OVER () AS Q1,
        PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY age) OVER () AS median_age,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY age) OVER () AS Q3
    FROM clients_ages
),
age_details AS (
    SELECT
        MIN(age) AS youngest_client,
        MAX(age) AS oldest_client,
        ROUND(AVG(age), 1) AS mean_age
    FROM clients_ages
)
SELECT
    a.youngest_client,
    p.Q1,
    p.median_age,
    a.mean_age,
    p.Q3,
    a.oldest_client
FROM age_details a
CROSS JOIN percentiles p;


-- What gender are our clients ?
SELECT
    gender,
    COUNT(client_id) as number_of_clients
FROM fin.client
GROUP BY gender;

-- Distribution of clients accross districts
SELECT DISTINCT 
    district_id ,
    COUNT(client_id) as number_of_clients
FROM fin.client
GROUP BY district_id
ORDER BY number_of_clients DESC;

-- How many accounts by clients ?
SELECT 
    c.client_id,
    c.gender,
    c.birth_date,
    d.type AS role, -- 'OWNER' or 'DISPONENT'
    a.account_id,
    a.date AS account_creation_date
FROM fin.client c
JOIN fin.disp d ON c.client_id = d.client_id
JOIN fin.account a ON d.account_id = a.account_id;

-- Distribution of accounts by the frequency of their checkings
SELECT
    frequency ,
    COUNT(account_id) as number_accounts
FROM fin.account
GROUP BY frequency;

-- How old are the accounts ?
WITH account_ages as (
SELECT 
    DATEDIFF(year, date , GETDATE()) AS longevity
FROM fin.account)
SELECT 
    AVG(longevity) as average_age ,
    MIN(longevity) as  most_recent ,
    MAX(longevity) as oldest
FROM account_ages;


-- How many users / owners do we have ?
SELECT
    type ,
    COUNT(disp_id) as count
FROM fin.disp 
GROUP BY type;

-- How many cards have been issued ?
SELECT 
    COUNT(card_id) as card_count
FROM fin.card;

-- Distribution of card type
SELECT 
    type,
    COUNT(card_id) as card_count
FROM fin.card
GROUP BY type;

-- Distribution of cards over districts
WITH client_card_details  AS (
SELECT 
    c.client_id,
    d.account_id,
    ca.card_id ,
    CASE 
        WHEN ca.card_id IS NOT NULL THEN 'card_owner'
        ELSE 'not_card_owner'
    END AS card_ownership 
FROM fin.client c
LEFT JOIN fin.disp d ON c.client_id = d.client_id
LEFT JOIN fin.card ca on ca.disp_id = d.disp_id
WHERE d.type = 'OWNER')
SELECT
    A2 as district_name ,
    card_ownership ,
    ROUND( 100.0 * count( DISTINCT c.account_id) / SUM(count( DISTINCT c.account_id)) OVER (PARTITION BY A2) , 2) as percent_of_accounts 
FROM client_card_details c
LEFT JOIN fin.account a on a.account_id = c.account_id
LEFT JOIN fin.district di on di.district_id = a.district_id
GROUP BY A2 , card_ownership
ORDER BY A2 , card_ownership ;



-- Number of transactions USER VS OWNER
SELECT 
    d.type,
    COUNT(t.trans_id) as card_count
FROM fin.disp d
JOIN fin.account a ON a.account_id = d.account_id
JOIN fin.trans t ON t.account_id = a.account_id
GROUP BY d.type;

-- Distribution of card types by unique activity counts
SELECT 
    c.type AS card_type,
    COUNT(DISTINCT c.card_id) AS number_of_cards,
    COUNT(DISTINCT t.trans_id) AS transaction_count,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT l.loan_id) AS loan_count,
    
    -- Normalized values (per card)
    1.0 * COUNT(DISTINCT t.trans_id) / COUNT(DISTINCT c.card_id) AS avg_transactions_per_card,
    1.0 * COUNT(DISTINCT o.order_id) / COUNT(DISTINCT c.card_id) AS avg_orders_per_card,
    1.0 * COUNT(DISTINCT l.loan_id) / COUNT(DISTINCT c.card_id) AS avg_loans_per_card
FROM fin.card c
JOIN fin.disp d ON c.disp_id = d.disp_id
JOIN fin.account a ON d.account_id = a.account_id
LEFT JOIN fin.trans t ON t.account_id = a.account_id
LEFT JOIN fin.[order] o ON o.account_id = a.account_id
LEFT JOIN fin.loan l ON l.account_id = a.account_id
GROUP BY c.type
ORDER BY c.type;




/* Orders */

-- popular order types 
SELECT
    k_symbol,
    COUNT(order_id) AS order_count ,
    AVG(amount) as average_amount
FROM fin.[order]
WHERE k_symbol IS NOT NULL AND k_symbol NOT IN ('', '""')
GROUP BY k_symbol;

-- accounts that makes the most order
SELECT
    account_id,
    COUNT(order_id) AS order_count
FROM fin.[order]
GROUP BY account_id
ORDER BY order_count DESC;

/* Transactions */

-- transaction  descriptive statistics
SELECT 
    COUNT(trans_id) AS total_number_of_transactions,
    MAX(amount) AS highest_amount_transferred,
    MIN(amount) AS lowest_amount_transferred,
    AVG(CAST(amount AS BIGINT)) AS average_amount_transferred
FROM fin.trans;

-- some transactions have a transferred amount of 0 , let's investigate that
SELECT 
    trans_id,
    account_id,
    [type],
    amount,
    balance 
FROM fin.trans
WHERE amount = 0;

-- Which accounts are most active by total transaction volume?
SELECT
    account_id,
    COUNT(trans_id) AS transaction_count
FROM fin.trans
GROUP BY account_id
ORDER BY transaction_count DESC;

-- Which accounts make the most withdrawals by total transaction volume?
SELECT
    account_id,
    COUNT(trans_id) AS transaction_count
FROM fin.trans
WHERE type = 'VYDAJ'
GROUP BY account_id
ORDER BY transaction_count DESC;

-- Which accounts make the most transactions that are not withdrawal ?
SELECT
    account_id,
    COUNT(trans_id) AS transaction_count
FROM fin.trans
WHERE type <> 'VYDAJ'
GROUP BY account_id
ORDER BY transaction_count DESC;

-- Trend of transactions throughout the year
SELECT
    FORMAT([date], 'yyyy-MM') AS transaction_month,
    COUNT(trans_id) as transaction_count ,
    AVG(amount) as average_amount 
    
FROM fin.trans
GROUP BY FORMAT([date], 'yyyy-MM') 
ORDER BY transaction_month;

-- Most common type of transaction by month
WITH monthly_operation_counts AS (
    SELECT
        FORMAT([date], 'yyyy-MM') AS transaction_month,
        [type],
        COUNT(*) AS type_count
    FROM fin.trans
    WHERE [type] IS NOT NULL
    GROUP BY FORMAT([date], 'yyyy-MM'), [type]
),
monthly_mode AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY transaction_month ORDER BY type_count DESC) AS rn
    FROM monthly_operation_counts
)
SELECT 
    transaction_month,
    [type] AS most_frequent_type,
    type_count
FROM monthly_mode
WHERE rn = 1
ORDER BY transaction_month;

-- Distribution of transactions by card type
SELECT
    c.type AS card_type,
    t.type AS transaction_type,
    COUNT(trans_id) AS transaction_count,
    100.0 * COUNT(trans_id) / SUM(COUNT(trans_id)) OVER (PARTITION BY c.type) AS percent_within_card_type
FROM fin.trans t
LEFT JOIN fin.disp d ON t.account_id = d.account_id
LEFT JOIN fin.card c ON c.disp_id = d.disp_id
WHERE c.type IS NOT NULL
GROUP BY c.type, t.type
ORDER BY c.type, transaction_count DESC;




--  Are there acount that transfer significantly more money than the median one ?  
-- Step 1: Sample the data for performance
WITH sample AS (
    SELECT 
        trans_id,
        account_id,
        account,
        amount
    FROM fin.trans
    TABLESAMPLE (1 PERCENT)
),

-- Step 2: Compute percentiles on the sample
percentiles AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount) OVER () AS Q1,
        PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY amount) OVER () AS median_amount,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount) OVER () AS Q3
    FROM sample
),

-- Step 3: Calculate bounds
quantile_metrics AS (
    SELECT
        Q1,
        Q3,
        median_amount,
        Q3 - Q1 AS IQR,
        Q1 - 1.5 * (Q3 - Q1) AS lower_bound,
        Q3 + 1.5 * (Q3 - Q1) AS upper_bound
    FROM percentiles
)

-- Step 4: Join bounds to the sample and filter
SELECT 
    s.trans_id,
    s.account_id,
    s.account,
    s.amount
FROM sample s
CROSS JOIN quantile_metrics q
WHERE s.account IS NOT NULL AND s.amount NOT BETWEEN q.lower_bound AND q.upper_bound
ORDER BY s.amount DESC



-- What are the most realized type of transactions  ?
SELECT 
    operation,
    100.0 * COUNT(trans_id) / SUM(COUNT(trans_id)) OVER () AS percent_operation
FROM fin.trans
WHERE operation is NOT NULL
GROUP BY operation 
ORDER BY percent_operation  ;

-- Bank of destination of the clients making the transactions the clients 
SELECT 
    bank,
    COUNT(trans_id) as total_count
FROM fin.trans
WHERE bank is NOT NULL
GROUP BY bank
ORDER BY total_count DESC;

-- Are there account that always debit / credit ?

WITH operation_percentages AS (
-- step 1 : find the percentages by operations
SELECT
  account_id , 
  operation,
  100.0 * COUNT(trans_id) / (SUM(COUNT(trans_id)) OVER (PARTITION BY account_id)) AS percent_operation
FROM fin.trans
WHERE operation is not NULL
GROUP BY account_id, operation ),

debit_percentages AS (
-- step 2 : Sum those percentages only for debit
SELECT
    account_id ,
    SUM(percent_operation)  as debit_percentage
FROM operation_percentages
WHERE operation = 'VYBER' OR  operation = 'PREVOD NA UCET' OR operation = 'VYBER KARTOU'
GROUP BY account_id
)
-- step 3 : filter 
SELECT
    *
FROM debit_percentages




    
/* loans */

-- Number of active loans
SELECT
    COUNT(loan_id) as active_loans
FROM fin.loan
WHERE [status] IN ('C','D');

-- Number of completed loans
SELECT
    COUNT(loan_id) as completed_loans
FROM fin.loan
WHERE [status] IN ('A','B');

-- Accounts that have contracted the more loans
SELECT
    account_id ,
    COUNT(loan_id) as number_of_loans
FROM fin.loan
GROUP BY account_id
ORDER BY number_of_loans DESC;

-- Number of loans not payed
SELECT
    COUNT(loan_id) as unpaid_loans
FROM fin.loan
WHERE [status] = 'B';

-- trend of loans over the time
SELECT
    FORMAT([date], 'yyyy-MM') AS loan_month,
    COUNT(loan_id) as loan_count ,
    AVG(amount) as average_amount 
    
FROM fin.loan
GROUP BY FORMAT([date], 'yyyy-MM') 
ORDER BY loan_month;

-- Distribution of loan_amounts by status
SELECT
    [status],
    AVG(amount) as average_amount,
    100.0 * COUNT(loan_id) / SUM(COUNT(loan_id)) OVER () AS percentage_of_loan
FROM fin.loan
GROUP BY [status]

-- Distribution of durations by status
SELECT
    [status],
    AVG(duration) as average_duration
FROM fin.loan
GROUP BY [status]



-- Distribution of durations by activity(number of transactions)
SELECT
    [status],
    AVG(t.amount) as avg_trans_amount,
    COUNT(trans_id) as transaction_count
FROM fin.loan l
LEFT JOIN fin.account a ON a.account_id = l.account_id
LEFT JOIN fin.trans t ON t.account_id = a.account_id
GROUP BY [status]

-- Distribution of durations by activity(number of order)
SELECT
    [status],
    AVG(o.amount) as avg_order_amount ,
    COUNT(order_id) as order_count
FROM fin.loan l
LEFT JOIN fin.account a ON a.account_id = l.account_id
LEFT JOIN fin.[order] o ON o.account_id = a.account_id
GROUP BY [status];


-- Distribution of status by card
WITH card_loan_data AS (
    SELECT 
        c.type AS card_type,
        l.status AS loan_status,
        c.card_id,
        l.loan_id,
        l.amount
    FROM fin.card c
    JOIN fin.disp d ON c.disp_id = d.disp_id
    JOIN fin.account a ON d.account_id = a.account_id
    LEFT JOIN fin.loan l ON l.account_id = a.account_id
)
SELECT
    loan_status,
    card_type,
    COUNT(DISTINCT card_id) AS number_of_cards,
    COUNT(DISTINCT loan_id) AS loan_count,
    AVG(amount) AS average_loan_amount,
    1.0 * COUNT(DISTINCT loan_id) / COUNT(DISTINCT card_id) AS avg_loans_per_card
FROM card_loan_data
GROUP BY loan_status, card_type
ORDER BY loan_status, card_type;


-- Distribution of status by gender
SELECT
    [status],
    c.gender , 
    COUNT(loan_id) as loan_count,
    AVG(l.amount) as average_amount
FROM fin.loan l
LEFT JOIN fin.account a ON a.account_id = l.account_id
LEFT JOIN fin.disp d ON d.account_id = a.account_id
LEFT JOIN fin.client c ON c.client_id = d.client_id
GROUP BY [status] , c.gender
ORDER BY [status] , c.gender;

-- Distribution of status by average_time_between_creation_and_loan
SELECT 
    [status],
    DATEDIFF(month, a.date, l.date) AS months_between_account_and_loan,
    COUNT(*) AS loan_count
FROM fin.loan l
JOIN fin.account a ON l.account_id = a.account_id
GROUP BY [status], DATEDIFF(month, a.date, l.date)
ORDER BY [status], months_between_account_and_loan;



-- Distribution of status by group of ages
-- Since the younger client is 38 we will group client according to their situation less than 60 is active and more is retired
WITH age_data AS (
    SELECT
        client_id ,
        CASE 
            WHEN DATEDIFF(YEAR, birth_date, GETDATE()) < 60 then  'active'
            ELSE 'retired'
        END age_group
    FROM fin.client)

SELECT
    [status],
    age_group,
    COUNT(loan_id) as loan_count,
    AVG(l.amount) as average_amount
FROM fin.loan l
LEFT JOIN fin.account a ON a.account_id = l.account_id
LEFT JOIN fin.disp d ON d.account_id = a.account_id
LEFT JOIN age_data c ON c.client_id = d.client_id
GROUP BY [status] , age_group
ORDER BY [status] , age_group;

-- Behavior of accounts that contracted a loan before and after the loan
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
        COUNT(trans_id) as prv_trans_count ,
        AVG(t.amount) as prv_avg_trans_amount 
    FROM date_infos d
    LEFT JOIN fin.trans t
    ON t.account_id = d.account_id AND t.[date] BETWEEN before_date AND loan_date
    GROUP BY d.account_id) ,
-- step 3 calculate the number of transactions and average amount of those transaction after the loan
    after_metrics AS(
    SELECT
        d.account_id ,
        COUNT(trans_id) as aft_trans_count ,
        AVG(t.amount) as aft_avg_trans_amount 
    FROM date_infos d
    LEFT JOIN fin.trans t
    ON t.account_id = d.account_id AND t.[date] BETWEEN loan_date AND after_date
    GROUP BY d.account_id
    ), 

-- step 4 compare the before and after loan
    client_behavior AS (
        SELECT
            a.account_id,
            CASE 
                WHEN (a.aft_avg_trans_amount/p.prv_avg_trans_amount) BETWEEN 0.9 AND 1.1 THEN 'no_change'
                WHEN (a.aft_avg_trans_amount/p.prv_avg_trans_amount) > 1.1 THEN 'increased_amount_transfered'
                WHEN (a.aft_avg_trans_amount/p.prv_avg_trans_amount) < 0.9 THEN 'decreased_amount_transfered'
            END AS amount_behavior,

            CASE 
                WHEN (a.aft_trans_count/p.prv_trans_count) BETWEEN 0.9 AND 1.1 THEN 'no_change'
                WHEN (a.aft_trans_count/p.prv_trans_count) > 1.1 THEN 'increased_number_of_transaction'
                WHEN (a.aft_trans_count/p.prv_trans_count) < 0.9 THEN 'decreased_number_of_transaction'
            END AS count_behavior
         
        FROM previous_metrics p
        JOIN after_metrics a on p.account_id = a.account_id

    )
-- step 5 aggregate over the loan status to see the impact of customer behavior on loan repayment
    SELECT 
        l.[status],
        b.amount_behavior ,
        100.0 * COUNT(loan_id) / ( SUM(COUNT(loan_id)) OVER (PARTITION BY [status]) ) AS loan_count,
        AVG(l.amount) AS avg_loan_amount
    FROM fin.loan l
    LEFT JOIN client_behavior b ON b.account_id = l.account_id
    GROUP BY [status] , b.amount_behavior 
    ORDER BY [status] , b.amount_behavior;


  


-- Distribution of status by other demographics infos

-- By district
WITH loan_by_status_district AS (
    SELECT
        l.status,
        d.A2 AS district_name,
        COUNT(l.loan_id) AS loan_count,
        AVG(l.amount) AS avg_loan_amount,
        AVG(d.A11) AS avg_district_salary
    FROM fin.loan l
    LEFT JOIN fin.account a ON l.account_id = a.account_id
    LEFT JOIN fin.district d ON a.district_id = d.district_id
    GROUP BY l.status, d.A2
)
SELECT 
    *,
    100.0 * loan_count / SUM(loan_count) OVER (PARTITION BY status) AS percent_within_status
FROM loan_by_status_district
ORDER BY status, district_name;



-- By region
SELECT
    [status],
    d.A3 as region,
    COUNT(loan_id) AS loan_count,
    AVG(l.amount) AS avg_loan_amount,
    AVG(d.A11) AS avg_district_salary
FROM fin.loan l
LEFT JOIN fin.account a ON a.account_id = l.account_id
LEFT JOIN fin.district d ON d.district_id = a.district_id
GROUP BY [status] , d.A3 
ORDER BY [status] , d.A3 ;



-- By Average district salary  of the region
EXEC    [dbo].[GetLoanStatsByDistrictField]
		@field = A11,
        @label = district_salary;


-- By Average district salary  of no of inhabitants
EXEC    [dbo].[GetLoanStatsByDistrictField]
		@field = A4,
        @label = no_of_inhabitants;


-- By Average no of cities
EXEC    [dbo].[GetLoanStatsByDistrictField]
		@field = A9,
        @label = no_of_cities;

-- By Average ratio of urban habitants
EXEC    [dbo].[GetLoanStatsByDistrictField]
		@field = A10,
        @label = ratio_of_urban_habitants;


-- By Average unemployment rate
EXEC    [dbo].[GetLoanStatsByDistrictField]
		@field = A12,
        @label = unemployment_rate;


-- By Average criminality (number of committed crimes)
EXEC    [dbo].[GetLoanStatsByDistrictField]
		@field = A16,
        @label = no_crimes;


-- By Average percentage of entrepreneurs for 1000 hbts
EXEC    [dbo].[GetLoanStatsByDistrictField]
		@field = A14,
        @label = entrepreneurs;

/* Client Segmentation */

-- Do clients with credit card make more transactions ? 
WITH client_card_details  AS (
SELECT 
    c.client_id,
    d.account_id,
    ca.card_id ,
    CASE 
        WHEN ca.card_id IS NOT NULL THEN 'card_owner'
        ELSE 'not_card_owner'
    END AS card_ownership 
FROM fin.client c
LEFT JOIN fin.disp d ON c.client_id = d.client_id
LEFT JOIN fin.card ca on ca.disp_id = d.disp_id
WHERE d.type = 'OWNER')

SELECT 
    card_ownership,
    AVG( CAST(t.amount AS BIGINT) ) as avg_transaction_amount,
    COUNT(t.trans_id) / COUNT(DISTINCT c.account_id )   as transaction_per_account
FROM client_card_details c
LEFT JOIN fin.trans t ON  c.account_id = t.account_id
GROUP BY card_ownership ;



-- Do people in certain districts favor certain type of transaction ?
SELECT
    A2 as district_name , 
    operation as transaction_type ,
    ROUND( 100.0 * COUNT(trans_id) / SUM (COUNT(trans_id)) OVER (PARTITION BY A2) , 2) as transaction_count
FROM fin.district di
LEFT JOIN fin.account  a on a.district_id = di.district_id
LEFT JOIN fin.trans t on t.account_id = a.account_id
WHERE operation is NOT NULL
GROUP BY A2 , operation
ORDER BY A2 , operation