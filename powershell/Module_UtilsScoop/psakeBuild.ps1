properties {

  $me   = ( $psScriptRoot | Split-Path -leaf ) -replace 'Module_'
  $manifest = Join-Path $psScriptRoot _src\$me.psd1 | Convert-Path
  
  $files = Get-ChildItem (Join-Path $psScriptRoot _src\include) -recurse -file 
  $simpleTestFiles =  Get-ChildItem (
                        Join-Path $psScriptRoot _test\Test-*
                      ) -file -errorAction SilentlyContinue

  $profileDir = Split-Path -path $profile -parent
  $scriptsDir = Join-Path $profileDIR Scripts 
  $formatModuleManifest = 
      Join-Path $scriptsDir Format-ModuleManifest.ps1                     
}



task default -depends Deploy   # Analyze, Deploy



task Deploy -depends Clean,Bump -description 'Deploys module to run-time locations' {
  Invoke-PSDeploy -path (Join-Path $psScriptRoot Module.psdeploy.ps1) `
                  -force -verbose:$VerbosePreference
}



task SimpleTest {
  $simpleTestFiles | Foreach-Object { & $_ } 
}



task Clean {

}


task Bump -description 'Bumps build version of module' {
  . $formatModuleManifest
  Step-ModuleVersion -path $manifest  
  Format-ModuleManifest -path $manifest
}


task Analyze {
  foreach($1file in $files.FullName){
    $saResults = Invoke-ScriptAnalyzer -path $1file -severity 'Error','Warning' -recurse -verbose:$False
    if ($saResults) {
      $saResults | Format-Table  
      'One or more Script Analyzer errors/warnings where found. Build cannot continue!' | Write-Error
    }
  }
}



task Test {
    $testResults = Invoke-Pester -Path $PSScriptRoot -PassThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}



task ? -Description "Helper to display task info" {
	Write-Documentation
}
