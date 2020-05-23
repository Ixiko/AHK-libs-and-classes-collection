; todo:

; GetCaretLocation: check if index does anything, else remove
; Getvisiblechildren test if retchild:=NumGet(&TempChildren, 0, "Int64") works under 64 bit

class JavaAccessBridge extends JavaAccessBridgeBase
{
	; The function JavaControlDoAction searches for the <occurrence>-instance of a Java-control that fits in <name>, <role> and <description> and performs <action> <count>-times
	; actions can be all actions provided by the control itself or:
	; - focus: attempts to focus the control and left clicks it if focusing fails
	; - check pos: tries if the object has a valid screen location
	; - left/double/right/middle click; wheel up/down: performs the respective mouse action in the center of the control
	ControlDoAction(HWND:=0, Name:="", Role:="", Description:="", Occurrence:="", Action:="", Times:=1, ParentContext:=0)
	{
		control:=this.ControlGet(HWND, Name, Role, Description, Occurrence, ParentContext)
		If (control>0)
		{
			Info:=control.getAccessibleContextInfo()
			Loop, %Times%
			{
				if (Action="check pos")
				{
					If !(Info.X=-1 and Info.Width=-1 and Info.Y=-1 and Info.Height=-1)
						return, 0
					else
						return, -3
				}
				if (Action="focus")
				{
					If (Instr(Info.States,"focusable"))
					{
						failure:=control.RequestFocus()
						if (failure<>0)
						{
							rval:=control.MouseClick()
						}
					}
					else
						return, -2
				}
				else if Action in % this.MouseClickActions
				{
					rval:=control.MouseClick(Action)
				}
				else
				{
					rval:=control.DoAccessibleActions(Action)
				}
				If (Times>A_Index)
					Sleep, 50
			}
			return, rval
		}
		else
			return control
	}

	ControlGet(HWND:=0, Name:="", Role:="", Description:="", Occurrence:="", ParentContext:=0)
	{
		root:=0
		If (ParentContext__Class()="JavaAccessibleContext"))
		{
			root:=ParentContext
		}
		else
		{
			if (!HWND)
				currwin:=this.GetJavaHWNDWithFocus()
			else
				currwin:=HWND
			if (this.IsJavaWindow(currwin))
			{
				root:=this.GetAccessibleContextFromHWND(currwin)
			}
		}
		If (root)
		{
			If (occurrence>1)
			{
				Loop, 2
				{
					If (this.IsSameObject(this.CachedParent,root))
					{
						Children:=this.CachedChildren
					}
					else
					{
						Children:=root.GetVisibleChildrenFromTree()
						this.CachedChildren:=Children
						this.CachedParent:=root
					}
					occurcnt:=0
					For index, child in Children
					{
						Info:=child.getAccessibleContextInfo()
						if ((Name="" or RegExMatch(Info.Name, Name))
							and (Role="" or Role=Info.Role)
							and (Description="" or RegExMatch(Info.Description, Description)))
						{
							occurcnt++
							if (Occurrence=occurcnt or Occurrence=0 or Occurrence="")
							{
								return child
							}
						}
					}
					this.CachedParent:=0
				}
			}
			else
			{
				retval:=root.FindVisibleChild(Name, Role, Description)
				if (retval)
					return retval
				else
					return -3
			}
		}
	}

	GetAccessibleContextAt(hwnd, x, y)
	{
		root:=this.GetAccessibleContextFromHWND(hwnd)
		return, this.FindContextAt(root, x, y)
	}

	; recursion for GetAccessibleContextAt
	; do not use separately
	FindContextAt(root, x, y)
	{
		Info:=root.getAccessibleContextInfo()
		If (Instr(Info.States,"visible"))
		{
			resac:=0
			Loop, % Info.ChildrenCount
			{
				tmpac:=root.GetAccessibleChildFromContext(A_Index-1)
				resrec:=this.FindContextAt(tmpac, x, y)
				If (resrec<>0)
					resac:=resrec
			}
			If ((resac=0) and (x>=Info.x) and (x<=(Info.x+Info.Width)) and (y>=Info.y) and (y<=(Info.y+Info.Height)))
			{
				return, root
			}
			else
				return, resac
		}
		else
			return, 0
	}

	; retrieves HWND of the focused Java window or child window e. g. if embedded in a browser
	GetJavaHWNDWithFocus()
	{
		hwnd:=WinExist("A")
		if (!this.IsJavaWindow(hwnd))
		{
			ControlGetFocus, currctrl, % "ahk_id " hwnd
			ControlGet, currwin2, Hwnd, , %currctrl%, % "ahk_id " hwnd
			if (this.IsJavaWindow(currwin2))
				return, currwin2
		}
		else
			return, hwnd
	}

	GetTextInfo()
	{
		txt:=""
		currwin:=this.GetJavaHWNDWithFocus()
		if (currwin)
		{
			control:=this.GetAccessibleContextWithFocus(currwin)
		}
		If (control)
		{
			Info:=control.GetAccessibleContextInfo()
			If (Info.AccessibleTextInterface)
			{
				res:=control.GetCaretLocation()
				caretmx:=res.X+res.Width//2
				caretmy:=res.Y+res.Height//2
				txt.="GetCaretLocation`n"
				txt.="X: " res.X " Y: " res.Y " Width: " res.Width " Height: " res.Height "`n"
				res:=control.GetAccessibleTextInfo(caretmx, caretmy)
				txt.="GetAccessibleTextInfo`n"
				txt.="CharCount: " res.CharCount " CaretIndex: " res.CaretIndex " IndexAtPoint (mid cursor): " res.IndexAtPoint "`n"
				caretindex:=res.CaretIndex
				res:=control.GetAccessibleTextItems(caretindex)
				txt.="GetAccessibleTextItems`n"
				txt.="letter: " res.letter " word: " res.word " sentence: " res.sentence "`n"
				res:=control.GetAccessibleTextSelectionInfo()
				txt.="GetAccessibleTextSelectionInfo`n"
				txt.="SelectionStartIndex: " res.SelectionStartIndex " SelectionEndIndex: " res.SelectionEndIndex " SelectedText: " res.SelectedText "`n"
				res:=control.GetAccessibleTextRange(caretindex-5, caretindex+5)
				txt.="GetAccessibleTextRange`n"
				txt.="Text: " res "`n"
				res:=control.GetAccessibleTextRect(caretindex)
				txt.="GetAccessibleTextRect`n"
				txt.="X: " res.X " Y: " res.Y " Width: " res.Width " Height: " res.Height "`n"
				res:=control.GetAccessibleTextLineBounds(caretindex)
				txt.="GetAccessibleTextLineBounds`n"
				txt.="StartPos: " res.StartPos " EndPos: " res.EndPos "`n"

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
		;~ GetTextAttributesInRange(vmID, ac, startc=0, endc=0)
					;~ txt.=" : "  " : "  " : "  "`n"

			}
			else
				txt:="Current accessible context does not have an accessible text interface."
		}
		else
			txt:="No valid accessible context with focus found."
		return, txt
	}
}

