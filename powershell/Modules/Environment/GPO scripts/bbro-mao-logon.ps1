# User Logon script %systemRoot%\System32\GroupPolicy\User\Scripts\Logon\bbro-mao-logon.ps1 


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




  "`n[{0,-14} {1}]" -f 'header user', (Set-LogEntry) | Out-String | Write-Log

  'User logon script {0,-22}, full path: {1}' -f 
        (Split-Path $PSCommandPath -Leaf), $PSCommandPath | 
        Write-Log

  Send-NetMessage "User logon script $PSCommandPath"




  $__user_variables = @{ 

 '..userName' =              'mao'
 '..homePath' =              '%..userRoot%\%..userName%'
 '..scoop' =                 '%..homeDrive%%..homePath%\scoop'
    scoop  =                 '%..homeDrive%%..homePath%\scoop'
                             
 '..psProfileDir' =          '%..homeDrive%%..homePath%\documents\windowsPowerShell'
    psProfileDir  =          '%..homeDrive%%..homePath%\documents\windowsPowerShell'

    nvm_Home =               '%..scoop%\apps\nvm\current'
    nvm_Symlink =            '%..scoop%\apps\nvm\current\nodeJs'
    nodePath =               '%..scoop%\apps\nvm\current\nodeJs' -join ';'

    githubUser =             'TurboBasic'
    githubUser2 =            'maoizm'
    githubGist =             '%githubAPI%/users/%githubUser%/gists'
    githubGist2 =            '%githubAPI%/users/%githubUser2%/gists'  

    dropbox =                '%systemDRIVE%\dropbox'
    dropbox_Home =           '%systemDRIVE%\dropbox'
    oneDrive =               '%systemDRIVE%\oneDrive'
    projects =               'E:\0projects'              
    winPepsiDebug =          1
         
    psModulePath =           '%..psProfileDir%\modules',
                             '%APPDATA%\boxStarter' -join ';'

    PATH =                   '%..homeDrive%%..homePath%\bin',  
                             '%..scoop%\shims',
                             '%nodePath%',      
                             '%APPDATA%\boxStarter',
                             '%oneDrive%\01_portable_apps',
                             '%junkPath%'  -join ';'                    
                             
    TEMP =                   '%LOCALAPPDATA%\temp'
    TMP =                    '%LOCALAPPDATA%\temp'
    ubuntu =                 '%LOCALAPPDATA%\lxss\rootfs'
  }



  Import-Environment -Environment $__user_variables -Scope User

  $a = Get-Environment -Name Path -Scope Machine -expand | Select -expandproperty Value| %{ $_ -split ';'}   #| Sort
  $b = Get-Environment -Name Path -Scope User -expand | Select -expandproperty Value| %{ $_ -split ';'}      #| Sort


  "`n[{0,-14} {1}]" -f 'body user', (Set-LogEntry) | Out-String | Write-Log
  Get-Environment * -Scope User |
          select Name, Value |
          ForEach { if($_.Name -NotIn @('Path', 'gitPath', 'cmderPath', 'junkPath')){
                      [psCustomObject][ordered]@{ Name=$_.Name; Value=$_.Value; Expanded=(Get-ExpandedName $_.Name -Scope User -Expand).Value }
                    } else {
                      $paths = $_.Value -split ';'
                      $pathsExpanded = (Get-ExpandedName $_.Name -Scope User -Expand).Value -split ';'
                      [psCustomObject][ordered]@{ Name=$_.Name; Value=$paths[0]; Expanded=$pathsExpanded[0] }
                      1..$paths.GetUpperBound(0) |
                          ForEach { 
                              [psCustomObject][ordered]@{ Name=' '; Value=$paths[$_]; Expanded=$pathsExpanded[$_] }
                          }
                    }
          }
