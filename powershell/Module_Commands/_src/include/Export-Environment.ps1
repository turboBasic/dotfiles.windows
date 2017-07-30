$environment = @{
    alias =     @{}
    env =       @{}
    function =  @{}
    variable =  @{}
}

$environment.data = @{
    alias =     'Name', 'Visibility', 'ResolvedCommand', 'Options'
    env =       'Name', 'Value' 
    function =  'Name', 'Visibility', 'ModuleName'
    variable =  'Name', 'Visibility', 'Value', 'Options'
}


foreach( $key in [Array]$environment.Keys ) {
    $environment.$key = Get-ChildItem -path "${key}:"
}

$environment