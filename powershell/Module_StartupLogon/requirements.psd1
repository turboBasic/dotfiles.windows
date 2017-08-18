@{
    
    StartupLogonLogFolderExists =  @{
        DependencyType =  'Command'
        Version =         'any'
        Target =          '$ENV:systemROOT\System32\LogFiles\Startup, Shutdown, Logon scripts'
    }
    Pester =    @{ Version ='4.0.5' }
    Psake =     @{ Version = 'latest'}
    PSDeploy =  @{ Version = 'latest'}
    #'BuildHelpers' = @{ DependencyType = 'PSGalleryModule' }
}