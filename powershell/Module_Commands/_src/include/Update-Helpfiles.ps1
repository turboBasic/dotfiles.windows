Function Update-HelpFiles {
  $params = @{ 
    Name = 'UpdateHelpJob'
    Credential = "${ENV:ComputerName}\${ENV:UserName}"
    ScriptBlock = {
      Update-Help -EA 0
    }
    Trigger = (New-JobTrigger -Daily -At '3 AM')
  }

  if (!(Get-ScheduledJob -Name UpdateHelpJob)) {
    Register-ScheduledJob @params
  }
}
