  function New-FullPath7z { 
  
    PARAM(
        [Parameter( Mandatory, 
                    Position=0, 
                    ValueFromPipeline )]
        [ValidateScript({ Test-Path $_ })]
        [string]
        $Path,

        [Parameter( Position=1 )]
        [ValidateScript({ Test-ValidFileName $_ })]  
        [string]
        $Name = "$( Split-Path $Path -parent )\$( Split-Path $Path -leaf )-FullPaths.7z"
    )
    
    
    
    7z a -spf2 -myx -mx $Name $Path\* 
    
  }