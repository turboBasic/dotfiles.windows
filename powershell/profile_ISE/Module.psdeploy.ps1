$me =                   ($psScriptRoot | Split-Path -Leaf)
$sourceRoot =           Join-Path $psScriptRoot _src
$profileDIR =           Split-Path $profile -parent
$destRoot =             $profileDIR 
$scriptsRoot =          Join-Path $profileDIR Scripts

Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want

    if( -not(Test-Path $destRoot) ) { 
      $null = New-Item -path $destRoot -itemType directory 
    } 
    
    By Filesystem {                                # Deployment type. See Get-PSDeploymentType
        FromSource  $sourceRoot   
        To          $destRoot
    }
    
}


