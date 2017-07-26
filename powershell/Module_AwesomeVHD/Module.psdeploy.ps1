$modulesRoot =    "${ENV:projects}/dotfiles.windows/powershell/Module_AwesomeVHD"
$destRoot =       "${ENV:psProfileDIR}/Modules/AwesomeVHD"

Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want
    By Filesystem {                                # Deployment type. See Get-PSDeploymentType
        FromSource "$modulesRoot/_src"             
        To         "$destRoot"                     #        DependingOn CommonModules
        WithOptions @{
            Mirror = $True
        }
    }
}
