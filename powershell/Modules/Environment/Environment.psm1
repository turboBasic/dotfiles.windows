#region initialization of module

  $paths = @(
    'include'
  )

  # dot source the individual scripts that make-up this module
  Foreach ($path in $paths) {
    "$psScriptRoot/$path/*.ps1" |
        Resolve-Path |
            ForEach-Object {
                . $_.ProviderPath
                Write-Verbose "$_.ProviderPath successfully included"
            } 
  } 
  Write-Host -ForegroundColor Green "Module $(Split-Path $PSScriptRoot -Leaf) was successfully loaded."


#endregion



#region shortcut functions (only for saving typing and keyboards)
  Function Get-GithubGist() { $Global:__githubGist }
#endregion



#region Create aliases for functions
  New-Alias -Name genv  Get-Environment              -EA SilentlyContinue
  New-Alias -Name ge    Get-Environment              -EA SilentlyContinue
  New-Alias -Name gist  Get-GithubGist               -EA SilentlyContinue
  New-Alias -Name senv  Set-Environment              -EA SilentlyContinue
  New-Alias -Name se    Set-Environment              -EA SilentlyContinue
  New-Alias -Name rmenv Remove-EnvironmentVariable   -EA SilentlyContinue
#endregion


#region Create Drives
#endregion


#region add custom Data types
#endregion add custom Data Types


Function Export-Environment {
  Get-Environment * * | ConvertTo-Csv -noTypeInformation  > "export_$(Get-Date -uFormat "%Y%M%d_%H%m%S").csv"
}




