Function Get-FileFromWeb( $url, $to ) {
    $wc = New-Object System.Net.webClient
    $wc.Headers.Add('User-Agent', 'Powershell/5.0')
    $wc.DownloadFile( $url, $to )
}
# Function dl