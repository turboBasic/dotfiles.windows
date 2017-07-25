
Function remove_from_path( $dir, $global ) {
    $dir = Get-FullPath $dir

    # future sessions
    $was_in_path, $newpath = strip_path (env 'path' $global) $dir
    if($Was_In_Path) {
        echo "Removing $(friendly_path $dir) from your path."
        env 'path' $global $newpath
    }

    # current session
    $was_in_path, $newpath = strip_path $env:path $dir
    if($was_in_path) { $env:path = $newpath }
}



