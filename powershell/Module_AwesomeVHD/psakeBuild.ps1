properties {
  $me   = ( $psScriptRoot | Split-Path -Leaf ) -replace 'Module_'
  $files = Get-ChildItem (Join-Path $psScriptRoot _src\include) -recurse -file 
                         
  $simpleTestFiles = Get-ChildItem -path (
                        Join-Path $psScriptRoot _test/Test-*
                    ) -file -errorAction SilentlyContinue
}


# task default -depends Analyze, Test
task default -depends Analyze, Deploy



task Deploy -depends Clean {
  Step-ModuleVersion -Path (Join-Path $psScriptRoot "_src\$me.psd1")
  Invoke-PSDeploy -Path (
      Join-Path $psScriptRoot Module.psdeploy.ps1
  ) -force -verbose:$VerbosePreference
}



task SimpleTest {
  $simpleTestFiles | Foreach-Object { & $_ } 
}



task Clean {

}



task Analyze {
  foreach($1file in $files.FullName){
    $saResults = Invoke-ScriptAnalyzer -path $1file -severity 'Error','Warning' -recurse -verbose:$False
    if ($saResults) {
        $saResults | Format-Table  
        'One or more Script Analyzer errors/warnings where found. 
        Build cannot continue!' -replace '\n\s*', ' ' | Write-Error      
    }
  }
}



task Test {
    $testResults = Invoke-Pester -path $PSScriptRoot -passThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        'One or more Pester tests failed. Build cannot continue!' | Write-Error 
    }
}



task ? -Description "Helper to display task info" {
	Write-Documentation
}
