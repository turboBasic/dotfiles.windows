function wraptext($text, $width) {
    if(!$width) { $width = $host.ui.rawui.windowsize.width };
    $width -= 1 # be conservative: doesn't seem to print the last char

    $text -split '\r?\n' | % {
        $line = ''
        $_ -split ' ' | % {
            if($line.length -eq 0) { $line = $_ }
            elseif($line.length + $_.length + 1 -le $width) { $line += " $_" }
            else { $lines += ,$line; $line = $_ }
        }
        $lines += ,$line
    }

    $lines -join "`n"
}

