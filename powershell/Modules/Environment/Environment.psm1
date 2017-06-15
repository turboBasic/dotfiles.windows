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



function Get-RegistryKey {

  #region Get-RegistryKey Parameters
  Param(
    [parameter( Mandatory, Position=0 )]
    [EnvironmentScopeType] 
    $From,

    [parameter( Position=1 )]
    [Boolean] 
    $Write=$False
  )
  #endregion

  switch ($From) {
    User {
        $key =  [Microsoft.Win32.RegistryKey]::OpenBaseKey(
                [Microsoft.Win32.RegistryHive]::CurrentUser,
                [Microsoft.Win32.RegistryView]::Default
        ).OpenSubKey('Environment', $Write)
        break
    }
    Volatile {
        $key =  [Microsoft.Win32.RegistryKey]::OpenBaseKey(
                [Microsoft.Win32.RegistryHive]::CurrentUser,
                [Microsoft.Win32.RegistryView]::Default
        ).OpenSubKey('Volatile Environment', $Write)
        break
    }
    Machine {
        $key =  [Microsoft.Win32.RegistryKey]::OpenBaseKey(
                [Microsoft.Win32.RegistryHive]::LocalMachine,
                [Microsoft.Win32.RegistryView]::Default
        ).OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $Write)
        break
    }
  }
  return $key
}



function expandNameInScope {
  #region expandNameInScope Parameters
  [CmdletBinding()]
  Param([parameter( Mandatory,
                    Position=0 )]
        [string] 
        $Name,

        [parameter( Mandatory,
                    Position=1 )]
        [EnvironmentScopeType] 
        $From
  )
  #endregion

  Write-Verbose "expandNameInScope: `$Name = $Name, `$From = $From"
  switch ($From) {
    Process {

      $res = Get-ChildItem -Path "env:\$Name" -EA SilentlyContinue | 
                % { [psCustomObject]@{ 
                        Name  = $_.Name; 
                        Value = $_.Value; 
                        Scope = $From 
                    } 
                }
      break
    }
    { $_ -in "Volatile", "User", "Machine" } {

      $key = Get-RegistryKey $From $False
      $res = $key.GetValueNames() | ? { $_ -like $Name } |
                % { [psCustomObject]@{  
                        Name  = $_;
                        Value = $key.GetValue($_, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames);
                        Scope = $From
                    }
                }
      break
    }
    default { Throw "expandNameInScope: Strange error in switch statement" }
  }
  Write-Output $res
}


<#  
.SYNOPSIS
  This cmdlet queries Windows Registry for Environment variables based on number of criteria.  The main difference comparing with 
  [Environment]:: methods and $env:variable approach is that
  1) you can specify the scope (eg. User or Machine ) which allows you to access system and user variables independently and
  2) you get %unexpanded% variables which keeps you aware of small details of how your resulting environment built
  3) you can get variables from Volatile (a.k.a. Session) scope which are not returned by `SET` and `Get-ChildItem env:` commands
  4) it fully supports Powershell's pipelines so you can push and pull the data in very exotic and delicate way.

.DESCRIPTION
  Get-Environment: queries Windows registry for Process, Volatile (Session), User and System Environment variables based on number of criteria.

.NOTES
  Created on: 10.06.2017
  Created by: Andriy Melnyk
  Filename:   Environment.psm1
  Credits:    Sorry for this but I have lost the initial source code which inspired me.  Will keep you posted, need to get through my bookmarks archive and web history...

.PARAMETER Names
  Name(s) of environment variable. You can save some typing ("-Names") if variable name is the 1st parameter of the call.  
  Accepts multiple values and standard Powershell wildcards (eg. *, ?, [a-z]).

.PARAMETER From
  Specifies scope for environment variables to be taken from (Process, Volatile, User, Machine). Accepts multiple scope values and "*".

.EXAMPLE
  PS> Get-Environment -Name Temp -From User

  Scope  Name  Value
  -----  ----  -----
  User   TEMP  %USERPROFILE%\AppData\Local\Temp

.EXAMPLE
  PS> Get-Environment Temp -From User, Machine

  Scope   Name Value
  -----   ---- -----
  User    TEMP %USERPROFILE%\AppData\Local\Temp
  Machine TEMP %SystemRoot%\TEMP
#>

