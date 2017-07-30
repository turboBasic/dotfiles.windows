# recipe taken from https://devblackops.io/building-a-simple-release-pipeline-in-powershell-using-psake-pester-and-psdeploy/

[cmdletBinding()]
PARAM(
    [string[]]$Task = 'default',

    [switch]$NoDepend = $True
)


#$PSDefaultParameterValues = @{ "*:NoDepend" = $True }

if( -not $NoDepend ) { 
  if( !(Get-Module -name PSDepend -listAvailable) ) { 
    Install-Module -name PSDepend 
  }      
  $null = Invoke-PSDepend -path "$psScriptRoot\build.requirements.psd1" -install -import -force    
}


Invoke-Psake -buildFile "$psScriptRoot\psakeBuild.ps1" -taskList $Task -verbose:$VerbosePreference
exit ( [int]( -not $psake.build_success ) )
