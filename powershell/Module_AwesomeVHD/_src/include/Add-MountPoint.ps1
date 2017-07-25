
# $Partition =  Mount-VHD -Path $vhdFile | 
#               Get-Disk | 
#               Where-Object Location -eq $vhdFile | 
#                   Get-Partition -PartitionNumber 2 | 
#                   Add-PartitionAccessPath -AccessPath (
#                       New-Item -Path $vhdDir -ItemType Directory -Force
#                   )
#
# HOW TO UNMOUNT CREATED DISK:
# $Partition | 
#       Remove-PartitionAccessPath -AccessPath $vhdDir -PassThru | 
#       Dismount-VHD
#
#

Function Add-MountPoint {

    [CMDLETBINDING( 
          SupportsShouldProcess = $True, 
          ConfirmImpact = 'Medium' )]
    [OutputType( [Microsoft.Management.Infrastructure.CimInstance] )]

    PARAM(
        [PARAMETER( Mandatory, 
                    Position=0, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName )]
        $Partition,

        [PARAMETER( Mandatory, Position=1 )]
        [String]$path
    )


    Function ShouldPurgeDirectory {
      if($PSCmdlet.ShouldProcess( $path, 'Remove recursively all files inside non-empty directory')) {
          Remove-Item (Join-Path $path '*') -Recurse -Force:$Force
      }
    }

    Function ShouldDeleteFile {
      if($PSCmdlet.ShouldProcess( $path, 'Delete existing file')) {
        Remove-Item $path -Force:$Force
      }
    }

    Function ShouldAddEmptyAccessPath {
        if($PSCmdlet.ShouldProcess( $path, "Mount partition $( $Partition.Guid ) to directory" )) {
          $Partition | Add-PartitionAccessPath -AccessPath $path -Force:$Force
        } 
    }

    Function ShouldCreateEmptyDir {
        if($PSCmdlet.ShouldProcess( $path, 'Create empty directory' )) {
          New-Item -Path $path -ItemType Directory -Force:$Force
        } 
    }


    $oldEAP = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    if( Test-Path -PathType Container -Path $path ) {
      $path = (Get-Item $path).FullName
      if($Force) {
        ShouldPurgeDirectory
        ShouldAddEmptyAccessPath
      } elseif((Test-Path (Join-Path $path '*')) -or ((Get-ChildItem $path -Attributes Hidden,System).count)) {
            Write-Warning "Directory $path is not empty, cannot mount drive here"
            $ErrorActionPreference = $oldEAP
            Return
      } else {
        ShouldAddEmptyAccessPath
      }
    } elseif( Test-Path -PathType Leaf -Path $path ) { 
        if($Force) {
          ShouldDeleteFile
        }
        ShouldCreateEmptyDir
        ShouldAddEmptyAccessPath
    } else {
      $Force = $True
      ShouldCreateEmptyDir
      ShouldAddEmptyAccessPath
    }
    $ErrorActionPreference = $oldEAP
}