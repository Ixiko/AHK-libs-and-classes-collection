#NoEnv
SetBatchLines, -1


; --- Create a new chrome instance ---

FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile", "https://autohotkey.com/")


; --- Connect to the active tab ---

Tab := ChromeInst.GetTab()


; --- Perform JavaScript injection ---

Loop
{
	InputBox, JS,,
	( LTrim
	Enter some JavaScript to be run in the tab
	
	For example:
	alert('hi');
	window.location = "https://p.ahkscript.org/";
	)
	
	if ErrorLevel
		break
	
	try
		Result := Tab.Evaluate(JS)
	catch e
	{
		MsgBox, % "Exception encountered in " e.What ":`n`n"
		. e.Message "`n`n"
		. "Specifically:`n`n"
		. Chrome.Jxon_Dump(Chrome.Jxon_Load(e.Extra), "`t")
		
		continue
	}
	
	MsgBox, % "Result: " Chrome.Jxon_Dump(Result)
}

ExitApp
return


#include ../Chrome.ahk
