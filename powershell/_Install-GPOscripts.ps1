$base = Join-Path $psScriptRoot 'Modules/Environment/GPO scripts'
sudo Copy-Item (Join-Path $base bbro-startup.ps1) -Destination "${ENV:systemRoot}/System32/GroupPolicy/Machine/Scripts/Startup/" -Force
sudo Copy-Item (Join-Path $base bbro-mao-logon.ps1) -Destination "${ENV:systemRoot}/System32/GroupPolicy/User/Scripts/Logon/" -Force