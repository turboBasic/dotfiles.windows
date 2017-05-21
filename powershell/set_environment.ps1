param(
    [switch]$initialise = $false,
    [switch]$debugging = $false
)
#
# Initializes Environment variables both globally and for current user session
#
# for login sessions run via 
#
#     powershell -noprofile -noninteractive -command "& { . C:\Dropbox\!my_environment_customization\windows\set_environment.ps1; initUserEnvironment; [Environment]::Exit($LASTEXITCODE) }"
#
#       or
#
#     powershell -noprofile -noninteractive -command "& { . C:\Dropbox\!my_environment_customization\windows\set_environment.ps1; initMachineEnvironment; [Environment]::Exit($LASTEXITCODE) }"
#

function script:initVariables () {
    sv _defineVars  $true
    
    sv _workingDir  (Split-Path $profile)                            -Scope 'Script'
    sv _logFile     "$_workingDir\set_environment.log"               -Scope 'Script' 
    sv _tools       'c:\tools'                                       -Scope 'Script'
    sv OneDrive     'c:\OneDrive'                                    -Scope 'Script'
    sv Dropbox      'c:\Dropbox'                                     -Scope 'Script'
    sv Git          "$_tools\git-sdk-64"                             -Scope 'Script' 
    sv MSYS         (_lowerTitle $Git)                               -Scope 'Script'
    sv Cmder_Root   (_lowerTitle $env:CMDER_INSTALL_DIR)             -Scope 'Script' 
    sv Scoop        (_lowerTitle "$env:UserProfile\scoop")           -Scope 'Script' 
    sv Laragon      'c:\Laragon'                                     -Scope 'Script'
    sv UBUNTU       (_lowerTitle "$env:localappdata\Lxss\rootfs")    -Scope 'Script'
    sv PHPSTORM_JDK (_lowerTitle $env:JAVA_HOME)                     -Scope 'Script'
    
}


function script:_log ($value='__empty__', $scope='User', $variable=$true) {

  if($value -eq 'zhopa') {
    Write-Output "We are here, $value"
    Start-Sleep 3
    Try {
      $_time = (get-date -format T)
      Add-Content -Path $_logFile -Value "$value : $_time"
    }
    Catch {
      Write-Output "Error: can not write to $_logFile !"
      $_logFile = "$_workingDir\set_environment_$(get-date -uformat %s).log"
      Write-Output "Will write to $_logFile instead."
      Write-Output "`$profile=$profile"
      Start-Sleep 10
      Add-Content -Path $_logFile -Value "$value `($(get-date -format T)`)"
    }
    Finally {
      Write-Output "Exiting at $_time"
      Start-Sleep 3
      Exit
    }
  }

	if (! ($value -eq '__empty__')) {
    if ($variable) {
      $value = get_env $value $scope
      $value += ' ' * (30 - $value.length)
      Add-Content -Path $_logFile -Value "`$value <= $value"
    }
    else {
      Add-Content -Path $_logFile -Value $value
    }
	} else {
		Add-Content -Path $_logFile -Value "`n"
	}
}


function script:_lowerTitle ($text) {
	return $text.Substring(0,1).toLower() + $text.Substring(1)
}


function initMachineEnvironment([switch]$initialise = $false) {

    initVariables
    sv path ((get_env 'Path' 'Machine') -split ';') -Scope 'Script'
    sv a '' -Scope 'Script'
    sv b '' -Scope 'Script' 
    sv p '' -Scope 'Script'
    sv pathSplit '' -Scope 'Script' 
    
    foreach ($p in $path) {
        $a = $p.substring(0,1).ToLower() 
        $b = $p.substring(1)
        $pathSplit = "$pathSplit  $a$b`r`n"
    }
    
    sv _time (Get-Date -format u) -Scope 'Script'
    
    _log -Variable $false -Value @"

::Time: $_time 
::PSScriptRoot: $PSScriptRoot
  ::PathMachineBefore: 
$pathSplit
"@
  
    set_env ChocolateyInstall (_lowerTitle "$env:ProgramData\chocolatey")        Machine
    set_env CMDER_INSTALL_DIR (_lowerTitle "$_tools\cmder")                      Machine
    set_env JAVA_HOME         'c:\Program Files\Java\jdk1.8.0_121'               Machine
    set_env SCOOP_GLOBAL      (_lowerTitle "$env:ProgramData\scoop")             Machine
	_log "ChocolateyInstall"   'Machine'
	_log "CMDER_INSTALL_DIR"   'Machine'
	_log "JAVA_HOME"           'Machine'
	_log "SCOOP_GLOBAL"        'Machine'
	_log
    
    sv windows @( 
        '%SystemRoot%\system32',
        '%SystemRoot%',
        '%SystemRoot%\System32\Wbem',
        '%SystemRoot%\System32\WindowsPowerShell\v1.0' ) -Scope 'Script' 
    sv myPackages @( 
        '%ProgramData%\scoop\shims', 
        '%ChocolateyInstall%\bin' ) -Scope 'Script'  
    sv backupValues @( "$env:ProgramFiles(x86)\NVIDIA Corporation\PhysX\Common" ) -Scope 'Script'
    
    sv newPath @() -Scope 'Script'
    $newPath += $windows
    $newPath += $myPackages
    $newPath += , $env:JAVA_HOME
    $newPath += , 'c:\Program Files\Docker\Docker\Resources\bin'
    $pathSplit = @()
    foreach ($p in $newpath) {
        $a = $p.substring(0,1).ToLower() 
        $b = $p.substring(1)
        $pathSplit += "$a$b"
    }
    $newPath = ($pathSplit | select -Unique)
    set_env Path ($newPath -join ';') Machine
    $pathSplit = $pathSplit -join "`r`n"

    $_time = (Get-Date -format u)
    
    _log -Variable $false -Value @"
::Time: $_time 
::PathMachineAfter:        
$pathSplit
"@    
    
    Broadcast-EnvironmentChanges
    exit 0
}


