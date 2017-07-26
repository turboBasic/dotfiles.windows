﻿properties {
  $files = Get-ChildItem (Join-Path $psScriptRoot '_src\include') -Recurse -File | Select-Object -ExpandProperty FullName
  $dest = "${ENV:psProfileDIR}/Modules/Environment"
}



# task default -depends Analyze, Test
task default -depends Analyze, Deploy




task Deploy -depends Clean {
  Invoke-PSDeploy -Path '.\Module.psdeploy.ps1' -Force -Verbose:$VerbosePreference
}



task Clean {
  Remove-Module -Force Commands -ErrorAction 0
  Remove-Item (Join-Path $dest '*') -Recurse -Force -ErrorAction 0
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