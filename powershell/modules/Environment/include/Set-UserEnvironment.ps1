Function Set-UserEnvironment {

  #region Parameters
    [CMDLETBINDING(
      SupportsShouldProcess=$True,
      ConfirmImpact="Medium"
    )]
    PARAM(
        [PARAMETER( Mandatory=$False,
                    ValueFromPipeline=$False, 
                    HelpMessage='Reset user environment')]
            [switch]
            $Initialise
    )
  #endregion

  Write-Verbose "`n Set-UserEnvironment `n"
  $__user_variables.Keys | 
      ForEach-Object { 
          Set-Environment -Name $_ -Value $__user_variables[$_] -Scope User -Expand:($__user_variables[$_] -match '%..*%') 
      }

  Send-EnvironmentChanges 
}