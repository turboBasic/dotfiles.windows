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
      . "$subModulePath/Get-Environment.ps1"
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
    psModulePath=               'C:\program files\windowsPowerShell\modules',
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
    git =                       'C:\program files\git'
    git_Install_Root =          'C:\program files\git'

    '..programFiles' =          '%..homeDrive%\program files'
    gitPath =                   'C:\program files\git\cmd',
                                'C:\program files\git',
                                'C:\program files\git\mingw64\bin',
                                'C:\program files\git\usr\bin' -join ';'

    kdiff3 =                    'C:\program files\kdiff3'
    'notepad++' =               'C:\program files\Notepad++\notepad++.exe'
    '..userRoot' =              '\users' 

    '..scoopGlobal'=            '%ALLUSERSPROFILE%\scoop'
    scoop_Global=               '%ALLUSERSPROFILE%\scoop'

    TEMP=                       '%systemROOT%\temp'
    TMP=                        '%systemROOT%\temp'

    '..programFilesX86' =       '%..homeDrive%\program files (x86)'
    junkPath =                  'C:\program files (x86)\skype\phone',
                                'C:\program files (x86)\brackets\command',
                                'C:\program files\microsoft SQL Server\130\tools\binn',
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
  Get-Environment * -Scope Machine |
          select Name, Value |
          ForEach { if($_.Name -NotIn @('Path', 'gitPath', 'cmderPath', 'junkPath')){
                      [psCustomObject][ordered]@{ Name=$_.Name; Value=$_.Value; Expanded=(Get-ExpandedName $_.Name -Scope Machine -Expand).Value }
                    } else {
                      $paths = $_.Value -split ';'
                      $pathsExpanded = (Get-ExpandedName $_.Name -Scope Machine -Expand).Value -split ';'
                      [psCustomObject][ordered]@{ Name=$_.Name; Value=$paths[0]; Expanded=$pathsExpanded[0] }
                      1..$paths.GetUpperBound(0) |
                          ForEach { 
                              [psCustomObject][ordered]@{ Name=' '; Value=$paths[$_]; Expanded=$pathsExpanded[$_] }
                          }
                    }
          }
