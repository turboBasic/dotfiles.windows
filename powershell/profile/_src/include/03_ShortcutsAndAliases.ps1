#region Global aliases & keyboard-saving shortcut functions

  function cppr {   # CoPy-PRofile from repository
    Try { & ${ENV:projects}\dotfiles.windows\powershell\profile\build.ps1 }
    Catch { 
      'Error while trying to run build file in source repository for Powershell profile' | Write-Warning 
    }
  }


  function g2src {  # Go 2 SouRCe directory
      Push-Location ${ENV:projects}\dotfiles.windows\powershell
  }


  function g2pr {   # Go 2 PRofile directory
      Push-Location (Split-Path $profile -parent)
  }

  
  function clistl {
	"choco list -lo $($args -join ' ')" | Invoke-Expression
  }


  function clists {
	"choco list --id-starts-with $($args -join ' ')" | Invoke-Expression
  }


  function cinsty {
	"choco install -y $($args -join ' ')" | Invoke-Expression
  }
  

  function Get-GithubGistApiUrlOfCurrentUser { $Global:__githubGist }


  function Get-InfoVariables {
      Get-Variable | Format-Table -Property Name, Options, Value -Autosize -Wrap
  }

  New-Alias 7zpath New-7zpath                        -force -scope Global
  New-Alias ginfo  Get-InfoVariables                 -force -scope Global
  New-Alias gist   Get-GithubGistApiUrlOfCurrentUser -force -scope Global

#endregion
