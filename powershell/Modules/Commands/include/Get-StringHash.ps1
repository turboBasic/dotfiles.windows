Function Get-StringHash {
    <# .SYNOPSIS
         produces hash string for argument

       .DESCRIPTION
         Calculates hash-functions using .Net class [System.Security.Cryptography.HashAlgorithm]
         Parameter HashName takes any of the following values: 
           SHA, SHA1, SHA256, SHA384, SHA512, MD5 (default is MD5)

       .PARAMETER String
         String to calculate hash for

       .PARAMETER HashName
         SHA, SHA1, SHA256, SHA384, SHA512, MD5 (default is MD5) 
    #>
 
    #region Parameters
        [CMDLETBINDING()] 
        PARAM( 
            [PARAMETER( Position=0, Mandatory, ValueFromPipeline )]
            [ALLOWEMPTYSTRING()]
            [String[]] 
            $String,
          
            [PARAMETER( POSITION=1 )]
            [VALIDATEPATTERN( '^MD5|(SHA(1|256|384|512)?)$' )]  
            [String] 
            $HashName = 'MD5'
        )
    #endregion
  
  BEGIN {
    Write-Verbose $PSCmdlet.ParameterSetName
    $String   | ConvertTo-Json -Compress | Write-Verbose 
    $HashName | ConvertTo-Json -Compress | Write-Verbose 
    $StringBuilder = New-Object System.Text.StringBuilder
  }

  PROCESS {
    $String | ConvertTo-Json -Compress | Write-Verbose 
    $_      | ConvertTo-Json -Compress | Write-Verbose
    forEach($s in $String) {
      [System.Security.Cryptography.HashAlgorithm]::
        Create( $HashName ).ComputeHash( [System.Text.Encoding]::UTF8.GetBytes($s) ) | 
        % {   [Void]$StringBuilder.Append($_.ToString('x2'))  } 
      Write-Output $StringBuilder.ToString()
    [Void]$StringBuilder.Clear()
    } 
  }

  END { }
}