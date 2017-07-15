function loadProfile {
    $globalVars = 'Set-UserGlobalVariables.ps1'
    $savedVerbosePreference = $VerbosePreference
    $VerbosePreference = 'Continue'

    . "$PSScriptRoot/Modules/Commands/include/Get-GistMao.ps1"
    . "$PSScriptRoot/Modules/Commands/include/ConvertTo-Hashtable.ps1"

    $s = @( (Join-Path (Split-Path $profile -parent) '/Modules/Environment/include/'),
            (Join-Path $PSScriptRoot '/Modules/Environment/include/') ) | 
          ForEach { Convert-Path "$_/$globalVars" -ErrorAction SilentlyContinue } | 
          Where { Test-Path $_ } | 
          Select -First 1

    if($s) {
        Write-Verbose 'Global Variables found -- setting them up...'
        . $s
        Set-UserGlobalVariables
    } else {
        Write-Error "Global Variables are not set -- file $globalVars not found"
        if ($__profile -eq $null) {
            $VerbosePreference = $savedVerbosePreference 
            Break 
        }
    }

    "$__profileDir/ISE_profile/*.ps1" | 
            ForEach { . (Convert-Path $_) } 

    $VerbosePreference = $savedVerbosePreference
}

loadProfile