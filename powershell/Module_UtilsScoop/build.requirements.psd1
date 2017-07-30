@{
    # Some defaults for all dependencies
    psDependOptions = @{
        Target = Join-Path (Split-Path $profile) Modules
        AddToPath = $True
    }

    'psake' =            @{ DependencyType = 'psGalleryModule' }
    'psDeploy' =         @{ DependencyType = 'psGalleryModule' }
    'psScriptAnalyzer' = @{ DependencyType = 'psGalleryModule' }
    'BuildHelpers' =     @{ DependencyType = 'psGalleryModule' }
 <# 'Pester' =   @{ DependencyType = 'psGalleryModule'
                    Version = '4.0.4'
                  } #>
  # @TODO(Add dependency of Commands.psm1)
}