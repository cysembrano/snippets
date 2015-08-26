------------------------------------------------------------------------------
--Adding Column [FEP_Plugin].[AssemblyFileVersion]
------------------------------------------------------------------------------
IF NOT EXISTS (
	SELECT
		*
	FROM
		SYS.COLUMNS C
	WHERE
			(C.[object_id] = OBJECT_ID('FEP_Plugin'))
		AND (C.[name] = 'AssemblyFileVersion')
	)
BEGIN
	PRINT 'Creating Column [FEP_Plugin].[AssemblyFileVersion]';
	
	ALTER TABLE
		[FEP_Plugin]
	ADD
		[AssemblyFileVersion] NVARCHAR(50) NULL
END;
GO
