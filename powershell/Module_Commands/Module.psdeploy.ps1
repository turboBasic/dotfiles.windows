$modulesRoot =    "${ENV:projects}/dotfiles.windows/powershell/Module_Commands"
$destRoot =       "${ENV:psProfileDIR}/Modules/Commands"

Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want
    By Filesystem MainFiles {                      # Deployment type. See Get-PSDeploymentType
        FromSource "$modulesRoot/_src"             # One or more sources to deploy. Absolute, or relative to deployment.yml paren
        To         "$destRoot"                     # One or more destinations to deploy the sources to
        DependingOn CommonModules
    }

    By Filesystem CommonModules {
        FromSource  "$modulesRoot/_src/include/Add-FileDetails.ps1",
                    "$modulesRoot/_src/include/Add-SmartMargin.ps1",
                    "$modulesRoot/_src/include/Convert-HashtableToObject.ps1",
                    "$modulesRoot/_src/include/ConvertTo-Hashtable.ps1",
                    "$modulesRoot/_src/include/Copy-Tree.ps1",
                    "$modulesRoot/_src/include/Expand-HashtableSelfReference.ps1",
                    "$modulesRoot/_src/include/Export-Environment.ps1",
                    "$modulesRoot/_src/include/Format-String.ps1",
                    "$modulesRoot/_src/include/Get-ConsoleColor.ps1",
                    "$modulesRoot/_src/include/Get-EnvironmentPath.ps1",
                    "$modulesRoot/_src/include/Get-GistMao.ps1",
                    "$modulesRoot/_src/include/Get-GuiHelp.ps1",
                    "$modulesRoot/_src/include/Get-HelpWindow.ps1",
                    "$modulesRoot/_src/include/Get-SpecialFolders.ps1",
                    "$modulesRoot/_src/include/Get-StringHash.ps1",
                    "$modulesRoot/_src/include/Get-TimeStamp.ps1",
                    "$modulesRoot/_src/include/Import-UserModules.ps1",
                    "$modulesRoot/_src/include/IsNull.ps1",
                    "$modulesRoot/_src/include/Merge-Hashtables.ps1",
                    "$modulesRoot/_src/include/New-Shortcut.ps1",
                    "$modulesRoot/_src/include/New-SymLink.ps1",
                    "$modulesRoot/_src/include/Remove-IndentationMark.ps1",
                    "$modulesRoot/_src/include/Remove-LeadingSpace.ps1",
                    "$modulesRoot/_src/include/Resolve-HashTable.ps1",
                    "$modulesRoot/_src/include/Send-NetMessage.ps1",
                    "$modulesRoot/_src/include/Set-FileTime.ps1",
                    "$modulesRoot/_src/include/Set-LogEntry.ps1",
                    "$modulesRoot/_src/include/Update-Helpfiles.ps1",
                    "$modulesRoot/_src/include/Write-Log.ps1",
                    "$modulesRoot/_src/include/Write-VariableDump.ps1"
                    
        To  "$destRoot/include"
    }
}


