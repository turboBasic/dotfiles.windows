# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Add-EnvironmentScopeType.ps1
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





# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Export-Environment.ps1
Function Export-Environment {

  PARAM(
      [PARAMETER( Position=0 )]
      [VALIDATESCRIPT({ $_.IndexOfAny( [System.IO.Path]::GetInvalidFileNameChars() ) -eq -1 })]
      [String]
      $Path = 'export_{0}.csv' -f (Get-Date -uFormat "%Y%m%d_%H:%M:%S")

      # TODO -NoClobber
      # TODO -Append
  )

  Get-Environment * * | 
        ConvertTo-Csv -noTypeInformation | 
        Out-File $Path -Encoding UTF8 -NoClobber

}





# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Get-Environment.ps1
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
  Credits:    Sorry for this but I have lost the initial source code which inspired me.  Will keep you posted, need to get through my bookmarks archive and web history...
#>




  #region FunctionParameters
    [CMDLETBINDING( PositionalBinding=$False )]
    [OUTPUTTYPE( [System.Array] )]
    PARAM(
        [PARAMETER( Mandatory, Position=0, ValueFromPipeline,  ValueFromPipelineByPropertyName )]
        [VALIDATENOTNULLOREMPTY()]  
        [String[]] 
        $Names,

        [PARAMETER( Position=1, ValueFromPipelineByPropertyName )]
        [ALIAS( 'From', 'Context' )]
        [VALIDATESCRIPT({
          . (Join-Path $psScriptRoot 'Add-EnvironmentScopeType.ps1')
          ($_ -in [enum]::GetNames( [EnvironmentScope] )) -or ($_ -eq '*') 
        })]
        [String[]]
        $Scope='Process',

        [PARAMETER( Position=2 )]
        [Switch] 
        $Expand
    )
  #endregion



  BEGIN {
#    . (Join-Path $psScriptRoot 'Add-EnvironmentScopeType.ps1')
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
    $res | Sort -Property Scope, Name, Value # | Select Scope, Name, Value -Unique
  }

}





# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Get-EnvironmentKey.ps1
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





# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Get-EnvironmentTable.ps1
Function Get-EnvironmentTable {
    $vars =     Get-Environment * * | select -expandProperty Name | sort -unique
    $scopes =   [enum]::GetNames([EnvironmentScope])

    $res = @()
    foreach($v in $vars) {
      $item = [psCustomObject][ordered]@{ Variable=$v; Machine=''; User=''; Volatile=''; Process='' }
      foreach($s in $scopes) {
        $value = Get-ExpandedName -Name $v -Scope $s | Select -expandProperty Value
        if($v -like '*path') {
          $item.$s = ($value -split ';') -join "`n"
        } else {
          $item.$s = $value
        }
      }
      $res += $item
    }

    $a = @{Label="Variable"; Expression={$_.Variable}; width=25}, 
         @{Label="Machine";  Expression={$_.Machine};  width=60}, 
         @{Label="User";     Expression={$_.User};     width=55},
         @{Label="Volatile"; Expression={$_.Volatile}; width=28},
         @{Label="Process";  Expression={$_.Process};  width=80}

    $res | Format-Table $a -Wrap
}





# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Get-ExpandedName.ps1
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





# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Import-Environment.ps1
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





# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Remove-EnvironmentVariable.ps1
. (Join-Path $psScriptRoot 'Add-EnvironmentScopeType.ps1')

Function Remove-EnvironmentVariable {
  <#   
      .SYNOPSIS
      This cmdlet deletes environment variable according to set of criteria

      .EXAMPLE
      Remove-EnvironmentVariable -Name Var -Scope User
  #>

  #region Remove-EnvironmentVariable Parameters
    PARAM(
      [PARAMETER( Mandatory, Position=0 )]
      [String] 
      $Name,

      [PARAMETER( Position=1 )]
      [EnvironmentScope] 
      $Scope='Process'
    )
  #endregion


  BEGIN {}

  PROCESS {
    Write-Verbose "Deleting environment variable $Name, scope: $Scope"
    if ( $Scope -eq 'Process' ) { 
        Remove-Item ENV:$Name 
    }
    else {
        (Get-EnvironmentKey $Scope -Write).DeleteValue($Name) 
    }
  }
 
  END {}  
}










# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Remove-UnprotectedVariables.ps1
$__protected_variables = @{
    ALLUSERSPROFILE         = 'C:\programData'
    CommonProgramFiles      = 'C:\program Files\common Files'
   'CommonProgramFiles(x86)'= 'C:\program Files (x86)\common Files'
    COMPUTERNAME            = 'BBRO'
    NUMBER_OF_PROCESSORS    = '8'
    OS                      = 'Windows_NT'
    PATHEXT                 = '.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC'
    PROCESSOR_ARCHITECTURE  = 'AMD64'
    PROCESSOR_IDENTIFIER    = 'Intel64 Family 6 Model 42 Stepping 7, GenuineIntel'
    PROCESSOR_LEVEL         = '6'
    PROCESSOR_REVISION      = '2a07'
    ProgramData             = 'C:\programData'
    ProgramFiles            = 'C:\program Files'
   'ProgramFiles(x86)'      = 'C:\program Files (x86)'
    ProgramW6432            = 'C:\program Files'
    PUBLIC                  = 'C:\users\public'
    systemDRIVE             = 'C:'
    systemROOT              = 'C:\windows'
                              
    APPDATA                 = 'C:\users\mao\appData\roaming'
    HOMEDRIVE               = 'C:'
    HOMEPATH                = '\users\mao'
    LOCALAPPDATA            = 'C:\users\mao\appData\local'
    LOGONSERVER             = '\\BBRO'
    USERDOMAIN              = 'BBRO'
    USERNAME                = 'mao'
    USERPROFILE             = 'C:\users\mao'
}

