function Remove-GlobalVariables {
  PARAM(
    [string[]]
    $variables=$null,

    [string[]]
    $functions=$null
  )

  $variables | 
    Where-Object { $_ -ne $Null } |
    ForEach-Object {
      Remove-Variable -Scope Global -Name $_ -ErrorAction SilentlyContinue
    }

  $functions | 
    Where-Object { $_ -ne $Null } |
    ForEach-Object {
      Remove-Item -Path FUNCTION:$_ -ErrorAction SilentlyContinue
    }
}