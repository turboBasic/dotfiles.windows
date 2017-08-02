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