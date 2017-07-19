# recipe taken from https://devblackops.io/building-a-simple-release-pipeline-in-powershell-using-psake-pester-and-psdeploy/

[CMDLETBINDING()]
PARAM(
    [String[]]$Task = 'default'
)

if (!(Get-Module -Name PSDepend -ListAvailable)) 
    { Install-Module PSDepend }  #  &(Resolve-Path "$PSScriptRoot\helpers\Install-PSDepend.ps1")
    
$null = Invoke-PSDepend -Path "$PSScriptRoot\build.requirements.psd1" -Install -Import -Force    

#TODO(проверить на чистом компьютере - устанавливает ли PSDeploy отсутствующие модули?)
<#  похоже не нужно, PSDeploy сам должен обо всем позаботиться.
 
if (!(Get-Module -Name Pester -ListAvailable))    
    { Install-Module -Name Pester -Scope CurrentUser }
if (!(Get-Module -Name psake -ListAvailable))     
    { Install-Module -Name psake -Scope CurrentUser }
if (!(Get-Module -Name PSDeploy -ListAvailable))  
    { Install-Module -Name PSDeploy -Scope CurrentUser }
    
#>    

Invoke-Psake -buildFile "$PSScriptRoot\psakeBuild.ps1" -taskList $Task -Verbose:$VerbosePreference
exit ( [int]( -not $psake.build_success ) )
