@{
  # Script module or binary module file associated with this manifest
  RootModule = './Commands.psm1'

  # Version number of this module.
  ModuleVersion = '1.1.1'

  # ID used to uniquely identify this module
  GUID = '4123ac51-202e-4b9b-8573-9e20e6d2062c'

  # Author of this module
  Author = 'Andriy Melnyk @TurboBasic'

  # Company or vendor of this module
  CompanyName = 'private'

  # Copyright statement for this module
  Copyright = '2017 Andriy Melnyk @TurboBasic'

  # Description of the functionality provided by this module
  Description = 'Generic system management utilies.'

  # Minimum version of the Windows PowerShell engine required by this module
  PowerShellVersion = '3.0.0'

  # Name of the Windows PowerShell host required by this module
  PowerShellHostName = 'ConsoleHost'

  # Minimum version of the Windows PowerShell host required by this module
  PowerShellHostVersion = ''

  # Minimum version of the .NET Framework required by this module
  DotNetFrameworkVersion = ''

  # Minimum version of the common language runtime (CLR) required by this module
  CLRVersion = ''

  # Processor architecture (None, X86, Amd64, IA64) required by this module
  ProcessorArchitecture = ''

  # Modules that must be imported into the global environment prior to importing this module
  RequiredModules = @()

  # Assemblies that must be loaded prior to importing this module
  RequiredAssemblies = @()

  # Script files (.ps1) that are run in the caller's environment prior to importing this module
  # TODO loader to bootstrap required functions outside of the module
  ScriptsToProcess = @()

  # Type files (.ps1xml) to be loaded when importing this module
  TypesToProcess = @()

  # Format files (.ps1xml) to be loaded when importing this module
  FormatsToProcess = @()

  # Modules to import as nested modules of the module specified in RootModule
  NestedModules = @(  
      'include/Add-FileDetails.ps1', 
      'include/Add-SmartMargin.ps1', 
      'include/ConvertTo-Hashtable.ps1', 
      'include/Copy-Tree.ps1', 
      'include/Expand-HashtableSelfReference.ps1',
      'include/Get-ConsoleColor.ps1', 
      'include/Get-EnvironmentPath.ps1', 
      'include/Get-GistMao.ps1', 
      'include/Get-GuiHelp.ps1', 
      'include/Get-HelpWindow.ps1',
      'include/Get-SpecialFolders.ps1', 
      'include/Get-StringHash.ps1', 
      'include/Get-TimeStamp.ps1',
      'include/IsNull.ps1', 
      'include/Merge-Hashtables.ps1',  
      'include/New-Shortcut.ps1', 
      'include/New-SymLink.ps1',
      'include/Remove-IndentationMark.ps1',
      'include/Remove-LeadingSpace.ps1',
      'include/Send-NetMessage.ps1',
      'include/Set-FileTime.ps1', 
      'include/Set-LogEntry.ps1', 
      'include/Update-HelpFiles.ps1', 
      'include/Write-Log.ps1',
      'include/Write-VariableDump.ps1'
  )

  # Functions to export from this module
  FunctionsToExport = '*'

  # Cmdlets to export from this module
  CmdletsToExport = '*'

  # Variables to export from this module
  VariablesToExport = ''

  # Aliases to export from this module
  AliasesToExport = '*'

  # List of all modules packaged with this module
  ModuleList = @()

  # List of all files packaged with this module
  FileList = @( 'Commands.psd1', 
                'Commands.psm1', 
                'include/Add-FileDetails.ps1', 
                'include/Add-SmartMargin.ps1', 
                'include/ConvertTo-Hashtable.ps1', 
                'include/Copy-Tree.ps1', 
                'include/Expand-HashtableSelfReference.ps1',
                'include/Get-ConsoleColor.ps1', 
                'include/Get-EnvironmentPath.ps1', 
                'include/Get-GistMao.ps1', 
                'include/Get-GuiHelp.ps1', 
                'include/Get-HelpWindow.ps1',
                'include/Get-SpecialFolders.ps1', 
                'include/Get-StringHash.ps1', 
                'include/Get-TimeStamp.ps1',
                'include/IsNull.ps1', 
                'include/Merge-Hashtables.ps1',  
                'include/New-Shortcut.ps1', 
                'include/New-SymLink.ps1', 
                'include/Set-FileTime.ps1', 
                'include/Set-LogEntry.ps1', 
                'include/Update-HelpFiles.ps1',
                'include/Write-Log.ps1',
                'include/Write-VariableDump.ps1'
  )

  # Private data to pass to the module specified in ModuleToProcess
  PrivateData = @{
        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @(
                "GitHub",
                "Gist",
                "REST",
                "OAuth"
            )

            # A URL to the license for this module.
            # LicenseUri = ""

            # A URL to the main website for this project.
            ProjectUri = "https://github.com/TurboBasic/dotfiles.windows/tree/master/powershell"

            # A URL to an icon representing this module.
            IconUri = "https://gist.githubusercontent.com/TurboBasic/9dfd228781a46c7b7076ec56bc40d5ab/raw/03942052ba28c4dc483efcd0ebf4bfc6809ed0d0/hexagram3D.png"

            # ReleaseNotes of this module
            ReleaseNotes = ""

        } 
  }
}