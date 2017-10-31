[CmdletBinding()]
PARAM(
    [string[]]
    $task = 'default',
    
    [switch]
    $noDepend = $True
)



$psakeParams = @{
    buildFile = Join-Path $PSScriptRoot build.Psake.ps1 
    taskList =  $task 
    noLogo =    $True 
    verbose =   ($verbosePreference -eq 'Continue')
}


Invoke-Psake @psakeParams 
exit ( [int]( -not $psake.build_success ) ) 
