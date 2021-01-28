; -- Initialize variables
; -----------------------------------------------------------------
{

global EditorWinHwnd, EditorOverlayWinHwnd, EditorWinNCX := "", EditorWinNCY
	 , EditorMouseX := 0 ; Stores real editor mouse coordinates, updated whenever EditorWinGetMousePos is called
	 , EditorMouseY := 0
	 , EditorMouseDownControl := 0
	 , EditorMouseDownMode := 0
	 , EditorMouseDownModifierKeys := 0
	 , EditorMouseMoveMode := 0
	 , EditorMouseWaitForDown := 0
	 , EditorControlAnchorX := 0
	 , EditorControlAnchorY := 0
	 , EditorControlState := {}, EditorControlStateGroup := 0
	 , EditorPrevMouseX := 0
	 , EditorPrevMouseY := 0
	 , EditorWinContextControlHwnd := 0, EditorWinContextMenuX := 0, EditorWinContextMenuY := 0
	 , EditorWinTargetCursor := 0
	 , EditorWinGrid := {Bitmap: 0, Graphics: 0, BGBrush: 0, FGBrush: 0, PatternBrush: 0, SolidBrush: 0, CurrentSize: 0, CurrentType: 0, CurrentBGColour: "", CurrentFGColour: ""}
	 , EditorWinResizeHandle := {Hwnd: 0, Id: 0, Visible: 0, AspectRatio: 1
		, Handles: {TL: {Hwnd: 0, X: 0, Y: 0}
			, TR: {Hwnd: 0, X: 0, Y: 0}
			, BL: {Hwnd: 0, X: 0, Y: 0}
			, BR: {Hwnd: 0, X: 0, Y: 0}
			, T:  {Hwnd: 0, X: 0, Y: 0}
			, B:  {Hwnd: 0, X: 0, Y: 0}
			, L:  {Hwnd: 0, X: 0, Y: 0}
			, R:  {Hwnd: 0, X: 0, Y: 0} }}
	 , EditorWinControlEditOverlay := {Visible: 0, Hwnd: 0, Id: 0, L: 0, R: 0, T: 0, B: 0, LabelBG: 0, LabelText: 0}
	 , Selection := {Window: 0, RectWinHwnd: 0, Rect: 0, Highlights: {}, HighlightsCount: 0, Current: 0, Count: 0, PreviousCount: 0, Controls: {}}
	 , EditorWinContextMenus := {}
}

; -- Functions
; -----------------------------------------------------------------

EditorWinAddControl(ControlType, ControlX, ControlY, ByRef ControlData := 0){
	Gui Editor:Default
	
	; > Build control options
	
	DefaultText := ControlTypeOptions[ControlType].Text
	Options := ControlTypeOptions[ControlType].Options
	
	if(CurrentGui.DefaultColour != "" and !ControlTypeOptions[ControlType].NoGuiTextColour)
		Options .= " c" CurrentGui.DefaultColour
	
	if(ControlType = "UpDown"){
		if(!GetKeyState("Alt", "P"))
			Options .= " -" UDS_AUTOBUDDY
	}
	
	ExportOptionGuiNameLabel := "Editor:"
	BuildGuiFontOptions("Reset")
	BuildGuiFontOptions(CurrentGui.Window, 0, "Gui")
	
	; > Create control
	
	Options := "x" ControlX " y" ControlY " " Options
	NewControlHwnd := EditorWinCreateInstance(ControlType, Options, DefaultText)
	Gui Editor:Font
	
	; > Other control options
	
	if(NewControlHwnd){
		ControlData := AddControl(NewControlHwnd, ControlType)
		ForceControlRedraw(Selection.Current)
		
		if(ControlType = "UpDown"){
			SendMessage, UDM_GETBUDDY, 0, 0, , ahk_id %NewControlHwnd%
			if(ErrorLevel){
				TargetControlData := CurrentGui.Controls[ErrorLevel]
				TargetControlData.UpDownBuddy := ControlData.Index
				ControlData.Target := TargetControlData.Index
				UpdateControlSize(ErrorLevel, 1)
			}
		}
		
		else if(ControlType = "Radio"){
			EditorWinUpdateRadioGroup(ControlData)
		}
		
		else if(ControlType = "Tab2"){
			TabNumber := GetTabNumber(ControlData)
			ParentControlSetVisible(ControlData.Index | (TabNumber << 16), 1)
		}
	}
	else
		CallThreadedFunction(ErrorMessageFunc, "This Gui already has a " ControlType)
	
	return NewControlHwnd
}

EditorWinCreateControlFromData(ControlData, UpdateIndexes := 1){
	if(ControlData = "Reset"){
		BuildGuiFontOptions("Reset")
		return
	}
	
	Options := ""
	BuildControlOptions(ControlData, Options, 1, 0)
	Options .= " HwndNewControlHwnd"
	
	ControlType := ControlData.ControlType
	Property := PropertiesDef.Common.Text, PropertyClass.ControlType := ControlType
	Text := GetPropertyValue("Common", "Text", ControlData)
	
	if(Property.Get("Type") = "List"){
		if((OptionValues := Property.Get("OptionValues")))
			Index := Property.Get("ListIndexes")[Text]
			, Text := Index ? OptionValues[Index] : Text
	}
	
	if((ForcedOptions := ControlTypeOptions[ControlType].ForceOptions) != "")
		Options .= " " ForcedOptions
	
	if(ControlType = "UpDown"){
		Options .= " -" UDS_AUTOBUDDY
	}
	
	else if(ControlType = "Picture"){
		if(!ControlData.HasValidPicture or !FileExist(Text))
			Options .= " Border"
	}
	
	BuildGuiFontOptions(ControlData)
	NewControlHwnd := EditorWinCreateInstance(ControlType, Options, Text)
	
	if(UpdateIndexes)
		CurrentGui.Controls[NewControlHwnd] := ControlData
		, CurrentGui.ControlIndexes[ControlData.Index] := NewControlHwnd
	
	if(ControlType = "Tab2"){
		TabNumber := GetTabNumber(ControlData, TabCount)
		while(TabCount){
			Parent := ControlData.Index | (TabCount << 16)
			Visible := TabCount = TabNumber
			ParentControlSetVisible(Parent, Visible, !Visible)
			TabCount--
		}
	}
	
	if(ControlData.Parent)
		ParentControlAddChild(ControlData.Parent, ControlData.Index)
	
	return NewControlHwnd
}

EditorWinCreateGui(){
	Gui Editor:New, HwndEditorWinHwnd Resize MinSize80x0 OwnerMain LabelOnEditorWin Delimiter%GUI_DELIMITER%, % PropertiesDef.Gui.Title.Default
	SubClassWindow(EditorWinHwnd, "OnEditorWinWindowProc")
	
	Gui Editor:Show, % "x341 y121 " ControlTypeOptions.EditorWin.Options
	GetWindowRect(EditorWinHwnd, WRX, WRY, WRW, WRH)
	GetClientSize(EditorWinHwnd, W, H)
	EditorWinNCX := WRW - WRX - W
	EditorWinNCY := WRH - WRY - H
	
	; Control edit overlay
	
	Gui ControlEditOverlay:New, HwndGuiHwnd OwnerEditor +E%WS_EX_TRANSPARENT% -Caption ToolWindow
	EditorWinControlEditOverlay.Hwnd := GuiHwnd
	EditorWinControlEditOverlay.Id := "ahk_id " GuiHwnd
	WinSet TransColor, 0x00FF00 64, % EditorWinControlEditOverlay.Id
	Gui ControlEditOverlay:Color, 0x00FF00
	Gui ControlEditOverlay:Add, Picture, x0 y0 HwndGuiHwnd, images\overlay-border.ico
	EditorWinControlEditOverlay.L := GuiHwnd
	Gui ControlEditOverlay:Add, Picture, x0 y0 HwndGuiHwnd, images\overlay-border.ico
	EditorWinControlEditOverlay.R := GuiHwnd
	Gui ControlEditOverlay:Add, Picture, x0 y0 HwndGuiHwnd, images\overlay-border.ico
	EditorWinControlEditOverlay.T := GuiHwnd
	Gui ControlEditOverlay:Add, Picture, x0 y0 HwndGuiHwnd, images\overlay-border.ico
	EditorWinControlEditOverlay.B := GuiHwnd
	Gui ControlEditOverlay:Add, Picture, x0 y0 w100 h18 HwndGuiHwnd BackgroundTrans, images\overlay-border.ico
	EditorWinControlEditOverlay.LabelBG := GuiHwnd
	Gui ControlEditOverlay:Add, Text, x0 y0 HwndGuiHwnd BackgroundTrans c0xFFFFFF, Testing
	EditorWinControlEditOverlay.LabelText := GuiHwnd
	
	; Resize handles
	
	Gui ResizeHandles:New, HwndGuiHwnd OwnerEditor +E%WS_EX_TRANSPARENT% -Caption ToolWindow
	Gui ResizeHandles:Color, 0xFF0000
	EditorWinResizeHandle.Hwnd := GuiHwnd
	EditorWinResizeHandle.Id   := "ahk_id " GuiHwnd
	WinSet TransColor, 0xFF0000, % EditorWinResizeHandle.Id
	EditorWinCreateGuiResizeHandle("TL"), EditorWinCreateGuiResizeHandle("TR")
	EditorWinCreateGuiResizeHandle("BL"), EditorWinCreateGuiResizeHandle("BR")
	EditorWinCreateGuiResizeHandle("T"),  EditorWinCreateGuiResizeHandle("B")
	EditorWinCreateGuiResizeHandle("L"),  EditorWinCreateGuiResizeHandle("R")
	
	; Selection overlay
	
	Gui SelectionWin:New, HwndGuiHwnd OwnerEditor +E%WS_EX_TRANSPARENT% +ToolWindow -Caption
	Selection.Window := GuiHwnd
	Selection.WindowId := "ahk_id " GuiHwnd
	Gui SelectionWin:Show, NoActivate
	WinSet TransColor, 0xFF0000 63, % Selection.WindowId
	Gui SelectionWin:Color, 0xFF0000
	
	Gui SelectionRectWin:New, +HwndGuiHwnd +OwnerEditor +E%WS_EX_TRANSPARENT% +ToolWindow -Caption
	Selection.RectWinHwnd := GuiHwnd
	Gui SelectionRectWin:Color, 0xFF0000
	WinSet TransColor, 0xFF0000 63, % "ahk_id " Selection.RectWinHwnd
	Gui SelectionRectWin:Add, Picture, HwndGuiHwnd, images\selection-highlight.ico
	Selection.Rect := GuiHwnd
	
	EditorWinUpdateOverlayWindow()
	
	EditorWinCreateGuiContextMenus()
	
	; Init
	
	EditorWinListenForEscape("create")
	OnMessage(WM_LBUTTONDBLCLK, "OnEditorWinMouseDoubleClick")
	OnMessage(WM_RBUTTONUP, "OnEditorWinMouseRightUp")
	
	Hotkey IfWinActive, ahk_id %EditorWinHwnd%
	Hotkey *Left, OnEditorWinArrowKey
	Hotkey *Right, OnEditorWinArrowKey
	Hotkey *Up, OnEditorWinArrowKey
	Hotkey *Down, OnEditorWinArrowKey
	Hotkey IfWinActive
}

