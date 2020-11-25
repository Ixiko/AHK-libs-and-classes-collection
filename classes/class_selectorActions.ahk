; Central place for functions called from Selector.
; All of them should take just one argument, a SelectorRow object (defined in selectorRow.ahk), generally named actionRow.
; There's also a debug mode that most of these should support:
;	You can check whether we're in debug mode via the flag actionRow.debugResult (boolean), so you can quit early before actually doing the action.
;  You can also populate actionRow.debugResult with info about what WOULD have run. Feel free to use objects - the calling code will use DEBUG.popup to display it to the user, which handles objects gracefully.

; Example function:
; EXAMPLE(actionRow) {
	; column := actionRow.data["COLUMN"]
	; id     := actionRow.data["ID"]
	
	; ; Processing as needed
	; finishedResult := column " " id
	
	; actionRow.debugResult := finishedResult
	; if(actionRow.isDebug)
		; return
	
	; Run, % finishedResult
; }


; == Return functions (just return the actionRow object or a specific piece of it) ==
; Just return the requested subscript (defaults to "DOACTION").
RET(actionRow, subToReturn = "DOACTION") {
	val := actionRow.data[subToReturn]
	
	actionRow.debugResult := val
	if(actionRow.isDebug)
		return
	
	return val
}

; Return data array, for when we want more than just one value back.
RET_DATA(actionRow) {
	data := actionRow.data
	
	actionRow.debugResult := data
	if(actionRow.isDebug)
		return
	
	return data
}

; Return entire object.
RET_OBJ(actionRow) {
	actionRow.debugResult := actionRow
	if(actionRow.isDebug)
		return
	
	return actionRow
}


; == Run functions (simply run DOACTION subscript of the actionRow object) ==
; Run the action.
DO(actionRow) {
	action := actionRow.data["DOACTION"]
	
	actionRow.debugResult := action
	if(actionRow.isDebug)
		return
	
	Run, % action
}


; == File operations ==
; Write to the windows registry.
REG_WRITE(actionRow) {
	keyName   := actionRow.data["KEY_NAME"]
	keyValue  := actionRow.data["KEY_VALUE"]
	keyType   := actionRow.data["KEY_TYPE"]
	rootKey   := actionRow.data["ROOT_KEY"]
	regFolder := actionRow.data["REG_FOLDER"]
	
	actionRow.debugResult := {"Key name":keyName, "Key value":keyValue, "Key Type":keyType, "Root key":rootKey, "Key folder":regFolder}
	if(actionRow.isDebug)
		return
	
	RegWrite, %keyType%, %rootKey%, %regFolder%, %keyName%, %keyValue%
}

; Change a value in an ini file.
INI_WRITE(actionRow) {
	offStrings := ["o", "f", "off", "0"]
	
	if(actionRow.data["FILE"]) {
		file := actionRow.data["FILE"]
		sect := actionRow.data["SECTION"]
		key  := actionRow.data["KEY"]
		val  := actionRow.data["VALUE"]
		
	; Special debug case - key from name, value from arbitrary end.
	} else {
		file := actionRow.data["KEY"]
		sect := actionRow.data["VALUE"]
		key  := actionRow.data["NAME"]
		val  := !contains(offStrings, actionRow.userInput)
	}
	
	actionRow.debugResult := {"File":file, "Section":sect, "Key":key, "Value":val}
	if(actionRow.isDebug)
		return
	
	if(!val) ; Came from post-pended arbitrary piece.
		IniDelete, %file%, %sect%, %key%
	else
		IniWrite,  %val%,  %file%, %sect%, %key%
}

; Updates specific settings out of the main script's configuration file, then reloads it.
UPDATE_AHK_SETTINGS(actionRow) {
	global MAIN_CENTRAL_SCRIPT
	INI_WRITE(actionRow) ; Has its own debug handling.
	
	if(actionRow.isDebug)
		return
	
	; Also reload the script to reflect the updated settings.
	reloadScript(MAIN_CENTRAL_SCRIPT, true)
}


; == Open specific programs / send built strings ==
; Run Hyperspace.
DO_HYPERSPACE(actionRow) {
	environment  := actionRow.data["COMM_ID"]
	versionMajor := actionRow.data["MAJOR"]
	versionMinor := actionRow.data["MINOR"]
	
	; Error check.
	if(!versionMajor || !versionMinor) {
		DEBUG.popup("DO_HYPERSPACE", "Missing info", "Major version", versionMajor, "Minor version", versionMinor)
		return
	}
	
	; Build run path.
	runString := buildHyperspaceRunString(versionMajor, versionMinor, environment)
	
	actionRow.debugResult := runString
	if(actionRow.isDebug)
		return
	
	Run, % runString
}

; Send internal ID of an environment.
SEND_ENVIRONMENT_ID(actionRow) {
	environmentId := actionRow.data["ENV_ID"]
	
	actionRow.debugResult := environmentId
	if(actionRow.isDebug)
		return
	
	Send, % environmentId
	Send, {Enter} ; Submit it too.
}

