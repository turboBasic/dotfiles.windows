Function Export-Environment {

  PARAM(
      [PARAMETER( Position=0 )]
      [VALIDATESCRIPT({ $_.IndexOfAny( [System.IO.Path]::GetInvalidFileNameChars() ) -eq -1 })]
      [String]
      $Path = 'export_{0}.csv' -f (Get-Date -uFormat "%Y%M%d_%H%m%S")

      # TODO -NoClobber
      # TODO -Append
  )

  Get-Environment * * | 
        ConvertTo-Csv -noTypeInformation | 
        Out-File $Path -Encoding UTF8 -NoClobber

}