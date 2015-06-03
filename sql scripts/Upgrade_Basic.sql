--ProofEmail_DBScript.sql

SET NOCOUNT ON;
GO

----------------------------------------------------------------
----DROP SCRIPT - Comment this out
----------------------------------------------------------------
--IF EXISTS (SELECT * FROM SYS.FOREIGN_KEYS WHERE [object_id] = OBJECT_ID('FK_FEP_cXML_FEP_cXML_Type') AND [parent_object_id] = OBJECT_ID('FEP_cXML'))
--BEGIN
--	ALTER TABLE FEP_cXML 
--	DROP CONSTRAINT [FK_FEP_cXML_FEP_cXML_Type];
--END;
--GO


--IF EXISTS (SELECT * FROM SYS.TABLES T WHERE (T.[name] = 'FEP_cXML_PunchOutSetupResponse'))
--BEGIN 
--	DROP TABLE [FEP_cXML_PunchOutSetupResponse] 
--END; 
--GO

----------------------------------------------------------------
----CREATE CY_CompanyParameters - Comment this out; Test ONLY
----------------------------------------------------------------







----------------------------------------------------------------
----CREATE TABLES
----------------------------------------------------------------

IF NOT EXISTS (
	SELECT
		*
	FROM
		SYS.TABLES T
	WHERE
		(T.[name] = 'FEP_cXML_PunchOutSetupRequest_Contact')
	)
BEGIN
	PRINT 'Creating Table [FEP_cXML_PunchOutSetupRequest_Contact]';
	
	CREATE TABLE [FEP_cXML_PunchOutSetupRequest_Contact]
	(
		 [Id]							UNIQUEIDENTIFIER NOT NULL
		,[PunchOutSetupRequestId]		UNIQUEIDENTIFIER NOT NULL
		,[Role]							NVARCHAR(50)	 NULL
		,[Name]							NVARCHAR(100)    NULL
		,[Email]						NVARCHAR(100)    NULL
		,[TimeStamp]					DATETIME DEFAULT GetDate() NULL
		
		,CONSTRAINT [PK_FEP_cXML_PunchOutSetupRequest_Contact] PRIMARY KEY CLUSTERED([Id] ASC)
		,CONSTRAINT [FK_FEP_cXML_PunchOutSetupRequest_Contact_FEP_cXML_PunchOutSetupRequest] FOREIGN KEY ([PunchOutSetupRequestId])
			REFERENCES [FEP_cXML_PunchOutSetupRequest]([Id])
	);
END



IF NOT EXISTS (
	SELECT
		*
	FROM
		SYS.TABLES T
	WHERE
		(T.[name] = 'FEP_cXML_PunchOutSetupResponse')
	)
BEGIN
	PRINT 'Creating Table [FEP_cXML_PunchOutSetupResponse]';
	
	CREATE TABLE [FEP_cXML_PunchOutSetupResponse]
	(
		 [Id]							UNIQUEIDENTIFIER NOT NULL
		,[cXMLId]						UNIQUEIDENTIFIER NOT NULL
		,[StatusCode]					NVARCHAR(50)	 NULL
		,[StatusText]					NVARCHAR(250)    NULL
		,[StartPageURL]					NVARCHAR(MAX)     NULL
		,[BuyerCookie]					NVARCHAR(250)    NULL
		
		,CONSTRAINT [PK_FEP_cXML_PunchOutSetupResponse] PRIMARY KEY CLUSTERED([Id] ASC)
	);
END
GO


----------------------------------------------------------------
----CREATE RELATIONSHIPS
----------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM SYS.FOREIGN_KEYS WHERE [object_id] = OBJECT_ID('FK_FEP_cXML_FEP_cXML_Type') AND [parent_object_id] = OBJECT_ID('FEP_cXML'))
BEGIN
	PRINT 'Applying Foreign Key for [FEP_cXML].[TypeId] referencing [FEP_cXML_Type] ([Id])';
	ALTER TABLE FEP_cXML 
	ADD CONSTRAINT [FK_FEP_cXML_FEP_cXML_Type] FOREIGN KEY ([TypeId]) 
		REFERENCES [dbo].[FEP_cXML_Type] ([Id])
END;
GO




----------------------------------------------------------------
-- UPDATE SITE VERSION
--	   - Cyrus, 2014-12-17
----------------------------------------------------------------
DECLARE @tgtMajor    INTEGER;
DECLARE @tgtMinor    INTEGER;
DECLARE @tgtBuild    INTEGER;
DECLARE @tgtRevision INTEGER;
DECLARE @tgtVersion  NVARCHAR(MAX);

SET @tgtMajor    = 3;
SET @tgtMinor    = 1;
SET @tgtBuild    = 9;
SET @tgtRevision = 3;

SET @tgtVersion =
	CAST(@tgtMajor    AS NVARCHAR(MAX)) + '.' +
	CAST(@tgtMinor    AS NVARCHAR(MAX)) + '.' +
	CAST(@tgtBuild    AS NVARCHAR(MAX)) + '.' +
	CAST(@tgtRevision AS NVARCHAR(MAX));

IF NOT EXISTS (SELECT * FROM [FEP_System_Version])
BEGIN
	PRINT 'Inserting Version: ''' + @tgtVersion + ''' into Table: [FEP_System_Version]...';
	INSERT INTO [FEP_System_Version] ([Major],[Minor],[Build],[Revision]) VALUES (@tgtMajor,@tgtMinor,@tgtBuild,@tgtRevision);
END
ELSE BEGIN
	DECLARE @major    INTEGER;
	DECLARE @minor    INTEGER;
	DECLARE @build    INTEGER;
	DECLARE @revision INTEGER;
		
	SELECT
		  @major    = [Major]
		 ,@minor    = [Minor]
		 ,@build    = [Build]
		 ,@revision = [Revision]
	FROM
		[FEP_System_Version];
		
	IF (
		    (@major < @tgtMajor)
		OR ((@major = @tgtMajor) AND (@minor < @tgtMinor))
		OR ((@major = @tgtMajor) AND (@minor = @tgtMinor) AND (@build < @tgtBuild))
		OR ((@major = @tgtMajor) AND (@minor = @tgtMinor) AND (@build = @tgtBuild) AND (@revision < @tgtRevision))
	   )
	BEGIN
		PRINT 'Updating Version: ''' + @tgtVersion + ''' into Table: [FEP_System_Version]...';
		UPDATE [FEP_System_Version]
		SET
			 [Major]    = @tgtMajor
			,[Minor]    = @tgtMinor
			,[Build]    = @tgtBuild
			,[Revision] = @tgtRevision;
	END;
END;