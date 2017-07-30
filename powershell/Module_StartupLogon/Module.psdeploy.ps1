$modulesRoot =       Join-Path $ENV:projects    'dotfiles.windows/powershell'
$moduleMerged =      Join-Path $psScriptRoot    '_build/allScripts.ps1'

$sourceRoot =        Join-Path $psScriptRoot    '_src'
$startupScript =     Join-Path $sourceRoot      'bbro-startup.ps1'
$logonScript =       Join-Path $sourceRoot      'bbro-mao-logon.ps1'

$destRoot =          Join-Path $ENV:systemROOT  'system32/GroupPolicy'
$destUser =          Join-Path $destRoot        'User/Scripts/Logon'
$destMachine =       Join-Path $destRoot        'Machine/Scripts/Startup'



Deploy AllScripts {
                                                          #   Deployment name. This needs to be unique. Call it whatever you want
    By Filesystem {                                       #   Deployment type. See Get-PSDeploymentType
        FromSource  $logonScript,                         #   One or more sources to deploy. Absolute, or relative to deployment.yml paren
                    $moduleMerged                         #   One or more destinations to deploy the sources to
                                                                  
        To          $destUser                                     
    }

    By Filesystem {
        FromSource  $startupScript,
                    $moduleMerged

        To          $destMachine
    }

}