class JavaAccessBridgeBase
{
	DLLVersion:=""
	DLLHandle:=""
	acType:="Int64"
	acPType:="Int64*"
	acSize:=8
	CachedParent:=0
	CachedChildren:=
	BlockedRoles:="panel,filler,root pane,layered pane,menu bar,tool bar,separator,split pane,viewport,scroll bar,scroll pane"
	HandledDefaultActions:="focus|check pos|left click|double click|right click|middle click|wheel up|wheel down"
	MouseClickActions:="left click,double click,right click,middle click,wheel up,wheel down"

	static MAX_BUFFER_SIZE:=10240
	static MAX_STRING_SIZE:=1024
	static SHORT_STRING_SIZE:=256

	static ACCESSIBLE_ALERT:="alert"
	static ACCESSIBLE_COLUMN_HEADER:="column header"
	static ACCESSIBLE_CANVAS:="canvas"
	static ACCESSIBLE_COMBO_BOX:="combo box"
	static ACCESSIBLE_DESKTOP_ICON:="desktop icon"
	static ACCESSIBLE_INTERNAL_FRAME:="internal frame"
	static ACCESSIBLE_DESKTOP_PANE:="desktop pane"
	static ACCESSIBLE_OPTION_PANE:="option pane"
	static ACCESSIBLE_WINDOW:="window"
	static ACCESSIBLE_FRAME:="frame"
	static ACCESSIBLE_DIALOG:="dialog"
	static ACCESSIBLE_COLOR_CHOOSER:="color chooser"
	static ACCESSIBLE_DIRECTORY_PANE:="directory pane"
	static ACCESSIBLE_FILE_CHOOSER:="file chooser"
	static ACCESSIBLE_FILLER:="filler"
	static ACCESSIBLE_HYPERLINK:="hyperlink"
	static ACCESSIBLE_ICON:="icon"
	static ACCESSIBLE_LABEL:="label"
	static ACCESSIBLE_ROOT_PANE:="root pane"
	static ACCESSIBLE_GLASS_PANE:="glass pane"
	static ACCESSIBLE_LAYERED_PANE:="layered pane"
	static ACCESSIBLE_LIST:="list"
	static ACCESSIBLE_LIST_ITEM:="list item"
	static ACCESSIBLE_MENU_BAR:="menu bar"
	static ACCESSIBLE_POPUP_MENU:="popup menu"
	static ACCESSIBLE_MENU:="menu"
	static ACCESSIBLE_MENU_ITEM:="menu item"
	static ACCESSIBLE_SEPARATOR:="separator"
	static ACCESSIBLE_PAGE_TAB_LIST:="page tab list"
	static ACCESSIBLE_PAGE_TAB:="page tab"
	static ACCESSIBLE_PANEL:="panel"
	static ACCESSIBLE_PROGRESS_BAR:="progress bar"
	static ACCESSIBLE_PASSWORD_TEXT:="password text"
	static ACCESSIBLE_PUSH_BUTTON:="push button"
	static ACCESSIBLE_TOGGLE_BUTTON:="toggle button"
	static ACCESSIBLE_CHECK_BOX:="check box"
	static ACCESSIBLE_RADIO_BUTTON:="radio button"
	static ACCESSIBLE_ROW_HEADER:="row header"
	static ACCESSIBLE_SCROLL_PANE:="scroll pane"
	static ACCESSIBLE_SCROLL_BAR:="scroll bar"
	static ACCESSIBLE_VIEWPORT:="viewport"
	static ACCESSIBLE_SLIDER:="slider"
	static ACCESSIBLE_SPLIT_PANE:="split pane"
	static ACCESSIBLE_TABLE:="table"
	static ACCESSIBLE_TEXT:="text"
	static ACCESSIBLE_TREE:="tree"
	static ACCESSIBLE_TOOL_BAR:="tool bar"
	static ACCESSIBLE_TOOL_TIP:="tool tip"
	static ACCESSIBLE_AWT_COMPONENT:="awt component"
	static ACCESSIBLE_SWING_COMPONENT:="swing component"
	static ACCESSIBLE_UNKNOWN:="unknown"
	static ACCESSIBLE_STATUS_BAR:="status bar"
	static ACCESSIBLE_DATE_EDITOR:="date editor"
	static ACCESSIBLE_SPIN_BOX:="spin box"
	static ACCESSIBLE_FONT_CHOOSER:="font chooser"
	static ACCESSIBLE_GROUP_BOX:="group box"
	static ACCESSIBLE_HEADER:="header"
	static ACCESSIBLE_FOOTER:="footer"
	static ACCESSIBLE_PARAGRAPH:="paragraph"
	static ACCESSIBLE_RULER:="ruler"
	static ACCESSIBLE_EDITBAR:="editbar"
	static PROGRESS_MONITOR:="progress monitor"
	
