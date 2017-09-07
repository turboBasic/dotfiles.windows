function Export-Drives {
  [CmdletBinding()]
  [OutputType( [PSCustomObject] )]
  PARAM()


  @{
      alias =    'Name', 'Visibility', 'ResolvedCommand', 'Options'
      env =      'Name', 'Value'
      function = 'Name', 'Visibility', 'ModuleName'
      variable = 'Name', 'Visibility', 'Value', 'Options'
  } | 
    ForEach-Object {
      $parent = $_
      [array]$_.Keys |
        ForEach-Object {
          $parent.$_ = Get-ChildItem -path ${_}: | Select-Object -property $parent.$_
        }
      [PSCustomObject]$_
    }

}
