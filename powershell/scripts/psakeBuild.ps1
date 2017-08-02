properties {
  $scripts = Get-ChildItem -path $sourceROOT\*.ps1
  $simpleTestFiles = Get-ChildItem -path (
                          Join-Path $psScriptRoot _test\Test-*
                     ) -file -errorAction SilentlyContinue
}

  
task default -depends Analyze, Deploy


task Deploy -description 'Deploys module to run-time location' 
{
    Invoke-PSDeploy -path (
        Join-Path $psScriptRoot Script.PSDeploy.ps1
    ) -force -verbose:$VerbosePreference
}


task Clean -description 'Helper to clean build artifacts' {}


task Bump -description 'Bumps build version of script' {}


task SimpleTest -description 'Helper to run ad-hoc tests from _test\Test-...' 
{
  $simpleTestFiles | Foreach-Object { & $_ } 
}


task Analyze 
{
  foreach( $file in $scripts.FullName ) 
  {
    $saResults =  Invoke-ScriptAnalyzer -path $file -severity @(
                      'Error','Warning'
                  ) -recurse -verbose:$False
                  
    if( $saResults ) 
    {
      $saResults | Format-Table  
      'One or more Script Analyzer errors/warnings where found. 
      Build cannot continue!' -replace '\n\s*',' ' | Write-Error      
    }
  }
}


task Test -description 'Helper to run Pester tests'  
{
    $testResults = Invoke-Pester -path $psScriptRoot -passThru
    if( $testResults.FailedCount -gt 0 ) 
    {
      $testResults | Format-List
      'One or more Pester tests failed. Build cannot continue!' | Write-Error
    }
}
