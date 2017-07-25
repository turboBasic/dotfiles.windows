function Get-Shim {
  PARAM(
      [PARAMETER( Mandatory )] 
      [String] $Path,
 
      [Switch] $Global = $false,   # Create shim in Global or User namespace
      [Switch] $Relative = $true,
      [Switch] $Norelative,
      [String] $Name,
      [String] $Arg,
      [String] $ShimPath
  )

  $ShimExe = 'Shim.exe'           # Full Path to shim.exe

    if( !(Test-Path $Path)) { 
        Abort "Can't shim '$(Fname $Path)': couldn't find '$Path'." 
    }
    $abs_shimdir = Ensure $ShimPath      #Ensure (Shimdir $global)
    if( !$Name ) { 
        $Name = Remove-Extension (Fname $Path) }

    $Shim = "$Abs_Shimdir\$($Name.ToLower()).ps1"

    # convert to relative path
    Push-Location $Abs_Shimdir
    if ($relative -And !$Norelative.IsPresent) { 
        $Relpath = Resolve-Path -Relative $Path 
        $Prefix = 'Join-Path "$psScriptRoot" ' 
    } else {
        $Relpath = Resolve-Path $Path
        $Prefix = ''
    }
    Pop-Location

    Write-Output ("{0}{1}{2}" -f '$Path = ', $Prefix, "`"$Relpath`"") | Out-File $Shim -Encoding UTF8
    if( $Arg ) {
        Write-Output "`$Args = '$($Arg -join "', '")', `$args" | Out-File $Shim -Encoding UTF8 -Append
    }
    Write-Output 'if($MyInvocation.ExpectingInput) { $input | & $Path @Args } else { & $Path @Args }' | 
            Out-File $Shim -Encoding UTF8 -Append

    if($Path -match '\.exe$') {

        # for programs with no awareness of any shell
        $Shim_Exe = "$(Remove-Extension($Shim)).Shim"
        Copy-Item $ShimExe "$(Remove-Extension($Shim)).exe" -Force
        Write-Output "Path = $(Resolve-Path $Path)" | Out-File $Shim_Exe -Encoding UTF8
        if($Arg) {
            Write-Output "Args = $Arg" | Out-File $Shim_Exe -Encoding UTF8 -Append
        }

    } elseif($Path -match '\.((bat)|(cmd))$') {

        # shim .bat, .cmd so they can be used by programs with no awareness of PSH
        $Shim_Cmd = "$(Remove-Extension($Shim)).cmd"
        "@`"$(Resolve-Path $Path)`" $Arg %*" | Out-File $Shim_Cmd -Encoding Ascii

    } elseif($Path -match '\.ps1$') {

        # make ps1 accessible from cmd.exe
        $Shim_Cmd = "$(Remove-Extension($Shim)).cmd"
        "@Powershell -NoProfile -ExecutionPolicy Unrestricted `"& '$(Resolve-Path $Path)' %*;Exit `$LastExitCode`"" |  
                Out-File $Shim_Cmd -Encoding Ascii

    }
}
