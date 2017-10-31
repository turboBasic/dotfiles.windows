#region E:\0projects\dotfiles.windows\powershell\Module_Text\_src\public\Remove-LeadingSpace.ps1

function Remove-LeadingSpace {

    ($Input + $Args) |     
        ForEach { $_ -replace '(?mx) ^ [^\S\n\r]*' } 
}
# -replace '^[^\S\n\r]*'
# -replace '(?m)^\s+(\S.*)$', '$1'

#endregion

#region E:\0projects\dotfiles.windows\powershell\Module_Text\_src\public\Remove-NewLineAndIndent.ps1

function Remove-NewlineAndIndent {

  ($Input + $Args) |
      ForEach-Object { $_ -replace '(?s)\s*[\r\n]\s*' }

}

#endregion

#region E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\isNull.ps1

function IsNull($objectToCheck) {

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

function Get-TimeStamp {
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
  [OUTPUTTYPE( [string] )]
  PARAM(
      [PARAMETER( ParameterSetName='Full Specification' )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [string]
      $dateDelimiter = '.',

      [PARAMETER( ParameterSetName='Full Specification' )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [string]
      $timeDelimiter = ':',

      [PARAMETER( ParameterSetName='Full Specification' )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [string]
      $Delimiter = ' ',

      [PARAMETER( ParameterSetName='Full Specification' )]
      [PARAMETER( ParameterSetName='No Delimiters' )]
      [ALIAS( 'WholeSeconds' )]
      [switch]
      $NoFractionOfSecond,

      [PARAMETER( Mandatory, 
                  ParameterSetName='No Delimiters' )]
      [switch]
      $NoDelimiters,

      [PARAMETER( Mandatory, 
                  ParameterSetName='Short' )]
      [switch]
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

#region E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Send-NetMessage.ps1

function Send-NetMessage {
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
      [string]
      $Message,

      [PARAMETER()]
      [string]
      $Session='*',
    
      [PARAMETER( ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [ALIAS( 'Name' )]
      [string[]]
      $Computername=$env:computername,
    
      [int]
      $Seconds='5',

      [switch]
      $VerboseMsg,

      [switch]
      $Wait
  )
    
  
  
  BEGIN {
      Write-Verbose "Sending the following message to computers with a $Seconds second delay: $Message"
  }
    

  PROCESS {
      ForEach ($Computer in $ComputerName) {
          Write-Verbose "Processing $Computer"
          $cmd = "msg.exe $Session /Time:$($Seconds)"
          if ($Computername) { $cmd += " /SERVER:$($Computer)" }
          if ($VerboseMsg) { $cmd += ' /V' }
          if ($Wait) { $cmd +=  '/W' }
          $cmd += " $($Message)"

          Invoke-Expression $cmd
      }
  }
    
    
  END {
      Write-Verbose 'Message sent.'
  }

}



#endregion

#region E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Write-Log.ps1

function Write-Log { 

  [CMDLETBINDING()]
  PARAM( 
      [PARAMETER( Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [AllowEmptyString()] [AllowNULL()]
      [string[]]
      $Message,

      [PARAMETER( Mandatory, Position=1, ValueFromPipelineByPropertyName )]
      [ALIAS('FilePath')]
      [String]
      $logFile
  )


  BEGIN{}

  PROCESS{
      foreach($m in $Message) {
          $m | Out-File -filePath $logFile -encoding UTF8 -append -Force
      }
  }

  END{}
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

#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Get-EnvironmentKey.ps1

function Get-EnvironmentKey {
<#
  .SYNOPSIS
Returns Registry key which holds particular part of Machine or User environment variables

  .DESCRIPTION
Helper function Get-EnvironmentKey returns Registry key which holds particular part of Machine or User environment variables. 
Does not modify registry.

#>


    [CmdletBinding()]
    PARAM(
        [PARAMETER( Mandatory, Position=0 )]
        [EnvironmentScope]
        [ALIAS( 'scope', 'context' )]
        $from
    )



    switch( $from ) {
    
        'Process' {
            $Null
            break
        }
    
        'User' {
            Get-Item -path HKCU:/Environment
            break
        }
        
        'Volatile' {
            Get-Item -path 'HKCU:/Volatile Environment'
            break
        }
        
        'Machine' {
            Get-Item -path ( 
              'HKLM:/SYSTEM/CurrentControlSet/
                  Control/Session Manager/Environment' | Remove-NewlineAndIndent
            )
            break
        }
        
    }

}

#endregion

#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Set-Environment.ps1

function Set-Environment {

  [CmdletBinding( PositionalBinding = $False )] 
  PARAM(
      [PARAMETER( Mandatory, Position=0 )]
      [string]
      $Name,

      [PARAMETER( Mandatory, Position=1 )]
      [string]
      $Value,

      [PARAMETER( Position=2 )]
      [string]
      $Scope = 'Process',

      [PARAMETER( Position=3 )]
      [switch]
      $Expand
  )


  BEGIN {
      $type = 'String'
      if( $Expand ) { 
          $type = 'ExpandString' 
      }
  }

  PROCESS {
      if( $Scope -eq 'Process' ) {
          if( $Expand ) { 
              $Value = [Environment]::ExpandEnvironmentVariables( $Value ) 
          }
          Set-Item -path ENV:\$Name -value $Value
          return  
      } 

      Try { 
          $key = Get-EnvironmentKey -scope $Scope
          Set-ItemProperty -path $key.PSPath -name $Name -value $Value -type $type
      } Catch { 
          "Cannot open $Scope / $Name for editing - please 
              switch to elevated cmd!" | Remove-NewLineAndIndent | Write-Error
      } Finally { 
          if( $key ) { 
            $key.Flush() 
          }
      }    
  }

  END {}
}

#endregion

#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Import-Environment.ps1

function Import-Environment {

  [CMDLETBINDING( SupportsShouldProcess, ConfirmImpact='Medium' )]
  PARAM(
      [PARAMETER( Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [hashtable]
      $Environment,

      [PARAMETER( Mandatory, Position=1 )]
      [EnvironmentScope]
      $Scope,

      [PARAMETER()]  # Reset environment
      [switch]
      $Initialise 
  )


  Write-Verbose "`n Import-Environment `n"
  $Environment.Keys | 
      ForEach { 
          Set-Environment -name $_ -value $Environment[$_] -scope $Scope -expand:($Environment[$_] -match '%..*%') 
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


  
    [CmdletBinding( PositionalBinding=$False )]
    [OutputType( [Array] )]
    PARAM(
        [PARAMETER( Mandatory, Position=0, ValueFromPipeline,  ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
          $_[0].length -gt 0   -or 
          $(Throw "name is mandatory ({0})" -f $MyInvocation.MyCommand)
        } )]        
        [string[]] 
        $name,

        [PARAMETER( Position=1, ValueFromPipelineByPropertyName )]
        [ALIAS( 'from', 'context' )]
        [ValidateScript( {
            if( [Management.Automation.WildcardPattern]::
                    ContainsWildcardCharacters($_)
            ){
                $_ = [enum]::GetNames([EnvironmentScope]) -like $_
                $True
            } elseif( $_ -notIn [enum]::GetNames([EnvironmentScope])
            ){   
                Throw "name is mandatory ({0})" -f $MyInvocation.MyCommand
            }
            $True
        } )]
        [string[]]
        $scope='Process',

        [PARAMETER()]
        [switch] 
        $expand
    )
    



  BEGIN {
    Write-Verbose "Get-Environment: `$names=$names, `$scope=$scope, `$expand=$expand"
    if ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($scope)) {
      $scope = [enum]::GetNames([EnvironmentScope]) -like $scope
    }
    $res = @()
  }

  PROCESS {
    foreach ($1name in $name) {
      $isWild = [Management.Automation.WildcardPattern]::ContainsWildcardCharacters($1name)
      $type = @{ $False='Simple'; $True='Wildcard' }[$isWild]

      Write-Verbose "Get-Environment: $type variable name request: `$name: $1name, `$scope: $scope, `$expand: $expand"

      foreach ($1scope in $scope) {
        $res += (Get-ExpandedName -name $1name -scope $1scope $expand)
      }
    }
  }

  END {
    $res | Sort-Object -property Scope, Name, Value 
  }

}




#endregion

#region E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Get-Expandedname.ps1

function Get-ExpandedName {
<#
    .SYNOPSIS
Expands references to a Variable (%VARIABLE%) in specified Windows environment scope

    .DESCRIPTION
Expands references to variables in CMD.EXE format (eg. %VARIABLE%) and replaces them with actual content of variable. Argument Scope specifies the scope from which the utility is going to take Variable's content.

    .PARAMETER name

    .PARAMETER scope

    .PARAMETER expand

    .EXAMPLE
PS> Get-ExpandedName -name PATH -scope Machine -expand | Format-List   

Scope : Machine
Name  : PATH
Value : C:\WINDOWS;C:\WINDOWS\system32;C:\WINDOWS\system32\wbem;C:\WINDOWS\system32\windowsPowerShell\v1.0;C:\Python27\;C:\Python27\Scripts

    .INPUTS
Does not accept input from the pipeline

    .OUTPUTS
Outputs [PSCustomObject] as the only type of result

    .NOTES
Name:    Get-TimeStamp
Author:  Andriy Melnyk  https://github.com/turboBasic/
Created: 2017.03.10 10:54:31.713

#>


    [CmdletBinding()] 
    [OutputType( [PSCustomObject] )]
    PARAM( 
        [PARAMETER( Mandatory, Position=0 )]
        [ValidateNotNullOrEmpty()]
        [string] 
        $name,

        [PARAMETER( Position=1 )]
        [EnvironmentScope] 
        $scope = [EnvironmentScope]::Process,

        [PARAMETER( Position=2 )]
        [switch] 
        $expand
    )



    switch( $scope ) {

        [EnvironmentScope]::Process {

            Get-ChildItem -path ENV:\$Name -errorAction SilentlyContinue | 
                ForEach-Object { 
                  [PSCustomObject][ordered]@{ 
                      Scope = $scope 
                      Name  = $_.Name; 
                      Value = $_.Value; 
                  } 
                }
            break
        }

        { $_ -in [EnvironmentScope]::Volatile, 
                 [EnvironmentScope]::User, 
                 [EnvironmentScope]::Machine } {
                 
            $key = Get-EnvironmentKey -from $scope
            $key.GetValueNames() | 
                Where-Object { 
                  $_ -like $Name 
                } |
                ForEach-Object { 
                  $item = [ordered]@{ 
                      Scope = $Scope
                      Name = $_ 
                  } 
                  if( -not $Expand ) { 
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
                  [PSCustomObject]$item
                }
            break
        }

        default { 
            Throw "Get-ExpandedName: Argument 'Scope' has illegal value $Scope" 
        }
    }

}

#endregion

# User Logon script %systemRoot%\System32\GroupPolicy\User\Scripts\Logon\bbro-mao-logon.ps1 


    #region     constants

      $registryKey = 'HKCU:\Software\Cargonautika'
  
      $__user_variables = @{ 

        appDATA =       ${ENV:appDATA} -replace 'Users','users'

     '..userFullNAME' = [Environment]::GetFolderPath('UserProfile') | 
                            Split-Path -leaf
                            
     '..homePATH' =     '%..usersROOT%\%..userFullNAME%'
     '..scoop' =        '%..homeDRIVE%%..homePATH%\scoop'
        scoop  =        '%..homeDRIVE%%..homePATH%\scoop'
                        
     '..psProfileDIR' = '%..homeDRIVE%%..homePATH%\documents\windowsPowerShell'
        psProfileDIR  = '%..homeDRIVE%%..homePATH%\documents\windowsPowerShell'

        nvm_Home =      '%..scoop%\apps\nvm\current'
        nvm_Symlink =   '%..scoop%\apps\nvm\current\nodeJs'
        nodePath =      '%..scoop%\apps\nvm\current\nodeJs' -join ';'

        githubUser =    'turboBasic'
        githubUser2 =   'maoizm'
        githubGist =    '%githubAPI%/users/%githubUser%/gists'
        githubGist2 =   '%githubAPI%/users/%githubUser2%/gists'  

        dropbox =       '%systemDRIVE%\dropbox'
        dropbox_Home =  '%systemDRIVE%\dropbox'
        oneDRIVE =      '%systemDRIVE%\oneDRIVE'
        projects =      'E:\0projects'              
        winPepsiDebug = 1
             
        PSModulePATH =   '%..psProfileDir%\Modules',
                         '%psHOME%\Modules',
                         '%programFILES%\WindowsPowerShell\Modules' -join ';'


        PATH =          '%..homeDRIVE%%..homePATH%\bin',  
                        '%..scoop%\shims',
                        '%nodePath%',      
                        '%appDATA%\boxStarter',
                        '%oneDrive%\01_portable_apps',
                        '%junkPath%'  -join ';'                    
                        
        TEMP =          '%localAppDATA%\temp'
        TMP =           '%localAppDATA%\temp'
        ubuntu =        '%localAppDATA%\lxss\rootfs'
      }
      
      $eventLogParams = @{
        logName = "Application" 
        source =  "Module_StartupLogon" 
        eventID =  3001
      }
      
    #endregion 

    
    if( -not (Test-Path $registryKey) ) {
        New-Item -path $registryKey -force -errorAction SilentlyContinue
        if( -not $? ) { 
          "Error during creation of registry key $registryKey" | Write-Warning 
        }
    }
    if( IsNull (Get-ItemProperty -path $registryKey).NextBoot ) {
        'No requests to initialize. exiting...' | Write-Verbose 
    }
    Set-ItemProperty -path $registryKey -name 'NextBoot' -value ''


  #region     writing header
      
      $message = ( Remove-NewlineAndIndent @"
          [ {0,-7} {1,-6} {2} ]
          User logon script '{3}', '{4}'
          
"@    ) -f  'user', 'header', (Get-TimeStamp), 
            (Split-Path $PSCommandPath -leaf), $PSCommandPath
          
      Write-EventLog @eventLogParams -message $message
      Send-NetMessage "User logon script $PSCommandPath"

  #endregion


  Import-Environment -environment $__user_variables -scope User

  
  #region initialization of variables dump procedure
  
      $params = @{ 
        scope = [EnvironmentScope]::User
        expand = $True
      }
      
      $allVars = Get-Environment * -scope User | 
          Select-Object Name, Value, @{ Name = 'Expanded'
                                        Expression = {
                                          $params.Name = $_.Name
                                          (Get-ExpandedName @params).Value 
                                        } 
          }
      
      $width = [ordered]@{ 
          Name =      27
          Value =     53
          Expanded = 'any'
      }
      $columns = [array]$width.keys
  
  #endregion initialization
  
  #region print headings
     
    $message = ( Remove-LeadingSpace @"
        [ {0,-7} {1,-6} {2} ]
        {3,-$( $width.Name )} {4,-$( $width.Value )} {5}
    
"@    ) -f '', 'body', (Get-TimeStamp), $columns[0], $columns[1], $columns[2]
    Write-EventLog @eventLogParams -message $message
    
  #endregion

      
  #region print variables  
    $printOnce = @{ Name=1; Value=1 }
    $message = ''
    
    $allVars | 
        ForEach-Object {
          $name = $_.Name
          $value = $_.Value -split ';'
          
          $printOnce.Name = 1
          $value | 
              ForEach-Object {      
                $text = "{0,-$( $width.Name )}" -f ($name * $printOnce.Name)
                $printOnce.Name = 0
             
                $expValue = [Environment]::ExpandEnvironmentVariables($_) -split ';'

                $currentValue = $_
                $printOnce.Value = 1
                $expValue | 
                    ForEach-Object { 
                      $message += "$text {0,-$( $width.Value )} {1} `r`n" -f 
                          ($currentValue * $printOnce.Value), $_
                      
                      $printOnce.Value = 0
                    }
          }
    }
    Write-EventLog @eventLogParams -message $message
  #endregion    