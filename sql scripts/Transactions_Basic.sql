-------------------------------------------------------------------------
-- DESCRIPTION
-- Before and After Transaction Script Pattern
-------------------------------------------------------------------------
-- View PO connected with supplier x (same shipid and same billid)
DECLARE @GoodSupplierID UNIQUEIDENTIFIER = '7F53F266-7AA0-4F63-8674-BD6F03E3FBFE'
DECLARE @BadSupplierID UNIQUEIDENTIFIER = '2AF1879E-EFE4-4A0C-8E0D-1E3CB08FD924'

--Before (Runs on different batch independent of that with the transaction below)
SELECT 
	PH.Id, PH.SupplierShipId, PH.SupplierBillId, 
	PH.HostRef, PH.OrderNo, PH.SupplierShipName, 
	PH.SupplierBillName
FROM FEP_PO_Hdr PH
WHERE
	SupplierShipId in (@GoodSupplierID,@BadSupplierID)
ORDER BY
	SupplierShipId;
Go

--UPDATE
---------------------------------
--BEGIN TRANSACTION UpdatePOHdr
---------------------------------
DECLARE @GoodSupplierID uniqueidentifier = '7F53F266-7AA0-4F63-8674-BD6F03E3FBFE'
DECLARE @BadSupplierID uniqueidentifier = '2AF1879E-EFE4-4A0C-8E0D-1E3CB08FD924'

BEGIN TRANSACTION UpdatePOHdr; --Make sure to name your transactions 
UPDATE
	FEP_PO_Hdr
SET
	SupplierShipId = @GoodSupplierID,
	SupplierBillId = @GoodSupplierID
WHERE
	suppliershipid = @BadSupplierID;
--After
SELECT 
	PH.Id, PH.SupplierShipId, PH.SupplierBillId, 
	PH.HostRef, PH.OrderNo, PH.SupplierShipName, 
	PH.SupplierBillName
FROM FEP_PO_Hdr PH
WHERE
	SupplierShipId in (@GoodSupplierID,@BadSupplierID)
ORDER BY
	SupplierShipId;
Go
--------------------------
--COMMIT UpdatePOHdr
--------------------------
COMMIT TRANSACTION UpdatePOHdr;
Go

--------------------------
--ROLLBACK UpdatePOHdr
--------------------------
ROLLBACK TRANSACTION UpdatePOHdr;
Go
