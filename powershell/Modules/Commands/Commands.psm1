
Function Add-FileDetails {
  param(
    [Parameter(ValueFromPipeline=$true)]
    $fileobject,
    $hash = @{Artists = 13; Album = 14; Year = 15; Genre = 16; Title = 21; Length = 27; Bitrate = 28}
  )
  begin {
    $shell = New-Object -COMObject Shell.Application
  }
  process {
    if ($_.PSIsContainer -eq $false) {
      $folder = Split-Path $fileobject.FullName
      $file = Split-Path $fileobject.FullName -Leaf
      $shellfolder = $shell.Namespace($folder)
      $shellfile = $shellfolder.ParseName($file)
      Write-Progress 'Adding Properties' $fileobject.FullName
      
      $hash.Keys |
      ForEach-Object {
        $property = $_
        $value = $shellfolder.GetDetailsOf($shellfile, $hash.$property)
        if ($value -as [Double]) { 
          $value = [Double]$value 
        }
        $fileobject | Add-Member NoteProperty "Extended_$property" $value -force
      }
    }
    $fileobject
  }
}


Function Get-GuiHelp {
    Set-Variable -name GuiHelpPath -value $env:DROPBOX_HOME\Public\Powershell -option constant  
    if (!$args[0]) {
        $a = "HH.EXE mk:@MSITStore:$GuiHelpPath\powershell2.chm::/test.htm"
        Invoke-Expression $a
        break 
    }
    if ($args[0].contains("about_")) {
        $a = "HH.EXE mk:@MSITStore:$GuiHelpPath\powershell2.chm::/about/" + $args[0] + ".help.htm"
        Invoke-Expression $a
    }
    elseif ($args[0].contains("-")) {
        $a = "HH.EXE mk:@MSITStore:$GuiHelpPath\powershell2.chm::/cmdlets/" + $args[0] + ".htm"
        Invoke-Expression $a
    }
    else {
        if ($args[0].contains(" ")) {
            $b = $args[0] -replace(" ","")
            $a = "HH.EXE mk:@MSITStore:$GuiHelpPath\powershell2.chm::/vbscript/" + $b + ".htm"
            Invoke-Expression $a
        }
        else {
            $b = $args[0] 
            $a = "HH.EXE mk:@MSITStore:d:\powershell help\powershell2.chm::/vbscript/" + $b + ".htm"
            Invoke-Expression $a
        }
        $a
    }
}


Function Get-StringHash([String] $String, $HashName = "MD5") { 
    $StringBuilder = New-Object System.Text.StringBuilder 
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) | %{ 
        [Void]$StringBuilder.Append($_.ToString("x2")) 
    } 
    $StringBuilder.ToString() 
}


