function Reduce-WhiteSpaces {
    ($Input + $Args) | ForEach-Object { $_.Trim() -replace '\s{2,}', ' ' }
}

<#

        $Argumentlist =  @"
        
            -NoProfile
            -ExecutionPolicy Bypass
            -File "$psCommandpath"
            
"@.     Trim() -replace '\n\s*', ' '

#>

