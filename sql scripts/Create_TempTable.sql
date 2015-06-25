----------------------------------------------------------------
----1.  
---     FIX SetCustomerPaymentTotalByLine Stored Procedure
----	to respect FEP_DRPAY_Line.Deleted
----    and set Updated Date
----------------------------------------------------------------

----------------------------------------------------------------
----CREATE PROCEDURE [SetCustomerPaymentTotalByLine]
----------------------------------------------------------------
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE ([object_id] = OBJECT_ID('SetCustomerPaymentTotalByLine')) AND ([type] in (N'P', N'PC')))
BEGIN
	PRINT 'Dropping Procedure [dbo].[SetCustomerPaymentTotalByLine]';
	DROP PROCEDURE [dbo].[SetCustomerPaymentTotalByLine];
END;
GO

PRINT 'Creating Procedure: [dbo].[ProofEmail_GetEmailList]';
GO


CREATE PROCEDURE [dbo].[SetCustomerPaymentTotalByLine]
  @Id uniqueidentifier, --HEADERID
  @SetTotal bit = 1
AS
BEGIN



  SET NOCOUNT ON
  
  DECLARE @StatusId integer  
  DECLARE @SubTotal money
  DECLARE @TaxTotal money
  DECLARE @TranTotal money

  SELECT @SubTotal	  = SUM(SubTotal),
         @TaxTotal	  = SUM(TaxTotal),
         @TranTotal	  = SUM(TranTotal)
  FROM FEP_DRPAY_Line
  WHERE DRPAYHdrId = @Id
  AND DELETED = 0
  
  IF @SetTotal = 1
	BEGIN
		UPDATE FEP_DRPAY_Hdr 
		SET SubTotal = @SubTotal, 
			TaxTotal = @TaxTotal, 
			TranTotal = @TranTotal,
			UpdatedDate = GetDate()
		WHERE Id = @Id
	END
  
  SELECT @SubTotal, @TaxTotal, @TranTotal
END
GO

----------------------------------------------------------------
----2.  
---     REVIEW 
----	Details 
----    and Summary
----------------------------------------------------------------
-----------------------------------------------------
--REVIEW DATA DETAIL AND SUMMARY
-----------------------------------------------------
DECLARE @Userid UniqueIdentifier = (Select top 1 ID From FEP_User where Username like 'SARGENTR.jaradmin%')


-- Detail
Select
	cust.LegalName,	
	hdr.PaymentReference as 'HdrPaymentReference',
	hdr.PaymentNo as 'HdrPaymentNo',
	lin.InvoiceNo as 'LineInvoiceNo', 
	lin.HostRef as 'LineHostRef', 
	lin.CreatedDate as 'LineCD', 
	lin.UpdatedDate as 'LineUD',
	lin.TranTotal as 'LineTranTotal',
	hdr.HostRef as 'HdrHostRef',
	hdr.TranTotal as 'HdrTranTotal',
	hdr.CreatedDate as 'HdrCD',
	hdr.UpdatedDate as 'HdrUD'
From FEP_DRPAY_Line lin
inner join FEP_DRPAY_Hdr hdr on lin.DRPAYHdrId = hdr.Id
inner join FEP_Customer cust on hdr.CustomerId = cust.Id
inner join FEP_User usr on usr.CustomerId = cust.Id
where usr.Id  = @Userid
  and lin.Deleted = 0
  and hdr.Deleted = 0
  and cust.Deleted = 0
  and cust.Active = 1
  and usr.Deleted = 0
  and usr.Active = 1
  and lin.CreatedDate > '2015-05-31'
order by hdr.PaymentReference , hdr.PaymentNo desc , lin.InvoiceNo asc
  
-- Summary
Select
	cust.LegalName,
	hdr.PaymentReference as 'HdrPaymentReference',
	hdr.PaymentNo as 'HdrPaymentNo',	 
	SUM(lin.TranTotal) as 'LineTranTotal',
	hdr.HostRef as 'HdrHostRef',
	hdr.TranTotal as 'HdrTranTotal'
From FEP_DRPAY_Line lin
inner join FEP_DRPAY_Hdr hdr on lin.DRPAYHdrId = hdr.Id
inner join FEP_Customer cust on hdr.CustomerId = cust.Id
inner join FEP_User usr on usr.CustomerId = cust.Id
where usr.Id  = @Userid
  and lin.Deleted = 0
  and hdr.Deleted = 0
  and cust.Deleted = 0
  and cust.Active = 1
  and usr.Deleted = 0
  and usr.Active = 1
  and lin.CreatedDate > '2015-05-31'
 group by cust.LegalName, hdr.HostRef, hdr.TranTotal, hdr.PaymentReference, hdr.PaymentNo
 order by hdr.PaymentReference , hdr.PaymentNo desc 

Go





----------------------------------------------------------------
----3.  
---     MARK DELETED
----	all corrupt data
----------------------------------------------------------------
---------------------------------
--CREATE TEMPORARY TABLE
---------------------------------
DECLARE @Userid UniqueIdentifier = (Select top 1 ID From FEP_User where Username like 'Sargentr.jaradmin%')

Create Table #Temp1
(
  Lineid uniqueIdentifier,
  Deleted bit
);

INSERT INTO #Temp1
Select
	LIN.Id,
	LIN.Deleted
From FEP_DRPAY_Line lin
inner join FEP_DRPAY_Hdr hdr on lin.DRPAYHdrId = hdr.Id
inner join FEP_Customer cust on hdr.CustomerId = cust.Id
inner join FEP_User usr on usr.CustomerId = cust.Id
where usr.Id  = @Userid
  and lin.Deleted = 0
  and hdr.Deleted = 0
  and cust.Deleted = 0
  and cust.Active = 1
  and usr.Deleted = 0
  and usr.Active = 1
  and lin.CreatedDate > '2015-05-31';

---------------------------------
--BEGIN TRANSACTION MyTransaction
---------------------------------

BEGIN TRANSACTION MyTransaction; --Make sure to name your transactions 
UPDATE
	FEP_DRPAY_LINE
SET
	Deleted = 1
WHERE
	ID IN (SELECT Lineid FROM #Temp1)

--After
SELECT ID, Deleted FROM FEP_DRPAY_Line WHERE ID in (SELECT Lineid FROM #Temp1)
Go

DROP TABLE #Temp1
--------------------------
--COMMIT MyTransaction
--------------------------
COMMIT TRANSACTION MyTransaction;
Go

--------------------------
--ROLLBACK MyTransaction
--------------------------
ROLLBACK TRANSACTION MyTransaction;
Go



----------------------------------------------------------------
----4.  
---     RUN 
----    Payment\Synchronise Payment (in) 
----	In flow actions
----------------------------------------------------------------








