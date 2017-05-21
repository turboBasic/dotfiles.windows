powershell -NoProfile -noninteractive -command "& { . (Join-Path (Split-Path $profile -parent) 'set_environment.ps1'); initMachineEnvironment; [Environment]::Exit($LASTEXITCODE) }"
powershell -NoProfile -noninteractive -command "& { . (Join-Path (Split-Path $profile -parent) 'set_environment.ps1'); initUserEnvironment; [Environment]::Exit($LASTEXITCODE) }"
