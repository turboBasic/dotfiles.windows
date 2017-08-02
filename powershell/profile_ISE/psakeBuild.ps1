properties {

  $me = $psScriptRoot | Split-Path -leaf 
  $includes = Get-ChildItem -path (
                  Join-Path $psScriptRoot _src\profile_ISE\include
              )  -file -recurse -errorAction SilentlyContinue
  
  $simpleTestFiles = Get-ChildItem -path (
                          Join-Path $psScriptRoot _test\Test-*
                     ) -file -errorAction SilentlyContinue
}

  
task default -depends Deploy     # Analyze, Deploy


task Deploy -depends Clean, Bump -description 'Deploys module to run-time locations' {
  Invoke-PSDeploy -path (Join-Path $psScriptRoot Module.psdeploy.ps1) -force -verbose:$VerbosePreference
}


task Clean -description 'Helper to clean build artifacts' {
    # Clean only build artefacts
    # Deployment artifacts should be cleaned in module.psdeploy.ps1
}


task Bump -description 'Bumps build version of script' {
  # @TODO(create Bump utility for standalone scripts)
  #. $formatModuleManifest
  #Step-ModuleVersion -path $manifest  
  #Format-ModuleManifest -path $manifest
}


task SimpleTest -description 'Helper to run ad-hoc tests from _test\Test-...' {
  $simpleTestFiles | Foreach-Object { & $_ } 
}


task Analyze {
  foreach( $file in $includes.FullName ) {
    $saResults = Invoke-ScriptAnalyzer -path $file `
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
