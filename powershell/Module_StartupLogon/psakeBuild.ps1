properties {
#   $script = "$PSScriptRoot\ServerInfo.ps1"
    $startupScript = '$psScriptRoot\_src\bbro-startup.ps1'
    $logonScript = '$psScriptRoot\_src\bbro-mao-logon.ps1'
}

# task default -depends Analyze, Test
task default -depends Deploy


task Deploy {
  Invoke-PSDeploy -Path '.\Module.psdeploy.ps1' -Force -Verbose:$VerbosePreference
}



task Analyze -depends Analyze-StartupScript, Analyze-LogonScript



task Analyze-StartupScript {
    $saResults = Invoke-ScriptAnalyzer -Path $startupScript -Severity @('Error', 'Warning') -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
}



task Analyze-LogonScript {
    $saResults = Invoke-ScriptAnalyzer -Path $logonScript -Severity @('Error', 'Warning') -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
}



task Test {
    $testResults = Invoke-Pester -Path $psScriptRoot -PassThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}



task ? -Description "Helper to display task info" {
	Write-Documentation
}



<#
task Deploy -depends Analyze, Test {
    Invoke-PSDeploy -Path '.\ServerInfo.psdeploy.ps1' -Force -Verbose:$VerbosePreference
}
#>





