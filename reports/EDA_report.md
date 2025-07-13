# Overview of the database

The PKDD'99 dataset is composed of eight tables originating from a Czech bank aiming to enhance its financial services and gain a deeper understanding of its customers. Specifically, the bank seeks to:

* Distinguish between good clients (those to whom additional services may be offered) and bad clients (those who should be monitored to minimize financial risk).
* Improve its overall understanding of customer behavior and profiles.
* Identify actionable insights to enhance service quality.

Before proceeding with the analysis, it is essential to define what constitutes a "good" client. In this context, a good client is someone who reliably repays loans and actively uses the bank’s services.

The eight tables included in the dataset are:

* account (4,500 entries; ACCOUNT.ASC): Contains static characteristics of each account.
* client (5,369 entries; CLIENT.ASC): Describes individual client characteristics.
* disposition (5,369 entries; DISP.ASC): Links clients to accounts, indicating the type of access a client has to a given account.
* permanent order (6,471 entries; ORDER.ASC): Contains details about scheduled payment orders.
* transaction (1,056,320 entries; TRANS.ASC): Logs individual account transactions.
* loan (682 entries; LOAN.ASC): Describes loans granted to accounts.
* card (892 entries; CARD.ASC): Provides information on credit cards issued to accounts.
* district (77 entries; DISTRICT.ASC): Includes demographic information about various districts.

# Descriptive Statistics
The database contains 5,369 clients, with an almost even distribution between men and women. Clients' ages range from 38 to 114 years, with an average age of approximately 71.

The districts with the highest number of clients are:
* **District 1**: 663 clients
* **District 74**: 180 clients
* **District 70**: 169 clients

Out of the 5,369 clients, 4,500 are account owners, while the remaining 869 are authorized users (disponents) without ownership.
There are 4,500 accounts (one per owner), and the duration since their creation ranges from 28 to 32 years. The majority of account holders (4,167) receive monthly account summaries.
Among these accounts, only 892 are linked to a credit card:
* **659** have a **Classic** card
* **145** have a **Junior** card
* **88** have a **Gold** card

On average, **Gold card holders** are the most active in terms of transactions per card, and they rank second in both the number of permanent orders per card and loans per card. **Classic card holders** follow, having the second highest number of transactions and the highest number of orders and loans (though the lead is slight). **Junior card holders** are consistently the least active across all metrics.

# Services specific details

## Orders
A total of 6,471 permanent orders were recorded in the dataset. These are distributed across the following categories:
* **3,502** for household payments
* **717** for loan payments
* **512** for insurance payments
* **341** for leasing payments

Most accounts have set up only one or two permanent orders. The maximum number of orders recorded for a single client is five.
Despite their smaller volume, loan payments have the highest average amount per order, while household payments have the lowest.

## Transactions
A total of 1.05 million transactions were recorded in the dataset. The maximum amount transferred was €87,400, while the minimum was €0. These zero-value transactions appear to correspond to failed or canceled operations, most commonly unsuccessful withdrawals. The average transaction amount was €5,971.

### Most Active Accounts by Volume
The accounts with the highest number of transactions are:
* Account 8261: 675 transactions
* Account 3834: 665 transactions
* Account 96: 661 transactions

When broken down by transaction type:
- Most withdrawals:
    * Account 3834: 507 withdrawals
    * Account 5215: 496 withdrawals
    * Account 96: 479 withdrawals

- Most debit operations:
    * Account 9307: 300 operations
    * Account 9203: 299 operations
    * Account 9707: 296 operations

### Seasonal Trends and High Spenders
December and January typically show the highest volume of transactions across all accounts. Accounts 404 and 3444 stand out for frequent high-value transfers, spending significantly more than the average client.

### Transaction Types
The distribution of transaction types is as follows:
* Cash withdrawals: 49.81%
* Remittances to other banks: 23.85%
* Cash credits: 17.95%
* Collections from other banks: 7.47%
* Credit card withdrawals: 0.92%

### Most Frequent Recipient Banks
The banks that received the highest number of transactions are:
* EF: 21,293 transactions
* KL: 21,234 transactions
* UV: 21,167 transactions
 

## Loans
There are 682 loans recorded in the dataset. Among them:
- 448 are currently active
- 234 have been completed, of which:
    * 31 were unsuccessfully completed (i.e., unpaid)

Each account in the dataset has taken out at most one loan during the observed period.
Loan activity is slightly higher at the beginning of the year (January) and mid-year (June/July), suggesting two seasonal peaks in loan applications.

### Repayment Overview
* **90%** of all loans are either fully repaid or are currently being paid normally.
* **10%** are either defaulted or not meeting their monthly payments.

Loan amount appears to be a significant factor in repayment behavior:
* The average amount for unpaid finished loans is €140,720, which is substantially higher than the €91,641 average for successfully repaid loans.
* Similarly, struggling loans (still active but not meeting payments) have an average amount of €249,284, compared to €171,400 for healthy active loans.
This suggests that larger loans are more likely to be unpaid or enter a struggling status, indicating a higher risk associated with granting high-value loans.

Also accounts with unpaid or struggling loans (statuses B and D) tend to have been created more recently compared to those with successfully repaid or currently healthy loans (statuses A and C). This suggests that issuing loans to newer accounts may carry a higher repayment risk, possibly due to limited historical data on client behavior.

Accounts that repay their loans tend to exhibit higher activity (more transactions and orders), though not necessarily higher monetary amounts. Loan repayment patterns do not appear to correlate strongly with:
* Client gender
* Client age
* Loan duration
* Credit card ownership/type

### Influence of District
District appears to have a significant influence on loan repayment behavior:
* For successfully repaid loans, the distribution is broad and relatively even across districts.
* For unpaid or defaulted loans, the distribution is concentrated in a few districts, indicating potential regional risk factors.

For instance, the Strakonice district:
* Accounts for 3.5% of all unpaid loans
* 7% of loans in arrears (struggling loans)
* Yet only 0.49% of repaid loans and 0.49% of healthy loans

This suggests certain districts may be inherently riskier, potentially due to:
* Socioeconomic conditions
* Regional economic performance
* Local banking policies

### Socioeconomic Factors
When analyzing loan performance by district-level features:
* **Average salary**: Districts with **higher average salaries** tend to have better loan repayment rates.
* **Population size**: Larger districts (more inhabitants) are associated with better repayment outcomes — likely because larger cities offer more stable employment and services.
* **Crime rate**: Surprisingly, districts with higher reported crime rates show slightly better repayment, though this is likely an artifact of urbanization — bigger cities both report more crimes and have stronger financial ecosystems.

# Summary
This analysis aimed to differentiate good and bad clients, improve customer understanding, and identify actionable insights to enhance banking services. The key findings are:
- Clients who reliably repay loans (“good” clients) tend to have lower loan amounts and older account ages compared to those with repayment difficulties.
- Loan repayment risk increases with larger loan amounts and when loans are issued to newer accounts.
- Client gender, age, loan duration, and credit card ownership have little impact on repayment behavior.
- District-level factors such as average salary and population size significantly influence loan repayment rates, highlighting regional risk differences.
- Customer activity patterns (transactions, orders) are generally higher among good clients, supporting targeted engagement strategies.
- These insights can help the bank better segment customers, tailor service offers, and focus risk management efforts on higher-risk profiles and regions.