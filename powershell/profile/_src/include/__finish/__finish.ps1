#region Clean

  $__clean = @{
      variablesToRemoveFromGlobal = @( 
        '__dotSource', 
        '__includes', 
        '__savedVerbosePreference', 
        '__clean'
      )
      functionsToRemoveFromGlobal = @( 'Main', 'Remove-GlobalVariables' )
  }

  $verbosePreference = $__savedVerbosePreference
  Remove-GlobalVariables  -variables $__clean.variablesToRemoveFromGlobal `
                          -functions $__clean.functionsToRemoveFromGlobal

#endregion