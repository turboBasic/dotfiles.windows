function is_local($path) {
    ($path -notmatch '^https?://') -and (test-path $path)
}