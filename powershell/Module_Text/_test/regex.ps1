function rgx {
  PARAM(
    [string]
    $pattern=''
  )

  [regex]$rx = $pattern  # ^\s*function\s+(?<fname>[-\w]+)\s*({.*)?$

  return $rx

}