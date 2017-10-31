#region initialization of module

  $aliases = @{
    'Set-FileTime' =        'touch'
    'Get-EnvironmentPath' = 'ppath'
    'Get-EnumInformation' = 'gei'
    'Get-GuiHelp' =         'gg'   
    'Get-HelpWindow' =      'gh'   
    'Get-Help' =            'ghc'  
    'Get-SpecialFolders' =  'Get-KnownFolders', 'gsf', 'gkf'      
    'Get-Alias' =           'ga'   
    'Set-LogEntry' =        'gle'  
    'Get-TimeStamp' =       'gts'  
  }

#endregion


#region exported variables

  $knownFolders = @{}

#

#region Create Drives
#endregion


#region add custom Data types
#endregion add custom Data Types


# Get public and private function definition files
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


# create aliases
$functions = $aliases.Keys

foreach( $function in $functions) {

  foreach($alias in $aliases[$function]) {
    New-Alias -name $alias -value $function
  }
}


# initialise  variables
$knownFolders = Get-SpecialFolders


# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only
Export-ModuleMember -function $Public.Basename `
                    -variable knownFolders `
                    -alias    ( $aliases.values | 
                                    ForEach-Object{ $_ | 
                                        ForEach-Object{ $_ } 
                                    }
                              )
