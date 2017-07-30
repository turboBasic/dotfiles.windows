function Format-ModuleManifest {
    [cmdletBinding()]
    [outputType( [void] )]
    PARAM(
      [parameter( Mandatory, Position=0 )]
      [validateScript({ Test-Path $_ -pathType Leaf })]
      [string]$path
    )

    
    $path = Resolve-Path $path
    $manifest = Import-PowerShellDataFile -path $path

    
    #region Prepare standard module manifest 
    
        $manifest.FunctionsToExport = $manifest.FunctionsToExport | 
                ForEach-Object { $_ }
                
        $manifest.NestedModules =     $manifest.NestedModules | 
                ForEach-Object { $_ }
                
        $manifest.RequiredModules =   $manifest.RequiredModules | 
                ForEach-Object { $_ }
                
        $manifest.ModuleList =        $manifest.ModuleList | 
                ForEach-Object { $_ }
        
        if( $manifest.ContainsKey('PrivateData') -and 
            $manifest.PrivateData.ContainsKey('PSData') ) {
          foreach ($node in $manifest.PrivateData['PSData'].GetEnumerator()) {
            $key = $node.Key
            if ($node.Value.GetType().Name -eq 'Object[]') {
              $value = $node.Value | ForEach-Object { $_ }
            }
            else {
              $value = $node.Value    
            }
            $manifest[$key] = $value
          }
          $manifest.Remove('PrivateData')
        }
    
    #endregion

    
    #region Copy properties with formatting bug and apply correct indentation
        $new = @{}
        'NestedModules', 'FileList' | ForEach-Object {
            $count = Try { $manifest.$_.count } Catch { 0 }
            
            if( $count -gt 0 ) { 
              $new.$_ = ( 
                  ( $manifest.$_ | ForEach-Object { "'$_'" } ) -join ",`n" 
              )
              $new.$_ = "$_ = @(
                  $( $new.$_ ) `n)" -replace "(?m)^\s*(?=')", "    "
            } else {
              $new.$_ = "$_ = @()"
            }
        }
    #endregion
    
    
    #region Write module with empty problem properties to simplify replacement
        $manifest.NestedModules = $manifest.FileList = @()
        New-ModuleManifest -path $path @manifest
    #endregion
    
    
    #region Replace properties with correctly formatted values
        $text = [IO.File]::ReadAllText($path).
            Replace( 'NestedModules = @()', $new.NestedModules ).
            Replace( 'FileList = @()', $new.FileList )
        [IO.File]::WriteAllText($path, $text)
    #endregion
}


<#    Determine invocation method of current script:
          .  DRIVE:\path\Set-UserGlobalVariables.ps1
  or    
          &  DRIVE:\path\Set-UserGlobalVariables.ps1
  or    
             DRIVE:\path\Set-UserGlobalVariables.ps1

see https://poshoholic.com/2008/03/18/powershell-deep-dive-using-myinvocation-and-invoke-expression-to-support-dot-sourcing-and-direct-invocation-in-shared-powershell-scripts/

          if ($MyInvocation.InvocationName -eq '&') {
              'Called using operator'
          } elseif ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '') {
              'Dot sourced'
          } elseif ((Resolve-Path -Path $MyInvocation.InvocationName -errorAction SilentlyContinue).ProviderPath -eq $MyInvocation.MyCommand.Path) {
              "Called using path $($MyInvocation.InvocationName)"
          }

#>


#Write-Verbose $MyInvocation.InvocationName
#Write-Verbose $MyInvocation.Line.Trim()
#Write-Verbose $MyInvocation.MyCommand.Path

  
if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.Line -ne '') {
    Invoke-Expression @"
      Format-ModuleManifest $(
        $passThruArgs = $Args
        foreach ($argument in $passThruArgs) {
          if ($argument.StartsWith('-')) { 
              $argument 
          } else {
              "$argument"
          }
        }
      )
"@
}

