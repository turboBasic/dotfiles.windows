function New-LogFolder {

    PARAM(
        [PARAMETER( Position=0 )]
        [string]
        $Dir = "$ENV:systemROOT\System32\LogFiles\Startup, Shutdown, Logon scripts",

        [PARAMETER( Position=1 )]
        [string]  
        $File = (Join-Path $Dir StartupLogon.log)
    )

    
    if( -not (Test-Path $Dir) ) {
        sudo New-Item -path $Dir -itemType Directory -force
    } 
    sudo Add-NTFSaccess -path $Dir -account S-1-5-32-555, S-1-5-32-547 -accessRights Modify -accessType Allow
    
}
