function strip_path($orig_path, $dir) {
    $stripped = [string]::join(';', @( $orig_path.split(';') | ? { $_ -and $_ -ne $dir } ))
    return ($stripped -ne $orig_path), $stripped
}
