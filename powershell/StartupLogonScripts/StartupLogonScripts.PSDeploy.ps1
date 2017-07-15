$modulesRoot =    "${ENV:projects}/dotfiles.windows/powershell/Modules"
$modEnvironment = "$modulesRoot/Environment/include"
$modCommands =    "$modulesRoot/Commands/include"
$destRoot =       "${ENV:systemROOT}/system32/GroupPolicy"

Deploy StartupLogonScripts {   
                                                      # Deployment name. This needs to be unique. Call it whatever you want
    By Filesystem User {                                  # Deployment type. See Get-PSDeploymentType
        FromSource "$PSScriptRoot/_src/bbro-mao-logon.ps1"                   # One or more sources to deploy. Absolute, or relative to deployment.yml paren
        To         "$destRoot/User/Scripts/Logon"                       # One or more destinations to deploy the sources to
        DependingOn CommonModules
    }

    By Filesystem Machine {
        FromSource "$PSScriptRoot/_src/bbro-startup.ps1"
        To         "$destRoot/Machine/Scripts/Startup"
        DependingOn CommonModules   
    }

    By Filesystem CommonModules {
        FromSource  "$modEnvironment/Add-EnvironmentScopeType.ps1",
            "$modEnvironment/Get-Environment.ps1",
            "$modEnvironment/Get-EnvironmentKey.ps1",
            "$modEnvironment/Get-ExpandedName.ps1",
            "$modEnvironment/Import-Environment.ps1",
            "$modEnvironment/Send-EnvironmentChanges.ps1",
            "$modEnvironment/Set-Environment.ps1",
            "$modCommands/Get-TimeStamp.ps1",
            "$modCommands/IsNull.ps1",
            "$modCommands/Set-LogEntry.ps1",
            "$modCommands/Send-NetMessage/ps1",
            "$modCommands/Write-Log.ps1"

        To  "$destRoot/Machine/Scripts/Startup/include",
            "$destRoot/User/Scripts/Logon/include"
    }
}