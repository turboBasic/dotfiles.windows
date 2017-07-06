function format($str, $hash) {
    $hash.keys | % { set-variable $_ $hash[$_] }
    $executionContext.invokeCommand.expandString($str)
}