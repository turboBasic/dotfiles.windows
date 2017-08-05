# recipe taken from https://devblackops.io/building-a-simple-release-pipeline-in-powershell-using-psake-pester-and-psdeploy/

[CMDLETBINDING()]
PARAM(
    [String[]]
    $Task = 'default',

    [switch]
    $NoDepend = $True
)


if( -not $NoDepend ) { 
  if( !(Get-Module -name psDepend -listAvailable) ) { 
      Install-Module psDepend 
  }
  $null = Invoke-psDepend -path (
              Join-Path $psScriptRoot requirements.psd1
          ) -install -import -force    
}  

Invoke-Psake -buildFile $psScriptRoot\psakeBuild.ps1 -taskList $Task -verbose:$VerbosePreference
exit ( [int]( -not $psake.build_success ) )

