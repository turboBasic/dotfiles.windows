function Main {

  #region constants
    $savedVerbosePreference = $verbosePreference
    $verbosePreference = 'Continue'
    $includes = Join-Path $psScriptRoot 'profile_ISE/include/*.ps1'
  #endregion

  $verbosePreference = $savedVerbosePreference
}



function Remove {
  PARAM(
    [string[]]
    $variables=$null,

    [string[]]
    $functions=$null
  )

  $variables | 
    Where-Object { $_ -ne $Null } |
    ForEach-Object {
      Remove-Variable -Scope Global -Name $_ -ErrorAction SilentlyContinue
    }

  $functions | 
    Where-Object { $_ -ne $Null } |
    ForEach-Object {
      Remove-item -Path FUNCTION:$_ -Scope Global -ErrorAction SilentlyContinue
    }
}


function Get-Initial {
  @{
      includes = ( Join-Path $psScriptRoot 'profile_console/include/*.ps1' )   
      variablesToRemoveFromGlobal = @( 'dotSource' )
      functionsToRemoveFromGlobal = @( 'Get-Initial', 'Main', 'Remove' )
  }
}


$dotSource = {
  PARAM(
    [PARAMETER( Mandatory )]
    [string[]]
    $path
  )

  Get-ChildItem -path $path -ErrorAction SilentlyContinue |
    ForEach-Object { 
      Write-Verbose "dot sourcing file $( $_.FullName )"
      #. $_ 
    }

}

#region Execution

$__init = Get-Initial

. $dotSource -path $__init.includes



Main
Remove -variables $__init.variablesToRemoveFromGlobal

#endregion