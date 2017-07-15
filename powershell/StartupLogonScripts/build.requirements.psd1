@{
    # Some defaults for all dependencies
    PSDependOptions = @{
        Target = '$ENV:USERPROFILE\Documents\WindowsPowerShell\Modules'
        AddToPath = $True
    }

    # Grab some modules without depending on PowerShellGet
    'psake' = @{ DependencyType = 'PSGalleryModule' }
    'PSDeploy' = @{ DependencyType = 'PSGalleryModule' }
    'BuildHelpers' = @{ DependencyType = 'PSGalleryModule' }
    'Pester' = @{
        DependencyType = 'PSGalleryModule'
        Version = '3.4.6'
        #DependencyType = 'FileDownload'
        #Source = 'https://github.com/pester/Pester/archive/4.0.3-rc.zip'
    }
}