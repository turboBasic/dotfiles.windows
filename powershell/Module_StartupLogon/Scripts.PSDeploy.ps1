$me = (Split-Path $PSScriptRoot -leaf) -replace 'Module_'

$buildDir =       Join-Path $PSScriptRoot   _build
$startupScript =  Join-Path $buildDir        bbro-startup.ps1
$logonScript =    Join-Path $buildDir        bbro-mao-logon.ps1

$destRoot =       Join-Path $ENV:systemROOT  system32/GroupPolicy
$destUser =       Join-Path $destRoot        User/Scripts/Logon
$destMachine =    Join-Path $destRoot        Machine/Scripts/Startup


#region     Elevated mode block 

  #region     If not in Elevated Mode

    $AdministratorRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $CurrentIdentity = [Security.Principal.WindowsPrincipal]( 
          [Security.Principal.WindowsIdentity]::GetCurrent() 
    )
    if( -not $CurrentIdentity.IsInRole($AdministratorRole) ) {
      $params = @{
          filePath =      'Powershell.exe'
          verb =          'RunAs'
          argumentList =  @"
      
              -NoProfile
              -ExecutionPolicy Bypass
              -File "$psCommandPath"
            
"@.         Trim() -replace '\n\s*', ' '

      }

      Write-Warning 'This script will ask for elevated priveleges if run without them'
	    Start-Process @params 
	    Exit 
    }

  #endregion  If not in Elevated Mode

  #region     Switch to elevated mode 

    Deploy AllScripts {
      By Filesystem {
          FromSource $logonScript
          To $destUser
      }

      By Filesystem {
          FromSource $startupScript
          To $destMachine
      }
    }

  #endregion  Switch to elevated mode

#endregion  Elevated mode block 