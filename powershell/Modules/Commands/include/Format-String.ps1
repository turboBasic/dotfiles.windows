Function Format-String {
<#
    .SYNOPSIS
Replaces text in a string based on named replacement tags

    .DESCRIPTION
Replaces text in a string based on named replacement tags.
Replacement is based on a hashtable or array of hashtables provided as an argument or taken from the pipeline.
    
    .EXAMPLE
PS> Format-String "Hello {NAME}" @{ NAME='PowerShell' }
Hello PowerShell

    .EXAMPLE
PS> Format-String "Your score is {SCORE:P}" @{ SCORE=0.85 }
Your score is 85.00%

    .EXAMPLE
PS> @{score=0.85; Now=(Get-Date)} | Format-String "Now is {NOW:yyyy-MM-dd HH:mm:ss}. Your score is {SCORE:P}"
Now is 2017-07-19 11:48:38. Your score is 85.00%

    .EXAMPLE
PS> @{score=0.85; Now=(Get-Date)}, @{score=0.97; Now=(Get-Date)} | Format-String "Now is {NOW:yyyy-MM-dd HH:mm:ss.fff}. Your score is {SCORE:P}"
Now is 2017-07-19 11:32:54.686. Your score is 85.00%
Now is 2017-07-19 11:32:54.687. Your score is 97.00%

    .EXAMPLE
PS> Format-String "Now is {NOW:yyyy-MM-dd HH:mm:ss.fff}. Your score is {SCORE:P0}" @{score=0.85; Now=(Get-Date)}, @{score=0.97; Now=(Get-Date)}
Now is 2017-07-19 11:36:44.149. Your score is 85%
Now is 2017-07-19 11:36:44.150. Your score is 97%
    
    .INPUTS
Takes array of hashtables from standard input both as whole value and as a property of object in the pipeline
    
    .OUTPUTS
Puts the result of [String[]] type in a pipeline
    
    .NOTES
Andriy Melnyk @turboBasic https://github.com/turboBasic : wrapped in cmdlet to allow pipeline processing
https://github.com/turboBasic/dotfiles.windows/tree/master/powershell/Modules/Commands/include
 
Original:
##############################################################################
##
## Format-String
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################    
 
 
 
.
   
   .LINK
https://github.com/turboBasic/dotfiles.windows/tree/master/powershell/Modules/Commands/include   
http://www.leeholmes.com/guide
   
#>


  [CMDLETBINDING( PositionalBinding=$False )]
  [OUTPUTTYPE( [String[]] )]
  PARAM(
  
      [PARAMETER( Mandatory, Position=0 )]
      ## The string to format. Any portions in the form of {NAME} will be automatically replaced by 
      ## the corresponding value from the supplied hashtable.
      [String] $String,

      [PARAMETER( Mandatory, Position=1, ValueFromPipeline, ValueFromPipelineByPropertyName )]  
      ## The named replacements to use in the string
      [Hashtable[]] $Replacements
  )
  


  
  BEGIN {
    # TODO(Set-StrictMode -Version 5)
    
    if($String -match '{{|}}') {
      Throw 'Escaping of replacement terms are not supported.'
    }
    
  }

  
  PROCESS {
  
    # Now we have all items in $Replacements[] 
    # and we have to unwrap items even if there is only
    # one item in the $Replacements array 
  
    foreach( $1replacement in $Replacements ) {
      $currentIndex = 0
      $replacementList = @()
      
      ## Go through each key in the hashtable
      foreach( $key in $1replacement.Keys ) {
        ## Convert the key into a number, so that it can be used by String.Format
        $inputPattern = '{([^{}]*)' + $key + '([^{}]*)}'
        $replacementPattern = '{${1}' + $currentIndex + '${2}}'
        $String = $String -replace $inputPattern, $replacementPattern
        $replacementList += $1replacement[$key]
        $currentIndex++
      }
      
      ## Now use String.Format to replace the numbers in the format string.
      $String -f $replacementList
      
    }
    
  }

  
  END {}
    
}
  