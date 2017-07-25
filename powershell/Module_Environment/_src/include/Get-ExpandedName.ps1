Function Get-ExpandedName {
<#

.SYNOPSIS
    Expands references to a Variable (%VARIABLE%) in specified Windows environment scope

.DESCRIPTION
    Expands references to variables in CMD.EXE format (eg. %VARIABLE%) and replaces them with actual content of variable. Argument Scope specifies the scope from which the utility is going to take Variable's content.

.PARAMETER dateDelimiter

.PARAMETER timeDelimiter

.PARAMETER Delimiter

.PARAMETER NoFractionOfSecond

.PARAMETER NoDelimiters

.PARAMETER Short

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.EXAMPLE

.INPUTS
    Does not accept input from the pipeline

.OUTPUTS
    Outputs [psCustomObject] as the only type of result

.NOTES
Name:    Get-TimeStamp
Author:  Andriy Melnyk  https://github.com/TurboBasic/
Created: 2017.03.10 10:54:31.713

#>

  #region Get-ExpandedName Parameters
      [CMDLETBINDING()] 
      [OUTPUTTYPE( [psCustomObject] )]
      PARAM( 
          [PARAMETER( Mandatory, Position=0 )]
          [VALIDATENOTNULLOREMPTY()]
          [String] 
          $Name,

          [PARAMETER( Position=1 )]
          [EnvironmentScope] 
          $Scope='Process',

          [PARAMETER( Position=2 )]
          [Switch] 
          $Expand
      )
  #endregion



  switch ([String]$Scope) {

    'Process' {

      $res = Get-ChildItem -Path ENV:\$Name -EA SilentlyContinue | 
                ForEach { [psCustomObject][ordered]@{ 
                        Scope = $Scope 
                        Name  = $_.Name; 
                        Value = $_.Value; 
                    } 
                }
      break
    }

    { $_ -in @('Volatile', 'User', 'Machine') } {

      $key = Get-EnvironmentKey -From $Scope -Write:$False
      $res = $key.GetValueNames() | 
                Where { $_ -like $Name } |
                ForEach { 
                  $item = [ordered]@{ Scope = $Scope; Name = $_ } 
                  if (!$Expand) { 
                    $item.Add( 
                        'Value', 
                        $key.GetValue(
                            $_, $null, 
                            [Microsoft.Win32.RegistryValueOptions]::
                            DoNotExpandEnvironmentNames
                        ) 
                    ) 
                  } else { 
                    $item.Add( 'Value', $key.GetValue($_, $null) ) 
                  }
                  [psCustomObject]$item
                }
      break
    }

    default { Throw "Get-ExpandedName: Argument 'Scope' has illegal value $Scope" }

  }

  $res

}