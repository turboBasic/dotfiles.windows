function unzip($path,$to) {
    if(!(test-path $path)) { abort "can't find $path to unzip"}
    try { add-type -assembly "System.IO.Compression.FileSystem" -ea stop }
    catch { unzip_old $path $to; return } # for .net earlier than 4.5
    try {
        [io.compression.zipfile]::extracttodirectory($path,$to)
    } catch [system.io.pathtoolongexception] {
        # try to fall back to 7zip if path is too long
        if(7zip_installed) {
            extract_7zip $path $to $false
            return
        } else {
            abort "Unzip failed: Windows can't handle the long paths in this zip file.`nRun 'scoop install 7zip' and try again."
        }
    } catch {
        abort "Unzip failed: $_"
    }
}



function script:unzip_old($path,$to) {
    # fallback for .net earlier than 4.5
    $shell = (new-object -com shell.application -strict)
    $zipfiles = $shell.namespace("$path").items()
    $to = ensure $to
    $shell.namespace("$to").copyHere($zipfiles, 4) # 4 = don't show progress dialog
}