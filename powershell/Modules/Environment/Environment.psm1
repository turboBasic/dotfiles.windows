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
        $Scope,

        [parameter( Mandatory=$False,
                    Position=2 )]
        [switch] 
        $Expand        
  )
  #endregion

  #Write-Verbose "expandNameInScope: `$Name = $Name, `$Scope = $Scope, `$Expand = $Expand"
  switch ($Scope) {
    Process {

      $res = Get-ChildItem -Path "env:\$Name" -EA SilentlyContinue | 
                % { [psCustomObject]@{ 
                        Name  = $_.Name; 
                        Value = $_.Value; 
                        Scope = $Scope 
                    } 
                }
      break
    }
    { $_ -in "Volatile", "User", "Machine" } {

      $key = Get-RegistryKey $Scope $False
      $res = $key.GetValueNames() | ? { $_ -like $Name } |
                % { 
                    $item = @{ Name = $_; Scope = $Scope } 
                    if (!$Expand)
                      { $item.Add( "Value", $key.GetValue($_, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames) ) }
                    else
                      { $item.Add( "Value", $key.GetValue($_, $null) ) }

                    [psCustomObject]$item
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

.PARAMETER Scope
  Specifies scope for environment variables to be taken from (Process, Volatile, User, Machine). Accepts multiple scope values and "*".

.EXAMPLE
  PS> Get-Environment -Names Temp -Scope User

  Scope  Names Value
  -----  ----  -----
  User   TEMP  %USERPROFILE%\AppData\Local\Temp

.EXAMPLE
  PS> Get-Environment Temp -Scope User, Machine

  Scope   Names Value
  -----   ----  -----
  User    TEMP  %USERPROFILE%\AppData\Local\Temp
  Machine TEMP  %SystemRoot%\TEMP

.EXAMPLE
  PS> Get-Environment "Temp" 

  Scope   Names Value
  -----   ----  -----
  Process TEMP  c:\Users\kid\AppData\Local\Temp

.EXAMPLE
  PS> Get-Environment *data -Scope User, Volatile

  Scope   Names Value
  -----   ----  ----=
  ......

.EXAMPLE
  PS> "ChocolateyInstall", "Scoop", "Git_Install_Root", "Cmder_Root" | Get-Environment -Scope Machine | Add-Content "~\.envvars.backup.txt"

.EXAMPLE
  PS> Get-Content "~\Desktop\vars.txt" | iex |
      Select @{ label='name'; expression={$_.value} } |
      Get-Environment -Scope Machine  
#>

function Get-Environment {
  #region Parameters
  [CmdletBinding( PositionalBinding=$False )]
  [OutputType( [System.Array] )]
  Param([parameter( Mandatory,
                    Position=0,
                    ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]  
        [string[]] $Names,

        [parameter( Mandatory=$False,
                    Position=1,
                    ValueFromPipeline )]
        [alias("From", "Context")]
        [ValidateScript({ $_ -in "Process", "Volatile", "User", "Machine", "*" })]
        [string[]] $Scope="Process",

        [parameter( Mandatory=$False,
                    Position=2 )]
        [switch] $Expand
  )
  #endregion

  Begin {
    Write-Verbose "Get-Environment: `$Names = $Names, `$Scope = $Scope, `$Expand = $Expand"
    if ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Scope)) {
      $Scope = @([EnvironmentScopeType]"Process", [EnvironmentScopeType]"Volatile", [EnvironmentScopeType]"User", [EnvironmentScopeType]"Machine")
    }
    $res = @()
  }

  Process {
    ForEach ($name in $Names) {
      $isWild = [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Names)
      $type = @{ $False = "Simple"; $True = "Wildcard" }[$isWild]

      Write-Verbose "Get-Environment: $type variable name request: `$Name: $name, `$Scope: $Scope, `$Expand: $Expand"

      ForEach ($_scope in $Scope) {
        $res += (expandNameInScope $name $_scope $Expand)
      }
    }
  }

  End {
    $res | Sort-Object -property Scope, Name, Value | Select-Object Scope, Name, Value -unique
  }

}


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



function Set-Environment {

  #region Set-Environment Parameters
  [CmdletBinding( PositionalBinding=$False )]
  Param(
    [parameter( Mandatory,
                Position=0 )]
    [string]
    $Name,

    [parameter( Mandatory,
                Position=1 )]
    [string]
    $Value,

    [parameter( Mandatory=$False,
                Position=2 )]
    [string]
    $Scope='Process',

    [parameter( Mandatory=$False,
                Position=3 )]
    [switch]
    $Expand
  )
  #endregion


  Begin {
    Write-Verbose "Set-Environment: `$Name = $Name, `$Value = $Value, `$Scope = $Scope, `$Expand = $Expand"
    if ($Expand) 
      { $_type = [Microsoft.Win32.RegistryValueKind]::ExpandString } 
    else 
      { $_type = [Microsoft.Win32.RegistryValueKind]::String }
  }

  Process {
    if ($Scope -eq "Process") {
      if ($Expand) 
        { $Value = [Environment]::ExpandEnvironmentVariables($Value) }
      Set-Item -Path "env:$Name" -Value $Value
      return  
    } 

    Try { 
      $key = Get-RegistryKey $Scope $True
      $key.SetValue($Name, $Value, $_type)
    }
    Catch { 
      Write-Error "Cannot open $Scope / $Name for editing - please switch to elevated cmd!" 
    }
    Finally { 
      if ($key) 
        { $key.Flush() }
    }    
  }

  End {}
}



<#
.SYNOPSIS
  This cmdlet deletes environment variable according to set of criteria

.EXAMPLE
  Remove-EnvironmentVariable -Name Var -Scope User
#>

function Remove-EnvironmentVariable {
  #region Remove-Environment Parameters
  [CmdletBinding( PositionalBinding=$False )]
  Param(
    [parameter( Mandatory,
                Position=0 )]
    [string] 
    $Name,

    [parameter( Position=1 )]
    [EnvironmentScopeType] 
    $Scope='Process'
  )
    
  if ( $Scope -eq 'Process' ) 
    { Remove-Item "env:/$Name" }
  else 
    { (Get-RegistryKey $Scope $True).DeleteValue($Name) }
}



New-Alias -Name genv  Get-Environment
New-Alias -Name ge    Get-Environment
New-Alias -Name senv  Set-Environment
New-Alias -Name se    Set-Environment
New-Alias -Name rmenv Remove-EnvironmentVariable
