Function Add-SmartMargin {

  [CmdletBinding( DefaultParameterSetName='Margin' )] 
  PARAM(  
      [PARAMETER( ParameterSetName='Value', 
                  Position=0, 
                  ValueFromPipeline, 
                  ValueFromPipelineByPropertyName )]
      [PARAMETER( ParameterSetName='ValueAndMargin', 
                  Position=0, 
                  ValueFromPipeline, 
                  ValueFromPipelineByPropertyName )]          
      [string[]] 
      $Value,

      [PARAMETER( ParameterSetName='Margin', Position=0 )]  
      [PARAMETER( ParameterSetName='ValueAndMargin', Position=1 )]      
      [byte] 
      $Margin = 0
  )
  
  
  
  BEGIN {}   

  PROCESS {
  
    $Value | 
        ForEach-Object {
        
          # Set $firstLine to 0 if you want the first line to have zero margin
          $firstLine = 1
          
          ( 
            $_ -split "`n" | 
            ForEach-Object { ' ' * $Margin * [bool]$firstLine++  +  $_ } 
          ) -join "`n"
          
        }
    
  }

  END {} 
  
}