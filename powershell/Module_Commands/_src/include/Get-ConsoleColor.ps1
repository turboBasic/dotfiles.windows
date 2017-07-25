Function Get-ConsoleColor {
  PARAM(
      [Switch]
      $Colorize
  )
 
  $wsh = New-Object -ComObject wscript.shell
  $data = [enum]::GetNames([Consolecolor])
 
  if ($Colorize) {
    Foreach ($color in $data) {
      Write-Host $color -ForegroundColor $Color
    }
    [Void]$wsh.Popup( 
        "The current background color is $([console]::BackgroundColor)", 
        16, 
        'Get-ConsoleColor' 
    )
    Return
  }
 
  $data
} 
