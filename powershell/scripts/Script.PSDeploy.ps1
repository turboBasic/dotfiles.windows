$sourceROOT =       Join-Path $psScriptRoot installable
$scripts =          Get-ChildItem -path $sourceROOT\*.ps1 -errorAction SilentlyContinue

$profileDIR =       Split-Path $profile -parent
$destROOT =         Join-Path $profileDIR scripts


Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want

    if( -not(Test-Path $destROOT) ) { 
      $null = New-Item -path $destROOT -itemType directory 
    } 
    
    By Filesystem {                                # Deployment type. See Get-PSDeploymentType
        FromSource  $scripts   
        To          $destROOT
    }
    
}


