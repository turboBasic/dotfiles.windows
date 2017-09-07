#region initialization of module

  # We do not dot source the individual scripts because loadin of subscripts
  # is executed automatically using `NestedModules` parameter in Commands.psd1

  # Write-Host -ForegroundColor Green "Module $(Split-Path $PSScriptRoot -Leaf) was successfully loaded."

#endregion


#region Variables

  $knownFolders = [enum]::GetNames([Environment+SpecialFolder]) | 
		  ForEach-Object { 
			  [PSCustomObject]@{ 
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


#region private functions

#endregion



# Get public and private function definition files.
    $Public  = @( Get-ChildItem -path $PSScriptRoot\Public\*.ps1 -errorAction SilentlyContinue )
    $Private = @( Get-ChildItem -path $PSScriptRoot\Private\*.ps1 -errorAction SilentlyContinue )


# dot source the files
    foreach( $import in @($Public + $Private) )   {
        Try {
            . $import.fullName
        }
        Catch {
            Write-Error -message "Failed to import function $($import.fullName): $_"
        }
    }


# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only
Export-ModuleMember -function $Public.Basename -variable knownFolders





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

