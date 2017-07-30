$me =         ($psScriptRoot | Split-Path -Leaf) -replace 'Module_'
$sourceRoot = Join-Path $psScriptRoot _src
$profileDIR = Split-Path $profile -parent
$destRoot =   Join-Path $profileDIR "Modules/$me"

Deploy AllScripts {

  Remove-Module $me -errorAction SilentlyContinue
  if( -not(Test-Path $destRoot) ) { 
    $null = New-Item -path $destRoot -itemType Directory 
  } 

  By Filesystem {                               
    FromSource  $sourceRoot          
    To          $destRoot                    
    WithOptions @{ Mirror=$True }
  }
}