; Run something through Thunder, generally a text session or Citrix.
DO_THUNDER(actionRow) {
	runString := ""
	thunderId := actionRow.data["THUNDER_ID"]
	
	runString := MainConfig.getProgram("Thunder", "PATH") " " thunderId
	
	actionRow.debugResult := runString
	if(actionRow.isDebug)
		return
	
	if(actionRow.data["COMM_ID"] = "LAUNCH") ; Special keyword - just show Thunder itself, don't launch an environment.
		activateProgram("Thunder")
	else
		Run, % runString
}

; Run a VDI.
DO_VDI(actionRow) {
	vdiId := actionRow.data["VDI_ID"]
	
	; Build run path.
	runString := buildVDIRunString(vdiId)
	
	actionRow.debugResult := runString
	if(actionRow.isDebug)
		return
	
	if(actionRow.data["COMM_ID"] = "LAUNCH") { ; Special keyword - just show VMWare itself, don't launch a specific VDI.
		runProgram("VMWareView")
	} else {
		if(!vdiId) ; Safety check - don't try to launch with no VDI specified (that's what the "LAUNCH" COMM_ID is for).
			return
		
		Run, % runString
		
		; Also fake-maximize the window once it shows up.
		WinWaitActive, ahk_exe vmware-view.exe, , 10, VMware Horizon Client ; Ignore the loading-type popup that happens initially with excluded title.
		if(ErrorLevel) ; Set if we timed out or if somethign else went wrong.
			return
		fakeMaximizeWindow()
	}
}

; Open an environment in Snapper using a dummy record.
DO_SNAPPER(actionRow) {
	environment := actionRow.data["COMM_ID"]
	ini         := actionRow.data["INI"]
	idList      := actionRow.data["ID"]
	
	url := buildSnapperURL(environment, ini, idList)
	
	actionRow.debugResult := url
	if(actionRow.isDebug)
		return
	
	if(actionRow.data["COMM_ID"] = "LAUNCH") ; Special keyword - just launch Snapper, not any specific environment.
		runProgram("Snapper")
	else
		Run, % url
}

; Open a homebrew timer (script located in the filepath below).
TIMER(actionRow) {
	time := actionRow.data["TIME"]
	runString := MainConfig.getFolder("AHK_ROOT") "\source\standalone\timer\timer.ahk " time
	
	actionRow.debugResult := runString
	if(actionRow.isDebug)
		return
	
	Run, % runString
}


; == Other assorted action functions ==
; Call a phone number.
CALL(actionRow) {
	num := actionRow.data["NUMBER"]
	special := actionRow.data["SPECIAL"]
	
	actionRow.debugResult := {"Number":num, "Special":special}
	if(actionRow.isDebug)
		return
	
	callNumber(num, actionRow.data["NAME"])
}

; Resizes the active window to the given dimensions.
RESIZE(actionRow) {
	width  := actionRow.data["WIDTH"]
	height := actionRow.data["HEIGHT"]
	ratioW := actionRow.data["WRATIO"]
	ratioH := actionRow.data["HRATIO"]
	
	if(ratioW)
		width  *= ratioW
	if(ratioH)
		height *= ratioH
	
	actionRow.debugResult := {"Width":width, "Height":height}
	if(actionRow.isDebug)
		return
	
	WinMove, A, , , , width, height
}

; Builds a string to add to a calendar event (with the format the outlook/tlg calendar needs to import happily into Delorean), then sends it and an Enter keystroke to save it.
OUTLOOK_TLG(actionRow) {
	tlp      := actionRow.data["TLP"]
	message  := actionRow.data["MSG"]
	dlg      := actionRow.data["DLG"]
	customer := actionRow.data["CUST"]
	
	; Sanity check - if the message is an EMC2 ID (or P.emc2Id) and the DLG is not, swap them.
	if(!isEMC2Id(dlg) && (SubStr(dlg, 1, 2) != "P.") ) {
		if(isEMC2Id(message)) {
			newDLG  := message
			message := dlg
			dlg     := newDLG
		}
	}
	textToSend := tlp "/" customer "///" dlg ", " message
	
	actionRow.debugResult := textToSend
	if(actionRow.isDebug)
		return
	
	SendRaw, % textToSend
	Send, {Enter}
}

; Builds and sends a string to exclude the items specified, for Snapper.
SEND_SNAPPER_EXCLUDE_ITEMS(actionRow) {
	itemsList := actionRow.data["STATUS_ITEMS"]
	
	itemsAry  := StrSplit(itemsList, ",")
	For i,item in itemsAry {
		if(i > 1)
			excludeItemsString .= ","
		excludeItemsString .= "-" item
	}
	
	actionRow.debugResult := excludeItemsString
	if(actionRow.isDebug)
		return
	
	Send, % excludeItemsString
	Send, {Enter}
}
