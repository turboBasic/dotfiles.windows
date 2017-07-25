Function Export-Environment {

  PARAM(
      [PARAMETER( Position=0 )]
      [VALIDATESCRIPT({ $_.IndexOfAny( [System.IO.Path]::GetInvalidFileNameChars() ) -eq -1 })]
      [String]
      $Path = 'export_{0}.csv' -f (Get-Date -uFormat "%Y%m%d_%H:%M:%S")

      # TODO -NoClobber
      # TODO -Append
  )

  Get-Environment * * | 
        ConvertTo-Csv -noTypeInformation | 
        Out-File $Path -Encoding UTF8 -NoClobber

}