;#include <MathConstants.au3>

#AutoIt3Wrapper_Run_AU3Check=n

;#cs single line #ce

#cs
# Comment #01
#ce

#cs
# @var string
#ce
Global $a = "a"

#cs
# @var string
#ce
$b = "a"

#cs
# abc does nothing
#ce
Func abc()
    ;
EndFunc

#cs
# This is a summary
#
# This is a description
#ce
Func abc2()
    ;
EndFunc

#cs
# This is a summary.
# This is a description
#ce
Func abc3()
    ;
EndFunc

#cs
# @source
#ce
Func abc4()
    ;
EndFunc

#cs
# @param string $argument1 This is the description.
#ce
Func abc5()
    ;
EndFunc

#cs
# A summary informing the user what the associated element does.
#
# A *description*, that can span multiple lines, to go _in-depth_ into the details of this element
# and to provide some background information or textual references.
#
# @param string $myArgument With a *description* of this argument, these may also
#    span multiple lines.
#
# @return void
#ce
Func abc6()
    ;
EndFunc

#cs
# Does nothing.
# This function does simply nothing of worth.
# @return void
#ce
Func abc7()
    #cs
        some multiline comment
    #ce

    $a = 1

    #cs
        another multiline comment
    #ce
EndFunc

#cs
# abc8
#ce
Func abc8()

EndFunc
