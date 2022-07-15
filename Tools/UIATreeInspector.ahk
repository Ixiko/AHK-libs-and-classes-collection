#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
CoordMode, Mouse, Screen
#include %A_ScriptDir%\..\classes\class_UIA_Interface.ahk
DetectHiddenWindows, Off

global UIA := UIA_Interface(), IsCapturing := False, Stored := {}, Acc, EnableAccTree := False, MainGuiHwnd
Stored.TreeView := {}
Acc_Init()
Acc_Error(1)

_xoffsetfirst := 328
_xoffset := 5
_yoffset := 20
_ysoffset := 2

Gui Main: New, AlwaysOnTop Resize hwndMainGuiHwnd, UIA Tree Inspector
Gui Main: Default

Gui Add, ListView, x8 y15 h460 w305 vLVWindowList gLVWindowList AltSubmit, Title|Process|ID

Gui Add, GroupBox, x328 y10 w302 h130, Window/Control Info
Gui Add, Text, xm+%_xoffsetfirst% yp+%_yoffset% w30 Section, WinTitle:
Gui Add, Edit, ys-%_ysoffset% w235 vEditWinTitle,
Gui Add, Text, x338 yp+30 Section, Hwnd:
Gui Add, Text,, Position:
Gui Add, Text,, Size:
Gui Add, Edit, ys-%_ysoffset% w80 vEditWinHwnd,
Gui Add, Edit, w80 vEditWinPosition,
Gui Add, Edit, w80 vEditWinSize,
Gui Add, Text, ys, ClassNN:
Gui Add, Text,, Process:
Gui Add, Text,, Process ID:
Gui Add, Edit, ys-%_ysoffset% w80 vEditWinClass,
Gui Add, Edit, w80 vEditWinProcess,
Gui Add, Edit, w80 vEditWinProcessID,

Gui Add, GroupBox, x%_xoffsetfirst% y150 w302 h240, UIAutomation Element Properties
Gui Add, ListView, xm+%_xoffsetfirst% yp+%_yoffset% h210 w285 vLVPropertyIds gLVPropertyIds AltSubmit, PropertyId|Value
ClearLVPropertyIds()

Gui Add, GroupBox, x%_xoffsetfirst% y395 w302 h150 vGBPatterns, UIAutomation Element Patterns
Gui Add, TreeView, xm+%_xoffsetfirst% yp+%_yoffset% h100 w285 vTVPatterns gTVPatterns
Gui Add, Button, xm+0 yp+75 w150 gButRefreshWindowList vButRefreshWindowList, Refresh window list
Gui Add, CheckBox, xm+160 yp+0 w50 gCBVisible vCBVisible Checked, Visible
Gui Add, CheckBox, xm+210 yp+0 w40 gCBTitle vCBTitle Checked, Title
Gui Add, CheckBox, xm+250 yp+0 w60 vCBActivate Checked, Activate

gosub ButRefreshWindowList
Gui Add, TreeView, x640 y8 w300 h400 hwndhMainTreeView vMainTreeView gMainTreeView
Gui, Font, Bold
Gui, Add, StatusBar, gMainSB vMainSB
SB_SetText("`tClick here to enable Acc path capturing (can't be used with UIA!)")
Gui, Font
SB_SetParts(380)
SB_SetText("`tCurrent UIA Interface version: " UIA.__Version,2)

Gui Show,, UIA Tree Inspector
Return

MainGuiEscape:
MainGuiClose:
	IsCapturing := False
    ExitApp

