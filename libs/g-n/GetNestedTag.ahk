/*
Function       : GetNestedTag() v1
Author         : hi5
Doc + Examples : https://github.com/hi5/GetNestedTag/
AHK Forum      : http://www.autohotkey.com/forum/viewtopic.php?t=77653
AutoHotkey     : Basic 1.0.48.05, AutoHotkey_L 1.0.X series
Purpose        : Function (parser) to retrieve the contents of a (nested) HTML-tag

*/

GetNestedTag(data,tag,occurrence="1")
	{
	 Start:=InStr(data,tag,false,1,occurrence)
	 RegExMatch(tag,"i)<([a-z]*)",basetag) ; get yer basetag1 here
	 Loop
		{
		 Until:=InStr(data, "</" basetag1 ">", false, Start, A_Index) + StrLen(basetag1) + 3
 		 Strng:=SubStr(data, Start, Until - Start) 

		 StringReplace, strng, strng, <%basetag1%, <%basetag1%, UseErrorLevel ; start counting to make match
		 OpenCount:=ErrorLevel
		 StringReplace, strng, strng, </%basetag1%, </%basetag1%, UseErrorLevel
		 CloseCount:=ErrorLevel
		 If (OpenCount = CloseCount)
		 	Break

		 If (A_Index > 250)	; for safety so it won't get stuck in an endless loop, 
		 	{				; it is unlikely to have over 250 nested tags
		 	 strng=
		 	 Break
		 	}	
		}
	 If (StrLen(strng) < StrLen(tag)) ; something went wrong/can't find it
	 	strng=
	 Return strng
	}
