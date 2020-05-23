GetTextInfo()
{
	global JABVariables
	txt:=""
	if (!JABVariables["JABInitialised"])
		InitJavaAccessBridge()
	if (JABVariables["JABInitialised"])
	{
		hwnd:=WinExist("A")
		if (!IsJavaWindow(hwnd))
		{
			ControlGetFocus, currctrl, ahk_id %hwnd%
			ControlGet, currwin, Hwnd, , %currctrl%, ahk_id %hwnd%
		}
		else currwin:=hwnd
		vmID:=0
		ac:=0
		if (IsJavaWindow(currwin))
		{
			GetAccessibleContextWithFocus(currwin, vmID, ac)
		}
		If (ac<>0)
		{
			res:=GetAccessibleContextInfo(vmID, ac)
			If (res["Accessible text interface"])
			{
				res:=GetCaretLocation(vmID, ac)
				caretmx:=res["X"]+res["Width"]//2
				caretmy:=res["Y"]+res["Height"]/2
				txt.="GetCaretLocation`n"
				txt.="X: " res["X"] " Y: " res["Y"] " Width: " res["Width"] " Height: " res["Height"] "`n"
				res:=GetAccessibleTextInfo(vmID, ac, caretmx, caretmy)
				txt.="GetAccessibleTextInfo`n"
				txt.="CharCount: " res["CharCount"] " CaretIndex: " res["CaretIndex"] " IndexAtPoint (mid cursor): " res["IndexAtPoint"] "`n"
				caretindex:=res["CaretIndex"]
				res:=GetAccessibleTextItems(vmID, ac, caretindex)
				txt.="GetAccessibleTextItems`n"
				txt.="letter: " res["letter"] " word: " res["word"] " sentence: " res["sentence"] "`n"
				res:=GetAccessibleTextSelectionInfo(vmID, ac)
				txt.="GetAccessibleTextSelectionInfo`n"
				txt.="SelectionStartIndex: " res["SelectionStartIndex"] " SelectionEndIndex: " res["SelectionEndIndex"] " SelectedText: " res["SelectedText"] "`n"
				res:=GetAccessibleTextRange(vmID, ac, caretindex-5, caretindex+5)
				txt.="GetAccessibleTextRange`n"
				txt.="Text: " res "`n"
				res:=GetAccessibleTextRect(vmID, ac, caretindex)
				txt.="GetAccessibleTextRect`n"
				txt.="X: " res["X"] " Y: " res["Y"] " Width: " res["Width"] " Height: " res["Height"] "`n"
				res:=GetAccessibleTextLineBounds(vmID, ac, caretindex)
				txt.="GetAccessibleTextLineBounds`n"
				txt.="StartPos: " res["StartPos"] " EndPos: " res["EndPos"] "`n"

	;~ ; retrieves the text attributes as an object with the keys:
	;~ ; bold, italic, underline, strikethrough, superscript, subscript,
	;~ ; backgroundColor, foregroundColor, fontFamily, fontSize,
	;~ ; alignment, bidiLevel, firstLineIndent, leftIndent, rightIndent,
	;~ ; lineSpacing, spaceAbove, spaceBelow, fullAttributesString
	;~ GetAccessibleTextAttributes(vmID, ac)
				;~ txt.=" : "  " : "  " : "  "`n"
	;~ ; retrieves the text attributes as an object with the keys:
	;~ ; bold, italic, underline, strikethrough, superscript, subscript,
	;~ ; backgroundColor, foregroundColor, fontFamily, fontSize,
	;~ ; alignment, bidiLevel, firstLineIndent, leftIndent, rightIndent,
	;~ ; lineSpacing, spaceAbove, spaceBelow, fullAttributesString
	;~ GetTextAttributesInRange(vmID, ac, startc:=0, endc:=0)
				;~ txt.=" : "  " : "  " : "  "`n"

			}
			else txt:="Current accessible context does not have an accessible text interface."
		}
		else txt:="No valid accessible context with focus found."
	}
	else txt:="Java Access Bridge not initialized."
	return, txt
}

; The function JavaControlDoAction searches for the <occurrence>-instance of a Java-control that fits in <name>, <role> and <description> and performs <action> <count>-times
; actions can be all actions provided by the control itself or:
; - focus: attempts to focus the control and left clicks it if focusing fails
; - check pos: tries if the object has a valid screen location
; - left/double/right/middle click; wheel up/down: performs the respective mouse action in the center of the control

JavaControlDoAction(hwnd:=0, name:="", role:="", description:="", occurrence:="", action:="", times:=1, parentcontext:=0)
{
	global JABVariables
	rval:=JavaControlGet(hwnd, name, role, description, occurrence, parentcontext)
	If (IsObject(rval))
	{
		Info:=getAccessibleContextInfo(rval["vmid"], rval["ac"])
		Loop, %times%
		{
			if (action="check pos")
			{
				If !(Info["X"]=-1 and Info["Width"]=-1 and Info["Y"]=-1 and Info["Height"]=-1)
					return, 0
				else
					return, -3
			}
			if (action="focus")
			{
				If (Instr(Info["States"],"focusable"))
				{
					failure:= RequestFocus(rval["vmid"], rval["ac"])
					if (failure<>0)
					{
						rval:=MouseClickJControl(Info)
					}
				}
				else return, -2
			}
			else if (action="left click")
			{
				rval:=MouseClickJControl(Info)
			}
			else if (action="double click")
			{
				rval:=MouseClickJControl(Info,"left",2)
			}
			else if (action="right click")
			{
				rval:=MouseClickJControl(Info,"right")
			}
			else if (action="middle click")
			{
				rval:=MouseClickJControl(Info,"middle")
			}
			else if (action="wheel up")
			{
				rval:=MouseClickJControl(Info,"wheel up")
			}
			else if (action="wheel down")
			{
				rval:=MouseClickJControl(Info,"wheel down")
			}
			else
			{
				rval:=DoAccessibleActions(rval["vmid"], rval["ac"], action)
			}
		}
		If (times>A_Index)
			Sleep, 50
		return, rval
	}
	else
	 return, rval
}

JavaControlGet(hwnd:=0, name:="", role:="", description:="", occurrence:="", parentcontext:=0)
{
	global JABVariables
	if (!JABVariables["JABInitialised"])
		InitJavaAccessBridge()
	if (JABVariables["JABInitialised"])
	{
		If (IsObject(parentcontext))
		{
			ac:=parentcontext["ac"]
			vmid:=parentcontext["vmid"]
		}
		else
		{
			if (hwnd=0)
			{
				hwnd:=WinExist("A")
				if (!IsJavaWindow(hwnd))
				{
					ControlGetFocus, currctrl, ahk_id %hwnd%
					ControlGet, currwin, Hwnd, , %currctrl%, ahk_id %hwnd%
				}
				else currwin:=hwnd
			}
			else currwin:=hwnd
			vmID:=0
			ac:=0
			if (IsJavaWindow(currwin))
			{
				getAccessibleContextFromHWND(currwin, vmID, ac)
			}
		}
		If (ac<>0)
		{
			If (occurrence>1)
			{
				Loop, 2
				{
					Info:=
					If (JABVariables["CachedParentAc"]=ac)
					{
						Children:=JABVariables["CachedChildren"]
					}
					else
					{
						Children:=GetVisibleChildrenFromTree(vmID, ac)
						JABVariables["CachedChildren"] :=Children
						JABVariables["CachedParentAc"] :=ac
					}
					occurcnt:=0
					For index, value in Children
					{
						Info:=getAccessibleContextInfo(vmID, value)
						if ((name="" or RegExMatch(Info["Name"],name))
							and (role="" or role=Info["Role"])
							and (description="" or RegExMatch(Info["Description"],description)))
						{
							occurcnt++
							if (Occurrence=occurcnt or Occurrence=0 or Occurrence="")
							{
								return, CreateContext(vmid, value)
							}
						}
					}
					JABVariables["CachedParentAc"] :=0
				}
			}
			else
			{
				retval:=FindVisibleChild(vmID, ac, name, role, description)
				if (retval<>"")
					return, retval
				else
					return, -3
			}
		}
	}
	else
	{
		return, -1
	}
}

