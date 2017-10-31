function Import-Environment {

  [CMDLETBINDING( SupportsShouldProcess, ConfirmImpact='Medium' )]
  PARAM(
      [PARAMETER( Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [hashtable]
      $Environment,

      [PARAMETER( Mandatory, Position=1 )]
      [EnvironmentScope]
      $Scope,

      [PARAMETER()]  # Reset environment
      [switch]
      $Initialise 
  )


  Write-Verbose "`n Import-Environment `n"
  $Environment.Keys | 
      ForEach { 
          Set-Environment -name $_ -value $Environment[$_] -scope $Scope -expand:($Environment[$_] -match '%..*%') 
      }

  Send-EnvironmentChanges 
}