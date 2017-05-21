# Run: START http://boxstarter.org/package/nr/url?https://gist.githubusercontent.com/maoizm/7d0192e9b9493dcd503449fa6a389b49/raw/4a7470fe1b0a81c8b78d7d42150d55c303f826bb/boxstarter.ps1
#  or: START http://boxstarter.org/package/nr/url?c:\install\boxstarter.ps1
#
# Powershell >= 5  but mostly should work at v3+
Set-ExplorerOptions -showHiddenFilesFoldersDrives -showProtectedOSFiles -showFileExtensions
Enable-RemoteDesktop

Set-ExecutionPolicy RemoteSigned 
# as we are sourcing this to boxstarter, boxstarter installs chocolatey if it is absent
# so at this point we already have choco

# upgrade choco to pre-release version
cinst -y -pre chocolatey
cinst -y NuGet.CommandLine
cinst -y 7zip
# TODO: set 7zip language english in registry and write-protect the key
cinst -y linkshellextension
cinst -y --ignore-checksums registrymanager 
cinst -y --ignore-checksums rapidee
cinst -y git
#  git clone https://gist.github.com/3883098.git  - clone gists
cinst -y msys2

# configure git
git config --global core.editor notepad++

### get scoop installed as well
setx SCOOP "%USERPROFILE%\scoop"
setx SCOOP_GLOBAL "%PROGRAMDATA%\scoop" /m
iwr https://get.scoop.sh -UseBasicParsing | iex
scoop install sudo

$utils = "$(Split-Path $profile)\Modules\Utils\"
md $utils -force
$utils += "Utils.psm1"
cp (Resolve-Path "$(scoop which scoop)\..\..\lib\core.ps1") $utils
echo @"

Export-ModuleMember -Function is_admin, abort, warn, success, basedir, appsdir, shimdir, 
  ensure, fullpath, relpath, dl, unzip, shim
"@ | Add-Content $utils
# Now we have scoop's shim command and other useful utilities

scoop bucket add extras
sudo scoop install notepadplusplus -a 32bit --global
$files = Get-ChildItem "$env:Scoop_Global\shims\notepad++.*"
foreach ($file in $files) {
  cp $file "$env:Scoop_Global\shims\npp$($(get-item $file).Extension)"
  cp $file "$env:Scoop_Global\shims\np$($(get-item $file).Extension)"
}
# now we have 'notepad++', 'npp' and 'np' commands to run notepad++

cinst -y fab
cinst -y -pre cmdermini    #cinst -y notepadplusplus.install --x86
cinst -y launchy putty kdiff3 everything

cinst Microsoft-Windows-Subsystem-Linux -source windowsfeatures 
cinst Microsoft-Hyper-V-All -source windowsFeatures

# install regional settings, computer name, reboot
# fonts
# mkdir c:\mnt\Data\Dropbox
# mkdir c:\mnt\Data\OneDrive
# mklink ...

cinst -y dropbox evernote
cinst -y googlechrome 
cinst -y firefox-dev -pre -packageParameters "l=en-GB" --ignore-checksums
cinst -y qbittorrent