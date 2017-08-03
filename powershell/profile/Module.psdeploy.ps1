$me =          $psScriptRoot | Split-Path -Leaf
$sourceROOT =  Join-Path $psScriptRoot _src
$files =       Get-ChildItem -path (Join-Path $sourceROOT *.ps1)
$includes =    Join-Path $sourceROOT include

$profileDIR =  Split-Path $profile -parent
$destROOT =    $profileDIR
$destInclude = Join-Path $destROOT profile
$scriptsROOT = Join-Path $profileDIR scripts


Deploy AllScripts {                                

    if( -not(Test-Path $destInclude) ) { 
      $null = New-Item -path $destInclude -itemType directory -force
    } 
    
    By Filesystem {                                
        FromSource  $files   
        To $destROOT
    }

    By Filesystem {                                
        FromSource $includes   
        To $destInclude
        WithOptions @{
            Mirror = $true
        }
    }
    
}


