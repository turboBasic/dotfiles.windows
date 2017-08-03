$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\_src\include\$sut"

Describe "Reduce-WhiteSpaces" {
    It "Doesn't change string without white spaces" {
        Reduce-WhiteSpaces 'abch^(%&#(k920' | Should Be 'abch^(%&#(k920'
    }
    It "Keeps unchanged string with single white spaces" {
        Reduce-WhiteSpaces 'abcde fg hij dkjf' | Should Be 'abcde fg hij dkjf'
    }
}
