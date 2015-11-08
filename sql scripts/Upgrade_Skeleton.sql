--ProofEmail_DBScript.sql
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
------------------------------------------------------------------------------
----DROP SCRIPT - Comment this out WARNING THIS WILL DROP EVERYTHING!!!!!
------------------------------------------------------------------------------
--Drop Foreign Keys Sample
IF EXISTS 
(
	SELECT TOP 1 * FROM SYS.FOREIGN_KEYS FK
	INNER JOIN SYS.TABLES T ON T.[Object_ID] = FK.Parent_object_id
	WHERE FK.[Name] = 'FK_tblEmp_Schedule_tblEmp_ScheduleLine' 
	AND T.[Name] = 'tblEmp_ScheduleLine'
)
BEGIN
	PRINT 'Dropping Foreign Key [FK_tblEmp_Schedule_tblEmp_ScheduleLine]';
	ALTER TABLE streamassist_dbo.tblEmp_ScheduleLine 
	DROP CONSTRAINT FK_tblEmp_Schedule_tblEmp_ScheduleLine;
END;
GO

--Drop Tables Sample
IF EXISTS (SELECT TOP 1 * FROM SYS.TABLES T WHERE (T.[name] = 'ProofEmail_Metadata'))
BEGIN 
	PRINT 'Dropping Table [ProofEmail_Metadata]';
	DROP TABLE [ProofEmail_Metadata] 
END; 
GO

--Drop Sproc Sample
IF EXISTS (SELECT TOP 1 * FROM SYS.OBJECTS WHERE ([object_id] = OBJECT_ID('ProofEmail_GetEmailList')) AND ([type] in (N'P', N'PC')))
BEGIN
	PRINT 'Dropping Procedure [dbo].[ProofEmail_GetEmailList]';
	DROP PROCEDURE [dbo].[ProofEmail_GetEmailList];
END


----------------------------------------------------------------
----CREATE TABLE STYLE 1 SAMPLE
----------------------------------------------------------------
BEGIN TRANSACTION
GO
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
GO
COMMIT

----------------------------------------------------------------
----CREATE TABLE STYLE 2 SAMPLE
----------------------------------------------------------------
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Table_1
	(
	id int NOT NULL IDENTITY (1, 1)
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Table_1 ADD CONSTRAINT
	PK_Table_1 PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Table_1 SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

----------------------------------------------------------------
----CREATE PROCEDURE SAMPLE
----------------------------------------------------------------
BEGIN TRANSACTION
GO
IF EXISTS (SELECT TOP 1 * FROM SYS.OBJECTS WHERE ([object_id] = OBJECT_ID('ProofEmail_GetEmailList')) AND ([type] in (N'P', N'PC')))
BEGIN
	PRINT 'Dropping Procedure [dbo].[ProofEmail_GetEmailList]';
	DROP PROCEDURE [dbo].[ProofEmail_GetEmailList];
END
GO

PRINT 'Creating Procedure: [dbo].[ProofEmail_GetEmailList]';
GO

CREATE PROCEDURE [dbo].[ProofEmail_GetEmailList] 
(
	 @EmailProof bit
	,@EmailProof_FirstReminder bit
	,@EmailProof_SecondReminder bit
)
AS
BEGIN
	DECLARE
	@sampleid uniqueidentifier, 
	@salesorderid nvarchar(50),
	@customeraccount nvarchar(50)
	SET @sampleid = (
						SELECT TOP 1 [Id] 
						FROM [ProofEmail] 
						WHERE 
							    [StatusId]='1'
							AND [EmailProof] = @EmailProof
							AND [EmailProof_FirstReminder] = @EmailProof_FirstReminder
							AND [EmailProof_SecondReminder] = @EmailProof_SecondReminder
					)
	SET @customeraccount = (SELECT [CustomerAccount] FROM [ProofEmail] WHERE [Id]=@sampleid)
	SET @salesorderid = (SELECT [SalesOrderId] FROM [ProofEmail] WHERE [Id]=@sampleid)

	SELECT
		 [Id]
		,[SalesOrderId]
		,[CustomerAccount]
		,[CustomerEmail]
	FROM [ProofEmail]
	WHERE 
		[SalesOrderId] = @salesorderid
		
	UNION

	SELECT 
		 [Id]
		,[SalesOrderId]
		,[CustomerAccount]
		,[CustomerEmail]
	FROM [ProofEmail]
	WHERE 
		[CUSTOMERACCOUNT] = @customeraccount
END
GO
COMMIT
----------------------------------------------------------------
----ADD COLUMN SAMPLE
----------------------------------------------------------------
IF EXISTS ( SELECT TOP 1 * FROM SYS.TABLES T WHERE (T.[name] = 'tblCallbackLogs') )
BEGIN
	IF NOT EXISTS 
	(
		SELECT TOP 1 * FROM 
					SYS.TABLES T 
		INNER JOIN SYS.COLUMNS C ON C.OBJECT_ID = T.OBJECT_ID 
		WHERE C.NAME = 'CallbackReasonTypeIdRef' AND T.NAME = 'tblCallbackLogs'
	)
	BEGIN
		PRINT 'Alter tblCallbackLogs Table:  Add [CallbackReasonTypeIdRef]';
		ALTER TABLE [streamassist_dbo].[tblCallbackLogs]
		ADD  [CallbackReasonTypeIdRef] Int NULL
	END;
END;
GO