FindVisibleChild(vmID, ac, name:="", role:="", description:="")
{
	global JABVariables
	retval:=""
	Info:=getAccessibleContextInfo(vmID,ac)
	If (Instr(Info["States"],"visible"))
	{
		if ((name="" or RegExMatch(Info["Name"],name))
			and (role="" or role=Info["Role"])
			and (description="" or RegExMatch(Info["Description"],description)))
		{
			retval:=CreateContext(vmid, ac)
		}
		if (retval="")
		{
			Loop, % Info["Children count"]
			{
				rac:=GetAccessibleChildFromContext(vmID, ac, A_Index-1)
				retval:=FindVisibleChild(vmID, rac, name, role, description)
				if (retval<>"")
					break
			}
		}
	}
	return, retval
}

CreateContext(vmid, ac)
{
	rval:=Object()
	rval["vmid"]:=vmid
	rval["ac"]:=ac
	rval["AccessMode"]:="JAB"
	return, rval
}

SplitContext(context, byref vmid, byref ac)
{
	If (IsObject(context))
	{
		vmid:=context["vmid"]
		ac:=context["ac"]
		return, 0
	}
	else
		return, -1
}

; used to retrieve an object with all visible children of the input control
GetVisibleChildrenFromTree(vmID, ac)
{
	global JABVariables
	Children:=Object()
	if (JABVariables["JABInitialised"])
	{
		RecurseVisibleChildren(vmID, ac, Children)
	}
	Return, Children
}

RecurseVisibleChildren(vmID, ac, byref Children)
{
	global JABVariables
	Info:=getAccessibleContextInfo(vmID,ac)
	If (Instr(Info["States"],"visible"))
	{
		If (Children.MaxIndex()="")
			Children[1]:=ac
		else
			Children[Children.MaxIndex()+1]:=ac
		Loop, % Info["Children count"]
		{
			rac:=GetAccessibleChildFromContext(vmID, ac, A_Index-1)
		RecurseVisibleChildren(vmID, rac, Children)
		}
	}
}

GetControlTree(vmID, ac, Invisible:=0)
{
	global JABVariables
	RetObj:=Object()
	Info:=getAccessibleContextInfo(vmID,ac)
	If (Instr(Info["States"],"visible") or invisible)
	{
		RetObj["ac"]:=ac
		RetObj["Children"]:=Object()
		Loop, % Info["Children count"]
		{
			rac:=GetAccessibleChildFromContext(vmID, ac, A_Index-1)
			RetObj["Children"][A_Index-1]:=GetControlTree(vmID, rac, Invisible)
		}
	}
	return, RetObj
}

; used to retrieve an object with all children that are likely to be controlled
GetControllableChildrenFromTree(vmID, ac)
{
	global JABVariables
	Children:=Object()
	if (JABVariables["JABInitialised"])
	{
		RecurseControllableChildren(vmID, ac, Children)
	}
	Return, Children
}

RecurseControllableChildren(vmID, ac, byref Children)
{
	global JABVariables
	Info:=getAccessibleContextInfo(vmID,ac)
	If (Instr(Info["States"],"visible"))
	{
		blockedroles:=JABVariables["BlockedRoles"]
		role:=Info["Role"]
		If role not in %blockedroles%
			Children.Insert(ac)
		;~ If (Children.MaxIndex()="")
			;~ Children[1]:=ac
		;~ else
			;~ Children[Children.MaxIndex()+1]:=ac
		Loop, % Info["Children count"]
		{
			rac:=GetAccessibleChildFromContext(vmID, ac, A_Index-1)
		RecurseControllableChildren(vmID, rac, Children)
		}
	}
}

; used to retrieve an object with all children of the input control
GetAllChildrenFromTree(vmID, ac)
{
	global JABVariables
	Children:=Object()
	if (JABVariables["JABInitialised"])
	{
		RecurseAllChildren(vmID, ac, Children)
	}
	Return, Children
}

RecurseAllChildren(vmID, ac, byref Children)
{
	global JABVariables
	Info:=getAccessibleContextInfo(vmID,ac)
	If (Children.MaxIndex()="")
		Children[1]:=ac
	else
		Children[Children.MaxIndex()+1]:=ac
	Loop, % Info["Children count"]
	{
		rac:=GetAccessibleChildFromContext(vmID, ac, A_Index-1)
		RecurseAllChildren(vmID, rac, Children)
	}
}

; performs mouse clicks in the center of the specified control
MouseClickJControl(byref Info, action:="left", count:=1)
{
	If !(Info["X"]=-1 and Info["Width"]=-1 and Info["Y"]=-1 and Info["Height"]=-1)
	{
		 xp:=Floor(Info["X"]+Info["Width"]/2)
		 yp:=Floor(Info["Y"]+Info["Height"]/2)
		 CoordMode, Mouse, Screen
		 SetMouseDelay, 0
		 SetDefaultMouseSpeed, 0
		 BlockInput On
		 MouseGetPos, MouseX, MouseY
		 ;~ sleep, 50
		 MouseClick, %action%, %xp%, %yp%, %count%
		 If (action<>"right")
		 {
			sleep, 100
			MouseMove, %MouseX%, %MouseY%
		}
		BlockInput Off
		return, 0
		 ;~ msgbox, %action%
	}
	else
		return, -1
}

; Java Access Bridge functions; see Access Bridge documentation for details

