CREATE TABLE #Result
(
   Id uniqueidentifier
  ,SalesOrderId nvarchar(20)
  ,CustomerAccount nvarchar(20)
  ,CustomerEmail nvarchar(MAX)
)
INSERT #Result EXEC ProofEmail_GetEmailList 1, 0, 0
SELECT 
* 
FROM #Result
Go
DROP TABLE #Result
Go
