#region initialization of module

  # We do not dot source the individual scripts because loadin of subscripts
  # is executed automatically using `NestedModules` parameter in Commands.psd1

  # Write-Host -ForegroundColor Green "Module $(Split-Path $PSScriptRoot -Leaf) was successfully loaded."

#endregion


#region shortcut functions (only for saving typing and keyboards)
    Function Private:smartShorten([string]$source, [int32]$width, [int32]$left) {
        if($source.length -le $width) {
            return $source
        } else {
            return $source.substring(0, $left) + 
                   " ... " +
                   $source.substring($source.length - ($width-$left-5), $width-$left-5)
        }
    }  
#endregion



#region Create aliases for functions
  New-Alias touch Set-FileTime
  New-Alias ppath Get-EnvironmentPath
  New-Alias sst   Select-String
  New-Alias gg    Get-GuiHelp 
  New-Alias gh    Get-HelpWindow
  New-Alias ghc   Get-Help
  New-Alias Get-KnownFolders Get-SpecialFolders
  New-Alias gkf   Get-KnownFolders
  New-Alias ga    Get-Alias
  New-Alias gle   Set-LogEntry
  New-Alias gts   Get-TimeStamp
#endregion


#region Variables

  $KnownFolders = [enum]::GetNames([Environment+SpecialFolder]) | 
		  ForEach-Object { 
			  [psCustomObject]@{ 
				  Name =  $_ 
				  Value = [Environment]::GetFolderPath($_) 
				  Scope = if($_ -in @( 
										  'CommonAdminTools',
										  'CommonApplicationData', 
										  'CommonDesktopDirectory', 
										  'CommonDocuments', 
										  'CommonMusic', 
										  'CommonOemLinks', 
										  'CommonPictures', 
										  'CommonProgramFiles', 
										  'CommonProgramFilesX86', 
										  'CommonPrograms', 
										  'CommonStartMenu', 
										  'CommonStartup', 
										  'CommonTemplates', 
										  'CommonVideos', 
										  'Fonts', 
										  'LocalizedResources', 
										  'MyComputer', 
										  'ProgramFiles', 
										  'ProgramFilesX86', 
										  'Resources', 
										  'System', 
										  'SystemX86', 
										  'Windows' 
									  ) 
							  ) 
								  {'Machine'} 
							  else 
								  {'User'} 
			  } 
		  } | 
      Sort-Object Scope, Name

#endregion

#region Create Drives
#endregion


#region add custom Data types
#endregion add custom Data Types