; Initialises the bridge access
InitJavaAccessBridge(ForceLegacy:=0)
{
	global JABVariables
	JABVariables:= Object()
	JABVariables["JABInitialised"]:=False
	JABVariables["JAB_DLLVersion"] :=""
	JABVariables["JAB_DLL"] :=""
	JABVariables["acType"] :="Int64"
	JABVariables["acPType"] :="Int64*"
	JABVariables["acSize"] :=8

	JABVariables["MAX_BUFFER_SIZE"] := 10240
	JABVariables["MAX_STRING_SIZE"] := 1024
	JABVariables["SHORT_STRING_SIZE"] := 256

	JABVariables["ACCESSIBLE_ALERT"] := "alert"
	JABVariables["ACCESSIBLE_COLUMN_HEADER"] := "column header"
	JABVariables["ACCESSIBLE_CANVAS"] := "canvas"
	JABVariables["ACCESSIBLE_COMBO_BOX"] := "combo box"
	JABVariables["ACCESSIBLE_DESKTOP_ICON"] := "desktop icon"
	JABVariables["ACCESSIBLE_INTERNAL_FRAME"] := "internal frame"
	JABVariables["ACCESSIBLE_DESKTOP_PANE"] := "desktop pane"
	JABVariables["ACCESSIBLE_OPTION_PANE"] := "option pane"
	JABVariables["ACCESSIBLE_WINDOW"] := "window"
	JABVariables["ACCESSIBLE_FRAME"] := "frame"
	JABVariables["ACCESSIBLE_DIALOG"] := "dialog"
	JABVariables["ACCESSIBLE_COLOR_CHOOSER"] := "color chooser"
	JABVariables["ACCESSIBLE_DIRECTORY_PANE"] := "directory pane"
	JABVariables["ACCESSIBLE_FILE_CHOOSER"] := "file chooser"
	JABVariables["ACCESSIBLE_FILLER"] := "filler"
	JABVariables["ACCESSIBLE_HYPERLINK"] := "hyperlink"
	JABVariables["ACCESSIBLE_ICON"] := "icon"
	JABVariables["ACCESSIBLE_LABEL"] := "label"
	JABVariables["ACCESSIBLE_ROOT_PANE"] := "root pane"
	JABVariables["ACCESSIBLE_GLASS_PANE"] := "glass pane"
	JABVariables["ACCESSIBLE_LAYERED_PANE"] := "layered pane"
	JABVariables["ACCESSIBLE_LIST"] := "list"
	JABVariables["ACCESSIBLE_LIST_ITEM"] := "list item"
	JABVariables["ACCESSIBLE_MENU_BAR"] := "menu bar"
	JABVariables["ACCESSIBLE_POPUP_MENU"] := "popup menu"
	JABVariables["ACCESSIBLE_MENU"] := "menu"
	JABVariables["ACCESSIBLE_MENU_ITEM"] := "menu item"
	JABVariables["ACCESSIBLE_SEPARATOR"] := "separator"
	JABVariables["ACCESSIBLE_PAGE_TAB_LIST"] := "page tab list"
	JABVariables["ACCESSIBLE_PAGE_TAB"] := "page tab"
	JABVariables["ACCESSIBLE_PANEL"] := "panel"
	JABVariables["ACCESSIBLE_PROGRESS_BAR"] := "progress bar"
	JABVariables["ACCESSIBLE_PASSWORD_TEXT"] := "password text"
	JABVariables["ACCESSIBLE_PUSH_BUTTON"] := "push button"
	JABVariables["ACCESSIBLE_TOGGLE_BUTTON"] := "toggle button"
	JABVariables["ACCESSIBLE_CHECK_BOX"] := "check box"
	JABVariables["ACCESSIBLE_RADIO_BUTTON"] := "radio button"
	JABVariables["ACCESSIBLE_ROW_HEADER"] := "row header"
	JABVariables["ACCESSIBLE_SCROLL_PANE"] := "scroll pane"
	JABVariables["ACCESSIBLE_SCROLL_BAR"] := "scroll bar"
	JABVariables["ACCESSIBLE_VIEWPORT"] := "viewport"
	JABVariables["ACCESSIBLE_SLIDER"] := "slider"
	JABVariables["ACCESSIBLE_SPLIT_PANE"] := "split pane"
	JABVariables["ACCESSIBLE_TABLE"] := "table"
	JABVariables["ACCESSIBLE_TEXT"] := "text"
	JABVariables["ACCESSIBLE_TREE"] := "tree"
	JABVariables["ACCESSIBLE_TOOL_BAR"] := "tool bar"
	JABVariables["ACCESSIBLE_TOOL_TIP"] := "tool tip"
	JABVariables["ACCESSIBLE_AWT_COMPONENT"] := "awt component"
	JABVariables["ACCESSIBLE_SWING_COMPONENT"] := "swing component"
	JABVariables["ACCESSIBLE_UNKNOWN"] := "unknown"
	JABVariables["ACCESSIBLE_STATUS_BAR"] := "status bar"
	JABVariables["ACCESSIBLE_DATE_EDITOR"] := "date editor"
	JABVariables["ACCESSIBLE_SPIN_BOX"] := "spin box"
	JABVariables["ACCESSIBLE_FONT_CHOOSER"] := "font chooser"
	JABVariables["ACCESSIBLE_GROUP_BOX"] := "group box"
	JABVariables["ACCESSIBLE_HEADER"] := "header"
	JABVariables["ACCESSIBLE_FOOTER"] := "footer"
	JABVariables["ACCESSIBLE_PARAGRAPH"] := "paragraph"
	JABVariables["ACCESSIBLE_RULER"] := "ruler"
	JABVariables["ACCESSIBLE_EDITBAR"] := "editbar"
	JABVariables["PROGRESS_MONITOR"] := "progress monitor"
	JABVariables["CachedParentAc"] :=0
	JABVariables["CachedChildren"] :=
	JABVariables["BlockedRoles"] :=	"panel,filler,root pane,layered pane,menu bar,tool bar,separator,split pane,viewport,scroll bar,scroll pane"
	JABVariables["HandledDefaultActions"] := "focus|check pos|left click|double click|right click|middle click|wheel up|wheel down"
	if (ForceLegacy=1)
	{
		JABVariables["JAB_DLLVersion"]:="WindowsAccessBridge"
		JABVariables["JAB_DLL"]:=DllCall("LoadLibrary", "Str", JABVariables["JAB_DLLVersion"] ".dll")
		JABVariables["acType"]:="Int"
		JABVariables["acPType"]:="Int*"
		JABVariables["acSize"]:=4
	}
	else
	if (A_PtrSize=8)
	{
		JABVariables["JAB_DLLVersion"]:="WindowsAccessBridge-64"
		JABVariables["JAB_DLL"]:=DllCall("LoadLibrary", "Str", JABVariables["JAB_DLLVersion"] ".dll")
	}
	else
	{
		JABVariables["JAB_DLLVersion"]:="WindowsAccessBridge-32"
		JABVariables["JAB_DLL"]:=DllCall("LoadLibrary", "Str", JABVariables["JAB_DLLVersion"] ".dll")
		if (JABVariables["JAB_DLL"]=0)
		{
			JABVariables["JAB_DLLVersion"]:="WindowsAccessBridge"
			JABVariables["JAB_DLL"]:=DllCall("LoadLibrary", "Str", JABVariables["JAB_DLLVersion"] ".dll")
			JABVariables["acType"]:="Int"
			JABVariables["acPType"]:="Int*"
			JABVariables["acSize"]:=4
		}
	}
	; it is necessary to preload the DLL
	; otherwise none of the calls suceed

	; start up the access bridge
	JABVariables["JABInitialised"]:=DllCall(JABVariables["JAB_DLLVersion"] "\Windows_run", "Cdecl Int")
	; it is necessary to give the application a few message cycles time before calling access bridge function
	; otherwise all calls will fail
	Sleep, 200 ; minimum 100 for all machines?
	Return, JABVariables["JABInitialised"]
}

; shuts down the access bridge
ExitJavaAccessBridge()
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall("FreeLibrary", "Ptr", JABVariables["JAB_DLL"])
	}
}

IsJavaWindow(hwnd)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		Return DllCall(JABVariables["JAB_DLLVersion"] "\isJavaWindow", "Int", hWnd, "Cdecl Int")
	}
	else
	{
		Return 0
	}
}

