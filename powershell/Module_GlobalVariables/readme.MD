# GlobalVariables - powershell module for setting global variables 

<img src="https://gist.githubusercontent.com/turboBasic/9dfd228781a46c7b7076ec56bc40d5ab/raw/03942052ba28c4dc483efcd0ebf4bfc6809ed0d0/hexagram3D.png" alt="GlobalVariables module" style="width: 100px; height: auto;" />

## Typical structure of project / psake build system

* _src\
    source files
    
* helpers\
    Install-PSDepend.ps1 - installs _PSDepend_ without using PowershellGet
    
* build.ps1
    Main and default build script. 
    Checks if everything is installed and Launches default task from psakeBuild.ps1 script
    
* build.requirements.psd1
    Resource file for _PSDepend_. Describes dependencies and what should be done to meet them
    
* psakeBuild.ps1
    _psake_ tasks are decribed here.
    
* readme.MD
    you are reading this file now :^)
    
* StartupLogonScripts.psdeploy.ps1
    deployment script of _PSDeploy_
    
    
## Sequences of actions

1. Powershell: run build.ps1

2. build.ps1:  checks if PSDepend is here and invokes it with `build.requirements.psd1` as argument

3. build.ps1:  invokes psakeBuild.ps1 with argument of build.ps1 if there is argument or 
   with 'default' argument otherwise
   
4. psakeBuild.ps1:  processes tasks specified inside it.  One of tasks could be 'Deploy' and this
   task can Invoke-PSDeploy with argument 'StartupLogonScripts.psdeploy.ps1' - this is deployment script
   
   
© 2017 Andriy Melnyk @turboBasic https://github.com/turboBasic