pushd %userprofile%\Documents\WindowsPowerShell
powershell -NoProfile -noninteractive -command "& { . .\set-environment.ps1; Set-MachineEnvironment; [Environment]::Exit($LASTEXITCODE) }"
powershell -NoProfile -noninteractive -command "& { . .\set-environment.ps1; Set-UserEnvironment; [Environment]::Exit($LASTEXITCODE) }"
popd