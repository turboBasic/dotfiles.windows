### Version: 0.2.0

$__user = "mao"
$__verbose = $True




Function _executeProfile {


  Function _loadModules {
    [cmdletbinding()]
    Param()

    <# Chocolatey profile
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

    Write-Verbose "Load ChocolateyProfile Module..."
    if (Test-Path $ChocolateyProfile) {
      Import-Module "$ChocolateyProfile" -verbose:$__verbose
    } else {
      Write-Verbose "Sorry, no ChocolateyProfile Module found..."
    }
    #>

    $m = Join-Path (Split-Path -Parent $Profile) "Modules"

    "Commands", "Environment", "UtilsScoop" | % {
      Write-Verbose "Load $_ User Module..."
      if (Test-Path(Join-Path $m "$_\$_.psm1")) {
        Import-Module $_ -verbose:$__verbose
      } else {
        Write-Verbose "Sorry, no $_ User Module found..."
      }
    }

  }




  Function _initialize {
    [cmdletbinding()]
    Param()

    $profileDir = Split-Path -Parent $Profile
    Write-Verbose "Profile directory found at $profileDir"


    Write-Verbose "Sourcing Solarized color theme files..."
    . (Join-Path -Path $profileDir -ChildPath $(switch($HOST.UI.RawUI.BackgroundColor.ToString()){'White'{'Set-SolarizedLightColorDefaults.ps1'}'Black'{'Set-SolarizedDarkColorDefaults.ps1'}default{return}}))


    _loadModules -verbose:$__verbose

    $environmentScript = "Set-Environment.ps1"
    Write-Verbose "Sourcing $environmentScript..."

    $environmentScript = Join-Path $profileDir $environmentScript

    if (Test-Path $environmentScript) {
      . $environmentScript
    } else {
      Write-Verbose "Sorry, no $environmentScript script foound..."
    }


  }


  Set-Variable -Name userAlias -Value $__user -Scope Global
  write-host $PSVersionTable.PSVersion.ToString()

  Write "Entering $profile User profile script..."
  _initialize -verbose:$__verbose


}


_executeProfile
