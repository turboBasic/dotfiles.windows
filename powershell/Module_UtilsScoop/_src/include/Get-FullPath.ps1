Function Get-FullPath( $Path ) { # should be ~ rooted

    $ExecutionContext.SessionState.Path.getUnresolvedProviderPathFromPSPath($Path)

}