
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
# .EXAMPLE
#     Get-Partition -DriveLetter G | Add-MountPoint -Path 'C:\temp\22' 
#     Get-Partition -DriveLetter G | Remove-MountPoint -Path 'C:\temp\22'
#
# .EXAMPLE
#     $Partition = Mount-VHD -Path C:\temp\ws2016.vhdx -PassThru | Get-Partition -PartitionNumber 2
#     $Partition | Add-MountPoint -Path C:\temp\22          
#     $Partition | Remove-MountPoint -Path C:\temp\22
#
# .EXAMPLE
#     Mount-VHD -Path C:\temp\ws2016.vhdx -PassThru | Get-Partition -PartitionNumber 2 | Add-MountPoint -Path c:\temp\22
#     Get-VHD -Path C:\temp\ws2016.vhdx | Get-Partition -PartitionNumber 2 | Remove-MountPoint -Path c:\temp\22
#

Function Add-MountPoint {

    [CMDLETBINDING( 
          SupportsShouldProcess = $True, 
          ConfirmImpact = 'Medium' )]
    [OutputType( [Microsoft.Management.Infrastructure.CimInstance] )]

    PARAM(
        [PARAMETER( Mandatory, 
                    Position = 0, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName )]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Partition,

        [PARAMETER( Mandatory, Position=1 )]
        [String]
        $path
    )


  BEGIN {
    $oldEAP = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    Function ShouldCreateEmptyDir ( [String]$path, [Switch]$Force ) {
        if($PSCmdlet.ShouldProcess( $path, "$( 'Force '*($Force -as [int]) )Create empty directory" )) {
          New-Item -Path $path -ItemType Directory -Force:$Force
        } 
    }

    Function ShouldAddEmptyAccessPath (
        [Microsoft.Management.Infrastructure.CimInstance]$partition, 
        [String]$path, 
        [Switch]$force 
    ) {
        if($PSCmdlet.ShouldProcess( $path, "Mount partition $( $partition.Guid ) to directory" )) {
          $Partition | Add-MountPoint -Path $path -Force:$Force
        } 
    }
  
  }


  PROCESS {

    if( (Test-Path -PathType Container -Path $path) -and 
        (-not (Test-Path -Path "$path\*")) -and 
        ((Get-ChildItem $path -Attributes Hidden, System).Count -eq 0)
    ) { 
          $path = (Get-Item $path).FullName
          if($PSCmdlet.ShouldProcess( $path, "Mount partition $( $_.Guid ) to directory" )) {
              $_ | Add-PartitionAccessPath -AccessPath $path
          }   
      } elseif( -Not(Test-Path $path) ) {
          ShouldCreateEmptyDir $path -Force
          ShouldAddEmptyAccessPath -Partition $_ -Path $path          # $_ | Add-PartitionAccessPath -AccessPath ((Get-Item $path).FullName)
      }

  }
  

  END {
    $ErrorActionPreference = $oldEAP
  }

}