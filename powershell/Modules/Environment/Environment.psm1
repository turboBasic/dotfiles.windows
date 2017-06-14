# eg. [EnvironmentScopeType]::User
Add-Type -TypeDefinition @"
  public enum EnvironmentScopeType {
    CurrentProcess, Process,
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


function ge {
[CmdletBinding( PositionalBinding=$False )]
[OutputType( [System.Array] )]
Param([parameter( Mandatory,
                  Position=0,
                  ValueFromPipeline,
                  ValueFromPipelineByPropertyName,
                  HelpMessage="Name of environment variable. Accepts multiple values and wildcards." )]
      [string[]] $Name,

      [parameter( Mandatory=$False,
                  ValueFromPipelineByPropertyName,
                  HelpMessage="Scope of environment variable. Accepts multiple values of [EnvironmentScopeType] type and ``*``." )]
      [EnvironmentScopeType[]]
      $From
)

Begin {
  Write-Verbose "`$Name=$Name, `$From=$From"
  $res = @()
}

Process {

  $item = "" | select name, value, source 
  $item.name = "env_var_1"
  $item.value = "1024 cr" 
  $item.source = [EnvironmentScopeType]::CurrentProcess

  $res += $item
}

End {
  $res
}

}



function G_V_Process { return "%ProcessValue%" }
function G_V_Volatile { return "%VolatileValue%" }
function G_V_User { return "%UserValue%" }
function G_V_Machine { return "%MachineValue%" }



function G_V {
  [CmdletBinding( DefaultParameterSetName="All",
                PositionalBinding=$False )]
  Param(  [parameter( Mandatory,
                      Position=0 )]
          [string] $Name,

          [parameter( Mandatory )]
          [EnvironmentContextType[]] $Context
  )


  Begin {

  }

  Process {
    $res = @()
    ForEach ($ctx in $Context) {
      $item = "" | select name, value, source
      $item.name = $Name
      $item.source = $ctx
      switch ($ctx) {
        Process   { $item.value = G_V_Process $Name;  break }
        Volatile  { $item.value = G_V_Volatile $Name; break }
        User      { $item.value = G_V_User $Name; break }  
        Machine   { $item.value = G_V_Machine $Name; break }
      }
      $res += $item
    }
  }

  End {
    return $res
  }

}



function VariableOutput([string]$Name, [psCustomObject]$Value) {
  Write-Output @{ $Name = $Value }
}

function Get_E {
  [CmdletBinding( DefaultParameterSetName="All",
                  PositionalBinding=$False )]
  [OutputType([System.Collections.Hashtable[]])]
  Param(  [parameter( Mandatory,
                      Position=0,
                      ValueFromPipeline,
                      ValueFromPipelineByPropertyName,
                      HelpMessage="Name of environment variable. Accepts wildcards." )]
          [string[]]
          $Name,

          [parameter( ParameterSetName="All" )]      
          [parameter( ParameterSetName="Context", Mandatory )]
          [parameter( ParameterSetName="Data" )]
          [parameter( ParameterSetName="VariableNameData" )]
          [parameter( ParameterSetName="ValueData" )]
          [parameter( ParameterSetName="SourceData" )]
          [EnvironmentScopeType[]]
          $Context,
          
          [parameter( ParameterSetName="ProcessContext", Mandatory )]
          [parameter( ParameterSetName="VolatileContext" )]
          [parameter( ParameterSetName="UserContext" )]
          [parameter( ParameterSetName="MachineContext" )]
          [parameter( ParameterSetName="Data" )]
          [parameter( ParameterSetName="VariableNameData" )]
          [parameter( ParameterSetName="ValueData" )]
          [parameter( ParameterSetName="SourceData" )]
          [switch]
          $Process,
          
          [parameter( ParameterSetName="ProcessContext" )]
          [parameter( ParameterSetName="VolatileContext", Mandatory )]
          [parameter( ParameterSetName="UserContext" )]
          [parameter( ParameterSetName="MachineContext" )]
          [parameter( ParameterSetName="Data" )]
          [parameter( ParameterSetName="VariableNameData" )]
          [parameter( ParameterSetName="ValueData" )]
          [parameter( ParameterSetName="SourceData" )]
          [switch]
          $Volatile,
          
          [parameter( ParameterSetName="ProcessContext" )]
          [parameter( ParameterSetName="VolatileContext" )]
          [parameter( ParameterSetName="UserContext", Mandatory )]
          [parameter( ParameterSetName="MachineContext" )]
          [parameter( ParameterSetName="Data" )]
          [parameter( ParameterSetName="VariableNameData" )]
          [parameter( ParameterSetName="ValueData" )]
          [parameter( ParameterSetName="SourceData" )]
          [switch]
          $User,
          
          [parameter( ParameterSetName="ProcessContext" )]
          [parameter( ParameterSetName="VolatileContext" )]
          [parameter( ParameterSetName="UserContext" )]
          [parameter( ParameterSetName="MachineContext", Mandatory )]
          [parameter( ParameterSetName="Data" )]
          [parameter( ParameterSetName="VariableNameData" )]
          [parameter( ParameterSetName="ValueData" )]
          [parameter( ParameterSetName="SourceData" )]
          [switch]
          $Machine,

          [parameter( ParameterSetName="All" )]            
          [parameter( ParameterSetName="Context" )]
          [parameter( ParameterSetName="ProcessContext" )]
          [parameter( ParameterSetName="VolatileContext" )]
          [parameter( ParameterSetName="UserContext" )]
          [parameter( ParameterSetName="MachineContext" )]
          [parameter( ParameterSetName="Data", Mandatory )]
          [EnvironmentDataType[]]
          $Data,
          
          [parameter( ParameterSetName="Context" )]
          [parameter( ParameterSetName="ProcessContext" )]
          [parameter( ParameterSetName="VolatileContext" )]
          [parameter( ParameterSetName="UserContext" )]
          [parameter( ParameterSetName="MachineContext" )]
          [parameter( ParameterSetName="VariableNameData", Mandatory )]
          [parameter( ParameterSetName="ValueData" )]
          [parameter( ParameterSetName="SourceData" )]
          [alias("VarName")]
          [switch]
          $VariableName,
          
          [parameter( ParameterSetName="Context" )]
          [parameter( ParameterSetName="ProcessContext" )]
          [parameter( ParameterSetName="VolatileContext" )]
          [parameter( ParameterSetName="UserContext" )]
          [parameter( ParameterSetName="MachineContext" )]
          [parameter( ParameterSetName="VariableNameData")]
          [parameter( ParameterSetName="ValueData", Mandatory  )]
          [parameter( ParameterSetName="SourceData" )]
          [switch]
          $Value,
          
          [parameter( ParameterSetName="Context" )]
          [parameter( ParameterSetName="ProcessContext" )]
          [parameter( ParameterSetName="VolatileContext" )]
          [parameter( ParameterSetName="UserContext" )]
          [parameter( ParameterSetName="MachineContext" )]
          [parameter( ParameterSetName="VariableNameData" )]
          [parameter( ParameterSetName="ValueData"  )]
          [parameter( ParameterSetName="SourceData", Mandatory )]
          [switch]
          $Source,
          
          [parameter()]
          [switch]
          $AllDeclarations,
          
          [parameter()]
          [switch]
          $Expand
  )

  Begin {
    #$allParameters = (Get-Command Get_E).Parameters
    $allParameters = "Name", "Context", "Process", "Volatile", "User", "Machine", "Data", "VariableName", "Value", 
    "Source", "AllDeclarations", "Expand" | % { Get-Variable $_ -Scope Local -EA SilentlyContinue }
  }

  Process {

    ForEach ($n in $name) {
      $isWild = [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($n)
      switch ($isWild) {
        $False {  Write-Verbose "Simple variable name=$n"
                  $_var = G_V -Name $n -Context $Context
                  VariableOutput -Name $n -Value $_var              #Write-Output @{ $n = G_V $n }
                  Break
        }
        $True {   Write-Verbose "Wildcard item ${n}: replacing with array of $($n.Length) items"    
                  $n_expand = "fakevar1", "fakevar2", "fakevar10"       # fake variables satisfying wildcard
                  ForEach ($nn in $n_expand) {
                    Write-Verbose "Simple variable name=$nn"
                    $_var = G_V -Name $n -Context $Context
                    VariableOutput -Name $nn -Value $_var          # Write-Output @{ $nn = G_V $nn }
                  }
                  Break
        }
      }
    }

  }

  End {

  }
}



<# 
.SYNOPSIS
    This cmdlet queries Windows Registry for Environment variables based on number of criteria.  The main difference comparing with [Environment]:: methods and $env:variable approach is that   
      1) you specify -User or -Machine switches which allows to access system and user variables independently and 
      2) you get %unexpanded% variables which keeps you aware of small details of how your resulting environment built
      3) you can get -Volatile variables which are not returned by `SET` and `Get-ChildItem env:` commands (this works only for -User context and throws if you try to do it in -Machine context)
      4) it fully supports Powershell's pipelines so you can push and pull the data in very exotic and delicate way.

