. (Join-Path $psScriptRoot 'Add-EnvironmentScopeType.ps1')

Function Remove-EnvironmentVariable {
  <#   
      .SYNOPSIS
      This cmdlet deletes environment variable according to set of criteria

      .EXAMPLE
      Remove-EnvironmentVariable -Name Var -Scope User
  #>

  #region Remove-EnvironmentVariable Parameters
    PARAM(
      [PARAMETER( Mandatory, Position=0 )]
      [String] 
      $Name,

      [PARAMETER( Position=1 )]
      [EnvironmentScope] 
      $Scope='Process'
    )
  #endregion


  BEGIN {}

  PROCESS {
    Write-Verbose "Deleting environment variable $Name, scope: $Scope"
    if ( $Scope -eq 'Process' ) { 
        Remove-Item ENV:$Name 
    }
    else {
        (Get-EnvironmentKey $Scope -Write).DeleteValue($Name) 
    }
  }
 
  END {}  
}




