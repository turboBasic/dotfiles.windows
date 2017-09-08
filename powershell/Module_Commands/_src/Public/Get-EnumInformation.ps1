function Get-EnumInformation( [Object] $thing ) {
  if( $thing -is [Enum] ) {
    $type = $thing.getType()
  } elseif( ($thing -as [Type]).baseType.fullName -eq 'System.Enum' ) {
    $type = $thing -as [Type]
  } else {
    return $null
  }
  
  [PSCustomObject] @{
    Type =                    $type.fullName
    UnderlyingType =          [Enum]::getUnderlyingType($type).fullName  # or $type.getUnderlyingType().fullName
    EnumElementNames =        [Enum]::getNames($type)                    # or $type.getEnumNames()
    EnumElementValues =       [Enum]::getValues($type)                   # or $type.getEnumValues()
    EnumElementNamesString =  [Enum]::getNames($type) -join ', '
  }
}