$moduleName =    (Get-Item -path $MyInvocation.MyCommand.Path).BaseName
$moduleRoot =    Split-Path -path $MyInvocation.MyCommand.Path -parent

$sourceDir =     '_src/'
$sourceRoot =    Join-Path $moduleRoot $sourceDir
$nestedModules = Join-Path $sourceRoot *.ps1 | Get-ChildItem -recurse


$scriptName_todelete = & { $myInvocation.ScriptName }






#region     Load functions

    $nestedModules | ForEach-Object { . $_ }

#endregion



