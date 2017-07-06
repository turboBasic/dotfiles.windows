
Function Set-GlobalVariables {

$vars = '__homeDrive','__userName','__systemBin','__projects','__profile',    
        '__profileDir','__profileSource','__githubUser','__githubGist', 
        '__githubUser2','__githubGist2','__gist'       

  #region Expand-HashTableSelfReference function

      <# 
          ¡¡¡ THIS FUNCTION IS LEFT HERE NOT BY MISTAKE, BUT INTENTIONALLY IN ORDER 
          TO AVOID DEPENDECY ON OTHER MODULES DURING PROFILE LOADING !!!
      #>
        
      Function Expand-HashTableSelfReference {

        [CMDLETBINDING()] PARAM( 
            [PARAMETER( ValueFromPipeline = $true )] 
                [HashTable]
                    $hTable 
        )

        $res = @{}
        $hTable.Keys | ForEach-Object { Set-Variable -Scope Local -Name $_ -Value $hTable[$_] }
        $hTable.Keys | ForEach-Object { 
            $tmp = $hTable[$_]
            # This is less reliable as needs synchronisation waiting:
               $value = $ExecutionContext.InvokeCommand.ExpandString($hTable[$_])
            #$value = "@`"`n$tmp`n`"@" | iex
            $res.Add( $_, $value ) 
          }
        $res
      }
  #endregion


  $__assets = @{
    userName          = 'mao'
    homeDrive         = 'C:'
    projects          = 'E:\0projects'
    profileSourcePath = './dotfiles.windows/powershell/Microsoft.PowerShell_profile.ps1'
    githubUser        = 'TurboBasic'
    githubUser2       = 'maoizm'
    githubApi         = 'https://api.github.com'
    githubGist        = '$($__assets.githubApi)/users/$($__assets.githubUser)/gists'
    githubGist2       = '$($__assets.githubApi)/users/$($__assets.githubUser2)/gists'
    testToken         = '$userName'
  }
  $__assets = $__assets | Expand-HashTableSelfReference 
 
  $vars | ForEach-Object{ New-Variable -Name ($_) -Value '' -Scope Global -Force -Option None}  
  
  $Global:__homeDrive =     $__assets.homeDrive            # disk with users' home directories
  $Global:__userName =      if(Test-Path ENV:userName) { $ENV:userName } else { $__assets.userName }
  $Global:__systemBin =     Join-Path $ENV:systemROOT 'system32'
  $Global:__projects =      $ENV:projects, $__assets.projects | Where-Object { $_ } | Where-Object { Test-Path $_ } | Select -First 1 | Convert-Path
  $Global:__profile =       $profile
  $Global:__profileDir =    Split-Path -parent $profile
  $Global:__profileSource = Join-Path $__projects $__assets.profileSourcePath | Convert-Path
  $Global:__githubUser =    $__assets.githubUser
  $Global:__githubGist =    $__assets.githubGist
  $Global:__githubUser2 =   $__assets.githubUser2
  $Global:__githubGist2 =   $__assets.githubGist2
  
#TODO __gist
  $Global:__gist  = ''
  $Global:__gist  = Get-GistMao  $__githubGist2
  $Global:__gist += Get-GistMao

  $ENV:githubUser = $__githubUser 
  $ENV:githubGist = $__githubGist             

  # "SilentlyContinue", "Inquiry", "Stop"
  $Global:VerbosePreference = "Continue"

  $vars | ForEach-Object{ Set-Variable -Name ($_) -Scope Global -Force -Option ReadOnly,AllScope }  
}

