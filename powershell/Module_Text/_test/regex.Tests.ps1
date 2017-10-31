$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace('.Tests.', '.')
. "$here\$sut"



  $rFunction = '(?<= ^|\s ) {0} (?= \s|$ )' -f 'FUNCTION'

  Describe "MatchFunctionKeyword" {
    $rx = '(?x) {0}' -f $rFunction

    It "matches function 1" {
        ' function Get-ChildItem    {  '  | Should Match $rx
    }
    It "matches function 2" {
        'Function Get-Child_697Item    {' | Should Match $rx
    }
    It "matches function 3" {
        '   FuncTioN _c6574567--___{  '   | Should Match $rx
    }
    It "matches function 4" {
        'function Get-ChildItem{'         | Should Match $rx
    }
    It "matches function 5" {
        'function Get-ChildItem'          | Should Match $rx
    }
  }


  $rName = '(?<= ^|\s ) ([-\w]+) (?= \W|$ )'
  $rFunctionName ='{0} \s+ {1}' -f $rFunction, $rName

  Describe "MatchFunctionKeywordAndName" {
    $rx = '(?x) {0}' -f $rFunctionName

    It "matches function 1" {
        ' function Get-ChildItem    {  '  | Should Match $rx
    }
    It "matches function 2" {
        'Function Get-Child_697Item    {' | Should Match $rx
    }
    It "matches function 3" {
        '   FuncTioN _c6574567--___{  '   | Should Match $rx
    }
    It "matches function 4" {
        'function Get-ChildItem{'         | Should Match $rx
    }
    It "matches function 5" {
        'function Get-ChildItem'          | Should Match $rx
    }
  }


  $rParentheses = '(   \(  [^()]*  \)   )?'
  $rFunctionNameAndParentheses ='{0} \s* {1}' -f $rFunctionName, $rParentheses

  Describe "MatchFunctionKeywordAndNameAndParentheses" {
    $rx = '(?x) {0}' -f $rFunctionNameAndParentheses

    It "matches function 1" {
        ' function Get-ChildItem    {  '  | Should Match $rx
    }
    It "matches function 2" {
        'Function Get-Child_697Item()    {' | Should Match $rx
    }
    It "matches function 3" {
        '   FuncTioN _c6574567--___ (){  '   | Should Match $rx
    }
    It "matches function 4" {
        'function Get-ChildItem ( "ruthgf", 67805 ){'         | Should Match $rx
    }
    It "matches function 5" {
        'function Get-ChildItem'          | Should Match $rx
    }
    It "matches function 6" {
        'function Get-ChildItem()'          | Should Match $rx
    }
 }



  $rBrace = '\{?'
  $rFunctionNameAndParenthesesAndBrace ='{0} \s* {1}' -f $rFunctionNameAndParentheses, $rBrace
  Write-Host -ForegroundColor Red $rFunctionNameAndParenthesesAndBrace

  Describe "MatchFunctionKeywordAndNameAndParenthesesAndBrace" {
    $rx = '(?x) {0}' -f $rFunctionNameAndParenthesesAndBrace

    It "matches function 1" {
        ' function Get-ChildItem    {  '  | Should Match $rx
    }
    It "matches function 2" {
        'Function Get-Child_697Item()    {' | Should Match $rx
    }
    It "matches function 3" {
        '   FuncTioN _c6574567--___ (){  '   | Should Match $rx
    }
    It "matches function 4" {
        'function Get-ChildItem ( "ruthgf", 67805 ){'         | Should Match $rx
    }
    It "matches function 5" {
        'function Get-ChildItem'          | Should Match $rx
    }
    It "matches function 6" {
        'function Get-ChildItem()'          | Should Match $rx
    }
    It "does not match function 7" {
        'function ()Get-ChildItem{'          | Should Not Match $rx
    }
 }