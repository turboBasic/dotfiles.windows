function reset_alias($name, $value) {
    if($existing = get-alias $name -ea ignore |? { $_.options -match 'readonly' }) {
        if($existing.definition -ne $value) {
            write-host "Alias $name is read-only; can't reset it." -f darkyellow
        }
        return # already set
    }
    if($value -is [scriptblock]) {
        new-item -path function: -name "script:$name" -value $value | out-null
        return
    }

    set-alias $name $value -scope script -option allscope
}

