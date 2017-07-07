$__protected_variables = @{
    ALLUSERSPROFILE         = 'C:\programData'
    CommonProgramFiles      = 'C:\program Files\common Files'
   'CommonProgramFiles(x86)'= 'C:\program Files (x86)\common Files'
    COMPUTERNAME            = 'BBRO'
    NUMBER_OF_PROCESSORS    = '8'
    OS                      = 'Windows_NT'
    PATHEXT                 = '.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC'
    PROCESSOR_ARCHITECTURE  = 'AMD64'
    PROCESSOR_IDENTIFIER    = 'Intel64 Family 6 Model 42 Stepping 7, GenuineIntel'
    PROCESSOR_LEVEL         = '6'
    PROCESSOR_REVISION      = '2a07'
    ProgramData             = 'C:\programData'
    ProgramFiles            = 'C:\program Files'
   'ProgramFiles(x86)'      = 'C:\program Files (x86)'
    ProgramW6432            = 'C:\program Files'
    PUBLIC                  = 'C:\users\public'
    systemDRIVE             = 'C:'
    systemROOT              = 'C:\windows'
                              
    APPDATA                 = 'C:\users\mao\appData\roaming'
    HOMEDRIVE               = 'C:'
    HOMEPATH                = '\users\mao'
    LOCALAPPDATA            = 'C:\users\mao\appData\local'
    LOGONSERVER             = '\\BBRO'
    USERDOMAIN              = 'BBRO'
    USERNAME                = 'mao'
    USERPROFILE             = 'C:\users\mao'
}

Function Remove-UnprotectedVariables {
  Get-ChildItem ENV: | 
      Where Name -NotIn $__protected_variables.Keys |
      ForEach { 
          Remove-Item ENV:\$_.Name
          Write-Verbose "Deleting environment variable $($_.Name)"
      }
}
