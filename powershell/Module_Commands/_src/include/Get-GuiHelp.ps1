Function Get-GuiHelp {

  PARAM(  
          [PARAMETER( Position=0 )]
          [String] $Request,

          [PARAMETER()]
          [Switch] $List,

          [PARAMETER()]
          [Switch] $Force            
  )

  
  
  $GuiHelpPath = Join-Path $ENV:DROPBOX_HOME '/Public/Powershell/powershell2.chm'

  if ($List) {
    Get-Content "$GuiHelpPath.TopicsList.txt"
    return
  }

        
  if ($Force) {
    Get-Content "$GuiHelpPath.TopicsList.txt" |
        Where { $_ -match ".*$Request.*" } |
        ForEach-Object { 
          $_
          HH.EXE "mk:@MSITStore:${GuiHelpPath}::$_"
        }
    return
  }
  
  
  
  $Postfix = switch ($Request) {
    
      { IsNull $_.Trim() } { 

          '/test.htm'
          break 
      }

      { $_ -match '^about_' } { 
      
          "/About/$_.help.htm"
          break  
      }

      { $_ -cmatch '^a[A-Z]\w+' } {
      
          "/About/about_$(
          
              $_.TrimStart('a').toLower()  
          
          ).help.htm"
          break  
      }
      
      { $_ -match '^\w+-\w+' } { 
      
          "/Cmdlets/$_.htm"
          break  
      }
      
      DEFAULT { "/VBScript/$_.htm" -replace ' ' }
      
    }

  "mk:@MSITStore:${GuiHelpPath}::${Postfix}" | Write-Verbose  
  HH.EXE "mk:@MSITStore:${GuiHelpPath}::${Postfix}"
  
}