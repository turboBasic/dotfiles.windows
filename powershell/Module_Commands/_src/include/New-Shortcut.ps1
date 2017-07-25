Function New-Shortcut() { 
  <#
      .SYNOPSIS
          Creates old-school "soft" shortcut to file or folder

      .DESCRIPTION
          Takes input from pipeline and named arguments
          New-Shortcut -name "~\startmenu.lnk" -target X:\directory\ -icon "%SystemDrive%\explorer.exe,0"

  #>
  #region New-Schortcut params

      # [String] $name, [String] $target, 
      # $arguments='',  $icon='%SystemRoot%\explorer.exe,0', 
      # $description='', $workDir='.'

    PARAM(
        [PARAMETER( Mandatory, 
                    Position=0, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName )]
        [VALIDATENOTNULLOREMPTY()]
        [String[]]
        $Name,

        [PARAMETER( Mandatory, 
                    Position=1, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName )]
        [VALIDATESCRIPT({ If (Test-Path $_) 
                            { $True } 
                          Else 
                            { Throw "'$_' doesn't exist!" } })]
        [String]
        $Target,

        [PARAMETER( ValueFromPipelineByPropertyName )]
        [String]
        $arguments='',

        [PARAMETER( ValueFromPipelineByPropertyName )]
        [String]
        $icon=$null,

        [PARAMETER( ValueFromPipelineByPropertyName )]
        [String]
        $workDir='.',

        [PARAMETER( ValueFromPipelineByPropertyName )]
        [String]
        $Description
    )

  #endregion

  BEGIN {}

  PROCESS {
    ForEach ($n in $Name) {
      if($n -notmatch ".*\.lnk$") {
        $n += ".lnk"
      }
      $WshShell = New-Object -ComObject WScript.Shell
      $Shortcut = $WshShell.CreateShortcut($n)
      $Shortcut.TargetPath = $target
      $Shortcut.Arguments = $arguments
      if ($icon) {
        $Shortcut.IconLocation = $icon
      }
      $Shortcut.Description = $description
      $Shortcut.WorkingDirectory = $workDir
      $Shortcut.Save()
      Write-Output $Shortcut
    }
  }

  END {}
}

