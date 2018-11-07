; -- Initialize variables
; -----------------------------------------------------------------
{

global PropertyWinHwnd
	 , PropertyWinHeaderHwnd
	 , PropertyWinContainerHwnd
	 , PropertyWinOverlayHwnd
	 , PropertyWinSubWin := {CurrentLayout: 0, Layouts: {}}
	 
	 , PropertyWinWidth			:= 320
	 , PropertyWinHeaderHeight	:= 24
	 , PropertyNameColWidth		:= 150
	 , PropertyWinRowHeight		:= 23
	 , PropertyWinPageHeight
	 
	 , PropertyWinRowHeightImageList := DllCall("ImageList_Create", Int,1, Int,PropertyWinRowHeight - 1, Int,ILC_COLOR4, Int,1, Int,1)
	 , PropertyWinListViews		:= {Count: 0, Current: [], CurrentCount: 0}
	 , PropertyWinCurrentControlType := 0
	 , PropertyWinCurrentItem	:= {ListView: 0, ItemIndex: -1, Selected: 0, OverlayWin: {ProcessFocusChange: 1}}
	 , PropertyWinPropertyTypeLayouts := {CurrentLayout: 0, NotificationTypes: {}}
	 , PropertyWinRedrawOverlayWindowFunc := Func("PropertyWinRedrawOverlayWindow")
	
 }

; -- Functions
; -----------------------------------------------------------------

PropertyWinActivateListView(ListView){
	Gui %PropertyWinContainerHwnd%:Default
	Gui ListView, %ListView%
}

PropertyWinActiviteOverlayWindow(){
	PropertyWinGetCurrentProperty(GroupName, PropertyName, Property)
	PropertyLayout := PropertyWinPropertyTypeLayouts[Property.Get("Type")]
	ControlFocus , , % "ahk_id " PropertyLayout.PrimaryControl
	Hotkey $Esc, OnPropertyWinOverlayEscape, On
	Hotkey $Enter, OnPropertyWinOverlayEscape, On
	Sleep 0 ; Let the focus change and the list view redraw before redrawing the overlay window
	PropertyWinRedrawOverlayWindow()
}

PropertyWinClearListViewSelection(){
	if(PropertyWinCurrentItem.Selected){
		PropertyWinActivateListView(PropertyWinCurrentItem.ListView)
		LV_Modify(0, "-Select")
		PropertyWinSelectItem(0, -1)
		DllCall("SetFocus", Ptr,0)
	}
}

PropertyWinControlTargetSelect(ControlHwnd){
	if(ControlHwnd = Selection.Current)
		return
	
	PropertyWinGetCurrentProperty(PropertyGroup, PropertyName, Property)
	PreviousTarget := CurrentControlData[PropertyName]
	
	if(!ControlHwnd)
		CurrentControlData[PropertyName] := 0
	else{
		Page := 0
		TargetControlData := CurrentGui.Controls[ControlHwnd]
		if(Property.Get("AllowParentPage")){
			if(TargetControlData.ControlType = "Tab2")
				Page := GetTabNumber(TargetControlData)
		}
		
		CurrentControlData[PropertyName] := TargetControlData.Index | (Page << 16 & 0xFFFF0000)
		OnEditorWinPropertyEdit(PropertyGroup, PropertyName, CurrentControlData, 0, PreviousTarget)
		OnPropertyWinPropertyChange(PropertyGroup, PropertyName)
	}
}

PropertyWinCreateGui(){
	DefaultPropertyWinHeight := 600
	DefaultPropertyWinHeight := 700
	Gui Properties:New, HwndPropertyWinHwnd OwnerMain LabelOnPropertyWin ToolWindow Resize MinSize%PropertyWinWidth%x200 MaxSize%PropertyWinWidth%x, Properties
	SubClassWindow(PropertyWinHwnd, "OnPropertyWinWindowProc")
	GroupAdd PropertyWinGroup, ahk_id %PropertyWinHwnd%
	
	; --- Header
	 
	Gui Add, Custom, ClassSysHeader32 w%PropertyWinWidth% h%PropertyWinHeaderHeight% x0 y0 HwndPropertyWinHeaderHwnd -TabStop
	HD_EX_Insert(PropertyWinHeaderHwnd, 1, "Property", PropertyNameColWidth + 1)
	HD_EX_Insert(PropertyWinHeaderHwnd, 2, "Value", PropertyWinWidth - PropertyNameColWidth)
	
	; Scroll view
	
	; WS_EX_CONTROLPARENT enables tabbing between controls in child windows, required because of a bug in windows?
	Gui New, HwndPropertyWinContainerHwnd Parent%PropertyWinHwnd% ToolWindow -Caption LastFound %WS_VSCROLL% E%WS_EX_CONTROLPARENT%
	Gui %PropertyWinContainerHwnd%:Color, 0xFFFFFF
	Gui %PropertyWinContainerHwnd%:Show
	SubClassWindow(PropertyWinContainerHwnd, "OnPropertyWinContainerWindowProc")
	
	PropertyWinCreatePropertyOverlayWindow()
	
	PropertyWinUpdateGroups()
	
	Gui Properties:Show, x2 y2 w%PropertyWinWidth% h%DefaultPropertyWinHeight% NoActivate
	; Update the window width because MinSize and MaxSize settings seem to intefere with the size specified in the show command when MinSizeX = MaxSizeX
	WinMove ahk_id %PropertyWinHwnd%, , , , %PropertyWinWidth%
}

PropertyWinCreatePropertyGroupListView(PropertiesName){
	Gui %PropertyWinContainerHwnd%:Default
	
	Properties := PropertiesDef[PropertiesName]
	PropertyList := Properties.GroupIndexes
	PropertiesHeader := Properties.GroupHeading
	
	Width := PropertyWinWidth - SM_CXVSCROLL
	ItemCount := PropertyList.MaxIndex()
	for Index, PropertyName in PropertyList
		if(Properties[PropertyName].NoDisplay)
			ItemCount--
	
	ListViewHeight := ItemCount * PropertyWinRowHeight
	Gui Add, ListView, x0 y0 w%Width% h%ListViewHeight% Grid -Hdr -Multi -E%WS_EX_CLIENTEDGE% HwndListViewHwnd Hidden Disabled, Property|Value
	SubClassWindow(ListViewHwnd, "OnPropertyWinListViewWindowProc")
	LV_SetImageList(PropertyWinRowHeightImageList, 1)
	LV_ModifyCol(1, PropertyNameColWidth)
	LV_ModifyCol(2, Width - PropertyNameColWidth)
	LV_ModifyCol(2, "Right")
	
	PropertyWinListViews[++PropertyWinListViews.Count] := Properties.ListViewHwnd := ListViewHwnd
	PropertyWinListViews[ListViewHwnd] := ListView := {Index:PropertyWinListViews.Count, PropertiesName: PropertiesName, HeaderPic: 0
		, Height: ListViewHeight, MouseOver: 0, ItemIndexMap: ItemIndexMap := {}}
	
	if(PropertiesHeader){
		Gui Add, Picture, x0 y0 w%Width% h%PropertyWinRowHeight% HwndHeaderPic Hidden Disabled, images\item-header-grad.ico
		Gui Font, Bold
		Gui Add, Text, x5 y0 BackgroundTrans Hidden HwndHeaderText, %PropertiesHeader%
		Gui Font
		
		ListView.HeaderPic := HeaderPic, ListView.HeaderText := HeaderText
	}
	
	ItemIndex := 1
	for Index, PropertyName in PropertyList{
		Property := Properties[PropertyName]
		if(Property.NoDisplay)
			continue
		ItemIndexMap[ItemIndex] := Index
		Property.ItemIndex := ItemIndex++
		if(!Property.HasKey("Name"))
			Property.Name := PropertyName
		LV_Add("", "", "")
	}
}

