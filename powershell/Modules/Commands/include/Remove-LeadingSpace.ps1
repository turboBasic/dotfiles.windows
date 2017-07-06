function Remove-LeadingSpace {

    ($Input + $Args) |     
        ForEach { $_ -replace '(?m)^\s+(\S.*)$','$1' } 
}