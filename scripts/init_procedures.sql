USE FinancialDataAnalytics ;
GO

-- Define a procedure to aclaculate statistics by districs infos
CREATE PROCEDURE GetLoanStatsByDistrictField
    @field NVARCHAR(50), 
    @label NVARCHAR(50) 
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    SET @sql = '
        SELECT 
            l.status,
            COUNT(*) AS loan_count,
            AVG(d.' + QUOTENAME(@field) + ') AS avg_' + @label + ' ,
            AVG(l.amount) AS avg_loan_amount
        FROM fin.loan l
        LEFT JOIN fin.account a ON l.account_id = a.account_id
        LEFT JOIN fin.district d ON a.district_id = d.district_id
        GROUP BY l.status
    '
    EXEC sp_executesql @sql
END
GO