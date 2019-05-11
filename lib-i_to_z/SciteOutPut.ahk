; https://autohotkey.com/boards/viewtopic.php?p=63779&sid=2f4fec3a88f97eb0017a893c7ae3d202#p63779
; https://autohotkey.com/boards/viewtopic.php?p=112019#p112019
SciTEOutput(fnText = "",fnClear = "1",fnLineBreak = "1")
{
	oSciTE := ComObjActive("{D7334085-22FB-416E-B398-B5038A5A0784}") ; get pointer to active SciTE window
	If (fnClear = 1)
		oSciTE.Message(0x111,420) ; clear output
	If (LineBreak = 1)
		fnText := "`r`n" fnText ; prepend newline to text
	oSciTE.Output(fnText) ; send text to output pane
}

/*
SciTEOutput("Hello, this`r`nis me")
Sleep, 3000

var:="This just shows using a variable"
SciTEOutput(var)
Sleep, 3000

var:="Didn't change defaults so cleared screen and appended line break to end"
SciTEOutput(var)
Sleep, 3000
*/