MainGuiSize(GuiHwnd, EventInfo, Width, Height){
	GuiControl, -Redraw, MainTreeView
	GuiControlGet, Pos, Pos , MainTreeView
	GuiControl, Move, MainTreeView, % "w" Width -Posx-10 " h" Height -Posy-35
	GuiControl, +Redraw, MainTreeView
	GuiControl, -Redraw, TVPatterns
	GuiControlGet, Pos, Pos , TVPatterns
	GuiControl, Move, TVPatterns, % " h" Height -Posy-35
	GuiControl, +Redraw, TVPatterns
	GuiControlGet, Pos, Pos , LVWindowList
	GuiControl, Move, LVWindowList, % " h" Height -Posy-60
	GuiControl, +Redraw, LVWindowList
	GuiControl, Move, ButRefreshWindowList, % "y" Height -50
	GuiControl, Move, CBVisible, % "y" Height -45
	GuiControl, Move, CBTitle, % "y" Height -45
	GuiControl, Move, CBActivate, % "y" Height -45
	GuiControlGet, Pos, Pos , GBPatterns
	GuiControl, Move, GBPatterns, % " h" Height -Posy-30
	GuiControl, +Redraw, MainSB
	SetTimer, RedrawMainWindow, -500
}

RedrawMainWindow:
	WinSet, Redraw,, ahk_id %MainGuiHwnd%
	return