PropertyWinCreatePropertyOverlayWindow(){
	static ControlSelectBtn, ControlClearBtn
		 , FontClearBtn
		 , SubWinOptionsUpBtn, SubWinOptionsDownBtn, SubWinOptionsAddBtn, SubWinOptionsRemoveBtn
	
	Gui New, HwndPropertyWinOverlayHwnd Parent%PropertyWinContainerHwnd% -Caption ToolWindow LastFound E%WS_EX_CONTROLPARENT% ; Enables tabbing between controls in this child window
	Gui %PropertyWinOverlayHwnd%:Default
	SubClassWindow(PropertyWinOverlayHwnd, "OnPropertyWinOverlayWindowProc")
	Gui Color, 0xFFFFFF
	
	Width := PropertyWinWidth - SM_CXVSCROLL - PropertyNameColWidth - 1
	Height := PropertyWinRowHeight - 1
	
	; Sub window
	{
		Gui New, HwndSubWinHwnd +Resize -Caption MinSize200x230 Owner%PropertyWinHwnd% AlwaysOnTop
		PropertyWinSubWin.Hwnd := SubWinHwnd
		SubClassWindow(PropertyWinSubWin.Hwnd, "OnPropertyWinSubWinWindowProc")
		Gui %SubWinHwnd%:Show, w200 h230 Hide
		Gui %PropertyWinOverlayHwnd%:Default
	}
	
	; Text
	{
		PropertyWinPropertyTypeLayouts.Text := CurrentLayout := {Controls: {}, Events: {}}
		
		Gui Add, Edit, x0 y0 w%Width% h%Height% Right HwndControlHwnd Hidden Disabled
		CurrentLayout.Controls.Edit := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
	}
	
	; TextToggle
	{
		PropertyWinPropertyTypeLayouts.TextToggle := CurrentLayout := {Controls: {}, Events: {}}
		
		X := 21
		W := Width - X
		Gui Add, Checkbox, x4 y0 w17 h%Height% HwndSubControl1Hwnd Hidden Disabled ; Don't use the BS_NOTIFY because there is no need to focus a checkbox
		Gui Add, Edit, x%X% y0 w%W% h%Height% Right HwndControlHwnd Hidden Disabled
		CurrentLayout.Controls.Edit := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
		CurrentLayout.Controls.Checkbox := SubControl1Hwnd, CurrentLayout.Events[SubControl1Hwnd] := "OnPropertyWinItemEdit"
	}
	
	; MultiText
	{
		PropertyWinPropertyTypeLayouts.MultiText := CurrentLayout := {Controls: {}, Events: {}}
		
		W := Width - Height
		Gui Add, Edit, x0 y0 w%W% h%Height% Right HwndControlHwnd Hidden Disabled
		Gui Add, Button, x%W% y0 w%Height% h%Height% HwndSubControlHwnd Hidden Disabled, ...
		CustomMouseDownEvents[SubControlHwnd] := {Threaded: Func("OnPropertyWinSubWinBtnClick"), Init: 1}
		CurrentLayout.Controls.Edit := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
		CurrentLayout.Controls.EditBtn := SubControlHwnd
		
		PropertyWinSubWin.Layouts.MultiText := SubWinLayout := {Controls: {}, Events: {}, Anchors: {}}
		Gui % PropertyWinSubWin.Hwnd ":Default"
		Gui Add, Edit, x0 y0 w10 h10 HwndEditHwnd WantTab -Wrap HScroll Multi Hidden
		Gui Add, Button, x0 y0 h26 w60 HwndCloseBtn Hidden, Close
		SubWinLayout.Controls.Edit := EditHwnd, SubWinLayout.Events[EditHwnd] := "OnPropertyWinSubWinMultilineChange"
		SubWinLayout.Controls.CloseBtn := CloseBtn, SubWinLayout.Events[CloseBtn] := "OnPropertyWinSubWinClose"
		PropertyWinSubWinAnchor(SubWinLayout, EditHwnd, "L 4 T 4 R 4 B 38")
		PropertyWinSubWinAnchor(SubWinLayout, CloseBtn, "L 4 B 4")
		
		Gui %PropertyWinOverlayHwnd%:Default
	}
	
	; Int
	{
		PropertyWinPropertyTypeLayouts.Int := CurrentLayout := {Controls: {}, Events: {}}
		
		Gui Add, Edit, x0 y0 w%Width% h%Height% Right HwndControlHwnd Hidden Disabled
		Gui Add, UpDown, Range%MIN_INT%-%MAX_INT% %UDS_NOTHOUSANDS% HwndSubControlHwnd Hidden Disabled
		RestrictInput(ControlHwnd, RI_INTEGER)
		CurrentLayout.Controls.Edit := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
		CurrentLayout.Controls.UpDown := SubControlHwnd
	}
	
	; IntToggle
	{
		PropertyWinPropertyTypeLayouts.IntToggle := CurrentLayout := {Controls: {}, Events: {}}
		
		X := 21
		W := Width - X
		Gui Add, Checkbox, x4 y0 w17 h%Height% HwndSubControl1Hwnd Hidden Disabled ; Don't use the BS_NOTIFY because there is no need to focus a checkbox
		Gui Add, Edit, x%X% y0 w%W% h%Height% Right HwndControlHwnd Hidden Disabled
		Gui Add, UpDown, Range%MIN_INT%-%MAX_INT% %UDS_NOTHOUSANDS% HwndSubControl2Hwnd Hidden Disabled
		RestrictInput(ControlHwnd, RI_INTEGER)
		CurrentLayout.Controls.Edit := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
		CurrentLayout.Controls.Checkbox := SubControl1Hwnd, CurrentLayout.Events[SubControl1Hwnd] := "OnPropertyWinItemEdit"
		CurrentLayout.Controls.UpDown := SubControl2Hwnd
	}
	
	; Label
	{
		PropertyWinPropertyTypeLayouts.Label := CurrentLayout := {Controls: {}, Events: {}}
		
		Gui Add, Edit, x0 y0 w%Width% h%Height% Right HwndControlHwnd Hidden Disabled
		RestrictInput(ControlHwnd, RI_LABEL)
		CurrentLayout.Controls.Edit := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
	}
	
	; Var
	{
		PropertyWinPropertyTypeLayouts.Var := CurrentLayout := {Controls: {}, Events: {}}
		
		Gui Add, Edit, x0 y0 w%Width% h%Height% Limit253 Right HwndControlHwnd Hidden Disabled
		RestrictInput(ControlHwnd, RI_VARIABLE)
		CurrentLayout.Controls.Edit := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
	}
	
	; XY
	{
		PropertyWinPropertyTypeLayouts.XY := CurrentLayout := {Controls: {}, Events: {}}
		
		W := (Width - 5) / 2
		X := W + 5
		Gui Add, Edit, x0 y0 w%W% h%Height% Right HwndControlHwnd Hidden Disabled
		Gui Add, UpDown, Range%MIN_INT%-%MAX_INT% %UDS_NOTHOUSANDS% HwndSubControlHwnd Hidden Disabled
		RestrictInput(ControlHwnd, RI_INTEGER)
		CurrentLayout.Controls.EditX := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
		CurrentLayout.Controls.UpDownX := SubControlHwnd
		Gui Add, Edit, x%X% y0 w%W% h%Height% Right HwndControlHwnd Hidden Disabled
		Gui Add, UpDown, Range%MIN_INT%-%MAX_INT% %UDS_NOTHOUSANDS% HwndSubControlHwnd Hidden Disabled
		RestrictInput(ControlHwnd, RI_INTEGER)
		CurrentLayout.Controls.EditY := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
		CurrentLayout.Controls.UpDownY := SubControlHwnd
	}
	
	; Toggle
	{
		PropertyWinPropertyTypeLayouts.Toggle := CurrentLayout := {Controls: {}, Events: {}, DisableFocus: 1}
		
		X := Width - 17
		Gui Add, Checkbox, x%X% y4 HwndControlHwnd Hidden Disabled ; Don't use the BS_NOTIFY because there is no need to focus a checkbox
		CurrentLayout.Controls.Checkbox := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
	}
	
	; Control
	{
		PropertyWinPropertyTypeLayouts.Control := CurrentLayout := {Controls: {}, Events: {}}
		
		W := Width - Height * 2 - 2
		Gui Add, Text, x0 y4 w%W% h%Height% Right HwndControlHwnd Hidden Disabled
		X := Width - Height * 2
		Gui Add, Button, x%X% y0 w%Height% h%Height% HwndSubControl1Hwnd vControlSelectBtn +%BS_NOTIFY% Hidden Disabled
		X := Width - Height
		Gui Add, Button, x%X% y0 w%Height% h%Height% HwndSubControl2Hwnd vControlClearBtn Hidden Disabled
		GuiButtonIcon(SubControl1Hwnd, "images\target.ico", 1, 22, 10)
		GuiButtonIcon(SubControl2Hwnd, "images\delete.ico", 1, 22, 6)
		CustomMouseDownEvents[SubControl1Hwnd] := CustomMouseDownEvents[SubControl2Hwnd] := Func("OnPropertyWinOverlayControlBtnClick")
		CurrentLayout.Controls.Label := ControlHwnd
		CurrentLayout.Controls.TargetBtn := CurrentLayout.PrimaryControl := SubControl1Hwnd
		CurrentLayout.Controls.ClearBtn := SubControl2Hwnd
	}
	
	; List
	{
		PropertyWinPropertyTypeLayouts.List := CurrentLayout := {Controls: {}, Events: {}, SubLayout: {}}
		
		Gui Add, DropDownList, x0 y0 w%Width% h%Height% r20 -Lowercase HwndControlHwnd Hidden Disabled
		CurrentLayout.Controls.DropDownList := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
		CurrentLayout.SubLayout[ControlHwnd] := {Prop: "IsComboBox", Value: "", IsPrimary: 1, ControlName: "Edit"}
		PropertyWinPropertyTypeLayouts.NotificationTypes[ControlHwnd] := "CBN"
		Gui Add, ComboBox, x0 y0 w%Width% h%Height% r20 -Lowercase HwndControlHwnd Hidden Disabled
		CurrentLayout.Controls.ComboBox := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
		CurrentLayout.SubLayout[ControlHwnd] := {Prop: "IsComboBox", Value: 1, IsPrimary: 1, ControlName: "Edit"}
		PropertyWinPropertyTypeLayouts.NotificationTypes[ControlHwnd] := "CBN"
	}
	
	; Font
	{
		PropertyWinPropertyTypeLayouts.Font := CurrentLayout := {Controls: {}, Events: {}}
		
		W := Width - Height * 2 - 2
		Gui Add, Text, x0 y4 w%W% h%Height% -Wrap HwndControlHwnd Hidden Disabled
		X := Width - Height * 2
		Gui Add, Button, x%X% y0 w%Height% h%Height% HwndSubControl1Hwnd Hidden Disabled, ...
		X := Width - Height
		Gui Add, Button, x%X% y0 w%Height% h%Height% HwndSubControl2Hwnd vFontClearBtn Hidden Disabled
		GuiButtonIcon(SubControl2Hwnd, "images\delete.ico", 1, 22, 6)
		CustomMouseDownEvents[SubControl1Hwnd] := {Threaded: Func("OnPropertyWinOverlayFontBtnClick"), Param: "FontSelectBtn"}
		CustomMouseDownEvents[SubControl2Hwnd] := Func("OnPropertyWinOverlayFontBtnClick")
		
		CurrentLayout.Controls.Label := ControlHwnd
		CurrentLayout.Controls.ChooseBtn := SubControl1Hwnd
		CurrentLayout.Controls.ClearBtn := SubControl2Hwnd
	}
	
	; Date
	{
		PropertyWinPropertyTypeLayouts.Date := CurrentLayout := {Controls: {}, Events: {}}
		
		Gui Add, DateTime, x0 y0 w%Width% h%Height% 2 HwndControlHwnd Hidden Disabled
		CurrentLayout.Controls.DateTime := CurrentLayout.PrimaryControl := ControlHwnd, CurrentLayout.Events[ControlHwnd] := "OnPropertyWinItemEdit"
	}
	
	; DateRange
	{
		PropertyWinPropertyTypeLayouts.DateRange := CurrentLayout := {Controls: {}, Events: {}}
		
		W := (Width - 5) / 2
		X := W + 5
		Gui Add, DateTime, x0 y0 w%W% h%Height% 2 HwndControl1Hwnd Hidden Disabled
		CurrentLayout.Controls.DateTimeMin := CurrentLayout.PrimaryControl := Control1Hwnd, CurrentLayout.Events[Control1Hwnd] := "OnPropertyWinItemEdit"
		Gui Add, DateTime, x%X% y0 w%W% h%Height% 2 HwndControl2Hwnd Hidden Disabled
		CurrentLayout.Controls.DateTimeMax := Control2Hwnd, CurrentLayout.Events[Control2Hwnd] := "OnPropertyWinItemEdit"
	}
	
	
	; Picture image load menu
	{
		Menu PictureLoadMenu, Add, Load from File, OnPropertyWinPictureLoadMenu
		Menu PictureLoadMenu, Add, Load from Resource, OnPropertyWinPictureLoadMenu
	}
	
	; Options sub window
	{
		PropertyWinSubWin.Layouts.Options := SubWinLayout := {Controls: {}, Events: {}, Anchors: {}}
		Gui % PropertyWinSubWin.Hwnd ":Default"
		Gui Add, ListView, x0 y0 w100 h100 Grid -LV%LVS_EX_HEADERDRAGDROP% -ReadOnly NoSortHdr HwndListViewHwnd Hidden, Value
		LV_ModifyCol(1, 180)
		Gui Add, Button, x0 y0 h26 w40 HwndCloseBtn Hidden, Close
		Gui Add, Button, x0 y0 h26 w26 HwndUpBtn vSubWinOptionsUpBtn Hidden
		Gui Add, Button, x0 y0 h26 w26 HwndDownBtn vSubWinOptionsDownBtn Hidden
		Gui Add, Button, x0 y0 h26 w26 HwndAddBtn vSubWinOptionsAddBtn Hidden
		Gui Add, Button, x0 y0 h26 w26 HwndRemoveBtn vSubWinOptionsRemoveBtn Hidden
		GuiButtonIcon(UpBtn, "images\up.ico", 1, 22, 6)
		GuiButtonIcon(DownBtn, "images\down.ico", 1, 22, 6)
		GuiButtonIcon(AddBtn, "images\add.ico", 1, 22, 6)
		GuiButtonIcon(RemoveBtn, "images\remove.ico", 1, 22, 6)
		SubWinLayout.Controls.ListView := ListViewHwnd
		SubWinLayout.Controls.CloseBtn := CloseBtn, SubWinLayout.Events[CloseBtn] := "OnPropertyWinSubWinClose"
		SubWinLayout.Controls.UpBtn := UpBtn, SubWinLayout.Events[UpBtn] := "OnPropertyWinSubWinOptionsButtonClick"
		SubWinLayout.Controls.DownBtn := DownBtn, SubWinLayout.Events[DownBtn] := "OnPropertyWinSubWinOptionsButtonClick"
		SubWinLayout.Controls.AddBtn := AddBtn, SubWinLayout.Events[AddBtn] := "OnPropertyWinSubWinOptionsButtonClick"
		SubWinLayout.Controls.RemoveBtn := RemoveBtn, SubWinLayout.Events[RemoveBtn] := "OnPropertyWinSubWinOptionsButtonClick"
		PropertyWinSubWinAnchor(SubWinLayout, ListViewHwnd, "L 4 T 4 R 4 B 38")
		PropertyWinSubWinAnchor(SubWinLayout, CloseBtn, "L 4 B 4")
		PropertyWinSubWinAnchor(SubWinLayout, UpBtn, "R 94 B 4")
		PropertyWinSubWinAnchor(SubWinLayout, DownBtn, "R 64 B 4")
		PropertyWinSubWinAnchor(SubWinLayout, AddBtn, "R 34 B 4")
		PropertyWinSubWinAnchor(SubWinLayout, RemoveBtn, "R 4 B 4")
		
		Gui %PropertyWinOverlayHwnd%:Default
	}
	
	Gui Show, x0 y0 w%Width% h%Height% Hide
	WinSet Top, , ahk_id %PropertyWinOverlayHwnd%
}

