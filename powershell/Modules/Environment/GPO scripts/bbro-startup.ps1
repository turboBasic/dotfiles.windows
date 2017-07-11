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
    git =                       '%..programFiles%\git'
    git_Install_Root =          '%..programFiles%\git'

    '..programFiles' =          '%..homeDrive%\Program Files'
    gitPath =                   '%..programFiles%\git\cmd',
                                '%..programFiles%\git',
                                '%..programFiles%\git\mingw64\bin',
                                '%..programFiles%\git\usr\bin' -join ';'

    kdiff3 =                    '%..programFiles%\kdiff3'
    'notepad++' =               '%..programFiles%\Notepad++\notepad++.exe'
    '..userRoot' =              '\users' 

    '..scoopGlobal'=            '%ALLUSERSPROFILE%\scoop'
    scoop_Global=               '%ALLUSERSPROFILE%\scoop'

    TEMP=                       '%systemROOT%\temp'
    TMP=                        '%systemROOT%\temp'

    '..programFilesX86' =       '%..homeDrive%\Program Files (x86)'
    junkPath =                  '%..programFilesX86%\skype\phone',
                                '%..programFilesX86%\brackets\command',
                                '%..programFiles%\microsoft SQL Server\130\tools\binn',
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