MainSB:
	GuiControlGet, SBText,, MainSB
	if (SBText == "`tClick here to enable Acc path capturing (can't be used with UIA!)") {
		EnableAccTree := True
		SB_SetText("",1)
		SB_SetText("`tClick on path to copy to Clipboard",2)
	} else if SBText {
		Clipboard := SubStr(SBText, 8)
		ToolTip, % "Copied """ SubStr(SBText, 8) """ to Clipboard!"
		SetTimer, RemoveToolTip, -2000
	}
	return

CBVisible:
	gosub ButRefreshWindowList
	return
CBTitle:
	gosub ButRefreshWindowList
	return

LVWindowList:
	GuiControlGet, chk,, CBVisible
	DetectHiddenWindows, % chk ? "Off" : "On"

	Gui, ListView, LVWindowList
	LV_GetText(wId, A_EventInfo, 3)
	if (!wId || !WinExist("ahk_id " wId) || (A_GuiEvent != "Normal"))
		return
	GuiControlGet, activate,, CBActivate
	if activate
		WinActivate, ahk_id %wId%

	try {
		mEl := UIA.ElementFromHandle(wId)
	} catch e {
		UpdateElementFields()
		GuiControl, Main:, EditName, % "ERROR: " e.Message
		if InStr(e.Message, "0x80070005")
			GuiControl, Main:, EditValue, Try running UIA Tree Inspector with Admin privileges
	}
	Stored.Hwnd := wId

	; In some setups Chromium-based renderers don't react to UIA calls by enabling accessibility, so we need to send the WM_GETOBJECT message to the first renderer control for the application to enable accessibility. Thanks to users malcev and rommmcek for this tip. Explanation why this works: https://www.chromium.org/developers/design-documents/accessibility/#TOC-How-Chrome-detects-the-presence-of-Assistive-Technology
	WinGet, cList, ControlList, ahk_id %wId%
	if InStr(cList, "Chrome_RenderWidgetHostHWND1")
		SendMessage, WM_GETOBJECT := 0x003D, 0, 1, Chrome_RenderWidgetHostHWND1, ahk_id %wId%
	WinGetTitle, wTitle, ahk_id %wId%
	WinGetPos, wX, wY, wW, wH, ahk_id %wId%
	WinGetClass, wClass, ahk_id %wId%
	WinGetText, wText, ahk_id %wId%
	WinGet, wProc, ProcessName, ahk_id %wId%
	WinGet, wProcID, PID, ahk_id %wId%

	GuiControl, Main:, EditWinTitle, %wTitle%
	GuiControl, Main:, EditWinHwnd, ahk_id %wId%
	GuiControl, Main:, EditWinPosition, X: %wX% Y: %wY%
	GuiControl, Main:, EditWinSize, W: %wW% H: %wH%
	GuiControl, Main:, EditWinClass, %wClass%
	GuiControl, Main:, EditWinProcess, %wProc%
	GuiControl, Main:, EditWinProcessID, %wProcID%

	try {
		UpdateElementFields(mEl)
		if EnableAccTree {
			oAcc := Acc_ObjectFromWindow(wId, 0), Acc_Location(oAcc,mEl.GetCurrentPatternAs("LegacyIAccessible").CurrentChildId,vAccLoc)
			SB_SetText(" Path: " GetAccPathTopDown(wId, vAccLoc), 1)
		}
	}
	try RedrawTreeView(mEl, False)
	return

LVPropertyIds:
	if (A_GuiEvent == "RightClick") {
		Gui, ListView, LVPropertyIds
		LV_GetText(info, A_EventInfo, 2)
		if info {
			LV_GetText(prop, A_EventInfo, 1)
			if (prop == "ControlType")
				RegexMatch(info, "(?<=\().+(?=\))", info)
			Clipboard := info
			ToolTip, % "Copied """ info """ to Clipboard!"
			SetTimer, RemoveToolTip, -2000
		}
	}
	return

TVPatterns:
	return

ButRefreshWindowList:
	GuiControlGet, chk,, CBVisible
	DetectHiddenWindows, % chk ? "Off" : "On"

	GuiControlGet, NeedsTitle,, CBTitle
	Gui, ListView, LVWindowList
	LV_Delete()
	WinGet, wList, List
	Loop, %wList%
	{
		wId := wList%A_Index%
		WinGetTitle, wTitle, ahk_id %wId%
		if (NeedsTitle && (wTitle == ""))
			continue
		WinGet, wExe, ProcessName, ahk_id %wId%
		LV_Add("", wTitle, wExe, wId)
	}
	LV_ModifyCol(1, 140)
	LV_ModifyCol(2)
	return

MainTreeView:
	if (A_GuiEvent == "S") {
		UpdateElementFields(Stored.Treeview[A_EventInfo])
		if EnableAccTree {
			br := Stored.Treeview[A_EventInfo].CurrentBoundingRectangle
			SB_SetText(" Path: " GetAccPathTopDown(Stored.Hwnd, "x" br.l " y" br.t " w" (br.r-br.l) " h" (br.b-br.t)), 1)
		}
	}
	return

RemoveToolTip:
	ToolTip
	return

ClearLVPropertyIds() {
	Gui, ListView, LVPropertyIds
	LV_Delete()
	LV_Add("", "ControlType", "")
	LV_Add("", "LocalizedControlType", "")
	LV_Add("", "Name", "")
	LV_Add("", "Value", "")
	LV_Add("", "AutomationId", "")
	LV_Add("", "BoundingRectangle", "")
	LV_Add("", "ClassName", "")
	LV_Add("", "HelpText", "")
	LV_Add("", "AccessKey", "")
	LV_Add("", "AcceleratorKey", "")
	LV_Add("", "HasKeyboardFocus", "")
	LV_Add("", "IsKeyboardFocusable", "")
	LV_Add("", "ItemType", "")
	LV_Add("", "ProcessId", "")
	LV_Add("", "IsEnabled", "")
	LV_Add("", "IsPassword", "")
	LV_Add("", "IsOffscreen", "")
	LV_Add("", "FrameworkId", "")
	LV_Add("", "IsRequiredForForm", "")
	LV_Add("", "ItemStatus", "")
	LV_Add("", "LabeledBy", "")
	LV_ModifyCol(1)
}

UpdateElementFields(mEl="") {
	if !IsObject(mEl) {
		ClearLVPropertyIds()
		return
	}
	try {
		mElPos := mEl.CurrentBoundingRectangle
		RangeTip(mElPos.l, mElPos.t, mElPos.r-mElPos.l, mElPos.b-mElPos.t, "Blue", 4)
	}
		Gui, ListView, LVPropertyIds
		LV_Delete()
		Gui, TreeView, TVPatterns
		TV_Delete()
	try {
		for k, v in UIA.PollForPotentialSupportedPatterns(mEl) {
			parent := TV_Add(RegexReplace(k, "Pattern$"))
			if (IsObject(UIA_%k%) && UIA_%k%.__properties) {
				pos := 1, m := "", pattern := mEl.GetCurrentPatternAs(k)
				while (pos := RegExMatch(UIA_%k%.__properties, "im)^(Current.+?),(\d+),(int|bstr|bool)", m, pos+StrLen(m))) {
					TV_Add(SubStr(m1,8) ": " pattern[m1], parent)
				}
			}
		}
	}
	try LV_Add("", "ControlType", (ctrlType := mEl.CurrentControlType) " (" UIA_Enum.UIA_ControlTypeId(ctrlType) ")")
	try LV_Add("", "LocalizedControlType", mEl.CurrentLocalizedControlType)
	try LV_Add("", "Name", mEl.CurrentName)
	try LV_Add("", "Value", mEl.GetCurrentPropertyValue(UIA_ValueValuePropertyId := 30045))
	try LV_Add("", "AutomationId", mEl.CurrentAutomationId)
	try LV_Add("", "BoundingRectangle", "l: " mElPos.l " t: " mElPos.t " r: " mElPos.r " b: " mElPos.b)
	try LV_Add("", "ClassName", mEl.CurrentClassName)
	try LV_Add("", "HelpText", mEl.CurrentHelpText)
	try LV_Add("", "AccessKey", mEl.CurrentAccessKey)
	try LV_Add("", "AcceleratorKey", mEl.CurrentAcceleratorKey)
	try LV_Add("", "HasKeyboardFocus", mEl.CurrentHasKeyboardFocus)
	try LV_Add("", "IsKeyboardFocusable", mEl.CurrentIsKeyboardFocusable)
	try LV_Add("", "ItemType", mEl.CurrentItemType)
	try LV_Add("", "ProcessId", mEl.CurrentProcessId)
	try LV_Add("", "IsEnabled", mEl.CurrentIsEnabled)
	try LV_Add("", "IsPassword", mEl.CurrentIsPassword)
	try LV_Add("", "IsOffscreen", mEl.CurrentIsOffscreen)
	try LV_Add("", "FrameworkId", mEl.CurrentFrameworkId)
	try LV_Add("", "IsRequiredForForm", mEl.CurrentIsRequiredForForm)
	try LV_Add("", "ItemStatus", mEl.CurrentItemStatus)
	try LV_ModifyCol(1)
	return
}

RedrawTreeView(el, noAncestors=True) {
	global MainTreeView, hMainTreeView
	Gui, TreeView, MainTreeView
	TV_Delete()
	TV_Add("Constructing TreeView...")
	Sleep, 40
	GuiControl, Main: -Redraw, MainTreeView
	TV_Delete()
	Stored.TreeView := {}
	if noAncestors {
		ConstructTreeView(el)
	} else {
		; Get all ancestors
		ancestors := [], parent := el
		while IsObject(parent) {
			try {
				ancestors.Push(parent := UIA.TreeWalkerTrue.GetParentElement(parent))
			} catch {
				break
			}
		}

		; Loop backwards through ancestors to create the TreeView
		maxInd := ancestors.MaxIndex(), parent := ""
		while (--maxInd) {
			if !IsObject(ancestors[maxInd])
				return
			try {
				elDesc := ancestors[maxInd].CurrentLocalizedControlType " """ ancestors[maxInd].CurrentName """"
				if (elDesc == " """"")
					break
				Stored.TreeView[parent := TV_Add(elDesc, parent)] := ancestors[maxInd]
			}
		}
		; Add child elements to TreeView also
		ConstructTreeView(el, parent)
	}
	for k,v in Stored.TreeView
		TV_Modify(k, "Expand")

	SendMessage, 0x115, 6, 0,, ahk_id %hMainTreeView% ; scroll to top
	GuiControl, Main: +Redraw, MainTreeView
}

