# Machine startup script %systemRoot%\System32\GroupPolicy\Machine\Scripts\Startup\bbro-startup.ps1 

. 'd:/0projects/dotfiles.windows/powershell/Modules/Environment/include/Set-MachineEnvironment.ps1'

<#
Function Set-MachineEnvironment {

  #region Parameters
    [CMDLETBINDING(
      SupportsShouldProcess=$True,
      ConfirmImpact='Medium'
    )]
    PARAM(
        [PARAMETER( Mandatory=$False,
                    ValueFromPipeline=$False, 
                    HelpMessage='Reset Machine environment' )]
            [switch]
            $Initialise
    )
  #endregion

  Write-Verbose "`n Set-MachineEnvironment `n"
  $__sys_variables.Keys | 
      ForEach-Object { 
          Set-Environment -Name $_ -Value $__sys_variables[$_] -Scope Machine -Expand:($__sys_variables[$_] -match '%..*%') 
      }

  Send-EnvironmentChanges 
} 

#>

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

  $__sys_variables = @{

    #region this is just for help doing reverse search
      '~~%systemROOT%\system32'= 'systemBin'
      '~~C:'=                    'systemROOT'
    #endregion

    '..systemBin'=           '%systemROOT%\system32'  
    systemBin=               '%systemROOT%\system32'
    WINDIR=                  '%systemROOT%'

    '..psHome'=              '%systemROOT%\system32\windowsPowerShell\v1.0'
    psHome=                  '%systemROOT%\system32\windowsPowerShell\v1.0'

    psModulePath=            '%PROGRAMFILES%\windowsPowerShell\modules',
                             '%..psHome%\modules' -join ';'

    PATH=                    '%..systemBin%',
                             '%systemROOT%',
                             '%..systemBin%\wbem',       
                             '%..psHome%',               
                             '%chocoPath%',
                             '%..scoopGlobal%\shims',
                             '%cmderPath%', 
                             '%gitPath%' -join ';'

    junkPath=                '%PROGRAMFILES(X86)%\skype\phone',
                             '%PROGRAMFILES(X86)%\brackets\command',
                             '%PROGRAMFILES%\microsoft SQL Server\130\tools\binn',
                             '%PROGRAMDATA%\oracle\java\javapath' -join ';'

    choco=                   'C:\programData\chocolatey'
    chocolateyInstall=       'C:\programData\chocolatey'
    chocoPath=               'C:\programData\chocolatey\bin'

    '..tools'=               '%systemDRIVE%\tools'
    tools=                   '%systemDRIVE%\tools'

    cmder_Root=              '%..tools%\cmderMini';
    cmder=                   '%..tools%\cmderMini';
    cmderPath=               '%..tools%\cmderMini',
                             '%..tools%\cmderMini\bin',
                             '%..tools%\cmderMini\vendor\conemu-maximus5',
                             '%..tools%\cmderMini\vendor\conemu-maximus5\conemu' -join ';'
    chocolateyToolsLocation= '%..tools%'

    git=                     '%PROGRAMFILES%\git'
    git_Install_Root =       '%PROGRAMFILES%\git'

    gitPath=                 '%PROGRAMFILES%\git\cmd',
                             '%PROGRAMFILES%\git',
                             '%PROGRAMFILES%\git\mingw64\bin',
                             '%PROGRAMFILES%\git\usr\bin' -join ';'

    kdiff3=                  '%PROGRAMFILES%\kdiff3'
    '..userName' =           $Global:__userName
    '..homeDrive' =          $Global:__homeDrive
    '..userRoot' =           "\users" 
    '..homePath'=            '%..userRoot%\%..userName%'
    '..scoop'=               '%..homeDrive%%..userRoot%\%..userName%\scoop'
    scoop=                   '%..homeDrive%%..homePath%\scoop'

    '..scoopGlobal'=         'C:\programData\scoop'
    scoop_Global=            '%PROGRAMDATA%\scoop'
    'notepad++'=             '%PROGRAMDATA%\scoop\apps\notepadplusplus\current\notepad++.exe'

    TEMP=                    '%systemROOT%\temp'
    TMP=                     '%systemROOT%\temp'
  }

      <#region Extra bits for future use
        conEmuDir=                '%cmder%\vendor\conemu-maximus5'
        java_Home=                '%PROGRAMFILES%\java\jdk1.8.0_121' 
        laragon=                  'C:\laragon'
        php_Ini_Scan_Dir=         '%laragon%\bin\php\current\ext'
        phpstorm_Jdk=             '%java_Home%'
        PATH=                     '%PROGRAMFILES%\docker\docker\resources\bin'
        PATH=                     '%PROGRAMFILES(X86)%\nVidia Сorporation\physX\common'
      #endregion#>
      <#region System Base variables         
        ALLUSERSPROFILE=          'C:\programData'
        COMMONPROGRAMFILES=       '%PROGRAMFILES%\common files'
        COMMONPROGRAMFILES(X86)=  '%PROGRAMFILES(X86)%\common files'
        COMPUTERNAME=             'ASUS'
        COMSPEC=                  '%systemROOT%\system32\cmd.exe'
        PROGRAMDATA=              '%systemDRIVE%\programData'
        PROGRAMFILES=             '%systemDRIVE%\program files'
        PROGRAMFILES(X86)=        '%PROGRAMFILES% (x86)'
        PROGRAMW6432=             '%PROGRAMFILES%'
        PUBLIC=                   '%userFolder%\public'
        systemDRIVE=              'C:'
        systemROOT=               '%systemDRIVE%\windows'
      #endregion#>
      <#region Default Machine variables
        COMSPEC=                  '%systemROOT%\system32\cmd.exe'
        NUMBER_OF_PROCESSORS=     '4'
        OS=                       'Windows_NT'
        PROCESSOR_ARCHITECTURE=   'AMD64'
        PROCESSOR_IDENTIFIER=     'Intel64 Family 6 Model 76 Stepping 3, GenuineIntel'
        PROCESSOR_LEVEL=          '6'
        PROCESSOR_REVISION=       '4c03'
        PATH=                     '%systemROOT%\system32',
                                  '%systemROOT%',
                                  '%systemROOT%\system32\wbem',
                                  '%systemROOT%\system32\windowsPowerShell\v1.0' - join ';'                                  
        PATH=%PATH% +             'C:\program files (x86)\brackets\command',
                                  'C:\program files\microsoft SQL Server\130\tools\binn',
                                  'C:\program files (x86)\skype\phone',
                                  'C:\programData\oracle\java\javapath' - join ';'                                 
        PATHEXT=                  '.com;.exe;.bat;.cmd;.vbs;.vbe;.js;.jse;.wsf;.wsh;.msc'                                 
        psModulePath=             '%PROGRAMFILES%\windowsPowerShell\modules',
                                  '%systemROOT%\system32\windowsPowerShell\v1.0\modules' - join ';'                                  
        TEMP=                     '%systemROOT%\temp'
        TMP=                      '%systemROOT%\temp'
        USERNAME=                 'SYSTEM'
        WINDIR=                   '%systemROOT%'
      #endregion#>


Write-Verbose "Executing Machine Startup script $psCommandPath"

Get-ChildItem ENV: | Out-String | Out-File 'd:/0projects/dotfiles.windows/powershell/Modules/Environment/include/Set-MachineEnvironment-Initial-env.txt'  -Encoding UTF8
