<#
    .SYNOPSIS

Flattens nested arrays and collections


    .DESCRIPTION

Flattens nested arrays and collections. Takes array both as argument and from pipeline


    .EXAMPLE

1, 2, @(3, @(4, 5, @(6)), 7), 8 | Get-FlatArray


#>
function Get-FlatArray {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Alias('InputObject', 'Array')]
    [Object[]] $arrays
  )

  BEGIN{}

  PROCESS{
    foreach($array in $arrays) {
      if($array.count -eq 1) {
        $array
      } else {
        Get-FlatArray -array $array
      }
    }
  }

  END{}
}