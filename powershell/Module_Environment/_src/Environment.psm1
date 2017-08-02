#region add custom Data types

<# Add-Type -TypeDefinition @"
  public Enum EnvironmentScope {
    Machine  
    User     
    Volatile 
    Process  
  }
"@  

Add-Type -TypeDefinition @"
  public Enum EnvironmentData {
    Name   
    Value  
    Source 
  }
"@  #>
  
 Enum EnvironmentScope {
    Machine  = 0x0001
    User     = 0x0002
    Volatile = 0x0004
    Process  = 0x0008
  }

  Enum EnvironmentData {
    Name   = 0x0010
    Value  = 0x0020
    Source = 0x0004
  }

#endregion add custom Data Types



#region initialization of module -- dot source the individual scripts that make-up this module

  Write-Verbose "Module $(Split-Path $psScriptRoot -leaf) was successfully loaded."

#endregion



#region shortcut functions (only for saving typing and keyboards)
#endregion



#region Create aliases for functions
  New-Alias -Name genv  Get-Environment            -ErrorAction SilentlyContinue
  New-Alias -Name ge    Get-Environment            -ErrorAction SilentlyContinue
  New-Alias -Name senv  Set-Environment            -ErrorAction SilentlyContinue
  New-Alias -Name se    Set-Environment            -ErrorAction SilentlyContinue
  New-Alias -Name rmenv Remove-EnvironmentVariable -ErrorAction SilentlyContinue
#endregion


#region Create Drives
#endregion


$Script:__localizationAssets = ConvertFrom-Json -InputObject '{
  "languages":  [
    "en-US"
  ],
  "messages": {
      "en-US":  {}
  }
}'


Function Initialize-Localization {
  #   Data structure for localized messages is self-explanatory
      PARAM(
          [PARAMETER( Mandatory )]
          [ValidateNotNullOrEmpty()]
          [Hashtable]
          $Data
      )

  $Script:__localizationAssets.messages = $Data | ConvertTo-JSON | ConvertFrom-Json

  if($Data.messages) {
    if($Data.messages.'en-US') {
      # $Script:__localizationAssets.messages.'en-US' = $Data.messages.'en-US' | ConvertTo-JSON | ConvertFrom-Json
      $Script:__localizationAssets.messages | Add-Member -Name 'en-US' -Type NoteProperty -Value ($Data.messages.'en-US' | ConvertTo-JSON | ConvertFrom-Json)
      #$Script:__localizationAssets.messages.Add('en-US', ($Data.messages.'en-US' | ConvertTo-JSON | ConvertFrom-Json) )
    } else {
      $Data.messages.GetEnumerator() |
        ForEach { $Script:__localizationAssets.messages.add($_.Key, ($_.Value | ConvertTo-JSON | ConvertFrom-Json) ) }
    }
  }

  $Data.languages |
      Where { $_ -notlike 'en-US'} |
      ForEach { $Script:__localizationAssets.languages += $_ }
}


Function Set-Localisation([String]$language='en-US') {
  <#
      Localization attributes:
        $Global:__currentLanguage  - active language
        $Global:__defaultLanguage  - default embedded language
        $Global:__messages         - hashtable with all localized messages for end-user

      General usage (after initialization of __messages):
        $__messages.messageCode -f messageParameters, ... | Write

  #>

  Set-Variable __defaultLanguage -Scope Global -Value $Script:__localizationAssets.languages[0]        # en-US
  Set-Variable __currentLanguage -Scope Global -Value $Script:__localizationAssets.languages[0]
  New-Variable __messages        -Scope Global -Force

  $isDefault = $language -eq $Global:__defaultLanguage
  $isValid   = $language -in $Script:__localizationAssets.languages
  $Global:__messages = $Script:__localizationAssets.messages.$Script:__currentLanguage

  if ($isValid) {
    $Global:__currentLanguage = $language
  } else {
    $Global:__messages.errorLocalisation -f $language, $Global:__currentLanguage | Write-Error
  }

  $Global:__messages.localisation -f $Global:__currentLanguage | Write-Verbose

}
