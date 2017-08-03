$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
Convert-path "$here\..\_src\include\$sut"
. "$here\..\_src\include\$sut"

Describe "Remove-LeadingSpace" {
    It "Doesn't change string without white spaces" {
        '1234' | Remove-LeadingSpace | Should Be '1234'
    }
    It "Keeps trailing spaces intact" {
        '1   23 45 ' | Remove-LeadingSpace | Should Be '1   23 45 '
    }
    It "Keeps trailing spaces intact but removes spaces in the beginning" {
        '    1   2 34 ' | Remove-LeadingSpace | Should Be '1   2 34 '
    }
    It "Removes spaces in the beginning of each line of multiline strings" {
        ' 1
     23
        45' | Remove-LeadingSpace | Should Be '1
23
45'
    }
    It "Works with multiline input and keeps empty lines without spaces" {
        ' 1
     23
     
     45' | Remove-LeadingSpace | Should Be '1
23

45'
    }
    It "Works with multiline strings made of white spaces" {
        '


        ' | Remove-LeadingSpace | Should Be "`n`n`n"
    }
}