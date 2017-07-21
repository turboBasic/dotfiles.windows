<#  .SYNOPSIS
      Merges any number of hashtables into one

    .DESCRIPTION
      Merges any number of hashtables taken both from pipeline and arguments, with the hashtables in the right overwriting the keys with the same names from hastables in the left

    .EXAMPLE
      $a = @{a = 'a1'; b = 'a2'}
      $b = @{b = 'b1'; c = 'b2'}
      $c = @{c = 'c1'; d = 'c2'}

      PS> Merge-Hashtables $a $b

      Name                  Value                                                                                                                                                              
      ----                  -----
      a                     a1
      b                     b1
      c                     b2

    .EXAMPLE
      PS> $a, $b | Merge-Hashtables $c

      Name                  Value                                                                                                                                                              
      ----                  -----
      a                     a1
      b                     b1
      c                     c1
      d                     c2  
#>

Function Merge-Hashtables {
    $Result = @{}
    ($Input + $Args) | 
        Where   { ($_.Keys -ne $null) -and ($_.Values -ne $null) -and ($_.GetEnumerator -ne $null) } | 
        ForEach { $_.GetEnumerator() } | 
        ForEach { $Result[$_.Key] = $_.Value } 
    $Result
    Write-Verbose (ConvertTo-Json $Result -compress)
}
