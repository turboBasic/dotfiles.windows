properties {

  $me   = ($psScriptRoot | Split-Path -leaf) -replace 'Module_'
  $manifest = Join-Path $psScriptRoot "_src\$me.psd1" | Convert-Path
  
  $files = Get-ChildItem (Join-Path $psScriptRoot _src\include) -recurse -file
  
  $simpleTestFiles =  Get-ChildItem -path (
                          Join-Path $psScriptRoot _test\Test-*
                      ) -file -errorAction SilentlyContinue
                      
  $formatModuleManifest = 
      Join-Path $psScriptRoot _src\include\Format-ModuleManifest.ps1
      
}

  
  
task default -depends Deploy


task Deploy -depends Clean, Bump `
            -description 'Deploys module to run-time locations' {
  Invoke-PSDeploy -path (Join-Path $psScriptRoot Module.psdeploy.ps1) `
                  -force -verbose:$VerbosePreference
}


task Clean -description 'Helper to clean buiild artifacts' {
    # Clean only build artefacts
    # Deployment artifacts should be cleaned in module.psdeploy.ps1
}


task Bump -description 'Bumps build version of module' {
  . $formatModuleManifest
  Step-ModuleVersion -path $manifest  
  Format-ModuleManifest -path $manifest
}


task Analyze {
  foreach( $1file in $files.FullName ) {
    $saResults = Invoke-ScriptAnalyzer -path $1file `
                      -severity 'Error','Warning' -recurse -verbose:$False
    if ($saResults) {
      $saResults | Format-Table  
      'One or more Script Analyzer errors/warnings where found. 
      Build cannot continue!' -replace '\n\s*',' ' | Write-Error      
    }
  }
}


task Test -description 'Helper to run Pester tests'  {
    $testResults = Invoke-Pester -path $psScriptRoot -passThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        'One or more Pester tests failed. Build cannot continue!' | Write-Error
    }
}


task ? -description "Helper to display task info" {
	Write-Documentation
}
