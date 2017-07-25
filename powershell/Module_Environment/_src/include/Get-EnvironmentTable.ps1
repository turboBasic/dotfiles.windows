Function Get-EnvironmentTable {
    $vars =     Get-Environment * * | select -expandProperty Name | sort -unique
    $scopes =   [enum]::GetNames([EnvironmentScope])

    $res = @()
    foreach($v in $vars) {
      $item = [psCustomObject][ordered]@{ Variable=$v; Machine=''; User=''; Volatile=''; Process='' }
      foreach($s in $scopes) {
        $value = Get-ExpandedName -Name $v -Scope $s | Select -expandProperty Value
        if($v -like '*path') {
          $item.$s = ($value -split ';') -join "`n"
        } else {
          $item.$s = $value
        }
      }
      $res += $item
    }

    $a = @{Label="Variable"; Expression={$_.Variable}; width=25}, 
         @{Label="Machine";  Expression={$_.Machine};  width=60}, 
         @{Label="User";     Expression={$_.User};     width=55},
         @{Label="Volatile"; Expression={$_.Volatile}; width=28},
         @{Label="Process";  Expression={$_.Process};  width=80}

    $res | Format-Table $a -Wrap
}