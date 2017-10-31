function Export-Environment {

  PARAM(
      [PARAMETER( Position=0 )]
      [ValidateScript({ 
          $_.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -eq -1 
      })]
      [string]
      $Path = 'export_{0}.csv' -f (Get-TimeStamp -short)

      # TODO -NoClobber
      # TODO -Append
  )

  Get-Environment * * | 
        ConvertTo-Csv -noTypeInformation | 
        Out-File $Path -encoding UTF8 -noClobber

}
