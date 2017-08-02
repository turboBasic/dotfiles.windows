$me =          ($psScriptRoot | Split-Path -Leaf) -replace 'Module_'
$sourceRoot =  Join-Path $psScriptRoot _src
$profileDIR =  Split-Path $profile -parent
$destRoot =    Join-Path $profileDIR "Modules/$me"
$scriptsRoot = Join-Path $profileDIR Scripts
$formatModuleManifest = 
      Join-Path $psScriptRoot _src\include\Format-ModuleManifest.ps1

Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want

    Remove-Module $me -errorAction SilentlyContinue
    if( -not(Test-Path $destRoot) ) { 
      $null = New-Item -path $destRoot -itemType directory 
    } 
    
    By Filesystem {                                # Deployment type. See Get-PSDeploymentType
        FromSource  $sourceRoot            
        To          $destRoot
        WithOptions @{ Mirror=$True }
    }
    
}
