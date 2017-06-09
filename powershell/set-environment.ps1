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


if ( !(Get-Command Set-EnvironmentVariable -EA SilentlyContinue) ) {
  Try {
    Import-Module Environment
  } Catch {
    Write-Error "Environment module not found. Make sure its location is in PSModulePath"
  }
}



function Set-MachineEnvironment([switch]$initialise = $false) {

    sv workingDir "." -Scope "Script"
    sv path ((get_env "Path" "Machine") -split ";") -Scope "Script"
    sv a '' -Scope "Script"
    sv b '' -Scope "Script" 
    sv p '' -Scope "Script"
    sv pathSplit '' -Scope "Script" 
    
    foreach ($p in $path) {
        $a = $p.substring(0,1).ToLower() 
        $b = $p.substring(1)
        $pathSplit = "$pathSplit  $a$b`r`n"
    }
    
    sv _time (Get-Date -format u) -Scope "Script"
    
    Add-Content -Path "$workingDir\set_environment.log" -EA SilentlyContinue -Value @"

::Time: $_time 
::PSScriptRoot: $PSScriptRoot
  ::PathMachineBefore: 
$pathSplit
"@

    set_env ChocolateyInstall c:\ProgramData\chocolatey Machine
    set_env JAVA_HOME %ProgramFiles%\Java\jdk1.8.0_121 Machine
    set_env SCOOP_GLOBAL %ProgramData%\scoop Machine
    set_env SCOOP %Userprofile%\scoop Machine
    
    sv windows @( 
        "%SystemRoot%\system32",
        "%SystemRoot%",
        "%SystemRoot%\System32\Wbem",
        "%SystemRoot%\System32\WindowsPowerShell\v1.0" ) -Scope "Script" 
    sv myPackages @( 
        "%ProgramData%\scoop\shims", 
        "%ChocolateyInstall%\bin" ) -Scope "Script"  
    sv backupValues @( "$env:ProgramFiles(x86)\NVIDIA Corporation\PhysX\Common" ) -Scope "Script"
    
    sv newPath @() -Scope "Script"
    $newPath += $windows
    $newPath += $myPackages
    $newPath += , "%JAVA_HOME%"
    $newPath += , "%ProgramFiles%\Docker\Docker\Resources\bin"
    $pathSplit = @()
    foreach ($p in $newpath) {
        $a = $p.substring(0,1).ToLower() 
        $b = $p.substring(1)
        $pathSplit += "$a$b"
    }
    $newPath = ($pathSplit | select -Unique)
    set_env Path ($newPath -join ";") Machine
    $pathSplit = $pathSplit -join "`r`n"

    $_time = (Get-Date -format u)
    
    Add-Content -Path "$workingDir\set_environment.log" -EA SilentlyContinue -Value @"
::Time: $_time 
::PathMachineAfter:        
$pathSplit
"@    

    Broadcast-EnvironmentChanges
    exit 0
}