; returns JAB version information as object containing the keys: VMversion, bridgeJavaClassVersion, bridgeJavaDLLVersion, bridgeWinDLLVersion
GetVersionInfo(vmID)
{
	global JABVariables
	Info:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(TempInfo, 2048,0)
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getVersionInfo", "Int", vmID, "UInt", &TempInfo, "Cdecl Int"))
		{
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2
				jver:=Chr(NumGet(TempInfo,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			Info["VMversion"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=((A_Index-1)*2)+JABVariables["SHORT_STRING_SIZE"]*2
				jver:=Chr(NumGet(&TempInfo,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			Info["bridgeJavaClassVersion"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+JABVariables["SHORT_STRING_SIZE"]*4
				jver:=Chr(NumGet(&TempInfo,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			Info["bridgeJavaDLLVersion"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+JABVariables["SHORT_STRING_SIZE"]*6
				jver:=Chr(NumGet(&TempInfo,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			Info["bridgeWinDLLVersion"]:=verstr
		}
	}
	Return Info
}

ReleaseJavaObject(vmID, ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\ReleaseJavaObject", "Int", vmID, JABVariables["acType"], ac, "Cdecl")
	}
}

IsSameObject(vmID, ac1, ac2)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		Return DllCall(JABVariables["JAB_DLLVersion"] "\isSameObject", "Int", vmID, JABVariables["acType"], ac1, JABVariables["acType"], ac2, "Cdecl Int")
	}
	else
	{
		Return 0
	}
}

; retrieves the root element from a window
GetAccessibleContextFromHWND(hwnd, ByRef vmID, ByRef ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		Return DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleContextFromHWND", "Int", hWnd, "Int*", vmID, JABVariables["acPType"], ac, "Cdecl Int")
	}
	else
	{
		Return 0
	}
}

GetHWNDFromAccessibleContext(vmID, ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		Return DllCall(JABVariables["JAB_DLLVersion"] "\getHWNDFromAccessibleContext", "Int", vmID, JABVariables["acType"], ac, "Cdecl UInt")
	}
	else
	{
		Return 0
	}
}

GetAccessibleContextAtHWND(hwnd, x, y)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		GetAccessibleContextFromHWND(hwnd, vmID, Winac)
		return, FindContextAt(vmID, Winac, x, y)
	}
	else
	{
		Return 0
	}
}

FindContextAt(vmID, ac, x, y)
{
	global JABVariables
	Info:=getAccessibleContextInfo(vmID,ac)
	If (Instr(Info["States"],"visible"))
	{
		resac:=0
		Loop, % Info["Children count"]
		{
			rac:=GetAccessibleChildFromContext(vmID, ac, A_Index-1)
			resact:=FindContextAt(vmID, rac, x, y)
			If (resact<>0)
				resac:=resact
		}
		If ((resac=0) and (x>=Info["x"]) and (x<=(Info["x"]+Info["Width"])) and (y>=Info["y"]) and (y<=(Info["y"]+Info["Height"])))
		{
			return, ac
		}
		return, resac
	}
	else
		return, 0
}

GetAccessibleContextAt(vmID, acParent, x, y, ByRef ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		Return DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleContextAt", "Int", vmID, JABVariables["acType"], acParent, "Int", x, "Int", y, JABVariables["acPType"], ac, "Cdecl Int")
		;~ Return DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleContextAt", "Int", vmID, "Int", acParent, "Int", x, "Int", y, "Ptr", ac, "Cdecl Int")
	}
	else
	{
		Return 0
	}
}

GetAccessibleContextWithFocus(hwnd, ByRef vmID, ByRef ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		vmid:=0
		ac:=0
		Return DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleContextWithFocus", "Int", hwnd, "Int*", vmID, JABVariables["acPType"], ac, "Cdecl Int")
	}
	else
	{
		Return 0
	}
}

GetActiveDescendent(vmID, ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		Return DllCall(JABVariables["JAB_DLLVersion"] "\getActiveDescendent", "Int", vmID, JABVariables["acType"], ac, "Cdecl Int")
	}
	else
	{
		Return 0
	}
}

GetObjectDepth(vmID, ac)
{
	global JABVariables
	depth:=0
	if (JABVariables["JABInitialised"])
	{
		depth:=DllCall(JABVariables["JAB_DLLVersion"] "\getObjectDepth", "Int", vmID, JABVariables["acType"], ac, "Cdecl Int")
	}
	Return depth
}

GetAccessibleParentFromContext(vmID, ac)
{
	global JABVariables
	acparent:=0
	if (JABVariables["JABInitialised"])
	{
		acparent:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleParentFromContext", "Int", vmID, JABVariables["acType"], ac, "Cdecl "JABVariables["acType"])
	}
	Return, acparent
}

GetTopLevelObject(vmID, ac)
{
	global JABVariables
	acparent:=0
	if (JABVariables["JABInitialised"])
	{
		acparent:=DllCall(JABVariables["JAB_DLLVersion"] "\getTopLevelObject", "Int", vmID, JABVariables["acType"], ac, "Cdecl "JABVariables["acType"])
	}
	Return, acparent
}

GetAccessibleChildFromContext(vmID, ac, index)
{
	global JABVariables
	acchild:=0
	if (JABVariables["JABInitialised"])
	{
		acchild:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleChildFromContext", "Int", vmID, JABVariables["acType"], ac, "Int", index, "Cdecl "JABVariables["acType"])
	}
	Return, acchild
}

GetParentWithRole(vmID, ac, byref role)
{
	global JABVariables
	acparent:=0
	if (JABVariables["JABInitialised"])
	{
		acparent:=DllCall(JABVariables["JAB_DLLVersion"] "\getParentWithRole", "Int", vmID, JABVariables["acType"], ac, "Ptr", &role, "Cdecl "JABVariables["acType"])
	}
	Return, acparent
}

GetParentWithRoleElseRoot(vmID, ac, byref role)
{
	global JABVariables
	acparent:=0
	if (JABVariables["JABInitialised"])
	{
		acparent:=DllCall(JABVariables["JAB_DLLVersion"] "\getParentWithRoleElseRoot", "Int", vmID, JABVariables["acType"], ac, "Ptr", &role, "Cdecl "JABVariables["acType"])
	}
	Return, acparent
}

; retrieves information about a certain element as an object with the keys:
; Name, Description, Role_local, Role, States_local, States, Index in parent,
; Children count, X, Y, Width, Height, Accessible component, Accessible action,
; Accessible selection, Accessible text, Accessible value interface,
; Accessible action interface, Accessible component interface,
; Accessible selection interface, Accessible table interface,
; Accessible text interface, Accessible hypertext interface
GetAccessibleContextInfo(vmID, ac)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 6188,0)
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleContextInfo", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Cdecl Int"))
		{
			verstr:=""
			Loop, % JABVariables["MAX_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.= jver
			}
			TempInfo["Name"]:=verstr
			verstr:=""
			Loop, % JABVariables["MAX_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+JABVariables["MAX_STRING_SIZE"]*2
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["Description"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+JABVariables["MAX_STRING_SIZE"]*4
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr:=verstr jver
			}
			TempInfo["Role_local"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*2
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["Role"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*4
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["States_local"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*6
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["States"]:=verstr
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Index in parent"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Children count"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+8
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["X"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+12
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Y"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+16
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Width"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+20
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Height"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+24
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Accessible component"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+28
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Accessible action"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+32
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Accessible selection"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+36
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Accessible text"]:=jver
			offset:=JABVariables["MAX_STRING_SIZE"]*4+JABVariables["SHORT_STRING_SIZE"]*8+40
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["Accessible value interface"]:=jver & 1
			TempInfo["Accessible action interface"]:=jver & 2
			TempInfo["Accessible component interface"]:=jver & 4
			TempInfo["Accessible selection interface"]:=jver & 8
			TempInfo["Accessible table interface"]:=jver & 16
			TempInfo["Accessible text interface"]:=jver & 32
			TempInfo["Accessible hypertext interface"]:=jver & 64
		}
		else
		{
			msgbox, Error in GetAccessibleContextInfo vmID: %vmID% ac: %ac%
		}
	}
	Return TempInfo
}

GetVisibleChildrenCount(vmID, ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		Return DllCall(JABVariables["JAB_DLLVersion"] "\getVisibleChildrenCount", "Int", vmID, JABVariables["acType"], ac, "Cdecl Int")
	}
	else
	{
		Return 0
	}
}

; this function seems to be unreliable under Win7 64bit
; works fine under WinXP
GetVisibleChildren(vmID, ac)
{
	global JABVariables
	Children:=Object()
	if (JABVariables["JABInitialised"])
	{
		NumChild:=getVisibleChildrenCount(vmID, ac)
		StartChild:=0
		cnt:=0
		VarSetCapacity(TempChildren, 257*JABVariables["acSize"],0)
		Loop
		{
			if (DllCall(JABVariables["JAB_DLLVersion"] "\getVisibleChildren", "Int", vmID, JABVariables["acType"], ac, "Int", StartChild, "Ptr", &TempChildren, "Cdecl Int"))
			{
				retchild:=NumGet(&TempChildren,0,"Int")
				str:=retchild ";;"
				Loop, %retchild%
				{
					Children[++cnt]:=Numget(&TempChildren, JABVariables["acSize"]*(A_Index), JABVariables["acType"])
				}
				StartChild:=StartChild+retchild
			}
			else break
		} Until StartChild>=NumChild
	}
	Return Children
}

GetAccessibleActions(vmID, ac)
{
	global JABVariables
	Actret:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Actions, 256*256*2+A_PtrSize,0)
		if DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleActions", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Actions, "Cdecl Int")
		{
			retact:=NumGet(&Actions,0,"Int")
			Loop, % retact
			{
				verstr:=""
				lind:=A_Index
				Loop, % JABVariables["SHORT_STRING_SIZE"]
				{
					offset:=(A_Index-1)*2+JABVariables["SHORT_STRING_SIZE"]*2*(lind-1)+A_PtrSize
					jver:=Chr(NumGet(&Actions,offset,"UChar"))
					if (jver=Chr(0))
					{
						break
					}
					verstr.= jver
				}
				Actret[A_Index]:=verstr
			}
		}
	}
	Return Actret
}

