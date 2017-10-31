# User Logon script %systemRoot%\System32\GroupPolicy\User\Scripts\Logon\bbro-mao-logon.ps1 


    #region     constants

      $controlRegistryKey = 'HKCU:\Software\Cargonautika'
  
      $__user_variables = @{ 

        appDATA =       ${ENV:appDATA} -replace 'Users','users'

     '..userFullNAME' = [Environment]::GetFolderPath('UserProfile') | 
                            Split-Path -leaf
                            
     '..homePATH' =     '%..usersROOT%\%..userFullNAME%'
     '..scoop' =        '%..homeDRIVE%%..homePATH%\scoop'
        scoop  =        '%..homeDRIVE%%..homePATH%\scoop'
                        
     '..psProfileDIR' = '%..homeDRIVE%%..homePATH%\documents\windowsPowerShell'
        psProfileDIR  = '%..homeDRIVE%%..homePATH%\documents\windowsPowerShell'

        nvm_Home =      '%..scoop%\apps\nvm\current'
        nvm_Symlink =   '%..scoop%\apps\nvm\current\nodeJs'
        nodePath =      '%..scoop%\apps\nvm\current\nodeJs' -join ';'

        githubUser =    'turboBasic'
        githubUser2 =   'maoizm'
        githubGist =    '%githubAPI%/users/%githubUser%/gists'
        githubGist2 =   '%githubAPI%/users/%githubUser2%/gists'  

        dropbox =       '%systemDRIVE%\dropbox'
        dropbox_Home =  '%systemDRIVE%\dropbox'
        oneDRIVE =      '%systemDRIVE%\oneDRIVE'
        projects =      'E:\0projects'              
        winPepsiDebug = 1
             
        PSModulePATH =   '%..psProfileDir%\Modules',
                         '%psHOME%\Modules',
                         '%programFILES%\WindowsPowerShell\Modules' -join ';'


        PATH =          '%..homeDRIVE%%..homePATH%\bin',  
                        '%..scoop%\shims',
                        '%nodePath%',      
                        '%appDATA%\boxStarter',
                        '%oneDrive%\01_portable_apps',
                        '%junkPath%'  -join ';'                    
                        
        TEMP =          '%localAppDATA%\temp'
        TMP =           '%localAppDATA%\temp'
        ubuntu =        '%localAppDATA%\lxss\rootfs'
      }
      
      $eventLogParams = @{
        logName = "Application" 
        source =  "Module_StartupLogon" 
        eventID =  3001
      }
      
    #endregion 

    
    if( -not (Test-Path $controlRegistryKey) ) {
        New-Item -path $controlRegistryKey -force -errorAction SilentlyContinue
        if( -not $? ) { 
          "Error during creation of registry key $controlRegistryKey" | Write-Warning 
        }
    }
    if( IsNull (Get-ItemProperty -path $controlRegistryKey).NextBoot ) {
        'No requests to re-initialize variables' | Write-Verbose 
    }
    Set-ItemProperty -path $controlRegistryKey -name 'NextBoot' -value ''


  #region     writing header
  
@"
      Source              Module_StartupLogon
      TimeStamp           2017.08.28 23:48:47.977
      Script type         User logon script
      Script name         bbro-mao-logon.ps1
      Script directory    C:\Windows\System32\GroupPolicy\User\Scripts\Logon\bbro-mao-logon.ps1

"@ | Out-Null
  
      $message = [ordered] @{
          Source =              $eventLogParams.source
          TimeStamp =           Get-TimeStamp
          'Script type' =       'User logon script'
          'Script name' =       Split-Path $PSCommandPath -leaf
          'Script directory' =  Split-Path $PSCommandPath -parent
      } | Out-String -stream | Select-Object -skip 3

      Send-NetMessage "User logon script $PSCommandPath

                      $message"

  #endregion


  Import-Environment -environment $__user_variables -scope User

  
  #region initialization of variables dump procedure
  
      $params = @{ 
        scope = [EnvironmentScope]::User
        expand = $True
      }
      
      $allVars = Get-Environment * -scope User | 
          Select-Object Name, Value, @{ Name = 'Expanded'
                                        Expression = {
                                          $params.Name = $_.Name
                                          (Get-ExpandedName @params).Value 
                                        } 
                                      }
      
      $width = [ordered]@{ 
          Name =      27
          Value =     63
          Expanded = 'any'
      }
      $columns = [array]$width.keys
  
  #endregion initialization
  
  #region print headings
     
    $message += ( Remove-LeadingSpace @"
        [ {0,-7} {1,-6} {2} ]
        {3,-$( $width.Name )} {4,-$( $width.Value )} {5}
    
"@    ) -f '', 'body', (Get-TimeStamp), $columns[0], $columns[1], $columns[2]
    # Write-EventLog @eventLogParams -message $message
    
  #endregion

      
  #region print variables 
  
    # during print iterations for PATH-like variables ( i.e.  somevar = path1;path2;%pathReference1%;)
    # this variable controls if variable Name and its parts are printed 
    $printVariable = @{
      Name  = $True
      Value = $True
    }
    
    $printOnce = @{ Name=1; Value=1 }
    $message = ''

    
    $allVars  |  ForEach-Object {
    
        # print PATH-like variables consisting of multiple paths in user-friendly 3-column view:
        #   VarName      Item1 (as is)               Item1.1 (%subvariables% expanded)
        #                                                                 ...
        #                                                                Item1.m (%subvariables% expanded)
        #                               ...
        #                           ItemN (as is)               ItemN.1 (%subvariables% expanded)
        #                                                                 ...
        #                                                                ItemN.k (%subvariables% expanded)    
    
        $name =  $_.Name
        $value = $_.Value -split ';'      # convert PATH-like variables to array of items
        
        $printVariable.Name = $True
        $printOnce.Name = 1
        $value  |  ForEach-Object {
        
              # [string]$name * [int]$printOnce.Name  becomes empty string when $printOnce.Name=0
              #     and remains unchanged when $printOnce.Name=1
              $text = "{0,-$( $width.Name )}" -f ($name * $printOnce.Name)
              $text = "{0,-$( $width.Name )}" -f (
                          if( $printVariable.Name ) {
                              $name
                          } else {
                              ' '
                          }
              )
              
              
              $printOnce.Name = 0
           
              $expValue = [Environment]::ExpandEnvironmentVariables($_) -split ';'

              $currentValue = $_
              $printOnce.Value = 1
              $expValue | 
                  ForEach-Object { 
                    $message += "$text {0,-$( $width.Value )} {1} `r`n" -f 
                        ($currentValue * $printOnce.Value), $_
                    $printOnce.Value = 0
                  }
                  
        }
    
    }
    Write-EventLog @eventLogParams -message $message
  #endregion    