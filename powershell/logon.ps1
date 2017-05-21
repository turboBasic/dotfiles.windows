$_logFile = 'c:\logs\logon.log'      # "$_workingDir\set_environment.log"

function script:_initVariables () {

}

function script:_createEnvironment() {
  set-env -Name '-Tools'          c:\tools                          Machine $false
  set-env -Name MSYS              '%-Tools%\msys64'                 Machine $true
  set-env -Name Cmder_Root        '%-Tools%\cmdermini'              Machine $true
  set-env -Name ChocolateyInstall "$env:ProgramData\chocolatey"     Machine $false
  set-env -Name Git               "$env:ProgramFiles\Git"           Machine $false
  set-env -Name '-SCOOP_GLOBAL'   "$env:ProgramData\Scoop"          Machine $false
  set-env -Name SCOOP_GLOBAL      '%-SCOOP_GLOBAL%'                 Machine $true
  set-env -Name NotepadPP  '%-SCOOP_GLOBAL%\apps\notepadplusplus\current\notepad++.exe'  Machine $true
  set-env -Name '-kdiff3'         "$env:ProgramFiles\kdiff3"        Machine $false
  set-env -Name '-Skype'          "$env:ProgramFiles (x86)\Skype\Phone"                  Machine $false
  set-env -Name '-SCOOP'          "$env:UserProfile\Scoop"          User    $false
  set-env -Name SCOOP             '%-Scoop%'                        User    $true
  set-env -Name Choco             '%ChocolateyInstall%'             User    $true
  set-env -Name ChocolateyToolsLocation '%-Tools%'                  User    $true
  set-env -Name Dropbox           c:\mnt\data\Dropbox               User    $false
  set-env -Name OneDrive          c:\mnt\data\OneDrive              User    $false

  $Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  # TODO create Path variable, remove duplicates
  Broadcast-EnvironmentChanges
  refreshenv
}


function script:_time() {
  return Get-Date -UFormat '%Y-%m-%d %H:%M:%S'
}


function script:_log ($value='__empty__', $scope='User', $variable=$true) {

  function _logError() {
    Write-Output "Error: can not write to ${_logFile} !"
    $_logFileSafe = "$(Split-Path $profile)\logon_$(get-date -uformat %s).log"
    Write-Output "Will write to ${_logFileSafe} instead."
    Write-Output "$(_time)  | `$profile=$profile"
    Start-Sleep 3
    Add-Content -Path $_logFileSafe -Value "$(_time)  | $value"
    Start-Sleep 3
  }


  if ($value -ne '__empty__') {
    if ($variable) {
      $value += ' = ' + ' ' * (30 - $value.length) + [Environment]::GetEnvironmentVariable($value)
      Try {
        Add-Content -Path $_logFile -Value "$(_time)  | $value"
      }
      Catch {
        _logError
        Exit
      }
    }
    else {
      Try {
        Add-Content -Path $_logFile -Value "$(_time)  | $value"
      }
      Catch {
        _logError
        Exit
      }
    }
  } else {
    Add-Content -Path $_logFile -Value "`n"
  }
}


function script:_logStart() {
  $_script = Split-Path $PSCommandPath -Leaf
  $_message = "$(_time)  | Hi from logon script '$PSCommandPath' !"

  Write-output $_message
  Add-Content -Path $_logfile -Value $_message
}


#. .\lib_environment.ps1
Import-Module -Name Environment

_logStart
_createEnvironment

_log -Value '-Tools'                   -Scope Machine 
_log -Value 'MSYS'                     -Scope Machine 
_log -Value 'Cmder_Root'               -Scope Machine 
_log -Value 'ChocolateyInstall'        -Scope Machine 
_log -Value 'Git'                      -Scope Machine
_log -Value '-SCOOP_GLOBAL'            -Scope Machine
_log -Value 'SCOOP_GLOBAL'             -Scope Machine 
_log -Value 'NotepadPP'                -Scope Machine 
_log -Value '-kdiff3'                  -Scope Machine 
_log -Value '-Skype'                   -Scope Machine
_log -Value '-SCOOP'                   -Scope User    
_log -Value 'SCOOP'                    -Scope User    
_log -Value 'Choco'                    -Scope User    
_log -Value 'ChocolateyToolsLocation'  -Scope User    
_log -Value 'Dropbox'                  -Scope User    
_log -Value 'OneDrive'                 -Scope User    

    
<#
  set-env -Name __test1_UF (_time) User $false
  set-env -Name __test2_UT 'test\add\path;%Path%' User $true
  set-env       __test3_UD 'test\add\path;%Path%' User
  set-env       __test4_UD 'test\add\path;%Path%' User $false
  set-env       __test5_MD 'test\add\path;%Path%' Machine
  Broadcast-EnvironmentChanges
#>