PropertyWinGetCurrentProperty(ByRef GroupName, ByRef PropertyName, ByRef Property := 0){
	ListViewProperties := PropertyWinListViews[PropertyWinCurrentItem.ListView]
	GroupName := ListViewProperties.PropertiesName
	Properties := PropertiesDef[GroupName]
	PropertyName := Properties.GroupIndexes[ListViewProperties.ItemIndexMap[PropertyWinCurrentItem.ItemIndex + 1]]
	Property := Properties[PropertyName]
}

PropertyWinGetPropertyAt(ListViewHwnd, ItemIndex, ByRef GroupName, ByRef PropertyName, ByRef Property := 0){
	ListViewProperties := PropertyWinListViews[ListViewHwnd]
	GroupName := ListViewProperties.PropertiesName
	Properties := PropertiesDef[GroupName]
	PropertyName := Properties.GroupIndexes[ListViewProperties.ItemIndexMap[ItemIndex + 1]]
	Property := Properties[PropertyName]
}

PropertyWinGetItemRect(ListViewHwnd, ItemIndex, ByRef Left, ByRef Top, ByRef Right, ByRef Bottom){
	VarSetCapacity(Rect, 16, 0)
	NumPut(LVIR_BOUNDS, Rect, 0, "Int")
	NumPut(0,			Rect, 4, "Int")
	SendMessage LVM_GETSUBITEMRECT, %ItemIndex%, &Rect, , ahk_id %ListViewHwnd%
	Left := NumGet(Rect, 0, "Int"), Top := NumGet(Rect, 4, "Int")
	Right := NumGet(Rect, 8, "Int"), Bottom := NumGet(Rect, 12, "Int")
}

PropertyWinRedrawOverlayWindow(){
	WinSet Top, , ahk_id %PropertyWinOverlayHwnd%
	WinSet Redraw, , ahk_id %PropertyWinOverlayHwnd%
}

PropertyWinScrollToItem(ListView, ItemNumber){
	ItemNumber -= 1
	VarSetCapacity(Rect, 16, 0)
	NumPut(LVIR_BOUNDS, Rect, 0, "Int")
	NumPut(0,			Rect, 4, "Int")
	SendMessage LVM_GETSUBITEMRECT, %ItemNumber%, &Rect, , ahk_id %ListView%
	Top := NumGet(Rect, 4, "Int"), Bottom := NumGet(Rect, 12, "Int")
	MapWindowPoints(ListView, PropertyWinContainerHwnd, 0, Top)
	MapWindowPoints(ListView, PropertyWinContainerHwnd, 0, Bottom)
	ScrollWindow(PropertyWinContainerHwnd, WM_VSCROLL, "ScrollTo", Top, Bottom)
}

PropertyWinSelectItem(ListView, ItemIndex, Hover := 0){
	if(ItemIndex > -1){
		
		if(PropertyWinCurrentItem.ListView != ListView or PropertyWinCurrentItem.ItemIndex != ItemIndex or !Hover){
			if(PropertyWinCurrentItem.ListView != ListView or PropertyWinCurrentItem.ItemIndex != ItemIndex){
				; Update the previous property ListView item if changes have been made to the property
				if(PropertyWinCurrentItem.ListView and PropertyWinCurrentItem.ItemIndex > -1)
					PropertyWinUpdateCurrentProperty()
				
				if(PropertyWinCurrentItem.ListView and PropertyWinCurrentItem.ListView != ListView){
					PropertyWinActivateListView(PropertyWinCurrentItem.ListView)
					LV_Modify(0, "-Select")
				}
				
				PropertyWinCurrentItem.ListView  := ListView
				PropertyWinCurrentItem.ItemIndex := ItemIndex
				
				PropertyWinGetCurrentProperty(GroupName, PropertyName, Property), PropertyClass.ControlType := CurrentControlData.ControlType
				if(Property.Get("Disable") or Property.Get("ReadOnly")){
					Gui %PropertyWinOverlayHwnd%:Hide
					return
				}
				
				; Get the item's bounding rectangle and position the overlay window on top of it
				PropertyWinGetItemRect(ListView, ItemIndex, Left, Top, Right, Bottom)
				Width := Right - Left
				MapWindowPoints(ListView, PropertyWinContainerHwnd, Left, Top)
				WinGetPos, , , WinWidth, , ahk_id %PropertyWinOverlayHwnd%
				Left -= WinWidth - Width ; Align the overlay window with the right side of the ListView
				Gui %PropertyWinOverlayHwnd%:Show, x%Left% y%Top% NoActivate
				
				PropertyWinUpdateOverlayWindow()
			}
			else{
				PropertyWinGetCurrentProperty(GroupName, PropertyName, Property), PropertyClass.ControlType := CurrentControlData.ControlType
				Gui %PropertyWinOverlayHwnd%:Show, NoActivate
			}
			
			if(PropertiesDef.PropertyTypeOptions["NoSelect" Property.Type] or Property.Get("NoSelect"))
				PropertyWinActivateListView(PropertyWinCurrentItem.ListView), LV_Modify(0, "-Select -Focus")
			else
				PropertyWinCurrentItem.Selected := !Hover
			PropertyWinRedrawOverlayWindow()
		}
	}
	else if(PropertyWinCurrentItem.ItemIndex != -1){
		PropertyWinUpdateCurrentProperty()
		PropertyWinGetCurrentProperty(GroupName, PropertyName, Property)
		PropertyClass.ControlType := ""
		Gui %PropertyWinOverlayHwnd%:Hide
		PropertyWinCurrentItem.ListView  :=  0
		PropertyWinCurrentItem.ItemIndex := -1
		PropertyWinCurrentItem.Selected  :=  0
	}
}