	__New(ForceLegacy:=0)
	{
		if (ForceLegacy=1)
		{
			this.DLLVersion:="WindowsAccessBridge"
			this.DLLHandle:=DllCall("LoadLibrary", "Str", this.DLLVersion ".dll")
			this.acType:="Int"
			this.acPType:="Int*"
			this.acSize:=4
		}
		else
		if (A_PtrSize=8)
		{
			this.DLLVersion:="WindowsAccessBridge-64"
			this.DLLHandle:=DllCall("LoadLibrary", "Str", this.DLLVersion ".dll")
		}
		else
		{
			this.DLLVersion:="WindowsAccessBridge-32"
			this.DLLHandle:=DllCall("LoadLibrary", "Str", this.DLLVersion ".dll")
			if (this.DLLHandle=0)
			{
				this.DLLVersion:="WindowsAccessBridge"
				this.DLLHandle:=DllCall("LoadLibrary", "Str", this.DLLVersion ".dll")
				this.acType:="Int"
				this.acPType:="Int*"
				this.acSize:=4
			}
		}
		; it is necessary to preload the DLL
		; otherwise none of the calls suceed

		; start up the access bridge
		If (!DllCall(this.DLLVersion "\Windows_run", "Cdecl Int"))
		{
			; Initialisation failed. Clean up.
			DllCall("FreeLibrary", "Ptr", this.DLLHandle)
			Return, 0
		}
		; it is necessary to give the application a few message cycles time before calling access bridge function
		; otherwise all calls will fail
		Sleep, 200 ; minimum 100 for all machines?
	}

	__Delete()
	{
		if (this.Initialised)
		{
			DllCall("FreeLibrary", "Ptr", this.DLLHandle)
		}
	}

	; retrieves the root element from a window
	GetAccessibleContextFromHWND(hwnd)
	{
		vmID:=0
		ac:=0
		If (DllCall(this.DLLVersion "\getAccessibleContextFromHWND", "Int", hWnd, "Int*", vmID, this.acPType, ac, "Cdecl Int"))
		{
			return new JavaAccessibleContext(vmID,ac,this)
		}
		else
			return 0
	}

	GetAccessibleContextWithFocus(hwnd)
	{
		vmID:=0
		ac:=0
		If (DllCall(this.DLLVersion "\getAccessibleContextWithFocus", "Int", hwnd, "Int*", vmID, this.acPType, ac, "Cdecl Int"))
		{
			return new JavaAccessibleContext(vmID, ac, this)
		}
		else
			return 0
	}

	; returns JAB version information as object containing the keys:
	; VMversion, bridgeJavaClassVersion, bridgeJavaDLLVersion, bridgeWinDLLVersion
	GetVersionInfo(vmID)
	{
		VarSetCapacity(Info, 2048,0)
		if (DllCall(this.DLLVersion "\getVersionInfo", "Int", vmID, "UInt", &Info, "Cdecl Int"))
		{
			TempInfo:=Object()
			Offset:=0
			TempInfo["VMversion"]:=GetJavaString(Info, Offset, this.SHORT_STRING_SIZE)
			TempInfo["bridgeJavaClassVersion"]:=GetJavaString(Info, Offset, this.SHORT_STRING_SIZE)
			TempInfo["bridgeJavaDLLVersion"]:=GetJavaString(Info, Offset, this.SHORT_STRING_SIZE)
			TempInfo["bridgeWinDLLVersion"]:=GetJavaString(Info, Offset, this.SHORT_STRING_SIZE)
			return TempInfo
		}
		else
			return 0
	}

	IsJavaWindow(hwnd)
	{
		return DllCall(this.DLLVersion "\isJavaWindow", "Int", hWnd, "Cdecl Int")
	}

	IsSameObject(JAObj1, JAObj2)
	{
		If (JAObj1.__Class="JavaAccessibleContext" and JAObj2.__Class="JavaAccessibleContext" and JAObj1.vmID=JAObj2.vmID)
		{
			Return DllCall(this.DLLVersion "\isSameObject", "Int", JAObj1.vmID, this.acType, JAObj1.ac, this.acType, JAObj2.ac, "Cdecl Int")
		}
		else
			return 0
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
		DllCall(this.DLLVersion "\setFocusGainedFP", "UInt", fp, "Cdecl")
	}

	setFocusLostFP(fp)
	{
		DllCall(this.DLLVersion "\setFocusLostFP", "UInt", fp, "Cdecl")
	}

	setJavaShutdownFP(fp)
	{
		DllCall(this.DLLVersion "\setJavaShutdownFP", "UInt", fp, "Cdecl")
	}

	setCaretUpdateFP(fp)
	{
		DllCall(this.DLLVersion "\setCaretUpdateFP", "UInt", fp, "Cdecl")
	}

	setMouseClickedFP(fp)
	{
		DllCall(this.DLLVersion "\setMouseClickedFP", "UInt", fp, "Cdecl")
	}

	setMouseEnteredFP(fp)
	{
		DllCall(this.DLLVersion "\setMouseEnteredFP", "UInt", fp, "Cdecl")
	}

	setMouseExitedFP(fp)
	{
		DllCall(this.DLLVersion "\setMouseExitedFP", "UInt", fp, "Cdecl")
	}

	setMousePressedFP(fp)
	{
		DllCall(this.DLLVersion "\setMousePressedFP", "UInt", fp, "Cdecl")
	}

	setMouseReleasedFP(fp)
	{
		DllCall(this.DLLVersion "\setMouseReleasedFP", "UInt", fp, "Cdecl")
	}

