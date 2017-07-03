### Version: 0.3.0
#~~~Requires -Modules Environment

#region Public functions declaration

Function loadLocalisation([string]$language='en-US') {

#region Localized messages

$assets = DATA -supportedCommand ConvertFrom-Json {
ConvertFrom-Json -InputObject @'
  {
    "languages":  [
      "en-US",
      "uk-UA"
    ],
    "messages": {
        "uk-UA":  {
            "moduleSuccess":       "УСПІХ: {0} завантажено",
            "moduleLoading":       "Завантаження: {0}",
            "localisation":        "Підключається локалізація {0} ...",
            "moduleFailure":       "ПОМИЛКА: Неможливо знайти {0} ...",
            "exit":                "До побачення!",
            "errorLocalisation":   "Мову з кодом {0} не знайдено, буде використано мову {1}",
            "welcome":             "Початок роботи скріпту профіля користувача ..."
        },
        "en-US":  {
            "moduleSuccess":       "SUCCESS: {0} loaded",
            "moduleLoading":       "Loading: {0}",
            "localisation":        "Localisation {0} loading...",
            "moduleFailure":       "FAILURE: Sorry, no {0} found...",
            "exit":                "Good-bye!",
            "errorLocalisation":   "Language {0} not found, using {1} instead",
            "welcome":             "Entering User profile script $profile ..."
        }
    }
  }
'@
}

#endregion

  Set-Variable __defaultLanguage -Scope Global -Value $assets.languages[0]        # en-US 
  Set-Variable __currentLanguage -Scope Global -Value $assets.languages[0]
  New-Variable __messages        -Scope Global

  $isDefault = $language -eq $Global:__defaultLanguage
  $isValid   = $language -in $assets.languages
  $Global:__messages = $assets.messages.$Global:__currentLanguage

  if (-Not $isValid) {
    $Global:__messages.errorLocalisation -f $language, $Global:__currentLanguage | Write-Error
  } else { 
    $Global:__currentLanguage = $language 
  }

  $Global:__messages.localisation -f $Global:__currentLanguage | Write-Verbose
}


Function loadEnvironmentVariables {
  Set-MachineEnvironment
  Set-UserEnvironment
}


Function copyModules {
  $From = Convert-Path "$__projects/dotfiles.windows/Powershell/Modules"
  $To = Convert-Path "$__profileDir/Modules"
  $ExcludeFolderMatch = '.git'
  write-verbose $From
  write-verbose $To

  Copy-Tree -from $From -to $To -excludeFolderMatch $ExcludeFolderMatch
}


Function loadModules {
  $modules = @{
    'Vendor module Chocolatey' = "$ENV:ChocolateyInstall/helpers/chocolateyProfile.psm1"
    'User module Commands'     = "$__profileDir/Modules/Commands"
    'User module Environment'  = "$__profileDir/Modules/Environment"
    'User module UtilsScoop'   = "$__profileDir/Modules/UtilsScoop"
    'User module Test'         = "$__profileDir/Modules/Test"
  }

  $modules.Keys | % {
    if(-Not( Test-Path ($m = $modules.$_) )) { 
      $m = Split-Path -Leaf $m 
    }

    $__messages.moduleLoading -f $_ | Write-Verbose
    Import-Module $m -Force
    $( if ($?) 
        { $__messages.moduleSuccess }
      else                       
        { $__messages.moduleFailure } ) -f $_ | Write-Verbose
  }
}


$loadFunctions = {

    Function Global:cppr { Copy-Item -LiteralPath $__profileSource -Destination $__profileDir -Force -Verbose }

    Function Global:g2pr { Push-Location $__profileDir }

    Function Global:New-7zpath([string]$Path) { 
      $parentDir = Split-Path -Parent $Path
      $files = $Path + '\*'
      $archiveName = $parentDir + '\' + (Split-Path -Leaf $Path) + '-FullPaths.7z'
      Invoke-Expression "7z a -spf2 -myx -mx $archiveName $files" 
    }

    Function Global:Get-InfoVariables {
      Get-Variable | Format-Table -Property Name, Options -Autosize
    }

    'loading functions...' | Write-Verbose
}

$loadAliases = {
  'Creating aliases...' | Write-Verbose
  New-Alias 7zpath New-7zpath        -Force -Scope Global
  New-Alias ginfo  Get-InfoVariables -Force -Scope Global
}

Function loadProfile {

  #region local functions declarations

    Function createUserSymlink {
      $_users = Resolve-Path '~\..'
      if ( !(Test-Path( Join-Path $_users $__userName )) ) {
        Write-Verbose "Creating symlink directory $__userName\ in $_users ..."
        New-SymLink -Path $ENV:USERPROFILE -SymName $__userName -Directory
      }
    }

    Function applyRegistryTweaks {
      Write-Verbose 'Applying some registry tweaks...'

$Registrycommands = @'
﻿Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag]
"ThisPCPolicy"="Hide"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag]
"ThisPCPolicy"="Hide"
'@

      # Hide some icons from Explorer
      , 'HideIconsFromThisPC.reg'  |  
          Where-Object{ Test-Path ".\$_" }  |  
          Foreach-Object{ cmd /c regedit.exe /s $_ }
    }

    Function loadThemes {
      #    Write-Verbose "Sourcing Solarized color theme files..."
      #    . (Join-Path -Path $profileDir -ChildPath $(switch($HOST.UI.RawUI.BackgroundColor.ToString()){'White'{'Set-SolarizedLightColorDefaults.ps1'}'Black'{'Set-SolarizedDarkColorDefaults.ps1'}default{return}}))
    }

    # TODO Update-Help make once a day
    Function updateHelpFiles {
      $params = @{ 
        Name = 'UpdateHelpJob'
        Credential = "${ENV:ComputerName}\${ENV:UserName}"
        ScriptBlock = {
          $tagFile = Join-Path $profileDir '.updateHelpFiles'
          Update-Help
          if ($?) { Set-FileTime $tagFile }
          else    { Set-FileTime "${tagFile}_fail"  }
        };
        Trigger = (New-JobTrigger -Daily -At '3 AM')
      }

      if (!(Get-ScheduledJob -Name UpdateHelpJob)) {
        Register-ScheduledJob @params
      }
    }

  #endregion

  copyModules
  loadModules
  createUserSymlink
  loadEnvironmentVariables
  loadThemes
  applyRegistryTweaks
  updateHelpFiles
  . $loadFunctions
  . $loadAliases

  #region initialize pshazz (if installed)
    $pshazz = 'Pshazz'
    $__messages.moduleLoading -f $pshazz | Write-Verbose
    $(  Try   { $null = Get-Command pshazz -ErrorAction Stop
                pshazz init 'default'
                $__messages.moduleSuccess 
              }
        Catch { $__messages.moduleFailure } 
    )  -f $pshazz | Write-Verbose
  #endregion
}

#endregion


#region Execution

  loadLocalisation 'uk-UA'
  Write-Host $PSVersionTable.PSVersion.ToString()
  Write-Host $__messages.welcome

  #region Set Global Variables

    $scriptPath = @($psScriptRoot, '.') | 
          ForEach-Object { Convert-Path "$_/_profiles/GlobalVariables.ps1" } | 
              Where-Object { Test-Path $_ } | Select -First 1

    if($scriptPath) {
      . $scriptPath
      Set-GlobalVariables
    } else {
      Write-Error "Global Variables are not set -- file GlobalVariables.ps1 not found.  Most probably scripts, modules and other stuff won't work"
    }

  #endregion

  loadProfile

#endregion
