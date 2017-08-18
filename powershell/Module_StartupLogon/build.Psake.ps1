properties {
  $me =           (Split-Path $PSScriptRoot -leaf) -replace 'Module_'
  $deployScript = Join-Path $PSScriptRoot scripts.PSDeploy.ps1
  
  $modulesDir =   Split-Path $PSScriptRoot -parent
  $sourceDir =    Join-Path $PSScriptRoot _src
  $buildDir =     Join-Path $PSScriptRoot _build
                  
  $sourceFiles =  Get-ChildItem $sourceDir -recurse -file     
  $includeFiles = 
      'Module_Text/_src/public/Remove-LeadingSpace.ps1',
      'Module_Text/_src/public/Remove-NewLineAndIndent.ps1',
      'Module_Commands/_src/include/isNull.ps1',
      'Module_Commands/_src/include/Get-TimeStamp.ps1',
      'Module_Commands/_src/include/Send-NetMessage.ps1',
      'Module_Commands/_src/include/Write-Log.ps1',   
      'Module_Environment/_src/include/Add-EnvironmentScopeType.ps1',
      'Module_Environment/_src/include/Send-EnvironmentChanges.ps1',
      'Module_Environment/_src/include/Get-EnvironmentKey.ps1',
      'Module_Environment/_src/include/Set-Environment.ps1',
      'Module_Environment/_src/include/Import-Environment.ps1', 
      'Module_Environment/_src/include/Get-Environment.ps1', 
      'Module_Environment/_src/include/Get-Expandedname.ps1' |
          ForEach-Object {
            Join-Path $modulesDir $_
          }
  
  $logDir = Join-Path -path $ENV:systemROOT -childPath (
              "System32\
               LogFiles\
               Startup, Shutdown, Logon scripts" | Remove-NewlineAndIndent
            )
  $logFileName = Join-Path $logDir StartupLogon.log     
}


task default -depends Clean, Deploy


task Deploy -depends Merge, CreateEventLogSource -description 'Deploys module to run-time locations' {
   sudo Invoke-PSDeploy -path $deployScript -force    # -verbose:$VerbosePreference
}


task Clean -description 'Clean build artifacts' {
    Remove-Item -path $buildDir/* -recurse
}


task CreateEventLogSource -description 'Registers event sources for the Applications event log' {

    "Application, Module_StartupLogon_Machine",
    "Application, Module_StartupLogon_User_${ENV:UserName}" | 
        ForEach-Object {
          $log, $source = $_ -split ', '
          if( -not [Diagnostics.EventLog]::SourceExists($source) ) {
            "Creating event source $source on event log $log" | Write-Verbose
            [Diagnostics.EventLog]::CreateEventSource($source, $log)
          } else {
            "Warning: Event source $source already exists in Event log $log" | 
                Write-Warning
          }
        }
        
}


task EnsureLogDir -description 'Ensures that directory and Log file exist, otherwise elevated credentials required' {
    $accounts = 'BUILTIN\Power Users', 'BUILTIN\Remote Desktop Users'

    if( -not (Test-Path $logDir) ) {
        sudo New-Item -path $logDir -itemType Directory -force
    } 
    sudo Add-NTFSaccess -path $logDir -account $accounts -accessRights Modify -accessType Allow
    if( -not (Test-Path $logFileName) ) {
      sudo New-Item -path $logFileName -itemType File -force
    }
    sudo Add-NTFSaccess -path $logFileName -account $accounts -accessRights Modify -accessType Allow
}


task Merge -depends Clean -description 'Merges helper functions from other modules into 1 file' {
  
<#
function Remove-LeadingSpace {
    ($Input + $Args) | ForEach { $_ -replace '(?mx) ^ [^\S\n\r]*' } 
} 
#>
  
  $content = ''
  $includeFiles |
    ForEach-Object { 
      "Merge to $_ to $mergeFile" | Write-Verbose
      $content += ( @'
          #region {0}
          
          {1}
          
          #endregion
          
          
'@        -replace '(?mx) ^ [^\S\n\r]*'
      ) -f $_, (Get-Content $_ -raw)
      
    }
    
    
  $sourceFiles |
      ForEach-Object {
        $params = @{
          itemType =  'File'
          path =      Join-Path $buildDir $_.Name
          value =     $content + (Get-Content $_.FullName -raw)
        }
        New-Item @params
      }
    
}



task Analyze {
  foreach($1file in $sourceFiles) {
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
    $testResults = Invoke-Pester -path $PSScriptRoot -passThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
         'One or more Pester tests failed. Build cannot continue!' | Write-Error
    }
}

