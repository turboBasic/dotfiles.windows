Function Set-MachineEnvironment {

  #region Parameters
    [CMDLETBINDING(
      SupportsShouldProcess=$True,
      ConfirmImpact='Medium'
    )]
    PARAM(
        [PARAMETER( Mandatory=$False,
                    ValueFromPipeline=$False, 
                    HelpMessage='Reset Machine environment' )]
            [switch]
            $Initialise
    )
  #endregion

  Write-Verbose "`n Set-MachineEnvironment `n"
  $__sys_variables.Keys | 
      ForEach-Object { 
          Set-Environment -Name $_ -Value $__sys_variables[$_] -Scope Machine -Expand:($__sys_variables[$_] -match '%..*%') 
      }

  Send-EnvironmentChanges 
}