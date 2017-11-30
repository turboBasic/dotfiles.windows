function Get-ModuleNounsAndVerbs { 
<#
        .SYNOPSIS
Gets list of cmdlet nouns in a module, each noun is complimented with the list of cmdlet verbs

        .DESCRIPTION
Gets list of cmdlet nouns in a module, each noun is complimented with the list of cmdlet verbs

        .INPUTS
[System.String[]]

        .OUTPUTS
[System.psCustomObject[]]

        .PARAMETER Name
The name(s) of module(s) where Get-ModuleNounsAndVerbs gets list of nouns and verbs from. 
The module should be reachable to current Powershell session, ie. the module exists in `Get-Module *` command output.

        .EXAMPLE
Get-ModuleNounsAndVerbs -module DISM

        .EXAMPLE
Get-ModuleNounsAndVerbs -module PackageManagement, PowershellGet

        .EXAMPLE
Get-ModuleNounsAndVerbs -module DISM | Tee-Object -variable result
$result | Format-Table | Out-String | Set-Clipboard

        .NOTES
(c) 2017 turboBasic https://github.com/turboBasic

        .LINK
https://github.com/turboBasic/

#>

    [CmdletBinding( 
        SupportsShouldProcess,
        ConfirmImpact = 'Low' )]
    [OutputType( [Object[]] )]

    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = 'Enter the module name to fetch commands from',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateScript({
            [Boolean]$(
                try { Get-Module -name $_ }
                catch { $False }
            )
        })]
        [Alias( 'moduleName')]
        [String[]] $name,

        [Switch] $force
    )

    BEGIN {
        if (-not $psBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $psCmdlet.SessionState.psVariable.GetValue('ConfirmPreference')
        }
        if (-not $psBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $psCmdlet.SessionState.psVariable.GetValue('WhatIfPreference')
        }
        if (-not $psBoundParameters.ContainsKey('Verbose')) {
            $WhatIfPreference = $psCmdlet.SessionState.psVariable.GetValue('VerbosePreference')
        }
        if (-not $psBoundParameters.ContainsKey('Debug')) {
            $WhatIfPreference = $psCmdlet.SessionState.psVariable.GetValue('DebugPreference')
        }
        # Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)

        $psBoundParameters.Remove('Force') | Out-Null            
        $psBoundParameters.Confirm = $false    
    }

    PROCESS 
    {
        if ($force -or $psCmdlet.ShouldProcess($name, 'Get all nouns and verbs from Powershell module')) 
        {
            foreach ($1module in (
                $name | ForEach { (Get-Module -name $_).Name }
            )) {
                "Get list of cmdlets from module $1module" | Write-Verbose

                $commands = Get-Command -module $1module -commandType Cmdlet, Function
                $commands | 
                    Select-Object -property Noun |
                    Sort-Object -unique Noun |
                    ForEach-Object {
                        "Get list of cmdlet verbs with noun='$($_.Noun)' in module $1module" | Write-Debug

                        [psCustomObject]@{
                            Module = $1module 
                            Noun =   $_.Noun
                            Verbs =  [Array](
                                $commands | 
                                    Where-Object Noun -EQ $_.Noun | 
                                    Select-Object -expandProperty Verb
                            )
                        }
                    }
            }
        }
    }

    END {}
}