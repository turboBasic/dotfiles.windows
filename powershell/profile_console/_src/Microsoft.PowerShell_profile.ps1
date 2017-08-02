@{Version=0.3.0}|Out-Null
#~~~Requires -Modules Environment



function Main {
<# user profile tasks which should not affect Global namespace #>

  [CmdletBinding()] [OutputType([void])] 
  PARAM()

 # @TODO( Turn some Environment Variables On/Off using Hashtable or Array
 # $env.Blacklist = @( 'nodePath', 'nvm_Home' )

  $savedVerbosePreference = $verbosePreference
  $verbosePreference = 'Continue'
  Write-Host $psVersionTable.psVersion.ToString()
  Write-Host $__messages.welcome
}



function Get-Initial {
  @{
      includes = (Join-Path $psScriptRoot 'profile_console/include/*.ps1')   # Global Public functions
      variablesToRemoveFromGlobal = @()
      functionsToRemoveFromGlobal = @('Get-Initial', 'Main')
  }
}


#region constants

#endregion


#region Global Variables

#endregion


#region Global aliases & keyboard-saving shortcut functions

  function cppr {   # CoPy-PRofile from repository
    $profileSourcePath = 'dotfiles.windows/powershell/profile_console'

    Try { & ${ENV:projects}\$profileSourcePath\build.ps1 }
    Catch { 
      'Error while trying to run build file in source repository for Powershell profile' | Write-Warining 
    }
  }


  function g2src {  # Go 2 SouRCe directory
      Push-Location E:\0projects\dotfiles.windows\powershell
  }


  function g2pr {   # Go 2 PRofile directory
      Push-Location (Split-Path $profile -parent)
  }


  function Get-GithubGistApiUrlOfCurrentUser { $Global:__githubGist }


  function Get-InfoVariables {
      Get-Variable | Format-Table -Property Name, Options, Value -Autosize -Wrap
  }


  New-Alias 7zpath New-7zpath                        -force -scope Global
  New-Alias ginfo  Get-InfoVariables                 -force -scope Global
  New-Alias gist   Get-GithubGistApiUrlOfCurrentUser -force -scope Global


#endregion


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
'@  }

#endregion




#region Execution

                                                            <#
                                                              if( -Not(Get-Command Initialize-Localization -EA 0) ) {
                                                                Import-module Environment -Force
                                                              }

                                                              Initialize-Localization (ConvertTo-Hashtable $assets)
                                                              Set-Localisation 'uk-UA'



                                                              #>

                                                            #  Import-Module posh-git

                                                            #. $newFunctions
                                                            #. $newAliases

  Get-ChildItem -path $includes -file -recurse -ErrorAction SilentlyContinue | 
      ForEach-Object {
        Write-Verbose "dot sourcing file $( $_.FullName )"
        . $_.FullName 
      }

  Main


#endregion
