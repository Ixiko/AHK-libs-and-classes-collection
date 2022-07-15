/*
#SingleInstance,Force
#Persistent
ControlGet, hCB, hwnd,, ComboBox2, Enregistrements des fournisseurs
ControlGet, CBList, List,,, % "ahk_id "hCB
AutoCompleteCB := Func("AutoCompleteCB").Bind(hCB, CBList)
SetTimer,%AutoCompleteCB%,200
return
*/

;-----------------------------------------------------------------------------------------------------------------------------------------
AutoCompleteCB(ByRef hCB, ByRef CBList) { ; ComboBox custom auto complete
;-----------------------------------------------------------------------------------------------------------------------------------------
	;-1-Initialise
	Static prevCBText

	;-2-Get Curr Content
	ControlGetText, CBText,, % "ahk_id "hCB
	if (!CBText or CBText=prevCBText)
		return

	;-3-Find in list
	if (InStr(CBList, CBText)) { ; current text matched anywhere so check it up
		;--------------------------------------------------------------------------------
		Loop, Parse, % CBList, `n
		{
			if (FoundPos := InStr(A_LoopField, CBText)){
				MatchCount++
				if (FoundPos = 1) { ; commence par contenu CBText ou Match anywhere?
					MatchCount_AtStartPos++
					; Order: "Recent" first, then "starting with"
				    MatchesAtStart := MatchesAtStart . "`n" . A_LoopField
				}
				else {
					; Order: "MatchAnywhere" After Best Matches
					MatchAnywhere .= "`n" . A_LoopField
				}
			}
		}
		;--------------------------------------------------------------------------------
		Matches := MatchesAtStart . MatchAnywhere ; Ordered Match list
		;ToolTip, % CBText "" Matches
		;--------------------------------------------------------------------------------
		if (MatchCount = 1) {
			FinalMatch := StrReplace(Matches, "`n") 	; match unique
			if (MatchCount_AtStartPos = 1) {
				cbAutoComplete(hCB, FinalMatch)
			}
			else {
				Control, ChooseString, %FinalMatch%,, % "ahk_id "hCB
			}
			;ToolTip, % FinalMatch
		}
	}
	prevCBText := CBText ; remembered static variable
}

;=======================================================================================
; https://github.com/pulover/cbautocomplete
;
; Function:      CbAutoComplete
; Description:   Auto-completes typed NewValue in a ComboBox.
;
; Author:        Pulover [Rodolfo U. Batista], D Rocks (tried improving Backspace behavior)
; Usage:         Call the function from the Combobox's gLabel.
;
; CB_GETEDITSEL = 0x0140, CB_SETEDITSEL = 0x0142
;=======================================================================================
CbAutoComplete(hCB, FinalMatch) {
	Static cbAutoCompleteBackspace

	hCB := "ahk_id "hCB
	SendMessage, 0x0140, 0, 0,, %hCB%
	If ((GetKeyState("Backspace", "P"))) {
		MakeShort(ErrorLevel, Start, End)
		Control, ChooseString, %FinalMatch%,, %hCB%
		if (cbAutoCompleteBackspace)  ; variable pour éviter bug double backspace quand nouveau nom (resetté après le cbAutoComplete)
			PostMessage, 0x0142, 0, MakeLong(Start,   StrLen(FinalMatch)),, %hCB%
		else
			PostMessage, 0x0142, 0, MakeLong(Start-1, StrLen(FinalMatch)),, %hCB%
		cbAutoCompleteBackspace := False
		return
	}
	MakeShort(ErrorLevel, Start, End)
	ControlGetText, CBBtext,, %hCB%
	Control, ChooseString, %CBBtext%,, %hCB%
	If (ErrorLevel) {
		ControlSetText,, %CBBtext%, %hCB%
		PostMessage, 0x0142, 0, MakeLong(Start, End),, %hCB%
		return
	}
	ControlGetText, CBBtext,, %hCB%
	PostMessage, 0x0142, 0, MakeLong(Start, StrLen(CBBtext)),, %hCB%
}

MakeLong(LoWord, HiWord)	{
	return (HiWord << 16) | (LoWord & 0xffff)
}
MakeShort(Long, ByRef LoWord, ByRef HiWord)	{
	LoWord := Long & 0xffff
  , HiWord := Long >> 16
}