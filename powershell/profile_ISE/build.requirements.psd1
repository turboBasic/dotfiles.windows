@{
    # Some defaults for all dependencies
    PSDependOptions = @{
        Target = Split-Path $profile -parent
        AddToPath = $False
    }

    'psake' =            @{ DependencyType = 'psGalleryModule' }
    'psDeploy' =         @{ DependencyType = 'psGalleryModule' }
    'psScriptAnalyzer' = @{ DependencyType = 'psGalleryModule' }
    'BuildHelpers' =     @{ DependencyType = 'psGalleryModule' }
    'Pester' =           @{ DependencyType = 'psGalleryModule'
                            Version        = '4.0.4'           } 
}