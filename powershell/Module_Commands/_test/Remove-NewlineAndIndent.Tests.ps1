$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\_src\include\$sut"

Describe "Remove-NewlineAndIndent" {
    Context 'Invocation without pipeline' {
        It "Doesn't change string without white spaces" {
            Remove-NewlineAndIndent '1234' | Should Be '1234'
        }
        It "Doesn't change string without new lines" {
            Remove-NewlineAndIndent '  12    3 4   ' | Should Be '  12    3 4   '
        }
        It "Keeps leading and trailing spaces intact" {
            Remove-NewlineAndIndent '  1   23 45 ' | Should Be '  1   23 45 '
        }
        It "Removes newlines" {
            Remove-NewlineAndIndent "`n`r`r1`n2`r34" | Should Be '1234'
        }
        It "Removes leading spaces in each line of multiline strings, except of line #1" {
                Remove-NewlineAndIndent " 1`n         23   `n1       `n            45" | 
                Should Be ' 123145'
        }
        It "Deletes empty lines in multiline strings" {
            Remove-NewlineAndIndent "1`n23`n`n`n45" | Should Be '12345'
        }
        It "Deletes multiline strings made of white spaces" {
            Remove-NewlineAndIndent '


            ' | Should Be ""
        }
    }
    
    Context 'Invocation in pipeline' {
        It "Doesn't change string without white spaces" {
            '1234' | Remove-NewlineAndIndent | Should Be '1234'
        }
        It "Doesn't change string without new lines" {
            '  12    3 4   ' | Remove-NewlineAndIndent | Should Be '  12    3 4   '
        }
        It "Keeps leading and trailing spaces intact" {
            '  1   23 45 ' | Remove-NewlineAndIndent | Should Be '  1   23 45 '
        }
        It "Removes newlines" {
            "`n`r`r1`n2`r34" | Remove-NewlineAndIndent | Should Be '1234'
        }
        It "Removes leading spaces in each line of multiline strings, except of line #1" {
            " 1`n         23   `n1       `n            45" | 
                Remove-NewlineAndIndent | 
                Should Be ' 123145'
        }
        It "Deletes empty lines in multiline strings" {
            "1`n23`n`n`n45" | Remove-NewlineAndIndent | Should Be '12345'
        }
        It "Deletes multiline strings made of white spaces" {
            '


            ' | Remove-NewlineAndIndent | Should Be ""
        }
    }
}