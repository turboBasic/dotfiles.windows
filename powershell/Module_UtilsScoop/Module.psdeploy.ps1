$me=($psScriptRoot | Split-Path -Parent | Split-Path -Leaf) -replace 'Module_'
$modulesRoot =    "${ENV:projects}/dotfiles.windows/powershell/Module_$me"
$destRoot =       "${ENV:psProfileDIR}/Modules/$me"

Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want
    By Filesystem MainFiles {                      # Deployment type. See Get-PSDeploymentType
        FromSource "$modulesRoot/_src"             # One or more sources to deploy. Absolute, or relative to deployment.yml paren
        To         "$destRoot"                     # One or more destinations to deploy the sources to
        WithOptions @{
            Mirror = $True
        }
    }
}
