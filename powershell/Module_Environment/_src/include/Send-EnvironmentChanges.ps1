Function Send-EnvironmentChanges {
    if (-Not ('Win32.NativeMethods' -as [Type])) {   

      #import sendmessagetimeout from win32
      Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @'

          [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
          public static extern IntPtr SendMessageTimeout(
              IntPtr hWnd, 
              uint Msg, 
              UIntPtr wParam, 
              string lParam,
              uint fuFlags, 
              uint uTimeout, 
              out UIntPtr lpdwResult
          );
'@  }

    $HWND_BROADCAST   = [System.IntPtr]0xffff;
    $WM_SETTINGCHANGE = 0x1a;
    $result           = [System.UIntPtr]::Zero

    # notify all windows of environment block change
    [Win32.NativeMethods]::SendMessageTimeout( 
        $HWND_BROADCAST, $WM_SETTINGCHANGE, 
        [System.UIntPtr]::Zero, 
        'Environment', 
        2, 
        5000, 
        [ref]$result
    ) | Out-Null
}