function Set-LogEntry {

  [CMDLETBINDING()]
  [OUTPUTTYPE( [String[]] )]
  PARAM( 
      [PARAMETER( Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [ALIAS('Text', 'Data', 'Value')]
      [String[]]
      $Message = @('')
  )

  BEGIN{}

  PROCESS{
      foreach($m in $Message) {
        '{0} {1}' -f (Get-TimeStamp), $m
      }
  }

  END{}
}
