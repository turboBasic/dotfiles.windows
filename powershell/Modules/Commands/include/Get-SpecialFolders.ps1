Function Get-SpecialFolders {
    $SpecialFolders = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,string]'
    [Environment+SpecialFolder].GetEnumNames() | 
          Sort | 
          ForEach { $SpecialFolders.Add($_, [Environment]::GetFolderPath($_)) }

    return $SpecialFolders
}
