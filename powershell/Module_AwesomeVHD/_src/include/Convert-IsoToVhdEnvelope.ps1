# Converts Windows installation ISO file to VHDX "envelope", i.e.
# VHDX image without \Sources\Install.wim file
# 
# Use Add-WimFile to add custom WIM file to VHDX image
#
# HOW TO MOUNT CREATED DISK:
# $vhdFile = 'ws2016.vhdx'
# $vhdDir  = Join-Path 'c:\temp' $vhdFile.Replace('.', '')
# $vhdFile = Join-Path 'c:\temp' $vhdFile
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

[OutputType( [void] )]
[OutputType( [Microsoft.Management.Infrastructure.CimInstance], 
              ParameterSetName = "NoDismount" )]
PARAM(
    [PARAMETER( Mandatory, Position=0 )]
    [ALIAS('From', 'Source')]
    [String]$iso,

    [PARAMETER( Mandatory, Position=1 )]
    [ALIAS('To', 'Destination')]
    [String]$vhd,

    [PARAMETER( ParameterSetName = 'NoDismount', Mandatory )]
    [Switch]$noDismount
)

$oldEAP = $ErrorActionPreference
$ErrorActionPreference = "Stop"
$tmpDir = 'c:\temp'

$tmpBase = ([System.Guid]::NewGuid() -as [String]) -replace '-'
$tmpMountDir = Join-Path $tmpDir $tmpBase
New-Item -ItemType Directory -Path $tmpMountDir
$tmpVhd = $tmpBase + '.vhdx'

Try {
  ( $Partition = New-VHD -Path $tmpVhd -SizeBytes 6GB -Dynamic | 
        Mount-VHD -PassThru |
        Initialize-Disk -PassThru | 
        New-Partition -UseMaximumSize |
        Add-PartitionAccessPath -AccessPath $tmpMountDir -PassThru 
  ) |
        Format-Volume -FileSystem NTFS -Confirm:$False -Force

} Catch {
      Write-Error 'Cannot create VHD $tmpVhd'
      $Partition = $null
      Remove-Item $tmpMountDir -Confirm
} Finally {
      $ErrorActionPreference = $oldEAP
}


$paramstring = 'x', '-y', ('-o"{0}"' -f $tmpMountDir), $iso, '*', '-xr!install.wim'
& 7z.exe $paramstring

#if(!NoDismount) {
  
$Partition | fl
Read-Host
$Partition | Remove-PartitionAccessPath -AccessPath $tmpMountDir
Remove-Item $tmpMountDir
Dismount-VHD -Path $tmpVhd
#}

Move-Item $tmpVhd $vhd