EditorWinCreateGuiContextMenu(ControlType, ItemsBefore := 0){
	static CreateStandardMenus := 1
	
	if(ItemsBefore and !IsObject(ItemsBefore)){
		EditorWinContextMenus[ControlType] := ItemsBefore
		return
	}
	
	if(CreateStandardMenus){
		for Index, AddControlType in MainWinAddControlTypes
			if(AddControlType != ""){
				Name := AddControlType[1]
				Menu EditorWinContextMenuAddControl, Add, %Name%, OnEditorWinContextMenu
				if((Icon := AddControlType[2]) != "")
					Menu EditorWinContextMenuAddControl, Icon, %Name%, %Icon%
			}
			else
				Menu EditorWinContextMenuAddControl, Add
		
		CreateStandardMenus := 0
	}
	
	EditorWinContextMenus[ControlType] := MenuData := {ControlType: ControlType}
	
	MenuName := "EditorWinContextMenu" (ControlType != "" ? "Control" : "") ControlType
	
	if(ItemsBefore){
		for Index, ItemName in ItemsBefore{
			Data := StrSplit(ItemName, "|")
			ItemName := Data[1]
			IconName := Data[2]
			ItemProperty := Data[3]
			
			Menu %MenuName%, Add, %ItemName%, OnEditorWinContextMenu
			
			if(IconName){
				Menu  %MenuName%, Icon, %ItemName%, images\%IconName%.ico
				IconName := ""
			}
			
			if(ItemProperty){
				if(!(Properties := MenuData.Properties))
					Properties := MenuData.Properties := []
				Properties[ItemName] := ItemProperty
			}
		}
	}
	
	Menu %MenuName%, Add, Cut, OnEditorWinContextMenu
	Menu %MenuName%, Add, Cut, OnEditorWinContextMenu
	Menu %MenuName%, Add, Copy, OnEditorWinContextMenu
	Menu %MenuName%, Add, Paste, OnEditorWinContextMenu
	Menu %MenuName%, Add, Delete, OnEditorWinContextMenu
	Menu %MenuName%, Add
	Menu %MenuName%, Add, Select All, OnEditorWinContextMenu
	Menu %MenuName%, Add, Deselect All, OnEditorWinContextMenu
	Menu %MenuName%, Add
	Menu %MenuName%, Add, Add, :EditorWinContextMenuAddControl
	
	Menu  %MenuName%, Icon, Cut, images\cut.ico
	Menu  %MenuName%, Icon, Copy, images\copy.ico
	Menu  %MenuName%, Icon, Paste, images\paste.ico
	Menu  %MenuName%, Icon, Delete, images\delete.ico
	Menu  %MenuName%, Icon, Select All, images\select-all.ico
	Menu  %MenuName%, Icon, Deselect All, images\deselect.ico
}

EditorWinCreateGuiContextMenus(){
	EditorWinCreateGuiContextMenu("")
	EditorWinCreateGuiContextMenu("StdControl")
	
	EditorWinCreateGuiContextMenu("Text", "StdControl")
	EditorWinCreateGuiContextMenu("Edit", "StdControl")
	EditorWinCreateGuiContextMenu("UpDown", "StdControl")
	EditorWinCreateGuiContextMenu("Picture", ["Reset Image Size", "Open Containing Folder", ""])
	EditorWinCreateGuiContextMenu("Button", "StdControl")
	EditorWinCreateGuiContextMenu("Checkbox", "StdControl")
	EditorWinCreateGuiContextMenu("Radio", "StdControl")
	EditorWinCreateGuiContextMenu("DropDownList", "StdControl")
	EditorWinCreateGuiContextMenu("ComboBox", "StdControl")
	EditorWinCreateGuiContextMenu("ListBox", "StdControl")
	EditorWinCreateGuiContextMenu("ListView", "StdControl")
	EditorWinCreateGuiContextMenu("TreeView", "StdControl")
	EditorWinCreateGuiContextMenu("Link", "StdControl")
	EditorWinCreateGuiContextMenu("Hotkey", "StdControl")
	EditorWinCreateGuiContextMenu("DateTime", "StdControl")
	EditorWinCreateGuiContextMenu("MonthCal","StdControl")
	EditorWinCreateGuiContextMenu("Slider", "StdControl")
	EditorWinCreateGuiContextMenu("GroupBox", ["Link Children||_LinkChildren", ""])
	EditorWinCreateGuiContextMenu("Tab2", ["Edit Current Tab Page", "Exit Tab Page Edit Mode"
		, "Move Selected Into Current Tab|tab-move-in", "Move Selected Out of Tab|tab-move-out", "Link Children||_LinkChildren", ""])
	EditorWinCreateGuiContextMenu("StatusBar", "StdControl")
	EditorWinCreateGuiContextMenu("ActiveX", "StdControl")
	EditorWinCreateGuiContextMenu("Custom", "StdControl")
}

EditorWinCreateGuiResizeHandle(Name){
	Gui ResizeHandles:Add, Picture, x0 y0 HwndHandleHwnd, images\resize-handle.ico
	EditorWinResizeHandle.Handles[Name].Hwnd := HandleHwnd
}

EditorWinCreateInstance(ControlType, ByRef Options, Text){
	UnqiueInstance := 0
	TypeOptions := ControlTypeOptions[ControlType]
	
	if(TypeOptions.IsUnique)
		UnqiueInstance := CurrentGui.UnqiueInstance[ControlType]
	
	if(UnqiueInstance and UnqiueInstance.Hwnd){
		if(UnqiueInstance.Visible)
			return 0
		
		UnqiueInstance.Visible := 1
		NewControlHwnd := UnqiueInstance.Hwnd
		W := UnqiueInstance.W, H := UnqiueInstance.H
		GuiControl %Options%, %NewControlHwnd%
		GuiControl, , %NewControlHwnd%, %Text%
		GuiControl Move, %NewControlHwnd%, w%W% h%H% %Options%
		GuiControl Font, %NewControlHwnd%
		GuiControl Show, %NewControlHwnd%
		GuiControl Enable, %NewControlHwnd%
	}
	else{
		if(TypeOptions.PlaceHolder){
			ControlAddType := TypeOptions.PlaceHolder
			Text := TypeOptions.PlaceHolderTpl
				? RegExReplace(TypeOptions.PlaceHolderTpl, "<Text>", Text = "" ? "" : "[" Text "]")
				: TypeOptions.PlaceHolderText
		}
		else
			ControlAddType := ControlType
		
		Gui Editor:Add, %ControlAddType%, %Options% HwndNewControlHwnd, %Text%
	}
	
	if(UnqiueInstance != 0 and !IsObject(UnqiueInstance)){
		GuiControlGet Control, Pos, %NewControlHwnd%
		CurrentGui.UnqiueInstance[ControlType] := {Hwnd: NewControlHwnd, W:ControlW, H:ControlH, Visible: 1}
		UniqueControls[NewControlHwnd] := 1
	}
	
	WinGetClass ClassNN, ahk_id %NewControlHwnd%
	; By default the WM_LBUTTONDOWN message does not fire for static controls
	if(ClassNN = "Static"){
		WinSet Style, +%SS_NOTIFY%, ahk_id %NewControlHwnd%
	}
	
	if(ControlType = "ComboBox"){
		VarSetCapacity(COMBOBOXINFO, Size := 40 + A_PtrSize * 3, 0)
		NumPut(Size, COMBOBOXINFO, 0, "UInt")
		SendMessage CB_GETCOMBOBOXINFO, 0, &COMBOBOXINFO, , ahk_id %NewControlHwnd%
		ListBoxHwnd := NumGet(COMBOBOXINFO, 40 + A_PtrSize * 2, "Ptr")
		SubClassWindow(ListBoxHwnd, "OnEditorWinControlDisableMouseWindowProc")
	}
	
	else if(ControlType = "ListView" or ControlType = "ListBox" or ControlType = "TreeView"){
		; Prevent the cursor from changing when hovering between ListView header column
		if(ControlType = "ListView"){
			LVM_GETHEADER           := 0x101F
			SendMessage LVM_GETHEADER, 0, 0, , ahk_id %NewControlHwnd%
			SubClassWindow(ErrorLevel, "OnEditorWinControlListViewHeaderWindowProc")
		}
		
		; Disable the scrollbars
		SubClassWindow(NewControlHwnd, "OnEditorWinControlDisableMouseWindowProc")
	}
	
	else if(ControlType = "Link"){
		; Subclass SysLink controls to disable the hand cursor
		SubClassWindow(NewControlHwnd, "OnEditorWinControlSysLinkWindowProc")
	}
	
	else if(ControlType = "Tab2"){
		Gui Editor:Tab
	}
	
	return NewControlHwnd
}

EditorWinGetMousePos(ByRef X, ByRef Y, Snap := 1, IgnoreCtrl := 0){
	; Snap = 0	Fetch the mouse coordinates and do not snap to grid
	; Snap = 1	Fetch the mouse coordinates and snap to grid
	; Snap = 2	Do not fetch the mouse coordinates and only snap to grid
	
	; Ctrl key will temporarily invert the snapping setting
	SnapToGrid := GetKeyState("Ctrl") and !IgnoreCtrl ? !Settings.SnapToGrid : Settings.SnapToGrid
	
	if(Snap < 2){
		MouseGetPos X, Y
		ScreenToClient(X, Y, EditorWinHwnd)
		EditorMouseX := X, EditorMouseY := Y
	}
	
	if(Snap and SnapToGrid)
		SnapToGrid(X, Y)
}

EditorWinListenForEscape(Listen := 1){
	; Enables or disables the Esc hotkey which is used to cancel certain actions
	
	if(Listen)
		SetApplicationHotKey("Esc", "OnEditorWinEscapeKey", Listen = "create" ? "Off" : "On")
	else
		SetApplicationHotKey("Esc", "Off")
}

EditorWinResetWindow(Width := "", Height := ""){
	Options := ControlTypeOptions.EditorWin.Options
	if(Width != "")
		Options .= " w" Width
	if(Height != "")
		Options .= " h" Height
	Gui Editor:Show, % "NoActivate " Options, % GetPropertyValue("Gui", "Title", CurrentGui.Window)
}

EditorWinSelectControl(ControlHwnd, Mode := "select", Update := 1){
	if(Mode = "select"){
		if(Selection.Count != 1 or Selection.Current != ControlHwnd){
			EditorWinSelectControlHighlight("clear")
			Selection.Controls := {}
			Selection.Controls[ControlHwnd] := EditorWinSelectControlHighlight(ControlHwnd)
			Selection.Count := 1
			Selection.Current := ControlHwnd
			
			CurrentControlData := CurrentGui.Controls[ControlHwnd]
			PropertyWinUpdateGroups()
		}
	}
	
	else if(Mode = "add"){
		if(!Selection.Controls[ControlHwnd]){
			Selection.Controls[ControlHwnd] := EditorWinSelectControlHighlight(ControlHwnd)
			Selection.Count++
		}
		
		if(Selection.Current != ControlHwnd){
			Selection.Current := ControlHwnd
			CurrentControlData := CurrentGui.Controls[ControlHwnd]
			
			if(Update){
				EditorWinUpdateResizeHandles()
				PropertyWinUpdateGroups()
			}
		}
	}
	
	else if(Mode = "remove"){
		if(Selection.Controls[ControlHwnd]){
			EditorWinSelectControlHighlight(ControlHwnd, 1)
			Selection.Count--
			Selection.Controls.Remove(ControlHwnd, "")
			if(Selection.Current = ControlHwnd){
				Selection.Current := 0
				for NewControlHwnd in Selection.Controls{
					Selection.Current := NewControlHwnd
					if(Update)
						EditorWinUpdateResizeHandles()
					break
				}
				if(!Selection.Current and Update)
					EditorWinShowResizeHandles(0)
				
				CurrentControlData := Selection.Current ? CurrentGui.Controls[Selection.Current] : CurrentGui.Window
				if(Update)
					PropertyWinUpdateGroups()
			}
		}
	}
	
	else if(Mode = "clear"){
		EditorWinSelectControlHighlight("clear")
		EditorWinShowResizeHandles(0)
		Selection.Controls := {}
		Selection.Count := 0
		Selection.Current := 0
		
		CurrentControlData := CurrentGui.Window
		PropertyWinUpdateGroups()
	}
	
	else if(Mode = "all"){
		EditorWinSelectControlHighlight("clear")
		Selection.Controls := {}
		Selection.Count := 0
		
		for ControlHwnd, ControlData in CurrentGui.Controls{
			if(!ParentControls[ControlData.Parent].Visible)
				continue
			
			Selection.Controls[ControlHwnd] := EditorWinSelectControlHighlight(ControlHwnd)
			Selection.Count++
		}
		
		if(!Selection.Current and ControlHwnd){
			Selection.Current := ControlHwnd
			EditorWinUpdateResizeHandles()
			CurrentControlData := CurrentGui.Controls[ControlHwnd]
			PropertyWinUpdateGroups()
		}
	}
	
	Selection.PreviousCount := Selection.Count
}

