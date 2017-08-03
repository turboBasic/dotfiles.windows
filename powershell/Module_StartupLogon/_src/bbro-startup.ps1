# Machine startup script %systemRoot%\System32\GroupPolicy\Machine\Scripts\Startup\bbro-startup.ps1 

  #region     constants

Add-Type -TypeDefinition @"
  public Enum EnvironmentScope {
    Machine  = 0x0001
    User     = 0x0002
    Volatile = 0x0004
    Process  = 0x0008
  }
"@  

Add-Type -TypeDefinition @"
  public Enum EnvironmentData {
    Name   = 0x0010
    Value  = 0x0020
    Source = 0x0004
  }
"@  
  
    $__sys_variables = @{
      '..homeDRIVE' =           'C:'
      '..usersROOT' =           '\users'  
                                
      '..systemBIN' =           '%systemROOT%\system32'  
      systemBIN =               '%systemROOT%\system32'
      winDIR =                  '%systemROOT%'
                                
      '..psHOME' =              '%systemROOT%\system32\windowsPowerShell\v1.0'
      psHOME =                  '%..systemBIN%\windowsPowerShell\v1.0'
      psModulePATH =            'C:\program Files\windowsPowerShell\modules',
                                '%..psHOME%\modules' -join ';'

      allUsersPROFILE =         'C:\programData'
      choco =                   '%allUsersPROFILE%\chocolatey'
      chocolateyInstall =       '%allUsersPROFILE%\chocolatey'
      chocoPath =               '%allUsersPROFILE%\chocolatey\bin'
                                
      '..tools' =               '%systemDRIVE%\tools'
      tools =                   '%systemDRIVE%\tools'
                                
      cmder =                   '%..tools%\cmderMini'
      cmder_Root =              '%..tools%\cmderMini'
      cmderPath =               '%..tools%\cmderMini',
                                '%..tools%\cmderMini\bin',
                                '%..tools%\cmderMini\vendor\conemu-maximus5',
                                '%..tools%\cmderMini\vendor\conemu-maximus5\conemu' -join ';'
      chocolateyToolsLocation = '%..tools%'

      githubApi =               'https://api.github.com'
      git =                     'C:\program Files\git'
      git_Install_Root =        'C:\program Files\git'

      '..programFILES' =        '%..homeDRIVE%\program Files'
      gitPath =                 'C:\program Files\git\cmd',
                                'C:\program Files\git',
                                'C:\program Files\git\mingw64\bin',
                                'C:\program Files\git\usr\bin' -join ';'

      kdiff3 =                  'C:\program Files\kdiff3'
      'notepad++' =             'C:\program Files\notepad++\notepad++.exe'

      '..scoopGlobal' =         '%allUsersPROFILE%\scoop'
      scoop_Global =            '%allUsersPROFILE%\scoop'

      TEMP =                    '%systemROOT%\temp'
      TMP =                     '%systemROOT%\temp'

      '..programFILESx86' =     '%..homeDRIVE%\program Files (x86)'
      junkPath =                'C:\program Files (x86)\skype\phone',
                                'C:\program Files (x86)\brackets\command',
                                '%allUsersPROFILE%\oracle\java\javapath' -join ';'

      PATH =                    '%systemROOT%',
                                '%..systemBIN%',
                                '%..systemBIN%\wbem',
                                '%..psHOME%',
                                '%chocoPath%',
                                '%..scoopGlobal%\shims',
                                '%cmderPath%', 
                                '%gitPath%' -join ';'
    }


    # Default Log filename for Write-Log
    $logDir = "${ENV:systemBIN}\LogFiles"
    
    $psDefaultParameterValues = @{
      'Write-Log:FilePath' = 
          "${ENV:systemBIN}\LogFiles\Startup, Shutdown, Logon scripts\
                StartupLogon.log" -replace '\n\s*'      
    }

    # include all helper functions
    Get-ChildItem $psScriptRoot\allScripts.ps1 | ForEach-Object { . $_ }

    if( IsNull (Get-ItemProperty -path 'HKLM:\Software\Cargonautika').NextBoot ) {
        Write-Verbose 'No requests to initialize. exiting...'
    }
    Set-ItemProperty  -path 'HKLM:\Software\Cargonautika' `
                      -name 'NextBoot' -value ''

  #endregion


  #region     writing header

      "`n[ {0,-7} {1,-6} {2} ]" -f 'machine', 'header', (Get-TimeStamp) | 
            Write-Log

      "Machine startup script '{0}', '{1}'" -f 
            (Split-Path $psCommandPath -leaf), $psCommandPath | Write-Log

  #endregion


  Import-Environment -environment $__sys_variables -scope Machine


   #region initialization of variables dump procedure
  
      $params = @{ 
        Scope = [EnvironmentScope]::Machine
        Expand = $True
      }
      
      $allVars = Get-Environment * -scope Machine | 
          Select-Object `
              Name, 
              Value, 
              @{  
                  Name = 'Expanded'
                  Expression = {
                    $params.Name = $_.Name
                    (Get-ExpandedName @params).Value 
                  } 
               }
      
      $width = [ordered]@{ 
          Name =     27
          Value =    53
          Expanded = 'any'
      }
      $columns = [array]$width.keys
  
  #endregion initialization

  #region print headings
    "`n[ {0,-7} {1,-6} {2} ]" -f '', 'body', (Get-TimeStamp) | Write-Log
    
    "{0,-$( $width.Name )} {1,-$( $width.Value )} {2}" -f $columns |
        ForEach-Object { 
          $_ | Write-Log
          $_ -replace '\S', '-' | Write-Log
        }
  #endregion

  
  #region print variables  
    $printOnce = @{ Name=1; Value=1 }
    $s | ForEach-Object {
      $name = $_.Name
      $value = $_.Value -split ';'
      
      $printOnce.Name = 1
      $value | 
          ForEach-Object {      
            $text = "{0,-$( $width.Name )}" -f ($name * $printOnce.Name)
            $printOnce.Name = 0
     
            $expValue = [Environment]::ExpandEnvironmentVariables($_) -split ';'

            $currentValue = $_
            $printOnce.Value = 1
            $expValue | 
                ForEach-Object { 
                  "$text {0,-$( $width.Value )} {1}" -f 
                      ($currentValue * $printOnce.Value), $_ | Write-Log  
                  $printOnce.Value = 0
                }
          }
    }
  #endregion
 

                        

  

        