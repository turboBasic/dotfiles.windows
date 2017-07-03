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
    Function Private:smartShorten([string]$source, [int32]$width, [int32]$left) {
        if($source.length -le $width) {
            return $source
        } else {
            return $source.substring(0, $left) + 
                   " ... " +
                   $source.substring($source.length - ($width-$left-5), $width-$left-5)
        }
    }  
#endregion



#region Create aliases for functions
  New-Alias -Name genv  Get-Environment
  New-Alias -Name ge    Get-Environment
  New-Alias -Name gist  Get-GithubGist
  New-Alias -Name senv  Set-Environment
  New-Alias -Name se    Set-Environment
  New-Alias -Name rmenv Remove-EnvironmentVariable
  New-Alias touch Set-FileTime
  New-Alias ppath Get-EnvironmentPath
  New-Alias sst   Select-String
  New-Alias gg    Get-GuiHelp 
  New-Alias gh    Get-HelpWindow
  New-Alias ghc   Get-Help
  New-Alias ga    Get-Alias
#endregion


#region Create Drives
#endregion


#region add custom Data types
#endregion add custom Data Types




