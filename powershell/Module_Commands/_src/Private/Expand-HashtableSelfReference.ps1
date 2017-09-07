# GOING TO DEPRECATE
# TODO(Deprecate)

Function Expand-HashTableSelfReference {
  [CMDLETBINDING()] 
  PARAM( 
      [PARAMETER( ValueFromPipeline )] 
      [HashTable]
      $hTable 
  )

  $res = @{}
  $hTable.Keys | 
      ForEach-Object { 
        Set-Variable -Scope Local -Name $_ -Value $hTable[$_] 
      }
    
  $hTable.Keys | 
      ForEach-Object { 
        $tmp = $hTable[$_]

        # This is less reliable as needs synchronisation waiting:
        #   $value = $ExecutionContext.InvokeCommand.ExpandString($hTable[$_])
        $value = "@`"`n$tmp`n`"@" | Invoke-Expression
        $res.Add( $_, $value ) 
      }
  $res
}