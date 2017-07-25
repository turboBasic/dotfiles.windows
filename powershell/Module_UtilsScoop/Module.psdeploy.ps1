$modulesRoot =    "${ENV:projects}/dotfiles.windows/powershell/Module_UtilsScoop"
$destRoot =       "${ENV:psProfileDIR}/Modules/UtilsScoop"

Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want
    By Filesystem MainFiles {                      # Deployment type. See Get-PSDeploymentType
        FromSource "$modulesRoot/_src"             # One or more sources to deploy. Absolute, or relative to deployment.yml paren
        To         "$destRoot"                     # One or more destinations to deploy the sources to
        DependingOn CommonModules
    }

    By Filesystem CommonModules {
        FromSource  "$modulesRoot/_src/include/abort.ps1",
                    "$modulesRoot/_src/include/coalesce.ps1",
                    "$modulesRoot/_src/include/ensure.ps1",
                    "$modulesRoot/_src/include/ensure_in_path.ps1",
                    "$modulesRoot/_src/include/filesize.ps1",
                    "$modulesRoot/_src/include/fname.ps1",
                    "$modulesRoot/_src/include/format.ps1",
                    "$modulesRoot/_src/include/friendly_path.ps1",
                    "$modulesRoot/_src/include/Get-FileFromWeb.ps1",
                    "$modulesRoot/_src/include/Get-FullPath.ps1",
                    "$modulesRoot/_src/include/Get-Shim.ps1",
                    "$modulesRoot/_src/include/is_local.ps1",
                    "$modulesRoot/_src/include/movedir.ps1",
                    "$modulesRoot/_src/include/pluralize.ps1",
                    "$modulesRoot/_src/include/relpath.ps1",
                    "$modulesRoot/_src/include/remove_from_path.ps1",
                    "$modulesRoot/_src/include/Remove-Extension.ps1",
                    "$modulesRoot/_src/include/reset_alias.ps1",
                    "$modulesRoot/_src/include/reset_aliases.ps1",
                    "$modulesRoot/_src/include/sanitary_path.ps1",
                    "$modulesRoot/_src/include/shim.ps1",
                    "$modulesRoot/_src/include/strip_path.ps1",
                    "$modulesRoot/_src/include/success.ps1",
                    "$modulesRoot/_src/include/Test-Administrator.ps1",
                    "$modulesRoot/_src/include/unzip.ps1",
                    "$modulesRoot/_src/include/warn.ps1",
                    "$modulesRoot/_src/include/wraptext.ps1"
                    
        To  "$destRoot/include"
    }
}
