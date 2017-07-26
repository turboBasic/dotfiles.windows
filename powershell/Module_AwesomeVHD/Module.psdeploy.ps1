$me=($psScriptRoot | Split-Path -Parent | Split-Path -Leaf) -replace 'Module_'
$modulesRoot =    "${ENV:projects}/dotfiles.windows/powershell/Module_$me"
$destRoot =       "${ENV:psProfileDIR}/Modules/$me"

Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want
    By Filesystem {                                # Deployment type. See Get-PSDeploymentType
        FromSource "$modulesRoot/_src"             
        To         "$destRoot"                     # DependingOn CommonModules
        WithOptions @{
            Mirror = $True
        }
    }
}
