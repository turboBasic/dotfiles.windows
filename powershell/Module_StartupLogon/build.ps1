# recipe taken from https://devblackops.io/building-a-simple-release-pipeline-in-powershell-using-psake-pester-and-psdeploy/

[CMDLETBINDING()]
PARAM(
    [string[]]
    $Task = 'default',

    [switch]
    $NoDepend = $True
)


if( -not $NoDepend ) { 
  if( -not (Get-Module -name PSDepend -listAvailable) ) { 
      Install-Module PSDepend 
  }
  $null = Invoke-PSDepend -path (
              Join-Path $PSScriptRoot requirements.psd1
          ) -install -import -force    
}  

Invoke-Psake -buildFile $PSScriptRoot\build.Psake.ps1 -taskList $Task -verbose:$VerbosePreference
exit [int]( -not $psake.build_success )
