pushd %userprofile%\Documents\WindowsPowerShell
powershell -NoProfile -noninteractive -command "& { . .\set_environment.ps1; initMachineEnvironment; [Environment]::Exit($LASTEXITCODE) }"
powershell -NoProfile -noninteractive -command "& { . .\set_environment.ps1; initUserEnvironment; [Environment]::Exit($LASTEXITCODE) }"
popd