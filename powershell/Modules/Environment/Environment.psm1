function Get-EnvironmentVariable ($name, $scope='User') {
  return (_Get-RegistryKey $scope).GetValue(
    $name, $null,
    [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
  )
}


function Set-EnvironmentVariable ($name, $text, $scope='User', $Expand=$true) {
  if ($Expand) {
    $_type = [Microsoft.Win32.RegistryValueKind]::ExpandString
  } else {
    $_type = [Microsoft.Win32.RegistryValueKind]::String
  }
  (_Get-RegistryKey $scope).SetValue($name, $text, $_type)
  (_Get-RegistryKey $scope).Flush()
}


function Delete-EnvironmentVariable ($name, $scope='User') {
  (_Get-RegistryKey $scope).DeleteValue($name)
}


function script:_Get-RegistryKey($scope='User') {
    switch ($scope.ToLower()) {
        user {  return [Microsoft.Win32.RegistryKey]::OpenBaseKey( 
                    [Microsoft.Win32.RegistryHive]::CurrentUser,  
                    [Microsoft.Win32.RegistryView]::Default
                ).OpenSubKey('Environment', $true)
        }
        machine { return [Microsoft.Win32.RegistryKey]::OpenBaseKey( 
                    [Microsoft.Win32.RegistryHive]::LocalMachine, 
                    [Microsoft.Win32.RegistryView]::Default 
                  ).OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment', $true)
        }
        default { throw 'getRegistryKey: Scope parameter should be either "Machine" or "User"' }
    }
}


function Broadcast-EnvironmentChanges() {

  if (-not ("Win32.NativeMethods" -as [Type])) {
    # import sendmessagetimeout from win32
    Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
      [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
      public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
        uint fuFlags, uint uTimeout, out UIntPtr lpdwResult
      );
"@
  }

  $HWND_BROADCAST = [IntPtr] 0xffff;
  $WM_SETTINGCHANGE = 0x1a;
  $result = [UIntPtr]::Zero

  # notify all windows of environment block change
  [Win32.Nativemethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", 2, 5000, [ref] $result);
}


New-Alias -Name get-env Get-EnvironmentVariable
New-Alias -Name set-env Set-EnvironmentVariable
New-Alias -Name del-env Delete-EnvironmentVariable
