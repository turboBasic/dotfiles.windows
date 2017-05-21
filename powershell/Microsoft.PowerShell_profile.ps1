Function _initialize() {

  . (Join-Path -Path (Split-Path -Parent -Path $PROFILE) -ChildPath $(switch($HOST.UI.RawUI.BackgroundColor.ToString()){'White'{'Set-SolarizedLightColorDefaults.ps1'}'Black'{'Set-SolarizedDarkColorDefaults.ps1'}default{return}}))

  pushd ~\..
  if (! (Test-Path ".\mao")) { 
      New-SymLink -Path "$env:USERPROFILE" -SymName "mao" -Directory
  }
  popd

  # Chocolatey profile
  $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
  if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
  }

  Try { 
    $null = gcm pshazz -ea stop; pshazz init 'default' 
  } Catch { }

  # Hide some icons from Explorer
  {
    cmd /c regedit.exe /s HideIconsFromThisPC.reg
  }

}


# TODO Update-Help make once a day

write-host $PSVersionTable.PSVersion.ToString()

# Create required symlinks and set environment variables
{
  pushd (Split-Path $profile)
  . .\set_environment.ps1
  popd
}
