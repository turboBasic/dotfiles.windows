sv Source  (gc .\package.json | convertfrom-json) -Scope 'Script'
sv Destination $Source.destination

foreach ($f in ($Source.files)) {
  #Write-Output $f.name
  Try { 
    Copy-Item $f -Destination $ExecutionContext.InvokeCommand.ExpandString($Destination)."name" -Recurse 
  }
  Catch {
    Write-Output "Cannot copy ($f.name) to $Destination"
  }
    #Copy-Item $f -Destination $Destination -Recurse -Force
}

Write-Output $Source.name