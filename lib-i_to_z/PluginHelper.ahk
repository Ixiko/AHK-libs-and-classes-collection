; LintaList Include
; Purpose: Parse (nested) plugins properly and assisting functions
; Version: 1.6
; Date:    20150328

; See the ProcessText label in Lintalist.ahk
; GrabPlugin() v1

; GrabPlugin is used for local variables only at the moment
GrabPlugin(data,tag="",level="1")
	{
	 if (tag <> "")
	 	tag .= "="
	 if RegExMatch(tag,"i)(Clipboard|Selected)")
	 	tag:=trim(tag,"=")
	 Start:=InStr(data,"[[" tag,,,level)
	 Loop
		{
		 Until:=InStr(data, "]]", false, Start, A_Index) + StrLen("]]")
		 Strng:=SubStr(data, Start, Until - Start)
		 OpenCount:=CountString(strng, "[[")
		 CloseCount:=CountString(strng, "]]")
		 If (OpenCount = CloseCount)
    		Break

		 If (A_Index > 250) ; for safety so it won't get stuck in an endless loop.
    		{
			 strng=
			 Break
			}
		}
	 If (StrLen(strng) < StrLen(tag)) ; something went wrong/can't find it
		strng=

	 Return strng
	}

; helper functions

GrabPluginOptions(data)
	{
	 Return Trim(SubStr(data,InStr(data,"=")+1),"[]")
	}

CountString(String, Char)
	{
	 StringReplace, String, String, %Char%,, UseErrorLevel
	 Return ErrorLevel
	}
