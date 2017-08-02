
  function Test-ValidFileName( [string]$testFileName ) { 
  
    foreach( $char in [IO.Path]::GetInvalidFileNameChars() ) { 
      if( $char -in [char[]]$testFileName ) { 
          return $False 
      } 
    }
    return $True
    
  }