EditorWinSelectControlHighlight(ControlHwnd, Remove := 0){
	; Creates and associates a highlight with a control, removes the highlight associated with the given control
	; or removes the highlights associated with all selected controls
	
	if(ControlHwnd = "clear"){
		for CurrentControlHwnd, HighlightHwnd in Selection.Controls{
			if(!HighlightHwnd)
				continue
			Selection.Controls[CurrentControlHwnd] := 0
			Selection.Highlights[++Selection.HighlightsCount] := HighlightHwnd
			GuiControl SelectionWin:Hide, %HighlightHwnd%
		}
		return
	}
	
	if(Remove){
		HighlightHwnd := Selection.Controls[ControlHwnd]
		if(!HighlightHwnd)
			return
		Selection.Controls[ControlHwnd] := 0
		Selection.Highlights[++Selection.HighlightsCount] := HighlightHwnd
		GuiControl SelectionWin:Hide, %HighlightHwnd%
		return
	}
	
	if(!Selection.HighlightsCount)
		Gui SelectionWin:Add, Picture, x0 y0 w1 h1 HwndHighlightHwnd, images\highlight.ico
	else
		HighlightHwnd := Selection.Highlights[Selection.HighlightsCount--]
	
	Selection.Controls[ControlHwnd] := HighlightHwnd
	EditorWinUpdateHighlight(ControlHwnd)
	
	return HighlightHwnd
}

EditorWinStartControlTargetMode(Start := 1){
	static PrevMouseMove, PrevSetCursor
	
	if(Start){
		EditorMouseDownMode := "TargetControl"
		MainWinStatusText("Select a control in the editor window`t`tCancel: Escape")
		
		EditorWinTargetCursor := !EditorWinTargetCursor ? DllCall("LoadCursor", Ptr,0, Int,IDC_CROSS := 32515) : EditorWinTargetCursor
		DllCall("SetCursor", Ptr,EditorWinTargetCursor)
		
		PrevMouseMove := OnMessage(WM_MOUSEMOVE)
		PrevSetCursor := OnMessage(WM_SETCURSOR)
		OnMessage(WM_MOUSEMOVE, "OnEditorWinTargetControlModeMouseMoveOverride")
		OnMessage(WM_SETCURSOR, "OnEditorWinTargetControlModeSetCursorOverride")
		
		EditorWinListenForEscape()
	}
	else{
		OnMessage(WM_MOUSEMOVE, PrevMouseMove)
		OnMessage(WM_SETCURSOR, PrevSetCursor)
		EditorMouseDownMode := 0
		MainWinStatusText()
		ToolTip
	}
}

EditorWinStartMoveSelection(){
	if(!Selection.Current)
		return
	
	EditorMouseDownControl := Selection.Current
	EditorMouseMoveMode := CurrentAppAction := "WaitForMove"
	EditorControlAnchorX := ""
	EditorMouseWaitForDown := 1
	
	SetTimer OnEditorWinMouseMove, -0
}

EditorWinShowResizeHandles(Show := 1){
	if(Show){
		if(!EditorWinResizeHandle.Visible){
			Gui ResizeHandles:Show, NoActivate
			EditorWinUpdateOverlayWindow(EditorWinResizeHandle.Hwnd)
			WinSet Top, , % EditorWinResizeHandle.Id
		}
	}
	else
		Gui ResizeHandles:Hide
	
	EditorWinResizeHandle.Visible := !!Show
}

EditorWinUpdateControlEditOverlay(ControlHwnd := 0, ResizeOnly := 0){
	static CurrentControlHwnd := 0
		, LabelWidth := 0, LabelHeight := 0
		, LabelTargetX := 0, LabelTargetY := 0
	
	ControlHwnd := !ControlHwnd ? CurrentControlHwnd : ControlHwnd
	CurrentControlHwnd := ControlHwnd
	ControlData := CurrentGui.Controls[ControlHwnd]
	
	if(!ResizeOnly){
		GuiControlGet Control, Editor:Pos, %ControlHwnd%
		ControlX1 := ControlX, ControlY1 := ControlY
		ControlX2 := ControlX1 + ControlW - 2
		ControlY2 := ControlY1 + ControlH - 2
		
		GuiControl ControlEditOverlay:Move, % EditorWinControlEditOverlay.L, x%ControlX1% y%ControlY1% h%ControlH%
		GuiControl ControlEditOverlay:Move, % EditorWinControlEditOverlay.R, x%ControlX2% y%ControlY1% h%ControlH%
		GuiControl ControlEditOverlay:Move, % EditorWinControlEditOverlay.T, x%ControlX1% y%ControlY1% w%ControlW%
		GuiControl ControlEditOverlay:Move, % EditorWinControlEditOverlay.B, x%ControlX1% y%ControlY2% w%ControlW%
		
		NewText := "Current Parent: " ControlData.Id
		if(ControlData.ControlType = "Tab2")
			NewText .= ">Tab" GetTabNumber(ControlData)
		
		GetTextSize(EditorWinControlEditOverlay.LabelText, NewText, LabelWidth, LabelHeight)
		GuiControl ControlEditOverlay:Move, % EditorWinControlEditOverlay.LabelText, w%LabelWidth% h%LabelHeight%
		GuiControl ControlEditOverlay:, % EditorWinControlEditOverlay.LabelText, %NewText%
		LabelWidth += 8, LabelHeight += 4
		LabelTargetX := ControlX1, LabelTargetY := ControlY2 + 2
		GuiControl ControlEditOverlay:Move, % EditorWinControlEditOverlay.LabelBG, w%LabelWidth% h%LabelHeight%
	}
	
	GetClientSize(EditorWinHwnd, WinWidth, WinHeight)
	LabelX := LabelTargetX, LabelY := LabelTargetY
	if(LabelX < 0)
		LabelX := 0
	else if(LabelX + LabelWidth > WinWidth)
		LabelX := WinWidth - LabelWidth
	if(LabelY < 0)
		LabelY := 0
	else if(LabelY + LabelHeight > WinHeight)
		LabelY := WinHeight - LabelHeight
	
	GuiControl ControlEditOverlay:Move, % EditorWinControlEditOverlay.LabelBG, x%LabelX% y%LabelY%
	LabelX += 4, LabelY += 2
	GuiControl ControlEditOverlay:Move, % EditorWinControlEditOverlay.LabelText, x%LabelX% y%LabelY%
}

EditorWinUpdateGrid(Redraw := 0){
	static COLOR_3DFACE_Colour =
	
	GridSize		:= Settings.GridSize
	GridType		:= Settings.GridType
	GridBGColour	:= CurrentGui.Window.BackgroundColour
	GridFGColour	:= Settings.GridColour
	
	; Only redraw when something has changed
	if(EditorWinGrid.CurrentSize = GridSize and EditorWinGrid.CurrentType = GridType and EditorWinGrid.CurrentBGColour = GridBGColour and EditorWinGrid.CurrentFGColour = GridFGColour)
		return Settings.ShowGrid ? EditorWinGrid.PatternBrush : EditorWinGrid.SolidBrush
	
	; Only create a new bitmap if the size has changed
	if(EditorWinGrid.Bitmap and EditorWinGrid.CurrentSize != GridSize){
		Gdip_DeleteGraphics(EditorWinGrid.Graphics)
		Gdip_DisposeImage(EditorWinGrid.Bitmap)
		EditorWinGrid.Bitmap := 0
	}
	
	if(!EditorWinGrid.Bitmap){
		EditorWinGrid.Bitmap	:= Gdip_CreateBitmap(GridSize, GridSize)
		EditorWinGrid.Graphics	:= Gdip_GraphicsFromImage(EditorWinGrid.Bitmap)
	}
	
	; Only create a new background brush if the background colour has changed
	if(!EditorWinGrid.BGBrush or EditorWinGrid.CurrentBGColour != GridBGColour){
		if(!COLOR_3DFACE_Colour)
			COLOR_3DFACE_Colour := FormatHex(DllCall("GetSysColor", Int,COLOR_3DFACE, UInt))
		NewBGColour := (GridBGColour = "" ? COLOR_3DFACE_Colour : GridBGColour)
		if((ColourFromName := ColourNameToRGB(NewBGColour)) != "")
			NewBGColour := ColourFromName
		if(SubStr(NewBGColour, 1, 2) != "0x")
			NewBGColour := "0x" NewBGColour
		NewBGColour := 0xFF000000 | (NewBGColour != "" ? NewBGColour : COLOR_3DFACE_Colour)
		
		if(!EditorWinGrid.BGBrush)
			EditorWinGrid.BGBrush := Gdip_BrushCreateSolid(NewBGColour)
		else
			Gdip_SetSolidFillColor(EditorWinGrid.BGBrush, NewBGColour)
		
		if(EditorWinGrid.SolidBrush)
			EditorWinGrid.SolidBrush := DllCall("DeleteObject", Ptr,EditorWinGrid.SolidBrush)
		EditorWinGrid.SolidBrush := DllCall("CreateSolidBrush", UInt,(NewBGColour << 16 & 0xFF0000) | (NewBGColour & 0xFF00) | (NewBGColour >> 16 & 0x0000FF))
	}
	
	Gdip_FillRectangle(EditorWinGrid.Graphics, EditorWinGrid.BGBrush, 0, 0, GridSize, GridSize)
	
	if(GridType = "Line"){
		if(!EditorWinGrid.FGBrush)
			EditorWinGrid.FGBrush := Gdip_BrushCreateSolid(GridFGColour)
		else
			Gdip_SetSolidFillColor(EditorWinGrid.FGBrush, GridFGColour)
		Gdip_FillRectangle(EditorWinGrid.Graphics, EditorWinGrid.FGBrush, GridSize - 1, 0, 1, GridSize - 1)
		Gdip_FillRectangle(EditorWinGrid.Graphics, EditorWinGrid.FGBrush, 0, GridSize - 1, GridSize, 1)
	}
	
	else{ ; GridType = "Dot"
		Gdip_SetPixel(EditorWinGrid.Bitmap, GridSize - 1, GridSize - 1, GridFGColour)
	}
	
	EditorWinGrid.CurrentSize		:= GridSize
	EditorWinGrid.CurrentType		:= GridType
	EditorWinGrid.CurrentBGColour	:= GridBGColour
	EditorWinGrid.CurrentFGColour	:= GridFGColour
	
	if(Redraw)
		WinSet Redraw, , ahk_id %EditorWinHwnd%
	
	if(EditorWinGrid.PatternBrush)
		DeleteObject(EditorWinGrid.PatternBrush)
	
	BrushHBitmap := Gdip_CreateHBITMAPFromBitmap(EditorWinGrid.Bitmap)
	EditorWinGrid.PatternBrush := DllCall("CreatePatternBrush", Ptr,BrushHBitmap, "Cdecl")
	DeleteObject(BrushHBitmap)
	
	return Settings.ShowGrid ? EditorWinGrid.PatternBrush : EditorWinGrid.SolidBrush
}

