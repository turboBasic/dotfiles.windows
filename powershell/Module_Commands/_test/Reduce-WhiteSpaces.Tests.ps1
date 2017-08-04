$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\_src\include\$sut"

Describe "Reduce-WhiteSpaces" {
    It "Doesn't change string without white spaces" {
        Reduce-WhiteSpaces 'abch^()%&#{}920' | Should Be 'abch^()%&#{}920'
    }
    It "Keeps unchanged string with single white spaces" {
        Reduce-WhiteSpaces 'abcde fg hij dkjf' | Should Be 'abcde fg hij dkjf'
    }
    It "Trims whitespaces" {
        Reduce-WhiteSpaces "
      `t  `n abcde fg hij dkjf
      
      `n `t`t" | Should Be 'abcde fg hij dkjf'
    }
    It "Replaces inner white spaces with single space" {
        Reduce-WhiteSpaces "abcde`t`tfg  hij 
      
      dkjf" | Should Be 'abcde fg hij dkjf'
    }
    It "Replaces inner and outer white spaces with single white spaces" {
        Reduce-WhiteSpaces "`n`n`n
      
      
      `n`nabcde 
                            fg 
                            hij 
                            dkjf`n`n`n`n" | Should Be 'abcde fg hij dkjf'
    }
}