ConstructTreeView(el, parent="") {
	if !IsObject(el)
		return
	try {
		elDesc := el.CurrentLocalizedControlType " """ el.CurrentName """"
		if (elDesc == " """"")
			return
		Stored.TreeView[TWEl := TV_Add(elDesc, parent)] := el
		if !(children := el.FindAll(UIA.TrueCondition, 0x2))
			return
		for k, v in children
			ConstructTreeView(v, TWEl)
	}
}

; Acc functions

GetAccPathTopDown(hwnd, vAccPos, updateTree=False) {
	static accTree
	if !IsObject(accTree)
		accTree := {}
	if (!IsObject(accTree[hwnd]) || updateTree)
		accTree[hwnd] := BuildAccTreeRecursive(Acc_ObjectFromWindow(hwnd, 0), {})
	for k, v in accTree[hwnd] {
		if (v == vAccPos)
			return k
	}
}

BuildAccTreeRecursive(oAcc, tree, path="") {
	if !IsObject(oAcc)
		return tree
	try
		oAcc.accChildCount
	catch
		return tree
	For i, oChild in Acc_Children(oAcc) {
		if IsObject(oChild)
			Acc_Location(oChild,,vChildPos)
		else
			Acc_Location(oAcc,oChild,vChildPos)
		tree[path (path?(IsObject(oChild)?".":" c"):"") i] := vChildPos
		tree := BuildAccTreeRecursive(oChild, tree, path (path?".":"") i)
	}
	return tree
}
Acc_Init()
{
	Static	h
	If Not	h
	h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}
