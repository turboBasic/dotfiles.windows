
# for dealing with user aliases
$default_aliases = @{
    'cp' = 'copy-item'
    'echo' = 'write-output'
    'gc' = 'get-content'
    'gci' = 'get-childitem'
    'gcm' = 'get-command'
    'gm' = 'get-member'
    'iex' = 'invoke-expression'
    'ls' = 'get-childitem'
    'mkdir' = { new-item -type directory @args }
    'mv' = 'move-item'
    'rm' = 'remove-item'
    'sc' = 'set-content'
    'select' = 'select-object'
    'sls' = 'select-string'
}




function reset_aliases() {
    # for aliases where there's a local function, re-alias so the function takes precedence
    $aliases = get-alias |? { $_.options -notmatch 'readonly|allscope' } |% { $_.name }
    get-childitem function: | % {
        $fn = $_.name
        if($aliases -contains $fn) {
            set-alias $fn local:$fn -scope script
        }
    }

    # set default aliases
    $default_aliases.keys | % { reset_alias $_ $default_aliases[$_] }
}