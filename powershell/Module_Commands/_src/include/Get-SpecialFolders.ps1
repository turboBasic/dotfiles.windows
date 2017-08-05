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

  $KnownFolders
}
