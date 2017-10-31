function Get-EnvironmentKey {
<#
  .SYNOPSIS
Returns Registry key which holds particular part of Machine or User environment variables

  .DESCRIPTION
Helper function Get-EnvironmentKey returns Registry key which holds particular part of Machine or User environment variables. 
Does not modify registry.

#>


    [CmdletBinding()]
    PARAM(
        [PARAMETER( Mandatory, Position=0 )]
        [EnvironmentScope]
        [ALIAS( 'scope', 'context' )]
        $from
    )



    switch( $from ) {
    
        'Process' {
            $Null
            break
        }
    
        'User' {
            Get-Item -path HKCU:/Environment
            break
        }
        
        'Volatile' {
            Get-Item -path 'HKCU:/Volatile Environment'
            break
        }
        
        'Machine' {
            Get-Item -path ( 
              'HKLM:/SYSTEM/CurrentControlSet/
                  Control/Session Manager/Environment' | Remove-NewlineAndIndent
            )
            break
        }
        
    }

}