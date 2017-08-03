  $__dotSource = {
    PARAM(
      [PARAMETER( Mandatory, Position=0 )]
      [string[]]
      $path
    )

    Get-ChildItem -path $path -ErrorAction SilentlyContinue |
      Where-Object Name -NotLike '__*.ps1' |
      ForEach-Object { 
        Write-Verbose "dot sourcing file $( $_.FullName )"
        . $_ 
      }
  }
  

  $__savedVerbosePreference = $verbosePreference
  $verbosePreference = 'Continue'
  

  . $__dotSource -path ( 
        $__includes |
            Get-ChildItem -file |
            Select -expandProperty FullName
    )