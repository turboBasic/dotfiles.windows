. (Join-Path $psScriptRoot 'Add-EnvironmentScopeType.ps1')

Function Get-EnvironmentKey {
<#
  .SYNOPSIS
      Returns Registry key which holds particular part of Machine or User 
      environment variables

  .DESCRIPTION
      Helper function Returns Registry key which holds particular part of Machine or User 
      environment variables. Does not modify registry.

#>



  #region Get-EnvironmentKey Parameters
    PARAM(
        [PARAMETER( Mandatory, Position=0 )]
        [EnvironmentScope] 
        $From,

        [PARAMETER( Position=1 )]
        [Switch] 
        $Write
    )
  #endregion



  switch ($From) {
    User {
        $key =  [Microsoft.Win32.RegistryKey]::OpenBaseKey(
                [Microsoft.Win32.RegistryHive]::CurrentUser,
                [Microsoft.Win32.RegistryView]::Default
        ).OpenSubKey( 'Environment', $Write ) 
        break
    }
    Volatile {
        $key  = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
                [Microsoft.Win32.RegistryHive]::CurrentUser,
                [Microsoft.Win32.RegistryView]::Default
        ).OpenSubKey( 'Volatile Environment', $Write )
        break
    }
    Machine {
        $key  = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
                [Microsoft.Win32.RegistryHive]::LocalMachine,
                [Microsoft.Win32.RegistryView]::Default
        ).OpenSubKey( 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $Write )
        break
    }
  }
  $key
}


# Deprecated
Function Get-RegistryKey($From, $Write) { 
    Write-Warning 'Get-RegistryKey deprecated, use Get-EnvironmentKey instead!'
    Get-EnvironmentKey ($From, $Write) 
}