function Get-Environment {
  #region Parameters
  [CmdletBinding( PositionalBinding=$False )]
  [OutputType( [System.Array] )]
  Param([parameter( Mandatory,
                    Position=0,
                    ValueFromPipeline,
                    ValueFromPipelineByPropertyName )]
        [string[]] $Names,

        [parameter( Mandatory=$False,
                    Position=1,
                    ValueFromPipelineByPropertyName )]
        [alias("Scope", "Context")]
        [ValidateScript({ $_ -in "Process", "Volatile", "User", "Machine", "*" })]
        [string[]] $From
  )
  #endregion

  Begin {
    Write-Verbose "Get-Environment: `$Names = $Names, `$From = $From"
    if ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($From)) {
      $From = @([EnvironmentScopeType]"Process", [EnvironmentScopeType]"Volatile", [EnvironmentScopeType]"User", [EnvironmentScopeType]"Machine")
    }
    $res = @()
  }

  Process {
    ForEach ($name in $Names) {
      $isWild = [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Names)
      $type = @{ $False = "Simple"; $True = "Wildcard" }[$isWild]

      Write-Verbose "Get-Environment: $type variable name request: $name, scope: $scope"

      ForEach ($scope in $From) {
        $res += (expandNameInScope $name $scope)
      }
    }
  }

  End {
    $res | Sort-Object -property Scope, Name, Value | Select-Object Scope, Name, Value -unique
  }

}

<# TODO - process the rest of below comments:

.SYNTAX
    Get-Environment -Name "Environment variable name" -Machine
    Get-Environment "Environment variable name" -User
    Get-Environment "Environment variable name"
    Get-Environment Environment_Variable_Name_without_Spaces
    Get-Environment LocalAppData -User -Volatile
    Get-Environment HomeDrive -Volatile
    Get-Environment * -User -Volatile
    Get-Environment *64* -System

.EXAMPLE
    PS> Get-Environment -Name "Environment variable" -Machine

.EXAMPLE
    PS> Get-Environment LocalAppData -User -Volatile

.EXAMPLE
    PS> Get-Environment HomeDrive -Volatile

.EXAMPLE
    PS> Get-Environment "Environment variable" -User

.EXAMPLE
    PS> Get-Environment "Environment variable"

.EXAMPLE
    PS> Get-Environment Environment_Variable_Name_without_Spaces

.EXAMPLE
    PS> Get-Environment *data -User -Volatile

.EXAMPLE
    PS> "ChocolateyInstall", "Scoop", "Git_Install_Root", "Cmder_Root" | Get-Environment -Machine | Add-Content "~\.envvars.backup.txt"

.EXAMPLE
    PS> Get-Content "~\Desktop\vars.txt" | iex |
            Select @{ label='name'; expression={$_.value} } |
            Get-Environment -Machine

#>



function Send-EnvironmentChanges {

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



function Set-EnvironmentVariable ([string]$name, [string]$text, [EnvironmentScopeType]$scope='User', [boolean]$Expand=$True) {
  if ($Expand) {
    $_type = [Microsoft.Win32.RegistryValueKind]::ExpandString
  } else {
    $_type = [Microsoft.Win32.RegistryValueKind]::String
  }
  (_Get-RegistryKey $scope).SetValue($name, $text, $_type)
  (_Get-RegistryKey $scope).Flush()
}



function Set-Environment {

  #region Set-Environment Parameters
  [CmdletBinding( DefaultParameterSetName="User",
                  PositionalBinding=$False
  )]
  Param(
    [parameter( Mandatory,
                Position=0,
                ValueFromPipeline,
                ValueFromPipelineByPropertyName,
                HelpMessage="Name of environment variable. Accepts wildcards." )]
    [string[]]
    $Name,

    [parameter( ParameterSetName="Machine",
                Mandatory,
                HelpMessage="Get environment variable from Machine context" )]
    [switch]
    $Machine,

    [parameter( ParameterSetName="User",
                Mandatory=$False,
                HelpMessage="Get environment variable from current User context")]
    [switch]
    $User
  )
  #endregion


  Begin{}


  Process{


  }


  End{}
}



function Remove-EnvironmentVariable ([string]$name, [EnvironmentScopeType]$scope='User') {
  (Get-RegistryKey $scope).DeleteValue($name)
}



New-Alias -Name genv  Get-Environment
New-Alias -Name ge    Get-Environment
New-Alias -Name senv  Set-Environment
New-Alias -Name rmenv Remove-EnvironmentVariable
