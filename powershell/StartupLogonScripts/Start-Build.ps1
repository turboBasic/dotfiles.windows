[CMDLETBINDING()]
PARAM(
    [string[]]$Task = 'default'
)

# dependencies

if(!(Get-Module -Name PSDepend -ListAvailable)) {  Install-Module PSDepend  }              # & (Resolve-Path "$PSScriptRoot\helpers\Install-PSDepend.ps1")
Import-Module PSDepend
Get-Command -Module PSDepend

$null = Invoke-PSDepend -Path "$PSScriptRoot\build.requirements.psd1" -Install -Import -Force



#Set-BuildEnvironment -Force

Invoke-psake -buildFile "$PSScriptRoot\psake.ps1" -taskList $Task -nologo -Verbose:$VerbosePreference
exit ( [int]( -not $psake.build_success ) )