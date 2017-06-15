# System Base
@{
  SystemDrive='C:';    # convert to lowercase
  SystemRoot='%SystemDrive%\Windows';
  ProgramData='%SystemDrive%\ProgramData';
  ProgramFiles='%SystemDrive%\Program Files';
  ProgramFiles(x86)='%ProgramFiles% (x86)';
  CommonProgramFiles='%ProgramFiles%\Common Files';
  CommonProgramFiles(x86)='%ProgramFiles(x86)\Common Files';
  Profiles='\Users';
  ProfilesDirectory='%SystemDrive%\%Profiles%';
  PUBLIC='%UserFolder%\Public';
  ProgramW6432='%ProgramFiles%';
#------------------------------------------
  SystemBin='%SystemRoot%\System32';
  ComSpec='%SystemBin%\cmd.exe';
  PSHome='%SystemBin%\WindowsPowerShell\v1.0';
  Path='%SystemBin%;%SystemRoot%;%SystemBin%\Wbem;%PSHome%';
  PSModulePath='%ProgramFiles%\WindowsPowerShell\Modules;%PSHome%\Modules';
  TEMP='%SystemRoot%\TEMP';
}

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



