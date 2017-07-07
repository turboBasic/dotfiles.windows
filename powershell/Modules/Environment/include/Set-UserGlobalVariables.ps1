# This is for USER only Global variables!

Function Set-UserGlobalVariables {

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


  #region dot sourcing Expand-HashTableSelfReference function
     
      . ( './Modules/Commands/include/Expand-HashTableSelfReference.ps1' |
                        ForEach { Join-Path (Split-Path $profile -Parent) $_ } )

  #endregion.   Now we can call Expand-HashTableSelfReference ...


  $__assets = @{
    userName          = $ENV:userName
    homeDrive         = $ENV:homeDrive
    projects          = $ENV:projects   
    profileSourcePath = './dotfiles.windows/powershell/Microsoft.PowerShell_profile.ps1'
    githubGist        = '${ENV:githubAPI}/users/${ENV:githubUser}/gists'
    githubGist2       = '${ENV:githubAPI}/users/${ENV:githubUser2})/gists'
    testToken         = '$userName'
  }
  $__assets = $__assets | Expand-HashTableSelfReference 
 
  $vars | ForEach { New-Variable -Name ($_) -Value '' -Scope Global -Force -Option None }  
  
  $Global:__homeDrive =     $__assets.homeDrive            # disk with users' home directories
  $Global:__userName =      if(Test-Path ENV:userName) { $ENV:userName } else { $__assets.userName }
  $Global:__systemBin =     Join-Path $ENV:systemROOT 'system32'
  $Global:__projects =      $ENV:projects
  $Global:__profile =       $profile
  $Global:__profileDir =    Split-Path -parent $profile
  $Global:__profileSource = Join-Path $__projects $__assets.profileSourcePath | Convert-Path
  $Global:__githubUser =    $ENV:githubUser
  $Global:__githubGist =    $__assets.githubGist
  $Global:__githubUser2 =   $ENV:githubUser2
  $Global:__githubGist2 =   $__assets.githubGist2
  
#TODO __gist
  $Global:__gist  = ''
  $Global:__gist  = Get-GistMao  $__githubGist2
  $Global:__gist += Get-GistMao

  $ENV:githubGist = $__githubGist             

  # "SilentlyContinue", "Inquiry", "Stop"
  $Global:VerbosePreference = "Continue"

  $vars | ForEach-Object{ Set-Variable -Name ($_) -Scope Global -Force -Option ReadOnly,AllScope }  
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