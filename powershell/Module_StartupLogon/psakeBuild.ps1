properties {
  $files = Get-ChildItem "$psScriptRoot\_src" -Recurse -File | 
                Select-Object -ExpandProperty FullName
                
  $modulesRoot = Join-Path $ENV:projects 'dotfiles.windows/powershell'
  
  $moduleEnvironment = Join-Path $modulesRoot 'Module_Environment/_src/include'
  $moduleCommands = Join-Path $modulesRoot 'Module_Commands/_src/include'
  
  $moduleMerged = Join-Path $psScriptRoot '_build/allScripts.ps1'
}

# task default -depends Analyze, Test
task default -depends Analyze, Deploy


task Deploy -depends Merge {
   Invoke-PSDeploy -Path 'Module.psdeploy.ps1' -Force -Verbose:$VerbosePreference
}



task Merge {
  New-Item -ItemType file -Path $moduleMerged -Force
  $moduleMerged = Resolve-Path $moduleMerged
  
  "Merging all files in $moduleEnvironment, $moduleCommands to $moduleMerged" | 
        Write-Verbose 
  
  $moduleEnvironment, $moduleCommands |
    Get-ChildItem | 
    ForEach-Object { 
      $content = Get-Content $_.FullName -Raw
      Add-Content -Path $moduleMerged -Encoding UTF8 -Value (
          "# $( $_.FullName )`r`n" + $content + ("`r`n" * 5)
      )
    }
}



task Analyze {
  foreach($1file in $files) {
      $saResults = Invoke-ScriptAnalyzer -Path $1file -Severity @('Error', 'Warning') -Recurse -Verbose:$false
      if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'Script Analyzer errors/warnings where found. Build cannot continue!'        
      }
  }
}


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





