# recipe taken from https://devblackops.io/building-a-simple-release-pipeline-in-powershell-using-psake-pester-and-psdeploy/

[CmdletBinding()]
PARAM(
    [String[]]$Task = 'default',
    
    [switch]$NoDepend = $True
)


if( -not $NoDepend ) { 
  if( !(Get-Module -Name PSDepend -ListAvailable) ) { 
      Install-Module PSDepend 
  }
  $null = Invoke-PSDepend -path (
              Join-Path $psScriptRoot build.requirements.psd1
          ) -install -import -force    
}


Invoke-Psake -buildFile (
    Join-Path $psScriptRoot psakeBuild.ps1
) -taskList $Task -verbose:$VerbosePreference 

exit ( [int]( -not $psake.build_success ) )
