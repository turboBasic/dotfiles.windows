function Copy-AllModules {

  $moduleSources = "${ENV:projects}\dotfiles.windows\powershell\Module_*"

  Get-ChildItem -path $moduleSources -Directory | 

      #skip build if .donotbuild file marker
      Where-Object { -not (Test-Path (Join-Path $_ '.donotbuild')) } | 
  
      ForEach-Object { 
        $moduleName = (Split-Path $_ -leaf) -replace 'Module_'
        Write-Host -ForegroundColor DarkMagenta $moduleName

        Try { 
          & (Join-Path $_ build.ps1)
        } Catch { 
          "Error while trying to run build file in source repository for module $moduleName" | 
              Write-Warning  
        }
      }
}