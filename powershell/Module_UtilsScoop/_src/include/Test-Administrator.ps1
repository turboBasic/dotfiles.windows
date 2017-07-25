Function Test-Administrator {

    $AdminRole =      [Security.Principal.WindowsBuiltinRole]::Administrator
    $CurrentUserId =  [Security.Principal.WindowsIdentity]::GetCurrent()

    ([Security.Principal.WindowsPrincipal]$CurrentUserId).IsInRole($AdminRole)

}