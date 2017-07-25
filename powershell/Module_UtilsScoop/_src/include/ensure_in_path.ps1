
function ensure_in_path($dir, $global) {
    $path = env 'path' $global
    $dir = Get-FullPath $dir
    if($path -notmatch [regex]::escape($dir)) {
        echo "Adding $(friendly_path $dir) to $(if($global){'global'}else{'your'}) path."

        env 'path' $global "$dir;$path" # for future sessions...
        $env:path = "$dir;$env:path" # for this session
    }
}