Function Remove-UnprotectedVariables {
  Get-ChildItem ENV: | 
      Where Name -NotIn $__protected_variables.Keys |
      ForEach { 
          Remove-Item ENV:\$_.Name
          Write-Verbose "Deleting environment variable $($_.Name)"
      }
}






# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Send-EnvironmentChanges.ps1
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





# E:\0projects\dotfiles.windows\powershell\Module_Environment\_src\include\Set-Environment.ps1
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





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Add-FileDetails.ps1
Function Add-FileDetails {

  PARAM(
    [PARAMETER( ValueFromPipeline )]
    $fileobject,

    $hash = @{ 
        Artists = 13
        Album   = 14
        Year    = 15
        Genre   = 16
        Title   = 21
        Length  = 27
        Bitrate = 28 
    }
  )



  BEGIN {
    $shell = New-Object -ComObject Shell.Application
  }

  
  PROCESS {
  
    if( !$_.psIsContainer ) {
      $folder = Split-Path $fileobject.FullName
      $file = Split-Path $fileobject.FullName -Leaf
      $shellfolder = $shell.Namespace($folder)
      $shellfile = $shellfolder.ParseName($file)
      Write-Progress 'Adding Properties' $fileobject.FullName
      
      $hash.Keys |
          ForEach-Object {
            $property = $_
            $value = $shellfolder.GetDetailsOf( $shellfile, $hash.$property )
            if( $value -as [Double] ) { 
              $value = [Double]$value 
            }
            $fileobject | 
                Add-Member NoteProperty "Extended_$property" $value -Force
          }
    }
    $fileobject
    
  }

  END {}
  
}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Add-SmartMargin.ps1
Function Add-SmartMargin {


  [CMDLETBINDING( DefaultParameterSetName='Margin' )] 
  PARAM(  
      [PARAMETER( ParameterSetName='Value', 
                  Position=0, 
                  ValueFromPipeline, 
                  ValueFromPipelineByPropertyName )]
      [PARAMETER( ParameterSetName='ValueAndMargin', 
                  Position=0, 
                  ValueFromPipeline, 
                  ValueFromPipelineByPropertyName )]          
      [String[]] 
      $Value,

      [PARAMETER( ParameterSetName='Margin', Position=0 )]  
      [PARAMETER( ParameterSetName='ValueAndMargin', Position=1 )]      
      [Byte] 
      $Margin = 0
  )
  
  
  
  BEGIN {}   

  PROCESS {
  
    $Value | 
        ForEach-Object {
        
          # Set $firstLine to 0 if you want the first line to have zero margin
          $firstLine = 1
          
          ( 
            $_ -split "`n" | 
            ForEach-Object { ' ' * $Margin * [bool]$firstLine++  +  $_ } 
          ) -join "`n"
          
        }
    
  }

  END {} 
  
}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Convert-HashtableToObject.ps1
Function Convert-HashtableToObject {




}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\ConvertTo-Hashtable.ps1
Function ConvertTo-Hashtable { 
  <#
      .SYNOPSIS
Converts PsCustomObject type to Hashtable. Takes pipeline input and common arguments

      .DESCRIPTION
Converts PsCustomObject type to Hashtable. Takes pipeline input, common arguments, array arguments for bulk processing 

  #>

  [CMDLETBINDING()] 
  PARAM( 
      [PARAMETER( Position=0, 
                  Mandatory, 
                  ValueFromPipeline, 
                  ValueFromPipelineByPropertyName )]
      [ALIAS( 'CustomObject', 'psCustomObject', 'psObject' )]         
      [psCustomObject[]] 
      $Object 
  ) 


  
  BEGIN { }
     
     
  PROCESS {
  
    foreach( $1object in $Object ) {
    
      $output = [ordered]@{} 
      $1object | 
          Get-Member -MemberType *Property | 
          ForEach-Object { 
            $output.($_.name) = $_object.($_.name) 
          }
          
      $output      
    }
  
  }
  
  
  END { } 

  
}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Copy-Tree.ps1
Function Copy-Tree {
#
#  @TODO(Write Doc Help)
#

    [CMDLETBINDING()] 
    PARAM(
        [PARAMETER( Mandatory )]
        [ALIAS('Source')]
        [String[]] 
        $from,

        [PARAMETER( Mandatory )]
        [ALIAS('Destination')]
        [String]
        $to,

        [PARAMETER()]
        [String[]]
        $excludeFiles=$null,

        [PARAMETER()]
        [String[]]
        $excludeFolderMatch=$null
    )

    $source = Resolve-Path $from
    if( $source.count -ne 1 ) { 
        Write-Error 'From path should be 1 and only directory' 
        Break
    } else {
        $source = [System.IO.Path]::GetFullPath($source).TrimEnd('\')
    }

    [regex]$excludeFolderMatchRegEx = '(?i)' + ($ExcludeFolderMatch -join '|') 
 
    Get-ChildItem -LiteralPath $source -Recurse -Exclude $excludeFiles -Force | 
        Where-Object { 
            !$excludeFolderMatch -or 
            $_.FullName.Replace($source,'') -notMatch $excludeFolderMatchRegEx 
        } |
        ForEach-Object { 
            $_ | 
            Copy-Item -Destination $(
                if( $_.psIsContainer ) { 
                    Join-Path $to $_.Parent.FullName.Substring($source.Length)
                } else {
                    Join-Path $to $_.FullName.Substring($source.length)
                } 
            ) -Force -Exclude $excludeFiles
        }

}






# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Expand-HashtableSelfReference.ps1
# GOING TO DEPRECATE
# TODO(Deprecate)

Function Expand-HashTableSelfReference {
  [CMDLETBINDING()] 
  PARAM( 
      [PARAMETER( ValueFromPipeline )] 
      [HashTable]
      $hTable 
  )

  $res = @{}
  $hTable.Keys | 
      ForEach-Object { 
        Set-Variable -Scope Local -Name $_ -Value $hTable[$_] 
      }
    
  $hTable.Keys | 
      ForEach-Object { 
        $tmp = $hTable[$_]

        # This is less reliable as needs synchronisation waiting:
        #   $value = $ExecutionContext.InvokeCommand.ExpandString($hTable[$_])
        $value = "@`"`n$tmp`n`"@" | Invoke-Expression
        $res.Add( $_, $value ) 
      }
  $res
}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Export-Environment.ps1
$environment = @{
    alias =     @{}
    env =       @{}
    function =  @{}
    variable =  @{}
}

$environment.data = @{
    alias =     'Name', 'ResolvedCommand', , 'Options'
    env =       'Name', 'Value', 'Visibility'
    function =  'Name', 'ModuleName', 'Visibility'
    variable =  'Name', 'Value', 'Visibility', 'Options'
}


foreach( $key in [Array]$environment.Keys ) {
    $environment.$key = Get-ChildItem "${key}:/"
}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Format-String.ps1
Function Format-String {
<#
    .SYNOPSIS
Replaces text in a string based on named replacement tags

    .DESCRIPTION
Replaces text in a string based on named replacement tags.
Replacement is based on a hashtable or array of hashtables provided as an argument or taken from the pipeline.
    
    .EXAMPLE
PS> Format-String "Hello {NAME}" @{ NAME='PowerShell' }
Hello PowerShell

    .EXAMPLE
PS> Format-String "Your score is {SCORE:P}" @{ SCORE=0.85 }
Your score is 85.00%

    .EXAMPLE
PS> @{score=0.85; Now=(Get-Date)} | Format-String "Now is {NOW:yyyy-MM-dd HH:mm:ss}. Your score is {SCORE:P}"
Now is 2017-07-19 11:48:38. Your score is 85.00%

    .EXAMPLE
PS> @{score=0.85; Now=(Get-Date)}, @{score=0.97; Now=(Get-Date)} | Format-String "Now is {NOW:yyyy-MM-dd HH:mm:ss.fff}. Your score is {SCORE:P}"
Now is 2017-07-19 11:32:54.686. Your score is 85.00%
Now is 2017-07-19 11:32:54.687. Your score is 97.00%

    .EXAMPLE
PS> Format-String "Now is {NOW:yyyy-MM-dd HH:mm:ss.fff}. Your score is {SCORE:P0}" @{score=0.85; Now=(Get-Date)}, @{score=0.97; Now=(Get-Date)}
Now is 2017-07-19 11:36:44.149. Your score is 85%
Now is 2017-07-19 11:36:44.150. Your score is 97%
    
    .INPUTS
Takes array of hashtables from standard input both as whole value and as a property of object in the pipeline
    
    .OUTPUTS
Puts the result of [String[]] type in a pipeline
    
    .NOTES
Andriy Melnyk @turboBasic https://github.com/turboBasic : wrapped in cmdlet to allow pipeline processing
https://github.com/turboBasic/dotfiles.windows/tree/master/powershell/Modules/Commands/include
В 
Original:
##############################################################################
##
## Format-String
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################    
В 
В 
В 
.
   
   .LINK
https://github.com/turboBasic/dotfiles.windows/tree/master/powershell/Modules/Commands/include   
http://www.leeholmes.com/guide
   
#>


  [CMDLETBINDING( PositionalBinding=$False )]
  [OUTPUTTYPE( [String[]] )]
  PARAM(
  
      [PARAMETER( Mandatory, Position=0 )]
      ## The string to format. Any portions in the form of {NAME} will be automatically replaced by 
      ## the corresponding value from the supplied hashtable.
      [String] $String,

      [PARAMETER( Mandatory, Position=1, ValueFromPipeline, ValueFromPipelineByPropertyName )]  
      ## The named replacements to use in the string
      [Hashtable[]] $Replacements
  )
  


  
  BEGIN {
    # TODO(Set-StrictMode -Version 5)
    
    if($String -match '{{|}}') {
      Throw 'Escaping of replacement terms are not supported.'
    }
    
  }

  
  PROCESS {
  
    # Now we have all items in $Replacements[] 
    # and we have to unwrap items even if there is only
    # one item in the $Replacements array 
  
    foreach( $1replacement in $Replacements ) {
      $currentIndex = 0
      $replacementList = @()
      
      ## Go through each key in the hashtable
      foreach( $key in $1replacement.Keys ) {
        ## Convert the key into a number, so that it can be used by String.Format
        $inputPattern = '{([^{}]*)' + $key + '([^{}]*)}'
        $replacementPattern = '{${1}' + $currentIndex + '${2}}'
        $String = $String -replace $inputPattern, $replacementPattern
        $replacementList += $1replacement[$key]
        $currentIndex++
      }
      
      ## Now use String.Format to replace the numbers in the format string.
      $String -f $replacementList
      
    }
    
  }

  
  END {}
    
}
  





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Get-ConsoleColor.ps1
Function Get-ConsoleColor {
  PARAM(
      [Switch]
      $Colorize
  )
 
  $wsh = New-Object -ComObject wscript.shell
  $data = [enum]::GetNames([Consolecolor])
 
  if ($Colorize) {
    Foreach ($color in $data) {
      Write-Host $color -ForegroundColor $Color
    }
    [Void]$wsh.Popup( 
        "The current background color is $([console]::BackgroundColor)", 
        16, 
        'Get-ConsoleColor' 
    )
    Return
  }
 
  $data
} 






# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Get-EnvironmentPath.ps1
Function Get-EnvironmentPath {

  $ENV:Path -split ';'

  #region Creating command 'ppath' for cmd.exe
  
    $ppath = 'ppath.cmd'
    $Exists = $( 
        Try   { Test-Path (cmd /c 'where' $ppath 2>&1 $null) } 
        Catch { $False }
    )

    if( $Exists ) { 
      Write-Verbose 'Get-EnvironmentPath: ppath.cmd already exists'
      return 
    }
   
    $shimPath = 
        "$ENV:scoop\shims", 
        "$ENV:chocolateyInstall\bin", 
        "$ENV:scoop_Global\shims", 
        '$ENV:systemROOT' | 
        Where { Test-Path $_ } | 
        Select-Object -First 1

    if( !$shimPath ) {
      " `n `nYou are probably running Linux!`n " | 
          Write-Error -Category WriteError -targetObject $shimPath 
      return
    }

    $shimPath = Join-Path $shimPath $ppath

    if( !(Test-Path $shimPath) ) {
    
        
        
        $command = @'
      
@powershell.exe -NoLogo 
                -NoProfile 
                -ExecutionPolicy Bypass 
                -Command "  $ENV:PATH -split ';'  "
                
'@.         Trim() -replace '\s+', ' '

        # $command = '@path | sed s/PATH=//;s/;/\n/g && echo.'
        # shim -global -norelative "$PSScriptRoot\ppath.cmd" "ppath"
        New-Item $shimPath -Force | Add-Content -Value $command 
        
        if( !$? ) {
          " `n `nCannot write to file $shimPath `n `n" |
              Write-Error -Category WriteError -targetObject $shimPath 
          return
        } 
        
        "Get-EnvironmentPath: File $shimPath for cmd.exe created successfully" |
            Write-Verbose 
    }
    
  #endregion

}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Get-GistMao.ps1
Function Get-GistMao {

  PARAM(
      [PARAMETER( Position=0 )]
      [AllowNull()] [allowEmptyString()]
      [String]
      $api 
  )

  if(!$api) {
    $api = 
        $ENV:githubGist, 
        "https://api.github.com/users/${ENV:USERNAME}/gists" | 
        Select -First 1
  }

  Invoke-WebRequest $api | 
    Select-Object -ExpandProperty Content | 
    ConvertFrom-Json | 
    ForEach-Object { 
      $_currentRecord = $_
      $_.files | 
      ConvertTo-Hashtable | 
      Select-Object -ExpandProperty Values | 
      ForEach-Object { 
          [psCustomObject]@{ 
              filename =    $_.filename
              url =         $_.raw_url
              id =          $_currentRecord.id 
              description = $_currentRecord.description
          }
      }
    } | 
    Format-List filename, url, description

}






# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Get-GuiHelp.ps1
Function Get-GuiHelp {

  PARAM(  
          [PARAMETER( Position=0 )]
          [String] $Request,

          [PARAMETER()]
          [Switch] $List,

          [PARAMETER()]
          [Switch] $Force            
  )

  
  
  $GuiHelpPath = Join-Path $ENV:DROPBOX_HOME '/Public/Powershell/powershell2.chm'

  if ($List) {
    Get-Content "$GuiHelpPath.TopicsList.txt"
    return
  }

        
  if ($Force) {
    Get-Content "$GuiHelpPath.TopicsList.txt" |
        Where { $_ -match ".*$Request.*" } |
        ForEach-Object { 
          $_
          HH.EXE "mk:@MSITStore:${GuiHelpPath}::$_"
        }
    return
  }
  
  
  
  $Postfix = switch ($Request) {
    
      { IsNull $_.Trim() } { 

          '/test.htm'
          break 
      }

      { $_ -match '^about_' } { 
      
          "/About/$_.help.htm"
          break  
      }

      { $_ -cmatch '^a[A-Z]\w+' } {
      
          "/About/about_$(
          
              $_.TrimStart('a').toLower()  
          
          ).help.htm"
          break  
      }
      
      { $_ -match '^\w+-\w+' } { 
      
          "/Cmdlets/$_.htm"
          break  
      }
      
      DEFAULT { "/VBScript/$_.htm" -replace ' ' }
      
    }

  "mk:@MSITStore:${GuiHelpPath}::${Postfix}" | Write-Verbose  
  HH.EXE "mk:@MSITStore:${GuiHelpPath}::${Postfix}"
  
}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Get-HelpWindow.ps1
Function Get-HelpWindow {

  Get-Help $($Args -join ' ') -ShowWindow
  
}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Get-SpecialFolders.ps1
Function Get-SpecialFolders {

  $SpecialFolders = 
    New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string]'
    
  [Environment+SpecialFolder].GetEnumNames() | 
    Sort | 
    ForEach-Object { 
      $SpecialFolders.Add( $_, [Environment]::GetFolderPath($_) ) 
    }

  $SpecialFolders

}






# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Get-StringHash.ps1
Function Get-StringHash {
    <# .SYNOPSIS
         produces hash string for argument

       .DESCRIPTION
         Calculates hash-functions using .Net class [System.Security.Cryptography.HashAlgorithm]
         Parameter HashName takes any of the following values: 
           SHA, SHA1, SHA256, SHA384, SHA512, MD5 (default is MD5)

       .PARAMETER String
         String to calculate hash for

       .PARAMETER HashName
         SHA, SHA1, SHA256, SHA384, SHA512, MD5 (default is MD5) 
    #>
 
    #region Parameters
        [CMDLETBINDING()] 
        PARAM( 
            [PARAMETER( Position=0, Mandatory, ValueFromPipeline )]
            [AllowEmptyString()]
            [String[]] 
            $String,
          
            [PARAMETER( Position=1 )]
            [ValidatePattern( '^MD5|(SHA(1|256|384|512)?)$' )]  
            [String] 
            $HashName = 'MD5'
        )
    #endregion
  
  BEGIN {
    Write-Verbose $PSCmdlet.ParameterSetName
    $String   | ConvertTo-Json -Compress | Write-Verbose 
    $HashName | ConvertTo-Json -Compress | Write-Verbose 
    $StringBuilder = New-Object System.Text.StringBuilder
  }

  PROCESS {
  
    $String | ConvertTo-Json -Compress | Write-Verbose 
    $_      | ConvertTo-Json -Compress | Write-Verbose
    
    forEach( $s in $String ) {
      [System.Security.Cryptography.HashAlgorithm]::Create( 
          $HashName 
      ).ComputeHash( 
          [System.Text.Encoding]::UTF8.GetBytes($s) 
      ) | 
      ForEach-Object{   
        [Void]$StringBuilder.Append( $_.ToString('x2') )  
      }
          
      Write-Output $StringBuilder.ToString()
      
      [Void]$StringBuilder.Clear()
    } 
  }

  END{}
}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Get-TimeStamp.ps1
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






# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Import-UserModules.ps1
# TODO: Generalize parameters

Function Import-UserModules {

  $modules = @{
    'Vendor module Chocolatey' = "$ENV:ChocolateyInstall/helpers/chocolateyProfile.psm1"
    'User module Commands'     = "$__profileDir/Modules/Commands"
    'User module Environment'  = "$__profileDir/Modules/Environment"
    'User module UtilsScoop'   = "$__profileDir/Modules/UtilsScoop"
    'User module Test'         = "$__profileDir/Modules/Test"
  }

  
  $modules.Keys | 
      ForEach-Object {
        $m = $modules.$_
        if( !(Test-Path $m) ) {
            $m = Split-Path -Leaf $m
        }

        $__messages.moduleLoading -f $_ | Write-Verbose
        Import-Module $m -Force
        
        $( 
            if( $? ) 
              { $__messages.moduleSuccess }
            else      
              { $__messages.moduleFailure }
              
        ) -f $_ | 
            Write-Verbose
      }

}






# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\IsNull.ps1
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





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Merge-Hashtables.ps1
<#  .SYNOPSIS
      Merges any number of hashtables into one

    .DESCRIPTION
      Merges any number of hashtables taken both from pipeline and arguments, with the hashtables in the right overwriting the keys with the same names from hastables in the left

    .EXAMPLE
      $a = @{a = 'a1'; b = 'a2'}
      $b = @{b = 'b1'; c = 'b2'}
      $c = @{c = 'c1'; d = 'c2'}

      PS> Merge-Hashtables $a $b

      Name                  Value                                                                                                                                                              
      ----                  -----
      a                     a1
      b                     b1
      c                     b2

    .EXAMPLE
      PS> $a, $b | Merge-Hashtables $c

      Name                  Value                                                                                                                                                              
      ----                  -----
      a                     a1
      b                     b1
      c                     c1
      d                     c2  
