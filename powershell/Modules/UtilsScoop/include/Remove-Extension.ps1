function Remove-Extension( $Fname ) { 

    $Fname -replace '\.[^\.]*$', '' 

}
# function Strip_Ext( $fname ) { 