$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-HelloWorld" {
    It "outputs 'Hello world!'" {
        Get-HelloWorld | Should Be 'Hello world!'
    }
}
