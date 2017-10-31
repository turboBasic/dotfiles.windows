function Update-HelpFiles {
  $params = @{ 
    Name = 'UpdateHelpJob'
    Credential = "${ENV:ComputerName}\${ENV:UserName}"
    ScriptBlock = {
      Update-Help -errorAction SilentlyContinue
    }
    Trigger = (New-JobTrigger -daily -at '03:00')
  }

  if (-not (Get-ScheduledJob -name UpdateHelpJob)) {
    Register-ScheduledJob @params
  }
}
