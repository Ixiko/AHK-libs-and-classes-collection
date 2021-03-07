; Title:   	objects: backport AHK v2 Gui/Menu classes to AHK v1 - Page 2
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=43530&p=204331#p204331
; Author:
; Date:
; for:     	AHK_L

/*


*/

;==================================================

;AHK v2 GUI/Menu objects for AHK v1 by jeeswg

;e.g. test with:
;control zoo (AHK v2) - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=37&t=41685
;also requires:
;commands as functions (AHK v2 functions for AHK v1) - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=37&t=29689

;==================================================

;TO DO

;- Submit: add support for Submit/AltSubmit (named controls)
;- return values: consider all return values (also consider properties: blank get/set code)
;- margins: get X/Y margins
;- events: consider renamimg GUI default event functions (and if AHK v2 'Gui_XXX' event handler function exists, use that as default + convert hWnds to objects)
;- events: consider 'oBtn.OnEvent("Click", Func("MyButtonFunc").Bind(oBtn))' cf. 'oBtn.OnEvent("Click", "MyButtonFunc")', note: it appeared to work (although I didn't actively try to add support for it)
;- hCtrl/objects: _NewEnum is giving some controls multiple times, there may be an issue with varStoreHCtrl, perhaps hCtrls are right, but associated object addresses are wrong

;For Hwnd, GuiCtrlObj in GuiObj
;  MsgBox "Control #" A_Index " is " GuiCtrlObj.ClassNN

;==================================================

;NOT AVAILABLE / RELATED FUNCTIONS

;not available: writable variables
;A_AllowMainWindow
;A_IconHidden
;A_IconTip

;TraySetIcon(FileName:="", IconNumber:="", Freeze:="")
;{
;    Menu Tray, Icon, %FileName%, %IconNumber%, %Freeze%
;}

;==================================================

;LINKS

;LINKS - GENERAL
;v2-changes
;https://autohotkey.com/v2/v2-changes.htm
;list of every object type/property/method - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=37&t=44081

;LINKS - MENU (AHK V2)
;Menu Object
;https://lexikos.github.io/v2/docs/objects/Menu.htm
;MenuCreate
;https://lexikos.github.io/v2/docs/commands/MenuCreate.htm
;MenuFromHandle
;https://lexikos.github.io/v2/docs/commands/MenuFromHandle.htm
;Variables and Expressions
;https://lexikos.github.io/v2/docs/Variables.htm#TrayMenu

;LINKS - GUI (AHK V2)
;GUI Object
;https://lexikos.github.io/v2/docs/objects/Gui.htm
;GuiCreate
;https://lexikos.github.io/v2/docs/commands/GuiCreate.htm
;GuiCtrlFromHwnd
;https://lexikos.github.io/v2/docs/commands/GuiCtrlFromHwnd.htm
;GuiFromHwnd
;https://lexikos.github.io/v2/docs/commands/GuiFromHwnd.htm
;OnEvent
;https://lexikos.github.io/v2/docs/objects/GuiOnEvent.htm

;LINKS - GUI CONTROLS (AHK V2)
;GuiControl Object
;https://lexikos.github.io/v2/docs/objects/GuiControl.htm
;GUI Control Types
;https://lexikos.github.io/v2/docs/commands/GuiControls.htm
;ListView (GUI)
;https://lexikos.github.io/v2/docs/commands/ListView.htm
;TreeView (GUI)
;https://lexikos.github.io/v2/docs/commands/TreeView.htm

;LINKS - MENU (AHK V1)
;Menu
;https://autohotkey.com/docs/commands/Menu.htm
;MenuGetHandle
;https://autohotkey.com/docs/commands/MenuGetHandle.htm
;MenuGetName
;https://autohotkey.com/docs/commands/MenuGetName.htm

;LINKS - GUI (AHK V1)
;GUI
;https://autohotkey.com/docs/commands/Gui.htm
;GuiControl
;https://autohotkey.com/docs/commands/GuiControl.htm
;GuiControlGet
;https://autohotkey.com/docs/commands/GuiControlGet.htm

;LINKS - GUI CONTROLS (AHK V1)
;[includes SB_XXX functions]
;GUI Control Types
;https://autohotkey.com/docs/commands/GuiControls.htm
;[includes IL_XXX functions]
;ListView (GUI)
;https://autohotkey.com/docs/commands/ListView.htm
;TreeView (GUI)
;https://autohotkey.com/docs/commands/TreeView.htm

;==================================================

;GUI/MENU LIBRARY - CLASSES

class AHKMenuClass {
	static issued := 0
	static varClickCount := 2
	static varStoreHMenu := []
	__New()	{
		Class := RegExReplace(A_ThisFunc, "\..*")
		this.varMenuName := "MenuObj" (1 + %Class%.issued++)
		Menu, % this.varMenuName, Add
		Menu, % this.varMenuName, DeleteAll
		hMenu := MenuGetHandle(this.varMenuName)
		%Class%.varStoreHMenu[hMenu+0] := &this
	}

	ClickCount[]	{
		get		{
			if !(this.varMenuName = "Tray")
				return
			return this.varClickCount
		}
		set		{
			if !(this.varMenuName = "Tray")
				return
			Menu, Tray, Click, % value
			return this.varClickCount := value
		}
	}
	Default[]	{
		get		{
			if !(this.varMenuName = "Tray")
				return
		}
		set		{
			if !(this.varMenuName = "Tray")
				return
			Menu, Tray, Default, % value
		}
	}
	Handle[]	{
		get		{
			return MenuGetHandle(this.varMenuName)
		}
		set
		{
		}
	}
	Standard[]	{
		get		{
			if !(this.varMenuName = "Tray")
				return
		}
		set
		{
			if !(this.varMenuName = "Tray")
				return
			Menu, Tray, % value ? "Standard" : "NoStandard"
		}
	}

	;MENU ADD
	Add(MenuItemName, CallbackOrSubmenu:="", Options:="")	{
		if IsObject(CallbackOrSubmenu)
			Menu, % this.varMenuName, Add, % MenuItemName, % ":" CallbackOrSubmenu.varMenuName, % Options
		else if IsFunc(CallbackOrSubmenu)
			Menu, % this.varMenuName, Add, % MenuItemName, % CallbackOrSubmenu, % Options
	}
	Check(MenuItemName)	{
		Menu, % this.varMenuName, Check, % MenuItemName
	}
	Delete(MenuItemName)	{
		Menu, % this.varMenuName, Delete, % MenuItemName
	}
	Disable(MenuItemName)	{
		Menu, % this.varMenuName, Disable, % MenuItemName
	}
	Enable(MenuItemName)	{
		Menu, % this.varMenuName, Enable, % MenuItemName
	}
	Insert(ItemToInsertBefore, NewItemName, CallbackOrSubmenu, Options:="")	{
		Menu, % this.varMenuName, Insert, % ItemToInsertBefore, % NewItemName, % CallbackOrSubmenu, % Options
	}
	Rename(MenuItemName, NewName)	{
		Menu, % this.varMenuName, Rename, % MenuItemName, % NewName
	}
	SetColor(ColorValue, Submenus:=1)	{
		Menu, % this.varMenuName, Color, % ColorValue, % Submenus
	}
	SetIcon(MenuItemName, FileName, IconNumber, IconWidth)	{
		Menu, % this.varMenuName, Icon, % MenuItemName, % FileName, % IconNumber, % IconWidth
	}
	Show(X, Y)	{
		Menu, % this.varMenuName, Show, % X, % Y
	}
	ToggleCheck(MenuItemName)	{
		Menu, % this.varMenuName, ToggleCheck, % MenuItemName
	}
	ToggleEnable(MenuItemName)	{
		Menu, % this.varMenuName, ToggleEnable, % MenuItemName
	}
	Uncheck(MenuItemName)	{
		Menu, % this.varMenuName, Uncheck, % MenuItemName
	}

}

;==================================================

class AHKGuiClass{
	static issued := 0
	static varStoreHWnd := []
	static varStoreFunc := []
	__New(Options, Title, EventObj)	{
		Gui, New, +HwndhWnd, % Title
		this.varHwnd := hWnd

		Class := RegExReplace(A_ThisFunc, "\..*")
		this.varGuiName := "GuiObj" (1 + %Class%.issued++)
		;this.Name := this.varGuiName
		%Class%.varStoreHWnd[hWnd+0] := &this

		oGui.OnEvent("Close", "GuiClose")
		oGui.OnEvent("ContextMenu", "GuiContextMenu")
		oGui.OnEvent("DropFiles", "GuiDropFiles")
		oGui.OnEvent("Escape", "GuiEscape")
		oGui.OnEvent("Size", "GuiSize")
	}
	__Call(Method, Arg*)	{
		;for AddXXX methods
		if !(Method = "Add")
		&& (SubStr(Method, 1, 3) = "Add")
		{
			ControlType := SubStr(Method, 4)
			this.Add(ControlType, Arg.1, Arg.2)
		}
	}
	_NewEnum()	{
		Enum := {}
		Enum.varData := []

		DHW := A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinGet, CtrlList, ControlListHwnd, % "ahk_id " this.Hwnd
		Index := 1
		Loop, Parse, CtrlList, `n
		{
			hCtrl := A_LoopField
			if !AHKCtrlClass.varStoreHCtrl.HasKey(hCtrl)
				continue
			Addr := AHKCtrlClass.varStoreHCtrl[hCtrl]
			Enum.varData[Index++] := [hCtrl, Object(Addr)]
		}
		DetectHiddenWindows, % DHW

		Enum.varIndex := 1
		Enum.varMax := Enum.varData.Length()
		FuncName := RegExReplace(A_ThisFunc, "\.[^.]*") ".Next"
		Enum.base := {Next:FuncName}
		return Enum
	}
	Next(ByRef Key, ByRef Value)	{
		if (this.varIndex > this.varMax)
			return 0
		Key := this.varData[this.varIndex, 1]
		Value := this.varData[this.varIndex, 2]
		this.varIndex++
		return 1
	}

	;GUI ADD
	Add(ControlType, Options:="", Text:="")	{
		GuiCtrl := new AHKCtrlClass(this.Hwnd, ControlType, Options, Text)
		return GuiCtrl
	}
	Cancel()	{
		Gui, % this.Hwnd ":Cancel"
	}
	Destroy()	{
		Gui, % this.Hwnd ":Destroy"
	}
	Flash(Blink:=1)	{
		Gui, % this.Hwnd ":Flash", % Blink ? "" : "Off"
	}
	Hide() {
		Gui, % this.Hwnd ":Hide"
	}
	Maximize()	{
		Gui, % this.Hwnd ":Maximize"
	}
	Minimize()	{
		Gui, % this.Hwnd ":Minimize"
	}
	OnEvent(EventName, Callback, AddRemove:=1)	{
		;MsgBox, % "register event handler:`r`n" EventName " " Callback
		Class := RegExReplace(A_ThisFunc, "\..*")
		%Class%.varStoreFunc[this.Hwnd+0, EventName] := Callback
	}
	Opt(Options)	{
		Gui, % this.Hwnd ":" Options
	}
	Options(Options)	{
		Gui, % this.Hwnd ":" Options
	}
	Restore()	{
		Gui, % this.Hwnd ":Restore"
	}
	SetFont(Options, FontName)	{
		Gui, % this.Hwnd ":Font", % Options, % FontName
	}
	Show(Options:="")	{
		Gui, % this.Hwnd ":Show", % Options
	}
	;[CHECK]
	Submit(Hide:=1)	{
		Gui, % this.Hwnd ":Submit", % Hide ? "" : "NoHide"
	}

	BackColor[]	{
		get		{
		}
		set
		{
			Gui, % this.Hwnd ":Color", % value
		}
	}
	ClientPos[]	{
		get		{
		}
		set
		{
			Gui_WinGetClientPos(X, Y, W, H, "ahk_id " this.Hwnd)
			return {X:X, Y:Y, W:W, H:H}
		}
	}
	Control[]	{
		get		{
			;name, ClassNN or HWND
			if (Addr := AHKCtrlClass.varStoreHCtrl[value])
				return Object(Addr)
			ControlGet, hCtrl, Hwnd,, % value, % "ahk_id " this.Hwnd
			if hCtrl
				return GuiCtrlFromHwnd(hCtrl)
			return GuiCtrlFromHwnd(value)
		}
		set		{
		}
	}
	FocusedCtrl[]	{
		get		{
			ControlGetFocus, ClassNN, % "ahk_id " this.Hwnd
			ControlGet, hCtrl, Hwnd,, % ClassNN, % "ahk_id " this.Hwnd
			return GuiCtrlFromHwnd(hCtrl)
		}
		set
		{
		}
	}
	Hwnd[]	{
		get		{
			return this.varHwnd
		}
		set		{
		}
	}
	MarginX[]	{
		get		{
		}
		set		{
			Gui, % this.Hwnd ":Margin", % value
		}
	}
	MarginY[]	{
		get
		{
		}
		set
		{
			Gui, % this.Hwnd ":Margin",, % value
		}
	}
	Menu[]	{
		get		{
		}
		set		{
			Gui, % this.Hwnd ":Menu", % value.varMenuName
		}
	}
	;Name[] ;Name is just a normal key
	Pos[]	{
		get		{
			WinGetPos, X, Y, W, H, % "ahk_id " this.Hwnd
			return {X:X, Y:Y, W:W, H:H}
		}
		set		{
		}
	}
	Title[]	{
		get		{
			WinGetTitle, Title, % "ahk_id " this.Hwnd
			return Title
		}
		set		{
			WinSetTitle, % "ahk_id " this.Hwnd,, % value
		}
	}

}

;==================================================

class AHKCtrlClass{
	static issued := 0
	static varStoreHCtrl := []
	static varStoreFunc := []
	__New(hWnd, ControlType, Options, Text)	{
		Gui, % hWnd ":Add", % ControlType, % Options " +HwndhCtrl", % Text
		if (ControlType = "Picture")
			this.varType := "Pic"
		else if (ControlType = "DropDownList")
			this.varType := "DDL"
		else
			for Key, Value in StrSplit("Text,Edit,UpDown,Pic,Button,CheckBox,Radio,DDL,ComboBox,ListBox,ListView,TreeView,Link,Hotkey,DateTime,MonthCal,Slider,Progress,GroupBox,Tab,StatusBar,ActiveX,Custom", ",")
				if (ControlType = Value)
					this.varType := Value
		this.varHwnd := hCtrl+0

		Class := RegExReplace(A_ThisFunc, "\..*")
		this.varGuiName := "GuiCtrlObj" (1 + %Class%.issued++)
		;this.Name := this.varGuiName
		%Class%.varStoreHCtrl[hCtrl+0] := &this

		;MsgBox, % Gui_ControlHwndGetClassNN(hCtrl) " " Object(AHKCtrlClass.varStoreHCtrl[hCtrl]).ClassNN
		this.varHwndParent := hWnd+0
		this.varAltSubmit := !!InStr(Options, "AltSubmit")
	}

	ClassNN[]	{
		get
		{
			return Gui_ControlHwndGetClassNN(this.Hwnd)
		}
		set
		{
		}
	}
	Enabled[]	{
		get
		{
			ControlGet, IsEnabled, Enabled,,, % "ahk_id " this.Hwnd
			return IsEnabled
		}
		set
		{
			Control, % value ? "Enable" : "Disable",,, % "ahk_id " this.Hwnd
		}
	}
	Focused[] 	{
		get
		{
			ControlGetFocus, ClassNN, % "ahk_id " this.varHwndParent
			ControlGet, hCtrl, Hwnd,, % ClassNN, A
			return (hCtrl = this.Hwnd)
		}
		set
		{
		}
	}
	Gui[] 	{
		get
		{
			return GuiFromHwnd(this.varHwndParent)
		}
		set
		{
		}
	}
	Hwnd[]	{
		get
		{
			return this.varHwnd
		}
		set
		{
		}
	}
	;Name[] ;Name is just a normal key
	Pos[]	{
		get
		{
		}
		set
		{
			Gui_ControlGetClientPos(X, Y, W, H, this.ClassNN, "ahk_id " this.varHwndParent)
			return {X:X, Y:Y, W:W, H:H}
		}
	}
	Text[]	{
		get
		{
			if (this.Type ~= "i)^(ComboBox|ListBox|Tab)$")
				GuiControlGet, Text,, % this.Hwnd
			else if (this.Type ~= "i)^(DateTime|Edit|Hotkey|MonthCal|Pic|Progress|Slider|UpDown)$")
				return
			else
				GuiControlGet, Text,, % this.Hwnd, Text
			return Text
		}
		set
		{
			if (this.Type ~= "i)^(ActiveX|DateTime|DDL|Edit|Hotkey|ListBox|ListView|MonthCal|Pic|Progress|Radio|Slider|Tab|TreeView|UpDown)$")
				return
			GuiControl, Text, % this.Hwnd, % value
		}
	}
	Type[]	{
		get
		{
			return this.varType
		}
		set
		{
		}
	}
	Value[] { ;[list of control types: https://lexikos.github.io/v2/docs/objects/GuiControl.htm#Value]

		get
		{
			;[CHECK] Use Value instead of Text if AltSubmit was used. [ComboBox,DDL,ListBox,Tab]
			if (this.Type ~= "i)^(Button|GroupBox|Link|ListView|Text|TreeView)$")
				return
			else
				GuiControlGet, Text,, % this.Hwnd
			return Text
		}
		set
		{
			if (this.Type ~= "i)^(ActiveX|Button|ComboBox|Custom|DDL|GroupBox|Link|ListBox|ListView|StatusBar|Tab|Text|TreeView)$")
				return
			GuiControl,, % this.Hwnd, % value
		}
	}
	Visible[]	{
		get
		{
			ControlGet, IsVisible, Visible,,, % this.varHwnd
			return IsVisible
		}
		set
		{
			Control, % value ? "Show" : "Hide",,,  % this.varHwnd
		}
	}

	;CONTROL ADD
	;[CHECK] handling of Add(Array*)
	Add(Arg1, Array*) { ;[ComboBox, DropDownList, ListBox, Tab][ListView, TreeView]

		if (this.Type = "ListView")
		{
			Gui, % this.varHwndParent ":" this.Type, % this.Hwnd
			return LV_Add(Arg1, Array*)
		}
		else if (this.Type = "TreeView")
		{
			Gui, % this.varHwndParent ":" this.Type, % this.Hwnd
			return TV_Add(Arg1, Array.1, Array.2)
		}
		else
		{
			List := ""
			if IsObject(Arg1)
				Loop, % Arg1.Length()
					List .= (A_Index=1?"":"|") Arg1[A_Index]
			Gui, % this.varHwndParent ":Add", % IsObject(Arg1) ? List : Arg1
		}
	}
	Choose(Value) { ;[ComboBox, DropDownList, ListBox, Tab]

		GuiControl, Choose, % "ahk_id " this.Hwnd, % Value
	}
	Delete(Value:=-1) { ;[ComboBox, DropDownList, ListBox, Tab][ListView, TreeView]

		if (this.Type = "ListView")
		{
			Gui, % this.varHwndParent ":" this.Type, % this.Hwnd
			return LV_Delete(Value)
		}
		else if (this.Type = "TreeView")
		{
			Gui, % this.varHwndParent ":" this.Type, % this.Hwnd
			return TV_Delete(Value)
		}
		else if (this.Type = "ComboBox") || (this.type = "DDL")
		{
			if (Value = -1)
				SendMessage, 0x14B,,,, % "ahk_id " this.Hwnd ;CB_RESETCONTENT := 0x14B
			else
				SendMessage, 0x144, % Value-1,,, "ahk_id " this.Hwnd ;CB_DELETESTRING := 0x144
		}
		else if (this.Type = "ListBox")
		{
			if (Value = -1)
				SendMessage, 0x184,,,, "ahk_id " this.Hwnd ;LB_RESETCONTENT := 0x184
			else
				SendMessage, 0x182, % Value-1,,, "ahk_id " this.Hwnd ;LB_DELETESTRING := 0x182
		}
		else if (this.Type = "Tab")
		{
			if (Value = -1)
				SendMessage, 0x1309,,,, "ahk_id " this.Hwnd ;TCM_DELETEALLITEMS := 0x1309
			else
				SendMessage, 0x1308, % Value-1,,, "ahk_id " this.Hwnd ;TCM_DELETEITEM := 0x1308
		}
	}
	Focus()	{
		ControlFocus,, % "ahk_id " this.Hwnd
	}
	Move(Pos, Draw:=0)	{
		if Draw
			GuiControl, MoveDraw, % this.Hwnd, % Pos
		else
			GuiControl, Move, % this.Hwnd, % Pos
	}
	OnEvent(EventName, Callback, AddRemove:=1)	{
		;MsgBox, % "register event handler:`r`n" EventName " " Callback
		Class := RegExReplace(A_ThisFunc, "\..*")
		%Class%.varStoreFunc[this.Hwnd+0, EventName] := Callback
		GuiControl, % "+gAHKCtrlEventFunc", % this.Hwnd
	}
	Opt(Options)	{
		GuiControl, % Options, % this.Hwnd
	}
	Options(Options)	{
		GuiControl, % Options, % this.Hwnd
	}
	SetFont(Options, FontName)	{
		Gui, % this.varHwndParent ":Font", % Options, % FontName
		GuiControl, Font, % this.Hwnd
	}
	SetFormat(DateTime)	{
		GuiControl, Text, % this.Hwnd, % DateTime
	}
	SetIcon(Filename, IconNumber:=1, PartNumber:=1)	{
		Gui, % this.varHwndParent ":Default"
		SB_SetIcon(Filename, IconNumber, PartNumber)
	}
	SetParts(Width*)	{
		Gui, % this.varHwndParent ":Default"
		SB_SetParts(Width*)
	}
	SetText(NewText, PartNumber:=1, Style:=0)	{
		Gui, % this.varHwndParent ":Default"
		SB_SetText(NewText, PartNumber, Style)
	}
	UseTab(Value, ExactMatch:=0)	{
		if !Value
			Gui, % this.varParentHwnd ":Tab"
		else if (Value ~= "^\d+$")
			Gui, % this.varParentHwnd ":Tab", % Value
		else if ExactMatch
			Gui, % this.varParentHwnd ":Tab", % Value,, Exact
		else
			Gui, % this.varParentHwnd ":Tab", % Value
	}

	;[GuiControl Object: further (listview/treeview)]
	DeleteCol(ColumnNumber) { ;[ListView]

		Gui, % this.varHwndParent ":ListView", % this.Hwnd
		return LV_DeleteCol(ColumnNumber)
	}
	Get(ItemID, Attribute) {  ;[TreeView]

		Gui, % this.varHwndParent ":TreeView", % this.Hwnd
		return TV_Get(ItemID, Attribute)
	}
	GetChild(ParentItemID) {  ;[TreeView]

		Gui, % this.varHwndParent ":TreeView", % this.Hwnd
		return TV_GetChild(ParentItemID)
	}
	GetCount(Mode:="") {  ;[ListView, TreeView]

		Gui, % this.varHwndParent ":" this.Type, % this.Hwnd
		if (this.Type = "ListView")
			return LV_GetCount(Mode)
		else if (this.Type = "TreeView")
			return TV_GetCount()
	}
	GetNext(Item, Type) ;[ListView, TreeView]
	{
		;LV.GetNext([StartingRowNumber, RowType])
		;TV.GetNext([ItemID := 0, ItemType := ""])
		Gui, % this.varHwndParent ":" this.Type, % this.Hwnd
		if (this.Type = "ListView")
			return LV_GetNext(Item, Type)
		else if (this.Type = "TreeView")
			return TV_GetNext(Item, Type)
	}
	GetParent(ItemID) ;[TreeView]
	{
		Gui, % this.varHwndParent ":TreeView", % this.Hwnd
		return TV_GetParent(ItemID)
	}
	GetPrev(ItemID) ;[TreeView]
	{
		Gui, % this.varHwndParent ":TreeView", % this.Hwnd
		return TV_GetPrev(ItemID)
	}
	GetSelection() ;[TreeView]
	{
		Gui, % this.varHwndParent ":TreeView", % this.Hwnd
		return TV_GetSelection()
	}
	GetText(Item, ColumnNumber) ;[ListView, TreeView]
	{
		;LV.GetText(RowNumber [, ColumnNumber])
		;TV.GetText(ItemID)
		Gui, % this.varHwndParent ":" this.Type, % this.Hwnd
		if (this.Type = "ListView")
			LV_GetText(RetrievedText, Item, ColumnNumber)
		else if (this.Type = "TreeView")
			TV_GetText(RetrievedText, Item)
		return RetrievedText
	}
	Insert(RowNumber, Options:="", Col*) ;[ListView]
	{
		Gui, % this.varHwndParent ":ListView", % this.Hwnd
		return LV_Insert(RowNumber, Options, Col*)
	}
	InsertCol(ColumnNumber, Options:="", ColumnTitle:="") ;[ListView]
	{
		Gui, % this.varHwndParent ":ListView", % this.Hwnd
		return LV_InsertCol(ColumnNumber, Options, ColumnTitle)
	}
	Modify(Item, Options:="", Col*) ;[ListView, TreeView]
	{
		;LV.Modify(RowNumber [, Options, NewCol1, NewCol2, ...])
		;TV.Modify(ItemID [, Options, NewName])
		Gui, % this.varHwndParent ":" this.Type, % this.Hwnd
		if (this.Type = "ListView")
			return LV_Modify(Item, Options, Col*)
		else if (this.Type = "TreeView")
			return TV_Modify(Item, Options, Col.1)
	}
	ModifyCol(ColumnNumber:="", Options:="", ColumnTitle:="") ;[ListView]
	{
		Gui, % this.varHwndParent ":ListView", % this.Hwnd
		return LV_ModifyCol(ColumnNumber, Options, ColumnTitle)
	}
	SetImageList(ImageListID, IconType:="") ;[ListView, TreeView]
	{
		Gui, % this.varHwndParent ":" this.Type, % this.Hwnd
		if (this.Type = "ListView")
			return LV_SetImageList(ImageListID [, 0|1|2])
		else if (this.Type = "TreeView")
			return TV_SetImageList(ImageListID [, 0|2])
	}
}

;==================================================

;LIBRARY - AUXILIARY FUNCTIONS FOR EVENTS (INFO)

;OnEvent
;https://lexikos.github.io/v2/docs/objects/GuiOnEvent.htm

;Close
;ContextMenu [windows]
;DropFiles
;Escape
;Size

;Change
;Click/DoubleClick/ColClick
;ContextMenu [controls]
;Focus/LoseFocus
;ItemCheck/ItemEdit/ItemExpand/ItemFocus/ItemSelect

;==================================================

;LIBRARY - AUXILIARY FUNCTIONS FOR EVENTS

AHKCtrlEventFunc(hCtrl, Info1, Info2:="", Info3:="", Info4:=""){
	;A_Gui/A_GuiControl/A_GuiEvent/A_GuiControlEvent/A_EventInfo
	if (Info1 = "Normal")
		Info1 := "Click"
	Func := AHKCtrlClass.varStoreFunc[hCtrl, Info1]
	;MsgBox, % "event notification:`r`n" (A_Gui+0) " @ " A_GuiControl " @ " A_GuiEvent " @ " A_GuiControlEvent " @ " A_EventInfo "`r`n" hCtrl " @ " Info1 " @ " Info2 " @ " Info3 " @ " Info4
	if (Info1 ~= "i)^(Click)$")
		%Func%(GuiCtrlFromHwnd(hCtrl), Info1)
}

;Ctrl_Change(GuiCtrlObj, Info)
;Ctrl_Click(GuiCtrlObj, Info)
;Ctrl_DoubleClick(GuiCtrlObj, Info)
;Ctrl_ColClick(GuiCtrlObj, Info)
;Ctrl_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y)
;Ctrl_Focus(GuiCtrlObj, Info)
;Ctrl_LoseFocus(GuiCtrlObj, Info)
;Ctrl_ItemCheck(GuiCtrlObj, Item, Checked)
;Ctrl_ItemEdit(GuiCtrlObj, Item)
;Ctrl_ItemExpand(GuiCtrlObj, Item, Expanded)
;Ctrl_ItemFocus(GuiCtrlObj, Item)
;ListView_ItemSelect(GuiCtrlObj, Item, Selected)
;TreeView_ItemSelect(GuiCtrlObj, Item)

GuiClose(GuiHwnd){
	Func := AHKGuiClass.varStoreFunc[GuiHwnd]
	%Func%(GuiHwnd)
}
GuiContextMenu(GuiHwnd, CtrlHwnd, Item, IsRightClick, X, Y){
	Func := AHKGuiClass.varStoreFunc[GuiHwnd]
}
GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y){
	;different order: Gui_DropFiles(GuiObj, GuiCtrlObj, FileArray, X, Y)
	Func := AHKGuiClass.varStoreFunc[GuiHwnd]
}
GuiEscape(GuiHwnd){
	;no GuiEscape() example here:
	;GUI
	;https://autohotkey.com/docs/commands/Gui.htm#GuiEscape

	Func := AHKGuiClass.varStoreFunc[GuiHwnd]
}
GuiSize(GuiHwnd, MinMax, Width, Height){
	Func := AHKGuiClass.varStoreFunc[GuiHwnd]
}

;==================================================

;LIBRARY - FUNCTIONS

;AHK v2 GUI functions for AHK v1

;GuiCreate
;GuiCtrlFromHwnd
;GuiFromHwnd
;MenuCreate
;MenuFromHandle

global A_TrayMenu

GuiCreate(Options:="", Title:="", EventObj:=""){
	if (Title="")
		Title := A_ScriptName
	return new AHKGuiClass(Options, Title, EventObj)
}
GuiCtrlFromHwnd(hCtrl){
	Addr := AHKCtrlClass.varStoreHCtrl[hCtrl+0]
	return Object(Addr)
}
GuiFromHwnd(hWnd, RecurseParent:=0){
	Addr := AHKGuiClass.varStoreHWnd[hWnd+0]
	return Object(Addr)
}
MenuCreate(){
	static Init := MenuCreate()
	if !Init	{
		A_TrayMenu := new AHKMenuClass
		A_TrayMenu.varMenuName := "Tray"
		return 1
	}
	return new AHKMenuClass
}
MenuFromHandle(hMenu){
	Addr := AHKMenuClass.varStoreHMenu[hMenu+0]
	return Object(Addr)
}

;==================================================

;LIBRARY - AUXILIARY FUNCTIONS

Gui_ControlHwndGetClassNN(hCtrl){
	WinGetClass, WinClass, % "ahk_id " hCtrl
	hWnd := DllCall("user32\GetAncestor", Ptr,hCtrl, UInt,1, Ptr) ;GA_PARENT := 1
	Loop	{
		ControlGet, hCtrl2, Hwnd,, % WinClass A_Index, % "ahk_id " hWnd
		if !hCtrl2
			break
		else if (hCtrl = hCtrl2)
			return WinClass A_Index
	}
}
Gui_ControlGetClientPos(ByRef X, ByRef Y, ByRef W, ByRef H, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:=""){
	ControlGet, hCtrl, Hwnd,, % Control, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
	VarSetCapacity(RECT, 16, 0)
	DllCall("user32\GetWindowRect", Ptr,hCtrl, Ptr,&RECT)
	DllCall("user32\MapWindowPoints", Ptr,0, Ptr,hWnd, Ptr,&RECT, UInt,2)
	X := NumGet(&RECT, 0, "Int"), Y := NumGet(&RECT, 4, "Int")
	W := NumGet(&RECT, 8, "Int")-X, H := NumGet(&RECT, 12, "Int")-Y
}
Gui_WinGetClientPos(ByRef X:="", ByRef Y:="", ByRef Width:="", ByRef Height:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:=""){
	local hWnd, RECT
	hWnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
	VarSetCapacity(RECT, 16, 0)
	DllCall("user32\GetClientRect", Ptr,hWnd, Ptr,&RECT)
	DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&RECT)
	X := NumGet(&RECT, 0, "Int"), Y := NumGet(&RECT, 4, "Int")
	Width := NumGet(&RECT, 8, "Int"), Height := NumGet(&RECT, 12, "Int")
}

;==================================================