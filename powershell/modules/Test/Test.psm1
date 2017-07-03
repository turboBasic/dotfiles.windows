function loadTest {
  copy-item "$__projects/dotfiles.windows/Powershell/Modules/*" -Recurse -Filter "Test*" -Destination "$profileDir/Modules/" -Force
  Import-Module "$profileDir/Modules/Test/Test.psm1" -Force
}

function t3 { 

  Param (  
    [parameter(ValueFromPipeline)] 
    [array]
    $item = "default"
  ) 

  $list = @($input) 
  if ($list.count) { 
    $item = $list 
  }  
  if (!(test-path variable:\item)) { 
    $item = "default" 
  } 
  $item | % { return $_ }
}


Function t-p {

  #region Parameters
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]            
    param(            
        [parameter( Mandatory = $false,            
                    ValueFromPipeline = $True,            
                    ValueFromPipelineByPropertyName = $True)]            
        [string[]]$pcName = "$env:computername",        
        
        [parameter( Mandatory = $false,            
                    ValueFromPipeline = $True,            
                    ValueFromPipelineByPropertyName = $True)]  
        [string[]]$User =  "$env:username",  
            
        [switch]$Force            
    ) 
  #endregion
  
            
  Begin { 
    #Write "Begin"
    #$pcName | Out-String -Stream | Write
  }

            
  Process {
    $pcName.count

    #$pcName | Out-String -Stream | Write
                
    #foreach($pc in $pcName) {
    #  $pcName | Out-String -Stream | Write     
    #}            
  }

            
  End {
   Write "`$pcName = " + ( $pcName | %{ ", $_" } | Out-String).TrimStart(",")
  }            
}



Export-ModuleMember -Function * -Alias *