properties {
  $me   =          (Split-Path -path $PSScriptRoot -leaf) -replace 'Module_'
  $sourceDir =     '_src/'

  $sourceRoot =    Join-Path $PSScriptRoot $sourceDir
  $manifest =      Join-Path $sourceRoot "${me}.psd1"
  $nestedModules = Join-Path $sourceRoot *.ps1 | Get-ChildItem -recurse | Select -expandProperty FullName
  $privateDir =    Join-Path $sourceRoot private
}

function Get-FunctionsToExport {
    $functionNamePattern = '(?x) ^\s* FUNCTION \s+ (?<fname> [-\w]+) \s* (?<args> \( [^()]* \) )? \s* \{?'

    $functions = Get-Item $nestedModules |
                    Where-Object { $_.FullName.IndexOf($privateDir) -eq -1 } |
                    Get-Content | 
                    ForEach-Object { 
                        if( $_ -match $functionNamePattern ) {
                            $matches['fname']
                        } 
                    }
    return $functions
}



task default -depends Analyze, Test

task InitializeManifest {
  #Assert (Test-Path $buildDir) "
    Push-Location $sourceRoot
    $params = @{
        Path =              "${me}.psd1" 
        RootModule =        $rootModule        ModuleVersion =     '0.1.0'        NestedModules =     $nestedModules | Resolve-Path -relative        FunctionsToExport = Get-FunctionsToExport
        CmdletsToExport =   ''        Guid =              '4871248c-f225-4f2b-9eec-d5203ddf822b'        Author =            'Andriy Melnyk @turboBasic'
        CompanyName =       'Cargonautica'        Description =       'This module provides text processing utilities'        PowerShellVersion = '3.0' 
        ClrVersion =        '4.0'
        Copyright =         '2017 Andriy Melnyk @turboBasic https://github.com/turboBasic'
        PrivateData = @{
            PSData = @{
                # Tags applied to this module. These help with module discovery in online galleries.
                Tags = 'GitHub', 'Gist', 'Regex', 'Text'

                # A URL to the license for this module.
                # LicenseUri = ''

                # A URL to the main website for this project.
                ProjectUri = 'https://github.com/turboBasic/dotfiles.windows/tree/master/powershell/Module_Commands'                # A URL to an icon representing this module.
                IconUri = 'https://gist.githubusercontent.com/turboBasic/9dfd228781a46c7b7076ec56bc40d5ab/raw/03942052ba28c4dc483efcd0ebf4bfc6809ed0d0/hexagram3D.png'
                # ReleaseNotes of this module
                ReleaseNotes = 'None'
            }
        }
    }
    New-ModuleManifest @params
    Pop-Location

}

task Build -depends Test 

task Analyze {
    $saResults = Invoke-ScriptAnalyzer -path $script -severity 'Error','Warning' -recurse -verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        'One or more Script Analyzer errors/warnings where found. Build cannot continue!' | Write-Error         
    }
}

task Test {
    $testResults = Invoke-Pester -path $PSScriptRoot -passThru
    if( $testResults.FailedCount -gt 0 ) {
        $testResults | Format-List
        'One or more Pester tests failed. Build cannot continue!' | Write-Error 
    }
}


#
# task option: 
#     -precondition <scriptblock>, eg: -precondition { return Test-Path $testsDirectory }
#     -requiredVariable <buildLocation>, eg: -requiredVariable testResultsDirectory

# this script is usually invoked as follows:
# Invoke-Psake -buildFile build.Psake.ps1 -taskList Analyze
# exit ( [int]( -not $psake.build_success ) )