#region add custom Data types

<# Add-Type -TypeDefinition @"
  public Enum EnvironmentScope {
    Machine  
    User     
    Volatile 
    Process  
  }
"@  

Add-Type -TypeDefinition @"
  public Enum EnvironmentData {
    Name   
    Value  
    Source 
  }
"@  #>
  
 Enum EnvironmentScope {
    Machine  = 0x0001
    User     = 0x0002
    Volatile = 0x0004
    Process  = 0x0008
  }

  Enum EnvironmentData {
    Name   = 0x0010
    Value  = 0x0020
    Source = 0x0004
  }

#endregion add custom Data Types



#region initialization of module -- dot source the individual scripts that make-up this module

  Write-Verbose "Module $(Split-Path $psScriptRoot -leaf) was successfully loaded."

#endregion



#region shortcut functions (only for saving typing and keyboards)
#endregion



#region Create aliases for functions
  New-Alias -Name genv  Get-Environment            -ErrorAction SilentlyContinue
  New-Alias -Name ge    Get-Environment            -ErrorAction SilentlyContinue
  New-Alias -Name senv  Set-Environment            -ErrorAction SilentlyContinue
  New-Alias -Name se    Set-Environment            -ErrorAction SilentlyContinue
  New-Alias -Name rmenv Remove-EnvironmentVariable -ErrorAction SilentlyContinue
#endregion


#region Create Drives
#endregion