.DESCRIPTION
    Get-Environment Windows Registry for System and User Environment variables based on number of criteria. 

.SYNTAX 
    Get-Environment -Name "Environment variable name" -Machine
    Get-Environment "Environment variable name" -User
    Get-Environment "Environment variable name"
    Get-Environment Environment_Variable_Name_without_Spaces
    Get-Environment LocalAppData -User -Volatile
    Get-Environment HomeDrive -Volatile
    Get-Environment * -User -Volatile
    Get-Environment *64* -System

.NOTES
    Created on:     10.06.2017
    Created by:     Andriy Melnyk
    Filename:       Environment.psm1
    Credits:        Sorry for this but I have lost the initial source code which inspired me.  Will keep you posted, need to get through my bookmarks archive and web history...

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

.PARAMETER Name
    Name of environment variable. You can save some typing ("-Name") if variable name is the 1st parameter of the call.  Name accepts traditional Powershell wildcards (*, ?, [a-z])

.PARAMETER Machine
    -Machine switch makes function return variable from Machine context. You are right that by default function queries -User context.

.PARAMETER User
    Default behavior of function: return variable from User context.  If you are fine with that you may save typing `-User` though keeping it explicit might help someone to understand your code.

.PARAMETER Volatile
    -Volatile switch allows to find obscure "volatile" variables existing in -User context, which can't be seen using `SET` and `Get-ChildItem` commands.  Those are LocalAppData, HomeDrive, HomePath ans so forth. The nature of these variables is so that they are created every logon session and keep their values only within logon sessions. Once again, they exist in -User context only, do not try to query them together with -Machine switch otherwise Get-Environment will throw.