PropertyWinSubWinAnchor(Layout, Control, Anchors){
	Position := "", Amount := ""
	Layout.Anchors[Control] := ControlAnchors := {}
	
	Loop Parse, Anchors, %A_Space%
	{
		if(Position = ""){
			Position := A_LoopField
			continue
		}
		
		Amount := A_LoopField
		ControlAnchors[Position] := Amount
		Position := ""
	}
}

PropertyWinUpdateCurrentProperty(FromSubWin := 0){
	ListView := FromSubWin ? PropertyWinSubWin.ListView : PropertyWinCurrentItem.ListView
	ItemIndex := FromSubWin ? PropertyWinSubWin.ItemIndex : PropertyWinCurrentItem.ItemIndex
	PropertyWinGetPropertyAt(ListView, ItemIndex, GroupName, PropertyName, Property)
	PropertyClass.ControlType := FromSubWin ? PropertyWinSubWin.ControlType : CurrentControlData.ControlType
	Gui %PropertyWinContainerHwnd%:Default
	Gui ListView, %ListView%
	LV_Modify(ItemIndex + 1, "Col2", GetPropertyValue(GroupName, PropertyName, CurrentControlData, 1))
}

PropertyWinUpdateGroups(Force := 0){
	Gui %PropertyWinContainerHwnd%:Default
	
	ControlType := CurrentControlData.ControlType
	Reposition := Force or PropertyWinCurrentControlType != ControlType
	PropertyWinCurrentControlType := ControlType
	GroupNames := PropertiesDef.GroupControlTypes[ControlType]
	
	; Hide current options
	if(Reposition){
		Loop % PropertyWinListViews.CurrentCount {
			ListViewHwnd := PropertiesDef[PropertyWinListViews.Current[A_Index]].ListViewHwnd
			ListView := PropertyWinListViews[ListViewHwnd]
			
			if(ListView.HeaderPic){
				Control, Hide, , , % "ahk_id " ListView.HeaderPic
				Control, Hide, , , % "ahk_id " ListView.HeaderText
			}
			
			Control, Hide, , , % "ahk_id " ListViewHwnd
			Control, Disable, , , % "ahk_id " ListViewHwnd
		}
		
		ScrollWindow(PropertyWinContainerHwnd, WM_VSCROLL, SB_TOP, 0)
	}
	
	Y := 0
	PropertyWinListViews.CurrentCount := GroupNames.MaxIndex()
	for Index, GroupName in GroupNames{
		Properties := PropertiesDef[GroupName]
		if(!Properties.HasKey("ListViewHwnd"))
			PropertyWinCreatePropertyGroupListView(GroupName)
		
		PropertyWinListViews.Current[Index] := GroupName
		ListViewHwnd := PropertiesDef[GroupName].ListViewHwnd
		ListView := PropertyWinListViews[ListViewHwnd]
		
		if(Reposition and (HeaderPic := ListView.HeaderPic)){
			HeaderText := ListView.HeaderText
			Control, Show, , , ahk_id %HeaderPic%
			GuiControl Move, %HeaderPic%, y%Y%
			
			TextY := Y + 4
			Control, Show, , , ahk_id %HeaderText%
			GuiControl Move, %HeaderText%, y%TextY%
			Y += PropertyWinRowHeight
		}
		
		; Update property values
		Gui ListView, %ListViewHwnd%
		RowIndex := 1
		for Index, PropertyName in Properties.GroupIndexes{
			Property := Properties[PropertyName]
			if(Property.NoDisplay)
				continue
			PropertyClass.ControlType := ControlType
			LV_Modify(RowIndex, "Col2", GetPropertyValue(GroupName, PropertyName, CurrentControlData, 1))
			LV_Modify(RowIndex++, "Col1", Property.Get("Name"))
		}
		
		; Show
		
		if(Reposition){
			Control, Show, , , ahk_id %ListViewHwnd%
			Control, Enable, , , ahk_id %ListViewHwnd%
			GuiControl %PropertyWinContainerHwnd%:Move, %ListViewHwnd%, y%Y%
			
			Y += ListView.Height
		}
	}
	
	if(Reposition){
		GetClientSize(PropertyWinHwnd, WinWidth, WinHeight)
		UpdateScrollBars(PropertyWinContainerHwnd, WinWidth, WinHeight - PropertyWinHeaderHeight)
	}
}

PropertyWinUpdateOverlayWindow(UpdateLayout := 1){
	Gui %PropertyWinOverlayHwnd%:Default
	
	PropertyWinGetCurrentProperty(GroupName, PropertyName, Property)
	PropertyClass.ControlType := CurrentControlData.ControlType
	Type := Property.Get("Type")
	PropertyLayout := PropertyWinPropertyTypeLayouts[PropertyWinPropertyTypeLayouts.CurrentLayout]
	
	if(UpdateLayout and Type != PropertyWinPropertyTypeLayouts.CurrentLayout or PropertyLayout.HasKey("SubLayout")){
		for Index, ControlHwnd in PropertyLayout.Controls{
			GuiControl Hide, %ControlHwnd%
			GuiControl Disable, %ControlHwnd%
		}
		
		PropertyWinPropertyTypeLayouts.CurrentLayout := Type
		PropertyLayout := PropertyWinPropertyTypeLayouts[Type]
		
		SubLayout := {}
		for ControlHwnd, Condition in PropertyLayout.SubLayout{
			if(Property.Get(Condition.Prop) = Condition.Value){
				SubLayout[ControlHwnd] := 0
				if(Condition.IsPrimary)
					PropertyLayout.PrimaryControl := ControlHwnd
				if(Condition.ControlName)
					PropertyLayout.Controls[Condition.ControlName] := ControlHwnd
			}
			else
				SubLayout[ControlHwnd] := 1
		}
		
		for Index, ControlHwnd in PropertyLayout.Controls{
			if(SubLayout[ControlHwnd])
				continue
			GuiControl Show, %ControlHwnd%
			GuiControl Enable, %ControlHwnd%
		}
	}
	
	; Prevent g-labels from being called when the values are updated
	for ControlHwnd, EventName in PropertyLayout.Events
		GuiControl -g, % ControlHwnd
	
	if(Type = "Int" or Type = "IntToggle"){
		Range := Property.Get("Range")
		RangeMin := Range[1], RangeMax := Range[2]
		if RangeMin is not integer
			Range := GetPropertyValue(RangeMin, RangeMax, CurrentControlData), RangeMin := Range[1], RangeMax := Range[2]
		RangeMin := RangeMin = "" ? MIN_INT : RangeMin
		RangeMax := RangeMax = "" ? MAX_INT : RangeMax
		Value := GetPropertyValue(GroupName, PropertyName, CurrentControlData)
		GuiControl, , % PropertyLayout.Controls.Edit, % Type = "IntToggle" ? Value[2] : Value
		GuiControl +Range%RangeMin%-%RangeMax%, % PropertyLayout.Controls.UpDown
		
		RestrictedInputs[PropertyLayout.Controls.Edit] := RangeMin != "" and RangeMin >= 0 ? RI_INTEGER_POSITIVE : RI_INTEGER
		
		if(Type = "IntToggle"){
			CheckType := Property.Get("Default") = "" ? "+Check3" : "-Check3"
			GuiControl %CheckType%, % PropertyLayout.Controls.Checkbox
			Value := Value[1]
			CheckValue := Property.Get("Default") = "" and Value = "" ? "-1" : Value = "Yes" ? 1 : 0
			GuiControl, , % PropertyLayout.Controls.Checkbox, %CheckValue%
		}
	}
	
	else if(Type = "XY"){
		Range := Property.Get("Range")
		RangeMin := Range[1] = "" ? MIN_INT : Range[1]
		RangeMax := Range[2] = "" ? MAX_INT : Range[2]
		Value := GetPropertyValue(GroupName, PropertyName, CurrentControlData)
		GuiControl, , % PropertyLayout.Controls.EditX, % Value[1]
		GuiControl, , % PropertyLayout.Controls.EditY, % Value[2]
		GuiControl +Range%RangeMin%-%RangeMax%, % PropertyLayout.Controls.UpDownX
		GuiControl +Range%RangeMin%-%RangeMax%, % PropertyLayout.Controls.UpDownY
		
		RestrictedInputs[PropertyLayout.Controls.EditX] := RangeMin != "" and RangeMin >= 0 ? RI_INTEGER_POSITIVE : RI_INTEGER
		RestrictedInputs[PropertyLayout.Controls.EditY] := RangeMin != "" and RangeMin >= 0 ? RI_INTEGER_POSITIVE : RI_INTEGER
	}
	
	else if(Type = "Toggle"){
		CheckType := Property.Get("Default") = "" ? "+Check3" : "-Check3"
		GuiControl %CheckType%, % PropertyLayout.Controls.Checkbox
		Value := GetPropertyValue(GroupName, PropertyName, CurrentControlData)
		CheckValue := Property.Get("Default") = "" and Value = "" ? "-1" : Value = "Yes" ? 1 : 0
		GuiControl, , % PropertyLayout.Controls.Checkbox, %CheckValue%
	}
	
	else if(Type = "Text" or Type = "TextToggle" or Type = "MultiText" or Type = "Label" or Type = "Var"){
		ValueData := GetPropertyValue(GroupName, PropertyName, CurrentControlData)
		Value := Type = "TextToggle" ? ValueData[2] : ValueData
		if(Property.Get("GuiDelimiter"))
			StringReplace Value, Value, %GUI_DELIMITER%, % CurrentGui.Delimiter, 1
		GuiControl, , % PropertyLayout.Controls.Edit, %Value%
		
		if(Property.Get("Limit"))
			GuiControl % "+Limit" Property.Get("Limit"), % PropertyLayout.Controls.Edit
		else
			GuiControl -Limit, % PropertyLayout.Controls.Edit
		
		if(Type = "TextToggle"){
			CheckType := Property.Get("Default") = "" ? "+Check3" : "-Check3"
			GuiControl %CheckType%, % PropertyLayout.Controls.Checkbox
			Value := ValueData[1]
			CheckValue := Property.Get("Default") = "" and Value = "" ? "-1" : Value = "Yes" ? 1 : 0
			GuiControl, , % PropertyLayout.Controls.Checkbox, %CheckValue%
		}
	}
	
	else if(Type = "Control"){
		GuiControl, , % PropertyLayout.Controls.Label, % GetPropertyValue(GroupName, PropertyName, CurrentControlData, 1)
	}
	
	else if(Type = "List"){
		Index := Property.Get("ListIndexes")[(Value := GetPropertyValue(GroupName, PropertyName, CurrentControlData))]
		GuiControl, , % PropertyLayout.Controls.Edit, % "|" Property.Get("Options")
		if(!Property.Get("IsComboBox") or Index)
			GuiControl Choose, % PropertyLayout.Controls.Edit, %Index%
		else
			GuiControl Text, % PropertyLayout.Controls.Edit, %Value%
	}
	
	else if(Type = "Font"){
		GuiControl, , % PropertyLayout.Controls.Label, % GetPropertyValue(GroupName, PropertyName, CurrentControlData, 1)
	}
	
	else if(Type = "Date"){
		GuiControl Text, % PropertyLayout.Controls.DateTime, % Property.Get("ShowTime") ? "yyyy/MM/dd hh:mm:ss" : ""
		Date := GetPropertyValue(GroupName, PropertyName, CurrentControlData)
		if(Date = "")
			GuiControl, , % PropertyLayout.Controls.DateTime, %A_Now%
		GuiControl, , % PropertyLayout.Controls.DateTime, %Date%
	}
	
	else if(Type = "DateRange"){
		Date := GetPropertyValue(GroupName, PropertyName, CurrentControlData, "Raw")
		DateMin := SubStr(Date[1], 2)
		DateMax := SubStr(Date[2], 2)
		if(DateMin = "")
			GuiControl, , % PropertyLayout.Controls.DateTimeMin, %A_Now%
		if(DateMax = "")
			GuiControl, , % PropertyLayout.Controls.DateTimeMax, %A_Now%
		GuiControl, , % PropertyLayout.Controls.DateTimeMin, %DateMin%
		GuiControl, , % PropertyLayout.Controls.DateTimeMax, %DateMax%
	}
	
	for ControlHwnd, EventName in PropertyLayout.Events
		GuiControl +g%EventName%, % ControlHwnd
}

