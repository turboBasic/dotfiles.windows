function _sampleFunctionA {
    PARAM()

    $myInvocation.ScriptName      # the name of current script
}

& { $myInvocation.ScriptName }    # the name of current script, taken outside of script's functions