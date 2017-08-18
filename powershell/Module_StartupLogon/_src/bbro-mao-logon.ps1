# User Logon script %systemRoot%\System32\GroupPolicy\User\Scripts\Logon\bbro-mao-logon.ps1 


    #region     constants

      $registryKey = 'HKCU:\Software\Cargonautika'
  
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
             
        psModulePATH =            '%..psProfileDir%\Modules',
                                  '%psHOME%\Modules',
                                  '%programFILES%\WindowsPowerShell\Modules' -join ';'


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
      $PSDefaultParameterValues = @{
        'Write-Log:FilePath' = 
            "${ENV:systemBIN}\LogFiles\Startup, Shutdown, Logon scripts\
                    StartupLogon.log" -replace '\n\s*'    
      }
      
      $eventLogParams = @{
        logName = "Application" 
        source =  "Module_StartupLogon_User_${ENV:UserName}" 
        eventID = 3001
      }
      
    #endregion 

     
    # include all helper functions
    # Get-ChildItem $psScriptRoot\allScripts.ps1 | ForEach-Object { . $_ }
    
    if( -not (Test-Path $registryKey) ) {
        New-Item -path $registryKey -force -errorAction SilentlyContinue
        if( -not $? ) { 
          "Error during creation of registry key $registryKey" | Write-Warning 
        }
    }
    if( IsNull (Get-ItemProperty -path $registryKey).NextBoot ) {
        Write-Verbose 'No requests to initialize. exiting...'
    }
    Set-ItemProperty -path $registryKey -name 'NextBoot' -value ''


  #region     writing header
      
#      $message = "`n[ {0,-7} {1,-6} {2} ]" -f 'user', 'header', (Get-TimeStamp)
#      $message | Write-Log
#      Write-EventLog -logName Application -source "Module_StartupLogon_User_${ENV:UserName}" -eventID 3001 -message $message
      
#      $message += "`nUser logon script '{0}', '{1}'" -f 
#            (Split-Path $PSCommandPath -leaf), $PSCommandPath
            
      $message = ( Remove-NewlineAndIndent @"
          [ {0,-7} {1,-6} {2} ]
          User logon script '{3}', '{4}'
          
"@    ) -f  'user', 'header', (Get-TimeStamp), 
            (Split-Path $PSCommandPath -leaf), $PSCommandPath
          
#      $message | Write-Log
      Write-EventLog @eventLogParams -message $message
      Send-NetMessage "User logon script $PSCommandPath"

  #endregion


  Import-Environment -environment $__user_variables -scope User

  
  #region initialization of variables dump procedure
  
      $params = @{ 
        scope = [EnvironmentScope]::User
        expand = $True
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
          Name =      27
          Value =     53
          Expanded = 'any'
      }
      $columns = [array]$width.keys
  
  #endregion initialization
  
  #region print headings
#    $message = "`n[ {0,-7} {1,-6} {2} ]" -f '', 'body', (Get-TimeStamp)
#    $message | Write-Log
#    Write-EventLog -logName Application -source "Module_StartupLogon_User_${ENV:UserName}" -eventID 3001 -message $message
    
#    "{0,-$( $width.Name )} {1,-$( $width.Value )} {2}" -f $columns |
#        ForEach-Object { 
#          $_ | Write-Log
#          Write-EventLog -logName Application -source "Module_StartupLogon_User_${ENV:UserName}" -eventID 3001 -message $_
     
    $message = ( Remove-LeadingSpace @"
        [ {0,-7} {1,-6} {2} ]
        {3,-$( $width.Name )} {4,-$( $width.Value )} {5}
    
"@    ) -f '', 'body', (Get-TimeStamp), $columns[0], $columns[1], $columns[2]
    Write-EventLog @eventLogParams -message $message
    
     
#          $_ -replace '\S', '-' | Write-Log
#          Write-EventLog -logName Application -source "Module_StartupLogon_User_${ENV:UserName}" -eventID 3001 -message ($_ -replace '\S', '-')
#        }
  #endregion

      
  #region print variables  
    $printOnce = @{ Name=1; Value=1 }
    $message = ''
    
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
              $message += "$text {0,-$( $width.Value )} {1} `r`n" -f 
                  ($currentValue * $printOnce.Value), $_
#              $message | Write-Log
#              Write-EventLog @eventLogParams -message $message
              
              $printOnce.Value = 0
            }
      }
    }
    Write-EventLog @eventLogParams -message $message
  #endregion    