PropertyWinUpdateSubWinLayout(Layout){
	Gui % PropertyWinSubWin.Hwnd ":Default"
	
	PropertyLayout := PropertyWinSubWin.Layouts[PropertyWinSubWin.CurrentLayout]
	
	if(Layout != PropertyWinSubWin.Layouts.CurrentLayout){
		for Index, ControlHwnd in PropertyLayout.Controls{
			GuiControl Hide, %ControlHwnd%
			GuiControl Disable, %ControlHwnd%
		}
		
		PropertyWinSubWin.CurrentLayout := Layout
		PropertyLayout := PropertyWinSubWin.Layouts[PropertyWinSubWin.CurrentLayout]
		for Index, ControlHwnd in PropertyLayout.Controls{
			GuiControl Show, %ControlHwnd%
			GuiControl Enable, %ControlHwnd%
		}
		
		PropertyWinUpdateSubWinSize()
	}
	
	; Prevent g-labels from being called when the values are updated
	for ControlHwnd, EventName in PropertyLayout.Events
		GuiControl -g, % ControlHwnd
	
	if(Layout = "MultiText"){
		GuiControl, , % PropertyLayout.Controls.Edit, % GetPropertyValue(PropertyWinSubWin.GroupName, PropertyWinSubWin.PropertyName, CurrentControlData)
	}
	
	else if(Layout = "Options"){
		PropertyWinSubWin.Options := StrSplit(CurrentControlData.Text, GUI_DELIMITER)
		Gui % PropertyWinSubWin.Hwnd ":Default"
		Gui ListView, % PropertyWinSubWin.Options.ListView
		LV_Delete()
		for Key, Value in PropertyWinSubWin.Options
			LV_Add("", Value)
	}
	
	for ControlHwnd, EventName in PropertyLayout.Events
		GuiControl +g%EventName%, % ControlHwnd
}

PropertyWinUpdateSubWinSize(){
	Gui % PropertyWinSubWin.Hwnd ":Default"
	GetClientSize(PropertyWinSubWin.Hwnd, WinWidth, WinHeight)
	Anchors := PropertyWinSubWin.Layouts[PropertyWinSubWin.CurrentLayout].Anchors
	
	for ControlHwnd, ControlAnchors in Anchors{
		MoveCommand := ""
		
		if(ControlAnchors.L != "" and ControlAnchors.R != "")
			MoveCommand .= "x" ControlAnchors.L " w" (WinWidth - ControlAnchors.L - ControlAnchors.R) " "
		else if(ControlAnchors.L != "")
			MoveCommand .= "x" ControlAnchors.L " "
		else if(ControlAnchors.R != ""){
			GuiControlGet Control, Pos, %ControlHwnd%
			MoveCommand .= "x" (WinWidth - ControlAnchors.R - ControlW) " "
		}
		
		if(ControlAnchors.T != "" and ControlAnchors.B != "")
			MoveCommand .= "y" ControlAnchors.T " h" (WinHeight - ControlAnchors.T - ControlAnchors.B) " "
		else if(ControlAnchors.T != "")
			MoveCommand .= "y" ControlAnchors.T " "
		else if(ControlAnchors.B != ""){
			GuiControlGet Control, Pos, %ControlHwnd%
			MoveCommand .= "y" (WinHeight - ControlAnchors.B - ControlH) " "
		}
		
		GuiControl,Move, %ControlHwnd%, % MoveCommand
	}
}

; -- Events
; -----------------------------------------------------------------

PropertyWinSubroutinesDef(){
	return
	
	OnPropertyWinClose:
	return
	
	OnPropertyWinItemEdit:
		OnPropertyWinItemEdit()
	return
	
	OnPropertyWinOverlayEscape:
		OnPropertyWinOverlayEscape()
	return
	
	OnPropertyWinOverlayMouseMove:
		OnPropertyWinOverlayMouseMove()
	return
	
	OnPropertyWinOverlayFocusChange:
		OnPropertyWinOverlayFocusChange()
	return
	
	OnPropertyWinPictureLoadMenu:
		OnPropertyWinPictureLoadMenu()
	return
	
	OnPropertyWinSubWinDeactivate:
		OnPropertyWinSubWinDeactivate()
	return
	
	OnPropertyWinSubWinMultilineChange:
		OnPropertyWinSubWinMultilineChange()
	return
	
	OnPropertyWinSubWinOptionsButtonClick:
		OnPropertyWinSubWinOptionsButtonClick()
	return
	
	OnPropertyWinSubWinClose:
		OnPropertyWinSubWinClose()
	return
}

OnPropertyWinContainerWindowProc(hwnd, msg, wParam, lParam){
	Critical
	
	if(msg = WM_VSCROLL){
		ScrollWindow(hwnd, msg, wParam, lParam)
		PropertyWinClearListViewSelection()
	}
	
	if(CurrentAppAction){
		if(msg = WM_NOTIFY){
			Code := NumGet(lParam+0, A_PtrSize * 2, "Int")
			
			if(Code = LVN_ITEMCHANGED){
				NewState := NumGet(lParam+0, A_PtrSize * 3 + 8, "UInt")
				if(NewState & LVIS_SELECTED)
					PropertyWinActivateListView(hwndFrom := NumGet(lParam+0, 0, "Ptr"))
					, LV_Modify(0, "-Select -Focus")
			}
		}
		
		goto OnPropertyWinContainerWindowProc_CallWindowProc
	}
	
	if(msg = WM_NOTIFY){
		Code := NumGet(lParam+0, A_PtrSize * 2, "Int")
		
		if(Code = NM_CLICK){
			PropertyWinActiviteOverlayWindow()
		}
		
		else if(Code = LVN_ITEMCHANGED){
			NewState := NumGet(lParam+0, A_PtrSize * 3 + 8, "UInt")
			
			if(NewState & LVIS_SELECTED){
				PropertyWinGetCurrentProperty(GroupName, PropertyName, Property), PropertyClass.ControlType := CurrentControlData.ControlType
				
				if(!Property.Get("Disable") and !Property.Get("ReadOnly")){
					hwndFrom := NumGet(lParam+0, 0, "Ptr")
					iItem := NumGet(lParam+0, A_PtrSize * 3, "Int")
					PropertyWinScrollToItem(hwndFrom, iItem + 1)
					PropertyWinActiviteOverlayWindow()
					PropertyWinSelectItem(hwndFrom, iItem)
				}
				else{
					PropertyWinActivateListView(PropertyWinCurrentItem.ListView)
					LV_Modify(0, "-Select -Focus")
				}
			}
		}
		
		else if(Code = LVN_HOTTRACK){
			hwndFrom := NumGet(lParam+0, 0, "Ptr")
			
			if(!PropertyWinCurrentItem.Selected){
				iItem := NumGet(lParam+0, A_PtrSize * 3, "Int")
				PropertyWinSelectItem(hwndFrom, iItem, 1)
			}
			
			if(!PropertyWinListViews[hwndFrom].MouseOver){
				VarSetCapacity(TRACKMOUSEEVENT, 8 + A_PtrSize * 2, 0)
				NumPut(8 + A_PtrSize * 2,	TRACKMOUSEEVENT, 0, "UInt")
				NumPut(TME_LEAVE,			TRACKMOUSEEVENT, 4, "UInt")
				NumPut(hwndFrom,			TRACKMOUSEEVENT, 8, "Ptr")
				DllCall("TrackMouseEvent", Ptr, &TRACKMOUSEEVENT)
				PropertyWinListViews[hwndFrom].MouseOver := 1
			}
		}
	}
	
	OnPropertyWinContainerWindowProc_CallWindowProc:
	return DllCall("CallWindowProc", Ptr,A_EventInfo, Ptr,hwnd, UInt,msg, Ptr,wParam, Ptr,lParam)
}