EditorWinUpdateHighlight(ControlHwnd){
	If(!(HighlightHwnd := Selection.Controls[ControlHwnd]))
		return
	GuiControlGet Control, Editor:Pos, %ControlHwnd%
	GuiControl SelectionWin:Move, %HighlightHwnd%, x%ControlX% y%ControlY% w%ControlW% h%ControlH%
	GuiControl SelectionWin:Show, %HighlightHwnd%
}

EditorWinUpdateListViewColumns(ListViewHwnd, ColumnText){
	Gui Editor:ListView, %ListViewHwnd%
	ColCount := LV_GetCount("Column")
	Index := 1
	
	Loop Parse, ColumnText, %GUI_DELIMITER%
	{
		if(A_LoopField = "")
			continue
		
		if(Index <= ColCount)
			LV_ModifyCol(Index, "", A_LoopField)
		else
			LV_InsertCol(Index, "", A_LoopField)
		
		Index++
	}
	
	while(ColCount >= Index)
		LV_DeleteCol(ColCount--)
	while(Index > 0)
		LV_ModifyCol(--Index, "AutoHdr")
}

EditorWinUpdateRadioGroup(ControlData){
	RadioGroupName := ControlData.Group := Trim(GetPropertyValue("Radio", "Group", ControlData))
	if(RadioGroupName = ControlData.CurrentRadioGroup)
		return
	
	if(ControlData.CurrentRadioGroup != ""){
		RadioGroup := CurrentGui.RadioGroups[ControlData.CurrentRadioGroup]
		RadioGroup.Controls.Remove(ControlData.Index, "")
		if(--RadioGroup.Count = 0)
			CurrentGui.RadioGroups.Remove(ControlData.CurrentRadioGroup, "")
	}
	
	if(RadioGroupName != ""){
		RadioGroup := CurrentGui.RadioGroups[RadioGroupName]
		if(!RadioGroup)
			RadioGroup := CurrentGui.RadioGroups[RadioGroupName] := {Count: 0, Controls: {}}
		RadioGroup.Controls[ControlData.Index] := 1
		RadioGroup.Count++
	}
	
	ControlData.CurrentRadioGroup := RadioGroupName
}

EditorWinUpdateResizeHandles(){
	if(Selection.Current){
		if(ControlTypeOptions[CurrentControlData.ControlType].NoResize){
			EditorWinShowResizeHandles(0)
			return
		}
		
		GuiControlGet Control, Editor:Pos, % Selection.Current
		ControlX1 := ControlX, ControlY1 := ControlY
		ControlX2 := ControlX1 + ControlW
		ControlY2 := ControlY1 + ControlH
		ControlMX := Floor(ControlX1 + ControlW / 2)
		ControlMY := Floor(ControlY1 + ControlH / 2)
		
		EditorWinUpdateResizeHandle("TL", ControlX1, ControlY1)
		EditorWinUpdateResizeHandle("TR", ControlX2, ControlY1)
		EditorWinUpdateResizeHandle("BL", ControlX1, ControlY2)
		EditorWinUpdateResizeHandle("BR", ControlX2, ControlY2)
		EditorWinUpdateResizeHandle("T", ControlMX, ControlY1)
		EditorWinUpdateResizeHandle("B", ControlMX, ControlY2)
		EditorWinUpdateResizeHandle("L", ControlX1, ControlMY)
		EditorWinUpdateResizeHandle("R", ControlX2, ControlMY)
		
		EditorWinShowResizeHandles()
	}
}

EditorWinUpdateResizeHandle(HandleName, HandleX, HandleY){
	HandleVar := EditorWinResizeHandle.Handles[HandleName]
	HandleHwnd := HandleVar.Hwnd
	HandleVar.X := (HandleX -= RESIZE_HANDLE_HALF_SIZE)
	HandleVar.Y := (HandleY -= RESIZE_HANDLE_HALF_SIZE)
	GuiControl ResizeHandles:Move, %HandleHwnd%, x%HandleX% y%HandleY%
}

EditorWinSetCurrentParent(ControlHwnd, PageNumber := 0){
	if(ControlHwnd){
		ControlData := CurrentGui.Controls[ControlHwnd]
		CurrentParent := ControlData.Index | (PageNumber << 16)
		CurrentParentHwnd := ControlHwnd
		Gui ControlEditOverlay:Show, NoActivate
		Winset Top, , % EditorWinControlEditOverlay.Id
		EditorWinControlEditOverlay.Visible := 1
		EditorWinUpdateOverlayWindow(EditorWinControlEditOverlay.Hwnd)
		EditorWinUpdateControlEditOverlay(EditorWinContextControlHwnd)
	}
	else{
		CurrentParent := CurrentParentHwnd := 0
		Gui ControlEditOverlay:Hide
		EditorWinControlEditOverlay.Visible := 0
	}
}

EditorWinUpdateTabPage(ControlHwnd, PreviousTab, NewTab){
	ControlData := CurrentGui.Controls[ControlHwnd]
	if(NewTab = PreviousTab)
		return
	
	PreviousTabParent := ControlData.Index | (PreviousTab << 16)
	NewTabParent := ControlData.Index | (NewTab << 16)
	
	ParentControlSetVisible(PreviousTabParent, 0)
	ParentControlSetVisible(NewTabParent, 1)
	
	if(CurrentParent = PreviousTabParent)
		CurrentParent := NewTabParent
		, EditorWinUpdateControlEditOverlay()
}

EditorWinUpdateOverlayWindow(Hwnd := 0){
	; Positions the overlay window over the editor window
	
	if(!Hwnd)
		Hwnd := Selection.Window
	X := Y := 0
	ClientToScreen(EditorWinHwnd, X, Y)
	GetClientSize(EditorWinHwnd, w, h)
	WinMove ahk_id %Hwnd%, , %x%, %y%, %w%, %h%
}

; -- Events
; -----------------------------------------------------------------

EditorWinSubroutinesDef(){
	return
	
	OnEditorWinArrowKey:
		OnEditorWinArrowKey()
	return
	
	OnEditorWinClose:
		OnEditorWinClose()
	return
	
	OnEditorWinContextMenu:
		OnEditorWinContextMenu()
	return
	
	OnEditorWinEscapeKey:
		OnEditorWinEscapeKey()
	return
	
	OnEditorWinMouseMove:
		OnEditorWinMouseMove()
	return
}

OnEditorWinArrowKey(){
	; If two arrows keys are pressed at the same time they may run at the same time which could cause incorrectly position resize handles
	Critical ; Prevents this thread from being interrupted
	
	if(!Selection.Current)
		return
	
	Amount := GetKeyState("Shift", "P") ? 10 : GetKeyState("Ctrl", "P") ? Settings.GridSize : 1
	
	AmountX := A_ThisHotkey = "*Left" ? -Amount : A_ThisHotkey = "*Right" ? Amount : 0
	AmountY := A_ThisHotkey = "*Up" ? -Amount : A_ThisHotkey = "*Down" ? Amount : 0
	
	for ControlHwnd in Selection.Controls{
		ControlData := CurrentGui.Controls[ControlHwnd]
		if(ControlTypeOptions[ControlData.ControlType].NoMove)
			continue	
	
		GuiControlGet Control, Editor:Pos, %ControlHwnd%
		ControlX += AmountX
		ControlY += AmountY
		GuiControl Editor:Move, %ControlHwnd%, x%ControlX% y%ControlY%
		EditorWinUpdateHighlight(ControlHwnd)
		ForceControlRedraw(ControlHwnd)
		
		ControlData.Position[1] := ControlX
		ControlData.Position[2] := ControlY
	}
	
	OnPropertyWinPropertyChange("Common", "Position")
	ShowControlInfoToolTip(Selection.Current, "auto", "", 1000)
	EditorWinUpdateResizeHandles()
}

OnEditorWinClose(){
	CreateNewGui()
}

OnEditorWinContextMenu(){
	ItemName := CleanMenuItemName(A_ThisMenuItem)
	
	if(A_ThisMenu = "EditorWinContextMenuAddControl"){
		EditorWinAddControl(ItemName, EditorWinContextMenuX, EditorWinContextMenuY)
		return
	}
	
	if(ItemName = "Cut"){
		MainWinExecuteMainMenuAction("Edit", "Cut")
	}
	
	else if(ItemName = "Copy"){
		MainWinExecuteMainMenuAction("Edit", "Copy")
	}
	
	else if(ItemName = "Paste"){
		MainWinExecuteMainMenuAction("Edit", "Paste")
	}
	
	else if(ItemName = "Delete"){
		MainWinExecuteMainMenuAction("Edit", "Delete")
	}
	
	else if(ItemName = "SelectAll"){
		MainWinExecuteMainMenuAction("Edit", "SelectAll")
	}
	
	else if(ItemName = "DeselectAll"){
		MainWinExecuteMainMenuAction("Edit", "DeselectAll")
	}
	
	ControlName := ""
	StringReplace ControlName, A_ThisMenu, EditorWinContextMenu
	StringReplace ControlName, ControlName, Control
	
	if(ControlName = "Picture"){
		if(ItemName = "ResetImageSize"){
			Gui Editor:Default
			Options := "*w0 *h0 " (CurrentControlData.IconIndex > 0 ? "*Icon" CurrentControlData.IconIndex " " : "")
			GuiControl, , % Selection.Current, % Options CurrentControlData.Text
			GuiControlGet Control, Pos, % Selection.Current
			CurrentControlData.Size[1] := ControlW
			CurrentControlData.Size[2] := ControlH
			OnPropertyWinPropertyChange("Common", "Size")
			EditorWinUpdateResizeHandles()
			EditorWinUpdateHighlight(Selection.Current)
		}
		
		else if(ItemName = "OpenContainingFolder"){
			if((Path := Trim(CurrentControlData.Text)) != ""){
				Path := ExpandEnvironmentStrings(Path)
				SplitPath, Path, , Path
				if((Path := Trim(Path)) != "")
					Run %Path%
			}
		}
	}
	
	else if(ControlName = "GroupBox"){
		if(ItemName = "LinkChildren"){
			ControlData := CurrentGui.Controls[EditorWinContextControlHwnd]
			ControlData._LinkChildren := ControlData._LinkChildren ? 0 : 2
		}
	}
	
	else if(ControlName = "Tab2"){
		if(ItemName = "EditCurrentTabPage"){
			TabNumber := GetTabNumber(EditorWinContextControlHwnd)
			EditorWinSetCurrentParent(EditorWinContextControlHwnd, TabNumber)
		}
		
		else if(ItemName = "ExitTabPageEditMode"){
			EditorWinSetCurrentParent(0)
		}
		
		else if(ItemName = "MoveSelectedIntoCurrentTab"){
			ControlData := CurrentGui.Controls[EditorWinContextControlHwnd]
			Parent := ControlData.Index | (GetTabNumber(ControlData) << 16)
			Property := PropertiesDef.Common.Parent
			
			for ControlHwnd in Selection.Controls{
				ChildControlData := CurrentGui.Controls[ControlHwnd]
				PropertyClass.ControlType := ChildControlData.ControlType
				if(ControlHwnd = EditorWinContextControlHwnd or Property.Get("Disable"))
					continue
				
				if(ChildControlData.Parent)
					ParentControlAddChild(ChildControlData.Parent, ChildControlData.Index, 0)
				ChildControlData.Parent := Parent
				ParentControlAddChild(Parent, CurrentGui.Controls[ControlHwnd].Index)
			}
			
			if(Selection.Current)
				OnPropertyWinPropertyChange("Common", "Parent")
		}
		
		else if(ItemName = "MoveSelectedOutOfTab"){
			ControlData := CurrentGui.Controls[EditorWinContextControlHwnd]
			Parent := ControlData.Index | (GetTabNumber(ControlData) << 16)
			
			for ControlHwnd in Selection.Controls{
				ChildControlData := CurrentGui.Controls[ControlHwnd]
				if(ControlHwnd = EditorWinContextControlHwnd or ChildControlData.Parent != Parent)
					continue
				ChildControlData.Parent := 0
				ParentControlAddChild(Parent, ChildControlData.Index, 0)
			}
			
			if(Selection.Current)
				OnPropertyWinPropertyChange("Common", "Parent")
		}
		
		else if(ItemName = "LinkChildren"){
			ControlData := CurrentGui.Controls[EditorWinContextControlHwnd]
			ControlData._LinkChildren := !ControlData._LinkChildren
		}
	}
}

