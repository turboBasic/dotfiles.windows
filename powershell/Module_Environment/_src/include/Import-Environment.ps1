Function Import-Environment {

  #region Parameters
    [CMDLETBINDING( SupportsShouldProcess, ConfirmImpact='Medium' )]
    PARAM(
        [PARAMETER( Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [Hashtable]
        $Environment,

        [PARAMETER( Mandatory, Position=1 )]
        [EnvironmentScope]
        $Scope,

        [PARAMETER()]  # Reset environment
        [Switch]
        $Initialise 
    )
  #endregion

  Write-Verbose "`n Import-Environment `n"
  $Environment.Keys | 
      ForEach { 
          Set-Environment -Name $_ -Value $Environment[$_] -Scope $Scope -Expand:($Environment[$_] -match '%..*%') 
      }

  Send-EnvironmentChanges 
}