Function New-SymLink {
    <#
        .SYNOPSIS
            Creates a Symbolic link to a file or directory

        .DESCRIPTION
            Creates a Symbolic link to a file or directory as an alternative to mklink.exe

        .PARAMETER Path
            Name of the path that you will reference with a symbolic link.

        .PARAMETER SymName
            Name of the symbolic link to create. Can be a full path/unc or just the name.
            If only a name is given, the symbolic link will be created on the current directory that the
            function is being run on.

        .PARAMETER File
            Create a file symbolic link

        .PARAMETER Directory
            Create a directory symbolic link

        .NOTES
            Name: New-SymLink
            Author: Boe Prox
            Created: 15 Jul 2013


        .EXAMPLE
            New-SymLink -Path "C:\users\admin\downloads" -SymName "C:\users\admin\desktop\downloads" -Directory

            SymLink                          Target                   Type
            -------                          ------                   ----
            C:\Users\admin\Desktop\Downloads C:\Users\admin\Downloads Directory

            Description
            -----------
            Creates a symbolic link to downloads folder that resides on C:\users\admin\desktop.

        .EXAMPLE
            New-SymLink -Path "C:\users\admin\downloads\document.txt" -SymName "SomeDocument" -File

            SymLink                             Target                                Type
            -------                             ------                                ----
            C:\users\admin\desktop\SomeDocument C:\users\admin\downloads\document.txt File

            Description
            -----------
            Creates a symbolic link to document.txt file under the current directory called SomeDocument.
    #>
    [cmdletbinding(
        DefaultParameterSetName = 'Directory',
        SupportsShouldProcess=$True
    )]
    Param (
        [parameter(Position=0,ParameterSetName='Directory',ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,Mandatory=$True)]
        [parameter(Position=0,ParameterSetName='File',ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,Mandatory=$True)]
        [ValidateScript({
            If (Test-Path $_) {$True} Else {
                Throw "`'$_`' doesn't exist!"
            }
        })]
        [string]$Path,
        [parameter(Position=1,ParameterSetName='Directory')]
        [parameter(Position=1,ParameterSetName='File')]
        [string]$SymName,
        [parameter(Position=2,ParameterSetName='File')]
        [switch]$File,
        [parameter(Position=2,ParameterSetName='Directory')]
        [switch]$Directory
    )
    Begin {
        Try {
            $null = [mklink.symlink]
        } Catch {
            Add-Type @"
            using System;
            using System.Runtime.InteropServices;
 
            namespace mklink
            {
                public class symlink
                {
                    [DllImport("kernel32.dll")]
                    public static extern bool CreateSymbolicLink(string lpSymlinkFileName, string lpTargetFileName, int dwFlags);
                }
            }
"@
        }
    }
    Process {
        #Assume target Symlink is on current directory if not giving full path or UNC
        If ($SymName -notmatch "^(?:[a-z]:\\)|(?:\\\\\w+\\[a-z]\$)") {
            $SymName = "{0}\{1}" -f $pwd,$SymName
        }
        $Flag = @{
            File = 0
            Directory = 1
        }
        If ($PScmdlet.ShouldProcess($Path,'Create Symbolic Link')) {
            Try {
                $return = [mklink.symlink]::CreateSymbolicLink($SymName,$Path,$Flag[$PScmdlet.ParameterSetName])
                If ($return) {
                    $object = New-Object PSObject -Property @{
                        SymLink = $SymName
                        Target = $Path
                        Type = $PScmdlet.ParameterSetName
                    }
                    $object.pstypenames.insert(0,'System.File.SymbolicLink')
                    $object
                } Else {
                    Throw "Unable to create symbolic link!"
                }
            } Catch {
                Write-warning ("{0}: {1}" -f $path,$_.Exception.Message)
            }
        }
    }
 }


Function ppath {
    
  if ( -Not $( 
            Try { 
                Test-Path (which ppath 2>&1 $null) 
            } 
            Catch { $false } 
        )`
  ) {              
    write-host "doing shim..."
    Add-Content -Path "$(shimdir $true)\ppath.cmd" -Value "`n" +
        "@path | sed s/PATH=//g | sed s/;/\n/g | sed ""s/^./\l&/g""  `n" 
    
    # shim -global -norelative "$PSScriptRoot\ppath.cmd" "ppath"
    if (Test-Path "$(shimdir $true)\ppath.ps1") {
      rm "$(shimdir $true)\ppath.ps1"
    }
    Write-Host "Installing 'ppath' as cmd.exe command ... done`r`n"
  }
  return $env:Path -split ';' | % { $_.Substring(0,1).toLower() + $_.Substring(1) }
}


Function Get-SpecialFolders() {
    $SpecialFolders = @{}
    $names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])

    foreach($name in $names) {
      if($path = [Environment]::GetFolderPath($name)) {
        $SpecialFolders[$name] = $path
      }
    }

    return $SpecialFolders.GetEnumerator() | Sort -Property Name
}


Function New-Shortcut(
        [String] $name, [String] $target, 
        $arguments='',  $icon='%SystemRoot%\explorer.exe,0', 
        $description='', $workDir='.') 
#
# Usage:
# New-Shortcut -name "c:\users\mao\desktop\startmenu.lnk" -target E:\0projects\ `
#              -icon "%SystemDrive%\explorer.exe,0"
#
{
  if(!($name -match ".*\.lnk$")) {
    $name += ".lnk"
  }
  $WshShell = New-Object -ComObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($name)
  $Shortcut.TargetPath = $target
  $Shortcut.Arguments = $arguments
  $Shortcut.IconLocation = $icon
  $Shortcut.Description = $description
  $Shortcut.WorkingDirectory = $workDir
  $Shortcut.Save()
}


New-Alias -name gg Get-GuiHelp 
New-Alias -name gh Get-Help
New-Alias -name ga Get-Alias
