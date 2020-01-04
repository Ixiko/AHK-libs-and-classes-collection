#NoEnv
SetBatchLines, -1

#Include ../Chrome.ahk


; --- Create a new Chrome instance ---

FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile", "https://autohotkey.com/")


; --- Connect to the page ---

if !(PageInst := ChromeInst.GetPage())
{
	MsgBox, Could not retrieve page!
	ChromeInst.Kill()
}
else
{
	; --- Perform JavaScript injection ---
	
	Loop
	{
		InputBox, JS,,
		( LTrim
		Enter some JavaScript to be run on the page, or leave blank to exit. For example:
		
		alert('hi');
		window.location = "https://p.ahkscript.org/";
		)
		
		if (JS == "" || ErrorLevel)
			break
		
		try
			Result := PageInst.Evaluate(JS)
		catch e
		{
			MsgBox, % "Exception encountered in " e.What ":`n`n"
			. e.Message "`n`n"
			. "Specifically:`n`n"
			. Chrome.Jxon_Dump(Chrome.Jxon_Load(e.Extra), "`t")
			
			continue
		}
		
		MsgBox, % "Result:`n" Chrome.Jxon_Dump(Result, "`t")
	}
	
	
	; --- Close the Chrome instance ---
	
	try
		PageInst.Call("Browser.close") ; Fails when running headless
	catch
		ChromeInst.Kill()
	PageInst.Disconnect()
}

ExitApp
return
