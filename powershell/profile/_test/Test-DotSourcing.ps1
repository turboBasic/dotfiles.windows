$dotSource = {
  PARAM(
    [PARAMETER( Mandatory, Position=0 )]
    [string[]]
    $path
  )

"Test-DotSourcing:`$dotSource $( ConvertTo-JSON $myInvocation.InvocationName )"
"Test-DotSourcing:`$dotSource $( ConvertTo-JSON $myInvocation.MyCommand.Path )"
"Test-DotSourcing:`$dotSource $( ConvertTo-JSON $myInvocation.Line )"
  Get-ChildItem -path $path -ErrorAction SilentlyContinue |
    ForEach-Object {
      Write-Host "dot sourcing file $( $_.FullName )"
      . $_
    }
}

"Test-DotSourcing: $( ConvertTo-JSON $myInvocation.InvocationName )"
"Test-DotSourcing: $( ConvertTo-JSON $myInvocation.MyCommand.Path )"
"Test-DotSourcing: $( ConvertTo-JSON $myInvocation.Line )"
remove-variable dotsourcing_include_01 -force -EA 0
. $dotSource -path $psScriptRoot\dotsourcing*.ps1
"`$dotsourcing_include_01: $dotsourcing_include_01"
#remove-variable dotsourcing_include_01 -force -EA 0