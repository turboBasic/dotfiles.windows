Function Get-EnvironmentPath {

  $ENV:Path -split ';'

  #region Creating command 'ppath' for cmd.exe
    $ppath = 'ppath.cmd'
    $Exists = $( Try { 
                    Test-Path (cmd /c where $ppath 2>&1 $null) 
                 } Catch { 
                    $False 
                 }
              )

    if ($Exists) { 
        Write-Verbose 'Get-EnvironmentPath: ppath.cmd already exists'
        return 
    }
   
    $shimPath = 
        "$ENV:scoop\shims", 
        "$ENV:chocolateyInstall\bin", 
        "$ENV:scoop_Global\shims", 
        '$ENV:systemROOT' | 
        Where { Test-Path $_ } | 
        Select -First 1

    if (!$shimPath) {
        Write-Error -Category WriteError -targetObject $shimPath 'You are running Linux!'
        return
    }

    $shimPath += '\ppath.cmd'

    if (!(Test-Path $shimPath)) {
        $command = '@path | sed s/PATH=//;s/;/\n/g && echo.'

        # shim -global -norelative "$PSScriptRoot\ppath.cmd" "ppath"
        New-Item $shimPath -Force | Add-Content -Value $command  
        if(!$?) {
            Write-Error -Category WriteError -targetObject $shimPath "Cannot write to file $shimPath"
            return
        } 
        Write-Verbose 'Get-EnvironmentPath: File $shimPath for cmd.exe created successfully'
    }
  #endregion

}