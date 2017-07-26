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

Function Remove-MountPoint {

    [CMDLETBINDING()]
    [OutputType( [Microsoft.Management.Infrastructure.CimInstance] )]

    PARAM(
        [PARAMETER( Mandatory, 
                    ValueFromPipeline, 
                    ValueFromPipelineByPropertyName )]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Partition,

        [PARAMETER( Mandatory )]
        [String]
        $path
    )


  BEGIN{}

  PROCESS{
    $_ | Remove-PartitionAccessPath -AccessPath $path -PassThru | Dismount-VHD
  
  }

  END{}

}