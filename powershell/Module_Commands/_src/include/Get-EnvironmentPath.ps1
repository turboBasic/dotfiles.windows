Function Get-EnvironmentPath {

  $ENV:Path -split ';'

  #region Creating command 'ppath' for cmd.exe
  
    $ppath = 'ppath.cmd'
    $Exists = $( 
        Try   { Test-Path (cmd /c 'where' $ppath 2>&1 $null) } 
        Catch { $False }
    )

    if( $Exists ) { 
      Write-Verbose 'Get-EnvironmentPath: ppath.cmd already exists'
      return 
    }
   
    $shimPath = 
        "$ENV:scoop\shims", 
        "$ENV:chocolateyInstall\bin", 
        "$ENV:scoop_Global\shims", 
        '$ENV:systemROOT' | 
        Where { Test-Path $_ } | 
        Select-Object -First 1

    if( !$shimPath ) {
      " `n `nYou are probably running Linux!`n " | 
          Write-Error -Category WriteError -targetObject $shimPath 
      return
    }

    $shimPath = Join-Path $shimPath $ppath

    if( !(Test-Path $shimPath) ) {
    
        
        
        $command = @'
      
@powershell.exe -NoLogo 
                -NoProfile 
                -ExecutionPolicy Bypass 
                -Command "  $ENV:PATH -split ';'  "
                
'@.         Trim() -replace '\s+', ' '

        # $command = '@path | sed s/PATH=//;s/;/\n/g && echo.'
        # shim -global -norelative "$PSScriptRoot\ppath.cmd" "ppath"
        New-Item $shimPath -Force | Add-Content -Value $command 
        
        if( !$? ) {
          " `n `nCannot write to file $shimPath `n `n" |
              Write-Error -Category WriteError -targetObject $shimPath 
          return
        } 
        
        "Get-EnvironmentPath: File $shimPath for cmd.exe created successfully" |
            Write-Verbose 
    }
    
  #endregion

}