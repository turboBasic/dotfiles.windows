Function Get-GuiHelp {

  PARAM(  [PARAMETER( Position=0 )]
          [String] $Request,

          [PARAMETER()]
          [Switch] $List  )

  $GuiHelpPath = ($ENV:DROPBOX_HOME -replace "\\", "/") + '/Public/Powershell/powershell2.chm' 

  if ($List) {
    Get-Content "$GuiHelpPath.TopicsList.txt"
  }

  $Postfix = 
    switch ($Request) {
      { $_.Trim().Length -eq 0 } { '/test.htm'; break }
      { $_ -match '^about_' }    { "/About/${Request}.help.htm"; break  }

      { $_ -cmatch '^a[A-Z][a-zA-Z_]{1,}' } { '/About/about_' + $Request.TrimStart('a').toLower() + '.help.htm'; break  }
      { $_ -match  '^[a-z]{1,}-[a-z]{1,}' } { "/Cmdlets/${Request}.htm"; break  }

      { $_.Contains(' ') }       { '/VBScript/' + $Request -replace(' ','') + '.htm'; break  }
      Default                    { "/VBScript/${Request}.htm" }
    }

  $command = "HH.EXE mk:@MSITStore:${GuiHelpPath}::${Postfix}"

  Write-Verbose "Get-GuiHelp: using `$Postfix = $Postfix"
  Write-Verbose "Get-GuiHelp: full command = $command"
  Invoke-Expression -Command $command
}