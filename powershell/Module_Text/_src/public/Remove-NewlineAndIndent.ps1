function Remove-NewlineAndIndent {

  ($Input + $Args) |
      ForEach-Object { $_ -replace '(?s)\s*[\r\n]\s*' }

}