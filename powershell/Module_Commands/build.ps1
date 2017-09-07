# recipe taken from https://devblackops.io/building-a-simple-release-pipeline-in-powershell-using-psake-pester-and-psdeploy/

[CmdletBinding()]
PARAM(
    [string[]]
    $task = 'default',
    
    [switch]
    $noDepend = $True
)


# $PSDefaultParameterValues = @{ "*:noDepend" = $True }

if( -not $noDepend ) {    
  if( !(Get-Module -name PSDepend -listAvailable) ) { 
      Install-Module PSDepend 
  }  
  $null = Invoke-PSDepend -path $PSScriptRoot\build.requirements.psd1 -install -import -force    
}


Invoke-Psake -buildFile $PSScriptRoot\psakeBuild.ps1 -taskList $task -verbose:$verbosePreference
exit ( [int]( -not $psake.build_success ) )