	setMenuCanceledFP(fp)
	{
		DllCall(this.DLLVersion "\setMenuCanceledFP", "UInt", fp, "Cdecl")
	}

	setMenuDeselectedFP(fp)
	{
		DllCall(this.DLLVersion "\setMenuDeselectedFP", "UInt", fp, "Cdecl")
	}

	setMenuSelectedFP(fp)
	{
		DllCall(this.DLLVersion "\setMenuSelectedFP", "UInt", fp, "Cdecl")
	}

	setPopupMenuCanceledFP(fp)
	{
		DllCall(this.DLLVersion "\setPopupMenuCanceledFP", "UInt", fp, "Cdecl")
	}

	setPopupMenuWillBecomeInvisibleFP(fp)
	{
		DllCall(this.DLLVersion "\setPopupMenuWillBecomeInvisibleFP", "UInt", fp, "Cdecl")
	}

	setPopupMenuWillBecomeVisibleFP(fp)
	{
		DllCall(this.DLLVersion "\setPopupMenuWillBecomeVisibleFP", "UInt", fp, "Cdecl")
	}

	setPropertyNameChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyNameChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyDescriptionChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyDescriptionChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyStateChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyStateChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyValueChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyValueChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertySelectionChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertySelectionChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyTextChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyTextChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyCaretChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyCaretChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyVisibleDataChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyVisibleDataChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyChildChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyChildChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyActiveDescendentChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyActiveDescendentChangeFP", "UInt", fp, "Cdecl")
	}

	setPropertyTableModelChangeFP(fp)
	{
		DllCall(this.DLLVersion "\setPropertyTableModelChangeFP", "UInt", fp, "Cdecl")
	}
}

class JavaAccessibleContext
{
	vmID:=0
	ac:=0
	JAB:=""

	__New(vmID, ac, JAB)
	{
		If (vmID and ac and IsObject(JAB))
		{
			this.vmID:=vmID
			this.ac:=ac
			this.JAB:=JAB
		}
		else
			return, 0
	}

	__Delete()
	{
		DllCall(this.JAB.DLLVersion "\ReleaseJavaObject", "Int", this.vmID, this.JAB.acType, this.ac, "Cdecl")
	}
	
	GetVisibleChild(Name:="", Role:="", Description:="")
	{
		retval:=0
		Info:=this.GetAccessibleContextInfo()
		If (Instr(Info.States,"visible"))
		{
			if ((Name="" or RegExMatch(Info.Name,Name))
				and (Role="" or Role=Info.Role)
				and (Description="" or RegExMatch(Info.Description,Description)))
			{
				retval:=new JavaAccessibleContext(this.vmID, this.ac, this.JAB)
			}
			if (!retval)
			{
				Loop, % Info.ChildrenCount
				{
					retval:=this.GetAccessibleChildFromContext(A_Index-1).GetVisibleChild(Name, Role, Description)
					if (retval)
						break
				}
			}
		}
		return, retval
	}

	; retrieves an object with all children of the input control
	GetAllChildrenFromTree()
	{
		Children:=Object()
		this.RecurseAllChildren(Children)
		return, Children
	}

	; recursion for RecurseAllChildren
	; do not use separately
	RecurseAllChildren(Children)
	{
		Info:=this.GetAccessibleContextInfo()
		Children.Push(new JavaAccessibleContext(this.vmID, this.ac, this.JAB))
		Loop, % Info.ChildrenCount
		{
			this.GetAccessibleChildFromContext(A_Index-1).RecurseAllChildren(Children)
		}
	}

	; used to retrieve an object with all visible children of the input control
	GetVisibleChildrenFromTree()
	{
		Children:=Object()
		this.RecurseVisibleChildren(Children)
		return, Children
	}

	; recursion for RecurseControllableChildren
	; do not use separately
	RecurseVisibleChildren(Children)
	{
		Info:=this.GetAccessibleContextInfo()
		If (Instr(Info.States,"visible"))
		{
			Children.Push(new JavaAccessibleContext(this.vmID, this.ac, this.JAB))
			Loop, % Info.ChildrenCount
			{
				this.GetAccessibleChildFromContext(A_Index-1).RecurseVisibleChildren(Children)
			}
		}
	}

	; used to retrieve an object with all children that are likely to be controlled
	GetControllableChildrenFromTree()
	{
		Children:=Object()
		this.RecurseControllableChildren(Children)
		return, Children
	}

	; recursion for RecurseControllableChildren
	; do not use separately
	RecurseControllableChildren(Children)
	{
		Info:=this.GetAccessibleContextInfo()
		If (Instr(Info.States,"visible"))
		{
			blockedroles:=this.JAB.BlockedRoles
			role:=Info.Role
			If role not in %blockedroles%
				Children.Push(new JavaAccessibleContext(this.vmID, this.ac, this.JAB))
			Loop, % Info.ChildrenCount
			{
				this.GetAccessibleChildFromContext(A_Index-1).RecurseControllableChildren(Children)
			}
		}
	}
	
	GetControlTree(Invisible:=0)
	{
		RetObj:=Object()
		Info:=this.GetAccessibleContextInfo()
		If (Instr(Info.States,"visible") or Invisible)
		{
			RetObj.AC:=new JavaAccessibleContext(this.vmID, this.ac, this.JAB)
			RetObj.Children:=Object()
			Loop, % Info.ChildrenCount
			{
				rac:=this.GetAccessibleChildFromContext(A_Index-1)
				RetObj.Children[A_Index-1]:=rac.GetControlTree(Invisible)
			}
		}
		return, RetObj
	}

