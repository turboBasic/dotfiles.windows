#region E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\isnull.ps1

Function IsNull($objectToCheck) {

    if ($objectToCheck -eq $null) {
        return $true
    }

    if ($objectToCheck -is [String] -and $objectToCheck -eq [String]::Empty) {
        return $true
    }

    if ($objectToCheck -is [DBNull] -or $objectToCheck -is [System.Management.Automation.Language.NullString]) {
        return $true
    }

    return $false

}

#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Get-TimeStamp.ps1

Function Get-TimeStamp {
<#

.SYNOPSIS
    returns Timestamp string

.DESCRIPTION
    Get-TimeStamp produces sortable and not dependent on current culture timestamp using local time of user.

.PARAMETER dateDelimiter
    Symbol or string which delimits day, month and year numbers. Default value is ‘.’

.PARAMETER timeDelimiter
    Symbol or string which delimits hours, minutes and seconds. Default value is ‘:’

.PARAMETER Delimiter
    Symbol or string which delimits date and time parts of the timestamp. Default value is ‘ ’

.PARAMETER NoFractionOfSecond
    Generates timestamp without fraction part of the seconds. By default timestamp is generated with an accuracy of a thousandth of second. This parameter has alias ‘WholeSeconds’ 

.PARAMETER NoDelimiters
    Generates timestamp without delimiters

.PARAMETER Short
    Generates timestamp without delimiters and fractions of second

.EXAMPLE
    PS> Get-TimeStamp
    2017.07.12 12:16:15.455

.EXAMPLE
    PS> Get-TimeStamp -dateDelimiter '-'
    2017-07-12 12:16:32.015

.EXAMPLE
    PS> Get-TimeStamp -timeDelimiter ''
    2017.07.12 121643.934

.EXAMPLE
    PS> Get-TimeStamp -Delimiter '___'
    2017.07.12___12:16:56.911

.EXAMPLE
    PS> Get-TimeStamp -NoFractionOfSecond
    2017.07.12 12:17:11

    PS> Get-TimeStamp -WholeSeconds
    2017.07.12 12:17:11

.EXAMPLE
    PS> Get-TimeStamp -dateDelimiter '...' -timeDelimiter '' -Delimiter '_' -WholeSeconds
    2017...07...12_121732

.EXAMPLE
    PS> Get-TimeStamp -NoDelimiters
    20170712121746.790

.EXAMPLE
    PS> Get-TimeStamp -NoDelimiters -NoFractionOfSecond
    20170712121758

.EXAMPLE
    PS> Get-TimeStamp -Short
    20170712121810

.INPUTS
    Does not accept input from the pipeline

.OUTPUTS
    Outputs [String] as the only type of result

.NOTES
Name:    Get-TimeStamp
Author:  Andriy Melnyk  https://github.com/TurboBasic/
Created: 2017.07.12 11:55:31.113

#>


  [CMDLETBINDING( PositionalBinding=$False )]
  [OUTPUTTYPE( [String]) ]
  PARAM(
      [PARAMETER( ParameterSetName='Full Specification' )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [String]
      $dateDelimiter = '.',

      [PARAMETER( ParameterSetName='Full Specification' )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [String]
      $timeDelimiter = ':',

      [PARAMETER( ParameterSetName='Full Specification' )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [String]
      $Delimiter = ' ',

      [PARAMETER( ParameterSetName='Full Specification' )]
      [PARAMETER( ParameterSetName='No Delimiters' )]
      [ALIAS( 'WholeSeconds' )]
      [Switch]
      $NoFractionOfSecond,

      [PARAMETER( Mandatory, 
                  ParameterSetName='No Delimiters' )]
      [Switch]
      $NoDelimiters,

      [PARAMETER( Mandatory, 
                  ParameterSetName='Short' )]
      [Switch]
      $Short
  )





  if( $PsCmdlet.ParameterSetName -in 'No Delimiters', 'Short' ) {
    $dateDelimiter = $timeDelimiter = $Delimiter = ''
  }

  if( $PsCmdlet.ParameterSetName -eq 'Short' ) {
    $NoFractionOfSecond = $True
  }

  if( $NoFractionOfSecond ) {
    $fractions = ''
  } else {
    $fractions = '.fff'
  }

  ( "{0:yyyy${dateDelimiter}", 
    "MM${dateDelimiter}", 
    "dd${Delimiter}",
    "HH${timeDelimiter}", 
    "mm${timeDelimiter}", 
    "ss${fractions}}" -join '') -f (Get-Date)

}


#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Write-Log.ps1

Function Write-Log { 
  [CMDLETBINDING()]
  PARAM( 
      [PARAMETER( Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [ALLOWEMPTYSTRING()]
      [ALLOWNULL()]
      [String[]]
      $Message,

      [PARAMETER( Mandatory, Position=1, ValueFromPipelineByPropertyName )]
      [ALIAS('FilePath')]
      [String]
      $logFile
  )

  BEGIN{}

  PROCESS{
      foreach($m in $Message) {
          $m | Out-File -FilePath $logFile -Encoding UTF8 -Append -Force
      }
  }

  END{}
}



#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Send-NetMessage.ps1

Function Send-NetMessage {
<#  
    .SYNOPSIS  
        Sends a message to network computers
 
    .DESCRIPTION  
        Allows the administrator to send a message via a pop-up textbox to multiple computers
 
    .EXAMPLE  
        Send-NetMessage "This is a test of the emergency broadcast system.  This is only a test."
 
        Sends the message to all users on the local computer.
 
    .EXAMPLE  
        Send-NetMessage "Updates start in 15 minutes.  Please log off." -Computername testbox01 -Seconds 30 -VerboseMsg -Wait
 
        Sends a message to all users on Testbox01 asking them to log off.  
        The popup will appear for 30 seconds and will write verbose messages to the console. 
    
    .EXAMPLE
        ".",$Env:Computername | Send-NetMessage "Fire in the hole!" -Verbose
        
        Pipes the computernames to Send-NetMessage and sends the message "Fire in the hole!" with verbose output
        
        VERBOSE: Sending the following message to computers with a 5 delay: Fire in the hole!
        VERBOSE: Processing .
        VERBOSE: Processing MyPC01
        VERBOSE: Message sent.
        
    .EXAMPLE
        Get-ADComputer -filter * | Send-NetMessage "Updates are being installed tonight. Please log off at EOD." -Seconds 60
        
        Queries Active Directory for all computers and then notifies all users on those computers of updates.  
        Notification stays for 60 seconds or until user clicks OK.
        
    .NOTES  
        Author: Rich Prescott  
        Blog: blog.richprescott.com
        Twitter: @Rich_Prescott
#>

PARAM(
    [PARAMETER( Mandatory )]
        [String]$Message,
    
        [String]$Session='*',
    
    [PARAMETER( ValueFromPipeline, ValueFromPipelineByPropertyName )]
    [ALIAS( 'Name' )]
        [String[]]$Computername=$env:computername,
    
        [Int]$Seconds='5',
        [Switch]$VerboseMsg,
        [Switch]$Wait
)
    
    
BEGIN {
    Write-Verbose "Sending the following message to computers with a $Seconds second delay: $Message"
}
    
PROCESS {
    ForEach ($Computer in $ComputerName) {
        Write-Verbose "Processing $Computer"
        $cmd = "msg.exe $Session /Time:$($Seconds)"
        if ($Computername) {$cmd += " /SERVER:$($Computer)"}
        if ($VerboseMsg) {$cmd += ' /V'}
        if ($Wait) {$cmd +=  '/W'}
        $cmd += " $($Message)"

        Invoke-Expression $cmd
    }
}
    
    
END {
    Write-Verbose 'Message sent.'
}

}



#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Add-EnvironmentScopeType.ps1

#region add custom Data types

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

#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Send-EnvironmentChanges.ps1

Function Send-EnvironmentChanges {
    if (-Not ('Win32.NativeMethods' -as [Type])) {   

      #import sendmessagetimeout from win32
      Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @'

          [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
          public static extern IntPtr SendMessageTimeout(
              IntPtr hWnd, 
              uint Msg, 
              UIntPtr wParam, 
              string lParam,
              uint fuFlags, 
              uint uTimeout, 
              out UIntPtr lpdwResult
          );
'@  }

    $HWND_BROADCAST   = [System.IntPtr]0xffff;
    $WM_SETTINGCHANGE = 0x1a;
    $result           = [System.UIntPtr]::Zero

    # notify all windows of environment block change
    [Win32.NativeMethods]::SendMessageTimeout( 
        $HWND_BROADCAST, $WM_SETTINGCHANGE, 
        [System.UIntPtr]::Zero, 
        'Environment', 
        2, 
        5000, 
        [ref]$result
    ) | Out-Null
}

#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Set-Environment.ps1

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

#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Get-EnvironmentKey.ps1

#. (Join-Path $psScriptRoot 'Add-EnvironmentScopeType.ps1')

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

#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Import-Environment.ps1

Function Import-Environment {

  #region Parameters
    [CMDLETBINDING( SupportsShouldProcess, ConfirmImpact='Medium' )]
    PARAM(
        [PARAMETER( Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [Hashtable]
        $Environment,

        [PARAMETER( Mandatory, Position=1 )]
        [EnvironmentScope]
        $Scope,

        [PARAMETER()]  # Reset environment
        [Switch]
        $Initialise 
    )
  #endregion

  Write-Verbose "`n Import-Environment `n"
  $Environment.Keys | 
      ForEach { 
          Set-Environment -Name $_ -Value $Environment[$_] -Scope $Scope -Expand:($Environment[$_] -match '%..*%') 
      }

  Send-EnvironmentChanges 
}

#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Get-Environment.ps1

Function Get-Environment {
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

    .PARAMETER Names
Name(s) of environment variable. You can save some typing ("-Names") if variable name is the 1st parameter of the call.  
Accepts multiple values and standard Powershell wildcards (eg. *, ?, [a-z]).

    .PARAMETER Scope
Specifies scope for environment variables to be taken from (Process, Volatile, User, Machine). Accepts list of multiple scope values and wildcard "*".

    .INPUTS
Takes variable names from [string[]] object from the pipeline.  Also capable of taking an array of scopes from pipeline properties.

    .OUTPUTS
Outputs to the pipeline [System.Array] object containing [psCustomObject] type items

    .EXAMPLE
PS> Get-Environment -Names Temp -Scope User

Scope      Names      Value
-----      ----       -----
User       TEMP       %USERPROFILE%\AppData\Local\Temp

    .EXAMPLE
PS> Get-Environment Temp -Scope User, Machine

Scope      Names      Value
-----      ----       -----
User       TEMP       %USERPROFILE%\AppData\Local\Temp
Machine    TEMP       %SystemRoot%\TEMP

    .EXAMPLE
PS> Get-Environment "Temp" 

Scope      Names      Value
-----      ----       -----
Process    TEMP       c:\Users\kid\AppData\Local\Temp

    .EXAMPLE
PS> Get-Environment *data -Scope User, Volatile

Scope      Names      Value
-----      ----       ----=
......                

    .EXAMPLE
PS> "ChocolateyInstall", "Scoop", "Git_Install_Root", "Cmder_Root" | Get-Environment -Scope Machine | Add-Content "~\.envvars.backup.txt"

    .EXAMPLE
PS> Get-Content "~\Desktop\vars.txt" | iex |
    Select @{ label = 'name'; expression = {$_.value} } |
    Get-Environment -Scope Machine  

    .NOTES
Created on: 10.06.2017
Author:     Andriy Melnyk  https://github.com/TurboBasic/
Filename:   Get-Environment.ps1
Credits:    Sorry but I have lost the initial source code which inspired me.  Will keep you posted, need to get through my bookmarks archive and web history...
#>




  #region FunctionParameters
  
    [CmdletBinding( PositionalBinding=$False )]
    [OutputType([System.Array])]
    PARAM(
        [PARAMETER( Mandatory, Position=0, ValueFromPipeline,  ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]  
        [string[]] 
        $Names,

        [PARAMETER( Position=1, ValueFromPipelineByPropertyName )]
        [ALIAS( 'From', 'Context' )]
        [ValidateScript({
          ($_ -in [enum]::GetNames([EnvironmentScope])) -or ($_ -eq '*') 
        })]
        [string[]]
        $Scope='Process',

        [PARAMETER( Position=2 )]
        [switch] 
        $Expand
    )
    
  #endregion



  BEGIN {
    Write-Verbose "Get-Environment: `$Names=$Names, `$Scope=$Scope, `$Expand=$Expand"
    if ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Scope)) {
      $Scope = [enum]::GetNames([EnvironmentScope]) | Where { $_ -like $Scope }
    }
    $res = @()
  }

  PROCESS {
    foreach ($name in $Names) {
      $isWild = [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Names)
      $type = @{ $False='Simple'; $True='Wildcard' }[$isWild]

      Write-Verbose "Get-Environment: $type variable name request: `$Name: $name, `$Scope: $Scope, `$Expand: $Expand"

      foreach ($_scope in $Scope) {
        $res += (Get-ExpandedName -Name $name -Scope $_scope $Expand)
      }
    }
  }

  END {
    $res | Sort -Property Scope, Name, Value          # | Select Scope, Name, Value -Unique
  }

}

#endregion


#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Get-Expandedname.ps1

Function Get-ExpandedName {
<#

.SYNOPSIS
    Expands references to a Variable (%VARIABLE%) in specified Windows environment scope

.DESCRIPTION
    Expands references to variables in CMD.EXE format (eg. %VARIABLE%) and replaces them with actual content of variable. Argument Scope specifies the scope from which the utility is going to take Variable's content.

.PARAMETER dateDelimiter

.PARAMETER timeDelimiter

.PARAMETER Delimiter

.PARAMETER NoFractionOfSecond

.PARAMETER NoDelimiters

.PARAMETER Short

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.INPUTS
    Does not accept input from the pipeline

.OUTPUTS
    Outputs [psCustomObject] as the only type of result

.NOTES
Name:    Get-TimeStamp
Author:  Andriy Melnyk  https://github.com/TurboBasic/
Created: 2017.03.10 10:54:31.713

#>

  #region Get-ExpandedName Parameters
      [CMDLETBINDING()] 
      [OUTPUTTYPE( [psCustomObject] )]
      PARAM( 
          [PARAMETER( Mandatory, Position=0 )]
          [VALIDATENOTNULLOREMPTY()]
          [String] 
          $Name,

          [PARAMETER( Position=1 )]
          [EnvironmentScope] 
          $Scope='Process',

          [PARAMETER( Position=2 )]
          [Switch] 
          $Expand
      )
  #endregion



  switch ([String]$Scope) {

    'Process' {

      $res = Get-ChildItem -Path ENV:\$Name -EA SilentlyContinue | 
                ForEach { [psCustomObject][ordered]@{ 
                        Scope = $Scope 
                        Name  = $_.Name; 
                        Value = $_.Value; 
                    } 
                }
      break
    }

    { $_ -in @('Volatile', 'User', 'Machine') } {

      $key = Get-EnvironmentKey -From $Scope -Write:$False
      $res = $key.GetValueNames() | 
                Where { $_ -like $Name } |
                ForEach { 
                  $item = [ordered]@{ Scope = $Scope; Name = $_ } 
                  if (!$Expand) { 
                    $item.Add( 
                        'Value', 
                        $key.GetValue(
                            $_, $null, 
                            [Microsoft.Win32.RegistryValueOptions]::
                            DoNotExpandEnvironmentNames
                        ) 
                    ) 
                  } else { 
                    $item.Add( 'Value', $key.GetValue($_, $null) ) 
                  }
                  [psCustomObject]$item
                }
      break
    }

    default { Throw "Get-ExpandedName: Argument 'Scope' has illegal value $Scope" }

  }

  $res

}

#endregion


