properties {

  $me   = ($psScriptRoot | Split-Path -leaf) -replace 'Module_'
  $manifest = Join-Path $psScriptRoot "_src\$me.psd1" | Convert-Path
  
  $files = Get-ChildItem (Join-Path $psScriptRoot '_src\include') -Recurse -File | 
                Select-Object -ExpandProperty FullName
          
  $simpleTestFiles =  Get-ChildItem -path (
                          Join-Path $psScriptRoot _test\Test-*
                      ) -file -errorAction SilentlyContinue
                      
  $formatModuleManifest = 
      Join-Path (Split-path $profile) Scripts\Format-ModuleManifest.ps1

}


task default -depends Deploy     # Analyze, Deploy



task Deploy -depends Clean, Bump `
            -description 'Deploys module to run-time locations' {
  Invoke-PSDeploy -path (Join-Path $psScriptRoot Module.psdeploy.ps1) `
                  -force -verbose:$VerbosePreference
}



task SimpleTest -description 'Helper to run ad-hoc tests from _test\Test-...' {
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
  foreach($1file in $files){
    $saResults = Invoke-ScriptAnalyzer -Path $1file -Severity @('Error', 'Warning') -Recurse -Verbose:$False
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
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
