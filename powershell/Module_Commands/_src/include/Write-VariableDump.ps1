function Write-VariableDump {
  <# .SYNOPSIS
        `$variable | ConvertTo-Json | Write-Verbose` on steroids
  #> 

 
  [CMDLETBINDING( DefaultParameterSetName='Prefix' )] 
  PARAM( 
      [PARAMETER( Position=0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
      [ALIAS( 'object' )]         
      [Object[]] $Name,

      [PARAMETER( ParameterSetName='Prefix', Position=1 )]
      [ALLOWEMPTYSTRING()]
      [String] $Prefix = '',

      [PARAMETER( ParameterSetName='Template' )]
      [ALLOWEMPTYSTRING()]
      [String] $Template = '${0} = {1}',

      [PARAMETER()]      
      [Switch] $noRecurse
  )   

    #region debug information printing functions
      Function DumpBeginBlock {
          'BEGIN: $ParameterSetName = {0}' -f 
              $PSCmdlet.ParameterSetName | Write-Verbose
          'BEGIN: $Name = {0}'             -f 
              ($Name    | ConvertTo-Json) | Add-SmartMargin 16 | Write-Verbose
          'BEGIN: $Prefix = {0}'           -f 
              $Prefix   | Write-Verbose
          'BEGIN: $Template = {0}'         -f 
              $Template | Write-Verbose
      }

      Function DumpProcessBlockBegin {
        '       PROCESS: $input = {0}' -f 
                ($input  | ConvertTo-Json) | Add-SmartMargin 25 | Write-Verbose
        '                type = {0}'   -f 
                $input.GetType().Name | Write-Verbose
        '       PROCESS: $Name = {0}'  -f 
                ($Name   | ConvertTo-Json) | Add-SmartMargin 25 | Write-Verbose
        '                type = {0}'   -f 
                $Name.GetType().Name  | Write-Verbose
        '       PROCESS: $_ = {0}'     -f 
                ($psItem | ConvertTo-Json) | Add-SmartMargin 25 | Write-Verbose
        '                type = {0}'   -f ( .{  if ($_ -eq $Null) 
                                                  { '<null>' } 
                                                else 
                                                  { $_.GetType().Name } 
                                             }  
                                          ) | Write-Verbose
        if( [string]$Name -like 'System.Management.Automation.PSVariable' ) {
            Write-Verbose '       PROCESS: $Name is like System.Management.Automation.PSVariable'
            $trueName = ([System.Management.Automation.PSVariable]$Name).get_Name()
        } else {
            Write-Verbose '       PROCESS: $Name is NOT like System.Management.Automation.PSVariable'
            $trueName = $Name
        }
        '       PROCESS: $trueName = {0}' -f 
                ($trueName | ConvertTo-Json) | Add-SmartMargin 25 | Write-Verbose
        '                type = {0}'      -f $trueName.GetType().Name | Write-Verbose
        $Private:message = (('       PROCESS: ' + $Template) -f 
                $trueName, 
                (Get-Variable -Name $Name -Scope 1 -ValueOnly | 
                ConvertTo-Json) | Add-SmartMargin 25)
        Write-Verbose $Private:message  
      }
    #endregion

    BEGIN {
        $oldverbose = $VerbosePreference
        $VerbosePreference = "SilentlyContinue"
        $Messages = ''
        DumpBeginBlock
    }

    PROCESS {
        DumpProcessBlockBegin
        foreach($singleName in $Name) {
            '      PROCESS FOREACH: $singleName = {0}' -f ($singleName | ConvertTo-Json) | Add-SmartMargin 32 | Write-Verbose
            '                       type = {0}' -f $singleName.GetType().Name | Write-Verbose
                   
            $Private:message = ($Template -f $singleName, (Get-Variable -Name $singleName -Scope 1 -ValueOnly | ConvertTo-Json) | Add-SmartMargin 1 )
            Write-Verbose (Add-SmartMargin $Private:message 9)
            $Messages += $(Write $Private:message) + "`n"
        }
    }

    END {
        $VerbosePreference = $oldverbose
        Write-Verbose $Messages 
        # "`n" 
    }
}

