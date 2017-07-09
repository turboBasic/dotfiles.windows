# Machine startup script %systemRoot%\System32\GroupPolicy\Machine\Scripts\Startup\bbro-startup.ps1 

  #region write info to log file

    Function Write-Log {  PARAM($logFile,$Description)
        $Str  = Get-Date -uFormat "%Y.%m.%d %H:%M:%S - "
        $Str += '{0,-22} {1,-18} {2,-75}' -f $Description, (Split-Path $PSCommandPath -Leaf), $PSCommandPath
        $Str | Out-File -FilePath $logFile -Encoding UTF8 -Append -Force
    }


    Write-Log @{ 
        logFile =     "${ENV:systemROOT}\System32\LogFiles\Startup, Shutdown, Logon scripts\StartupLogon.log"
        Description = 'Machine startup script'
    }

  #endregion

  #TODO d: or e:
  $subModulePath = 'e:/0projects/dotfiles.windows/powershell/Modules/Environment/include'

  $__sys_variables = @{
    '..homeDrive' =             'C:'
                                
    '..systemBin' =             '%systemROOT%\system32'  
    systemBin =                 '%systemROOT%\system32'
    WINDIR =                    '%systemROOT%'
                                
    '..psHome'=                 '%systemROOT%\system32\windowsPowerShell\v1.0'
    psHome=                     '%systemROOT%\system32\windowsPowerShell\v1.0'
    psModulePath=               '%PROGRAMFILES%\windowsPowerShell\modules',
                                '%..psHome%\modules' -join ';'

    choco =                     'C:\programData\chocolatey'
    chocolateyInstall =         'C:\programData\chocolatey'
    chocoPath =                 'C:\programData\chocolatey\bin'
                                
    '..tools' =                 '%systemDRIVE%\tools'
    tools =                     '%systemDRIVE%\tools'
                                
    cmder =                     '%..tools%\cmderMini'
    cmder_Root =                '%..tools%\cmderMini'
    cmderPath =                 '%..tools%\cmderMini',
                                '%..tools%\cmderMini\bin',
                                '%..tools%\cmderMini\vendor\conemu-maximus5',
                                '%..tools%\cmderMini\vendor\conemu-maximus5\conemu' -join ';'
    chocolateyToolsLocation =   '%..tools%'

    githubApi =                 'https://api.github.com'
    git =                       '%PROGRAMFILES%\git'
    git_Install_Root =          '%PROGRAMFILES%\git'

    gitPath =                   '%PROGRAMFILES%\git\cmd',
                                '%PROGRAMFILES%\git',
                                '%PROGRAMFILES%\git\mingw64\bin',
                                '%PROGRAMFILES%\git\usr\bin' -join ';'

    kdiff3 =                    '%PROGRAMFILES%\kdiff3'
    'notepad++' =               '%PROGRAMFILES(X86)%\Notepad++\notepad++.exe'
    '..userRoot' =              '\users' 

    '..scoopGlobal'=            'C:\programData\scoop'
    scoop_Global=               '%PROGRAMDATA%\scoop'

    TEMP=                       '%systemROOT%\temp'
    TMP=                        '%systemROOT%\temp'

    junkPath =                  '%PROGRAMFILES(X86)%\skype\phone',
                                '%PROGRAMFILES(X86)%\brackets\command',
                                '%PROGRAMFILES%\microsoft SQL Server\130\tools\binn',
                                '%PROGRAMDATA%\oracle\java\javapath' -join ';'

    PATH =                      '%..systemBin%',
                                '%systemROOT%',
                                '%..systemBin%\wbem',
                                '%..psHome%',
                                '%chocoPath%',
                                '%..scoopGlobal%\shims',
                                '%cmderPath%', 
                                '%gitPath%' -join ';'
  }


  Write-Verbose "Executing Machine Startup script $psCommandPath"
  . "$subModulePath/Import-Environment.ps1"

  Import-Environment -Environment $__sys_variables -Scope Machine

  Get-ChildItem ENV: | 
      Out-String | 
      Out-File "$subModulePath/Set-MachineEnvironment-Initial-env.txt" -Encoding UTF8


  #region extra information

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

  #endregion extra information