OnEditorWinControlDisableMouseWindowProc(hwnd, msg, wParam, lParam){
	Critical
	
	; Disable interacting with scrollbars with the mouse
	
	if(msg = WM_NCRBUTTONDOWN){
		return 0
	}
	
	else if(msg = WM_NCRBUTTONUP){
		SendMessage WM_RBUTTONUP, wParam, lParam, , ahk_id %EditorWinHwnd%
	}
	
	else if(msg = WM_RBUTTONDOWN){
		return 0
	}
	
	if(msg = WM_NCLBUTTONDBLCLK){
		return 1
	}
	
	else if(msg = WM_NCLBUTTONDOWN){
		; Pass the message along to the editor window because scrollbars block the WM_LBUTTONDOWN for some reason
		wParam := (GetKeyState("Control", "P") ? MK_CONTROL : 0) | (GetKeyState("Shift", "P") ? MK_SHIFT : 0)
		lParam := 0
		SendMessage WM_LBUTTONDOWN, wParam, lParam, , ahk_id %EditorWinHwnd%
		return 1
	}
	
	return DllCall("CallWindowProc", Ptr,A_EventInfo, Ptr,hwnd, UInt,msg, Ptr,wParam, Ptr,lParam)
}

OnEditorWinControlSysLinkWindowProc(hwnd, msg, wParam, lParam){
	Critical
	
	if(msg = WM_SETCURSOR){
		return 1
	}
	
	return DllCall("CallWindowProc", Ptr,A_EventInfo, Ptr,hwnd, UInt,msg, Ptr,wParam, Ptr,lParam)
}

OnEditorWinControlListViewHeaderWindowProc(hwnd, msg, wParam, lParam){
	Critical
	
	if(msg = WM_SETCURSOR){
		return 1
	}
	
	return DllCall("CallWindowProc", Ptr,A_EventInfo, Ptr,hwnd, UInt,msg, Ptr,wParam, Ptr,lParam)
}

OnEditorWinEscapeKey(){
	; Various actions can be canceled with the escape key
	
	if(EditorMouseDownMode = "TargetControl"){
		EditorWinStartControlTargetMode(0)
	}
	
	if(EditorMouseDownMode = "DebugInspect"){
		CursorOverlayWindow.Show()
		EditorMouseDownMode := CurrentAppAction := 0
		MainWinStatusText()
	}
	
	else if(SubStr(EditorMouseDownMode, 1, 3) = "Add"){
		EditorMouseDownMode := 0
		MainWinSetControlAddMode("")
		MainWinStatusText()
		CurrentAppAction := 0
	}
	
	else if(EditorMouseMoveMode = "MoveControl"){
		OnEditorWinMouseUp()
		StoreControlStates(Selection.Controls, "load")
	}
	
	else if(EditorMouseMoveMode = "ResizeControl"){
		OnEditorWinMouseUp()
		StoreControlStates(Selection.Current, "load")
	}
	
	else if(EditorMouseMoveMode = "SelectionRect"){
		EditorControlAnchorX := ""
		OnEditorWinMouseUp()
	}
	
	EditorWinListenForEscape(0)
	EditorMouseWaitForDown := 0
}

OnEditorWinMouseDoubleClick(wParam, lParam, msg, hwnd){
	; Simply prevents double clicks from interacting normally (ticking checkboxes, etc.) with controls added to the editor window
	
	FindControlParentWindow(hwnd, ParentWindow)
	
	if(ParentWindow = EditorWinHwnd or EditorMouseDownMode = "TargetControl"){
		return 1
	}
}

OnEditorWinMouseRightUp(wParam, lParam, msg, hwnd){
	; Prevents right clicks from interacting normally (ticking checkboxes, etc.) with controls added to the editor window
	; and also handles the display of the editor context menu
	
	if(CurrentAppAction)
		return
	
	; Catch clicks on disabled and other types of controls
	if(hwnd = EditorWinHwnd){
		MouseGetPos, , , WinHwnd, ControlHwnd, 2
		if(ControlHwnd and WinHwnd = EditorWinHwnd)
			hwnd := ControlHwnd
	}
	
	FindControlParentWindow(hwnd, ParentWindow)
	
	if(ParentWindow = EditorWinHwnd){
		EditorWinGetMousePos(EditorWinContextMenuX, EditorWinContextMenuY, 1, 1)
		
		if(!CurrentGui.Controls.HasKey(hwnd))
			hwnd := DllCall("GetParent", Ptr,hwnd)
		EditorWinContextControlHwnd := hwnd
		
		if((ControlData := CurrentGui.Controls[hwnd]) and (MenuData := EditorWinContextMenus[ControlData.ControlType])){
			MenuName := "EditorWinContextMenuControl" (IsObject(MenuData) ? MenuData.ControlType : MenuData)
			for ItemName, PropertyName in MenuData.Properties
				Menu %MenuName%, % ControlData[PropertyName] ? "Check" : "Uncheck", %ItemName%
			Menu %MenuName%, Show
		}
		else
			Menu EditorWinContextMenu, Show
		
		return 1
	}
}

OnEditorWinMouseDown(wParam, lParam, msg, Hwnd, ByRef ReturnValue){
	if(EditorMouseWaitForDown){
		EditorMouseWaitForDown := 0
		ReturnValue := 0
		return
	}
	
	FindControlParentWindow(Hwnd, ParentWindow)
	EditorWinGetMousePos(MouseX, MouseY, 0) ; Get the actual editor mouse coordinates
	
	; Resize handles
	
	if(!EditorMouseDownMode and EditorWinResizeHandle.Visible){ ; < The resize handles cannot be dragged when another action is taking place
		EditorControlAnchorX := ""
		
		for HandleName, Handle in EditorWinResizeHandle.Handles{
			if(MouseX >= Handle.X and MouseX <= Handle.X + RESIZE_HANDLE_SIZE and MouseY >= Handle.Y and MouseY <= Handle.Y + RESIZE_HANDLE_SIZE){
				EditorControlAnchorX := HandleName
				break
			}
		}
		
		; One of the handles was pressed so start dragging
		if(EditorControlAnchorX != ""){
			EditorWinResizeHandle.AspectRatio := CurrentControlData.Size[1] / CurrentControlData.Size[2]
			StoreControlStates(Selection.Current)
			EditorMouseMoveMode := CurrentAppAction := "ResizeControl"
			EditorWinListenForEscape()
			EditorWinShowResizeHandles(0)
			ShowControlInfoToolTip(Selection.Current)
			ReturnValue := 0
			
			EditorWinGetMousePos(MouseX, MouseY, 0)
			EditorPrevMouseX := MouseX, EditorPrevMouseY := MouseY
		}
	}
	
	if(ParentWindow = EditorWinHwnd and !EditorMouseMoveMode){
		EditorMouseDownModifierKeys := (wParam & MK_SHIFT) | (wParam & MK_CONTROL) | (GetKeyState("Alt") ? MK_ALT : 0)
		
		EditorPrevMouseX := MouseX, EditorPrevMouseY := MouseY
		EditorWinGetMousePos(MouseX, MouseY, 2) ; Snap the cooridnates to the grid according to the settings and modifier keys
		;~ out("  Mouse Down <" MouseX ", " MouseY "> " EditorMouseDownMode)
		
		; Catch clicks on disabled and other types of controls
		if(Hwnd = EditorWinHwnd){
			MouseGetPos, , , WinHwnd, ControlHwnd, 2
			if(ControlHwnd and WinHwnd = EditorWinHwnd)
				Hwnd := ControlHwnd
		}
		
		if(EditorMouseDownMode = "TargetControl"){
			TargetControlHwnd := hwnd != EditorWinHwnd ? hwnd : 0
			PropertyWinControlTargetSelect(TargetControlHwnd)
			EditorWinStartControlTargetMode(0)
		}
		
		else if(EditorMouseDownMode = "DebugInspect"){
			CursorOverlayWindow.Hide()
			EditorMouseDownMode := CurrentAppAction := 0
			MainWinStatusText()
			
			if(Hwnd){
				if(Hwnd != EditorWinHwnd and !CurrentGui.Controls.HasKey(Hwnd))
					Hwnd := DllCall("GetParent", Ptr,Hwnd)
				ControlData := !(EditorMouseDownModifierKeys & MK_SHIFT)
					? (Hwnd = EditorWinHwnd ? CurrentGui.Window : CurrentGui.Controls[Hwnd])
					: CurrentGui
				MainWinShowDebugWindow("----------------------------------------------------------`n"
					. (EditorMouseDownModifierKeys & MK_SHIFT ? "CurrentGui" : Hwnd = EditorWinHwnd ? "Window" : ControlData.Id)
					. "`n----------------------------------------------------------`n"
					. PrintObjFormatted(ControlData, MainWinDebugWinFunc, MainWinDebugWinFilter))
			}
		}
		
		; In Add mode, add a new control and start resizing
		else if(SubStr(EditorMouseDownMode, 1, 3) = "Add"){
			EditorControlAnchorX := MouseX
			EditorControlAnchorY := MouseY
			AddType := SubStr(EditorMouseDownMode, 4)
			NewControlHwnd := EditorWinAddControl(AddType, MouseX, MouseY, ControlData)
			
			EditorWinSelectControl(NewControlHwnd)
			EditorWinShowResizeHandles(0)
			MainWinStatusText()
			
			if(!ControlTypeOptions[AddType].NoResize){
				EditorMouseMoveMode := CurrentAppAction := "ResizeControl"
				ShowControlInfoToolTip(Selection.Current)
				StoreControlStates(Selection.Current)
				EditorWinResizeHandle.AspectRatio := ControlData.Size[1] / ControlData.Size[2]
			}
			else
				CurrentAppAction := 0
			
			; Add multiple controls in a row
			if(!NewControlHwnd or !(EditorMouseDownModifierKeys & MK_SHIFT)){
				EditorMouseDownMode := 0
				MainWinSetControlAddMode("")
			}
		}
		
		; Empty space was clicked, either deselect or start dragging a selection rectangle
		else if(Hwnd = EditorWinHwnd){
			EditorMouseDownControl := -1
			EditorMouseMoveMode := CurrentAppAction := "WaitForMove"
			EditorControlAnchorX := EditorMouseX
			EditorControlAnchorY := EditorMouseY
		}
		
		; Clicked on a control, either select it or start dragging
		else{
			; Embedded controls, eg. ComboBox has a child Edit
			if(!CurrentGui.Controls.HasKey(Hwnd))
				Hwnd := DllCall("GetParent", Ptr,Hwnd)
			
			EditorMouseDownControl := Hwnd
			EditorMouseMoveMode := CurrentAppAction := "WaitForMove"
			EditorControlAnchorX := ""
		}
		
		; A return value of 0 prevents the click from interacting normally (ticking checkboxes, etc.) with controls in the editor window
		ReturnValue := 0
	}
	
	else if(EditorMouseDownMode = "TargetControl"){
		EditorWinStartControlTargetMode(0)
		ReturnValue := 0
	}
	
	; If an action has taken place listen for mouse movement
	if(EditorMouseMoveMode or EditorMouseDownControl){
		SetTimer OnEditorWinMouseMove, -0
	}
}

