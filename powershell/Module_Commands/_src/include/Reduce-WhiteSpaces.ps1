function Reduce-WhiteSpaces {
    ($Input + $Args) | ForEach-Object { $_.Trim() -replace '\n\s*', ' ' }
}

<#

        $Argumentlist =  @"
        
            -NoProfile
            -ExecutionPolicy Bypass
            -File "$psCommandpath"
            
"@.     Trim() -replace '\n\s*', ' '

#>

