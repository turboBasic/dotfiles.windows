function Get-EnvironmentVariable ($name, $scope='User') {
  return (_Get-RegistryKey $scope).GetValue(
    $name, $null,
    [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
  )
}


function Set-EnvironmentVariable ($name, $text, $scope='User', $Expand=$true) {
  if ($Expand) {
    $_type = [Microsoft.Win32.RegistryValueKind]::ExpandString
  } else {
    $_type = [Microsoft.Win32.RegistryValueKind]::String
  }
  (_Get-RegistryKey $scope).SetValue($name, $text, $_type)
  (_Get-RegistryKey $scope).Flush()
}


function Remove-EnvironmentVariable ($name, $scope='User') {
  (_Get-RegistryKey $scope).DeleteValue($name)
}


function script:_Get-RegistryKey($scope='User') {
    switch ($scope.ToLower()) {
        user {  return [Microsoft.Win32.RegistryKey]::OpenBaseKey( 
                    [Microsoft.Win32.RegistryHive]::CurrentUser,  
                    [Microsoft.Win32.RegistryView]::Default
                ).OpenSubKey('Environment', $true)
        }
        machine { return [Microsoft.Win32.RegistryKey]::OpenBaseKey( 
                    [Microsoft.Win32.RegistryHive]::LocalMachine, 
                    [Microsoft.Win32.RegistryView]::Default 
                  ).OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
        }
        default { throw 'getRegistryKey: Scope parameter should be either "Machine" or "User"' }
    }
}




function Get-Environment {
<# 
  .DESCRIPTION
    Some description

  .SYNTAX 
    Get-Environment -Name "Environment variable name" -Machine
    Get-Environment "Environment variable name" -User
    Get-Environment "Environment variable name"
    Get-Environment Environment_Variable_Name_without_Spaces
    Get-Environment LocalAppData -User -Volatile
    Get-Environment HomeDrive -Volatile
    Get-Environment * -User -Volatile

  .SYNOPSIS
    This script creates .

  .NOTES
    Created on:     1/20/15
    Created by:     Andriy Melnyk
    Filename:       New-ScheduledScript.ps1
    Credits:        http://blogs.technet.com/b/heyscriptingguy/archive/2015/01/16/use-powershell-to-create-scheduled-task-in-new-folder.aspx

  .EXAMPLE
    PS> Get-Environment -Name "Environment variable name" -Machine

  .EXAMPLE
    PS> Get-Environment LocalAppData -User -Volatile

  .EXAMPLE
    PS> Get-Environment HomeDrive -Volatile

  .EXAMPLE
    PS> Get-Environment "Environment variable name" -User

  .EXAMPLE
    PS> Get-Environment "Environment variable name"

  .EXAMPLE
    PS> Get-Environment Environment_Variable_Name_without_Spaces

  .EXAMPLE
    PS> Get-Environment * -User -Volatile

  .PARAMETER Name
    The remote or local file path of the Powershell script

  .PARAMETER Machine
    Any parameters to execute with the script

  .PARAMETER User
    If this script is copying a Powershell script from somewhere else, this is the folder path where the
    script will be copied to and referenced to run in the scheduled task.

  .PARAMETER Volatile
    A hashtable of parameters that will be passed to the New-ScheduledTaskTrigger cmdlet.  For available options, visit
    http://technet.microsoft.com/en-us/library/jj649821.aspx.
#>

  [CmdletBinding(DefaultParameterSetName="User",
                 PositionalBinding=$False)]
  Param(
    [parameter(Mandatory=$True,
               Position=0,
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               HelpMessage="Name of environment variable")]
    [string[]]
    $Name,

    [parameter( ParameterSetName="Machine",
                Mandatory=$True,
                HelpMessage="Get environment variable from Machine context" )]
    [switch]
    $Machine,

    [parameter( ParameterSetName="User",
                Mandatory=$False,
                HelpMessage="Get environment variable from Current user context")]
    [switch]
    $User,

    [parameter( ParameterSetName="User",
                Mandatory=$False,
                HelpMessage="Get values from Volatile Environment registry branch")]
    [switch]
    $Volatile
  )


  Begin {

    if ($User -eq $Machine) {  
      $User = !$User
      Write-Verbose "-Machine is $Machine, so I change -User from $(!$User) to $User"
      Write-Verbose "This is possible only when PScmdlet.ParameterSetName is User, so I check: ""$($PScmdlet.ParameterSetName)"""
    }
    Write-Verbose "Executing command Get-Environment -Name $Name -Machine:$Machine -User:$User -Volatile:$Volatile"
    $RegistryKey = $null
    switch ($Machine) {

      $False { 
        $Key = 'Environment'
        if ($Volatile) {
          $Key = 'Volatile ' + $Key
        }
        $RegistryKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey( 
            [Microsoft.Win32.RegistryHive]::CurrentUser,  
            [Microsoft.Win32.RegistryView]::Default
        ).OpenSubKey($Key, $true)
        $Key = 'HKCU\' + $Key
      }

      $True { 
        $Key = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
        $RegistryKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey( 
             [Microsoft.Win32.RegistryHive]::LocalMachine, 
             [Microsoft.Win32.RegistryView]::Default 
        ).OpenSubKey($Key, $false)
        $Key = 'HKLM\' + $Key
      }

    }
    Write-Verbose "Registry path to query variables from: $Key"
  }

  Process {
    ForEach ($envName in $Name) {
      if ($RegistryKey -ne $null) {
        $value = $RegistryKey.GetValue(
            $envName, $null,
            [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
        )
        Write-Verbose "Variable found: Name = $envName ; Value = $value"
        Write-Output $value
      } else {
        Write-Verbose "Variable $envName not found"
        Write-Output $null
      }
    }
  }

  End {
  }

}



function Send-EnvironmentChanges() {

  if (-not ("Win32.NativeMethods" -as [Type])) {
    # import sendmessagetimeout from win32
    Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
      [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
      public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
        uint fuFlags, uint uTimeout, out UIntPtr lpdwResult
      );
"@
  }

  $HWND_BROADCAST = [IntPtr] 0xffff;
  $WM_SETTINGCHANGE = 0x1a;
  $result = [UIntPtr]::Zero

  # notify all windows of environment block change
  [Win32.Nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", 2, 5000, [ref] $result);
}


New-Alias -Name get-env Get-EnvironmentVariable
New-Alias -Name ge      Get-Environment
New-Alias -Name set-env Set-EnvironmentVariable
New-Alias -Name del-env Delete-EnvironmentVariable
