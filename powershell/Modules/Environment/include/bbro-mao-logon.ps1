# User Logon script %systemRoot%\System32\GroupPolicy\User\Scripts\Logon\bbro-mao-logon.ps1 

. 'd:/0projects/dotfiles.windows/powershell/Modules/Environment/include/Set-UserEnvironment.ps1'

<# 

Function Set-UserEnvironment {

  #region Parameters
    [CMDLETBINDING(
      SupportsShouldProcess=$True,
      ConfirmImpact="Medium"
    )]
    PARAM(
        [PARAMETER( Mandatory=$False,
                    ValueFromPipeline=$False, 
                    HelpMessage='Reset user environment')]
            [switch]
            $Initialise
    )
  #endregion

  Write-Verbose "`n Set-UserEnvironment `n"
  $__user_variables.Keys | 
      ForEach-Object { 
          Set-Environment -Name $_ -Value $__user_variables[$_] -Scope User -Expand:($__user_variables[$_] -match '%..*%') 
      }

  Send-EnvironmentChanges 
}

#>

  $__user_variables = @{ 
    '..psProfileDir'=        '%..homeDrive%%..homePath%\documents\windowsPowerShell'
    psProfileDir=            '%..homeDrive%%..homePath%\documents\windowsPowerShell'

    nvm_Home=                '%..scoop%\apps\nvm\current'
    nvm_Symlink=             '%..scoop%\apps\nvm\current\nodeJs'
    nodePath=                '%..scoop%\apps\nvm\current\nodeJs' -join ';'

    dropbox=                 '%systemDRIVE%\dropbox'
    dropbox_Home=            '%systemDRIVE%\dropbox'
    oneDrive=                '%systemDRIVE%\oneDrive'
    projects=                'E:\0projects'              
    winPepsiDebug=           1
         
    psModulePath=            '%..psProfileDir%\modules',
                             '%APPDATA%\boxStarter' -join ';'


    PATH=                    '%..homeDrive%%..homePath%\bin',  
                             '%..scoop%\shims',
                             '%nodePath%',      
                             '%APPDATA%\boxStarter',
                             '%oneDrive%\01_portable_apps',
                             '%junkPath%' -join ';'                    
                             
    TEMP=                    '%LOCALAPPDATA%\temp'
    TMP=                     '%LOCALAPPDATA%\temp'
    ubuntu =                 '%LOCALAPPDATA%\lxss\rootfs'
  }

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


Write-Verbose "Executing User Logon script $psCommandPath"

Get-ChildItem ENV: | Out-String | Out-File 'd:/0projects/dotfiles.windows/powershell/Modules/Environment/include/Set-UserEnvironment-Initial-env.txt'  -Encoding UTF8