function Set-UserEnvironment {

  [CmdletBinding(
    SupportsShouldProcess=$True,
    ConfirmImpact="Medium"
  )]
  Param(
    [parameter(Mandatory=$False,
               ValueFromPipeline=$False, 
               HelpMessage='Reset user environment')]
    [Alias("Init")]
    [switch]
    $Initialise
  )


  # Initialisation
  $__toolsDisk   = "c:"
  $__tools       = "tools"
  $__cmder       = "cmdermini"
  $__chocolatey  = "chocolatey"
  $__git         = "git"
  $__dropbox     = "c:\Dropbox"
  $__onedrive    = "c:\Onedrive"
  $__laragonDisk = "c:"
  $__laragon     = "laragon"
  $__phpstrom    = "%JAVA_HOME%"
  $__scoop       = "%Userprofile%\scoop"
  $__ubuntu      = "%localappdata%\Lxss\rootfs"
  $__PSmodule    = @( "$env:Userprofile\Documents\WindowsPowerShell\Modules", 
                      "$env:Appdata\Boxstarter"
  ) -join ';'
  $__MSYS__      = $False
  

  
  $_log = "$PSScriptRoot\set-environment.log"

  $settings = ( $settings = ( $settings = @{
    tools        = Join-Path $__toolsDisk $__tools }) + @{
    Choco        = Join-Path $settings.tools $__chocolatey ;
    Cmder        = Join-Path $settings.tools $__cmder;
    Dropbox      = $__dropbox;
    Git          = Join-Path $settings.tools $__git;
    Laragon      = Join-Path $__laragonDisk $__laragon;
    OneDrive     = $__onedrive; 
    Scoop        = $__scoop; }) + @{
    Cmder_root   = $settings.Cmder; 
    PHPSTORM_JDK = $__phpstorm;
    Ubuntu       = $__ubuntu; 
    MSYS         = $settings.Git;
    PSModulePath = ((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' | 
                        select PSModulePath).PSModulePath + ";" + $__PSmodule) | 
                        select -unique;
    Path         = @( 
          ($_utilPath  = @(
                    "%SCOOP%\shims", 
                    "%Userprofile%\bin" 
          )),
          ($_cmderPath = @(
                    "%Cmder_Root%", 
                    "%Cmder_Root%\bin", 
                    "%Cmder_Root%\vendor\conemu-maximus5", 
                    "%Cmder_Root%\vendor\conemu-maximus5\ConEmu" 
          )),
          ($_gitPath = @(
                    "%Git%", 
                    "%Git%\mingw64\bin",
                    "%Git%\usr\bin" 
          )),
          ($_perlPath = @(
                    '%Git%\usr\bin\core_perl', 
                    '%Git%\usr\bin\site_perl', 
                    '%Git%\usr\bin\vendor_perl' 
          )),
          ($_nodePath = @(
                    "%SCOOP%\apps\nvm\current\nodejs", 
                    "%LocalAppData%\Yarn\config\global\node_modules\.bin" 
          )),
          ($_MSYSpath = @( 
                  # "%ChocolateyInstall%\lib\msys2", 
                    "%MSYS%", 
                    "%MSYS%\usr\bin" 
          )),
          ($_otherPath = @(
                    "%AppData%\Boxstarter",
                    "%OneDrive%\01_portable_apps"
                 # "C:\Program Files\ImageMagick-7.0.5-Q16" 
                 #, "%Userprofile%\AppData\Local\Microsoft\WindowsApps"
          )) | % { $_ }
    );
    ChocolateyInstall = $settings.Choco;
    ConEmuDir         = Join-Path $settings.Cmder "vendor\conemu-maximus5";
    Git_Install_Root  = $settings.Git;
    NVM_HOME          = Join-Path $settings.Scoop "apps\nvm\current";
    NVM_SYMLINK       = Join-Path $settings.Scoop "apps\nvm\current\nodejs";
    ONEDRIVE_HOME     = $settings.OneDrive;
    DROPBOX_HOME      = $settings.Dropbox;
    PHP_INI_SCAN_DIR  = Join-Path $settings.laragon "bin\php\current\ext";
  }
  


  $settings.Path | % { Write-Debug ($_) }
  $_time = Get-Date -format u
  Add-Content $_log "`r`n`r`n::Set-UserEnvironment $Initialise `r`n::Time: $_time" -EA SilentlyContinue



  if ($initialise) {
    Write-Verbose "`r`n::Initialising User variables"

    "tools", "Git", "Scoop"  | % {
        $_msg = "Old value $_ = {0}" -f (Get-EnvironmentVariable $_)
        Write-Verbose $_msg
        Add-Content $_log $_msg -EA SilentlyContinue

        Set-EnvironmentVariable -Name $_ -Text $settings[$_]          #[Environment]::SetEnvironmentVariable($_, $settings[$_], "User")
        $_msg = "$_ = $($settings[$_])"
        Write-Verbose $_msg
        Add-Content $_log $_msg -EA SilentlyContinue
        Send-EnvironmentChanges 
    }
    refreshenv

    "Choco", "Cmder", "Onedrive", "Dropbox", "MSYS", "Cmder_root", "PSModulePath"  | % { 
        $_msg = "Old value $_ = {0}" -f (Get-EnvironmentVariable $_)
        Write-Verbose $_msg
        Add-Content $_log $_msg -EA SilentlyContinue

        Set-EnvironmentVariable -Name $_ -Text $settings[$_]         #[Environment]::SetEnvironmentVariable($_, $settings[$_], "User")
        $_msg = "$_ = $($settings[$_])"
        Write-Verbose $_msg
        Add-Content $_log $_msg -EA SilentlyContinue
    }
    Send-EnvironmentChanges
    refreshenv
  }
 

  $_msg = "Old path = `r`n{0}" -f ((Get-EnvironmentVariable Path) -replace ';', "`r`n")
  Write-Verbose $_msg
  Add-Content $_log $_msg -EA SilentlyContinue

  $Path = $settings.Path | select -Unique
  Set-EnvironmentVariable -Name Path -Text ($Path -join ';')
  $_msg = "Path = `r`n{0}" -f ($Path -join "`r`n")
  Write-Verbose $_msg
  Add-Content $_log $_msg -EA SilentlyContinue

  Add-Content $_log -EA SilentlyContinue -Value @"

::Time: $_time
::PSScriptRoot: `r`n$PSScriptRoot
::PSModulePath: `r`n$($settings.PSModulePath -replace ';', "`r`n")
::PathUserAfter: $($Path -join "`r`n                 ")
"@
    
  Send-EnvironmentChanges  
  return 0  
}