Acc_ObjectFromEvent(ByRef _idChild_, hWnd, idObject, idChild)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromEvent", "Ptr", hWnd, "UInt", idObject, "UInt", idChild, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
	Return	ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "")
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
	Return	ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromWindow(hWnd, idObject = -4)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
	Return	ComObjEnwrap(9,pacc,1)
}

Acc_WindowFromObject(pacc)
{
	If	DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0
	Return	hWnd
}
Acc_Error(p="") {
	static setting:=0
	return p=""?setting:setting:=p
}
Acc_Children(Acc) {
	if ComObjType(Acc,"Name") != "IAccessible"
		ErrorLevel := "Invalid IAccessible Object"
	else {
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
			Loop %cChildren%
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Push(NumGet(varChildren,i-8)=9?Acc_Query(child):child), NumGet(varChildren,i-8)=9?ObjRelease(child):
			return Children.MaxIndex()?Children:
		} else
			ErrorLevel := "AccessibleChildren DllCall Failed"
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}
Acc_Location(Acc, ChildId=0, byref Position="") { ; adapted from Sean's code
	try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
	catch
		return
	Position := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
	return	{x:NumGet(x,0,"int"), y:NumGet(y,0,"int"), w:NumGet(w,0,"int"), h:NumGet(h,0,"int")}
}
Acc_Parent(Acc)
{
	try parent:=Acc.accParent
	return parent?Acc_Query(parent):
}
Acc_Child(Acc, ChildId=0)
{
	try child:=Acc.accChild(ChildId)
	return child?Acc_Query(child):
}
Acc_Query(Acc)
{
	try return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}

RangeTip(x:="", y:="", w:="", h:="", color:="Red", d:=2) ; from the FindText library, credit goes to feiyue
{
  local
  static id:=0
  if (x="")
  {
    id:=0
    Loop 4
      Gui, Range_%A_Index%: Destroy
    return
  }
  if (!id)
  {
    Loop 4
      Gui, Range_%A_Index%: +Hwndid +AlwaysOnTop -Caption +ToolWindow
        -DPIScale +E0x08000000
  }
  x:=Floor(x), y:=Floor(y), w:=Floor(w), h:=Floor(h), d:=Floor(d)
  Loop 4
  {
    i:=A_Index
    , x1:=(i=2 ? x+w : x-d)
    , y1:=(i=3 ? y+h : y-d)
    , w1:=(i=1 or i=3 ? w+2*d : d)
    , h1:=(i=2 or i=4 ? h+2*d : d)
    Gui, Range_%i%: Color, %color%
    Gui, Range_%i%: Show, NA x%x1% y%y1% w%w1% h%h1%
  }
}