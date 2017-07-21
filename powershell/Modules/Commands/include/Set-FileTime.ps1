Function Set-FileTime {

  PARAM(
    [String[]] $paths,
    [Bool]     $only_modification = $false,
    [Bool]     $only_access = $false
  )

  BEGIN {

    Function updateFileSystemInfo( [System.IO.FileSystemInfo]$fsInfo ) {
      $datetime = Get-Date
      if ( $only_access ) {
         $fsInfo.LastAccessTime = $datetime
      }
      elseif ( $only_modification ) {
         $fsInfo.LastWriteTime = $datetime
      }
      else {
         $fsInfo.CreationTime = $datetime
         $fsInfo.LastWriteTime = $datetime
         $fsInfo.LastAccessTime = $datetime
      }
    }
   
    Function touchExistingFile($arg) {
      if ($arg -is [System.IO.FileSystemInfo]) {
        updateFileSystemInfo($arg)
      }
      else {
        $resolvedPaths = resolve-path $arg
        foreach ($rpath in $resolvedPaths) {
          if (test-path -type Container $rpath) {
            $fsInfo = new-object System.IO.DirectoryInfo($rpath)
          }
          else {
            $fsInfo = new-object System.IO.FileInfo($rpath)
          }
          updateFileSystemInfo($fsInfo)
        }
      }
    }
   
    Function touchNewFile([String]$path) {
      #$null > $path
      Set-Content -Path $path -value $null;
    }

  }
 
  PROCESS {
    if ($_) {
      if (test-path $_) {
        touchExistingFile($_)
      }
      else {
        touchNewFile($_)
      }
    }
  }
 
  END {
    if ($paths) {
      foreach ($path in $paths) {
        if (test-path $path) {
          touchExistingFile($path)
        }
        else {
          touchNewFile($path)
        }
      }
    }
  }

}