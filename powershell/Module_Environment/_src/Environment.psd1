#
# Module manifest for module 'Environment'
#
# Generated by: Andriy Melnyk
#
# Generated on: 02.08.2017
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Environment.psm1'

# Version number of this module.
ModuleVersion = '1.0.38'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '59aa5901-f7fa-4f03-b0db-b6156cb3807a'

# Author of this module
Author = 'Andriy Melnyk'

# Company or vendor of this module
CompanyName = 'Cargonautica'

# Copyright statement for this module
Copyright = 'Andriy Melnyk, 2017'

# Description of the functionality provided by this module
Description = 'Utilities to manage Environment variables. Support variable expansion, User and Machine scopes'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = '1.0'

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
DotNetFrameworkVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
CLRVersion = '2.0'

# Processor architecture (None, X86, Amd64) required by this module
ProcessorArchitecture = 'None'

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = 'include/Add-EnvironmentScopeType.ps1'

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
    'include/Add-EnvironmentScopeType.ps1',
    'include/Export-Environment.ps1',
    'include/Get-Environment.ps1',
    'include/Get-EnvironmentKey.ps1',
    'include/Get-EnvironmentTable.ps1',
    'include/Get-ExpandedName.ps1',
    'include/Import-Environment.ps1',
    'include/Remove-EnvironmentVariable.ps1',
    'include/Remove-UnprotectedVariables.ps1',
    'include/Send-EnvironmentChanges.ps1',
    'include/Set-Environment.ps1' 
)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = '*'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @(
    'Environment.psd1',
    'Environment.psm1',
    'include/Add-EnvironmentScopeType.ps1',
    'include/Export-Environment.ps1',
    'include/Get-Environment.ps1',
    'include/Get-EnvironmentKey.ps1',
    'include/Get-EnvironmentTable.ps1',
    'include/Get-ExpandedName.ps1',
    'include/Import-Environment.ps1',
    'include/Remove-EnvironmentVariable.ps1',
    'include/Remove-UnprotectedVariables.ps1',
    'include/Send-EnvironmentChanges.ps1',
    'include/Set-Environment.ps1' 
)

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'GitHub', 'Gist', 'REST', 'OAuth', 'Environment'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/TurboBasic/dotfiles.windows/tree/master/powershell/Module_Environment'

        # A URL to an icon representing this module.
        IconUri = 'https://gist.githubusercontent.com/turboBasic/9dfd228781a46c7b7076ec56bc40d5ab/raw/03942052ba28c4dc483efcd0ebf4bfc6809ed0d0/hexagram3D.png'

        # ReleaseNotes of this module
        ReleaseNotes = 'None'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