OnPropertyWinItemEdit(){
	PropertyWinGetCurrentProperty(GroupName, PropertyName, Property)
	Type := Property.Get("Type")
	PropertyLayout := PropertyWinPropertyTypeLayouts[Type]
	
	if(Type = "Int" or Type = "IntToggle"){
		GuiControlGet Value, , % PropertyLayout.Controls.Edit
		ValidateIntegerValue(Value)
		
		if(Type = "Int")
			CurrentControlData[PropertyName] := Value
		else{
			CurrentControlData[PropertyName][2] := Value
			GuiControlGet Value, , % PropertyLayout.Controls.Checkbox
			CurrentControlData[PropertyName][1] := Value = -1 and Property.Get("Default") = ""
				? ""
				: Value = 1 ? "Yes" : "No"
		}
	}
	
	else if(Type = "XY"){
		GuiControlGet ValueX, , % PropertyLayout.Controls.EditX
		GuiControlGet ValueY, , % PropertyLayout.Controls.EditY
		ValidateIntegerValue(ValueX)
		ValidateIntegerValue(ValueY)
		
		if(!CurrentControlData.HasKey(PropertyName) or !IsObject(CurrentControlData[PropertyName]))
			CurrentControlData[PropertyName] := [ValueX, ValueY]
		else
			CurrentControlData[PropertyName][1] := ValueX
		  , CurrentControlData[PropertyName][2] := ValueY
	}
	
	else if(Type = "Toggle"){
		GuiControlGet Value, , % PropertyLayout.Controls.Checkbox
		CurrentControlData[PropertyName] := Value = -1 and Property.Get("Default") = ""
			? ""
			: Value = 1 ? "Yes" : "No"
	}
	
	else if(Type = "Text" or Type = "TextToggle" or Type = "MultiText"){
		GuiControlGet Value, , % PropertyLayout.Controls.Edit
		if(Property.Get("GuiDelimiter"))
			StringReplace Value, Value, % CurrentGui.Delimiter, %GUI_DELIMITER%, 1
		
		if(Type = "TextToggle"){
			CurrentControlData[PropertyName][2] := Value
			GuiControlGet Value, , % PropertyLayout.Controls.Checkbox
			CurrentControlData[PropertyName][1] := Value = -1 and Property.Get("Default") = ""
				? ""
				: Value = 1 ? "Yes" : "No"
		}
		else
			CurrentControlData[PropertyName] := Value
	}
	
	else if(Type = "Date"){
		GuiControlGet Value, , % PropertyLayout.Controls.DateTime
		CurrentControlData[PropertyName] := "d" Value ; Prepend "d" to ensure that this value is interpreted as a string
	}
	
	else if(Type = "DateRange"){
		GuiControlGet ValueMin, , % PropertyLayout.Controls.DateTimeMin
		GuiControlGet ValueMax, , % PropertyLayout.Controls.DateTimeMax
		if(ValueMin = "" and ValueMax != "" and Property.Get("AllowSingle"))
			ValueMin := ValueMax, ValueMax := ""
		
		if(!CurrentControlData.HasKey(PropertyName) or !IsObject(CurrentControlData[PropertyName]))
			CurrentControlData[PropertyName] := ["d" ValueMin, "d" ValueMax]
		else
			CurrentControlData[PropertyName][1] := "d" ValueMin ; Prepend "d" to ensure that this value is interpreted as a string
		  , CurrentControlData[PropertyName][2] := "d" ValueMax
	}
	
	else{
		GuiControlGet Value, , % PropertyLayout.Controls.Edit
		CurrentControlData[PropertyName] := Value
	}
	
	OnEditorWinPropertyEdit(GroupName, PropertyName, CurrentControlData)
}

OnPropertyWinListViewWindowProc(hwnd, msg, wParam, lParam){
	Critical
	
	if(CurrentAppAction)
		goto OnPropertyWinListViewWindowProc_CallWindowProc
	
	if(msg = WM_MOUSELEAVE){
		MouseGetPos MouseX, MouseY
		GetClientSize(PropertyWinOverlayHwnd, OverlayWidth, OverlayHeight)
		ScreenToClient(MouseX, MouseY, PropertyWinOverlayHwnd)
		
		if(MouseX < 0 or MouseY < 0 or MouseX > OverlayWidth or MouseY > OverlayHeight){
			if(!PropertyWinCurrentItem.Selected)
				PropertyWinSelectItem(0, -1)
		}
		else if(!PropertyWinCurrentItem.Selected){
			Left := Top := 0
			ClientToScreen(PropertyWinOverlayHwnd, Left, Top)
			PropertyWinCurrentItem.OverlayWin.Left		:= Left
			PropertyWinCurrentItem.OverlayWin.Top		:= Top
			PropertyWinCurrentItem.OverlayWin.Right		:= Left + OverlayWidth
			PropertyWinCurrentItem.OverlayWin.Bottom	:= Top + OverlayHeight
			SetTimer OnPropertyWinOverlayMouseMove, -0
		}
		
		PropertyWinListViews[hwnd].MouseOver := 0
	}
	
	OnPropertyWinListViewWindowProc_CallWindowProc:
	return DllCall("CallWindowProc", Ptr,A_EventInfo, Ptr,hwnd, UInt,msg, Ptr,wParam, Ptr,lParam)
}

OnPropertyWinMouseWheel(Key := ""){
	if(Key = "")
		Key := A_ThisHotkey
	
	ScrollWindow(PropertyWinContainerHwnd, WM_VSCROLL, Key = "~*WheelDown", 0)
	PropertyWinClearListViewSelection()
}

OnPropertyWinPictureLoadMenu(){
	IconPath := CurrentControlData.Text
	IconIndex := CurrentControlData.HasKey("IconIndex") ? CurrentControlData.IconIndex - 1 : 0
	SetModalMode(1)
	Update := 0
	
	if(A_ThisMenuItem = "Load from File"){
		FileSelectFile FilePath, 1, %IconPath%, Select an image file, Images (*.bmp; *.gif; *.jpg; *.jpeg; *.png; *.tiff, *.exif, *.wmf)
		
		if(!ErrorLevel){
			IconPath := FilePath
			Update := 1
			IconIndex := - 1
		}
	}
	
	else if(A_ThisMenuItem = "Load from Resource"){
		SplitPath IconPath, , IconDir, IconExt
		StringLower IconExt, IconExt
		if(IconExt = "bmp" or IconExt = "gif" or  IconExt = "jpg"  or  IconExt = "jpeg" or IconExt = "png" or IconExt = "tiff" or IconExt = "exif" or IconExt = "wmf")
			IconPath := IconDir
		if( PickIconDlg(IconPath, IconIndex, EditorWinHwnd) )
			Update := 1
	}
	
	if(Update){
		CurrentControlData.Text := IconPath
		CurrentControlData.IconIndex := IconIndex + 1
		PropertyWinUpdateCurrentProperty(1)
		OnEditorWinPropertyEdit(PropertyWinSubWin.GroupName,  PropertyWinSubWin.PropertyName, CurrentControlData)
	}
	
	SetModalMode(0)
}

OnPropertyWinOverlayControlBtnClick(){
	if(A_GuiControl = "ControlClearBtn"){
		PropertyWinGetCurrentProperty(PropertyGroup, PropertyName)
		PreviousTarget := CurrentControlData[PropertyName]
		CurrentControlData[PropertyName] := 0
		OnEditorWinPropertyEdit(PropertyGroup, PropertyName, CurrentControlData, 0, PreviousTarget)
		OnPropertyWinPropertyChange(PropertyGroup, PropertyName)
		PropertyWinUpdateOverlayWindow(0)
	}
	
	else if(A_GuiControl = "ControlSelectBtn"){
		PropertyWinActiviteOverlayWindow()
		PropertyWinSelectItem(PropertyWinCurrentItem.ListView, PropertyWinCurrentItem.ItemIndex)
		
		EditorWinStartControlTargetMode()
	}
	
	CallThreadedFunction(PropertyWinRedrawOverlayWindowFunc) ; Use CallThreadedFunction so that the other actions can first complete before the overlay window is redrawn
}

