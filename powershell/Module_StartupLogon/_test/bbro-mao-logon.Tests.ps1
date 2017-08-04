$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\_src\$sut"

Describe "Reduce-WhiteSpaces" {
    It "User Environment Variables" {
        $__user_variables.Gettype().Name | Should BeOfType 'Hashtable'
    }
}