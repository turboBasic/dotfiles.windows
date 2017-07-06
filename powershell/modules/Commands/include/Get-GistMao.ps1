Function Get-GistMao($api) {
  #
  # 'https://api.github.com/users/USERNAME/gists'
  #

#TODO  if (-not (Test-Path FUNCTION:ConvertTo-Hashtable)) { Import-Module }

  if($api -eq $Null) {
    if (! (($__githubGist) -eq $Null)) {
      $api = $__githubGist
    }
  }

  $api=$__githubGist

  (curl $api | 
    select -expandProperty Content | 
    ConvertFrom-Json) | % { 
      $_currentRecord = $_
      $_.files | 
      ConvertTo-Hashtable | 
      Select -expandProperty Values | 
      %{ [psCustomObject]@{ 
            filename = $_.filename;
                 url = $_.raw_url
                  id = $_currentRecord.id; 
         description = $_currentRecord.description;
         }
      }
  } | Format-List filename, url, description

}