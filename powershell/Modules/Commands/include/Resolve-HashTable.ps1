function Resolve-HashTable {
<#

  PS> {@{ 
  >>    basePath  = 'c:\Windows'
  >>    cmd       = $_.basePath + '\' + 'cmd.exe' }} | 
  >>  Resolve-HashTable

  Name                           Value
  ----                           -----
  basePath                       c:\Windows
  cmd                            c:\Windows\cmd.exe


  PS> {@{basePath='c:\Windows'; cmd=$_.basePath+'\cmd.exe'}} | Resolve-Hashtable -OutVariable a | Out-Null
  PS> $a
  
  Name                           Value
  ----                           -----
  basePath                       c:\Windows
  cmd                            c:\Windows\cmd.exe


  PS> {@{basePath='c:\Windows'; cmd=$_.basePath+'\cmd.exe'}},{@{a='c:\Very\VeryLong\Path'; cmd1=$_.a+'\dir1'; cmd2=$_.cmd1+'\dir2'}}  | Resolve-Hashtable

#>

  [CMDLETBINDING( PositionalBinding=$False )]
  [OUTPUTTYPE( [Hashtable[]] )]
  PARAM(
      [PARAMETER( Mandatory, Position=0, ValueFromPipeline )]
      [ValidateNotNullOrEmpty()]
      [Scriptblock[]] $InputObject
  )
  

  
  BEGIN {}

  
  PROCESS {
  
    foreach( $hashTable in $InputObject ) {
      Try   { $__ = $hashTable.Invoke() }
      Catch { 
        $__ = $null 
        Write-Verbose 'Invoke failed'
      }
      
      if( IsNull $__ ) {
          $result = $null
      } else {
          $result = [Scriptblock]::Create( $hashTable.toString().Replace('$_', '$__') ).Invoke()
      }

      $result
    }
    
  }

  
  END {}

}