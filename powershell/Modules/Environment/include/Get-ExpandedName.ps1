Function Get-ExpandedName {
  <#
      .SYNOPSIS 
        Expands %VARIABLE% occurences in specifies Scope

      .DESCRIPTION 
        Expands %VARIABLE% occurences and replaces them with actual content of variable. Argument
        Scope specifies the scope from which the utility is going to take Variable's content.

  #>
  #region Get-ExpandedName Parameters
      [CMDLETBINDING()] 
      PARAM( 
          [PARAMETER( Mandatory, Position=0 )]
          [String] 
          $Name,

          [PARAMETER( Mandatory, Position=1 )]
          [EnvironmentScope] 
          $Scope,

          [PARAMETER( Position=2 )]
          [Switch] 
          $Expand        
      )
  #endregion

  #Write-Verbose "Get-ExpandedName: `$Name = $Name, `$Scope = $Scope, `$Expand = $Expand"
  switch ($Scope) {
    Process {
      $res = Get-ChildItem -Path ENV:\$Name -EA SilentlyContinue | 
                % { [psCustomObject]@{ 
                        Name  = $_.Name; 
                        Value = $_.Value; 
                        Scope = $Scope 
                    } 
                }
      break
    }
    { $_ -in [EnvironmentScope]::Volatile, [EnvironmentScope]::User, [EnvironmentScope]::Machine } {
      $key = Get-EnvironmentKey $Scope $False
      $res = $key.GetValueNames() | ? { $_ -like $Name } |
                % { 
                    $item = @{ Name = $_; Scope = $Scope } 
                    if (!$Expand) { 
                        $item.Add( 'Value', $key.GetValue($_, $null, 
                        [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames) ) 
                    } else { 
                        $item.Add( 'Value', $key.GetValue($_, $null) ) 
                    }

                    [psCustomObject]$item
                }
      break
    }
    default { Throw 'Get-ExpandedName: Strange error in switch statement' }
  }

  $res
}