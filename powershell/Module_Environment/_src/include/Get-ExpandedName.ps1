function Get-ExpandedName {
<#
    .SYNOPSIS
Expands references to a Variable (%VARIABLE%) in specified Windows environment scope

    .DESCRIPTION
Expands references to variables in CMD.EXE format (eg. %VARIABLE%) and replaces them with actual content of variable. Argument Scope specifies the scope from which the utility is going to take Variable's content.

    .PARAMETER name

    .PARAMETER scope

    .PARAMETER expand

    .EXAMPLE
PS> Get-ExpandedName -name PATH -scope Machine -expand | Format-List   

Scope : Machine
Name  : PATH
Value : C:\WINDOWS;C:\WINDOWS\system32;C:\WINDOWS\system32\wbem;C:\WINDOWS\system32\windowsPowerShell\v1.0;C:\Python27\;C:\Python27\Scripts

    .INPUTS
Does not accept input from the pipeline

    .OUTPUTS
Outputs [PSCustomObject] as the only type of result

    .NOTES
Name:    Get-TimeStamp
Author:  Andriy Melnyk  https://github.com/turboBasic/
Created: 2017.03.10 10:54:31.713

#>


    [CmdletBinding()] 
    [OutputType( [PSCustomObject] )]
    PARAM( 
        [PARAMETER( Mandatory, Position=0 )]
        [ValidateNotNullOrEmpty()]
        [string] 
        $name,

        [PARAMETER( Position=1 )]
        [EnvironmentScope] 
        $scope = [EnvironmentScope]::Process,

        [PARAMETER( Position=2 )]
        [switch] 
        $expand
    )



    switch( $scope ) {

        [EnvironmentScope]::Process {

            Get-ChildItem -path ENV:\$Name -errorAction SilentlyContinue | 
                ForEach-Object { 
                  [PSCustomObject][ordered]@{ 
                      Scope = $scope 
                      Name  = $_.Name; 
                      Value = $_.Value; 
                  } 
                }
            break
        }

        { $_ -in [EnvironmentScope]::Volatile, 
                 [EnvironmentScope]::User, 
                 [EnvironmentScope]::Machine } {
                 
            $key = Get-EnvironmentKey -from $scope
            $key.GetValueNames() | 
                Where-Object { 
                  $_ -like $Name 
                } |
                ForEach-Object { 
                  $item = [ordered]@{ 
                      Scope = $Scope
                      Name = $_ 
                  } 
                  if( -not $Expand ) { 
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
                  [PSCustomObject]$item
                }
            break
        }

        default { 
            Throw "Get-ExpandedName: Argument 'Scope' has illegal value $Scope" 
        }
    }

}