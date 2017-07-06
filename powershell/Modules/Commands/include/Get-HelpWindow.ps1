Function Get-HelpWindow {
  $command = "Get-Help $($args -join ' ') -ShowWindow"
  Write-Verbose $command
  Invoke-Expression $command
}