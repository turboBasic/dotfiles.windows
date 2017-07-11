  # TODO: Generalize parameters

  Function Import-UserModules {
    $modules = @{
      'Vendor module Chocolatey' = "$ENV:ChocolateyInstall/helpers/chocolateyProfile.psm1"
      'User module Commands'     = "$__profileDir/Modules/Commands"
      'User module Environment'  = "$__profileDir/Modules/Environment"
      'User module UtilsScoop'   = "$__profileDir/Modules/UtilsScoop"
      'User module Test'         = "$__profileDir/Modules/Test"
    }

    $modules.Keys | ForEach-Object {
      if(-Not( Test-Path ($m = $modules.$_) )) {
        $m = Split-Path -Leaf $m
      }

      $__messages.moduleLoading -f $_ | Write-Verbose
      Import-Module $m -Force
      $( if   ($?) { $__messages.moduleSuccess }
         else      { $__messages.moduleFailure } ) -f $_ | Write-Verbose
    }

  }
