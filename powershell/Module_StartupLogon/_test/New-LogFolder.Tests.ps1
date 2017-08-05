$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$DirName = "$ENV:systemROOT\System32\LogFiles\Startup, Shutdown, Logon scripts"
$Dir2 = Join-Path (Split-Path $DirName) -childPath 'TestDir'

Describe "New-LogFolder" {
    It "Creates path" {
        New-LogFolder -dir $Dir2 
        $Dir2 | Should Exist
    }
    It "Creates directory" {
        $Dir2 | Test-Path -pathType Container
    }
    It "Has correct access rights" {
        $CurrentIdentity = [Security.Principal.WindowsPrincipal](
           [Security.Principal.WindowsIdentity]::GetCurrent()
        )
        $a = Get-Item -path $Dir2 | Get-NTFSeffectiveAccess -account $currentIdentity.Identities.User.Value
        $a.AccessRights.ToString() | Should Match 'Modify'
    }
}