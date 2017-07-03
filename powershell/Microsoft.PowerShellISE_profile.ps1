function loadProfile {
    $globalVars = 'GlobalVariables.ps1'
    $savedVerbosePreference = $VerbosePreference
    $VerbosePreference = 'Continue'

    $s = @($PSScriptRoot, "$PSScriptRoot/_profiles", '.') | %{ Convert-Path "$_/$globalVars" -ErrorAction SilentlyContinue } | ? { Test-Path $_ } | Select -First 1
    if($s) {
        Write-Verbose 'Global Variables found -- setting them up...'
        . $s
        Set-GlobalVariables
    } else {
        Write-Error 'Global Variables are not set -- file GlobalVariables.ps1 not found'
        if ($__profile -eq $null) {
            $VerbosePreference = $savedVerbosePreference 
            Break 
        }
    }

    $addonDir = 'ISE_profile'
    $sourceBaseDir = "$__projects/dotfiles.windows/powershell/$addonDir"
    Write $sourceBaseDir
    Copy-Item -Recurse -filter *.ps1 -Force $sourceBaseDir "$__profileDir/" 

    $includes = @(
      "$__profileDir/$addonDir/*.ps1"
    )

    $includes | %{ Convert-Path $_ } | %{ . $_ }
    $VerbosePreference = $savedVerbosePreference
}

loadProfile


