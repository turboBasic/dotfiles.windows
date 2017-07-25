function pluralize($count, $singular, $plural) {
    if($count -eq 1) { $singular } else { $plural }
}
