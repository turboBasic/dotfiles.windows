#region add custom Data types

  Enum EnvironmentScope {
    Process  = 0x0001
    Volatile = 0x0002
    User     = 0x0004
    Machine  = 0x0008
  }

  Enum EnvironmentData {
    Name   = 0x0010
    Value  = 0x0020
    Source = 0x0004
  }

<# TODO delete

        # eg. [EnvironmentScopeType]::User
        Add-Type -TypeDefinition @"
          public enum EnvironmentScopeType {
            Process,
            Volatile,
            User,
            Machine
          }
      "@


        # eg. [EnvironmentDataType]::Source
        Add-Type -TypeDefinition @"
          public enum EnvironmentDataType {
            Name,
            Value,
            Source
          }
      "@
#>

#endregion add custom Data Types



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
      [PARAMETER( Mandatory, 
                  Position=0 )]
          [EnvironmentScope] 
              $From,

      [PARAMETER( Position=1 )]
          [switch] 
              $Write
    )
  #endregion

  switch ($From) {
    User {
        $key =  [MICROSOFT.WIN32.REGISTRYKEY]::OpenBaseKey(
                [MICROSOFT.WIN32.REGISTRYHIVE]::CurrentUser,
                [MICROSOFT.WIN32.REGISTRYVIEW]::Default
        ).OpenSubKey('Environment', $Write)
        break
    }
    Volatile {
        $key  = [MICROSOFT.WIN32.REGISTRYKEY]::OpenBaseKey(
                [MICROSOFT.WIN32.REGISTRYHIVE]::CurrentUser,
                [MICROSOFT.WIN32.REGISTRYVIEW]::Default
        ).OpenSubKey('Volatile Environment', $Write)
        break
    }
    Machine {
        $key  = [MICROSOFT.WIN32.REGISTRYKEY]::OpenBaseKey(
                [MICROSOFT.WIN32.REGISTRYHIVE]::LocalMachine,
                [MICROSOFT.WIN32.REGISTRYVIEW]::Default
        ).OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $Write)
        break
    }
  }
  $key
}



Function Get-RegistryKey($From, $Write) { 
    Write-Warning 'Get-RegistryKey deprecated, use Get-EnvironmentKey instead!'
    Get-EnvironmentKey ($From, $Write) 
}



Function Remove-EnvironmentVariable {
  <#   
      .SYNOPSIS
      This cmdlet deletes environment variable according to set of criteria

      .EXAMPLE
      Remove-EnvironmentVariable -Name Var -Scope User
  #>

  #region Remove-Environment Parameters
    PARAM(
      [PARAMETER( Mandatory, 
                  Position=0 )]
          [string] 
              $Name,

      [PARAMETER( Position=1 )]
          [EnvironmentScope] 
              $Scope
    )
  #endregion#


  BEGIN {}

  PROCESS {
    Write-Verbose "Deleting Environment variable $Name, scope: $Scope"
    if ( $Scope -eq 'Process' ) { 
        Remove-Item ENV:/$Name 
    }
    else {
        (Get-EnvironmentKey $Scope -Write).DeleteValue($Name) 
    }
  }
 
  END {}  
}



Function Remove-UnprotectedVariables {
  Get-ChildItem ENV:\* | 
      Where-Object { $_.Name -NotIn $__protected_variables.Keys } |
          ForEach-Object { 
              Remove-Item ENV:\$_.Name
              Write-Verbose "Deleting environment variable $($_.Name)"
          }
}



Function Send-EnvironmentChanges {

$_nativeMethodType =
@"
  [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
  public static extern IntPtr SendMessageTimeout(
    IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
    uint fuFlags, uint uTimeout, out UIntPtr lpdwResult
  );
"@

    if (-not ("Win32.NativeMethods" -as [Type])) {   # import sendmessagetimeout from win32
     
      Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition $Private:_nativeMethodType
    }

    $HWND_BROADCAST=[IntPtr] 0xffff;
    $WM_SETTINGCHANGE=0x1a;
    $result=[UIntPtr]::Zero

    # notify all windows of environment block change
    [WIN32.NATIVEMETHODS]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, 
                                              [UIntPtr]::Zero, "Environment", 2, 
                                              5000, [ref] $result);
}
