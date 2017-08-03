# System Base
@{
  _SystemDrive='C:';                              # convert to lowercase
  _SystemRoot='%_SystemDrive%\\Windows';
  _ProgramData='%_SystemDrive%\\ProgramData';
  _ProgramFiles='%_SystemDrive%\\Program Files';
  _ProgramFiles(x86)='%_ProgramFiles% (x86)';
  _CommonProgramFiles='%_ProgramFiles%\\Common Files';
  _CommonProgramFiles(x86)='%_ProgramFiles(x86)%\\Common Files';
  _PUBLIC='%_ProfilesDirectory%\\Public';
  _ProgramW6432='%_ProgramFiles%';
#------------------------------------------
  _ComSpec='%_SystemBin%\cmd.exe';
}

# System additional 
@{
  _Profiles='\Users';
  _ProfilesDirectory='%_SystemDrive%\%_Profiles%';
  
#--------------------------------------
  _PSHome='%_SystemBin%\WindowsPowerShell\v1.0';
  _PSModulePath='%_ProgramFiles%\WindowsPowerShell\Modules;%_PSHome%\Modules';
  _Path='%_SystemBin%;%_SystemRoot%;%_SystemBin%\Wbem;%_PSHome%';
  _SystemBin='%_SystemRoot%\System32';
  _TEMP='%_SystemRoot%\TEMP';
}

<#
# User Base
@{
  UserName='...';
  HomeDrive='C:';
  HomePath='%Profiles%\%UserName%';
  UserProfile='%HomeDrive%\%HomePath%';
  UserApp='%USERPROFILE%\AppData';
  AppData='%USERAPP%\Roaming';
  LocalAppData='%USERAPP%\Local';
#-----------------------------------------
  LOGONSERVER='\\ASUS';
  USERDOMAIN='ASUS';
  USERDOMAIN_ROAMINGPROFILE='ASUS';
}

# User Additional
@{
  Projects='e:\0projects'
}



# Default Machine variables
@{
    ComSpec='%SystemRoot%\system32\cmd.exe';
    NUMBER_OF_PROCESSORS='4';
    OS='Windows_NT';
    PROCESSOR_ARCHITECTURE='AMD64';
    PROCESSOR_IDENTIFIER='Intel64 Family 6 Model 76 Stepping 3, GenuineIntel';
    PROCESSOR_LEVEL='6';
    PROCESSOR_REVISION='4c03';
    Path='%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0';
    PATHEXT='.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC';
    PSModulePath='%ProgramFiles%\WindowsPowerShell\Modules;%SystemRoot%\system32\WindowsPowerShell\v1.0\Modules';
    TEMP='%SystemRoot%\TEMP';
    TMP='%SystemRoot%\TEMP';
    USERNAME='SYSTEM';
    windir='%SystemRoot%';
}



# Default automatic Machine variables
@{
    ALLUSERSPROFILE='C:\ProgramData'
    CommonProgramFiles='C:\Program Files\Common Files'
    CommonProgramFiles(x86)='C:\Program Files (x86)\Common Files'
    COMPUTERNAME='ASUS'
    ProgramData='C:\ProgramData'
    ProgramFiles='C:\Program Files'
    ProgramFiles(x86)='C:\Program Files (x86)'
    ProgramW6432='C:\Program Files'
    PUBLIC='C:\Users\Public'
    SystemDrive='C:'
    SystemRoot='C:\WINDOWS'
}




# Default User variables
@{
    Path='%USERPROFILE%\AppData\Local\Microsoft\WindowsApps';
    TEMP='%USERPROFILE%\AppData\Local\Temp';
    TMP='%USERPROFILE%\AppData\Local\Temp';
}



# Default automatic User variables
@{
    APPDATA='%USERPROFILE%\AppData\Roaming';
    HOMEDRIVE='C:';
    HOMEPATH='\Users\mao';
    LOCALAPPDATA='%USERPROFILE%\AppData\Local';
    LOGONSERVER='\\ASUS';
    USERDOMAIN='ASUS';
    USERNAME='mao';
    USERPROFILE='C:\Users\mao';
}

#>

