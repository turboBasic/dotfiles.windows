$me =               $psScriptRoot | Split-Path -Leaf
$sourceROOT =       Join-Path $psScriptRoot _src
$includes =         Get-ChildItem -path (
                      Join-Path $psScriptRoot _src\$me\include
                    ) -file -recurse -errorAction SilentlyContinue

$profileDIR =       Split-Path $profile -parent
$destROOT =         $profileDIR 
$scriptsROOT =      Join-Path $profileDIR scripts


Deploy AllScripts {                                # Deployment name. This needs to be unique. Call it whatever you want

    if( -not(Test-Path $destROOT) ) { 
      $null = New-Item -path $destROOT -itemType directory 
    } 
    
    By Filesystem {                                # Deployment type. See Get-PSDeploymentType
        FromSource  $sourceROOT   
        To          $destROOT
    }
    
}


