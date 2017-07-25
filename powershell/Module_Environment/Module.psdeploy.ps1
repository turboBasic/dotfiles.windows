$modulesRoot =    "${ENV:projects}/dotfiles.windows/powershell/Module_Environment"
$destRoot =       "${ENV:psProfileDIR}/Modules/Environment"

Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want
    By Filesystem MainFiles {                      # Deployment type. See Get-PSDeploymentType
        FromSource "$modulesRoot/_src"             # One or more sources to deploy. Absolute, or relative to deployment.yml paren
        To         "$destRoot"                     # One or more destinations to deploy the sources to
        DependingOn CommonModules
    }

    By Filesystem CommonModules {
        FromSource  "$modulesRoot/_src/include/Add-EnvironmentScopeType.ps1",
                    "$modulesRoot/_src/include/Export-Environment.ps1",
                    "$modulesRoot/_src/include/Get-Environment.ps1",
                    "$modulesRoot/_src/include/Get-EnvironmentKey.ps1",
                    "$modulesRoot/_src/include/Get-EnvironmentTable.ps1",
                    "$modulesRoot/_src/include/Get-ExpandedName.ps1",
                    "$modulesRoot/_src/include/Import-Environment.ps1",
                    "$modulesRoot/_src/include/Remove-EnvironmentVariable.ps1",
                    "$modulesRoot/_src/include/Remove-UnprotectedVariables.ps1",
                    "$modulesRoot/_src/include/Send-EnvironmentChanges.ps1",
                    "$modulesRoot/_src/include/Set-Environment.ps1",
                    "$modulesRoot/_src/include/Set-UserGlobalVariables.ps1"
                    
        To  "$destRoot/include"
    }
}