function initUserEnvironment([switch]$initialise = $false) {

    initVariables

    if ($initialise -Or !$env:OneDrive) { 
      [Environment]::SetEnvironmentVariable('OneDrive', $OneDrive, 'User') 
      _log 'OneDrive'
    }
    
    if ($initialise -Or !$env:Dropbox) { 
      [Environment]::SetEnvironmentVariable('Dropbox', $Dropbox, 'User') 
      _log 'Dropbox'
    }
    
    if ($initialise -Or !$env:Git) { 
      [Environment]::SetEnvironmentVariable('Git', $Git, 'User')
      _log 'Git'
    }
    
    if ($initialise -Or !$env:MSYS) { 
      [Environment]::SetEnvironmentVariable('MSYS', $MSYS, 'User') 
      _log 'MSYS'
    }
    
    if ($initialise -Or !$env:Cmder_Root) { 
      set_env Cmder_Root $Cmder_Root User
      _log 'Cmder_Root'
    }
    
    if ($initialise -Or !$env:SCOOP -Or $true) {
        set_env SCOOP $Scoop User
		_log 'SCOOP'
    } 

    if ($initialise -Or !$env:laragon) {
      set_env Laragon $Laragon User
      _log 'laragon'
    }
    
    if ($initialise -Or !$env:UBUNTU) {
      set_env UBUNTU $Ubuntu User
      _log 'Ubuntu'
    }
    
    if ($initialise -Or !$env:PHPSTORM_JDK) {
      set_env PHPSTORM_JDK $PHPSTORM_JDK
      _log 'PHPSTORM_JDK'
    }

    sv pathCmder ( @(
      '%Cmder_Root%', 
      '%Cmder_Root%\bin', 
      '%Cmder_Root%\vendor\conemu-maximus5', 
      '%Cmder_Root%\vendor\conemu-maximus5\ConEmu') -join ';') -Scope 'Script'

    sv pathGit ( @(
      '%Git%', 
      '%Git%\mingw64\bin',
      '%Git%\usr\bin') -join ';') -Scope 'Script'

    sv pathPerl ( @(
      '%Git%\usr\bin\core_perl', 
      '%Git%\usr\bin\site_perl', 
      '%Git%\usr\bin\vendor_perl') -join ';') -Scope "Script" 
    
    sv pathNode ( @(
      "$env:SCOOP\apps\nvm\current\nodejs", 
      '%LocalAppData%\Yarn\config\global\node_modules\.bin') -join ';') -Scope 'Script'
    
    sv pathMsys ( @( 
      '%MSYS%', 
      '%MSYS%\usr\bin') -join ';') -Scope 'Script'
    
    sv pathOther ( @( 
      '%AppData%\Boxstarter' ) -join ';') -Scope 'Script'

    sv Path @() -Scope 'Local'
    $Path += , "$env:SCOOP\shims" 
    $Path += , '%Userprofile%\bin' 
    $Path += $pathCmder -split ';'
    $Path += $pathGit -split ';'
    $Path += $pathPerl -split ';'
    $Path += $pathNode -split ';'
    $Path += $pathMsys -split ';'
    $Path += , '%OneDrive%\01_portable_apps'
    $Path += $pathOther -split ';'
    $Path = ($Path | select -Unique)
    $pathSplit = ($Path -join "`r`n")

    sv _time (Get-Date -format u) -Scope 'Script'
    
    sv banner '' -Scope 'Script'
    if ($initialise) {
        $banner = "`r`n::Initialise User variables"
    }
    
    $Path = ($Path -join ';')
    set_env Choco             '%ChocolateyInstall%'                 User
    set_env ConEmuDir         '%Cmder_Root%\vendor\conemu-maximus5' User
    set_env Git_Install_Root  '%Git%'                               User 
    set_env NVM_HOME          "$env:SCOOP\apps\nvm\current"            User
    set_env NVM_SYMLINK       "$env:SCOOP\apps\nvm\current\nodejs"     User
    set_env ONEDRIVE_HOME     '%OneDrive%'                          User
    set_env DROPBOX_HOME      '%Dropbox%'                           User
    set_env Path              $Path                                 User
    set_env PHP_INI_SCAN_DIR  '%laragon%\bin\php\current\ext'       User
    [Environment]::SetEnvironmentVariable('PSModulePath', "$env:Userprofile\Documents\WindowsPowerShell\Modules;$env:Appdata\Boxstarter", 'User')

    _log 'Choco'
    _log 'ConEmuDir'
    _log 'Git_Install_Root'
    _log 'NVM_HOME'
    _log 'NVM_SYMLINK'
    _log 'ONEDRIVE_HOME'
    _log 'DROPBOX_HOME'
    _log 'Path'
    _log 'PHP_INI_SCAN_DIR'
    _log 'PSModulePath'    
    
  _log -Variable $false -Value @"

::Time: $_time $banner
::PSScriptRoot: $PSScriptRoot
::PSModulePath: $env:Userprofile\Documents\WindowsPowerShell\Modules;$env:Appdata\Boxstarter
::PathUserAfter:        
$pathSplit
"@
    
  Broadcast-EnvironmentChanges  
  exit 0  
}


function _test() {
  initVariables
  _log -Value 'zhopa'
}