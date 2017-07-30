<#
    .SYNOPSIS
        Deploy using Robocopy or Copy-Item for folder and file deployments, respectively.

    .DESCRIPTION
        Deploy using Robocopy or Copy-Item for folder and file deployments, respectively.

        Runs in the current session (i.e. as the current user)

    .PARAMETER Deployment
        Deployment to run

    .PARAMETER Mirror
        If specified and the source is a folder, we effectively call robocopy /MIR (Can remove folders/files...)
#>
[CMDLETBINDING()]
PARAM(
    [ValidateScript({ $_.PSObject.TypeNames[0] -eq 'PSDeploy.Deployment' })]
    [psObject[]]$Deployment,
)

Write-Verbose "Starting local merge deployment with $($Deployment.count) sources"

#Local Deployment. Duplicate code. Sigh.
foreach($Map in $Deployment) {
    if($Map.SourceExists) {
        $Targets = $Map.Targets
        foreach($Target in $Targets) {
            if($Map.SourceType -eq 'Directory') {
                # Resolve PSDrives.
                $Target = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Target)
                
                Write-Verbose "Merging all files in $( $Map.Source ) to $Target"
                
                Get-ChildItem $Map.Source -Recurse | 
                    ForEach-Object { 
                        Get-Content $_
                        Out-File $Target -Append
                    }
            }
            else {
                Write-Verbose "Add file '$($Map.Source)' to '$Target'"
                Try {
                    Add-Content -Value (Get-Content $Map.Source) -Path $Target -Force
                }
                Catch [System.IO.IOException], [System.IO.DirectoryNotFoundException] {
                    Write-Verbose "Cannot write to $Target"
                }
            }
        }
    }
}