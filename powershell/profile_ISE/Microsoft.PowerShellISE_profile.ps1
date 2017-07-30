Function loadProfile {

  #Import-Module Commands

  #region constants
    $savedVerbosePreference = $verbosePreference
    $verbosePreference = 'Continue'
    $globalVars = 'Set-UserGlobalVariables.ps1'
    $includes = Join-Path $psScriptRoot 'profile_ISE/include/*.ps1'
  #endregion

  
  #region include sub-scripts
    Get-ChildItem $includes -ErrorAction SilentlyContinue |
        Foreach-Object { . $_ }
  #endregion

  $s = @( (Join-Path (Split-Path $profile) 'Modules/Environment/include'),
          (Join-Path $psScriptRoot 'Modules/Environment/include') 
        ) | 
          ForEach-Object { 
              Convert-Path "$_/$globalVars" -ErrorAction SilentlyContinue 
          } | 
          Where-Object { Test-Path $_ } | 
          Select-Object -First 1

  if($s) {
  
      Write-Verbose 'Global Variables found -- setting them up...'
      . $s
      Set-UserGlobalVariables
      
  } else {
  
      Write-Error "Global Variables are not set -- file $globalVars not found"
      if( !$__profile ) {
          $VerbosePreference = $savedVerbosePreference 
          Return 
      }
      
  }


  $verbosePreference = $savedVerbosePreference
}

loadProfile