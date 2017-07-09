### Version: 0.3.0
#~~~Requires -Modules Environment

#region Public functions declaration

  Function Set-Localisation([String]$language='en-US') {

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

    if ($isValid) {
      $Global:__currentLanguage = $language 
    } else { 
      $Global:__messages.errorLocalisation -f $language, $Global:__currentLanguage | Write-Error
    }

    $Global:__messages.localisation -f $Global:__currentLanguage | Write-Verbose

  }    # Function Set-Localisation


  Function Copy-AllModules {
    $From = Convert-Path "$__projects/dotfiles.windows/Powershell/Modules"
    $To = Convert-Path "$__profileDir/Modules"
    $ExcludeFolderMatch = '.git'
    Write-Verbose $From
    Write-Verbose $To

    Copy-Tree -From $From -To $To -ExcludeFolderMatch $ExcludeFolderMatch
  }


  Function Import-AllModules {
    $modules = @{
      'Vendor module Chocolatey' = "$ENV:ChocolateyInstall/helpers/chocolateyProfile.psm1"
      'User module Commands'     = "$__profileDir/Modules/Commands"
      'User module Environment'  = "$__profileDir/Modules/Environment"
      'User module UtilsScoop'   = "$__profileDir/Modules/UtilsScoop"
      'User module Test'         = "$__profileDir/Modules/Test"
    }

    $modules.Keys | ForEach-Object {
      if(-Not( Test-Path ($m = $modules.$_) )) { 
        $m = Split-Path -Leaf $m 
      }

      $__messages.moduleLoading -f $_ | Write-Verbose
      Import-Module $m -Force
      $( if   ($?) { $__messages.moduleSuccess }
         else      { $__messages.moduleFailure } ) -f $_ | Write-Verbose
    }

  }       # Function Import-AllModules


  $newFunctions = {

      Function Global:cppr { 
          Copy-Item -LiteralPath $__profileSource -Destination $__profileDir -Force -Verbose 
      }

      Function Global:g2pr { 
          Push-Location $__profileDir 
      }

      Function Global:Get-GithubGistApiUrlOfCurrentUser { $Global:__githubGist }

      Function Global:New-7zpath([String]$Path) { 
        $parentDir = Split-Path -Parent $Path
        $files = $Path + '\*'
        $archiveName = $parentDir + '\' + (Split-Path -Leaf $Path) + '-FullPaths.7z'
        Invoke-Expression "7z a -spf2 -myx -mx $archiveName $files" 
      }

      Function Global:Get-InfoVariables {
        Get-Variable | Format-Table -Property Name, Options -Autosize
      }

      'loading functions...' | Write-Verbose

  }       # $newFunctions

  $newAliases = {                           # TODO remove this -> move to USER
    'Creating aliases...' | Write-Verbose
    New-Alias 7zpath New-7zpath                        -Force -Scope Global
    New-Alias ginfo  Get-InfoVariables                 -Force -Scope Global
    New-Alias gist   Get-GithubGistApiUrlOfCurrentUser -Force -Scope Global 
  }


Function Set-Profile {

  #region local functions declarations

    Function New-UserSymlink {              # TODO remove this -> move to USER
      $_users = Resolve-Path '~\..'
      if ( !(Test-Path( Join-Path $_users $__userName )) ) {
        Write-Verbose "Creating symlink directory $__userName\ in $_users ..."
        New-SymLink -Path $ENV:USERPROFILE -SymName $__userName -Directory
      }
    }

    Function Set-RegistryTweaks {           # TODO remove this -> move to USER
      Write-Verbose 'Applying some registry tweaks...'

      $item = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0}\PropertyBag'
      Set-ItemProperty ($item -f '{35286a68-3c57-41a1-bbb1-0eae73d76c95}') -Name ThisPCPolicy -Value Hide
      Set-ItemProperty ($item -f '{a0c69a99-21c8-4671-8703-7934162fcf1d}') -Name ThisPCPolicy -Value Hide

    }

    Function Set-Themes {                   # TODO remove this -> move to USER
      #    Write-Verbose "Sourcing Solarized color theme files..."
      #    . (Join-Path -Path $profileDir -ChildPath $(switch($HOST.UI.RawUI.BackgroundColor.ToString()){'White'{'Set-SolarizedLightColorDefaults.ps1'}'Black'{'Set-SolarizedDarkColorDefaults.ps1'}default{return}}))
    }

    Function Update-HelpFiles {             # TODO remove this -> move to USER
      $params = @{ 
        Name = 'UpdateHelpJob'
        Credential = "${ENV:ComputerName}\${ENV:UserName}"
        ScriptBlock = {
          Save-Help -Destination e:\Downloads\PowershellHelp -UIculture en-US
          Update-Help -SourcePath e:\Downloads\PowershellHelp -Recurse -Force -EA 0 
        }
        Trigger = (New-JobTrigger -Daily -At '3 AM')
      }

      if (!(Get-ScheduledJob -Name UpdateHelpJob)) {
        Register-ScheduledJob @params
      }
    }

  #endregion

  Copy-AllModules
  Import-AllModules

  New-UserSymlink
  # Set-EnvironmentVariables                # TODO Remove this completely

  Set-Themes
  Set-RegistryTweaks

  Update-HelpFiles
  . $newFunctions
  . $newAliases

}       # Function Set-Profile

#endregion


#region Execution

  Set-Localisation 'uk-UA'
  Write-Host $PSVersionTable.PSVersion.ToString()
  Write-Host $__messages.welcome

  #region Set Global Variables

    # TODO separate Machine and User variables:  Here should be $Global: variables only!
    # TODO Machine ENV: variables and environment should be already set up in Machine Startup script
    # TODO User    ENV: variables and environment should be already set up in User Logon script

<#

    Proposed Environment setting procedure execution order:

    1) Machine Startup Scripts:

          %systemRoot%\System32\GroupPolicy\Machine\Scripts\Startup\bbro-startup.ps1

    2) User Logon Scripts:

          %systemRoot%\System32\GroupPolicy\User\Scripts\Logon\bbro-mao-logon.ps1

    3) Powershell profile when running Powershell

          - Set $Global: variables based on ENV: Machine, User and Volatile variables

#>

    $err = $False
    '/Modules/Environment/include/Set-UserGlobalVariables.ps1' | 
        ForEach { Join-Path (Split-Path $profile -Parent) $_ } |
        Where { ($err = Test-Path $_) | Out-Null ; $_ } |
        ForEach { & $_ ; $err = $err -and $? }
  
    if( $err ) {
      Write-Warning 'Global Variables are not set -- Set-UserGlobalVariables.ps1 not found.'
      Write-Warning "Scripts, modules and other stuff may not work"
    }

  #endregion

  Set-Profile

#endregion
