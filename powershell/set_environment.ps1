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

function script:set_env ($name, $text, $scope="User") { 
    (getRegistryKey $scope).SetValue($name, $text, [Microsoft.Win32.RegistryValueKind]::ExpandString)
    (getRegistryKey $scope).Flush()
}

function script:del_env ($name, $scope="User") { 
    (getRegistryKey $scope).DeleteValue($name)
}

function get_env ($name, $scope="User") {
    return (getRegistryKey $scope).GetValue(
        $name, $null, 
        [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
    )
    # get-itemproperty 'hkcu:\Environment' |select path| %{$_.path -split ';'} | select -unique| sort
}

function script:getRegistryKey($scope="User") {
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
}


function Broadcast-EnvironmentChanges() {

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


function initMachineEnvironment([switch]$initialise = $false) {

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
    
    Add-Content -Path "$workingDir\set_environment.log" -Value @"

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
    
    Add-Content -Path "$workingDir\set_environment.log" -Value @"
::Time: $_time 
::PathMachineAfter:        
$pathSplit
"@    

    Broadcast-EnvironmentChanges
    exit 0
}






function initUserEnvironment {

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

  $settings = ( $settings = ( $settings = @{
    tools        = "c:\tools" }) + @{
    Choco        = $settings.tools + "\chocolatey";
    Cmder        = $settings.tools + "\cmdermini";
    Dropbox      = "c:\Dropbox";
    Git          = $settings.tools + "\git";
    Laragon      = "c:\laragon";
    OneDrive     = "c:\OneDrive"; 
    Scoop        = "%Userprofile%\scoop"; }) + @{
    Cmder_root   = $settings.Cmder; 
    PHPSTORM_JDK = "%JAVA_HOME%";
    Ubuntu       = "%localappdata%\Lxss\rootfs"; 
    MSYS         = $settings.Git;
    PSModulePath = ((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' | 
                      select PSModulePath).PSModulePath + ";" +
                      "$env:Userprofile\Documents\WindowsPowerShell\Modules;" + 
                      "$env:Appdata\Boxstarter") | select -unique;
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
                 #, "%Userprofile%\AppData\Local\Microsoft\WindowsApps"
          )) | % { $_ }
    );
    ChocolateyInstall = $settings.Choco;
    ConEmuDir         = $settings.Cmder + "\vendor\conemu-maximus5";
    Git_Install_Root  = $settings.Git;
    NVM_HOME          = $settings.Scoop + "\apps\nvm\current";
    NVM_SYMLINK       = $settings.Scoop + "\apps\nvm\current\nodejs";
    ONEDRIVE_HOME     = $settings.OneDrive;
    DROPBOX_HOME      = $settings.Dropbox;
    PHP_INI_SCAN_DIR  = $settings.laragon + "\bin\php\current\ext";
  }
  
  $settings.Path | % { Write-Debug ($_) }

  if ($initialise) {
    "tools", "Git", "Scoop"  | % { 
        [Environment]::SetEnvironmentVariable($_, $settings[$_], "User") 
        Write-Verbose "$_ = $($settings[$_])"
        Broadcast-EnvironmentChanges 
    }
    refreshenv
    "Choco", "Cmder", "Onedrive", "Dropbox", "MSYS", "Cmder_root", "PSModulePath"  | % { 
        [Environment]::SetEnvironmentVariable($_, $settings[$_], "User")
        Write-Verbose "$_ = $($settings[$_])" 
        # Broadcast-EnvironmentChanges 
    }
    $banner = "`r`n::Initialise User variables"
    refreshenv
  }
  
  # $Scoop = $env:SCOOP
  ##if ($initialise -Or !$env:SCOOP -Or $Scoop -eq "$env:Userprofile\scoop") {
  ##    $Scoop = $settings.scoop
  ##    set_env SCOOP $Scoop User
  ##} 

  $Path = $settings.Path | select -Unique
  set_env Path ($Path -join ';') User 
  Write-Verbose ("Path = {0}" -f ($Path -join "`r`n"))

  $_time = Get-Date -format u  
  Add-Content -Path "$workingDir\set_environment.log" -Value @"

::Time: $_time $banner
::PSScriptRoot: $PSScriptRoot
::PSModulePath: $PSModulePath
::PathUserAfter: $($Path -join "`r`n                  ")
"@
    
  Broadcast-EnvironmentChanges  
  return 0  
}
