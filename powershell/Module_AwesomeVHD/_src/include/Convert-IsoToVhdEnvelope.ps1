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

Function Convert-IsoToVhdEnvelope {

    [CMDLETBINDING( DefaultParameterSetName = "Iso&Vhd" )]
    [OutputType( [void] )]
    [OutputType( [Microsoft.Management.Infrastructure.CimInstance], 
                  ParameterSetName = "NoDismount" )]
    PARAM(
        [PARAMETER( ParameterSetName = "Iso&Vhd", Mandatory, Position=0 )]
        [ALIAS('From', 'Source')]
        [String]$iso,

        [PARAMETER( ParameterSetName = "Iso&Vhd", Mandatory, Position=1 )]
        [ALIAS('To', 'Destination')]
        [String]$vhd,

        [PARAMETER( ParameterSetName = 'Iso&Vhd' )]
        [PARAMETER( ParameterSetName = 'NoDismount', Mandatory )]
        [Switch]$noDismount
    )

    $oldEAP = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    $tmpDir = 'c:\temp'

    $random  = ([System.Guid]::NewGuid() -as [String]) -replace '-'
    $mountDir = Join-Path $tmpDir $random
    New-Item -ItemType Directory -Path $mountDir
    $newVhd = $random + '.vhdx'
    $newVhd = Join-Path $tmpDir $newVhd

    Try { $Partition = New-VHD -Path $newVhd -SizeBytes 6GB -Dynamic }
    Catch {
          $Partition = $null
          Remove-Item $mountDir -Recurse -Force
          $ErrorActionPreference = $oldEAP
          Write-Error "Cannot create VHD $newVhd"
    }

    Try {     
      $Partition = ( 
          $Partition | 
              Mount-VHD -PassThru |
              Initialize-Disk -PassThru | 
              New-Partition -UseMaximumSize
      )
    } Catch {
          $ErrorActionPreference = $oldEAP
          Write-Error "Cannot create partition: $Partition"
    }


    Try {
      $Partition | 
        Add-PartitionAccessPath -AccessPath $mountDir -PassThru |
        Format-Volume -FileSystem NTFS -Confirm:$False -Force
    } Catch {
          $Partition = $null
          Remove-Item $mountDir -Confirm
          $ErrorActionPreference = $oldEAP
          Write-Error "Cannot add Accesspath $mountDir"
    } Finally {
          $ErrorActionPreference = $oldEAP
    }


    $paramstring = 'x', '-y', ('-o"{0}"' -f $mountDir), $iso, '*', '-xr!install.wim'
    & 7z.exe $paramstring

    #if(!NoDismount) {
    #}

    Try {
      $Partition | Remove-PartitionAccessPath -AccessPath $mountDir -PassThru | Dismount-VHD
    } Catch {
      Write-Error 'Cannot release mounted VHD: do it manually'
      Return
    }

    Remove-Item $mountDir
    Move-Item $newVhd $vhd
}