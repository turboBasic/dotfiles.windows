Function Add-SmartMargin {
  [CMDLETBINDING( DefaultParameterSetName='Margin' )] 
  PARAM(  
      [PARAMETER( ParameterSetName='Value', Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [PARAMETER( ParameterSetName='ValueAndMargin', Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName )]          
      [String[]] 
      $Value,

      [PARAMETER( ParameterSetName='Margin', Position=0 )]  
      [PARAMETER( ParameterSetName='ValueAndMargin', Position=1 )]      
      [Byte] 
      $Margin = 0
  )
  
  BEGIN {}   

  PROCESS {
    $Value | % { 
        # Set $firstLine to 0 if you want the first line to have zero margin
        $firstLine=1 
        ( $_ -split "`n" | % { ' ' * $Margin * [bool]$firstLine++  +  $_ } ) -join "`n" 
    }
  }

  END {}  
}