function smartShorten([string]$source, [int32]$width, [int32]$left) {

    if($source.length -le $width) {
        return $source
    } else {
        return $source.substring(0, $left) + 
                " ... " +
                $source.substring($source.length - ($width-$left-5), $width-$left-5)
    }

} 