# User Logon script %systemRoot%\System32\GroupPolicy\User\Scripts\Logon\bbro-mao-logon.ps1 


  #region     constants

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
      $PSDefaultParameterValues = @{
        'Write-Log:FilePath' = 
              "${ENV:systemROOT}\System32\LogFiles\Startup, Shutdown, Logon scripts\StartupLogon.log"     
      }

      Get-ChildItem "$psScriptRoot/allScripts.ps1" | ForEach { . $_ }

      if( IsNull (Get-ItemProperty -Path 'HKCU:\Software\Cargonautika').NextBoot ) {
          Write-Verbose 'No requests to initialize. exiting...'
      }
      Set-ItemProperty -Path 'HKCU:\Software\Cargonautika' -Name 'NextBoot' -Value ''


  #endregion


  #region     writing header

      "`n[ {0,-7} {1,-6} {2} ]" -f 'user', 'header', (Get-TimeStamp) | Write-Log

      "User logon script '{0}', '{1}'" -f 
            (Split-Path $PSCommandPath -Leaf), $PSCommandPath | Write-Log

      Send-NetMessage "User logon script $PSCommandPath"

  #endregion


  Import-Environment -Environment $__user_variables -Scope User

  "`n[ {0,-7} {1,-6} {2} ]" -f '', 'body', (Get-TimeStamp) | Write-Log
  Get-Environment * -Scope User |
      Select-Object Name, Value |
      ForEach-Object { 
          if($_.Name -NotLike '*path') {
                  [psCustomObject][ordered]@{ 
                      Name     = $_.Name
                      Value    = $_.Value
                      Expanded = (Get-ExpandedName $_.Name -Scope User -Expand).Value 
                  }
          } else {
            $paths    = (Get-ExpandedName $_.Name -Scope User).Value -split ';'
            $pathsExp = (Get-ExpandedName $_.Name -Scope User -Expand).Value -split ';'
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
