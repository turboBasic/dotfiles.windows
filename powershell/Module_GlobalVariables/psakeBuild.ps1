properties {

  $me = ( $psScriptRoot | Split-Path -leaf ) -replace 'Module_'
  $manifest = Join-Path $psScriptRoot "_src\$me.psd1" | Convert-Path
  
  $simpleTestFiles =  Get-ChildItem -path (
                          Join-Path $psScriptRoot _test\Test-*
                      ) -file -errorAction SilentlyContinue
   
  $profileDir = Split-Path -path $profile -parent
  $scriptsDir = Join-Path $profileDIR Scripts 
  $formatModuleManifest = 
      Join-Path $scriptsDir Format-ModuleManifest.ps1 
      
}



task default -depends Deploy


task Deploy -depends Clean, Bump `
            -description 'Deploys module to run-time locations' {
  Invoke-PSDeploy -path (Join-Path $psScriptRoot Module.psdeploy.ps1) `
                  -force -verbose:$VerbosePreference
}


task Clean -description 'Helper to clean buiild artifacts' {

}


task Bump -description 'Bumps build version of module' {
  . $formatModuleManifest
  Step-ModuleVersion -path $manifest  
  Format-ModuleManifest -path $manifest
}


task SimpleTest -description 'Helper to run ad-hoc tests from _test\Test-...' {
  $simpleTestFiles | Foreach-Object { & $_ } 
}


task Test {
  $testResults = Invoke-Pester -path $PSScriptRoot -passThru
  if ($testResults.FailedCount -gt 0) {
    $testResults | Format-List
    'One or more Pester tests failed. Build cannot continue!' | Write-Error 
  }
}



task ? -description "Helper to display task info" {
	Write-Documentation
}
