/* Function: TskDlg
 *     Wrapper for TaskDialog(comctl32.dll) function - http://goo.gl/lgiPd8
 *     This is a modified version of just me's TaskDialog() - http://goo.gl/qBn8dv
 * Requirements:
 *     Windows Vista or newer, AHK v1.1+ OR v2.0-a054+
 * Syntax:
 *     res := TskDlg( main [, extra, title, buttons, icon, parent ] )
 * Return Value:
 *     The text of the button pressed by the user. Values are OK, Cancel, Retry,
 *     Yes, No.
 * Parameters:
 *     main      	[in]       	- 	main instruction text
 *     extra     	[in, opt] 	- 	additional text that appears below the main instruction
 *     title       	[in, opt] 	- 	task dialog window title, defaults to A_ScriptName
 *     buttons  	[in, opt] 	- 	pipe/space/comma/newline-delimited string containing
 *                                         	the name/text of the buttons to display. Argument can
 *                                         	also be a combination of flags/integer values defined
 *                                         	in TDBTNS(static variable). If omitted an 'OK' button
 *                                         	is used. 
 *     icon      	[in, opt] 	- 	the icon to display in the task dialog. Can be one
 *                                       	of the keys defined in TDICON(static variable). If
 *                                       	omitted, no icon is used.
 *     parent   	[in, opt] 	- 	handle to the owner window of the task dialog
 * Remarks:
 *     Credits to just me. An exception is thrown if A_OSVersion <= WIN_XP.
 */
TskDlg(main, extra:=0, title:="", buttons:=0, icon:=0, parent:=0) {
	static is_xp := A_AhkVersion < "2" ? A_OSVersion == "WIN_XP" : A_OSVersion < "6"
	static TDBTNS := { "OK": 0x01, "YES": 0x02, "NO": 0x04, "CANCEL": 0x08
	                 , "RETRY": 0x10, "CLOSE": 0x20 }
	     , TDICON := { 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9
	                 , "WARN": 1, "ERROR": 2, "INFO": 3, "SHIELD": 4, "BLUE": 5
	                 , "YELLOW": 6, "RED": 7, "GREEN": 8, "GRAY": 9 }
	     , TDRES  := [ "OK", "Cancel",, "Retry",, "Yes", "No", "Close" ]

	if is_xp
		throw A_ThisFunc . "(): This function requires Windows Vista or higher."
	
	btns := 0
	if (Abs(buttons) != "")
		btns := buttons & 0x3F
	else
		for i, btn in StrSplit(buttons, ["|", " ", ",", "`n"])
			btns |= (b := TDBTNS[btn]) ? b : 0
	ico := (i := TDICON[icon]) ? 0x10000 - i : 0

	return DllCall( "comctl32\TaskDialog"
	              , "Ptr", parent, "Ptr", 0
	              , "WStr", title != "" ? title : A_ScriptName
	              , "WStr", main, extra == 0 ? "Ptr" : "WStr", extra
	              , "UInt", btns, "Ptr", ico
	              , "IntP", result ) == 0 ? TDRES[result] : 0
}