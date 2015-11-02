--SelectSurvey_Extensions.sql
SET NOCOUNT ON;
GO

------------------------------------------------------------------------------
----DROP SCRIPT
----Comment this out WARNING THIS WILL DROP EVERYTHING!!!!!
------------------------------------------------------------------------------

--Drop Tables 
IF EXISTS (SELECT TOP 1 * FROM SYS.TABLES T WHERE (T.[name] = 'sur_extn_contract'))
BEGIN 
	PRINT 'Dropping Table [sur_extn_contract]';
	DROP TABLE [sur_extn_contract]
END; 
GO


----------------------------------------------------------------
----CREATE TABLES
----------------------------------------------------------------
IF NOT EXISTS (SELECT TOP 1 * FROM SYS.TABLES T	WHERE(T.[name] = 'ProofEmail'))
BEGIN
	PRINT 'Creating Table [ProofEmail]';
	
	CREATE TABLE [ProofEmail]
	(
		 [Id]							UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
		,[TypeId]						INT 			 NOT NULL
		,[StatusId]						INT 			 NOT NULL
		
		,[SalesOrderId]					NVARCHAR(50)	 NOT NULL
		,[EmailProof]      				BIT              NOT NULL DEFAULT 1
		,[EmailProof_FirstReminder]		BIT              NOT NULL DEFAULT 0
		,[EmailProof_SecondReminder]	BIT              NOT NULL DEFAULT 0
		,[Selling_Company]				VARCHAR(10)	 	 NOT NULL
		,[CustomerAccount]				NVARCHAR(50)	 NOT NULL
		,[CustomerEmail]				NVARCHAR(MAX)	 NOT NULL
		,[Season]						NVARCHAR(50)	 NOT NULL
		
		,[WorkingDays]					AS (case when datepart(month,getdate())>(10) then (3) else (10) end)
		
		,[CreatedDate]					DATETIME		 NOT NULL DEFAULT GETDATE()
		
		,CONSTRAINT [PK_ProofEmail] PRIMARY KEY CLUSTERED([Id] ASC)
		,CONSTRAINT [FK_ProofEmail_ProofEmail_Type] FOREIGN KEY ([TypeId])
			REFERENCES [ProofEmail_Type]([Id])
		,CONSTRAINT [FK_ProofEmail_ProofEmail_Status] FOREIGN KEY ([StatusId])
			REFERENCES [ProofEmail_Status]([Id])
	);
END
