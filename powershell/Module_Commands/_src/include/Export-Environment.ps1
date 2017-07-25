$environment = @{
    alias =     @{}
    env =       @{}
    function =  @{}
    variable =  @{}
}

$environment.data = @{
    alias =     'Name', 'ResolvedCommand', , 'Options'
    env =       'Name', 'Value', 'Visibility'
    function =  'Name', 'ModuleName', 'Visibility'
    variable =  'Name', 'Value', 'Visibility', 'Options'
}


foreach( $key in [Array]$environment.Keys ) {
    $environment.$key = Get-ChildItem "${key}:/"
}