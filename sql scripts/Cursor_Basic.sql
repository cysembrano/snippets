DECLARE @currentuserid UNIQUEIDENTIFIER
DECLARE login_cursor CURSOR FOR  
	SELECT DISTINCT(USERID) FROM FEP_User_Right
OPEN login_cursor   
FETCH NEXT FROM login_cursor INTO @currentuserid   
WHILE @@FETCH_STATUS = 0   
BEGIN   
	IF NOT EXISTS (SELECT * FROM FEP_User_Right WHERE UserId = @currentuserid AND RightId = 233)
	BEGIN
		PRINT('Adding Right 233 to User id (' + convert(nvarchar(50), @currentuserid) + ')')
	END       
FETCH NEXT FROM login_cursor INTO @currentuserid   
END
CLOSE login_cursor   
DEALLOCATE login_cursor
