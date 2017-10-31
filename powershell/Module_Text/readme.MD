# Text processing functions

## About
Author: Andriy Melnyk [[@turboBasic](https://github.com/turboBasic)]

## Overview
Text processing functions for various repetitive tasks - consolidated and distributed as Powershell module.

## Release Pipeline Model
This module is using the Release Pipeline Model with PowerShell-based tools. This repository hosts the ```_src/text.psd1``` 
module manifest. This repository also includes associated tests and build tasks for day to day operations and deployment of the module.

## Usage
A ```Psake``` script has been created to manage the various operations related to testing and deployment of ```text.psd1```

### Build Operations

* Test the script via Pester and Script Analyzer  
```powershell
.\build.ps1
```
    
* Test the script with Pester only  
```powershell
.\build.ps1 -task Test
```
    
* Test the script with Script Analyzer only  
```powershell
.\build.ps1 -task Analyze
```
    
* Deploy the script via PSDeploy  
```powershell
.\build.ps1 -task Deploy
```


## Typical structure of project and description of files

* _src/
    source code files
 
* _test/
    test files (usually ```Pester``` scripts)

* helpers/
    eg. ```Install-PSDepend.ps1``` - installs ```PSDepend``` without using PowershellGet (for compatibility with Powershell version < 5)
    
* build.ps1
    Wrapper script for Main and default build tasks. 
    Checks if everything is installed and launches default task from ```build.Psake.ps1```
    
* build.requirements.psd1
    Resource file for ```PSDepend```. Describes dependencies and what should be done to meet them
    
* build.Psake.ps1
    ```Psake``` tasks are decribed here.
    
* readme.MD
    you are reading this file now :^)
    
* module.Psdeploy.ps1
    deployment script of _PSDeploy_
    
    
## Sequences of actions

1. Powershell: run ```build.ps1```

2. ```build.ps1```:  invokes ```PSDepend``` with ```build.requirements.psd1``` as argument

3. ```build.ps1```:  invokes ```Psake``` with build script argument ```build.Psake.ps1``` 
   
4. ```build.Psake.ps1```:  describes build tasks. 
   
   
© 2017 Andriy Melnyk [[@turboBasic](https://github.com/turboBasic)]
