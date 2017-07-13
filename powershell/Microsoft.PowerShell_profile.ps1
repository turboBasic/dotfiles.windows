### Version: 0.3.0
#~~~Requires -Modules Environment

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
                  "welcome":             "Початок роботи скріпту профіля користувача ...",
                  "globalVarsError":     "Глобальні змінні не визначені -- {0} не знайдено.\nСкріпти, модулі та інші компоненти не працюватимуть"
              },
              "en-US":  {
                  "moduleSuccess":       "SUCCESS: {0} loaded",
                  "moduleLoading":       "Loading: {0}",
                  "localisation":        "Localisation {0} loading...",
                  "moduleFailure":       "FAILURE: Sorry, no {0} found...",
                  "exit":                "Good-bye!",
                  "errorLocalisation":   "Language {0} not found, using {1} instead",
                  "welcome":             "Entering User profile script profile ...",
                  "globalVarsError":     "Global Variables are not set -- {0} not found.\nScripts, modules and other stuff may not work"
              }
          }
        }
'@    }

    $GlobalVarScript = DATA {
      '/Modules/Environment/include/Set-UserGlobalVariables.ps1'
    }

  #endregion



#region Public functions declaration

  Function Copy-AllModules {
    $From = "$__projects/dotfiles.windows/Powershell"
    $To =    $__profileDir
    $ExcludeFolder = '.git'

    $What = @{From="$From/Modules";     To="$To/Modules";     Files=,'*'; XD=$ExcludeFolder },
            @{From="$From/_profiles";   To="$To/_profiles";   Files=,'*'; XD=$ExcludeFolder },
            @{From="$From/ISE_profile"; To="$To/ISE_profile"; Files=,'*'; XD=$ExcludeFolder },
            @{From=$From; To=$To; Files='*profile.ps1', '*.json', 'Powershell.xml', '_install*.*'; XD='*' }

    $What | ForEach { robocopy $_.From  $_.To  $_.Files /MIR /FFT /Z /XA:H /W:5 /XD $_.XD }
  }


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

  }


  $newAliases = {
    New-Alias 7zpath New-7zpath                        -Force -Scope Global
    New-Alias ginfo  Get-InfoVariables                 -Force -Scope Global
    New-Alias gist   Get-GithubGistApiUrlOfCurrentUser -Force -Scope Global
  }

#endregion





#region Execution


  if( -Not(Get-Command Initialize-Localization -EA 0) ) {
    Import-module Environment -Force
  }
  . (Join-Path $PsScriptRoot '/modules/Environment/include/Add-EnvironmentScopeType.ps1')



  Initialize-Localization (ConvertTo-Hashtable $assets)
  Set-Localisation 'uk-UA'



  Write-Host $PSVersionTable.PSVersion.ToString()
  Write-Host $__messages.welcome



  #region Set Global Variables

    & {
        $ok = $true
        $newPath = Join-Path (Split-Path $profile -Parent) $GlobalVarScript
        $ok = $ok -And (Test-Path $newPath)

        & $newPath

        $ok = $ok -And $?
        if( !$ok ) {
          Write-Warning $__messages.GlobalVarsError -f (Split-Path $GlobalVarScript -Leaf)
        }
    }

  #endregion




  Copy-AllModules
  Import-Module posh-git

. $newFunctions
. $newAliases



#endregion
