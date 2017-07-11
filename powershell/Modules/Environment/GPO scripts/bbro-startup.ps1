# Machine startup script %systemRoot%\System32\GroupPolicy\Machine\Scripts\Startup\bbro-startup.ps1 

  #region     initialization

      # Default Log filename for Write-Log
      $PSDefaultParameterValues = @{
        'Write-Log:FilePath' = 
              "${ENV:systemROOT}\System32\LogFiles\Startup, Shutdown, Logon scripts\StartupLogon.log"     
      }

      #TODO d: or e:
      $subModulePath =     'e:/0projects/dotfiles.windows/powershell/Modules/Environment/include'
      $commandModulePath = 'e:/0projects/dotfiles.windows/powershell/Modules/Commands/include'

      . "$subModulePath/Import-Environment.ps1"
      . "$commandModulePath/Set-LogEntry.ps1"
      . "$commandModulePath/Write-Log.ps1"

  #endregion

  "`n[{0,-14} {1}]" -f 'header machine', (Set-LogEntry) | Out-String | Write-Log

  'Machine startup script {0,-22}, full path: {1}' -f 
        (Split-Path $PSCommandPath -Leaf), $PSCommandPath | 
        Write-Log

  $__sys_variables = @{
    '..homeDrive' =             'C:'
                                
    '..systemBin' =             '%systemROOT%\system32'  
    systemBin =                 '%systemROOT%\system32'
    WINDIR =                    '%systemROOT%'
                                
    '..psHome'=                 '%systemROOT%\system32\windowsPowerShell\v1.0'
    psHome=                     '%systemROOT%\system32\windowsPowerShell\v1.0'
    psModulePath=               '%PROGRAMFILES%\windowsPowerShell\modules',
                                '%..psHome%\modules' -join ';'

    choco =                     '%ALLUSERSPROFILE%\chocolatey'
    chocolateyInstall =         '%ALLUSERSPROFILE%\chocolatey'
    chocoPath =                 '%ALLUSERSPROFILE%\chocolatey\bin'
                                
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
    git =                       '%COMMONPROGRAMFILES%\..\git'
    git_Install_Root =          '%COMMONPROGRAMFILES%\..\git'

    gitPath =                   '%COMMONPROGRAMFILES%\..\git\cmd',
                                '%COMMONPROGRAMFILES%\..\git',
                                '%COMMONPROGRAMFILES%\..\git\mingw64\bin',
                                '%COMMONPROGRAMFILES%\..\git\usr\bin' -join ';'

    kdiff3 =                    '%COMMONPROGRAMFILES%\..\kdiff3'
    'notepad++' =               '%COMMONPROGRAMFILES%\..\Notepad++\notepad++.exe'
    '..userRoot' =              '\users' 

    '..scoopGlobal'=            '%ALLUSERSPROFILE%\scoop'
    scoop_Global=               '%ALLUSERSPROFILE%\scoop'

    TEMP=                       '%systemROOT%\temp'
    TMP=                        '%systemROOT%\temp'

    junkPath =                  '%COMMONPROGRAMFILES(X86)%\..\skype\phone',
                                '%COMMONPROGRAMFILES(X86)%\..\brackets\command',
                                '%COMMONPROGRAMFILES%\..\microsoft SQL Server\130\tools\binn',
                                '%ALLUSERSPROFILE%\oracle\java\javapath' -join ';'

    PATH =                      '%..systemBin%',
                                '%systemROOT%',
                                '%..systemBin%\wbem',
                                '%..psHome%',
                                '%chocoPath%',
                                '%..scoopGlobal%\shims',
                                '%cmderPath%', 
                                '%gitPath%' -join ';'
  }

  Import-Environment -Environment $__sys_variables -Scope Machine

  "`n[{0,-14} {1}]" -f 'body machine', (Set-LogEntry) | Out-String | Write-Log
  Get-ChildItem ENV: | 
      Out-String -Width 2048 -Stream | 
      ForEach { $_.TrimEnd() } | 
      Write-Log

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