DoAccessibleActions(vmID, ac, ByRef actionsToDo)
; actionsToDo : comma separated list of actions
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Actions, 256*256*2+A_PtrSize,0)
		Loop, Parse, actionsToDo, `,, %A_Space%
		{
			NumPut(A_Index,&Actions,0,"Int")
			lind:=A_Index
			Loop, Parse, A_LoopField
			{
				offset:=(A_Index-1)*2+JABVariables["SHORT_STRING_SIZE"]*2*(lind-1)+A_PtrSize
				NumPut(Asc(A_LoopField),&Actions,offset,"UChar")
			}
		}
		failure:=0
		DllCall( JABVariables["JAB_DLLVersion"] "\doAccessibleActions", "Int", vmID , JABVariables["acType"], ac , "Ptr", &Actions , "Int", failure, "Cdecl Int")
		return, failure
	}
}

RequestFocus(vmID, ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		return DllCall(JABVariables["JAB_DLLVersion"] "\requestFocus", "Int", vmID, JABVariables["acType"], ac, "Cdecl Int")
	}
}

; retrieves information about a certain text element as an object with the keys:
; CharCount, CaretIndex, IndexAtPoint
GetAccessibleTextInfo(vmID, ac, x:=0, y:=0)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 12,0)
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTextInfo", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Int", x, "Int", y, "Cdecl Int"))
		{
			jver:=NumGet(&Info,0,"Int")
			TempInfo["CharCount"]:=jver
			jver:=NumGet(&Info,4,"Int")
			TempInfo["CaretIndex"]:=jver
			jver:=NumGet(&Info,8,"Int")
			TempInfo["IndexAtPoint"]:=jver
		}
		else
		{
			TempInfo:=
			Return, TempInfo
		}
	}
	Return TempInfo
}

Is64bit(vmID, ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		If (A_Is64bitOS)
		{
			; find out if the JVM is running at 32 or 64 bit to circumvent a bug with the adress length in 32 bit JVMs (JRE 6+7)
			tlo:=GetTopLevelObject(vmID, ac)
			Awin:=GetHWNDFromAccessibleContext(vmID, tlo)
			currwin:=WinExist("A")
      WinGet, ProcID, PID, ahk_id %Awin%
			phandle:=DllCall("OpenProcess", "uint", 0x1000, "uint", 0, "uint", ProcID)
			isWow64process:=0
			DllCall("IsWow64Process", "uint", phandle, "int*", isWow64process)
			if (isWow64process)
			{
				Return, 0
			}
			else
			{
				Return, 1
			}
	  }
		else
		{
			Return, 0
		}
	}
	Return, 0
}

; retrieves the currently selected text and its start and end index as an object with the keys:
; SelectionStartIndex, SelectionEndIndex, SelectedText
GetAccessibleTextSelectionInfo(vmID, ac)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, JABVariables["MAX_STRING_SIZE"]*2+8,0)
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTextSelectionInfo", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Cdecl Int"))
		{
			jver:=NumGet(&Info,0,"Int")
			TempInfo["SelectionStartIndex"]:=jver
			jver:=NumGet(&Info,4,"Int")
			TempInfo["SelectionEndIndex"]:=jver
			verstr:=""
			Loop, % JABVariables["MAX_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+8
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.= jver
			}
			TempInfo["SelectedText"]:=verstr
			Return, TempInfo
		}
	}
	Return, 0
}

SelectTextRange32(vmID, ac, startIndex, endIndex)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
  	; find out if the JVM is running at 32 or 64 bit to circumvent a bug with the adress length in 32 bit JVMs (JRE 6+7)
		; this workaround seems not be necessary with JRE7update67 or later but seems to causes no trouble either
		;~ if (Is64bit(vmID, ac))
		;~ {
			;~ msgbox, miep
			;~ Return, DllCall(JABVariables["JAB_DLLVersion"] "\selectTextRange", "Int", vmID, JABVariables["acType"], ac, "Int", startIndex, "Int", endIndex, "Cdecl Int")
		;~ }
		;~ else
		;~ {
			Return, DllCall(JABVariables["JAB_DLLVersion"] "\selectTextRange", "Int", vmID, "Ptr", ac, "Int", startIndex, "Int", endIndex, "Cdecl Int")
		;~ }
	}
	Return, 0
}

SetCaretPosition64(vmID, ac, position)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
  	; find out if the JVM is running at 32 or 64 bit to circumvent a bug with the adress length in 32 bit JVMs (JRE 6+7)
		; this workaround seems not be necessary with JRE7update67 or later but seems to causes no trouble either
		;~ if (Is64bit(vmID, ac))
		;~ {
			Return, DllCall(JABVariables["JAB_DLLVersion"] "\setCaretPosition", "Int", vmID, JABVariables["acType"], ac, "Int", position, "Cdecl Int")
		;~ }
		;~ else
		;~ {
			;~ Return, DllCall(JABVariables["JAB_DLLVersion"] "\setCaretPosition", "Int", vmID, "Ptr", ac, "Int", position, "Cdecl Int")
		;~ }
	}
	Return, 0
}

SelectTextRange64(vmID, ac, startIndex, endIndex)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
  	; find out if the JVM is running at 32 or 64 bit to circumvent a bug with the adress length in 32 bit JVMs (JRE 6+7)
		; this workaround seems not be necessary with JRE7update67 or later but seems to causes no trouble either
		;~ if (Is64bit(vmID, ac))
		;~ {
			;~ msgbox, miep
			Return, DllCall(JABVariables["JAB_DLLVersion"] "\selectTextRange", "Int", vmID, JABVariables["acType"], ac, "Int", startIndex, "Int", endIndex, "Cdecl Int")
		;~ }
		;~ else
		;~ {
			;~ Return, DllCall(JABVariables["JAB_DLLVersion"] "\selectTextRange", "Int", vmID, "Ptr", ac, "Int", startIndex, "Int", endIndex, "Cdecl Int")
		;~ }
	}
	Return, 0
}

SetCaretPosition32(vmID, ac, position)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
  	; find out if the JVM is running at 32 or 64 bit to circumvent a bug with the adress length in 32 bit JVMs (JRE 6+7)
		; this workaround seems not be necessary with JRE7update67 or later but seems to causes no trouble either
		;~ if (Is64bit(vmID, ac))
		;~ {
			;~ Return, DllCall(JABVariables["JAB_DLLVersion"] "\setCaretPosition", "Int", vmID, JABVariables["acType"], ac, "Int", position, "Cdecl Int")
		;~ }
		;~ else
		;~ {
			Return, DllCall(JABVariables["JAB_DLLVersion"] "\setCaretPosition", "Int", vmID, "Ptr", ac, "Int", position, "Cdecl Int")
		;~ }
	}
	Return, 0
}

; retrieves the caret location as an object with the keys:
; Index, X, Y, Width, Height
GetCaretLocation(vmID, ac)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 16,0)
		Index:=0
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getCaretLocation", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Int", Index, "Cdecl Int"))
		{
			jver:=NumGet(&Info,0,"Int")
			TempInfo["X"]:=jver
			jver:=NumGet(&Info,4,"Int")
			TempInfo["Y"]:=jver
			jver:=NumGet(&Info,8,"Int")
			TempInfo["Width"]:=jver
			jver:=NumGet(&Info,12,"Int")
			TempInfo["Height"]:=jver
			TempInfo["Index"]:=Index
		}
		else
		{
			TempInfo:=
			Return, TempInfo
		}
	}
	Return TempInfo
}

; retrieves the location of position Index as an object with the keys:
; X, Y, Width, Height
GetAccessibleTextRect(vmID, ac, Index)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 16,0)
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTextRect", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Int", Index, "Cdecl Int"))
		{
			jver:=NumGet(&Info,0,"Int")
			TempInfo["X"]:=jver
			jver:=NumGet(&Info,4,"Int")
			TempInfo["Y"]:=jver
			jver:=NumGet(&Info,8,"Int")
			TempInfo["Width"]:=jver
			jver:=NumGet(&Info,12,"Int")
			TempInfo["Height"]:=jver
		}
		else
		{
			TempInfo:=
			Return, TempInfo
		}
	}
	Return TempInfo
}

; retrieves the start and end index of the line containing Index as an object with the keys:
; StartPos, EndPos
GetAccessibleTextLineBounds(vmID, ac, Index)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		StartPos:=0
		EndPos:=0
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTextLineBounds", "Int", vmID, JABVariables["acType"], ac, "Int*", &StartPos, "Int*", &EndPos, "Cdecl Int"))
		{
			TempInfo["StartPos"]:=StartPos
			TempInfo["EndPos"]:=EndPos
		}
		else
		{
			TempInfo:=
			Return, TempInfo
		}
	}
	Return TempInfo
}

; retrieves text between start and end index
GetAccessibleTextRange(vmID, ac, startc:=0, endc:=0)
{
	global JABVariables
	TempStr:=""
	if (JABVariables["JABInitialised"])
	{
		maxlen:=10000 ; arbitrary value, larger values tend to fail sometimes
		TInfo:=GetAccessibleTextInfo(vmID, ac)
		If IsObject(TInfo)
		{
			If (startc<0)
			{
				startc:=0
			}
			cnt:=startc
			If (endc=0 or endc>TInfo["CharCount"])
			{
				endc:=TInfo["CharCount"]
			}
			If (endc>0)
			{
				Loop,
				{
					if (cnt+maxlen>endc)
					{
						cnt2:=endc-1
					}
					else
					{
						cnt2:=cnt+maxlen
					}
          len:=maxlen+1
					VarSetCapacity(Txt, len*2,0)
					if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTextRange", "Int", vmID, JABVariables["acType"], ac, "Int", cnt, "Int", cnt2, "Ptr", &Txt, "Int", len, "Cdecl Int"))
					{
						NumPut(0,Txt,(cnt2-cnt+1)*2, "UChar")
            if (cnt2>cnt) and (NumGet(Txt,0,"UChar")=0) ; occasionally the first call fails at the end of the text
						{
              DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTextRange", "Int", vmID, JABVariables["acType"], ac, "Int", cnt, "Int", cnt2, "Ptr", &Txt, "Int", len, "Cdecl Int")
							NumPut(0,Txt,(cnt2-cnt+1)*2, "UChar")
						}
					  Loop, % maxlen+1
						{
							offset:=(A_Index-1)*2
							jver:=Chr(NumGet(&Txt,offset,"UChar"))
							if (jver=Chr(0))
							{
								break
							}
							TempStr.=jver
						}
					}
          if (cnt>=cnt2)
					{
						cnt++
					}
					else
					{
					  cnt:=cnt2+1
					}
          if (cnt>=endc-1)
						break
				}
			}
		}
	}
	Return TempStr
}

SetTextContents(vmID, ac, ntext)	; may not work properly before JRE7 Update 67
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		len := StrLen(ntext)
		VarSetCapacity(TempStr, len * 2 + 2, 0)
		Loop, Parse, ntext
		{
			offset:=(A_Index-1)*2
			NumPut(Asc(A_LoopField),TempStr,offset,"UChar")
		}
		Return, DllCall(JABVariables["JAB_DLLVersion"] "\setTextContents", "Int", vmID, JABVariables["acType"], ac, "UInt", &TempStr, "Cdecl Int")
	}
}

; retrieves the text attributes as an object with the keys:
; bold, italic, underline, strikethrough, superscript, subscript,
; backgroundColor, foregroundColor, fontFamily, fontSize,
; alignment, bidiLevel, firstLineIndent, leftIndent, rightIndent,
; lineSpacing, spaceAbove, spaceBelow, fullAttributesString
GetAccessibleTextAttributes(vmID, ac)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 3644,0)
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTextAttributes", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Cdecl Int"))
		{
			offset:=0
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["bold"]:=jver
			offset:=4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["italic"]:=jver
			offset:=8
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["underline"]:=jver
			offset:=12
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["strikethrough"]:=jver
			offset:=16
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["superscript"]:=jver
			offset:=20
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["subscript"]:=jver
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+24
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["backgroundColor"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+24+JABVariables["SHORT_STRING_SIZE"]*2
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["foregroundColor"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+24+JABVariables["SHORT_STRING_SIZE"]*4
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["fontFamily"]:=verstr
			offset:=24+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["fontSize"]:=jver
			offset:=28+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["alignment"]:=jver
			offset:=32+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["bidiLevel"]:=jver
			offset:=36+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["firstLineIndent"]:=jver
			offset:=40+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["leftIndent"]:=jver
			offset:=44+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["rightIndent"]:=jver
			offset:=48+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["lineSpacing"]:=jver
			offset:=52+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["spaceAbove"]:=jver
			offset:=56+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["spaceBelow"]:=jver
			verstr:=""
			Loop, % JABVariables["MAX_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+60+JABVariables["SHORT_STRING_SIZE"]*6
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.= jver
			}
			TempInfo["fullAttributesString"]:=verstr
		}
		else
		{
			msgbox, Error in GetAccessibleTextAttributes vmID: %vmID% ac: %ac%
		}
	}
	Return TempInfo
}

; retrieves the text items as an object with the keys:
; letter, word, sentence
GetAccessibleTextItems(vmID, ac, Index)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 2562,0)
		res:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTextItems", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Int", Index,  "Cdecl Int")
		if (res)
		{
			jver:=Chr(NumGet(&Info,0,"UChar"))
			TempInfo["letter"]:=jver
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+2
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr:=verstr jver
			}
			TempInfo["word"]:=verstr
			verstr:=""
			Loop, % JABVariables["MAX_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+2+JABVariables["SHORT_STRING_SIZE"]*2
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.= jver
			}
			TempInfo["sentence"]:=verstr
		}
		else
		{
			msgbox, Error in GetAccessibleTextItems vmID: %vmID% ac: %ac%
		}
	}
	Return TempInfo
}

; retrieves the text attributes as an object with the keys:
; bold, italic, underline, strikethrough, superscript, subscript,
; backgroundColor, foregroundColor, fontFamily, fontSize,
; alignment, bidiLevel, firstLineIndent, leftIndent, rightIndent,
; lineSpacing, spaceAbove, spaceBelow, fullAttributesString
GetTextAttributesInRange(vmID, ac, startc:=0, endc:=0)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 3644,0)
		len:=endc-startc+1
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getTextAttributesInRange", "Int", vmID, JABVariables["acType"], ac, "Int", startc, "Int", endc, "Ptr", &Info, "Int", len, "Cdecl Int"))
		{
			offset:=0
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["bold"]:=jver
			offset:=4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["italic"]:=jver
			offset:=8
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["underline"]:=jver
			offset:=12
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["strikethrough"]:=jver
			offset:=16
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["superscript"]:=jver
			offset:=20
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["subscript"]:=jver
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+24
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["backgroundColor"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+24+JABVariables["SHORT_STRING_SIZE"]*2
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["foregroundColor"]:=verstr
			verstr:=""
			Loop, % JABVariables["SHORT_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+24+JABVariables["SHORT_STRING_SIZE"]*4
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.=jver
			}
			TempInfo["fontFamily"]:=verstr
			offset:=24+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["fontSize"]:=jver
			offset:=28+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["alignment"]:=jver
			offset:=32+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["bidiLevel"]:=jver
			offset:=36+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["firstLineIndent"]:=jver
			offset:=40+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["leftIndent"]:=jver
			offset:=44+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["rightIndent"]:=jver
			offset:=48+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["lineSpacing"]:=jver
			offset:=52+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["spaceAbove"]:=jver
			offset:=56+JABVariables["SHORT_STRING_SIZE"]*6
			jver:=NumGet(&Info,offset,"Float")
			TempInfo["spaceBelow"]:=jver
			verstr:=""
			Loop, % JABVariables["MAX_STRING_SIZE"]
			{
				offset:=(A_Index-1)*2+60+JABVariables["SHORT_STRING_SIZE"]*6
				jver:=Chr(NumGet(&Info,offset,"UChar"))
				if (jver=Chr(0))
				{
					break
				}
				verstr.= jver
			}
			TempInfo["fullAttributesString"]:=verstr
		}
		else
		{
			msgbox, Error in GetTextAttributesInRange vmID: %vmID% ac: %ac%
		}
	}
	Return TempInfo
}

; AccessibleTable

; retrieves the table information as an object with the keys:
; caption (AccesibleContext), summary (AccesibleContext), rowCount,
; columnCount, accessibleContext, accessibleTable
GetAccessibleTableInfo(vmID, ac)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 40,0)
		len:=endc-startc+1
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableInfo", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Cdecl Int"))
		{
			offset:=0
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["caption"]:=jver
			offset:=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["summary"]:=jver
			offset+=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["rowCount"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["columnCount"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["accessibleContext"]:=jver
			offset+=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["accessibleTable"]:=jver
		}
		else
		{
			msgbox, Error in GetAccessibleTableInfo vmID: %vmID% ac: %ac%
		}
	}
	Return TempInfo
}

; retrieves the table cell information as an object with the keys:
; accessibleContext, index, row, column, rowExtent, columnExtent, isSelected
GetAccessibleTableCellInfo(vmID, ac, row, column)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 28,0)
		len:=endc-startc+1
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableCellInfo", "Int", vmID, JABVariables["acType"], ac, "Int", row, "Int", column, "Ptr", &Info, "Cdecl Int"))
		{
			offset:=0
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["index"]:=jver
			offset:=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["row"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["column"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["rowExtent"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["columnExtent"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["isSelected"]:=jver
		}
		else
		{
			msgbox, Error in GetAccessibleTableCellInfo vmID: %vmID% ac: %ac%
		}
	}
	Return TempInfo
}

; retrieves the table row header information as an object with the keys:
; caption (AccesibleContext), summary (AccesibleContext), rowCount,
; columnCount, accessibleContext, accessibleTable
GetAccessibleTableRowHeader(vmID, ac)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 40,0)
		len:=endc-startc+1
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableRowHeader", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Cdecl Int"))
		{
			offset:=0
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["caption"]:=jver
			offset:=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["summary"]:=jver
			offset+=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["rowCount"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["columnCount"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["accessibleContext"]:=jver
			offset+=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["accessibleTable"]:=jver
		}
		else
		{
			msgbox, Error in GetAccessibleTableRowHeader vmID: %vmID% ac: %ac%
		}
	}
	Return TempInfo
}

; retrieves the table column header information as an object with the keys:
; caption (AccesibleContext), summary (AccesibleContext), rowCount,
; columnCount, accessibleContext, accessibleTable
GetAccessibleTableColumnHeader(vmID, ac)
{
	global JABVariables
	TempInfo:=Object()
	if (JABVariables["JABInitialised"])
	{
		VarSetCapacity(Info, 40,0)
		len:=endc-startc+1
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableColumnHeader", "Int", vmID, JABVariables["acType"], ac, "Ptr", &Info, "Cdecl Int"))
		{
			offset:=0
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["caption"]:=jver
			offset:=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["summary"]:=jver
			offset+=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["rowCount"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,"Int")
			TempInfo["columnCount"]:=jver
			offset+=4
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["accessibleContext"]:=jver
			offset+=JABVariables["acSize"]
			jver:=NumGet(&Info,offset,JABVariables["acType"])
			TempInfo["accessibleTable"]:=jver
		}
		else
		{
			msgbox, Error in GetAccessibleTableColumnHeader vmID: %vmID% ac: %ac%
		}
	}
	Return TempInfo
}

GetAccessibleTableRowDescription(vmID, ac, row)
{
	global JABVariables
	acchild:=0
	if (JABVariables["JABInitialised"])
	{
		acchild:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableRowDescription", "Int", vmID, JABVariables["acType"], ac, "Int", row, "Cdecl "JABVariables["acType"])
	}
	Return, acchild
}

GetAccessibleTableColumnDescription(vmID, ac, column)
{
	global JABVariables
	acchild:=0
	if (JABVariables["JABInitialised"])
	{
		acchild:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableColumnDescription", "Int", vmID, JABVariables["acType"], ac, "Int", column, "Cdecl "JABVariables["acType"])
	}
	Return, acchild
}

GetAccessibleTableRowSelectionCount(vmID, ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		cnt:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableRowSelectionCount", "Int", vmID, JABVariables["acType"], ac, "Cdecl Int")
	}
	Return, cnt
}

IsAccessibleTableRowSelected(vmID, ac, row)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		cnt:=DllCall(JABVariables["JAB_DLLVersion"] "\isAccessibleTableRowSelected", "Int", vmID, JABVariables["acType"], ac, "Int", row, "Cdecl Int")
	}
	Return, cnt
}

GetAccessibleTableRowSelections(vmID, ac)
{
	global JABVariables
	Children:=Object()
	if (JABVariables["JABInitialised"])
	{
		NumChild:=GetAccessibleTableRowSelectionCount(vmID, ac)
		cnt:=0
		VarSetCapacity(TempChildren, 64*JABVariables["acSize"],0)
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableRowSelections", "Int", vmID, JABVariables["acType"], ac, "Int", NumChild, "Ptr", &TempChildren, "Cdecl Int"))
		{
			retchild:=NumGet(&TempChildren,0,"Int")
			str:=retchild ";;"
			Loop, %retchild%
			{
				Children[++cnt]:=Numget(&TempChildren, JABVariables["acSize"]*(A_Index), JABVariables["acType"])
			}
		}
	}
	Return Children
}

GetAccessibleTableColumnSelectionCount(vmID, ac)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		cnt:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableColumnSelectionCount", "Int", vmID, JABVariables["acType"], ac, "Cdecl Int")
	}
	Return, cnt
}

IsAccessibleTableColumnSelected(vmID, ac, row)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		cnt:=DllCall(JABVariables["JAB_DLLVersion"] "\isAccessibleTableColumnSelected", "Int", vmID, JABVariables["acType"], ac, "Int", row, "Cdecl Int")
	}
	Return, cnt
}

GetAccessibleTableColumnSelections(vmID, ac)
{
	global JABVariables
	Children:=Object()
	if (JABVariables["JABInitialised"])
	{
		NumChild:=GetAccessibleTableColumnSelectionCount(vmID, ac)
		VarSetCapacity(TempChildren, 64*JABVariables["acSize"],0)
		if (DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableColumnSelections", "Int", vmID, JABVariables["acType"], ac, "Int", NumChild, "Ptr", &TempChildren, "Cdecl Int"))
		{
			retchild:=NumGet(&TempChildren,0,"Int")
			str:=retchild ";;"
			Loop, %retchild%
			{
				Children[++cnt]:=Numget(&TempChildren, JABVariables["acSize"]*(A_Index), JABVariables["acType"])
			}
		}
	}
	Return Children
}

GetAccessibleTableRow(vmID, ac, index)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		cnt:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableRow", "Int", vmID, JABVariables["acType"], ac, "Int", index, "Cdecl Int")
	}
	Return, cnt
}

GetAccessibleTableColumn(vmID, ac, index)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		cnt:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableColumn", "Int", vmID, JABVariables["acType"], ac, "Int", index, "Cdecl Int")
	}
	Return, cnt
}

GetAccessibleTableIndex(vmID, ac, row, column)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		cnt:=DllCall(JABVariables["JAB_DLLVersion"] "\getAccessibleTableIndex", "Int", vmID, JABVariables["acType"], ac, "Int", row, "Int", column, "Cdecl Int")
	}
	Return, cnt
}

; callback set routines
; see access bridge documentation for definitions of callback funtions
;
; usage:
;
; if InitJavaAccessBridge()
; {
;   Address := RegisterCallback("FocusGained","CDecl")
;   setFocusGainedFP(Address)
; }
; ...
; Return
;
; FocusGained(vmID, event, source)
; {
;   DoSomething(vmID, source)
;   ReleaseJavaObject(vmID,event)
;   ReleaseJavaObject(vmID,source)
; }

setFocusGainedFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setFocusGainedFP", "UInt", fp, "Cdecl")
	}
}

setFocusLostFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setFocusLostFP", "UInt", fp, "Cdecl")
	}
}

setJavaShutdownFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setJavaShutdownFP", "UInt", fp, "Cdecl")
	}
}

setCaretUpdateFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setCaretUpdateFP", "UInt", fp, "Cdecl")
	}
}

setMouseClickedFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setMouseClickedFP", "UInt", fp, "Cdecl")
	}
}

setMouseEnteredFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setMouseEnteredFP", "UInt", fp, "Cdecl")
	}
}

setMouseExitedFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setMouseExitedFP", "UInt", fp, "Cdecl")
	}
}

setMousePressedFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setMousePressedFP", "UInt", fp, "Cdecl")
	}
}

setMouseReleasedFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setMouseReleasedFP", "UInt", fp, "Cdecl")
	}
}

setMenuCanceledFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setMenuCanceledFP", "UInt", fp, "Cdecl")
	}
}

setMenuDeselectedFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setMenuDeselectedFP", "UInt", fp, "Cdecl")
	}
}

setMenuSelectedFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setMenuSelectedFP", "UInt", fp, "Cdecl")
	}
}

setPopupMenuCanceledFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPopupMenuCanceledFP", "UInt", fp, "Cdecl")
	}
}

setPopupMenuWillBecomeInvisibleFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPopupMenuWillBecomeInvisibleFP", "UInt", fp, "Cdecl")
	}
}

setPopupMenuWillBecomeVisibleFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPopupMenuWillBecomeVisibleFP", "UInt", fp, "Cdecl")
	}
}

setPropertyNameChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyNameChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyDescriptionChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyDescriptionChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyStateChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyStateChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyValueChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyValueChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertySelectionChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertySelectionChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyTextChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyTextChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyCaretChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyCaretChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyVisibleDataChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyVisibleDataChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyChildChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyChildChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyActiveDescendentChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyActiveDescendentChangeFP", "UInt", fp, "Cdecl")
	}
}

setPropertyTableModelChangeFP(fp)
{
	global JABVariables
	if (JABVariables["JABInitialised"])
	{
		DllCall(JABVariables["JAB_DLLVersion"] "\setPropertyTableModelChangeFP", "UInt", fp, "Cdecl")
	}
}

/*
functions that have not been ported yet

{ exported user functions of the Java Access Bridge }


{ AccessibleRelationSet }
function getAccessibleRelationSet(vmID: longint; ac: AccessibleContext; relationSetInfo: PAccessibleRelationSetInfo):JBool;

{ AccessibleHypertext }
function getAccessibleHypertext(vmID: longint; ac: AccessibleContext; hypertextInfo: PAccessibleHypertextInfo):JBool;
function activateAccessibleHyperlink(vmID: longint; ac: AccessibleContext; aH: AccessibleHyperlink):JBool;
function getAccessibleHyperlinkCount(vmID: longint; ac: AccessibleContext):Jint;
function getAccessibleHypertextExt(vmID: longint; ac: AccessibleContext; nStartIndex: jint; hypertextInfo: PAccessibleHypertextInfo):JBool;
function getAccessibleHypertextLinkIndex(vmID: longint; ah: AccessibleHypertext; nIndex: jint):jint;
function getAccessibleHyperlink(vmID: longint; ah: AccessibleHypertext; nIndex: jint; hyperlinkInfo: PAccessibleHyperlinkInfo):JBool;

{ Accessible KeyBindings, Icons and Actions }
function getAccessibleKeyBindings(vmID: longint; ac: AccessibleContext; keyBindings: PAccessibleKeyBindings):JBool;
function getAccessibleIcons(vmID: longint; ac: AccessibleContext; icons: PAccessibleIcons):JBool;

{ AccessibleText }
getCurrentAccessibleValueFromContext
getMaximumAccessibleValueFromContext
getMinimumAccessibleValueFromContext

function GetCurrentAccessibleValueFromContext(vmID: longint; av: AccessibleValue; value: pwidechar; len: jshort):JBool;
function GetMaximumAccessibleValueFromContext(vmID: longint; av: AccessibleValue; value: pwidechar; len: jshort):JBool;
function GetMinimumAccessibleValueFromContext(vmID: longint; av: AccessibleValue; value: pwidechar; len: jshort):JBool;

procedure AddAccessibleSelectionFromContext(vmID: longint; acsel: AccessibleSelection; i: Jint);
procedure ClearAccessibleSelectionFromContext(vmID: longint; acsel: AccessibleSelection);
function GetAccessibleSelectionFromContext(vmID: longint; acsel: AccessibleSelection; i: jint):JObject;
function GetAccessibleSelectionCountFromContext(vmID: longint; acsel: AccessibleSelection):Jint;
function IsAccessibleChildSelectedFromContext(vmID: longint; acsel: AccessibleSelection; i: Jint):Jbool;
procedure RemoveAccessibleSelectionFromContext(vmID: longint; acsel: AccessibleSelection; i: Jint);
procedure SelectAllAccessibleSelectionFromContext(vmID: longint; acsel: AccessibleSelection);

{ Utility methods }
function getVirtualAccessibleName(vmID: longint; ac: AccessibleContext; name: pwidechar; len: integer):JBool;
function getTextAttributesInRange(vmID: longint; ac: AccessibleContext; startIndex: integer; endIndex: integer; attributes: PAccessibleTextAttributesInfo; len: Jshort): JBool;
function getEventsWaiting():Jint;

{ All unported functions in Windowsaccessbridge32.dll }
activateAccessibleHyperlink
getAccessibleHyperlink
getAccessibleHyperlinkCount
getAccessibleHypertext
getAccessibleHypertextExt
getAccessibleHypertextLinkIndex

addAccessibleSelectionFromContext
clearAccessibleSelectionFromContext
getAccessibleSelectionCountFromContext
getAccessibleSelectionFromContext
isAccessibleChildSelectedFromContext
removeAccessibleSelectionFromContex
selectAllAccessibleSelectionFromContext

getAccessibleIcons
getAccessibleKeyBindings
getAccessibleRelationSet
getEventsWaiting
getVirtualAccessibleName
*/
