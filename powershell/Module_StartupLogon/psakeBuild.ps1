properties {
  $me   = ($psScriptRoot | Split-Path -leaf) -replace 'Module_'
  $MergeFile = Join-Path $psScriptRoot _build/allScripts.ps1
  $LogDir = "$ENV:systemROOT\System32\LogFiles\Startup, Shutdown, Logon scripts"
  $logFileName = Join-Path $LogDir StartupLogon.log
  
  $files = Get-ChildItem $psScriptRoot\_src -recurse -file     

  $modulesRoot = Split-Path $psScriptRoot -parent
  $includeFiles = @(
      '..\Module_Commands\_src\include\isnull.ps1',
      '..\Module_Commands\_src\include\Get-TimeStamp.ps1',
      '..\Module_Commands\_src\include\Write-Log.ps1',
      '..\Module_Commands\_src\include\Send-NetMessage.ps1',
      '..\Module_Environment\_src\include\Add-EnvironmentScopeType.ps1',
      '..\Module_Environment\_src\include\Send-EnvironmentChanges.ps1',
      '..\Module_Environment\_src\include\Set-Environment.ps1',
      '..\Module_Environment\_src\include\Get-EnvironmentKey.ps1',
      '..\Module_Environment\_src\include\Import-Environment.ps1', 
      '..\Module_Environment\_src\include\Get-Environment.ps1', 
      '..\Module_Environment\_src\include\Get-Expandedname.ps1'
  ) 
  
  $newEventlogSource = Join-Path $psScriptRoot helpers\new-EventLogSource.ps1
}


task default -depends Clean, Deploy


task Deploy -depends Merge, EventlogSource -description 'Deploys module to run-time locations' {
   sudo Invoke-psDeploy -path 'scripts.psDeploy.ps1' -force    # -verbose:$VerbosePreference
}


task Clean -description 'Helper to clean build artifacts' {
    Remove-Item -path (Join-Path (Split-Path $MergeFile) '*') -recurse
}


task EventlogSource -description 'Register sources for creation of events in the Event log' {
    . $newEventlogSource
}

task EnsureLogDir -description 'Ensure that directory and Log file exist, otherwise elevated credentials required' {
    if( -not (Test-Path $LogDir) ) {
        sudo New-Item -path $LogDir -itemType Directory -force
    } 
    sudo Add-NTFSaccess -path $LogDir -account S-1-5-32-555, S-1-5-32-547 -accessRights Modify -accessType Allow
    if( -not (Test-Path $logFileName) ) {
      sudo New-Item -path $logFileName -itemType File -force
    }
    sudo Add-NTFSaccess -path $logFileName -account S-1-5-32-555, S-1-5-32-547 -accessRights Modify -accessType Allow
}


task Merge -description 'Merges helper functions from other modules into 1 file' {

  New-Item -itemType file -path $MergeFile -force
  $MergeFile = Resolve-Path $MergeFile 
  
  $includeFiles |
    Get-Item | 
    ForEach-Object { 
      "Merge to $( $_.FullName ) to $MergeFile" | Write-Verbose
      $content = Get-Content $_.FullName -raw
      Add-Content -path $MergeFile -encoding UTF8 -value ( @"
#region $( $_.FullName )

$content

#endregion


"@
)
    }
}



task Analyze {
  foreach($1file in $files) {
      $saResults = Invoke-ScriptAnalyzer -path $1file -severity 'Error','Warning' -recurse -verbose:$false
      if ($saResults) {
        $saResults | Format-Table  
        'Script Analyzer errors/warnings where found. Build cannot continue!' | Write-Error      
      }
  }
}

task Analyze-StartupScript {
    $saResults = Invoke-ScriptAnalyzer -path $startupScript -severity 'Error','Warning' -recurse -verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        'One or more Script Analyzer errors/warnings where found. Build cannot continue!' | Write-Error        
    }
}

task Analyze-LogonScript {
    $saResults = Invoke-ScriptAnalyzer -path $logonScript -severity 'Error','Warning' -recurse -verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        'One or more Script Analyzer errors/warnings where found. Build cannot continue!' | Write-Error      
    }
}

task Test {
    $testResults = Invoke-Pester -path $psScriptRoot -passThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
         'One or more Pester tests failed. Build cannot continue!' | Write-Error
    }
}

