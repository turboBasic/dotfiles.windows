function sanitary_path($path) { return [regex]::replace($path, "[/\\?:*<>|]", "") }
