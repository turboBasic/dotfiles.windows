Function Set-Environment {

  #region Set-Environment Parameters
    [CMDLETBINDING( POSITIONALBINDING = $False )] PARAM(
        [PARAMETER( Mandatory,
                    Position = 0 )]
                [string]
                $Name,
  
        [PARAMETER( Mandatory,
                    Position = 1 )]
                [string]
                $Value,
  
        [PARAMETER( Mandatory = $False,
                    Position = 2 )]
                [string]
                $Scope = 'Process',
  
        [PARAMETER( Mandatory = $False,
                    Position = 3 )]
                [switch]
                $Expand
    )
  #endregion


  BEGIN {
    Write-Verbose "Set-Environment: `$Name=$Name, `$Value=$Value, `$Scope=$Scope, `$Expand=$Expand"
    if ($Expand) 
      { $_type = [Microsoft.Win32.RegistryValueKind]::ExpandString } 
    else 
      { $_type = [Microsoft.Win32.RegistryValueKind]::String }
  }

  PROCESS {
    if ($Scope -eq 'Process') {
      if ($Expand) 
        { $Value = [Environment]::ExpandEnvironmentVariables($Value) }
      Set-Item -Path ENV:\$Name -Value $Value
      return  
    } 

    Try { 
      $key = Get-EnvironmentKey $Scope $True
      $key.SetValue( $Name, $Value, $_type )
    }
    Catch { 
      Write-Error "Cannot open $Scope / $Name for editing - please switch to elevated cmd!" 
    }
    Finally { 
      if ($key) 
        { $key.Flush() }
    }    
  }

  END {}
}