@{
    # Some defaults for all dependencies
    PSDependOptions = @{
        Target = '$ENV:userPROFILE\Documents\WindowsPowerShell\Modules'
        AddToPath = $True
    }

    'psake' =            @{ DependencyType = 'psGalleryModule' }
    'psDeploy' =         @{ DependencyType = 'psGalleryModule' }
    'psScriptAnalyzer' = @{ DependencyType = 'psGalleryModule' }
 <# 'Pester' =   @{ DependencyType = 'psGalleryModule'
                    Version = '4.0.4'
                  } #>
  # @TODO(Add dependency of Commands.psm1)
}