#>

Function Merge-Hashtables {
    $Result = @{}
    ($Input + $Args) | 
        Where   { ($_.Keys -ne $null) -and ($_.Values -ne $null) -and ($_.GetEnumerator -ne $null) } | 
        ForEach { $_.GetEnumerator() } | 
        ForEach { $Result[$_.Key] = $_.Value } 
    $Result
    Write-Verbose (ConvertTo-Json $Result -compress)
}






# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\New-Shortcut.ps1
Function New-Shortcut() { 
  <#
      .SYNOPSIS
          Creates old-school "soft" shortcut to file or folder

      .DESCRIPTION
          Takes input from pipeline and named arguments
          New-Shortcut -name "~\startmenu.lnk" -target X:\directory\ -icon "%SystemDrive%\explorer.exe,0"

  #>
  #region New-Schortcut params

      # [String] $name, [String] $target, 
      # $arguments='',  $icon='%SystemRoot%\explorer.exe,0', 
      # $description='', $workDir='.'

    PARAM(
        [PARAMETER( Mandatory, 
                    Position=0, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName )]
        [VALIDATENOTNULLOREMPTY()]
        [String[]]
        $Name,

        [PARAMETER( Mandatory, 
                    Position=1, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName )]
        [VALIDATESCRIPT({ If (Test-Path $_) 
                            { $True } 
                          Else 
                            { Throw "'$_' doesn't exist!" } })]
        [String]
        $Target,

        [PARAMETER( ValueFromPipelineByPropertyName )]
        [String]
        $arguments='',

        [PARAMETER( ValueFromPipelineByPropertyName )]
        [String]
        $icon=$null,

        [PARAMETER( ValueFromPipelineByPropertyName )]
        [String]
        $workDir='.',

        [PARAMETER( ValueFromPipelineByPropertyName )]
        [String]
        $Description
    )

  #endregion

  BEGIN {}

  PROCESS {
    ForEach ($n in $Name) {
      if($n -notmatch ".*\.lnk$") {
        $n += ".lnk"
      }
      $WshShell = New-Object -ComObject WScript.Shell
      $Shortcut = $WshShell.CreateShortcut($n)
      $Shortcut.TargetPath = $target
      $Shortcut.Arguments = $arguments
      if ($icon) {
        $Shortcut.IconLocation = $icon
      }
      $Shortcut.Description = $description
      $Shortcut.WorkingDirectory = $workDir
      $Shortcut.Save()
      Write-Output $Shortcut
    }
  }

  END {}
}







# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\New-SymLink.ps1

Function New-SymLink {
    <#
        .SYNOPSIS
            Creates a Symbolic link to a file or directory

        .DESCRIPTION
            Creates a Symbolic link to a file or directory as an alternative to mklink.exe

        .PARAMETER Path
            Name of the path that you will reference with a symbolic link.

        .PARAMETER SymName
            Name of the symbolic link to create. Can be a full path/unc or just the name.
            If only a name is given, the symbolic link will be created on the current directory that the
            function is being run on.

        .PARAMETER File
            Create a file symbolic link

        .PARAMETER Directory
            Create a directory symbolic link

        .NOTES
            Name: New-SymLink
            Author: Boe Prox
            Created: 15 Jul 2013


        .EXAMPLE
            New-SymLink -Path "C:\users\admin\downloads" -SymName "C:\users\admin\desktop\downloads" -Directory

            SymLink                             Target                      Type
            -------                             ------                      ----
            C:\Users\admin\Desktop\Downloads    C:\Users\admin\Downloads    Directory

            Description
            -----------
            Creates a symbolic link to downloads folder that resides on C:\users\admin\desktop.

        .EXAMPLE
            New-SymLink -Path "C:\users\admin\downloads\document.txt" -SymName "SomeDocument" -File

            SymLink                                Target                                     Type
            -------                                ------                                     ----
            C:\users\admin\desktop\SomeDocument    C:\users\admin\downloads\document.txt      File

            Description
            -----------
            Creates a symbolic link to document.txt file under the current directory called SomeDocument.
    #>

    [CMDLETBINDING( DefaultParameterSetName = 'Directory', 
                    SupportsShouldProcess )]
    PARAM (
        [PARAMETER( ParameterSetName='Directory', 
                    Mandatory, 
                    Position=0, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName )]
        [PARAMETER( ParameterSetName='File', 
                    Mandatory, 
                    Position=0, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName )]
        [VALIDATESCRIPT({ if (Test-Path $_) 
                            { $True } 
                          else  
                            { Throw "'$_' doesn't exist!" } })]
        [String] 
        $Path,

        [PARAMETER( ParameterSetName='FILE', 
                    Position=1 )]
        [PARAMETER( ParameterSetName='Directory', 
                    Position=1 )]
        [String] 
        $SymName,

        [PARAMETER( ParameterSetName='File', 
                    Position=2 )]
        [Switch] 
        $File,

        [PARAMETER( ParameterSetName='Directory', 
                    Position=2 )]
        [Switch] 
        $Directory
    )


    BEGIN {
        Try {
            $null = [mklink.symlink]
        } Catch {
            Add-Type @"
                using System;
                using System.Runtime.InteropServices;
     
                namespace mklink
                {
                    public class symlink
                    {
                        [DllImport("kernel32.dll")]
                        public static extern bool CreateSymbolicLink(string lpSymlinkFileName, string lpTargetFileName, int dwFlags);
                    }
                }
"@
        }
    }
    PROCESS {
        #Assume target Symlink is on current directory if not giving full path or UNC
        If ($SymName -notmatch '^(?:[a-z]:\\)|(?:\\\\\w+\\[a-z]\$)') {
            $SymName = '{0}\{1}' -f $pwd, $SymName
        }
        $Flag = @{
            File = 0
            Directory = 1
        }
        If ($PScmdlet.ShouldProcess($Path, 'Create Symbolic Link')) {
            Try {
                $return = [mklink.symlink]::CreateSymbolicLink(
                    $SymName, 
                    $Path, 
                    $Flag[$PScmdlet.ParameterSetName]
                )
                If ($return) {
                    $object = New-Object PSObject -Property @{
                        SymLink = $SymName
                        Target = $Path
                        Type = $PScmdlet.ParameterSetName
                    }
                    $object.pstypenames.insert(0, 'System.File.SymbolicLink')
                    $object
                } Else {
                    Throw 'Unable to create symbolic link!'
                }
            } Catch {
                Write-warning ('{0}: {1}' -f $path, $_.Exception.Message)
            }
        }
    }
 }







# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Remove-IndentationMark.ps1
Function Remove-IndentationMark {
    PARAM( 
      [String]
      $DeleteBefore = 'вЂ¦' 
    )

    $DeleteBefore = [Regex]::Escape( $DeleteBefore )

    ($Input + $Args) | 
        ForEach { $_ -replace "(?m)$Del", '' }
}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Remove-LeadingSpace.ps1
function Remove-LeadingSpace {

    ($Input + $Args) |     
        ForEach { $_ -replace '(?mx) ^ [^\S\n\r]*' } 
}
# -replace '^[^\S\n\r]*'
# -replace '(?m)^\s+(\S.*)$', '$1'





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Resolve-HashTable.ps1
function Resolve-HashTable {
<#

  PS> {@{ 
  >>    basePath  = 'c:\Windows'
  >>    cmd       = $_.basePath + '\' + 'cmd.exe' }} | 
  >>  Resolve-HashTable

  Name                           Value
  ----                           -----
  basePath                       c:\Windows
  cmd                            c:\Windows\cmd.exe


  PS> {@{basePath='c:\Windows'; cmd=$_.basePath+'\cmd.exe'}} | Resolve-Hashtable -OutVariable a | Out-Null
  PS> $a
  
  Name                           Value
  ----                           -----
  basePath                       c:\Windows
  cmd                            c:\Windows\cmd.exe


  PS> {@{basePath='c:\Windows'; cmd=$_.basePath+'\cmd.exe'}},{@{a='c:\Very\VeryLong\Path'; cmd1=$_.a+'\dir1'; cmd2=$_.cmd1+'\dir2'}}  | Resolve-Hashtable

#>

  [CMDLETBINDING( PositionalBinding=$False )]
  [OUTPUTTYPE( [Hashtable[]] )]
  PARAM(
      [PARAMETER( Mandatory, Position=0, ValueFromPipeline )]
      [ValidateNotNullOrEmpty()]
      [Scriptblock[]] $InputObject
  )
  

  
  BEGIN {}

  
  PROCESS {
  
    foreach( $hashTable in $InputObject ) {
      Try   { $__ = $hashTable.Invoke() }
      Catch { 
        $__ = $null 
        Write-Verbose 'Invoke failed'
      }
      
      if( IsNull $__ ) {
          $result = $null
      } else {
          $result = [Scriptblock]::Create( $hashTable.toString().Replace('$_', '$__') ).Invoke()
      }

      $result
    }
    
  }

  
  END {}

}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Send-NetMessage.ps1
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







# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Set-FileTime.ps1
Function Set-FileTime {

  PARAM(
    [String[]] $paths,
    [Bool]     $only_modification = $false,
    [Bool]     $only_access = $false
  )

  BEGIN {

    Function updateFileSystemInfo( [System.IO.FileSystemInfo]$fsInfo ) {
      $datetime = Get-Date
      if ( $only_access ) {
         $fsInfo.LastAccessTime = $datetime
      }
      elseif ( $only_modification ) {
         $fsInfo.LastWriteTime = $datetime
      }
      else {
         $fsInfo.CreationTime = $datetime
         $fsInfo.LastWriteTime = $datetime
         $fsInfo.LastAccessTime = $datetime
      }
    }
   
    Function touchExistingFile($arg) {
      if ($arg -is [System.IO.FileSystemInfo]) {
        updateFileSystemInfo($arg)
      }
      else {
        $resolvedPaths = resolve-path $arg
        foreach ($rpath in $resolvedPaths) {
          if (test-path -type Container $rpath) {
            $fsInfo = new-object System.IO.DirectoryInfo($rpath)
          }
          else {
            $fsInfo = new-object System.IO.FileInfo($rpath)
          }
          updateFileSystemInfo($fsInfo)
        }
      }
    }
   
    Function touchNewFile([String]$path) {
      #$null > $path
      Set-Content -Path $path -value $null;
    }

  }
 
  PROCESS {
    if ($_) {
      if (test-path $_) {
        touchExistingFile($_)
      }
      else {
        touchNewFile($_)
      }
    }
  }
 
  END {
    if ($paths) {
      foreach ($path in $paths) {
        if (test-path $path) {
          touchExistingFile($path)
        }
        else {
          touchNewFile($path)
        }
      }
    }
  }

}





# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Set-LogEntry.ps1
Function Set-LogEntry {

  [CMDLETBINDING()]
  [OUTPUTTYPE( [String[]] )]
  PARAM( 
      [PARAMETER( Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [ALIAS('Text', 'Data', 'Value')]
      [String[]]
      $Message = @('')
  )

  BEGIN{}

  PROCESS{
      foreach($m in $Message) {
        '{0} {1}' -f (Get-TimeStamp), $m
      }
  }

  END{}
}






# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Update-Helpfiles.ps1
Function Update-HelpFiles {
  $params = @{ 
    Name = 'UpdateHelpJob'
    Credential = "${ENV:ComputerName}\${ENV:UserName}"
    ScriptBlock = {
      Update-Help -EA 0
    }
    Trigger = (New-JobTrigger -Daily -At '3 AM')
  }

  if (!(Get-ScheduledJob -Name UpdateHelpJob)) {
    Register-ScheduledJob @params
  }
}






# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Write-Log.ps1
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







# E:\0projects\dotfiles.windows\powershell\Module_Commands\_src\include\Write-VariableDump.ps1
Function Write-VariableDump {
  <# .SYNOPSIS
        `$variable | ConvertTo-Json | Write-Verbose` on steroids
  #> 

 
  [CMDLETBINDING( DefaultParameterSetName='Prefix' )] 
  PARAM( 
      [PARAMETER( Position=0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [ALIAS( 'object' )]         
      [Object[]] $Name,

      [PARAMETER( ParameterSetName='Prefix', Position=1 )]
      [ALLOWEMPTYSTRING()]
      [String] $Prefix = '',

      [PARAMETER( ParameterSetName='Template' )]
      [ALLOWEMPTYSTRING()]
      [String] $Template = '${0} = {1}',

      [PARAMETER()]      
      [Switch] $noRecurse
  )   

    #region debug information printing functions
      Function DumpBeginBlock {
          'BEGIN: $ParameterSetName = {0}' -f 
              $PSCmdlet.ParameterSetName | Write-Verbose
          'BEGIN: $Name = {0}'             -f 
              ($Name    | ConvertTo-Json) | Add-SmartMargin 16 | Write-Verbose
          'BEGIN: $Prefix = {0}'           -f 
              $Prefix   | Write-Verbose
          'BEGIN: $Template = {0}'         -f 
              $Template | Write-Verbose
      }

      Function DumpProcessBlockBegin {
        '       PROCESS: $input = {0}' -f 
                ($input  | ConvertTo-Json) | Add-SmartMargin 25 | Write-Verbose
        '                type = {0}'   -f 
                $input.GetType().Name | Write-Verbose
        '       PROCESS: $Name = {0}'  -f 
                ($Name   | ConvertTo-Json) | Add-SmartMargin 25 | Write-Verbose
        '                type = {0}'   -f 
                $Name.GetType().Name  | Write-Verbose
        '       PROCESS: $_ = {0}'     -f 
                ($psItem | ConvertTo-Json) | Add-SmartMargin 25 | Write-Verbose
        '                type = {0}'   -f ( .{  if ($_ -eq $Null) 
                                                  { '<null>' } 
                                                else 
                                                  { $_.GetType().Name } 
                                             }  
                                          ) | Write-Verbose
        if( [string]$Name -like 'System.Management.Automation.PSVariable' ) {
            Write-Verbose '       PROCESS: $Name is like System.Management.Automation.PSVariable'
            $trueName = ([System.Management.Automation.PSVariable]$Name).get_Name()
        } else {
            Write-Verbose '       PROCESS: $Name is NOT like System.Management.Automation.PSVariable'
            $trueName = $Name
        }
        '       PROCESS: $trueName = {0}' -f 
                ($trueName | ConvertTo-Json) | Add-SmartMargin 25 | Write-Verbose
        '                type = {0}'      -f $trueName.GetType().Name | Write-Verbose
        $Private:message = (('       PROCESS: ' + $Template) -f 
                $trueName, 
                (Get-Variable -Name $Name -Scope 1 -ValueOnly | 
                ConvertTo-Json) | Add-SmartMargin 25)
        Write-Verbose $Private:message  
      }
    #endregion

    BEGIN {
        $oldverbose = $VerbosePreference
        $VerbosePreference = "SilentlyContinue"
        $Messages = ''
        DumpBeginBlock
    }

    PROCESS {
        DumpProcessBlockBegin
        foreach($singleName in $Name) {
            '      PROCESS FOREACH: $singleName = {0}' -f ($singleName | ConvertTo-Json) | Add-SmartMargin 32 | Write-Verbose
            '                       type = {0}' -f $singleName.GetType().Name | Write-Verbose
                   
            $Private:message = ($Template -f $singleName, (Get-Variable -Name $singleName -Scope 1 -ValueOnly | ConvertTo-Json) | Add-SmartMargin 1 )
            Write-Verbose (Add-SmartMargin $Private:message 9)
            $Messages += $(Write $Private:message) + "`n"
        }
    }

    END {
        $VerbosePreference = $oldverbose
        Write-Verbose $Messages 
        # "`n" 
    }
}







