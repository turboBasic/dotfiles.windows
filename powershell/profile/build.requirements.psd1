@{
    # Some defaults for all dependencies
    #psDependOptions = @{
    #    Target = "~\Documents\WindowsPowerShell"
    #    AddToPath = $False
    #}

    psake = @{ 
        DependencyType = 'psGalleryModule' 
        Version =        'latest'
    }
    psDeploy = @{ 
        DependencyType = 'psGalleryModule' 
        Version =        'latest'
    }
    psScriptAnalyzer = @{ 
        DependencyType = 'psGalleryModule' 
        Version =        'latest'
    }
    BuildHelpers = @{ 
        DependencyType = 'psGalleryModule' 
        Version =        'latest'
    }
    Pester = @{ 
        DependencyType = 'psGalleryModule'
        Version        = '4.0.4'           
    } 
}