OnEditorWinMouseMove(){
	static ControlAnchors
		, ControlList := [], ControlListSize := 0
	
	While(EditorMouseMoveMode and (EditorMouseWaitForDown or GetKeyState("LButton", "P"))){
		; First get the actual mouse coordinates and check if the mouse has changed position since the last call
		EditorWinGetMousePos(MouseX, MouseY, 0)
		;~ out("  " MouseX, EditorPrevMouseX ", " MouseY, EditorPrevMouseY)
		if(MouseX = EditorPrevMouseX and MouseY = EditorPrevMouseY)
			goto OnEditorWinMouseMove_EndLoop
		
		EditorPrevMouseX := MouseX, EditorPrevMouseY := MouseY
		EditorWinGetMousePos(MouseX, MouseY, 2) ; Then snap the cooridnates to the grid according to the settings and modifier keys
		;~ out("OnMouseMove <" MouseX ", " MouseY "> " EditorMouseMoveMode " [" A_TickCount "]")
		
		if(EditorMouseMoveMode){
			; Certain actions, such as selecting or dragging, only take affect when the mouse is moved or released, when that is the case EditorMouseMoveMode is set to "WaitForMove"
			if(EditorMouseMoveMode = "WaitForMove"){
				; If the mouse was pressed in empty space the user wants to drag a selection box
				if(EditorMouseDownControl = -1){
					EditorMouseMoveMode := CurrentAppAction := "SelectionRect"
					Gui SelectionRectWin:Show, NoActivate
					EditorWinUpdateOverlayWindow(Selection.RectWinHwnd)
					
					; Start a new selection if no modifier keys were pressed
					if(EditorMouseDownModifierKeys & MK_SHIFT = 0 and EditorMouseDownModifierKeys & MK_CONTROL = 0)	
						EditorWinSelectControl(0, "clear")
				}
				; If the mouse was pressed on a control the user wants to start moving
				else{
					EditorMouseMoveMode := CurrentAppAction := "MoveControl"
					; Either select this control or add it to the current selection if shift was pressed
					if(EditorMouseDownControl and !Selection.Controls[EditorMouseDownControl])
						EditorWinSelectControl(EditorMouseDownControl, EditorMouseDownModifierKeys & MK_SHIFT ? "add" : "select")
					StoreControlStates(Selection.Controls)
				}
				
				EditorWinListenForEscape()
			}
			
			if(EditorMouseMoveMode = "ResizeControl"){
				;~ out(CurrentControlData)
				ControlX := CurrentControlData.Position[1], ControlY := CurrentControlData.Position[2]
				ControlW := CurrentControlData.Size[1], ControlH := CurrentControlData.Size[2]
				
				; The mouse was moved for the first time, initialize the anchor points
				if EditorControlAnchorX is alpha
				{
					if(EditorControlAnchorX = "TL"){
						EditorControlAnchorX := ControlX + ControlW
						EditorControlAnchorY := ControlY + ControlH
					}
					else if(EditorControlAnchorX = "TR"){
						EditorControlAnchorX := ControlX
						EditorControlAnchorY := ControlY + ControlH
					}
					else if(EditorControlAnchorX = "BL"){
						EditorControlAnchorX := ControlX + ControlW
						EditorControlAnchorY := ControlY
					}
					else if(EditorControlAnchorX = "BR"){
						EditorControlAnchorX := ControlX
						EditorControlAnchorY := ControlY
					}
					else if(EditorControlAnchorX = "T"){
						EditorControlAnchorX := ""
						EditorControlAnchorY := ControlY + ControlH
					}
					else if(EditorControlAnchorX = "B"){
						EditorControlAnchorX := ""
						EditorControlAnchorY := ControlY
					}
					else if(EditorControlAnchorX = "L"){
						EditorControlAnchorX := ControlX + ControlW
						EditorControlAnchorY := ""
					}
					else if(EditorControlAnchorX = "R"){
						EditorControlAnchorX := ControlX
						EditorControlAnchorY := ""
					}
				}
				
				; Resize along the x-axis
				if(EditorControlAnchorX != ""){
					if(MouseX > EditorControlAnchorX){
						W := MouseX - EditorControlAnchorX
						if(W < CONTROL_MIN_SIZE)
							W := CONTROL_MIN_SIZE
						X := EditorControlAnchorX
					}
					else{
						W := EditorControlAnchorX - MouseX
						if(W < CONTROL_MIN_SIZE)
							W := CONTROL_MIN_SIZE
						X := EditorControlAnchorX - W
					}
				}
				else{ ; No resizing along the x-axis
					X := ControlX
					W := ControlW
				}
				
				; Resize along the y-axis
				if(EditorControlAnchorY != ""){
					if(MouseY > EditorControlAnchorY){
						H := MouseY - EditorControlAnchorY
						if(H < CONTROL_MIN_SIZE)
							H := CONTROL_MIN_SIZE
						Y := EditorControlAnchorY
					}
					else{
						H := EditorControlAnchorY - MouseY
						if(H < CONTROL_MIN_SIZE)
							H := CONTROL_MIN_SIZE
						Y := EditorControlAnchorY - H
					}
				}
				else{ ; No resizing along the y-axis
					Y := ControlY
					H := ControlH
				}
				
				if(EditorControlAnchorX != "" and EditorControlAnchorY != "" and GetKeyState("Shift", "P")){
					H := Round(W / EditorWinResizeHandle.AspectRatio)
					if(MouseY < EditorControlAnchorY)
						Y := EditorControlAnchorY - H
				}
				
				Property := PropertiesDef.Common.Size, PropertyClass.ControlType := CurrentControlData.ControlType
				CurrentControlData.Position[1] := X
				CurrentControlData.Position[2] := Y
				CurrentControlData.Size[1] := W
				CurrentControlData.Size[2] := H
				
				SizeString := "x" X " y" Y (W != "" ? " w" W : "") (H != "" ? " h" H : "")
				GuiControl Editor:Move, % Selection.Current, %SizeString%
				ForceControlRedraw(Selection.Current)
				ShowControlInfoToolTip(Selection.Current)
				EditorWinUpdateHighlight(Selection.Current)
				MainWinStatusText("Resize control`t`tGrid toggle: Ctrl | Cancel: Escape")
				
				OnPropertyWinPropertyChange("Common", "Position", "Common", "Size")
				if(Selection.Current = CurrentParentHwnd)
					EditorWinUpdateControlEditOverlay(CurrentParentHwnd)
			}
			
			else if(EditorMouseMoveMode = "MoveControl"){
				; The mouse was moved for the first time, reset the anchor points
				if(EditorControlAnchorX = ""){
					ControlAnchors := {}
					EditorControlAnchorX := 0
					EditorWinGetMousePos(AnchorMouseX, AnchorMouseY, 1, 1)
				}
				
				ControlListSize := 0
				for ControlHwnd in Selection.Controls{
					ControlList[++ControlListSize] := ControlHwnd
					while(ControlListSize > 0){
						ControlHwnd := ControlList[ControlListSize--]
						ControlData := CurrentGui.Controls[ControlHwnd]
						if(ControlTypeOptions[ControlData.ControlType].NoMove)
							continue
						
						; The mouse was moved for the first time, initialize the anchor points for this control
						if(ControlAnchors[ControlHwnd "X"] = ""){
							GuiControlGet Control, Editor:Pos, %ControlHwnd%
							ControlAnchors[ControlHwnd "X"] := AnchorMouseX - ControlData.Position[1]
							ControlAnchors[ControlHwnd "Y"] := AnchorMouseY - ControlData.Position[2]
						}
						
						X := MouseX - ControlAnchors[ControlHwnd "X"]
						Y := MouseY - ControlAnchors[ControlHwnd "Y"]
						GuiControl Editor:MoveDraw, %ControlHwnd%, x%X% y%Y%
						EditorWinUpdateHighlight(ControlHwnd)
						
						ControlData.Position[1] := X
						ControlData.Position[2] := Y
						
						if(ControlHwnd = CurrentParentHwnd)
							EditorWinUpdateControlEditOverlay(CurrentParentHwnd)
						
						; Child controls
						if(ControlData._LinkChildren = 2){
							for Index, ControlHwnd in EditorControlStateGroup
								ControlList[++ControlListSize] := ControlHwnd
						}
						else if(ControlData._LinkChildren){
							for PageNumber in ControlData._HasChildrenOnPage
								for ChildIndex in ParentControls[ControlData.Index | (PageNumber << 16)].Children
									ControlList[++ControlListSize] := CurrentGui.ControlIndexes[ChildIndex]
						}
					}
				}
				
				OnPropertyWinPropertyChange("Common", "Position")
				EditorWinShowResizeHandles(0)
				ShowControlInfoToolTip(EditorMouseDownControl)
				
				MainWinStatusText("Move control`t`tGrid toggle: Ctrl | Cancel: Escape")
			}
			
			else if(EditorMouseMoveMode = "SelectionRect"){
				X := EditorMouseX < EditorControlAnchorX ? EditorMouseX : EditorControlAnchorX
				Y := EditorMouseY < EditorControlAnchorY ? EditorMouseY : EditorControlAnchorY
				W := (EditorMouseX > EditorControlAnchorX ? EditorMouseX : EditorControlAnchorX) - X
				H := (EditorMouseY > EditorControlAnchorY ? EditorMouseY : EditorControlAnchorY) - Y
				GuiControl SelectionRectWin:Move, % Selection.Rect, x%X% y%Y% w%W% h%H%
			}
		}
		
		OnEditorWinMouseMove_EndLoop:
		Sleep 16 ; 16 ms ~ 60 frames per second
	}
	
	OnEditorWinMouseUp()
}

