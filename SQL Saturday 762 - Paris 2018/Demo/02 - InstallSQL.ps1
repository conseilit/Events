﻿/sources/setup/setup.exe /Q /ACTION=Install `
  /INSTANCENAME=MSSQLServer `
  /FEATURES=SQLEngine `
  /UPDATEENABLED=1 `
  /TCPENABLED=1 `
  /SECURITYMODE=SQL /SAPWD=Password1! `
  /SQLSVCACCOUNT="NT AUTHORITY\System"  `
  /SQLSYSADMINACCOUNTS="BUILTIN\ADMINISTRATORS" `
  /IACCEPTSQLSERVERLICENSETERMS

