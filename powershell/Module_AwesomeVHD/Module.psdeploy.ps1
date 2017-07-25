$modulesRoot =    "${ENV:projects}/dotfiles.windows/powershell/Module_AwesomeVHD"
$destRoot =       "${ENV:psProfileDIR}/Modules/AwesomeVHD"

Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want
    By Filesystem MainFiles {                      # Deployment type. See Get-PSDeploymentType
        FromSource "$modulesRoot/_src"             # One or more sources to deploy. Absolute, or relative to deployment.yml paren
        To         "$destRoot"                     # One or more destinations to deploy the sources to
        DependingOn CommonModules
    }

    By Filesystem CommonModules {
        FromSource  "$modulesRoot/_src/include/Add-MountPoint.ps1",
                    "$modulesRoot/_src/include/Convert-IsoToVhdEnvelope.ps1"

        To  "$destRoot/include"
    }
}