Function Write-Log { 
    [CMDLETBINDING()]
    PARAM( 
        [PARAMETER( Mandatory, Position=0 )]
        [String]
        $logFile,
        
        [PARAMETER( Mandatory, Position=1 )]
        [String]
        $Message
    )

    $Str  = Get-Date -uFormat "%Y.%m.%d %H:%M:%S - "
    $Str += $Message, (Split-Path $PSCommandPath -Leaf), $PSCommandPath
    $Str | Out-File -FilePath $logFile -Encoding UTF8 -Append -Force
}