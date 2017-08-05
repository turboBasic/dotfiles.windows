function Remove-IndentationMark {
    PARAM( 
      [String]
      $DeleteBefore = '…' 
    )

    $DeleteBefore = [Regex]::Escape( $DeleteBefore )

    ($Input + $Args) | 
        ForEach { $_ -replace "(?m)$Del", '' }
}