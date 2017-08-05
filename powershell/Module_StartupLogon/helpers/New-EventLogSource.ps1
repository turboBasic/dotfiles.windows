"Application,Module_StartupLogon_Machine",
"Application,Module_StartupLogon_User_${ENV:UserName}" | 
    ForEach-Object {
        $log, $source = $_ -split ','
        if(-not( [Diagnostics.EventLog]::SourceExists($source) )) {
            "Creating event source $source on event log $log" | Write-Verbose
            [Diagnostics.EventLog]::CreateEventSource($source, $log)
        } else {
            "Warning: Event source $source already exists. 
             Cannot create this source on Event log $log"| 
                Reduce-WhiteSpaces |
                Write-Warning
        }
    }
