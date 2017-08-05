Function Get-StringHash {
    <# 
       .SYNOPSIS
produces hash string for argument

       .DESCRIPTION
Calculates hash-functions using .Net class [System.Security.Cryptography.HashAlgorithm]
Parameter HashName takes any of the following values: 
      SHA, SHA1, SHA256, SHA384, SHA512, MD5 (default is MD5)

       .PARAMETER String
String to calculate hash for

       .PARAMETER HashName
SHA, SHA1, SHA256, SHA384, SHA512, MD5 (default is MD5) 

       .EXAMPLE
PS> Get-StringHash 'abcdef' 'SHA256'
bef57ec7f53a6d40beb640a780a639c83bc29ac8a9816f1fc6c5c6dcd93c4721
    #>
 

      [CmdletBinding()] 
      PARAM( 
          [PARAMETER( Position=0, Mandatory, ValueFromPipeline )]
          [AllowEmptyString()]
          [string[]] 
          $String,
          
          [PARAMETER( Position=1 )]
          [ValidatePattern( '^MD5|(SHA(1|256|384|512)?)$' )]  
          [string] 
          $HashName = 'MD5'
      )

  
  BEGIN {
    Write-Verbose $psCmdlet.ParameterSetName
    $String   | ConvertTo-Json -compress | Write-Verbose 
    $HashName | ConvertTo-Json -compress | Write-Verbose 
    $StringBuilder = New-Object System.Text.StringBuilder
  }

  PROCESS {
  
    $String | ConvertTo-Json -compress | Write-Verbose 
    $_      | ConvertTo-Json -compress | Write-Verbose
    
    forEach( $s in $String ) {
      [Security.Cryptography.HashAlgorithm]::Create( 
          $HashName 
      ).ComputeHash( 
          [Text.Encoding]::UTF8.GetBytes($s) 
      ) | 
      ForEach-Object{   
        [Void]$StringBuilder.Append( $_.ToString('x2') )  
      }
          
      Write-Output $StringBuilder.ToString()
      
      [Void]$StringBuilder.Clear()
    } 
  }

  END{}
}