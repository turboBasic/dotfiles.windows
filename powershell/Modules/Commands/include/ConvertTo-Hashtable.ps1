Function ConvertTo-Hashtable { 
  <#
      .SYNOPSIS
          Converts PsCustomObject type to Hashtable. Takes pipeline input and common arguments

      .DESCRIPTION
          Converts PsCustomObject type to Hashtable. Takes pipeline input, common arguments, 
          array arguments for bulk processing 

  #>

  [CMDLETBINDING()] 
  PARAM( 
      [PARAMETER( Position=0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [ALIAS( 'CustomObject', 'psCustomObject', 'psObject' )]         
      [psCustomObject[]] 
      $Object 
  ) 
  
  BEGIN { }
     
  PROCESS {
    foreach ($_object in $Object) {
        $output = @{ } 
        $_object | Get-Member -MemberType *Property | % { 
            $output.($_.name) = $_object.($_.name) 
        }
        $output 
    }
  }
  
  END { } 
}