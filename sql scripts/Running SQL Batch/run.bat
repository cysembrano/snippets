set inputfile="try.sql"

echo %inputfile%
sqlcmd -S .\SQLEXPR_X64_2014 -U FlowFBAccountingSA -P F1ow199! -i %inputfile%

pause