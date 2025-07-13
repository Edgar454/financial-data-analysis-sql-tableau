/*
=======================================================================================================
Financial Client Analytics Views Creation Script
=======================================================================================================

Purpose:
--------
This script creates a set of SQL views to support a Tableau dashboard for the bank’s
financial client dataset. The views aim to provide summarized, ready-to-use data aligned
with the key business objectives:

1) Client Segmentation:
   - Provide comprehensive profiles differentiating clients with good vs. risky loan behaviors.
   - Include demographics, account/card ownership, loan status, and activity metrics.

2) Customer Understanding:
   - Summarize client demographics, account longevity, and geographic distribution.
   - Detail transaction and card usage patterns.

3) Actionable Insights:
   - Highlight loan performance variations across demographics and districts.
   - Capture behavioral changes pre- and post-loan issuance.
   - Facilitate identification of clients for targeted marketing or risk management.

Views Included:
---------------
- vw_ClientProfiles: combines client demographics, account info, card ownership, loan status, and activity metrics.
- vw_DemographicsSummary: aggregates clients by age group, gender, district, and card ownership.
- vw_LoanPortfolio: summarizes loans by status, amount, duration, and district socioeconomic factors.
- vw_TransactionSummary: aggregates transaction counts, amounts, types, and monthly trends per client/account.
- vw_CardUsageStats: details card issuance and usage statistics by type and geography.
- vw_BehavioralChange: compares transaction activity before and after loan issuance to flag significant behavior shifts.

=======================================================================================================
*/
