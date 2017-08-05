$params = @{
  LogName =   'Application'
  Source =    "Module_StartupLogon_User_${ENV:UserName}"
  EventID =   101
  EntryType = 'Information' 
  Category =  8 
#  Keywords =  'Environment', 'Logon'
  Message =   Get-Environment * -scope User | 
                Select-Object Name, Value, @{  
                    Name='Expanded'
                    Expression={
                      $params.Name = $_.Name
                      (Get-ExpandedName @params).Value 
                    } 
                } |
                ConvertTo-Xml -As Document -Depth 3
}

Write-EventLog @params

$params = @{
  LogName =   'Application'
  Source =    'Module_StartupLogon_Machine'
  EventID =   201
  EntryType = 'Information' 
  Category =  8 
#  Keywords =  'Environment', 'Startup'
  Message =   "Test write to Application log by 'Module_StartupLogon_Machine'" 
}  

Write-EventLog @params