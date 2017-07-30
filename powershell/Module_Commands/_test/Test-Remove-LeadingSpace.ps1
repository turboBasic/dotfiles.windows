Write-Host -ForegroundColor Magenta ( 
    $header = ('-' * 25), '$input={0}', ('-' * 10), '<begin>{1}<end>' -join "`n" 
)

'1234',
'1   23 45 ',
'    1   2 34 ', 
' 1  
     23
        45', 
' 1
     23
     
     45',
'


'     |  
            Foreach-Object { 
              $header -f $_, ( $_ | Remove-LeadingSpace )
            }
