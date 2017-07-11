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

  "`n[{0,-14} {1}]" -f 'body user', (Set-LogEntry) | Out-String | Write-Log
  Get-ChildItem ENV: | 
      Out-String -Width 2048 -Stream | 
      ForEach { $_.TrimEnd() } |
      Write-Log

  #region extra information

      <#region Powershell variables based on Environment vars  (__Set-GlobalVariables.ps1)
        $__profileDir=              $env:psProfileDir
        $__projects=                $env:projects
        $__userName=                $env:USERNAME
        $__homeDrive=               $env:HOMEDRIVE
      #endregion#>  
      <#region perl settings
        perlPath=                  '%git%\usr\bin\core_perl', 
                                   '%git%\usr\bin\site_perl', 
                                   '%git%\usr\bin\vendor_perl' -join ';' 
      #endregion#>
      <#region Extra bits for future use
        ..nodePath=                '%LOCALAPPDATA%\yarn\config\global\node_modules\.bin'
        PATH=                      '%LOCALAPPDATA%\yarn\config\global\node_modules\.bin'
        PATH=                      'C:\program files\imageMagick-7.0.5-Q16'
        PATH=                      '%LOCALAPPDATA%\Microsoft\WindowsApps'       
      #endregion#>
      <#region User Base variables         
        USERNAME=                  'mao'                     
        HOMEDRIVE=                 'C:'
        HOMEPATH=                  '%profiles%\%USERNAME%'
        USERPROFILE=               '%HOMEDRIVE%%HOMEPATH%'
        USERAPP=                   '%USERPROFILE%\APPDATA'
        APPDATA=                   '%USERAPP%\roaming'
        LOCALAPPDATA=              '%USERAPP%\local'
        LOGONSERVER=               '\\ASUS'
        USERDOMAIN=                'ASUS'
        USERDOMAIN_ROAMINGPROFILE= 'ASUS'
      #endregion#>
      <#region Default User variables
        PATH=                      '%USERPROFILE%\appData\local\microsoft\windowsApps';
        TEMP=                      '%USERPROFILE%\appData\local\temp';
        TMP=                       '%USERPROFILE%\appData\local\temp';
      #endregion#>

  #endregion
