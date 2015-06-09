--ProofEmail_DBScript.sql
SET NOCOUNT ON;
GO

------------------------------------------------------------------------------
----DROP SCRIPT - Comment this out WARNING THIS WILL DROP EVERYTHING!!!!!
------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM SYS.FOREIGN_KEYS WHERE [object_id] = OBJECT_ID('FK_ProofEmail_Metadata_ProofEmail') AND [parent_object_id] = OBJECT_ID('ProofEmail_Metadata'))
BEGIN
	PRINT 'Dropping Foreign Key [FK_ProofEmail_Metadata_ProofEmail]';
	ALTER TABLE ProofEmail_Metadata 
	DROP CONSTRAINT [FK_ProofEmail_Metadata_ProofEmail];
END;
GO

IF EXISTS (SELECT * FROM SYS.FOREIGN_KEYS WHERE [object_id] = OBJECT_ID('FK_ProofEmail_ProofEmail_Status') AND [parent_object_id] = OBJECT_ID('ProofEmail'))
BEGIN
	PRINT 'Dropping Foreign Key [FK_ProofEmail_ProofEmail_Status]';
	ALTER TABLE ProofEmail 
	DROP CONSTRAINT [FK_ProofEmail_ProofEmail_Status];
END;
GO

IF EXISTS (SELECT * FROM SYS.FOREIGN_KEYS WHERE [object_id] = OBJECT_ID('FK_ProofEmail_ProofEmail_Type') AND [parent_object_id] = OBJECT_ID('ProofEmail'))
BEGIN
	PRINT 'Dropping Foreign Key [FK_ProofEmail_ProofEmail_Type]';
	ALTER TABLE ProofEmail 
	DROP CONSTRAINT [FK_ProofEmail_ProofEmail_Type];
END;
GO


IF EXISTS (SELECT * FROM SYS.TABLES T WHERE (T.[name] = 'ProofEmail_Metadata'))
BEGIN 
	PRINT 'Dropping Table [ProofEmail_Metadata]';
	DROP TABLE [ProofEmail_Metadata] 
END; 
GO

IF EXISTS (SELECT * FROM SYS.TABLES T WHERE (T.[name] = 'ProofEmail'))
BEGIN
	PRINT 'Dropping Table [ProofEmail]';
	DROP TABLE [ProofEmail] 
END; 
GO

IF EXISTS (SELECT * FROM SYS.TABLES T WHERE (T.[name] = 'ProofEmail_Status'))
BEGIN
	PRINT 'Dropping Table [ProofEmail_Status]';
	DROP TABLE [ProofEmail_Status] 
END; 
GO

IF EXISTS (SELECT * FROM SYS.TABLES T WHERE (T.[name] = 'ProofEmail_Type'))
BEGIN
	PRINT 'Dropping Table [ProofEmail_Type]';
	DROP TABLE [ProofEmail_Type] 
END; 
GO


----------------------------------------------------------------
----CREATE TABLE [ProofEmail_Type]
----------------------------------------------------------------
IF NOT EXISTS (
	SELECT
		*
	FROM
		SYS.TABLES T
	WHERE
		(T.[name] = 'ProofEmail_Type')
	)
BEGIN
	PRINT 'Creating Table [ProofEmail_Type]';
	
	CREATE TABLE [ProofEmail_Type]
	(
		 [Id]							INT 		 NOT NULL
		,[Code]							NVARCHAR(50) NOT NULL
		,[EmailText]					NVARCHAR(50) NULL
		
		,CONSTRAINT [PK_ProofEmail_Type] PRIMARY KEY CLUSTERED([Id] ASC)
	);
	
	INSERT INTO ProofEmail_Type VALUES (1, 'CALENDAR', 'Calendar');
	INSERT INTO ProofEmail_Type VALUES (2, 'NOVELTY', 'Magnet');	
END

----------------------------------------------------------------
----CREATE TABLE [ProofEmail_Status]
----------------------------------------------------------------
IF NOT EXISTS (
	SELECT
		*
	FROM
		SYS.TABLES T
	WHERE
		(T.[name] = 'ProofEmail_Status')
	)
BEGIN
	PRINT 'Creating Table [ProofEmail_Status]';
	
	CREATE TABLE [ProofEmail_Status]
	(
		 [Id]							INT 		 NOT NULL
		,[Code]							NVARCHAR(10) NOT NULL
		,[Description]					NVARCHAR(20) NULL
		
		,CONSTRAINT [PK_ProofEmail_Status] PRIMARY KEY CLUSTERED([Id] ASC)
	);
	
	INSERT INTO ProofEmail_Status VALUES (1, 'NEW', 'New Record');
	INSERT INTO ProofEmail_Status VALUES (2, 'SENT', 'Email Sent');
END

----------------------------------------------------------------
----CREATE TABLE [ProofEmail]
----------------------------------------------------------------
IF NOT EXISTS (
	SELECT
		*
	FROM
		SYS.TABLES T
	WHERE
		(T.[name] = 'ProofEmail')
	)
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


----------------------------------------------------------------
----CREATE TABLE [ProofEmail_Metadata]
----------------------------------------------------------------
IF NOT EXISTS (
	SELECT
		*
	FROM
		SYS.TABLES T
	WHERE
		(T.[name] = 'ProofEmail_Metadata')
	)
BEGIN
	PRINT 'Creating Table [ProofEmail_Metadata]';
	
	CREATE TABLE [ProofEmail_Metadata]
	(
		 [Id]							INT				 NOT NULL IDENTITY(1,1)
		,[ProofEmailId]					UNIQUEIDENTIFIER NOT NULL
		,[FileName_SO]					NVARCHAR(MAX) 	 NOT NULL
		,[FileName_Attachment]			NVARCHAR(MAX) 	 NULL

		
		,CONSTRAINT [PK_ProofEmail_Metadata] PRIMARY KEY CLUSTERED([Id] ASC)
		,CONSTRAINT [FK_ProofEmail_Metadata_ProofEmail] FOREIGN KEY ([ProofEmailId])
			REFERENCES [ProofEmail]([Id])

	);
END
GO


----------------------------------------------------------------
----CREATE PROCEDURE [ProofEmail_GetEmailList]
----------------------------------------------------------------
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE ([object_id] = OBJECT_ID('ProofEmail_GetEmailList')) AND ([type] in (N'P', N'PC')))
BEGIN
	PRINT 'Dropping Procedure [dbo].[ProofEmail_GetEmailList]';
	DROP PROCEDURE [dbo].[ProofEmail_GetEmailList];
END;
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