OnPropertyWinOverlayEscape(){
	PropertyWinClearListViewSelection()
	Hotkey $Esc, OnPropertyWinOverlayEscape, Off
	Hotkey $Enter, OnPropertyWinOverlayEscape, Off
}

OnPropertyWinOverlayFocusChange(){
	Action := PropertyWinCurrentItem.OverlayWin.Action
	
	if(Action = "SetFocus"){
		if(!PropertyWinCurrentItem.Selected){
			PropertyWinCurrentItem.Selected := 1
			PropertyWinCurrentItem.OverlayWin.ProcessFocusChange := 0
			PropertyWinActivateListView(PropertyWinCurrentItem.ListView)
			LV_Modify(PropertyWinCurrentItem.ItemIndex + 1, "Select")
			if(PropertyWinCurrentItem.OverlayWin.Focus)
				ControlFocus, , % "ahk_id " PropertyWinCurrentItem.OverlayWin.Focus
			PropertyWinCurrentItem.OverlayWin.ProcessFocusChange := 1
			Sleep 0
			PropertyWinRedrawOverlayWindow()
		}
	}
	else if(Action = "KillFocus"){
		PropertyWinActivateListView(PropertyWinCurrentItem.ListView)
		LV_Modify(0, "-Select")
		PropertyWinSelectItem(0, -1)
		Hotkey $Esc, OnPropertyWinOverlayEscape, Off
		Hotkey $Enter, OnPropertyWinOverlayEscape, Off
	}
	
	PropertyWinCurrentItem.OverlayWin.Action := 0
}

OnPropertyWinOverlayFontBtnClick(ButtonName := ""){
	if(ButtonName = "")
		ButtonName := A_GuiControl
	
	if(ButtonName = "FontSelectBtn"){
		ColourAsName := 0
		
		PropertyWinGetCurrentProperty(GroupName, PropertyName, Property)
		Font := GetPropertyValue(GroupName, PropertyName, CurrentControlData)
		FontName := Font.Name, FontSize := Font.Size, FontStyle := Font.Style, FontColour := (ColourProperty := Property.Get("ColourProperty")) ? CurrentControlData[ColourProperty] : 0
		
		if FontColour is not integer
			FontColour := ColourNameToRGB(FontColour)
		if(FontColour = "")
			FontColour := 0xFF000000 ; Use the alpha byte to determine whether or not another colour was selected in the font dialog
		
		SetModalMode(), Result := Dlg_Font(FontName, FontSize, FontStyle, FontColour, 1, PropertyWinHwnd), SetModalMode(0)
		if(!Result)
			return
		
		ColourName := ColourNameToRGB(FontColour, 1)
		if(ColourProperty and FontColour != 0xFF000000 and CurrentControlData[ColourProperty] != FontColour and CurrentControlData[ColourProperty] != ColourName){
			FontColour := ColourName != "" ? ColourName : FontColour
			if FontColour is integer
				CurrentControlData[ColourProperty] := FormatHex(FontColour)
			else
				CurrentControlData[ColourProperty] := FontColour
			ColourPropertyGroup := Property.Get("ColourPropertyGroup")
			OnPropertyWinPropertyChange(ColourPropertyGroup, ColourProperty)
			OnEditorWinPropertyEdit(ColourPropertyGroup, ColourProperty, CurrentControlData)
		}
		
		Font.Name := FontName, Font.Size := FontSize, Font.Style := FontStyle
		OnPropertyWinPropertyChange(GroupName, PropertyName)
		OnEditorWinPropertyEdit(GroupName, PropertyName, CurrentControlData)
	}
	
	else if(ButtonName = "FontClearBtn"){
		PropertyWinGetCurrentProperty(GroupName, PropertyName, Property)
		Font := GetPropertyValue(GroupName, PropertyName, CurrentControlData)
		Font.Name := Font.Size := Font.Style := ""
		
		PropertyWinUpdateOverlayWindow(0)
		OnPropertyWinPropertyChange(GroupName, PropertyName)
		OnEditorWinPropertyEdit(GroupName, PropertyName, CurrentControlData)
	}

	CallThreadedFunction(PropertyWinRedrawOverlayWindowFunc) ; Use CallThreadedFunction so that the other actions can first complete before the overlay window is redrawn
}

OnPropertyWinOverlayMouseMove(){
	Loop{
		MouseGetPos MouseX, MouseY
		
		if(MouseX < PropertyWinCurrentItem.OverlayWin.Left or MouseX > PropertyWinCurrentItem.OverlayWin.Right
		or MouseY < PropertyWinCurrentItem.OverlayWin.Top or MouseY > PropertyWinCurrentItem.OverlayWin.Bottom){
			if(!PropertyWinCurrentItem.Selected)
				PropertyWinSelectItem(0, -1)
			break
		}
		Sleep 33 ; 33 ms ~ 30 frames per second
	}
}

OnPropertyWinOverlayWindowProc(hwnd, msg, wParam, lParam){
	Critical
	
	if(msg = WM_LBUTTONDOWN){
		if(!PropertyWinPropertyTypeLayouts[PropertyWinPropertyTypeLayouts.CurrentLayout].DisableFocus){
			PropertyWinScrollToItem(PropertyWinCurrentItem.ListView, PropertyWinCurrentItem.ItemIndex + 1)
			PropertyWinSelectItem(PropertyWinCurrentItem.ListView, PropertyWinCurrentItem.ItemIndex)
			PropertyWinActiviteOverlayWindow()
		}
	}
	
	else if(msg = WM_NOTIFY){
		Code := NumGet(lParam+0, A_PtrSize * 2, "Int")
		HwndFrom := NumGet(lParam+0, 0, "Ptr")
		DTN_DROPDOWN	:= -754
		DTM_GETMONTHCAL	:= 0x1008
		MCM_SETMAXSELCOUNT      := 0x1004
		if(Code = NM_SETFOCUS){
			PropertyWinCurrentItem.OverlayWin.Action := "SetFocus"
			SetTimer OnPropertyWinOverlayFocusChange, -0
		}
		
		else if(Code = NM_KILLFOCUS){
			PropertyWinCurrentItem.OverlayWin.Action := "KillFocus"
			SetTimer OnPropertyWinOverlayFocusChange, -0
		}
		
		else if(Code = DTN_DROPDOWN){
			SendMessage DTM_GETMONTHCAL, 0, 0, , ahk_id %HwndFrom%
			MonthCalHwnd := ErrorLevel
			SendMessage MCM_SETMAXSELCOUNT, %MAX_INT%, 0, , ahk_id %MonthCalHwnd%
		}
	}
	
	else if(msg = WM_COMMAND){
		if(lParam != 0){
			Code := wParam >> 16 & 0xFFFF
			
			; Distinguish between different control types because CBN_DROPDOWN = BN_KILLFOCUS
			
			; - DropDownList
			if(PropertyWinPropertyTypeLayouts.NotificationTypes[lParam] = "CBN"){
				if(Code = CBN_SETFOCUS){
					PropertyWinCurrentItem.OverlayWin.Action := "SetFocus"
					SetTimer OnPropertyWinOverlayFocusChange, -0
				}
				
				else if(Code = CBN_KILLFOCUS){
					PropertyWinCurrentItem.OverlayWin.Action := "KillFocus"
					SetTimer OnPropertyWinOverlayFocusChange, -0
				}
				
				else if(Code = CBN_DROPDOWN){
					; Select the ListView row on the CBN_DROPDOWN notification because selecting it when a ComboBox drop down list is opened after this message
					; will close the drop down list for some reason
					PropertyWinActivateListView(PropertyWinCurrentItem.ListView)
					LV_Modify(PropertyWinCurrentItem.ItemIndex + 1, "Select")
				}
			}
			
			; - Any other control
			else if(Code = EN_SETFOCUS or Code = BN_SETFOCUS){
				if(!PropertyWinCurrentItem.ListView)
					DllCall("SetFocus", Ptr,0)
				
				else if(PropertyWinCurrentItem.OverlayWin.ProcessFocusChange){
					PropertyWinCurrentItem.OverlayWin.Action := "SetFocus"
					PropertyWinCurrentItem.OverlayWin.Focus  := lParam
					SetTimer OnPropertyWinOverlayFocusChange, -0 ; Use a timer to first allow any other focus messages to br processes before taking action
				}
			}
			
			else if(Code = EN_KILLFOCUS or Code = BN_KILLFOCUS){
				if(PropertyWinCurrentItem.OverlayWin.ProcessFocusChange){
					PropertyWinCurrentItem.OverlayWin.Action := "KillFocus"
					SetTimer OnPropertyWinOverlayFocusChange, -0
				}
			}
		}
	}
	
	return DllCall("CallWindowProc", Ptr,A_EventInfo, Ptr,hwnd, UInt,msg, Ptr,wParam, Ptr,lParam)
}

OnPropertyWinPropertyChange(ModifiedProperties*){
	Gui %PropertyWinContainerHwnd%:Default
	
	ControlType := CurrentControlData.ControlType
	CurrentListView := 0
	Count := ModifiedProperties.MaxIndex()
	while(Count > 0){
		GroupName := ModifiedProperties[Count - 1]
		PropertyName := ModifiedProperties[Count]
		Properties := PropertiesDef[GroupName]
		
		if(CurrentListView != Properties.ListViewHwnd){
			Gui ListView, % Properties.ListViewHwnd
			CurrentListView := Properties.ListViewHwnd
		}
		
		Property := Properties[PropertyName], PropertyClass.ControlType := ControlType
		LV_Modify(Property.ItemIndex, "Col2", GetPropertyValue(GroupName, PropertyName, CurrentControlData, 1))
		
		Count -= 2
	}
}