OnEditorWinMouseUp(){
	;~ out("Mouse Up > Down: " EditorMouseDownMode ", Move: " EditorMouseMoveMode)
	
	MouseMoveMode := EditorMouseMoveMode
	EditorMouseMoveMode := CurrentAppAction := 0
	
	; Certain actions, such as selecting or dragging, only take affect when the mouse is moved or released, when that is the case EditorMouseMoveMode is set to "WaitForMove"
	if(MouseMoveMode = "WaitForMove"){
		; Empty space was clicked which clears the current selection
		if(EditorMouseDownControl = -1){
			EditorWinSelectControl(0, "clear")
		}
		; A control was clicked, either select it, add it, or remove from the current selection depending on the modifier keys
		else{
			EditorWinSelectControl(EditorMouseDownControl, EditorMouseDownModifierKeys & MK_CONTROL ? "remove" : EditorMouseDownModifierKeys & MK_SHIFT ? "add" : "select")
			if(EditorMouseDownModifierKeys & MK_CONTROL = 0){
				EditorWinUpdateResizeHandles()
			}
		}
	}
	
	else if(MouseMoveMode = "ResizeControl"){
		EditorWinUpdateResizeHandles()
		ToolTip
		MainWinStatusText()
	}
	
	else if(MouseMoveMode = "MoveControl"){
		EditorWinUpdateResizeHandles()
		ToolTip
		MainWinStatusText()
	}
	
	else if(MouseMoveMode = "SelectionRect"){
		; Only if the action was not canceled
		if(EditorControlAnchorX != ""){
			EditorWinGetMousePos(MouseX, MouseY, 0)
			X1 := EditorMouseX < EditorControlAnchorX ? EditorMouseX : EditorControlAnchorX
			Y1 := EditorMouseY < EditorControlAnchorY ? EditorMouseY : EditorControlAnchorY
			X2 := (EditorMouseX > EditorControlAnchorX ? EditorMouseX : EditorControlAnchorX)
			Y2 := (EditorMouseY > EditorControlAnchorY ? EditorMouseY : EditorControlAnchorY)
			
			Deselect := EditorMouseDownModifierKeys & MK_CONTROL
			
			for ControlHwnd, ControlData in CurrentGui.Controls{
				if(!ParentControls[ControlData.Parent].Visible)
					continue
				
				GuiControlGet Control, Editor:Pos, %ControlHwnd%
				ControlW += ControlX, ControlH += ControlY
				if(ControlX >= X1 and ControlW <= X2 and ControlY >= Y1 and ControlH <= Y2)
					EditorWinSelectControl(ControlHwnd, Deselect ? "remove" : "add", 0)
			}
			EditorWinUpdateResizeHandles()
			PropertyWinUpdateGroups()
		}
		
		GuiControl SelectionRectWin:Move, % Selection.Rect, x0 y0 w0 h0
		Gui SelectionRectWin:Hide
	}
	
	; Add multiple (Shift) - Display the add tooltip again
	if(SubStr(EditorMouseDownMode, 1, 3) = "Add")
		MainWinSetControlAddMode("", EditorMouseDownMode)
	
	if(!EditorMouseDownMode)
		EditorWinListenForEscape(0)
	
	EditorMouseDownModifierKeys := 0, EditorMouseDownControl := 0
}

OnEditorWinPropertyEdit(PropertyGroup, PropertyName, Data, ControlHwnd := 0, PreviousValue := ""){
	; Informs the editor that a control's property has changed
	; Called by the property editor window when a property is edited by the user
	
	ControlType := Data.ControlType
	Property := PropertiesDef[PropertyGroup][PropertyName], PropertyClass.ControlType := ControlType
	if(Property.Get("IgnoreProperty"))
		return
	
	Gui Editor:Default
	if(!ControlHwnd)
		ControlHwnd := Selection.Current
	if((EditPropertyName := Property.Get("EditPropertyName")))
		PropertyName := EditPropertyName
	
	if(PropertyGroup = "Gui" or PropertyGroup = "GuiOptions"){
		if(PropertyName = "BackgroundColour" or PropertyName = "ControlColour"){
			CtrlColour := Data.ControlColour = "" ? "Default" : Data.ControlColour
			EditorWinUpdateGrid()
			Gui Color, , %CtrlColour%
			
			for ControlHwnd, ControlData in CurrentGui.Controls
				if(!ControlData.HasOwnBackground and !ControlTypeOptions[ControlData.ControlType].NoGuiBGColour)
					GuiControl +Background%CtrlColour%, %ControlHwnd%
		}
		
		else if(PropertyName = "C"){
			C := "+c" (Data.C = "" ? "Default" : Data.C)
			for ControlHwnd, ControlData in CurrentGui.Controls{
				if(ControlData.C = "" and !ControlTypeOptions[ControlData.ControlType].NoGuiTextColour){
					GuiControl %C%, %ControlHwnd%
					ForceControlRedraw(ControlHwnd)
				}
			}
			
			CurrentGui.DefaultColour := Data.C
		}
		
		else if(PropertyName = "Delimiter"){
			if(Data.Delimiter = "``t")
				Data.Delimiter := "Tab"
			else if(Data.Delimiter != "Space" and Data.Delimiter != "Tab" and Data.Delimiter != "``n")
				Data.Delimiter := SubStr(Data.Delimiter, 1, 1)
			if(Data.Delimiter = " ")
				Data.Delimiter := "Space"
			CurrentGui.Delimiter := Data.Delimiter = "Space" ? " "
				: Data.Delimiter = "Tab" or Data.Delimiter = "``t" ? "`t"
				: Data.Delimiter = "``n" ? "`n"
				: Data.Delimiter = "" ? "|" : Data.Delimiter
		}
		
		else if(PropertyName = "Font"){
			GuiC := Data.C
			ExportOptionGuiNameLabel := "Editor:"
			BuildGuiFontOptions("Reset")
			BuildGuiFontOptions(CurrentGui.Window, 0, "Gui")
			for ControlHwnd, ControlData in CurrentGui.Controls{
				BuildGuiFontOptions(ControlData)
				GuiControl Font, %ControlHwnd%
				; The (GuiControl Font) resets the control colour, make sure to set it back
				C := ControlData.C = "" ? GuiC : ControlData.C
				GuiControl % "+c" (C = "" ? "Default" : C), %ControlHwnd%
			}
			
			Gui Font
		}
		
		else if(PropertyName = "Size"){
			WinMove ahk_id %EditorWinHwnd%, , , , % Data.Size[1] + EditorWinNCX, % Data.Size[2] + EditorWinNCY
			; Fixes redraw issues with the property window controls when resizing the editor window >
			Sleep 0
			PropertyWinRedrawOverlayWindow()
		}
		
		else if(PropertyName = "Theme"){
			Gui % (Data.Theme = "Yes" ? "+" : "-") "Theme"
			
			NewControls := {}
			for ControlHwnd in CurrentGui.Controls
				RecreateControl(ControlHwnd, NewControls)
			CurrentGui.Controls := NewControls
		}
		
		else if(PropertyName = "Title"){
			Gui Show, NoActivate, % GetPropertyValue(PropertyGroup, PropertyName, Data)
		}
	}
	
	else{
		if(Property.Get("RecreateOnEdit")){
			RecreateControl(ControlHwnd)
		}
		
		else if(Property.Get("UseConstantOnEdit")){
			Control Style, % (Data[PropertyName] = "Yes" ? "+" : "-") GetConstant(Property.Get("Constant")), , ahk_id %ControlHwnd%
		}
		
		else if((UsePropertyNameOnEdit := Property.Get("UsePropertyNameOnEdit"))){
			Type := Property.Get("Type")
			
			if(IsObject(UsePropertyNameOnEdit)){
				Command := UsePropertyNameOnEdit[(Data[PropertyName] = "Yes") + 1]
			}
			
			else if(Type = "Int"){
				Value := GetPropertyValue(PropertyGroup, PropertyName, Data)
				Value := Value = 0 and Property.Get("OutputIgnore" Value) ? "" : Value
				Command := (Value != "" ? "+" : "-") PropertyName Value
			}
			
			else if(Type = "Text" or Type = "MultiText" or Type = "Var" or Type = "Label"){
				Value := GetPropertyValue(PropertyGroup, PropertyName, Data)
				Command := (Value != "" ? "+" : "-") PropertyName Value
			}
			
			else{
				Command := (Data[PropertyName] = "Yes" ? "+" : "-") PropertyName
			}
			
			GuiControl %Command%, %ControlHwnd%
			
			if((RedrawAfterEdit := Property.Get("RedrawAfterEdit")))
				ForceControlRedraw(ControlHwnd, RedrawAfterEdit = 2)
		}
		
		else if(PropertyName = "Background"){
			if(Data.Background = "")
				Data.Remove("HasOwnBackground")
			else
				Data.HasOwnBackground := 1
			Colour := Data.Background = "" and !ControlTypeOptions[Data.ControlType].NoGuiBGColour ? GetPropertyValue("Gui", "ControlColour", CurrentGui.Window) : Data.Background
			Command := "+Background" (Colour = "" ? "Default" : Colour)
			
			GuiControl %Command%, %ControlHwnd%
		}
		
		else if(PropertyName = "Border"){
			Command := Data.Border = "Yes" or ControlType = "Picture" and !Data.HasValidPicture ? "+Border" : "-Border"
			GuiControl %Command%, %ControlHwnd%
			ForceControlRedraw(ControlHwnd, 1)
		}
		
		else if(PropertyName = "Choose"){
			OptionNumber := Data.Choose
			
			if(ControlType = "DropDownList" or ControlType = "ComboBox"){
				OptionCount := GetListCount(Data.Text, GUI_DELIMITER)
				OptionNumber := OptionNumber > OptionCount ? 0 : OptionNumber
			}
			else if(ControlType = "Tab2"){
				OptionCount := GetListCount(Data.Text, GUI_DELIMITER)
				OptionNumber := OptionNumber > OptionCount or OptionNumber = "" or OptionNumber = 0 ? 1 : OptionNumber
				ControlGet PreviousTab, Tab, , , ahk_id %ControlHwnd%
			}
			
			GuiControl Choose, %ControlHwnd%, % OptionNumber != "" ? OptionNumber : 0
			
			; Update the tab child controls only after changing the active tab to avoid redraw issues when the control is outside of the tab
			if(ControlType = "Tab2"){
				EditorWinUpdateTabPage(ControlHwnd, PreviousTab, OptionNumber)
			}
		}
		
		else if(PropertyName = "C"){
			C := Data.C = "" and !ControlTypeOptions[Data.ControlType].NoGuiTextColour ? CurrentGui.DefaultColour : Data.C
			GuiControl % "+c" (C = "" ? "Default" : C), %ControlHwnd%
			ForceControlRedraw(ControlHwnd)
		}
		
		else if(PropertyName = "Check3"){
			GuiControl % (Data.Check3 = "Yes" ? "+" : "-") "Check3" , %ControlHwnd%
			GuiControl, , %ControlHwnd%, % ControlTypeOptions.Checkbox.States[GetPropertyValue("Checkbox", "State", Data)]
		}
		
		else if(PropertyName = "Checked"){
			GuiControl, , %ControlHwnd%, % (Checked := Data.Checked = "Yes")
			
			if(Checked and Data.Group != ""){
				RadioGroup := CurrentGui.RadioGroups[Data.Group]
				CurrentId := Data.Index
				for ControlId in RadioGroup.Controls{
					ControlHwnd := CurrentGui.ControlIndexes[ControlId]
					ControlData := CurrentGui.Controls[ControlHwnd]
					if(ControlId != CurrentId and ControlData.Checked = "Yes")
						ControlData.Checked := "No"
						, OnEditorWinPropertyEdit("Radio", "Checked", ControlData, ControlHwnd)
				}
			}
		}
		
		else if(PropertyName = "DateTimeDate"){
			UseDate := GetPropertyValue("DateTime", "Date", Data)
			CheckBox := GetPropertyValue("DateTime", "DateTimeCheckBox", Data) = "Yes"
			ControlGet ControlStyle, Style, , , ahk_id %ControlHwnd%
			HasCheckBox := ControlStyle & DTS_SHOWNONE
			
			if(UseDate = "Default")
				SelectedDate := A_Now
			else if(UseDate = "Selected")
				SelectedDate := GetPropertyValue("DateTime", "SelectedDate", Data)
			else if(UseDate = "None")
				SelectedDate := ""
			
			if((VarName := Property.Get("EmptyValueVar")))
				SelectedDate := SelectedDate = "" ? %VarName% : SelectedDate
			
			if(UseDate = "None" and !HasCheckBox or !CheckBox and HasCheckBox and UseDate != "None")
				RecreateControl(ControlHwnd)
			else
				GuiControl, , %ControlHwnd%, %SelectedDate%
		}
		
		else if(PropertyName = "Font"){
			ExportOptionGuiNameLabel := "Editor:"
			BuildGuiFontOptions("Reset")
			BuildGuiFontOptions(CurrentGui.Window, 0, "Gui")
			BuildGuiFontOptions(Data)
			GuiControl Font, %ControlHwnd%
			C := Data.C = "" ? CurrentGui.DefaultColour : Data.C
			GuiControl % "+c" (C = "" ? "Default" : C), %ControlHwnd%
			Gui Font
		}
		
		else if(PropertyName = "Group"){
			EditorWinUpdateRadioGroup(Data)
		}
		
		else if(PropertyName = "Justify"){
			if(Data.Justify = "None" or Data.Justify = "")
				GuiControl -Left -Right -Center, %ControlHwnd%
			else
				GuiControl % "+" Data.Justify, %ControlHwnd%
		}
		
		else if(PropertyName = "ListViewColumns"){
			EditorWinUpdateListViewColumns(ControlHwnd, GetPropertyValue("Common", "Text", Data))
		}
		
		else if(PropertyName = "MonthCalDate"){
			DateMin := SubStr(Data.Text[1], 2)
			DateMax := SubStr(Data.Text[2], 2)
			IsDateRange := DateMax != "" and DateMin != ""
			NotEmpty := DateMax != "" or DateMin != ""
			Value := DateMin (IsDateRange or NotEmpty and !Property.Get("AllowSingle") ? "-" : "") DateMax
			if((VarName := Property.Get("EmptyValueVar")) and DateMin = "" and DateMax = "")
				Value := %VarName%
			
			GuiControl, , %ControlHwnd%, %Value%
		}
		
		else if(PropertyName = "Password"){
			Command := (Data.Password[1] = "Yes" ? "+" : "-") "Password" (Data.Password[1] = "Yes" ? Data.Password[2] : "")
			GuiControl %Command%, %ControlHwnd%
			ForceControlRedraw(ControlHwnd)
		}
		
		else if(PropertyName = "Parent"){
			ParentControlType := CurrentGui.Controls[ CurrentGui.ControlIndexes[Data.Parent & 0xFFFF] ].ControlType
			AllowedTypes := Property.Get("AllowedTypes")
			
			if(AllowedTypes = "" or InStr(AllowedTypes, ParentControlType)){
				if(PreviousValue)
					ParentControlAddChild(PreviousValue, Data.Index, 0)
				if(Data.Parent)
					ParentControlAddChild(Data.Parent, Data.Index)
			}
			else{
				Data.Parent := PreviousValue
			}
		}
		
		else if(PropertyName = "PictureFileName"){
			FileName := Data.Text	
			
			if(Data.IconIndex > 0)
				FileName := "*Icon" Data.IconIndex " " FileName
			
			GuiControl, , %ControlHwnd%, %FileName%
			
			GuiControlGet Control, Pos, %ControlHwnd%
			if(ControlW = 0 or ControlH = 0 or !FileExist(ExpandEnvironmentStrings(Data.Text))){
				GuiControl +Border, %ControlHwnd%
				GuiControl Move, %ControlHwnd%, % "w" Data.Size[1] " h" Data.Size[2]
				Data.HasValidPicture := 0
			}
			else{
				Data.HasValidPicture := 1
				if(!Data.Border)
					GuiControl -Border, %ControlHwnd%
			}
		}
		
		else if(PropertyName = "Position"){
			X := Data.Position[1]
			Y := Data.Position[2]
			GuiControl Move, %ControlHwnd%, x%X% y%Y%
			EditorWinUpdateHighlight(ControlHwnd)
			EditorWinUpdateResizeHandles()
		}
		
		else if(PropertyName = "Range"){
			if(ControlType = "MonthCal"){
				DateMin := SubStr(Data.Range[1], 2)
				DateMax := SubStr(Data.Range[2], 2)
				Options := (DateMin = "" and DateMax = "" ? "+" : "+") "Range" (DateMin = "" ? "00000001" : DateMin) "-" (DateMax = "" ? "99991231" : DateMax)
				GuiControl %Options%, %ControlHwnd%
			}
			
			else if(ControlType = "UpDown" or ControlType = "Slider" or ControlType = "Progress"){
				Options := "+Range" (Data.Range[1] != "" ? Data.Range[1] : MIN_INT) "-" (Data.Range[2] != "" ? Data.Range[2] : MAX_INT)
				GuiControl %Options%, %ControlHwnd%
				
				; Need to refresh the Progress "Position" after changing the range otherwise it will be dispalyed incorrectly
				if(ControlType = "Progress")
					GuiControl, , %ControlHwnd%, % GetPropertyValue("Common", "Text", Data)
			}
		}
		
		else if(PropertyName = "Size"){
			SizeString := (Data.Size[1] != "" ? "w" Data.Size[1] : "") (Data.Size[2] != "" ? " h" Data.Size[2] : "")
			GuiControl Move, %ControlHwnd%, %SizeString%
			EditorWinUpdateHighlight(ControlHwnd)
			EditorWinUpdateResizeHandles()
			ForceControlRedraw(ControlHwnd)
		}
		
		else if(PropertyName = "Smooth"){
			if(Data.Smooth != "Yes")
				RecreateControl(ControlHwnd)
			else
				GuiControl +Smooth, %ControlHwnd%
		}
		
		else if(PropertyName = "State"){
			GuiControl, , %ControlHwnd%, % ControlTypeOptions.Checkbox.States[Data.State]
		}
		
		else if(PropertyName = "T"){
			TabStops := Trim(Data.T)
			Command := ""
			Loop Parse, TabStops, %A_Space%
				if(A_LoopField != "")
					Command .= " t" A_LoopField
			Command := (Command = "") ? "-Tn" : ("+Tn" Command)
			GuiControl %Command%, %ControlHwnd%
		}
		
		else if(PropertyName = "Target"){
			if(ControlType = "UpDown"){
				if( (PreviousTarget := PreviousValue & 0xFFFF) )
					CurrentGui.Controls[ CurrentGui.ControlIndexes[PreviousTarget] ].UpDownBuddy := 0
				
				if(Data.Target != ""){
					TargetControlHwnd := CurrentGui.ControlIndexes[Data.Target]
					TargetControlData := CurrentGui.Controls[TargetControlHwnd]
					
					if(TargetControlData.UpDownBuddy and TargetControlData.UpDownBuddy != CurrentControlData.Index){
						CallThreadedFunction(ErrorMessageFunc, "That control already has an associated UpDown")
						Data.Target := ""
					}
					else{
						TargetControlData.UpDownBuddy := CurrentControlData.Index
						SendMessage UDM_SETBUDDY, %TargetControlHwnd%, 0, , ahk_id %ControlHwnd%
						UpdateControlSize(ControlHwnd, 1)
						EditorWinUpdateHighlight(ControlHwnd)
						EditorWinUpdateResizeHandles()
						OnPropertyWinPropertyChange("Common", "Position", "Common", "Size")
						UpdateControlSize(TargetControlHwnd, 1)
					}
				}
			}
		}
		
		else if(PropertyName = "Text"){
			Value := GetPropertyValue("Common", "Text", Data)
			
			if(Property.Get("MultiTextLayout") = "Options")
				Value := GUI_DELIMITER Value
			
			if(ControlTypeOptions[ControlType].PlaceHolderTpl)
				Value := RegExReplace(ControlTypeOptions[ControlType].PlaceHolderTpl, "<Text>", Value = "" ? "" : "[" Value "]")
			 
			if((VarName := Property.Get("EmptyValueVar")))
				Value := Value = "" ? %VarName% : Value
			
			GuiControl, , %ControlHwnd%, %Value%
			
			if((UpdatePropertyName := Property.Get("UpdateAfter")))
				OnEditorWinPropertyEdit(ControlType, UpdatePropertyName, Data)
		}
		
		else if(PropertyName = "Theme"){
			RecreateControl(ControlHwnd)
		}
		
		if((CheckAfterEdit := Property.Get("CheckAfterEdit"))){
			if(Data[PropertyName] = CheckAfterEdit[1])
				OnEditorWinPropertyEdit(CheckAfterEdit[2], CheckAfterEdit[3], Data, ControlHwnd)
		}
	}
}

