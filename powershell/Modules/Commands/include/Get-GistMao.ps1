Function Get-GistMao {
  PARAM(
    [PARAMETER( Position=0 )]
    [String]
    $api = ${ENV:githubGist}        # 'https://api.github.com/users/USERNAME/gists'
  )

  Invoke-WebRequest $api | 
    Select -ExpandProperty Content | 
    ConvertFrom-Json | 
    ForEach { 
      $_currentRecord = $_
      $_.files | 
      ConvertTo-Hashtable | 
      Select -ExpandProperty Values | 
      ForEach { 
          [psCustomObject]@{ 
              filename =    $_.filename
              url =         $_.raw_url
              id =          $_currentRecord.id 
              description = $_currentRecord.description
          }
      }
    } | 
    Format-List filename, url, description

}