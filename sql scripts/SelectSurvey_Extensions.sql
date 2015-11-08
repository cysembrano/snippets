--SelectSurvey_Extensions.sql
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
----DROP SCRIPT
----Comment this out WARNING THIS WILL DROP EVERYTHING!!!!!
------------------------------------------------------------------------------
--Drop Foreign Keys
IF EXISTS 
(
	SELECT TOP 1 * FROM SYS.FOREIGN_KEYS FK
	INNER JOIN SYS.TABLES T ON T.[Object_ID] = FK.Parent_object_id
	WHERE FK.[Name] = 'FK_sur_extn_data_group_sur_extn_contract' 
	AND T.[Name] = 'sur_extn_data_group'
)
BEGIN
	PRINT 'Dropping Foreign Key [FK_sur_extn_data_group_sur_extn_contract]';
	ALTER TABLE sur_extn_data_group 
	DROP CONSTRAINT FK_sur_extn_data_group_sur_extn_contract;
END;
GO

IF EXISTS 
(
	SELECT TOP 1 * FROM SYS.FOREIGN_KEYS FK
	INNER JOIN SYS.TABLES T ON T.[Object_ID] = FK.Parent_object_id
	WHERE FK.[Name] = 'FK_sur_extn_list_item_sur_extn_list' 
	AND T.[Name] = 'sur_extn_list_item'
)
BEGIN
	PRINT 'Dropping Foreign Key [FK_sur_extn_list_item_sur_extn_list]';
	ALTER TABLE sur_extn_list_item 
	DROP CONSTRAINT FK_sur_extn_list_item_sur_extn_list;
END;
GO


--Drop Tables
IF EXISTS (SELECT TOP 1 * FROM SYS.TABLES T WHERE (T.[name] = 'sur_extn_list_item'))
BEGIN 
	PRINT 'Dropping Table [sur_extn_list_item]';
	DROP TABLE [sur_extn_list_item]
END; 
GO


IF EXISTS (SELECT TOP 1 * FROM SYS.TABLES T WHERE (T.[name] = 'sur_extn_list'))
BEGIN 
	PRINT 'Dropping Table [sur_extn_list]';
	DROP TABLE [sur_extn_list]
END; 
GO

IF EXISTS (SELECT TOP 1 * FROM SYS.TABLES T WHERE (T.[name] = 'sur_extn_data_group'))
BEGIN 
	PRINT 'Dropping Table [sur_extn_data_group]';
	DROP TABLE [sur_extn_data_group]
END; 
GO
 
IF EXISTS (SELECT TOP 1 * FROM SYS.TABLES T WHERE (T.[name] = 'sur_extn_contract'))
BEGIN 
	PRINT 'Dropping Table [sur_extn_contract]';
	DROP TABLE [sur_extn_contract]
END; 
GO




----------------------------------------------------------------
----CREATE TABLES
----------------------------------------------------------------
BEGIN TRANSACTION
GO
IF NOT EXISTS (SELECT TOP 1 * FROM SYS.TABLES T	WHERE(T.[name] = 'sur_extn_contract'))
BEGIN
	PRINT 'Creating Table [sur_extn_contract]'
	CREATE TABLE [sur_extn_contract]
	(
		 [Id]							INT				 NOT NULL IDENTITY (1, 1)
		,[ClientName]					NVARCHAR(50)	 NOT NULL
		,[ContractName]					NVARCHAR(50)	 NOT NULL
		,[Active]	      				BIT              NOT NULL DEFAULT 1
		,[CreatedDate]					DATETIME		 NOT NULL DEFAULT GETDATE()
		,[ModifiedDate]					DATETIME		 NULL
		,CONSTRAINT [PK_sur_extn_contract] PRIMARY KEY CLUSTERED([Id] ASC)
	);
	PRINT 'Created Table [sur_extn_contract]'
END
GO
ALTER TABLE [sur_extn_contract] SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


BEGIN TRANSACTION
GO
IF NOT EXISTS (SELECT TOP 1 * FROM SYS.TABLES T	WHERE(T.[name] = 'sur_extn_data_group'))
BEGIN
	PRINT 'Creating Table [sur_extn_data_group]'
	CREATE TABLE [sur_extn_data_group]
	(
		 [Id]							INT				 NOT NULL IDENTITY (1, 1)
		,[ContractId]					INT				 NOT NULL
		,[GroupName]					NVARCHAR(50)	 NOT NULL
		,[SortOrder]					INT				 NULL
		,[Active]	      				BIT              NOT NULL DEFAULT 1
		,[CreatedDate]					DATETIME		 NOT NULL DEFAULT GETDATE()
		,[ModifiedDate]					DATETIME		 NULL
		,CONSTRAINT [PK_sur_extn_data_group] PRIMARY KEY CLUSTERED([Id] ASC)
		,CONSTRAINT [FK_sur_extn_data_group_sur_extn_contract] FOREIGN KEY ([ContractId])
			REFERENCES [sur_extn_contract]([Id])
	);
	PRINT 'Created Table [sur_extn_data_group]'
END
GO
ALTER TABLE [sur_extn_data_group] SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


BEGIN TRANSACTION
GO
IF NOT EXISTS (SELECT TOP 1 * FROM SYS.TABLES T	WHERE(T.[name] = 'sur_extn_list'))
BEGIN
	PRINT 'Creating Table [sur_extn_list]'
	CREATE TABLE [sur_extn_list]
	(
		 [Id]							INT				 NOT NULL IDENTITY (1, 1)
		,[ListName]						NVARCHAR(50)	 NOT NULL
		,[Active]	      				BIT              NOT NULL DEFAULT 1
		,[CreatedDate]					DATETIME		 NOT NULL DEFAULT GETDATE()
		,[ModifiedDate]					DATETIME		 NULL
		,CONSTRAINT [PK_sur_extn_list] PRIMARY KEY CLUSTERED([Id] ASC)
	);
	PRINT 'Created Table [sur_extn_list]'
END
GO
ALTER TABLE [sur_extn_list] SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


BEGIN TRANSACTION
GO
IF NOT EXISTS (SELECT TOP 1 * FROM SYS.TABLES T	WHERE(T.[name] = 'sur_extn_list_item'))
BEGIN
	PRINT 'Creating Table [sur_extn_list_item]'
	CREATE TABLE [sur_extn_list_item]
	(
		 [Id]							INT				 NOT NULL IDENTITY (1, 1)
		,[ListId]						INT				 NOT NULL
		,[ItemText]						NVARCHAR(100)	 NOT NULL
		,[ItemValue]					NVARCHAR(100)	 NOT NULL
		,[Active]	      				BIT              NOT NULL DEFAULT 1
		,[CreatedDate]					DATETIME		 NOT NULL DEFAULT GETDATE()
		,[ModifiedDate]					DATETIME		 NULL
		,CONSTRAINT [PK_sur_extn_list_item] PRIMARY KEY CLUSTERED([Id] ASC)
		,CONSTRAINT [FK_sur_extn_list_item_sur_extn_list] FOREIGN KEY ([ListId])
			REFERENCES [sur_extn_list]([Id])
	);
	PRINT 'Created Table [sur_extn_list_item]'
END
GO
ALTER TABLE [sur_extn_list_item] SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
