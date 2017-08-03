

  ConvertFrom-StringData @'
      moduleSuccess     = SUCCESS: {0} loaded
      moduleLoading     = Loading: {0}
      localisation      = Localisation {0} loading...
      moduleFailure     = FAILURE: Sorry, no {0} found...
      exit              = Good-bye!
      errorLocalisation = Language {0} not found, using {1} instead
      welcome           = Entering User profile script... {0}
      globalVarsError   = Global Variables are not set -- {0} not found. Scripts, modules and other stuff may not work
'@