OnPropertyWinSubWinActivate(){
	Property := PropertiesDef[PropertyWinSubWin.GroupName][PropertyWinSubWin.PropertyName]
	PropertyClass.ControlType := PropertyWinSubWin.ControlType
	Layout := Property.Get("MultiTextLayout")
	if(Layout = "")
		Layout := Property.Get("Type")
	PropertyWinUpdateSubWinLayout(Layout)
	
	OverlayLeft := OverlayTop := 0
	ClientToScreen(PropertyWinOverlayHwnd, OverlayLeft, OverlayTop)
	Gui % PropertyWinSubWin.Hwnd ":Show", x%OverlayLeft% y%OverlayTop%
}

OnPropertyWinSubWinBtnClick(){
	static Init := 1
	
	if(Init){
		PropertyWinGetCurrentProperty(GroupName, PropertyName, Property)
		PropertyWinSubWin.ListView := PropertyWinCurrentItem.ListView
		PropertyWinSubWin.ItemIndex := PropertyWinCurrentItem.ItemIndex
		PropertyWinSubWin.PropertyName := PropertyName
		PropertyWinSubWin.GroupName := GroupName
		PropertyWinSubWin.Property := Property
		PropertyWinSubWin.ControlType := CurrentControlData.ControlType
		
		Init := 0
		return
	}
	
	Property := PropertyWinSubWin.Property, PropertyClass.ControlType := CurrentControlData.ControlType
	Action := Property.Get("MultiTextAction")
	
	if(Action = "PictureLoadMenu")
		Menu PictureLoadMenu, Show
	
	else if(Action = "ColourDialog"){
		Colour := GetPropertyValue(PropertyWinSubWin.GroupName, PropertyWinSubWin.PropertyName, CurrentControlData)
		
		if Colour is not integer
			Colour := ColourNameToRGB(Colour)
		SetModalMode(), Colour := ChooseColor(Colour, PropertyWinHwnd), SetModalMode(0)
		if(!ErrorLevel){
			Colour := ColourValueToRGBHex(Colour)
			CurrentControlData[PropertyWinSubWin.PropertyName] := Colour
			PropertyWinUpdateCurrentProperty(1)
			OnEditorWinPropertyEdit(PropertyWinSubWin.GroupName, PropertyWinSubWin.PropertyName, CurrentControlData)
		}
	}
	
	else
		OnPropertyWinSubWinActivate()
	
	Init := 1
}

OnPropertyWinSubWinClose(){
	WinHide % "ahk_id " PropertyWinSubWin.Hwnd
}

OnPropertyWinSubWinDeactivate(){
	PropertyWinUpdateCurrentProperty(1)
	
	WinHide % "ahk_id " PropertyWinSubWin.Hwnd
}

OnPropertyWinSubWinMultilineChange(){
	GuiControlGet Value, , % PropertyWinSubWin.Layouts.MultiText.Controls.Edit
	CurrentControlData[PropertyWinSubWin.PropertyName] := Value
	OnEditorWinPropertyEdit(PropertyWinSubWin.GroupName, PropertyWinSubWin.PropertyName, CurrentControlData)
}

OnPropertyWinSubWinOptionsButtonClick(){
	Gui % PropertyWinSubWin.Hwnd ":Default"
	Gui ListView, % PropertyWinSubWin.Options.ListView
	Modified := 0
	
	if(A_GuiControl = "SubWinOptionsUpBtn"){
		RowNumber := 0
		Selected := []
		Loop{
			RowNumber := LV_GetNext(RowNumber)
			if(RowNumber <= 1)
				break
			
			SwapValue := PropertyWinSubWin.Options[RowNumber - 1]
			LV_Modify(RowNumber - 1, "",  PropertyWinSubWin.Options[RowNumber - 1] := PropertyWinSubWin.Options[RowNumber])
			LV_Modify(RowNumber, "",  PropertyWinSubWin.Options[RowNumber] := SwapValue)
			Selected.Insert(RowNumber - 1)
			
			Modified := 1
		}
		
		if(Modified){
			LV_Modify(0, "-Select")
			for Index, RowNumber in Selected
				LV_Modify(RowNumber,  "Select")
		}
	}
	
	else if(A_GuiControl = "SubWinOptionsDownBtn"){
		RowNumber := 0, RowCount := LV_GetCount()
		ListViewSelection := []
		Loop{
			RowNumber := LV_GetNext(RowNumber)
			if(!RowNumber)
				break
			
			ListViewSelection.Insert(1, RowNumber)
		}
		
		Selected := []
		if(ListViewSelection[1] != RowCount)
			for Index, RowNumber in ListViewSelection{
				SwapValue := PropertyWinSubWin.Options[RowNumber + 1]
				LV_Modify(RowNumber + 1, "",  PropertyWinSubWin.Options[RowNumber + 1] := PropertyWinSubWin.Options[RowNumber])
				LV_Modify(RowNumber, "",  PropertyWinSubWin.Options[RowNumber] := SwapValue)
				Selected.Insert(RowNumber + 1)
				Modified := 1
			}
		
		if(Modified){
			LV_Modify(0, "-Select")
			for Index, RowNumber in Selected
				LV_Modify(RowNumber,  "Select")
		}
	}
	
	else if(A_GuiControl = "SubWinOptionsAddBtn"){
		PropertyDef := PropertiesDef[PropertyWinSubWin.ControlType]
		NewName := PropertyDef.HasKey("MultiTextOptionInsertText") ? PropertyDef.MultiTextOptionInsertText : "Option"
		PropertyWinSubWin.Options.Insert(NewName " " LV_GetCount() + 1)
		LV_Add("", NewName " " LV_GetCount() + 1)
		Modified := 1
	}
	
	else if(A_GuiControl = "SubWinOptionsRemoveBtn"){
		RowNumber := 0, Selected := 0
		Loop{
			RowNumber := LV_GetNext(RowNumber)
			if(!RowNumber)
				break
			if(!Selected)
				Selected := RowNumber
			PropertyWinSubWin.Options.Remove(RowNumber)
			LV_Delete(RowNumber--)
			Modified := 1
		}
		
		if(Selected){
			if(Selected > LV_GetCount())
				Selected := LV_GetCount()
			LV_Modify(Selected, "Select")
		}
	}
	
	if(Modified){
		ArrayJoin(PropertyWinSubWin.Options, OptionsString, GUI_DELIMITER)
		CurrentControlData[PropertyWinSubWin.PropertyName] := OptionsString
		OnEditorWinPropertyEdit(PropertyWinSubWin.GroupName, PropertyWinSubWin.PropertyName, CurrentControlData)
	}
}

OnPropertyWinSubWinWindowProc(hwnd, msg, wParam, lParam){
	Critical
	
	if(msg = WM_NOTIFY){
		HwndFrom := NumGet(lParam+0, 0, "Ptr")
		
		; Handle the editing here because the g-label causes problems when using a custom WindowProc
		if(HwndFrom = PropertyWinSubWin.Layouts.Options.Controls.ListView){
			Code := NumGet(lParam+0, A_PtrSize * 2, "Int")
			
			if(Code = LVN_ENDLABELEDITA or Code = LVN_ENDLABELEDITW){
				ItemIndex := NumGet(lParam+0, A_PtrSize * 2 + 12, "Int") + 1
				NewValue := NumGet(lParam+0, A_PtrSize * 3 + 24, "Ptr")
				if(NewValue)
					NewValue := StrGet(NewValue)
				
				if(NewValue and PropertyWinSubWin.Options[ItemIndex] != NewValue){
					PropertyWinSubWin.Options[ItemIndex] := NewValue
					ArrayJoin(PropertyWinSubWin.Options, OptionsString, GUI_DELIMITER)
					CurrentControlData[PropertyWinSubWin.PropertyName] := OptionsString
					OnEditorWinPropertyEdit(PropertyWinSubWin.GroupName, PropertyWinSubWin.PropertyName, CurrentControlData)
				}
			}
		}
	}
	
	else if(msg = WM_SIZE){
		PropertyWinUpdateSubWinSize()
	}
	
	else if(msg = WM_ACTIVATE){
		Type := wParam & 0xFFFF
		if(Type = WA_INACTIVE)
			SetTimer OnPropertyWinSubWinDeactivate, -0 ; Prevents interfering with other actions
	}
	
	return DllCall("CallWindowProc", Ptr,A_EventInfo, Ptr,hwnd, UInt,msg, Ptr,wParam, Ptr,lParam)
}

OnPropertyWinWindowProc(hwnd, msg, wParam, lParam){
	if(msg = WM_NOTIFY){
		HwndFrom := NumGet(lParam+0, 0, "Ptr")
		
		if(HwndFrom = PropertyWinHeaderHwnd){
			Code := NumGet(lParam+0, A_PtrSize * 2, "Int")
			
			if(Code = HDN_DIVIDERDBLCLICK || Code = HDN_BEGINTRACKA || Code = HDN_BEGINTRACKW){
				return 1
			}
		}
	}
	
	else if(msg = WM_SIZE){
		GetClientSize(PropertyWinHwnd, WinWidth, WinHeight)
		WinHeight -= PropertyWinHeaderHeight
		WinMove ahk_id %PropertyWinContainerHwnd%, , 0, %PropertyWinHeaderHeight%, %WinWidth%, %WinHeight%
		UpdateScrollBars(PropertyWinContainerHwnd, WinWidth, WinHeight)
		PropertyWinPageHeight := Floor(WinHeight / PropertyWinRowHeight)
	}
	
	return DllCall("CallWindowProc", Ptr,A_EventInfo, Ptr,hwnd, UInt,msg, Ptr,wParam, Ptr,lParam)
}