Function Expand-HashTableSelfReference {
  [CMDLETBINDING()] 
  PARAM( 
      [PARAMETER( ValueFromPipeline )] 
      [HashTable]
      $hTable 
  )

  $res = @{}
  $hTable.Keys | % { Set-Variable -Scope Local -Name $_ -Value $hTable[$_] }
  $hTable.Keys | % { 
      $tmp = $hTable[$_]

      # This is less reliable as needs synchronisation waiting:
      #   $value = $ExecutionContext.InvokeCommand.ExpandString($hTable[$_])
      $value = "@`"`n$tmp`n`"@" | iex
      $res.Add( $_, $value ) 
  }
  $res
}