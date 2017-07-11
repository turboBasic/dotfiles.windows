Function Set-LogEntry {
  [CMDLETBINDING()]
  PARAM( 
      [PARAMETER( Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [ALLOWEMPTYSTRING()]
      [ALLOWNULL()]
      [String[]]
      $Message = @('')
  )

  BEGIN{}

  PROCESS{
      foreach($m in $Message) {
         $delimiter = '' 
         if($m) { $delimiter = '=' } 
         '{0}.{1:D3}{2}{3}' -f (Get-Date -uFormat '%Y.%m.%d %H:%M:%S'), (Get-Date).Millisecond, $delimiter, $m
      }
  }

  END{}
}