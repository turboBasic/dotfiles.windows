if( -not( 
      [Security.Principal.WindowsPrincipal] (
          [Security.Principal.WindowsIdentity]::GetCurrent()
      )
    ).IsInRole( [Security.Principal.WindowsBuiltInRole] 'Administrator' )  
) { 
      Start-Process Powershell.exe -Verb RunAs (
            '-NoProfile -ExecutionPolicy Bypass -File "{0}" ' -f $psCommandPath
      )
      Exit 
  }

# Your script below this line

$params = @{
  Path =          "${ENV:systemBIN}/LogFiles/Startup, Shutdown, Logon scripts"
  Account =       'BUILTIN\Users'
  AppliesTo =     'ThisFolderSubfoldersAndFiles'
  AccessRights =  'Write, CreateFiles, AppendData, WriteExtendedAttributes'
}
Add-NTFSAccess @params
