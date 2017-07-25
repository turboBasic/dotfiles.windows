Function Write-Log { 
  [CMDLETBINDING()]
  PARAM( 
      [PARAMETER( Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [ALLOWEMPTYSTRING()]
      [ALLOWNULL()]
      [String[]]
      $Message,

      [PARAMETER( Mandatory, Position=1, ValueFromPipelineByPropertyName )]
      [ALIAS('FilePath')]
      [String]
      $logFile
  )

  BEGIN{}

  PROCESS{
      foreach($m in $Message) {
          $m | Out-File -FilePath $logFile -Encoding UTF8 -Append -Force
      }
  }

  END{}
}

