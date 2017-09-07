function Write-Log { 

  [CMDLETBINDING()]
  PARAM( 
      [PARAMETER( Mandatory, Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [AllowEmptyString()] [AllowNULL()]
      [string[]]
      $Message,

      [PARAMETER( Mandatory, Position=1, ValueFromPipelineByPropertyName )]
      [ALIAS('FilePath')]
      [String]
      $logFile
  )


  BEGIN{}

  PROCESS{
      foreach($m in $Message) {
          $m | Out-File -filePath $logFile -encoding UTF8 -append -Force
      }
  }

  END{}
}

