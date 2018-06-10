WinGetAll(TextFile = True, DetHidden = False) {
	if (A_DetectHiddenWindows)
		detectHiddenWindowPrevious := "On"
	else
		detectHiddenWindowPrevious := "Off"
	
	if (DetHidden = True)
		DetectHiddenWindows On
	else
		DetectHiddenWindows Off
	
	if (TextFile) {
		WinGet, id, list,,, Program Manager
		FileDelete Resources\WindowSpyInfo.csv
		Loop %id%
		{
			this_id := id%A_Index%
			WinActivate, ahk_id %this_id%
			WinGetClass, this_class, ahk_id %this_id%
			WinGetTitle, this_title, ahk_id %this_id%
			WindowList = %WindowList%`"%A_index%`", `"%this_id%`", `"%this_class%`", `"%this_title%`"`n
		}
		FileAppend % "Win Number, Win ID, Win Class, Win Title"
		FileAppend, %WindowList%, Resources\WindowSpyInfo.csv
		Run Resources\WindowSpyInfo.csv
	}
	else	{
		WinGet, id, list,,, Program Manager
		Loop, %id%
		{
			this_id := id%A_Index%
			WinActivate, ahk_id %this_id%
			WinGetClass, this_class, ahk_id %this_id%
			WinGetTitle, this_title, ahk_id %this_id%
			MsgBox, 4, , Visiting All Windows`n%a_index% of %id%`nahk_id %this_id%`nahk_class %this_class%`n%this_title%`n`nContinue?
			IfMsgBox, NO, break
		}
	}
	DetectHiddenWindows %detectHiddenWindowPrevious%
}