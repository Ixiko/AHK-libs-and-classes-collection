ListLines(PassTrueToTurnOnOrFalseToTurnOff := "") 	; Returns the previous setting of ListLines (prior to this call).
{ 												; can also return the current setting when no value passed to it
    static sListLines := true  ; The starting default for all scripts is "ListLines On".
    if (PassTrueToTurnOnOrFalseToTurnOff = "")
    	return sListLines

    ListLines % PassTrueToTurnOnOrFalseToTurnOff ? "On" : "Off"  ; Execute ListLines unconditionally to omit the lines executed below from the log.
    ListLines_prev := sListLines
    sListLines := PassTrueToTurnOnOrFalseToTurnOff
    return ListLines_prev
}

/*
	; To use the above function:
	prev_ListLines := ListLines(false)  ; Turn off ListLines temporarily.
	; ...
	ListLines(prev_ListLines)  ; Restore ListLines to its previous setting


	current_ListLines := ListLines() 

/*