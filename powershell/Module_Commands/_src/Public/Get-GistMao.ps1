Function Get-GistMao {

  PARAM(
      [PARAMETER( Position=0 )]
      [AllowNull()] [allowEmptyString()]
      [String]
      $api 
  )

  if(!$api) {
    $api = 
        $ENV:githubGist, 
        "https://api.github.com/users/${ENV:USERNAME}/gists" | 
        Select -First 1
  }

  Invoke-WebRequest $api | 
    Select-Object -ExpandProperty Content | 
    ConvertFrom-Json | 
    ForEach-Object { 
      $_currentRecord = $_
      $_.files | 
      ConvertTo-Hashtable | 
      Select-Object -ExpandProperty Values | 
      ForEach-Object { 
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
