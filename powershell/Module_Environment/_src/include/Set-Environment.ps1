function Set-Environment {

  [CmdletBinding( PositionalBinding = $False )] 
  PARAM(
      [PARAMETER( Mandatory, Position=0 )]
      [string]
      $Name,

      [PARAMETER( Mandatory, Position=1 )]
      [string]
      $Value,

      [PARAMETER( Position=2 )]
      [string]
      $Scope = 'Process',

      [PARAMETER( Position=3 )]
      [switch]
      $Expand
  )


  BEGIN {
      $type = 'String'
      if( $Expand ) { 
          $type = 'ExpandString' 
      }
  }

  PROCESS {
      if( $Scope -eq 'Process' ) {
          if( $Expand ) { 
              $Value = [Environment]::ExpandEnvironmentVariables( $Value ) 
          }
          Set-Item -path ENV:\$Name -value $Value
          return  
      } 

      Try { 
          $key = Get-EnvironmentKey -scope $Scope
          Set-ItemProperty -path $key.PSPath -name $Name -value $Value -type $type
      } Catch { 
          "Cannot open $Scope / $Name for editing - please 
              switch to elevated cmd!" | Remove-NewLineAndIndent | Write-Error
      } Finally { 
          if( $key ) { 
            $key.Flush() 
          }
      }    
  }

  END {}
}