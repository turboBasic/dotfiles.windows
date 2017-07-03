Function Get-SpecialFolders() {
    $SpecialFolders = @{}
    $names = [Environment+SpecialFolder]::GetNames( [Environment+SpecialFolder] )

    foreach($name in $names) {
      if($path = [Environment]::GetFolderPath($name)) {
        $SpecialFolders[$name] = $path
      }
    }

    return $SpecialFolders.GetEnumerator() | Sort -Property Name
}