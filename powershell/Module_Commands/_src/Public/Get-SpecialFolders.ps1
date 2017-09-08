Function Get-SpecialFolders {
  <#
  $SpecialFolders = 
    New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string]'
    
  [Environment+SpecialFolder].GetEnumNames() | 
      Sort | 
      ForEach-Object { 
        $SpecialFolders.Add( $_, [Environment]::GetFolderPath($_) ) 
      }

  $SpecialFolders
  #>

  # $knownFolders

$machineScopeFolders = @( 
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


  [Enum]::GetNames( [Environment+SpecialFolder] ) | 
    ForEach-Object { 
        [PSCustomObject] @{ 
            Name =  $_ 
            Value = [Environment]::GetFolderPath($_) 
            Scope = if( $_ -in $machineScopeFolders )
                        { 'Machine' } 
                    else 
                        { 'User' } 
        } 
    } | 
    Sort-Object Scope, Name

}