OnEditorWinRecreateControl(ControlHwnd, ControlNewHwnd){
	if(Selection.Current = ControlHwnd)
		Selection.Current := ControlNewHwnd
	if((HighlightHwnd := Selection.Controls[ControlHwnd])){
		Selection.Controls.Remove(ControlHwnd, "")
		Selection.Controls[ControlNewHwnd] := HighlightHwnd
		EditorWinUpdateHighlight(ControlNewHwnd)
		EditorWinUpdateResizeHandles()
	}
}

OnEditorWinTargetControlModeMouseMoveOverride(wParam, lParam, msg, hwnd){
	if(hwnd = EditorWinHwnd){
		MouseGetPos, , , WinHwnd, ControlHwnd, 2
		if(ControlHwnd and WinHwnd = EditorWinHwnd)
			hwnd := ControlHwnd
	}
	
	if( (ControlData := CurrentGui.Controls[hwnd]) )
		ShowToolTip("Control: " ControlData.Id)
	else
		ToolTip
	
	return 1
}

OnEditorWinTargetControlModeSetCursorOverride(wParam, lParam, msg, hwnd){
	static CurrentHwnd := 0
	
	if(CurrentHwnd != hwnd){
		CurrentHwnd := hwnd
		DllCall("SetCursor", Ptr,EditorWinTargetCursor)
	}
	
	return 1
}

OnEditorWinWindowProc(hwnd, msg, wParam, lParam){
	Critical
	
	if(msg = WM_SETCURSOR){
		WinGetClass ClassNN, ahk_id %wParam%
		if(ClassNN = "Edit") ; Use the default cursor for edit controls instead of the I-beam
			return 1
	}
	else if(msg = WM_SETFOCUS){
		return 0 ; Prevents controls from receiving focus when the editor window is focused
	}
	else if(msg = WM_CTLCOLORDLG){
		return EditorWinUpdateGrid()
	}
	else if(msg = WM_MOVE){
		EditorWinUpdateResizeHandles()
		EditorWinUpdateOverlayWindow()
		if(EditorWinResizeHandle.Visible)
			EditorWinUpdateOverlayWindow(EditorWinResizeHandle.Hwnd)
		if(EditorWinControlEditOverlay.Visible)
			EditorWinUpdateOverlayWindow(EditorWinControlEditOverlay.Hwnd)
	}
	else if(msg = WM_SIZE){
		EditorWinUpdateResizeHandles()
		EditorWinUpdateOverlayWindow()
		if(EditorWinResizeHandle.Visible)
			EditorWinUpdateOverlayWindow(EditorWinResizeHandle.Hwnd)
		if(EditorWinControlEditOverlay.Visible)
			EditorWinUpdateOverlayWindow(EditorWinControlEditOverlay.Hwnd)
			, EditorWinUpdateControlEditOverlay(0, 1)
		
		if(EditorWinNCX != ""){
			for ControlHwnd in Selection.Controls
				if(ControlTypeOptions[CurrentGui.Controls[ControlHwnd].ControlType].UpdateOnResize)
					EditorWinUpdateHighlight(ControlHwnd)
			
			GetClientSize(EditorWinHwnd, W, H)
			CurrentGui.Window.Size[1] := W, CurrentGui.Window.Size[2] := H
			OnPropertyWinPropertyChange("Gui", "Size")
		}
	}
	
	return DllCall("CallWindowProc", Ptr,A_EventInfo, Ptr,hwnd, UInt,msg, Ptr,wParam, Ptr,lParam)
}