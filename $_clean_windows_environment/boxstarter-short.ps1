# Run: START http://boxstarter.org/package/nr/url?https://gist.githubusercontent.com/maoizm/7d0192e9b9493dcd503449fa6a389b49/raw/4a7470fe1b0a81c8b78d7d42150d55c303f826bb/boxstarter.ps1
#  or: START http://boxstarter.org/package/nr/url?c:\install\boxstarter.ps1
#

# @TODO add  lib_environment.ps1

Set-ExecutionPolicy RemoteSigned 

# ENable Group Policy for Powershell
$_urlBase = 'https://raw.githubusercontent.com/TurboBasic/.dotfiles/master/windows/GroupPolicy/'
$_scriptBase = "$env:temp\" + [string][System.Guid]::NewGuid()
$_scriptName = $_scriptBase + ".registry.pol"
(iwr "$_urlBase/registry.pol").Content > ($_scriptName)
$_lgpo='d:\$install\$software\lgpo\lgpo.exe'
cmd /c $_lgpo /m $_scriptName
cmd /c $_lgpo /u $_scriptName

# Import our module for managing Environment variables from https://github.com/TurboBasic/.dotfiles
$_scriptName = $_scriptBase + ".ps1"
$_urlBase = 'https://raw.githubusercontent.com/TurboBasic/.dotfiles/master/windows/powershell/Modules'
(iwr "$_urlBase/Environment/Environment.psm1").Content > $_scriptName
(iwr "$_urlBase/Commands/Commands.psm1").Content >> $_scriptName
(iwr "$_urlBase/UtilsScoop/UtilsScoop.psm1").Content >> $_scriptName
echo "Environment.psm1, Commands.psm1 and UtilsScoop.psm1 downloaded to $_scriptName"

. $_scriptName
echo "Sourced $_scriptName, begin executing script"


# Here we go - Boxstarter script itself

$ErrorActionPreference = "Continue"

Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles `
    -EnableShowFileExtensions -EnableShowFullPathInTitleBar -EnableOpenFileExplorerToQuickAccess `
    -EnableShowFrequentFoldersInQuickAccess -EnableExpandToOpenFolder

Enable-RemoteDesktop

# as we are sourcing this to boxstarter, boxstarter installs chocolatey if it is absent
# so at this point we already have choco

Set-EnvironmentVariable -Name '(c)Tools'  c:\tools                      Machine $false  # setx -Tools c:\tools
Set-EnvironmentVariable -Name MSYS2_ROOT  '%(c)Tools%\msys64'           Machine $true
Set-EnvironmentVariable -Name Cmder_Root  '%(c)Tools%\cmdermini'        Machine $true
Set-EnvironmentVariable -Name Git         "%ProgramFiles%\Git"          Machine $true
Set-EnvironmentVariable -Name '(c)Choco'  "%ProgramData%\chocolatey"    Machine $true
Set-EnvironmentVariable -Name '(c)SCOOP_GLOBAL'  "%ProgramData%\Scoop"  Machine $true
Set-EnvironmentVariable -Name SCOOP_GLOBAL       '%(c)SCOOP_GLOBAL%'    Machine $true
#Set-EnvironmentVariable -Name '-SCOOP'          "$env:UserProfile\Scoop"                            User    $false
#Set-EnvironmentVariable -Name SCOOP             '%-Scoop%'                                          User    $true
Set-EnvironmentVariable -Name Choco                   "%(c)Choco%"      Machine $true
Set-EnvironmentVariable -Name ChocolateyToolsLocation "%(c)Tools%"      Machine $true
Set-EnvironmentVariable -Name ChocolateyInstall       "%(c)Choco%"      Machine $true
Set-EnvironmentVariable -Name Dropbox   c:\mnt\data\Dropbox             User    $false
Set-EnvironmentVariable -Name OneDrive  c:\mnt\data\OneDrive            User    $false
Set-EnvironmentVariable -Name Notepad   "%ProgramFiles(x86)%\notepad++\notepad++.exe"   Machine $true
Broadcast-EnvironmentChanges

cmd /c mklink /d %UserProfile%\SendTo\Send2SendTo %UserProfile%\SendTo
cmd /c mklink /d %UserProfile%\SendTo\StartMenu "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs"
New-Shortcut -name "${env:ALLUSERSPROFILE}\Microsoft\Windows\Start Menu\Programs\Cmder" -target "%Cmder_Root%\Cmder.exe" -icon "%Cmder_Root%\icons\cmder.ico"

# upgrade choco to pre-release version ܍
cinst -y -pre chocolatey

cinst -y NuGet.CommandLine
cinst -y 7zip
# TODO: set 7zip language english in registry and write-protect the key
cinst -y linkshellextension systemexplorer treesizefree doublecmd
cinst -y --ignore-checksums registrymanager 
cinst -y --ignore-checksums rapidee

cinst -y git
# configure git
# TODO git clone https://gist.github.com/3883098.git  - clone gists
# git config --global core.editor notepad++

  #cinst -y msys2
cinst -y fab
cinst -y -pre cmdermini    
cinst -y notepadplusplus.install --x86
cinst -y launchy putty kdiff3 everything
  #cinst -y hackfont firacode lato sourcecodepro robotofonts nexusfont
  #cinst -y --allow-empty-checksums ubuntu.font 

  #cinst -y dropbox evernote
cinst -y googlechrome 
  #cinst -y firefox-dev -pre -packageParameters "l=en-GB" --ignore-checksums
cinst -y qbittorrent

Broadcast-EnvironmentChanges


<#

### get scoop installed as well
#$_scoop = 'c:\tools\scoop'
#setx SCOOP $_scoop
#$env:SCOOP = $_scoop
#setx PATH "$env:PATH;$_scoop\shims" /m
iwr https://get.scoop.sh -UseBasicParsing | iex
scoop install sudo

$utils = "$(Split-Path $profile)\Modules\Utils\"
md $utils -force
$utils += "Utils.psm1"
cp (Resolve-Path "$(scoop which scoop)\..\..\lib\core.ps1") $utils
echo @"

Export-ModuleMember -Function is_admin, abort, error, warn, success, basedir, appsdir, shimdir, 
  ensure, fullpath, relpath, dl, unzip, shim
"@ | Add-Content $utils
# Now we have scoop's shim command and other useful utilities

#scoop bucket add extras
#sudo scoop install notepadplusplus -a 32bit --global
#$files = Get-ChildItem "$env:Scoop_Global\shims\notepad++.*"
#foreach ($file in $files) {
#  cp $file "$env:Scoop_Global\shims\npp$($(get-item $file).Extension)"
#  cp $file "$env:Scoop_Global\shims\np$($(get-item $file).Extension)"
#}
# now we have 'notepad++', 'npp' and 'np' commands to run notepad++

#>

#cinst Microsoft-Windows-Subsystem-Linux -source windowsfeatures 
#cinst Microsoft-Hyper-V-All -source windowsFeatures

# install regional settings, computer name, reboot
# fonts
# mkdir c:\mnt\Data\Dropbox
# mkdir c:\mnt\Data\OneDrive
# mklink ...

Broadcast-EnvironmentChanges
