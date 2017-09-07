Function Copy-Tree {
#
#  @TODO(Write Doc Help)
#

    [CMDLETBINDING()] 
    PARAM(
        [PARAMETER( Mandatory )]
        [ALIAS('Source')]
        [String[]] 
        $from,

        [PARAMETER( Mandatory )]
        [ALIAS('Destination')]
        [String]
        $to,

        [PARAMETER()]
        [String[]]
        $excludeFiles=$null,

        [PARAMETER()]
        [String[]]
        $excludeFolderMatch=$null
    )

    $source = Resolve-Path $from
    if( $source.count -ne 1 ) { 
        Write-Error 'From path should be 1 and only directory' 
        Break
    } else {
        $source = [System.IO.Path]::GetFullPath($source).TrimEnd('\')
    }

    [regex]$excludeFolderMatchRegEx = '(?i)' + ($ExcludeFolderMatch -join '|') 
 
    Get-ChildItem -LiteralPath $source -Recurse -Exclude $excludeFiles -Force | 
        Where-Object { 
            !$excludeFolderMatch -or 
            $_.FullName.Replace($source,'') -notMatch $excludeFolderMatchRegEx 
        } |
        ForEach-Object { 
            $_ | 
            Copy-Item -Destination $(
                if( $_.psIsContainer ) { 
                    Join-Path $to $_.Parent.FullName.Substring($source.Length)
                } else {
                    Join-Path $to $_.FullName.Substring($source.length)
                } 
            ) -Force -Exclude $excludeFiles
        }

}
