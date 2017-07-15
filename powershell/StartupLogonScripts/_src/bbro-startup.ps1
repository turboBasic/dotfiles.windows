# Machine startup script %systemRoot%\System32\GroupPolicy\Machine\Scripts\Startup\bbro-startup.ps1 


  #region     constants

      $__sys_variables = @{
        '..homeDRIVE' =             'C:'
        '..usersROOT' =             '\users'  
                                    
        '..systemBIN' =             '%systemROOT%\system32'  
        systemBIN =                 '%systemROOT%\system32'
        winDIR =                    '%systemROOT%'
                                    
        '..psHOME' =                '%systemROOT%\system32\windowsPowerShell\v1.0'
        psHOME =                    '%..systemBIN%\windowsPowerShell\v1.0'
        psModulePATH =              'C:\program Files\windowsPowerShell\modules',
                                    '%..psHOME%\modules' -join ';'

        allUsersPROFILE =           'C:\programData'
        choco =                     '%allUsersPROFILE%\chocolatey'
        chocolateyInstall =         '%allUsersPROFILE%\chocolatey'
        chocoPath =                 '%allUsersPROFILE%\chocolatey\bin'
                                    
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
        git =                       'C:\program Files\git'
        git_Install_Root =          'C:\program Files\git'

        '..programFILES' =          '%..homeDRIVE%\program Files'
        gitPath =                   'C:\program Files\git\cmd',
                                    'C:\program Files\git',
                                    'C:\program Files\git\mingw64\bin',
                                    'C:\program Files\git\usr\bin' -join ';'

        kdiff3 =                    'C:\program Files\kdiff3'
        'notepad++' =               'C:\program Files\notepad++\notepad++.exe'

        '..scoopGlobal' =           '%allUsersPROFILE%\scoop'
        scoop_Global =              '%allUsersPROFILE%\scoop'

        TEMP =                      '%systemROOT%\temp'
        TMP =                       '%systemROOT%\temp'

        '..programFILESx86' =       '%..homeDRIVE%\program Files (x86)'
        junkPath =                  'C:\program Files (x86)\skype\phone',
                                    'C:\program Files (x86)\brackets\command',
                                    '%allUsersPROFILE%\oracle\java\javapath' -join ';'

        PATH =                      '%systemROOT%',
                                    '%..systemBIN%',
                                    '%..systemBIN%\wbem',
                                    '%..psHOME%',
                                    '%chocoPath%',
                                    '%..scoopGlobal%\shims',
                                    '%cmderPath%', 
                                    '%gitPath%' -join ';'
      }


      # Default Log filename for Write-Log
      $PSDefaultParameterValues = @{
        'Write-Log:FilePath' = 
              "${ENV:systemROOT}\System32\LogFiles\Startup, Shutdown, Logon scripts\StartupLogon.log"     
      }


      Get-ChildItem "$psScriptRoot/include/*.ps1" | ForEach { . $_ }

      if( IsNull (Get-ItemProperty -Path 'HKLM:\Software\Cargonautika').NextBoot ) {
          Write-Verbose 'No requests to initialize. exiting...'
      }
      Set-ItemProperty -Path 'HKLM:\Software\Cargonautika' -Name 'NextBoot' -Value ''


  #endregion


  #region     writing header

      "`n[ {0,-7} {1,-6} {2} ]" -f 'machine', 'header', (Get-TimeStamp) | Write-Log

      "Machine startup script '{0}', '{1}'" -f 
            (Split-Path $PSCommandPath -Leaf), $PSCommandPath | Write-Log

  #endregion


  Import-Environment -Environment $__sys_variables -Scope Machine


  "`n[ {0,-7} {1,-6} {2} ]" -f '', 'body', (Get-TimeStamp) | Write-Log
  Get-Environment * -Scope Machine |
          select Name, Value |
          ForEach { if($_.Name -NotLike '*path'){
                      [psCustomObject][ordered]@{ Name=$_.Name; Value=$_.Value; Expanded=(Get-ExpandedName $_.Name -Scope Machine -Expand).Value }
                    } else {
                      $paths    = (Get-ExpandedName $_.Name -Scope Machine).Value -split ';'
                      $pathsExp = (Get-ExpandedName $_.Name -Scope Machine -Expand).Value -split ';' 
                      if($pathsExp.Count -gt $path.Count)  
                          { $numberOfPaths = $pathsExp.Count }
                      else 
                          { $numberOfPaths = $path.Count }   
                      foreach( $i in 0..($numberOfPaths - 1) ) { 
                          $res = [ordered]@{ Name=''; Value=''; Expanded='' }
                          if($i -eq 0)               { $res.Name = $_.Name }
                          if($i -lt $paths.Count)    { $res.Value = $paths[$i] }
                          if($i -lt $pathsExp.Count) { $res.Expanded = $pathsExp[$i] }
                          [psCustomObject]$res
                      }
                    }
          } | Out-String -width 360 -stream | Write-Log
