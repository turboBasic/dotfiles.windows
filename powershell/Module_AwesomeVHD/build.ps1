# recipe taken from https://devblackops.io/building-a-simple-release-pipeline-in-powershell-using-psake-pester-and-psdeploy/

[CMDLETBINDING()]
PARAM(
    [string[]]$Task = 'default'
    
    [switch]$NoDepend = $True
)


if( -not $NoDepend ) {    
  if( !(Get-Module -name PSDepend -listAvailable) ) { 
      Install-Module PSDepend 
  }  
  $null = Invoke-PSDepend -path "$psScriptRoot\build.requirements.psd1" -install -import -force    
}


#TODO(проверить на чистом компьютере - устанавливает ли PSDepend отсутствующие модули?)
<#  похоже не нужно, PSDepend сам должен обо всем позаботиться.
 
if (!(Get-Module -Name Pester -ListAvailable))    
    { Install-Module -Name Pester -Scope CurrentUser }
if (!(Get-Module -Name psake -ListAvailable))     
    { Install-Module -Name psake -Scope CurrentUser }
if (!(Get-Module -Name PSDeploy -ListAvailable))  
    { Install-Module -Name PSDeploy -Scope CurrentUser }
    
#>    

Invoke-Psake -buildFile "$psScriptRoot\psakeBuild.ps1" -taskList $Task -Verbose:$VerbosePreference
exit ( [int]( -not $psake.build_success ) )
