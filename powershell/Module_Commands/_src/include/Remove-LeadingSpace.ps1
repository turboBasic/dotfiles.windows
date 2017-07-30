function Remove-LeadingSpace {

    ($Input + $Args) |     
        ForEach { $_ -replace '(?mx) ^ [^\S\n\r]*' } 
}
# -replace '^[^\S\n\r]*'
# -replace '(?m)^\s+(\S.*)$', '$1'