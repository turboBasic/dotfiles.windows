Function Get-TimeStamp {
<#

.SYNOPSIS
    returns Timestamp string

.DESCRIPTION
    Get-TimeStamp produces sortable and not dependent on current culture timestamp using local time of user.

.PARAMETER dateDelimiter
    Symbol or string which delimits day, month and year numbers. Default value is ‘.’

.PARAMETER timeDelimiter
    Symbol or string which delimits hours, minutes and seconds. Default value is ‘:’

.PARAMETER Delimiter
    Symbol or string which delimits date and time parts of the timestamp. Default value is ‘ ’

.PARAMETER NoFractionOfSecond
    Generates timestamp without fraction part of the seconds. By default timestamp is generated with an accuracy of a thousandth of second. This parameter has alias ‘WholeSeconds’ 

.PARAMETER NoDelimiters
    Generates timestamp without delimiters

.PARAMETER Short
    Generates timestamp without delimiters and fractions of second

.EXAMPLE
    PS> Get-TimeStamp
    2017.07.12 12:16:15.455

.EXAMPLE
    PS> Get-TimeStamp -dateDelimiter '-'
    2017-07-12 12:16:32.015

.EXAMPLE
    PS> Get-TimeStamp -timeDelimiter ''
    2017.07.12 121643.934

.EXAMPLE
    PS> Get-TimeStamp -Delimiter '___'
    2017.07.12___12:16:56.911

.EXAMPLE
    PS> Get-TimeStamp -NoFractionOfSecond
    2017.07.12 12:17:11

    PS> Get-TimeStamp -WholeSeconds
    2017.07.12 12:17:11

.EXAMPLE
    PS> Get-TimeStamp -dateDelimiter '...' -timeDelimiter '' -Delimiter '_' -WholeSeconds
    2017...07...12_121732

.EXAMPLE
    PS> Get-TimeStamp -NoDelimiters
    20170712121746.790

.EXAMPLE
    PS> Get-TimeStamp -NoDelimiters -NoFractionOfSecond
    20170712121758

.EXAMPLE
    PS> Get-TimeStamp -Short
    20170712121810

.INPUTS
    Does not accept input from the pipeline

.OUTPUTS
    Outputs [String] as the only type of result

.NOTES
Name:    Get-TimeStamp
Author:  Andriy Melnyk  https://github.com/TurboBasic/
Created: 2017.07.12 11:55:31.113

#>


  [CMDLETBINDING( PositionalBinding=$False )]
  [OUTPUTTYPE( [String]) ]
  PARAM(
      [PARAMETER( ParameterSetName='Full Specification' )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [String]
      $dateDelimiter = '.',

      [PARAMETER( ParameterSetName='Full Specification' )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [String]
      $timeDelimiter = ':',

      [PARAMETER( ParameterSetName='Full Specification' )]
      [AllowEmptyString()] [AllowEmptyCollection()] [AllowNull()]
      [String]
      $Delimiter = ' ',

      [PARAMETER( ParameterSetName='Full Specification' )]
      [PARAMETER( ParameterSetName='No Delimiters' )]
      [ALIAS( 'WholeSeconds' )]
      [Switch]
      $NoFractionOfSecond,

      [PARAMETER( Mandatory, 
                  ParameterSetName='No Delimiters' )]
      [Switch]
      $NoDelimiters,

      [PARAMETER( Mandatory, 
                  ParameterSetName='Short' )]
      [Switch]
      $Short
  )





  if( $PsCmdlet.ParameterSetName -in 'No Delimiters', 'Short' ) {
    $dateDelimiter = $timeDelimiter = $Delimiter = ''
  }

  if( $PsCmdlet.ParameterSetName -eq 'Short' ) {
    $NoFractionOfSecond = $True
  }

  if( $NoFractionOfSecond ) {
    $fractions = ''
  } else {
    $fractions = '.fff'
  }

  ( "{0:yyyy${dateDelimiter}", 
    "MM${dateDelimiter}", 
    "dd${Delimiter}",
    "HH${timeDelimiter}", 
    "mm${timeDelimiter}", 
    "ss${fractions}}" -join '') -f (Get-Date)

}
