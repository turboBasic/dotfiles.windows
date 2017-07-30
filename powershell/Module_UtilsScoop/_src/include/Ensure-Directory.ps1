Function Ensure-Directory {
  [CMDLETBINDING()]
  PARAM(
    [PARAMETER( Mandatory, 
                Position=0, 
                ValueFromPipeline, 
                ValueFromPipelineByPropertyName )]
    [ValidateNotNullOrEmpty()]
    [object[]]$path
  )

  BEGIN{}

  PROCESS {
    $path | ForEach-Object {
      if( !(Test-Path $_) ) { 
        $Null = New-Item -Path $_ -ItemType Directory 
      }
      Resolve-Path $_ 
    }
  }

  END{}
}

Function ensure($dir) {

    <#  if( !(Test-Path $dir) ) { 
        mkdir $dir > $null 
      }
      Resolve-Path $dir  #>

    Ensure-Directory -path $dir
}