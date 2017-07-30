#region add custom Data types
#endregion add custom Data Types


#region initialization of module
  # We do not dot source the individual scripts because loadin of subscripts
  # is executed automatically using `NestedModules` parameter in Commands.psd1

  # Write-Host -ForegroundColor Green "Module $(Split-Path $PSScriptRoot -Leaf) was successfully loaded."
#endregion


#region shortcut functions (only for saving typing and keyboards)
#endregion


#region Create aliases for functions
#endregion


#region Create Drives
#endregion


# This is for USER only Global variables!

Function Set-UserGlobalVariables {

  $Global:VerbosePreference = Continue  # SilentlyContinue, Inquiry, Stop

  $vars = @(
    '__gist',
    '__githubGist', 
    '__githubGist2',
    '__githubUser',
    '__githubUser2',
    '__homeDrive',
    '__profile',    
    '__profileDir',
    '__profileSource',
    '__projects',
    '__systemBin',
    '__userName'
  )       

  $__assets = @{
    userName          = $ENV:userName
    homeDrive         = $ENV:homeDrive
    projects          = $ENV:projects   
    profileSourcePath = 
        './dotfiles.windows/powershell/Microsoft.PowerShell_profile.ps1'
    githubGist        = $ENV:githubGist
    githubGist2       = $ENV:githubGist2
  }
 
  $vars | ForEach-Object { 
      New-Variable -name ($_) -value '' -scope Global -force -option None 
  }

  
  # disk with users' home directories
  $Global:__homeDrive =     $__assets.homeDrive  
  $Global:__userName =      if(Test-Path ENV:userName) 
                                { $ENV:userName } 
                            else 
                                { $__assets.userName }
                                
  $Global:__systemBin =     Join-Path $ENV:systemROOT system32
  $Global:__projects =      $ENV:projects
  $Global:__profile =       $profile
  $Global:__profileDir =    Split-Path -parent $profile
  $Global:__profileSource = 
      Join-Path $Global:__projects $__assets.profileSourcePath | Convert-Path

  $Global:__githubUser =    $ENV:githubUser
  $Global:__githubGist =    $ENV:githubGist
  $Global:__githubUser2 =   $ENV:githubUser2
  $Global:__githubGist2 =   $ENV:githubGist2
  
  $Global:__gist  = Try {
                        Get-GistMao $__githubGist2
                    } Catch {
                        Write-Warning "Cannot connect to $__githubGist2"
                        ''
                    }
  $Global:__gist += Try {
                        Get-GistMao
                    } Catch {
                        Write-Warning "Cannot connect to $__githubGist"
                        ''
                    }         

  $vars | ForEach-Object { 
      Set-Variable -name ($_) -scope Global -force -option ReadOnly,AllScope 
  }  
}


<#    Determine invocation method of current script:
          .  DRIVE:\path\Set-UserGlobalVariables.ps1
  or    
          &  DRIVE:\path\Set-UserGlobalVariables.ps1
  or    
             DRIVE:\path\Set-UserGlobalVariables.ps1

see https://poshoholic.com/2008/03/18/powershell-deep-dive-using-myinvocation-and-invoke-expression-to-support-dot-sourcing-and-direct-invocation-in-shared-powershell-scripts/


          if ($MyInvocation.InvocationName -eq '&') {
              'Called using operator'
          } elseif ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq '') {
              'Dot sourced'
          } elseif ((Resolve-Path -Path $MyInvocation.InvocationName).ProviderPath -eq $MyInvocation.MyCommand.Path) {
              "Called using path $($MyInvocation.InvocationName)"
          }

#>

if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.Line -ne '') {
    Invoke-Expression @"
      Set-UserGlobalVariables $(
        $passThruArgs = $Args
        foreach ($argument in $passThruArgs) {
          if ($argument.StartsWith('-')) { 
              $argument 
          } else {
              "$argument"
          }
        }
      )
"@
}

