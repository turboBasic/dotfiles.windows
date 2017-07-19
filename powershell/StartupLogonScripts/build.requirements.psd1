@{
    # Some defaults for all dependencies
    PSDependOptions = @{
        Target = '$ENV:userPROFILE\Documents\WindowsPowerShell\Modules'
        AddToPath = $True
    }

    'psake' = @{ DependencyType = 'PSGalleryModule' }
    'PSDeploy' = @{ DependencyType = 'PSGalleryModule' }
    'BuildHelpers' = @{ DependencyType = 'PSGalleryModule' }
    'Pester' = @{
        DependencyType = 'PSGalleryModule'
        Version = '4.0.4'
    }
}