	; performs mouse clicks in the center of the specified control
	MouseClick(action:="left", count:=1)
	{
		Info:=this.GetAccessibleContextInfo()
		If !(Info["X"]=-1 and Info["Width"]=-1 and Info["Y"]=-1 and Info["Height"]=-1)
		{
		 xp:=Floor(Info["X"]+Info["Width"]/2)
		 yp:=Floor(Info["Y"]+Info["Height"]/2)
		 CoordMode, Mouse, Screen
		 SetMouseDelay, 0
		 SetDefaultMouseSpeed, 0
		 BlockInput On
		 MouseGetPos, MouseX, MouseY
		 MouseClick, %action%, %xp%, %yp%, %count%
		 If (action<>"right")
		 {
			sleep, 100
			MouseMove, %MouseX%, %MouseY%
		}
		BlockInput Off
		return, 0
	}

	; actionsToDo : object (1,"Action") of actions
	DoAccessibleActions(actionsToDo)
	{
		VarSetCapacity(Actions, 256*256*2+A_PtrSize,0)
		for index, action in actionsToDo
		{
			NumPut(A_Index,&Actions,0,"Int")
			lind:=A_Index
			Loop, Parse, action
			{
				offset:=(A_Index-1)*2+this.SHORT_STRING_SIZE*2*(lind-1)+A_PtrSize
				NumPut(Asc(A_LoopField),&Actions,offset,"UChar")
			}
			failure:=0
			DllCall(this.JAB.DLLVersion "\doAccessibleActions", "Int", this.vmID , this.JAB.acType, this.ac , "Ptr", &Actions , "Int", failure, "Cdecl Int")
		}
		return, failure
	}

	GetAccessibleActions()
	{
		VarSetCapacity(Actions, 256*256*2+A_PtrSize,0)
		if DllCall(this.JAB.DLLVersion "\getAccessibleActions", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Actions, "Cdecl Int")
		{
			Actret:=Object()
			retact:=NumGet(&Actions,0,"Int")
			Offset:=A_PtrSize
			Loop, % retact
			{
				Actret[A_Index]:=GetJavaString(Actions, Offset, this.JAB.SHORT_STRING_SIZE)
			}
			return Actret
		}
		else
			return 0
	}

	; index is 0 based
	GetAccessibleChildFromContext(index)
	{
		ac:=DllCall(this.JAB.DLLVersion "\getAccessibleChildFromContext", "Int", this.vmID, this.JAB.acType, ac, "Int", index, "Cdecl " this.JAB.acType)
		If (ac)
			return new JavaAccessibleContext(this.vmID,ac,this.JAB)
		else
			return 0
	}

	; retieves child context at coordinates x, y within the parent context
	; Is not always reliable. Better use: JavaAccessBridge.GetAccessibleContextAt
	GetAccessibleContextAt(x, y)
	{
		ac:=0
		If DllCall(this.JAB.DLLVersion "\getAccessibleContextAt", "Int", this.vmID, this.JAB.acType, this.ac, "Int", x, "Int", y, this.JAB.acPType, ac, "Cdecl Int")
			return new JavaAccessibleContext(this.vmID,ac,this.JAB)
		else
			return 0
	}

	; retrieves information about a certain element as an object with the keys:
	; Name, Description, Role_local, Role, States_local, States, IndexInParent,
	; ChildrenCount, X, Y, Width, Height, AccessibleComponent, AccessibleAction,
	; AccessibleSelection, AccessibleText, AccessibleValueInterface,
	; AccessibleActionInterface, AccessibleComponentInterface,
	; AccessibleSelectionInterface, AccessibleTableInterface,
	; AccessibleTextInterface, AccessibleHypertextInterface
	GetAccessibleContextInfo()
	{
		VarSetCapacity(Info, 6188,0)
		if (DllCall(this.JAB.DLLVersion "\getAccessibleContextInfo", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Info, "Cdecl Int"))
		{
			TempInfo:=Object()
			Offset:=0
			TempInfo["Name"]:=GetJavaString(Info, Offset, this.JAB.MAX_STRING_SIZE)
			TempInfo["Description"]:=GetJavaString(Info, Offset, this.JAB.MAX_STRING_SIZE)
			TempInfo["Role_local"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["Role"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["States_local"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["States"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["IndexInParent"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			TempInfo["ChildrenCount"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			TempInfo["X"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			TempInfo["Y"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			TempInfo["Width"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			TempInfo["Height"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			TempInfo["AccessibleComponent"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			TempInfo["AccessibleAction"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			TempInfo["AccessibleSelection"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			TempInfo["AccessibleText"]:=NumGet(&Info,Offset,"Int")
			Offset+=4
			tmp:=NumGet(&Info,Offset,"Int")
			TempInfo["AccessibleValueInterface"]:=tmp & 1
			TempInfo["AccessibleActionInterface"]:=tmp & 2
			TempInfo["AccessibleComponentInterface"]:=tmp & 4
			TempInfo["AccessibleSelectionInterface"]:=tmp & 8
			TempInfo["AccessibleTableInterface"]:=tmp & 16
			TempInfo["AccessibleTextInterface"]:=tmp & 32
			TempInfo["AccessibleHypertextInterface"]:=tmp & 64
			return TempInfo
		}
		else
			return 0
	}

	GetAccessibleParentFromContext()
	{
		ac:=DllCall(this.JAB.DLLVersion "\getAccessibleParentFromContext", "Int", this.vmID, this.JAB.acType, this.ac, "Cdecl "this.JAB.acType)
		If (ac)
			return new JavaAccessibleContext(this.vmID,ac,this.JAB)
		else
			return 0
	}

	; retrieves the text items as an object with the keys:
	; letter, word, sentence
	GetAccessibleTextItems(Index)
	{
		VarSetCapacity(Info, 2562,0)
		If (DllCall(this.JAB.DLLVersion "\getAccessibleTextItems", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Info, "Int", Index,  "Cdecl Int"))
		{
			TempInfo:=Object()
			TempInfo["letter"]:=Chr(NumGet(&Info,0,"UChar"))
			Offset:=2
			TempInfo["word"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["sentence"]:=GetJavaString(Info, Offset, this.JAB.MAX_STRING_SIZE)
			return TempInfo
		}
		else
			return 0
	}

	; retrieves the text attributes as an object with the keys:
	; bold, italic, underline, strikethrough, superscript, subscript,
	; backgroundColor, foregroundColor, fontFamily, fontSize,
	; alignment, bidiLevel, firstLineIndent, leftIndent, rightIndent,
	; lineSpacing, spaceAbove, spaceBelow, fullAttributesString
	GetAccessibleTextAttributes()
	{
		VarSetCapacity(Info, 3644,0)
		if (DllCall(this.JAB.DLLVersion "\getAccessibleTextAttributes", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Info, "Cdecl Int"))
		{
			TempInfo:=Object()
			Offset:=0
			TempInfo["bold"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["italic"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["underline"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["strikethrough"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["superscript"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["subscript"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["backgroundColor"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["foregroundColor"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["fontFamily"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["fontSize"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["alignment"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["bidiLevel"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["firstLineIndent"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["leftIndent"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["rightIndent"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["lineSpacing"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["spaceAbove"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["spaceBelow"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["fullAttributesString"]:=GetJavaString(Info, Offset, this.JAB.MAX_STRING_SIZE)
			return TempInfo
		}
		else
			return 0
	}

	; retrieves information about a certain text element as an object with the keys:
	; CharCount, CaretIndex, IndexAtPoint
	GetAccessibleTextInfo(x:=0, y:=0)
	{
		VarSetCapacity(Info, 12,0)
		if (DllCall(this.JAB.DLLVersion "\getAccessibleTextInfo", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Info, "Int", x, "Int", y, "Cdecl Int"))
		{
			TempInfo:=Object()
			TempInfo["CharCount"]:=NumGet(&Info, 0, "Int")
			TempInfo["CaretIndex"]:=NumGet(&Info, 4, "Int")
			TempInfo["IndexAtPoint"]:=NumGet(&Info, 8, "Int")
			return TempInfo
		}
		else
			return 0
	}

	; retrieves the start and end index of the line containing Index as an object with the keys:
	; StartPos, EndPos
	GetAccessibleTextLineBounds(Index)
	{
		StartPos:=0
		EndPos:=0
		if (DllCall(this.JAB.DLLVersion "\getAccessibleTextLineBounds", "Int", this.vmID, this.JAB.acType, this.ac, "Int*", &StartPos, "Int*", &EndPos, "Cdecl Int"))
		{
			TempInfo:=Object()
			TempInfo["StartPos"]:=StartPos
			TempInfo["EndPos"]:=EndPos
			return TempInfo
		}
		else
			return 0
	}

	; retrieves text between start and end index
	GetAccessibleTextRange(startc:=0, endc:=0)
	{
		TInfo:=this.GetAccessibleTextInfo()
		If IsObject(TInfo)
		{
			TempStr:=""
			maxlen:=10000 ; arbitrary value, larger values tend to fail sometimes
			If (startc<0)
			{
				startc:=0
			}
			cnt:=startc
			If (endc=0 or endc>TInfo.CharCount)
			{
				endc:=TInfo.CharCount
			}
			If (endc>0)
			{
				Loop,
				{
					if (cnt+maxlen>endc)
						cnt2:=endc-1
					else
						cnt2:=cnt+maxlen
					len:=maxlen+1
					VarSetCapacity(Txt, len*2,0)
					if (DllCall(this.JAB.DLLVersion "\getAccessibleTextRange", "Int", this.vmID, this.JAB.acType, this.ac, "Int", cnt, "Int", cnt2, "Ptr", &Txt, "Int", len, "Cdecl Int"))
					{
						NumPut(0,Txt,(cnt2-cnt+1)*2, "UChar")
						if (cnt2>cnt) and (NumGet(Txt,0,"UChar")=0) ; occasionally the first call fails at the end of the text
						{
							DllCall(this.JAB.DLLVersion "\getAccessibleTextRange", "Int", this.vmID, this.JAB.acType, this.ac, "Int", cnt, "Int", cnt2, "Ptr", &Txt, "Int", len, "Cdecl Int")
							NumPut(0,Txt,(cnt2-cnt+1)*2, "UChar")
						}
						Offset:=0
						TempStr.=GetJavaString(Txt, Offset, maxlen+1)
						if (cnt>=cnt2)
							cnt++
						else
							cnt:=cnt2+1
						if (cnt>=endc-1)
							break
					}
				}
			}
		}
		Return TempStr
	}

	; retrieves the location of position Index as an object with the keys:
	; X, Y, Width, Height
	GetAccessibleTextRect(Index)
	{
		VarSetCapacity(Info, 16,0)
		if (DllCall(this.JAB.DLLVersion "\getAccessibleTextRect", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Info, "Int", Index, "Cdecl Int"))
		{
			TempInfo:=Object()
			TempInfo["X"]:=NumGet(&Info,0,"Int")
			TempInfo["Y"]:=NumGet(&Info,4,"Int")
			TempInfo["Width"]:=NumGet(&Info,8,"Int")
			TempInfo["Height"]:=NumGet(&Info,12,"Int")
			return TempInfo
		}
		else
			return 0
	}

	; retrieves the currently selected text and its start and end index as an object with the keys:
	; SelectionStartIndex, SelectionEndIndex, SelectedText
	GetAccessibleTextSelectionInfo()
	{
		VarSetCapacity(Info, this.JAB.MAX_STRING_SIZE*2+8,0)
		if (DllCall(this.JAB.DLLVersion "\getAccessibleTextSelectionInfo", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Info, "Cdecl Int"))
		{
			TempInfo:=Object()
			TempInfo["SelectionStartIndex"]:=NumGet(&Info, 0, "Int")
			TempInfo["SelectionEndIndex"]:=NumGet(&Info, 4, "Int")
			Offset:=8
			TempInfo["SelectedText"]:=GetJavaString(Info, Offset, this.JAB.MAX_STRING_SIZE)
			return TempInfo
		}
		else
			return 0
	}

	; retrieves the text attributes as an object with the keys:
	; bold, italic, underline, strikethrough, superscript, subscript,
	; backgroundColor, foregroundColor, fontFamily, fontSize,
	; alignment, bidiLevel, firstLineIndent, leftIndent, rightIndent,
	; lineSpacing, spaceAbove, spaceBelow, fullAttributesString
	GetTextAttributesInRange(startc:=0, endc:=0)
	{
		VarSetCapacity(Info, 3644,0)
		len:=endc-startc+1
		if (DllCall(this.JAB.DLLVersion "\getTextAttributesInRange", "Int", this.vmID, this.JAB.acType, this.ac, "Int", startc, "Int", endc, "Ptr", &Info, "Int", len, "Cdecl Int"))
		{
			TempInfo:=Object()
			Offset:=0
			TempInfo["bold"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["italic"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["underline"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["strikethrough"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["superscript"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["subscript"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["backgroundColor"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["foregroundColor"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["fontFamily"]:=GetJavaString(Info, Offset, this.JAB.SHORT_STRING_SIZE)
			TempInfo["fontSize"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["alignment"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["bidiLevel"]:=NumGet(&Info, Offset, "Int")
			Offset+=4
			TempInfo["firstLineIndent"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["leftIndent"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["rightIndent"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["lineSpacing"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["spaceAbove"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["spaceBelow"]:=NumGet(&Info, Offset, "Float")
			Offset+=4
			TempInfo["fullAttributesString"]:=GetJavaString(Info, Offset, this.JAB.MAX_STRING_SIZE)
			return TempInfo
		}
		else
			return 0
	}

	GetActiveDescendent()
	{
		ac:=0
		If (DllCall(this.JAB.DLLVersion "\getActiveDescendent", "Int", this.vmID, this.JAB.acType, this.ac, "Cdecl Int"))
			return new JavaAccessibleContext(this.vmID,ac,this.JAB)
		else
			return 0
	}

	; retrieves the caret location as an object with the keys:
	; Index, X, Y, Width, Height
	GetCaretLocation(Index:=0)
	{
		VarSetCapacity(Info, 16,0)
		Index:=0
		if (DllCall(this.JAB.DLLVersion "\getCaretLocation", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Info, "Int", Index, "Cdecl Int"))
		{
			TempInfo:=Object()
			TempInfo["X"]:=NumGet(&Info,0,"Int")
			TempInfo["Y"]:=NumGet(&Info,4,"Int")
			TempInfo["Width"]:=NumGet(&Info,8,"Int")
			TempInfo["Height"]:=NumGet(&Info,12,"Int")
			TempInfo["Index"]:=Index
			return TempInfo
		}
		else
			return 0
	}

	GetHWNDFromAccessibleContext()
	{
		return DllCall(this.JAB.DLLVersion "\getHWNDFromAccessibleContext", "Int", this.vmID, this.JAB.acType, this.ac, "Cdecl UInt")
	}

	GetObjectDepth()
	{
		return DllCall(this.JAB.DLLVersion "\getObjectDepth", "Int", this.vmID, this.JAB.acType, this.ac, "Cdecl Int")
	}

	GetParentWithRole(Role)
	{
		ac:=DllCall(this.JAB.DLLVersion "\getParentWithRole", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Role, "Cdecl " this.JAB.acType)
		If (ac)
			return new JavaAccessibleContext(this.vmID,ac,this.JAB)
		else
			return 0
	}

	GetParentWithRoleElseRoot(Role)
	{
		ac:=DllCall(this.JAB.DLLVersion "\getParentWithRoleElseRoot", "Int", this.vmID, this.JAB.acType, this.ac, "Ptr", &Role, "Cdecl " this.JAB.acType)
		If (ac)
			return new JavaAccessibleContext(this.vmID,ac,this.JAB)
		else
			return 0
	}

	GetTopLevelObject()
	{
		ac:=DllCall(this.JAB.DLLVersion "\getTopLevelObject", "Int", this.vmID, this.JAB.acType, this.ac, "Cdecl "	this.JAB.acType)
		If (ac)
			return new JavaAccessibleContext(this.vmID,ac,this.JAB)
		else
			return 0
	}

	; this function seems to be unreliable under Win7 64bit (limit 768 elements?)
	; works fine under WinXP
	GetVisibleChildren()
	{
		NumChild:=this.GetVisibleChildrenCount()
		StartChild:=0
		Children:=Object()
		Loop,
		{
			VarSetCapacity(TempChildren, 257*this.JAB.acSize,0)
			if (DllCall(this.JAB.DLLVersion "\getVisibleChildren", "Int", this.vmID, this.JAB.acType, this.ac, "Int", StartChild, "Ptr", &TempChildren, "Cdecl Int"))
			{
				retchild:=NumGet(&TempChildren, 0, "Int")
				Loop, %retchild%
				{
					ac:=Numget(&TempChildren, this.JAB.acSize*A_Index, this.JAB.acType)
					Children.Push(new JavaAccessibleContext(this.vmID,ac,this.JAB))
				}
				StartChild:=StartChild+retchild-10
			}
			else
				break
		} Until StartChild>=NumChild
		return Children
	}

	GetVisibleChildrenCount()
	{
		return DllCall(this.JAB.DLLVersion "\getVisibleChildrenCount", "Int", this.vmID, this.JAB.acType, this.ac, "Cdecl Int")
	}

	RequestFocus()
	{
		return DllCall(this.JAB.DLLVersion "\requestFocus", "Int", this.vmID, this.JAB.acType, this.ac, "Cdecl Int")
	}

	; may not work properly before JRE7 Update 67
	SetTextContents(Text)
	{
		len := StrLen(Text)
		VarSetCapacity(TempStr, len * 2 + 2, 0)
		Loop, Parse, Text
		{
			offset:=(A_Index-1)*2
			NumPut(Asc(A_LoopField),TempStr,offset,"UChar")
		}
		return, DllCall(this.JAB.DLLVersion "\setTextContents", "Int", this.vmID, this.JAB.acType, this.ac, "UInt", &TempStr, "Cdecl Int")
	}

	; helper function to determine if the current JVM is 32 or 64 bit
	Is64bit()
	{
		If (A_Is64bitOS)
		{
			; find out if the JVM is running at 32 or 64 bit to circumvent a bug with the adress length in 32 bit JVMs (JRE 6+7)
			tlo:=this.GetTopLevelObject()
			Awin:=tlo.GetHWNDFromAccessibleContext()
      WinGet, ProcID, PID, ahk_id %Awin%
			phandle:=DllCall("OpenProcess", "uint", 0x1000, "uint", 0, "uint", ProcID)
			isWow64process:=0
			DllCall("IsWow64Process", "uint", phandle, "int*", isWow64process)
			if (isWow64process)
				return 0
			else
				return 1
	  }
		else
			return 0
	}

	SelectTextRange(startIndex, endIndex)
	{
		; find out if the JVM is running at 32 or 64 bit to circumvent a bug with the adress length in 32 bit JVMs (JRE 6+7)
		; this workaround seems not be necessary with JRE7update67 or later but seems to causes no trouble either
		if (this.Is64bit())
		{
			return DllCall(this.JAB.DLLVersion "\selectTextRange", "Int", this.vmID, this.JAB.acType, this.ac, "Int", startIndex, "Int", endIndex, "Cdecl Int")
		}
		else
		{
			return DllCall(this.JAB.DLLVersion "\selectTextRange", "Int", this.vmID, "Ptr", this.ac, "Int", startIndex, "Int", endIndex, "Cdecl Int")
		}
	}

	SetCaretPosition(position)
	{
		; find out if the JVM is running at 32 or 64 bit to circumvent a bug with the adress length in 32 bit JVMs (JRE 6+7)
		; this workaround seems not be necessary with JRE7update67 or later but seems to causes no trouble either
		if (this.Is64bit())
		{
			return DllCall(this.JAB.DLLVersion "\setCaretPosition", "Int", this.vmID, this.JAB.acType, this.ac, "Int", position, "Cdecl Int")
		}
		else
		{
			return DllCall(this.JAB.DLLVersion "\setCaretPosition", "Int", this.vmID, "Ptr", this.ac, "Int", position, "Cdecl Int")
		}
	}
}

GetJavaString(byref Struct, byref BaseOffset, Length)
{
	resstr:=""
	Loop, %Length%
	{
		offset:=(A_Index-1)*2+BaseOffset
		char:=Chr(NumGet(&Struct,offset,"UChar"))
		if (char=Chr(0))
			break
		resstr.=char
	}
	BaseOffset+=Length*2
	return resstr
}

/*
functions that have not been ported yet

{ exported user functions of the Java Access Bridge }

{ AccessibleTable }
function getAccessibleTableInfo(vmID: longint; ac: AccessibleContext; tableinfo: PAccessibleTableInfo):JBool;
function getAccessibleTableCellInfo(vmID: longint; at: AccessibleTable; row: jint; column: jint; tableCellInfo: PAccessibleTableCellInfo):JBool;
function getAccessibleTableRowHeader(vmID: longint; acParent: AccessibleContext; tableInfo: PAccessibleTableInfo):JBool;
function getAccessibleTableColumnHeader(vmID: longint; acParent: AccessibleContext; tableinfo: PAccessibleTableInfo):JBool;
function getAccessibleTableRowDescription(vmID: longint; acParent: AccessibleContext; row: jint):AccessibleContext;
function getAccessibleTableColumnDescription(vmID: longint; acParent: AccessibleContext; column: jint):AccessibleContext;
function getAccessibleTableRowSelectionCount(vmID: longint; table: AccessibleTable):jint;
function isAccessibleTableRowSelected(vmID: longint; table: AccessibleTable; row: jint):Jbool;
function getAccessibleTableRowSelections(vmID: longint; table: AccessibleTable; count: jint; selections: pjint):JBool;
function getAccessibleTableColumnSelectionCount(vmID: longint; table: AccessibleTable):Jint;
function isAccessibleTableColumnSelected(vmID: longint; table: AccessibleTable; column: jint):JBool;
function getAccessibleTableColumnSelections(vmID: longint; table: AccessibleTable; count: jint; selections: pjint):JBool;
function getAccessibleTableRow(vmID: longint; table: AccessibleTable; index: jint):jint;
function getAccessibleTableColumn(vmID: longint; table: AccessibleTable; index: jint):jint;
function getAccessibleTableIndex(vmID: longint; table: AccessibleTable; row: jint; column: jint):jint;

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

getAccessibleTableCellInfo
getAccessibleTableColumn
getAccessibleTableColumnDescription
getAccessibleTableColumnHeader
getAccessibleTableColumnSelectionCount
getAccessibleTableColumnSelections
getAccessibleTableIndex
getAccessibleTableInfo
getAccessibleTableRow
getAccessibleTableRowDescription
getAccessibleTableRowHeader
getAccessibleTableRowSelectionCount
getAccessibleTableRowSelections
isAccessibleTableColumnSelected
isAccessibleTableRowSelected

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