#>
function Get-Environment {

  [CmdletBinding( DefaultParameterSetName="User",
                  PositionalBinding=$False 
  )]
  [OutputType([System.Collections.Hashtable[]])]
  Param(  [parameter( Mandatory,
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
                      HelpMessage="Get environment variable from current User context" )]
          [switch]
          $User,

          [parameter( ParameterSetName="User",
                      Mandatory=$False,
                      HelpMessage="Get values from Volatile Environment branch of User context" )]
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
    if ($RegistryKey -eq $null) {
      Write-Error "Cannot open registry Key $RegistryKey"
      Throw 1
    }
  }

  Process {
    ForEach ($envName in $Name) {
      $isWild = [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($envName)
      if ($isWild) {
        $envNames = $RegistryKey.GetValueNames() | Where { $_ -like $envName }
        Write-Verbose "Wildcard found in ${envName} item: replacing with array of $($envNames.Length) items"
        ForEach ($smallName in $envNames) {
          $value = $RegistryKey.GetValue(
            $smallName, $null,
            [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
          )
          Write-Verbose "Variable found: Name = $smallName ; Value = $value"
          Write-Output @{ $smallName = $value }
        }
      } else {
        $value = $RegistryKey.GetValue(
            $envName, $null,
            [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
        )
        Write-Verbose "Variable found: Name = $envName ; Value = $value"
        Write-Output @{ $envName = $value }
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



function Set-Environment {

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



  Begin{}
 
                                                          
  Process{


  }


  End{}
}



function Remove-EnvironmentVariable ($name, $scope='User') {
  (_Get-RegistryKey $scope).DeleteValue($name)
}



function Get-RegistryKey {
  [CmdletBinding()]
  Param(
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

  Begin {}

  Process {
    switch (!$Machine) {
        $True {  return [Microsoft.Win32.RegistryKey]::OpenBaseKey( 
                    [Microsoft.Win32.RegistryHive]::CurrentUser,  
                    [Microsoft.Win32.RegistryView]::Default
                ).OpenSubKey('Environment', $true)
        }
        $False { return [Microsoft.Win32.RegistryKey]::OpenBaseKey( 
                    [Microsoft.Win32.RegistryHive]::LocalMachine, 
                    [Microsoft.Win32.RegistryView]::Default 
                  ).OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
        }
        default { throw 'getRegistryKey: Scope parameter should be either "Machine" or "User"' }
    }
  }

  End {
  }
}



<#
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
} #>

New-Alias -Name get-env Get-EnvironmentVariable
#New-Alias -Name ge      Get-Environment
New-Alias -Name set-env Set-EnvironmentVariable
New-Alias -Name del-env Delete-EnvironmentVariable
