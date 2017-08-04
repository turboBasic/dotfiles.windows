# User Logon script %systemRoot%\System32\GroupPolicy\User\Scripts\Logon\bbro-mao-logon.ps1 


  #region     constants

Enum EnvironmentScope {
    Machine  = 0x0001
    User     = 0x0002
    Volatile = 0x0004
    Process  = 0x0008
  }
 

Enum EnvironmentData {
    Name   = 0x0010
    Value  = 0x0020
    Source = 0x0004
  }
  
  
      $__user_variables = @{ 

        appDATA =                ${ENV:appDATA} -replace 'Users','users'

     '..userFullNAME' =          Split-Path ([Environment]::GetFolderPath('UserProfile')) -Leaf
     '..homePATH' =              '%..usersROOT%\%..userFullNAME%'
     '..scoop' =                 '%..homeDRIVE%%..homePATH%\scoop'
        scoop  =                 '%..homeDRIVE%%..homePATH%\scoop'
                                 
     '..psProfileDIR' =          '%..homeDRIVE%%..homePATH%\documents\windowsPowerShell'
        psProfileDIR  =          '%..homeDRIVE%%..homePATH%\documents\windowsPowerShell'

        nvm_Home =               '%..scoop%\apps\nvm\current'
        nvm_Symlink =            '%..scoop%\apps\nvm\current\nodeJs'
        nodePath =               '%..scoop%\apps\nvm\current\nodeJs' -join ';'

        githubUser =             'turboBasic'
        githubUser2 =            'maoizm'
        githubGist =             '%githubAPI%/users/%githubUser%/gists'
        githubGist2 =            '%githubAPI%/users/%githubUser2%/gists'  

        dropbox =                '%systemDRIVE%\dropbox'
        dropbox_Home =           '%systemDRIVE%\dropbox'
        oneDRIVE =               '%systemDRIVE%\oneDRIVE'
        projects =               'E:\0projects'              
        winPepsiDebug =          1
             
        psModulePATH =           '%..psProfileDIR%\modules',
                                 '%appDATA%\boxStarter' -join ';'

        PATH =                   '%..homeDRIVE%%..homePATH%\bin',  
                                 '%..scoop%\shims',
                                 '%nodePath%',      
                                 '%appDATA%\boxStarter',
                                 '%oneDrive%\01_portable_apps',
                                 '%junkPath%'  -join ';'                    
                                 
        TEMP =                   '%localAppDATA%\temp'
        TMP =                    '%localAppDATA%\temp'
        ubuntu =                 '%localAppDATA%\lxss\rootfs'
      }

      # Default Log filename for Write-Log
      $psDefaultParameterValues = @{
        'Write-Log:FilePath' = 
            "${ENV:systemBIN}\LogFiles\Startup, Shutdown, Logon scripts\
                    StartupLogon.log" -replace '\n\s*'    
      }
      
      # include all helper functions
      Get-ChildItem $psScriptRoot\allScripts.ps1 | ForEach-Object { . $_ }
      
      
      if( -not (Test-Path 'HKCU:\Software\Cargonautika')) {
          New-Item -path 'HKCU:\Software\Cargonautika' -force -errorAction SilentlyContinue
          if (-not $?) { 'Something wrong with this' | Write-Warning }
      }
      if( IsNull (Get-ItemProperty -path 'HKCU:\Software\Cargonautika').NextBoot ) {
          Write-Verbose 'No requests to initialize. exiting...'
      }
      Set-ItemProperty -path 'HKCU:\Software\Cargonautika' -name 'NextBoot' -value ''


  #endregion


  #region     writing header

      "`n[ {0,-7} {1,-6} {2} ]" -f 'user', 'header', (Get-TimeStamp) | Write-Log

      "User logon script '{0}', '{1}'" -f 
            (Split-Path $psCommandPath -Leaf), $psCommandPath | Write-Log

      Send-NetMessage "User logon script $psCommandPath"

  #endregion


  Import-Environment -environment $__user_variables -scope user

  
  #region initialization of variables dump procedure
  
      $params = @{ 
        Scope = [EnvironmentScope]::User
        Expand = $True
      }
      
      $allVars = Get-Environment * -scope User | 
          Select-Object `
              Name, 
              Value, 
              @{  
                  Name='Expanded'
                  Expression={
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
    $allVars | ForEach-Object {
      $name = $_.Name
      $value = $_.Value -split ';'
      
      $printOnce.Name = 1
      $value | ForEach-Object {      
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