﻿;=======================================================================================
;
;                    Class Toolbar
;
; Author:            Pulover [Rodolfo U. Batista]
; AHK version:       1.1.23.01
;
;                    Class for AutoHotkey Toolbar custom controls
;=======================================================================================
;
; This class provides intuitive methods to work with Toolbar controls created via
;    Gui, Add, Custom, ClassToolbarWindow32.
;
; Note: It's recommended to call any method only after Gui, Show. Adding or modifying
;     buttons of a toolbar in a Gui that is not yet visible might fail eventually.
;
;=======================================================================================
;
; Toolbar Methods:
;    Add([Options, Label1[=Text]:Icon[(Options)], Label2[=Text]:Icon[(Options)]...])
;    AutoSize()
;    Customize()
;    Delete(Button)
;    Export()
;    Get([HotItem, TextRows, Rows, BtnWidth, BtnHeight, Style, ExStyle])
;    GetButton(Button [, ID, Text, State, Style, Icon, Label, Index])
;    GetButtonPos(Button [, OutX, OutY, OutW, OutH])
;    GetButtonState(Button, StateQuerry)
;    GetCount()
;    GetHiddenButtons()
;    Insert(Position [, Options, Label1[=Text]:Icon[(Options)], Label2[=Text]:Icon[(Options)]...])
;    LabelToIndex(Label)
;    ModifyButton(Button, State [, Set])
;    ModifyButtonInfo(Button, Property, Value)
;    MoveButton(Button, Target)
;    OnMessage(CommandID)
;    OnNotify(Param [, MenuXPos, MenuYPos, Label, ID, AllowCustom])
;    Reset()
;    SetButtonSize(W, H)
;    SetDefault([Options, Label1[=Text]:Icon[(Options)], Label2[=Text]:Icon[(Options)]...])
;    SetExStyle(Style)
;    SetHotItem(Button)
;    SetImageList(IL_Default [, IL_Hot, IL_Pressed, IL_Disabled])
;    SetIndent(Value)
;    SetListGap(Value)
;    SetMaxTextRows([MaxRows])
;    SetPadding(X, Y)
;    SetRows([Rows, AddMore])
;    ToggleStyle(Style)
;
; Presets Methods:
;    Presets.Delete(Slot)
;    Presets.Export(Slot, [ArrayOut])
;    Presets.Import(Slot, [Options, Label1[=Text]:Icon, Label2[=Text]:Icon, Label3[=Text]:Icon...])
;    Presets.Load(Slot)
;    Presets.Save(Slot, Buttons)
;
;=======================================================================================
;
; Useful Toolbar Styles:   Styles can be applied to Gui command options, e.g.:
;                              Gui, Add, Custom, ClassToolbarWindow32 0x0800 0x0100
;
; TBSTYLE_FLAT      := 0x0800 - Shows separators as bars.
; TBSTYLE_LIST      := 0x1000 - Shows buttons text on their side.
; TBSTYLE_TOOLTIPS  := 0x0100 - Shows buttons text as tooltips.
; CCS_ADJUSTABLE    := 0x0020 - Allows customization by double-click and shift-drag.
; CCS_NODIVIDER     := 0x0040 - Removes the separator line above the toolbar.
; CCS_NOPARENTALIGN := 0x0008 - Allows positioning and moving toolbars.
; CCS_NORESIZE      := 0x0004 - Allows resizing toolbars.
; CCS_VERT          := 0x0080 - Creates a vertical toolbar (add WRAP to button options).
;
;=======================================================================================
class Toolbar extends Toolbar.Private {
;=======================================================================================
;    Method:             Add
;    Description:        Add button(s) to the end the toolbar. The Buttons parameters
;                            sets target Label, text caption and icon index for each
;                            button. If not a valid label name, a function name can be
;                            used instead.
;                        To add a separator call this method without parameters.
;                        Prepend any non letter or digit symbol, such as "-" or "*"
;                            to the label to add a hidden button. Hidden buttons won't
;                            be visible when Gui is shown but will still be available
;                            in the customize window. E.g.: "-Label=New:1", "*Label:2".
;    Parameters:
;        Options:        Enter zero or more words, separated by space or tab, from the
;                            following list to set buttons' initial states and styles:
;                            Checked, Ellipses, Enabled, Hidden, Indeterminate, Marked,
;                            Pressed, Wrap, Button, Sep, Check, Group, CheckGroup,
;                            Dropdown, AutoSize, NoPrefix, ShowText, WholeDropdown.
;                        You can also set the minimum and maximum button width,
;                            for example W20-100 would set min to 20 and max to 100.
;                        This option affects all buttons in the toolbar when added or
;                            inserted but does not prevent modifying button sizes.
;                        If this parameter is blank it defaults to "Enabled", otherwise
;                            you must set this parameter to enable buttons.
;                        You may pass integer values that correspond to (a combination of)
;                            button styles. You cannot set states this way (it will always
;                            be set to "Enabled").
;        Buttons:        Buttons can be added in the following format: Label=Text:1,
;                            where "Label" is the target label to execute when the
;                            button is pressed, "Text" is caption to be displayed
;                            with the button or as a Tooltip if the toolbar has the
;                            TBSTYLE_TOOLTIPS style (this parameter can be omitted) and
;                            "1" can be any numeric value that represents the icon index
;                            in the ImageList (0 means no icon).
;                        You can include specific states and styles for a button appending
;                            them inside parenthesis after the icon. E.g.:
;                            "Label=Text:3(Enabled Dropdown)". This option can also be
;                            an Integer value, in this case the general options are
;                            ignored for that button.
;                        To add a separator between buttons specify "" or equivalent.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Add(Options := "Enabled", Buttons*) {
        If (!Buttons.Length) {
            Struct := this.BtnSep(TBBUTTON, Options)
			this.DefaultBtnInfo.Push(Struct)
            result := SendMessage(Toolbar.TB_ADDBUTTONS, 1, TBBUTTON.ptr,, "ahk_id " this.tbHwnd)
            If (!result)
                return False
        } Else If (Options = "")
            Options := "Enabled"
        For each, Button in Buttons {
            If !(this.SendMessage(Button, Options, Toolbar.TB_ADDBUTTONS, 1))
                return False
        }
        this.AutoSize()
        return true
    }
;=======================================================================================
;    Method:             AutoSize
;    Description:        Auto-sizes toolbar.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    AutoSize() {
        PostMessage Toolbar.TB_AUTOSIZE, 0, 0,, "ahk_id " this.tbHwnd ; no return value, and no more ErrorLevel... hm...
		return true
    }
;=======================================================================================
;    Method:             Customize
;    Description:        Displays the Customize Toolbar dialog box.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Customize() {
		; debug.msg("hwnd: " this.tbHwnd)
        result := SendMessage(Toolbar.TB_CUSTOMIZE, 0, 0,, "ahk_id " this.tbHwnd) ; no return value
		return true
    }
;=======================================================================================
;    Method:             Delete
;    Description:        Delete one or all buttons.
;    Parameters:
;        Button:         1-based index of the button. If omitted deletes all buttons.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Delete(Button := "") {
		result := 0
        If (!Button) {
            Loop this.GetCount()
                this.Delete(1)
        } Else
            result := SendMessage(Toolbar.TB_DELETEBUTTON, Button-1, 0,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             Export()
;    Description:        Returns a text string with current buttons and order in Add and
;                            Insert methods compatible format (this includes button's
;                            styles but not states). Duplicate labels are ignored.
;    Parameters:
;        ArrayOut:       Set to TRUE to return an object array. The returned object
;                            format is compatible with Presets.Save and Presets.Load
;                            methods, which can be used to save and load layout presets.
;    HidMark:            Changes the default symbol to prepend to hidden buttons.
;    Return:             A text string with current buttons information to be exported.
;=======================================================================================
    Export(ArrayOut := False, HidMark := "-") {
        BtnArray := [], IncLabels := ":", BtnString := ""
		
		; Debug.Msg("BtnCount: " this.GetCount())
        Loop this.GetCount() {
            this.GetButton(A_Index, ID:=0, Text:="", State:=0, Style:=0, Icon:=0)
            Label := this.Labels.Has(String(ID)) ? this.Labels[String(ID)] : ""
			IncLabels .= Label ":"
            cString := (Label ? (Label (Text ? "=" Text : "") ":" Icon (Style ? "(" Style ")" : "")) : "") ", "
            BtnString .= cString
			
            If (ArrayOut)
                BtnArray.Push(Map("Icon",Icon-1, "ID",ID, "State",State, "Style",Style, "Text",Text, "Label",Label))
        }
		
		; Debug.Msg(BtnString)
		
        For i, Button in this.DefaultBtnInfo {
			curKey := this.Labels.Has(String(Button["ID"])) ? this.Labels[String(Button["ID"])] : ""
			Label := ""
            If (!Label)
                continue

            If (!InStr(IncLabels, ":" (Label := this.Labels[String(Button["ID"])]) ":")) {
                oString := Label (Button["Text"] ? "=" Button["Text"] : "")
                        .    ":" Button["Icon"]+1 (Button["Style"] ? "(" Button["Style"] ")" : "")
                BtnString .= HidMark oString ", "
            }
        }
		
		; Debug.Msg("#2:     " BtnString)
		
        return ArrayOut ? BtnArray : RTrim(BtnString, ", ")
    }
;=======================================================================================
;    Method:             Get
;    Description:        Retrieves information from the toolbar.
;    Parameters:
;        HotItem:        OutputVar to store the 1-based index of current HotItem.
;        TextRows:       OutputVar to store the number of text rows
;        Rows:           OutputVar to store the number of rows for vertical toolbars.
;        BtnWidth:       OutputVar to store the buttons' width in pixels.
;        BtnHeight:      OutputVar to store the buttons' heigth in pixels.
;        Style:          OutputVar to store the current styles numeric value.
;        ExStyle:        OutputVar to store the current extended styles numeric value.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Get(ByRef HotItem := "", ByRef TextRows := "", ByRef Rows := ""
       ,ByRef BtnWidth := "", ByRef BtnHeight := "", ByRef Style := "", ByRef ExStyle := "") {
        result := SendMessage(Toolbar.TB_GETHOTITEM, 0, 0,, "ahk_id " this.tbHwnd)
            HotItem := (result = 4294967295) ? 0 : result+1
        result := SendMessage(Toolbar.TB_GETTEXTROWS, 0, 0,, "ahk_id " this.tbHwnd)
            TextRows := result
        result := SendMessage(Toolbar.TB_GETROWS, 0, 0,, "ahk_id " this.tbHwnd)
            Rows := result
        result := SendMessage(Toolbar.TB_GETBUTTONSIZE, 0, 0,, "ahk_id " this.tbHwnd)
            this.MakeShort(result, BtnWidth, BtnHeight)
        result := SendMessage(Toolbar.TB_GETSTYLE, 0, 0,, "ahk_id " this.tbHwnd)
            Style := result
        result := SendMessage(Toolbar.TB_GETEXTENDEDSTYLE, 0, 0,, "ahk_id " this.tbHwnd) ; returns DWORD ... hm
            ExStyle := result
        return (!result) ? False : true
    }
;=======================================================================================
;    Method:             GetButton
;    Description:        Retrieves information from the toolbar buttons.
;    Parameters:
;        Button:         1-based index of the button.
;        ID:             OutputVar to store the button's command ID.
;        Text:           OutputVar to store the button's text caption.
;        State:          OutputVar to store the button's state numeric value.
;        Style:          OutputVar to store the button's style numeric value.
;        Icon:           OutputVar to store the button's icon index.
;        Label:          OutputVar to store the button's associated script label or function.
;        Index:          OutputVar to store the button's text string index.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    GetButton(Button, ByRef ID := "", ByRef Text := "", ByRef State := "", ByRef Style := ""
             ,ByRef Icon := "", ByRef Label := "", ByRef Index := "") {
		
        BtnVar := BufferAlloc(8 + (A_PtrSize * 3), 0)
        result := SendMessage(Toolbar.TB_GETBUTTON, Button-1, BtnVar.ptr,, "ahk_id " this.tbHwnd)
		
		; Debug.Msg("get btn result: " result)
		
        ID := NumGet(BtnVar.ptr, 4, "Int"), Icon := NumGet(BtnVar.ptr, 0, "Int")+1
       ,State := NumGet(BtnVar.ptr, 8, "Char"), Style := NumGet(BtnVar.ptr, 9, "Char")
       ,Index := NumGet(BtnVar.ptr, 8 + (A_PtrSize * 2), "Int")
	   
		; Debug.Msg("ID: " ID " / Icon: " Icon " / State: " State " / Style: " Style " / Index: " Index) ; ???
	   
	    Label := this.Labels.Has(String(ID)) ? this.Labels[String(ID)] : ""
		
		If (ID) {
			result := SendMessage(Toolbar.TB_GETBUTTONTEXT, ID, 0,, "ahk_id " this.tbHwnd)
			If (result = -1)
				return false
			
		    Buffer := BufferAlloc(result * 2, 0)
            result := SendMessage(Toolbar.TB_GETBUTTONTEXT, ID, Buffer.ptr,, "ahk_id " this.tbHwnd)
			Text := StrGet(Buffer.ptr,"UTF-16")
		} Else
			result := 1 ; it's a separator?
			
		; Debug.Msg("invalid? :    " result)

        
        return (result = -1) ? False : true
        ; Alternative way to retrieve the button state.
        ; SendMessage, this.TB_GETSTATE, ID, 0,, % "ahk_id " this.tbHwnd
        ; State := ErrorLevel
    }
;=======================================================================================
;    Method:             GetButtonPos
;    Description:        Retrieves position and size of a specific button, relative to
;                            the toolbar control.
;    Parameters:
;        Button:         1-based index of the button.
;        OutX:           OutputVar to store the button's horizontal position.
;        OutY:           OutputVar to store the button's vertical position.
;        OutW:           OutputVar to store the button's width.
;        OutH:           OutputVar to store the button's height.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    GetButtonPos(Button, ByRef OutX := "", ByRef OutY := "", ByRef OutW := "", ByRef OutH := "") {
        this.GetButton(Button, BtnID), RECT := BufferAlloc(16, 0)
        result := SendMessage(Toolbar.TB_GETRECT, BtnID, RECT.ptr,, "ahk_id " this.tbHwnd)
        OutX := NumGet(RECT.ptr, 0, "Int"), OutY := NumGet(RECT.ptr, 4, "Int")
    ,   OutW := NumGet(RECT.ptr, 8, "Int") - OutX, OutH := NumGet(RECT.ptr, 12, "Int") - OutY
        return (!result) ? False : true
    }
;=======================================================================================
;    Method:             GetButtonState
;    Description:        Retrieves the state of a button based on a querry.
;    Parameters:
;        StateQuerry:    Enter one of the following words to get the state of the button:
;                            Checked, Enabled, Hidden, Highlighted, Indeterminate, Pressed.
;    Return:             The TRUE if the StateQuerry is true, FALSE if it's not.
;=======================================================================================
    GetButtonState(Button, StateQuerry) {
        this.GetButton(Button, BtnID)
        If (this.HasProp("TB_ISBUTTON" StateQuerry) )
            Msg := this.TB_ISBUTTON%StateQuerry%
        result := SendMessage(Msg, BtnID, 0,, "ahk_id " this.tbHwnd)
        return result ? true : False
    }
;=======================================================================================
;    Method:             GetCount
;    Description:        Retrieves the total number of buttons.
;    Return:             The total number of buttons in the toolbar.
;=======================================================================================
    GetCount() {
        result := SendMessage(Toolbar.TB_BUTTONCOUNT, 0, 0,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             GetHiddenButtons
;    Description:        Retrieves which buttons are hidden when the toolbar size is 
;                            smaller then the total size of the buttons it has.
;                        This method is most useful when the toolbar is a child window of
;                            a Rebar control, in order to show a menu when the chevron is
;                            pushed. It does not retrieve buttons hidden by gui size.
;    Return:             An array with all buttons hidden by the Rebar band. Each key
;                            in the array has 4 properties: ID, Text, Label and Icon.
;=======================================================================================
    GetHiddenButtons() {
        ControlGetPos x,y, tbWidth,,, "ahk_id " this.tbHwnd
        RECT := BufferAlloc(16, 0), HiddenButtons := []
        Loop this.GetCount()
        {
            result := SendMessage(Toolbar.TB_GETITEMRECT, A_Index-1, RECT.ptr,, "ahk_id " this.tbHwnd)
            If (NumGet(RECT.ptr, 8, "Int") > tbWidth)
                this.GetButton(A_Index, ID, Text, "", "", Icon)
            ,   HiddenButtons.Push(Map("ID",ID, "Text",Text, "Label",this.Labels[String(ID)], "Icon",Icon))
        }
        return HiddenButtons
    }
;=======================================================================================
;    Method:             Insert
;    Description:        Insert button(s) in specified postion.
;                        To insert a separator call this method without parameters.
;    Parameters:
;        Position:       1-based index of button position to insert the new buttons.
;        Options:        Same as Add().
;        Buttons:        Same as Add().
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Insert(Position, Options := "Enabled", Buttons*) {
        If (!Buttons.Length) {
            this.BtnSep(TBBUTTON, Options)
            result := SendMessage(Toolbar.TB_INSERTBUTTON, Position-1, TBBUTTON.ptr,, "ahk_id " this.tbHwnd)
            If (!result)
                return False
        } Else If (Options = "")
            Options := "Enabled"
		
        For i, Button in Buttons {
            If !(this.SendMessage(Button, Options, Toolbar.TB_INSERTBUTTON, (Position-1)+(i-1)))
                return False
        }
        return true
    }
;=======================================================================================
;    Method:             LabelToIndex
;    Description:        Converts a button label to its index in a toolbar.
;    Parameters:
;        Label:          Button's associated label or function.
;    Return:             The 1-based index for the button or FALSE if Label is invalid.
;=======================================================================================
    LabelToIndex(Label) {
        For ID, L in this.Labels {
            If (L = Label) {
                result := SendMessage(Toolbar.TB_COMMANDTOINDEX, ID, 0,, "ahk_id " this.tbHwnd)
                return result+1
            }
        }
        return False
    }
;=======================================================================================
;    Method:             ModifyButton
;    Description:        Sets button states.
;    Parameters:
;        Button:         1-based index of the button.
;        State:          Enter one word from the follwing list to change a button's
;                            state: Check, Enable, Hide, Mark, Press.
;        Set:            Enter TRUE or FALSE to set the state on/off.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    ModifyButton(Button, State, Set := true) {
		checkThese := ["CHECK","ENABLE","HIDE","MARK","PRESS"], cont := false
		For i, val in checkThese
			If State = val
				cont := true
		If (!cont)
			return false
		
        ; If State not in CHECK,ENABLE,HIDE,MARK,PRESS
            ; return False
			
        Message := Toolbar.TB_%State%BUTTON
    ,   this.GetButton(Button, BtnID)
        result := SendMessage(Message, BtnID, Set,, "ahk_id " this.tbHwnd)
        return (!result) ? False : true
    }
;=======================================================================================
;    Method:             ModifyButtonInfo
;    Description:        Sets button parameters such as Icon and CommandID.
;    Parameters:
;        Button:         1-based index of the button.
;        Property:       Enter one word from the following list to select the Property
;                            to be set: Command, Image, Size, State, Style, Text, Label.
;        Value:          The value to be set in the selected Property.
;                            If Property is State or Style you can enter named values as
;                            in the Add options.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    ModifyButtonInfo(Button, Property, Value) {
        If (Property = "Label") {
            this.GetButton(Button, ID), this.Labels[String(ID)] := Value
            return true
        }
        If (Property = "State") || (Property = "Style") {
            If (Type(Value) = "Integer")
                Value := Value
            Else {
                Loop Parse, Value, A_Space A_Tab
                {
                    If (Toolbar.HasProp( "TBSTATE_" A_LoopField ))
                        tbState += Toolbar.TBSTATE_%A_LoopField%
                    Else If (Toolbar.HasProp( "BTNS_" A_LoopField ) )
                        tbStyle += Toolbar.BTNS_%A_LoopField%
                }
                Value := tb%Property%
            }
        }
        If (Property = "Command")
            this.GetButton(Button, "", "", "", "", "", Label), this.Labels[String(Value)] := Label
        this.DefineBtnInfoStruct(TBBUTTONINFO, Property, Value)
    ,   this.GetButton(Button, BtnID)
        result := SendMessage(Toolbar.TB_SETBUTTONINFO, BtnID, TBBUTTONINFO.ptr,, "ahk_id " this.tbHwnd)
        return (!result) ? False : true
    }
;=======================================================================================
;    Method:             MoveButton
;    Description:        Moves a toolbar button (change order).
;    Parameters:
;        Button:         1-based index of the button to be moved.
;        Target:         1-based index of the new position.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    MoveButton(Button, Target) {
        result := SendMessage(Toolbar.TB_MOVEBUTTON, Button-1, Target-1,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             OnMessage
;    Description:        Run label associated with button's Command identifier.
;                        This method should be called from a function monitoring the
;                            WM_COMMAND message. Pass the wParam as the CommandID.
;    Parameters:
;        CommandID:      Command ID associated with the button. This is send via
;                            WM_COMMAND message, you must pass the wParam from
;                            inside a function that monitors this message.
;        FuncParams:     In case the button is associated with a valid function,
;                            you may pass optional parameters for the function call.
;                            You can pass any number of parameters.
;    Return:             TRUE if target label or function exists, or FALSE otherwise.
;=======================================================================================
    OnMessage(CommandID, FuncParams*) {
		strID := String(CommandID)
        ; If (IsLabel(this.Labels[strID])) {
            ; GoSub(this.Labels[strID])
            ; return true
        ; } Else 
		If (!this.Labels.Has(strID))
			return false
		
		If (IsFunc(this.Labels[strID])) {
			BtnFunc := this.Labels[strID]
		,	%BtnFunc%(FuncParams*)
			return true
		} Else
            return False
    }
;=======================================================================================
;    Method:             OnNotify
;    Description:        Handles toolbar notifications.
;                        This method should be called from a function monitoring the
;                            WM_NOTIFY message. Pass the lParam as the Param.
;                            The returned value should be used as return value for
;                            the monitoring function as well.
;    Parameters:
;        Param:          The lParam from WM_NOTIFY message.
;        MenuXPos:       OutputVar to store the horizontal position for a menu.
;        MenuYPos:       OutputVar to store the vertical position for a menu.
;        BtnLabel:       OutputVar to store the label or function name associated with the button.
;        ID:             OutputVar to store the button's Command ID.
;        AllowCustom:    Set to FALSE to prevent customization of toolbars.
;        AllowReset:     Set to FALSE to prevent Reset button from restoring original buttons.
;        HideHelp:       Set to FALSE to show the Help button in the customize dialog.
;    Return:             The required return value for the function monitoring
;                            the the WM_NOTIFY message.
;=======================================================================================
    OnNotify(ByRef Param, ByRef MenuXPos := "", ByRef MenuYPos := "", ByRef BtnLabel := "", ByRef ID := ""
    ,   AllowCustom := true, AllowReset := true, HideHelp := true) {
        
		nCode  := NumGet(Param + (A_PtrSize * 2), 0, "Int")
		tbHwnd := NumGet(Param + 0, 0, "UPtr")
		Index := 0
		
        If (tbHwnd != this.tbHwnd)
            return ""
        If (nCode = Toolbar.TBN_DROPDOWN)
        {
            ID  := NumGet(Param + (A_PtrSize * 3), 0, "Int"), BtnLabel := this.Labels[String(ID)]
        ,   RECT := Bufferalloc(16, 0)
            result := SendMessage(Toolbar.TB_GETRECT, ID, RECT.ptr,, "ahk_id " this.tbHwnd)
            ControlGetPos TBX, TBY,,,, "ahk_id " this.tbHwnd
            MenuXPos := TBX + NumGet(RECT.ptr, 0, "Int"), MenuYPos := TBY + NumGet(RECT.ptr, 12, "Int")
            return False
        } Else
            BtnLabel := "", ID := ""
        If (nCode = Toolbar.TBN_QUERYINSERT)
            return AllowCustom
        If (nCode = Toolbar.TBN_QUERYDELETE)
            return AllowCustom
        If (nCode = Toolbar.TBN_GETBUTTONINFO) {
            iItem := NumGet(Param + (A_PtrSize * 3), 0, "Int")
            If (iItem = this.DefaultBtnInfo.Length)
                return False
			
            For each, Member in this.DefaultBtnInfo[iItem+1] ; {Icon: -1, ID: "", State: "", Style: Style, Text: "", Label: ""}
                %each% := Member
            If (IsSet(Text) And Text != "") { ; orig >>> Text != ""
				bufSize := StrPut(Text,"UTF-16")
                BTNSTR := BufferAlloc(bufSize, 0) ; was x 2
            ,   StrPut(Text, BTNSTR, "UTF-16") ; was specifying length
                result := SendMessage(Toolbar.TB_ADDSTRING, 0, BTNSTR.ptr,, "ahk_id " this.tbHwnd)
                Index := result, this.DefaultBtnInfo[iItem+1]["Index"] := Index
            ,   this.DefaultBtnInfo[iItem+1]["Text"] := Text
            }
			
			If (!ID)
				ID := 0
			If (!Index)
				Index := 0
				
			Debug.Msg(Icon " / " ID " / " State " / " Style " / " param " / " Index " / " 8 + (A_PtrSize * 2) " / " Param + (A_PtrSize * 4))
			
			NumPut "Int", Icon, "Int", ID, "Char", State, "Char", Style, Param + (A_PtrSize * 4)
			NumPut "Ptr", Index, Param + (A_PtrSize * 4), 8 + (A_PtrSize * 2) ; orig 8 +...
			
            ; NumPut(Icon, Param + (A_PtrSize * 4), 0, "Int") ; iBitmap
        ; ,   NumPut(ID, Param + (A_PtrSize * 4), 4, "Int") ; idCommand
        ; ,   NumPut(State, Param + (A_PtrSize * 4), 8, "Char") ; tbState
        ; ,   NumPut(Style, Param + (A_PtrSize * 4), 9, "Char") ; tbStyle
        ; ,   NumPut(Index, Param + (A_PtrSize * 4), 8 + (A_PtrSize * 2), "Int") ; iString
            return true
        }
        If (nCode = Toolbar.TBN_TOOLBARCHANGE) {
            CurrentButtons := this.Export(true)
            this.pLoad(CurrentButtons) ; this.Presets.Load(CurrentButtons) 
            CurrentButtons := ""
        }
        If (nCode = Toolbar.TBN_RESET) {
            If (AllowReset) {
                this.Reset()
                return 2
            }
        }
        If (nCode = Toolbar.TBN_INITCUSTOMIZE)
            return HideHelp
        return ""
    }
;=======================================================================================
;    Method:             Reset
;    Description:        Restores all toolbar's buttons to default layout.
;                        Default layout is set by the buttons added. This can be changed
;                            calling the SetDefault method.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    Reset() {
        BtnsArray := IsSet(CustomArray) ? CustomArray : this.DefaultBtnInfo ; was IsObject()
    ,   this.Get("", "", Rows)
        Loop this.GetCount()
            this.Delete(1)
        For each, Button in BtnsArray {
            For each, Member in Button
                %each% := Member
            If ((Rows > 1) && (Style = this.BTNS_SEP))
                State := 0x24
            If (IsSet(Text) And Text != "") {
				bufSize := StrPut(Text,"UTF-16")
                BTNSTR := BufferAlloc(bufSize, 0)
            ,   StrPut(Text, BTNSTR.ptr, "UTF-16")
                result := SendMessage(Toolbar.TB_ADDSTRING, 0, BTNSTR.ptr,, "ahk_id " this.tbHwnd)
                Index := result
            }
            TBBUTTON := BufferAlloc(8 + (A_PtrSize * 3), 0)
			NumPut "Int", Icon, "Int", ID, "Char", State, "Char", Style, TBBUTTON
			NumPut "Int", Index, TBBUTTON, 8 + (A_PtrSize * 2)
			
			
        ; ,   NumPut(Icon, TBBUTTON, 0, "Int")
        ; ,   NumPut(ID, TBBUTTON, 4, "Int")
        ; ,   NumPut(State, TBBUTTON, 8, "Char")
        ; ,   NumPut(Style, TBBUTTON, 9, "Char")
        ; ,   NumPut(Index, TBBUTTON, 8 + (A_PtrSize * 2), "Int")
            result := SendMessage(Toolbar.TB_ADDBUTTONS, 1, TBBUTTON,, "ahk_id " this.tbHwnd)
        }
        return result
    }
;=======================================================================================
;    Method:             SetButtonSize
;    Description:        Sets the size of buttons on a toolbar. Affects current buttons.
;    Parameters:
;        W:              Width of buttons, in pixels
;        H:              Height of buttons, in pixels
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetButtonSize(W, H) {
        Long := this.MakeLong(W, H)
        result := SendMessage(Toolbar.TB_SETBUTTONSIZE, 0, Long,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             SetDefault
;    Description:        Sets the internal default layout to be used when customizing or
;                        when the Reset method is called.
;    Parameters:
;        Options:        Same as Add().
;        Buttons:        Same as Add().
;    Return:             Always TRUE.
;=======================================================================================
    SetDefault(Options := "Enabled", Buttons*) {
        this.DefaultBtnInfo := []
        If (!Buttons.Length)
            this.DefaultBtnInfo.Push(Map("Icon",-1, "ID","", "State","", "Style",Toolbar.BTNS_SEP, "Text","", "Label",""))
        If (Options = "")
            Options := "Enabled"
        For each, Button in Buttons
            this.SendMessage(Button, Options)
        return true
    }
;=======================================================================================
;    Method:             SetExStyle
;    Description:        Sets toolbar's extended style.
;    Parameters:
;        Style:          Enter one or more words, separated by space or tab, from the
;                            following list to set toolbar's extended styles:
;                            Doublebuffer, DrawDDArrows, HideClippedButtons,
;                            MixedButtons.
;                        You may also enter an integer value to define the style.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetExStyle(Style) {
		tbStyle_Ex_ := 0
        If (IsInteger(Style))
            tbStyle_Ex_ := Style
        Else {
            Loop Parse, Style, A_Space A_Tab
			{
                If (Toolbar.HasProp("TBSTYLE_EX_" A_LoopField) )
                    tbStyle_Ex_ += (Toolbar.TBSTYLE_EX_%A_LoopField%)
            }
        }
        result := SendMessage(Toolbar.TB_SETEXTENDEDSTYLE, 0, tbStyle_Ex_,, "ahk_id " this.tbHwnd)
    }
;=======================================================================================
;    Method:             SetHotItem
;    Description:        Sets the hot item on a toolbar.
;    Parameters:
;        Button:         1-based index of the button.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetHotItem(Button) {
        result := SendMessage(Toolbar.TB_SETHOTITEM, Button-1, 0,, "ahk_id " this.tbHwnd)
        return (result = -1) ? False : true
    }
;=======================================================================================
;    Method:             SetImageList
;    Description:        Sets an ImageList to the toolbar control.
;    Parameters:
;        IL_Default:     ImageList ID of default ImageList.
;        IL_Hot:         ImageList ID of Hot ImageList.
;        IL_Pressed:     ImageList ID of Pressed ImageList.
;        IL_Disabled:    ImageList ID of Disabled ImageList.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetImageList(IL_Default, IL_Hot := "", IL_Pressed := "", IL_Disabled := "") {
        result := SendMessage(Toolbar.TB_SETIMAGELIST, 0, IL_Default,, "ahk_id " this.tbHwnd)
        If (IL_Hot)
            result := SendMessage(Toolbar.TB_SETHOTIMAGELIST, 0, IL_Hot,, "ahk_id " this.tbHwnd)
        If (IL_Pressed)
            result := SendMessage(Toolbar.TB_SETPRESSEDIMAGELIST, 0, IL_Pressed,, "ahk_id " this.tbHwnd)
        If (IL_Disabled)
            result := SendMessage(Toolbar.TB_SETDISABLEDIMAGELIST, 0, IL_Disabled,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             SetIndent
;    Description:        Sets the indentation for the first button on a toolbar.
;    Parameters:
;        Value:          Value specifying the indentation, in pixels.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetIndent(Value) {
        result := SendMessage(Toolbar.TB_SETINDENT, Value, 0,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             SetListGap
;    Description:        Sets the distance between icons and text on a toolbar.
;    Parameters:
;        Value:          The gap, in pixels, between buttons on the toolbar.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetListGap(Value) {
        result := SendMessage(Toolbar.TB_SETLISTGAP, Value, 0,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             SetMaxTextRows
;    Description:        Sets maximum number of text rows for button captions.
;    Parameters:
;        MaxRows:        Maximum number of text rows. If omitted defaults to 0.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetMaxTextRows(MaxRows := 0) {
        result := SendMessage(Toolbar.TB_SETMAXTEXTROWS, MaxRows, 0,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             SetPadding
;    Description:        Sets the padding for icons a toolbar. 
;    Parameters:
;        X:              Horizontal padding, in pixels
;        Y:              Vertical padding, in pixels
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetPadding(X, Y) {
        Long := this.MakeLong(X, Y)
        result := SendMessage(Toolbar.TB_SETPADDING, 0, Long,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             SetRows
;    Description:        Sets the number of rows for a toolbar.
;    Parameters:
;        Rows:           Number of rows to set. If omitted defaults to 0.
;        AddMore:        Indicates whether to create more rows than requested when the
;                            system cannot create the number of rows specified.
;                            If TRUE, the system creates more rows. If FALSE, the system
;                            creates fewer rows.
;    Return:             TRUE if successful, FALSE if there was a problem.
;=======================================================================================
    SetRows(Rows := 0, AddMore := False) {
        Long := this.MakeLong(Rows, AddMore)
        result := SendMessage(Toolbar.TB_SETROWS, Long,,, "ahk_id " this.tbHwnd)
        return result
    }
;=======================================================================================
;    Method:             ToggleStyle
;    Description:        Toggles toolbar's style.
;    Parameters:
;        Style:          Enter zero or more words, separated by space or tab, from the
;                            following list to toggle toolbar's styles:
;                            AltDrag, CustomErase, Flat, List, RegisterDrop, Tooltips,
;                            Transparent, Wrapable, Adjustable, Border, ThickFrame,
;                            TabStop.
;                        You may also enter an integer value to define the style.
;    Return:             TRUE if a valid style is passed, or FALSE otherwise.
;=======================================================================================
    ToggleStyle(Style) {
		Style := 0
        If IsInteger(Style)
            tbStyle := Style
        Else {
            Loop Parse, Style, A_Space A_Tab
            {
                If (Toolbar.HasProp("TBSTYLE_" A_LoopField) )
                    tbStyle += Toolbar.TBSTYLE_%A_LoopField%
            }
        }
        ; TB_SETSTYLE moves the toolbar away from its position for some reason.
        ; SendMessage, this.TB_SETSTYLE, 0, tbStyle,, % "ahk_id " this.tbHwnd
        If (tbStyle != "") {
            WinSetStyle "^" tbStyle, "ahk_id " this.tbHwnd
            return true
        }
        Else
            return False
    }
;=======================================================================================
;    Presets Methods     These methods are used exclusively by the Presets Object.
;                        Presets can be used to quickly change buttons of a toolbar
;                            to predetermined or saved layouts.
;=======================================================================================
    Class tbPresets extends Toolbar.Private { ; Toolbar.Private
;=======================================================================================
;    Method:             Presets.Delete
;    Description:        Deletes the layout of the specified slot. 
;    Parameters:
;        Slot:           Number of the slot containing the layout to be deleted.
;    Return:             TRUE if the slot contains a layout, or FALSE otherwise.
;=======================================================================================
		pDelete(Slot) {
			If !this.Slots.Has(Slot)
				return false
			Else If (IsObject(this.Slots[Slot])) {
				this.Slots.Delete(Slot)
				return true
			} Else
				return False
		}
	;=======================================================================================
	;    Method:             Presets.Export
	;    Description:        Returns a text string with buttons and order in Add and
	;                            Insert methods compatible format from the specified slot.
	;    Parameters:
	;        Slot:           Number of the slot in which to save the layout.
	;        ArrayOut:       Set to TRUE to return an object array. The returned object
	;                            format is compatible with Presets.Save and Presets.Load
	;                            methods, which can be used to save and load layout presets.
	;    Return:             A text string with buttons information to be exported.
	;=======================================================================================
		pExport(Slot, ArrayOut := False) {
			BtnArray := [], BtnString := ""
			
			If this.Slots.has(Slot) {
				For i, Button in this.Slots[Slot] {
					For each, Member in Button
						%each% := Member
					BtnString .= (Label ? (Label (Text ? "=" Text : "")
							.    ":" Icon+1 (Style ? "(" Style ")" : "")) : "") ", "
					If (ArrayOut)
						BtnArray.Push(Map("Icon",Icon, "ID",ID, "State",State, "Style",Style, "Text",Text, "Label",Label))
				}
			}
			return ArrayOut ? BtnArray : RTrim(BtnString, ", ")
		}
	;=======================================================================================
	;    Method:             Presets.Import
	;    Description:        Imports a buttons layout from a string in Add/Insert methods
	;                            format and saves it into the specified slot.
	;    Parameters:
	;        Slot:           Number of the slot in which to save the layout.
	;        Options:        Same as Add().
	;        Buttons:        Same as Add().
	;    Return:             Always TRUE.
	;=======================================================================================
		pImport(Slot, Options := "Enabled", Buttons*) {
			BtnArray := []
			If (Options = "")
				Options := "Enabled"
			For each, Button in Buttons {
				If (RegExMatch(Button, "^(\W?)(\w+)[=\s]?(.*)?:(\d+)\(?(.*?)?\)?$", Key)) { ;  And Trim(Button) != ""
					If (Key.Value(1))
						continue
					idCommand := this.StringToNumber(Key.Value(2))
					iString := Key.Value(3), iBitmap := Key.Value(4)
					
					; Debug.Msg(this.Labels[String(idCommand)])
					
					Struct := this.DefineBtnStruct(TBBUTTON, iBitmap, idCommand, iString, Key.Value(5) ? Key.Value(5) : Options)
					Struct.Label := Key.Value(2), BtnArray.Push(Struct)
				}
				Else
					Struct := this.BtnSep(TBBUTTON, Options), BtnArray.Push(Struct)
			}
			this.Slots[Slot] := BtnArray
			return true
		}
	;=======================================================================================
	;    Method:             Presets.Load
	;    Description:        Loads a layout from the specified slot.
	;    Parameters:
	;        Slot:           Number of the slot containing the layout to be loaded.
	;                        For convenience and internal operations this parameter can be an
	;                            object in the same format of Presets.Save Buttons parameter.
	;    Return:             TRUE if the slot contains a layout, or FALSE otherwise.
	;=======================================================================================
		pLoad(Slot) {
			Index := 0
			If (IsObject(Slot))
				Buttons := Slot
			Else
				Buttons := this.Slots[Slot]
			If (!IsObject(Buttons))
				return False
			result := SendMessage(Toolbar.TB_GETROWS, 0, 0,, "ahk_id " this.tbHwnd)
				Rows := result
			result := SendMessage(Toolbar.TB_BUTTONCOUNT, 0, 0,, "ahk_id " this.tbHwnd)
			Loop result
				result := SendMessage(Toolbar.TB_DELETEBUTTON, 0, 0,, "ahk_id " this.tbHwnd)
			For each, Button in Buttons {
				For each, Member in Button
					%each% := Member
				
				; Debug.Msg("Parsing: " Style)
				
				If ((Rows > 1) && (Style = Toolbar.BTNS_SEP))
					State := 0x24
				If (IsSet(Text) And Trim(Text) != "") {
					BTNSTR := BufferAlloc(StrPut(Text,"UTF-16"), 0)
					StrPut(Text, BTNSTR.ptr, "UTF-16")
					result := SendMessage(Toolbar.TB_ADDSTRING, 0, BTNSTR.ptr,, "ahk_id " this.tbHwnd)
					Index := result
				}
				TBBUTTON := BufferAlloc(8 + (A_PtrSize * 3), 0)
				
				If (!ID)
					ID := 0
				If (!Index)
					Index := 0
				
				; Debug.Msg(Icon " / " ID " / " State " / " Style " / " Text)
				
				NumPut "Int", Icon, "Int", ID, "Char", State, "Char", Style, TBBUTTON
				NumPut "Int", Index, TBBUTTON, 8 + (A_PtrSize * 2)
				
				result := SendMessage(Toolbar.TB_ADDBUTTONS, 1, TBBUTTON.ptr,, "ahk_id " this.tbHwnd)
			}
			return result
		}
	;=======================================================================================
	;    Method:             Presets.Save
	;    Description:        Saves a buttons layout as a preset into the specified slot. 
	;    Parameters:
	;        Slot:           Number of the slot in which to save the layout. There is no
	;                            predefined limit of slots.
	;        Buttons:        Buttons array must be in a valid format. You can use the Export
	;                            Toolbar Method (not the Preset Method of the same name)
	;                            passing TRUE to the ArrayOut parameter to return a valid
	;                            array to be used with this method.
	;    Return:             TRUE if Buttons is an object, or FALSE otherwise.
	;=======================================================================================
		pSave(Slot, Buttons) {
			If (IsObject(Buttons)) {
				this.Slots[Slot] := Buttons
				return true
			} Else
				return False
		}
    }
;=======================================================================================
;    Private Class       This class is used internally.
;=======================================================================================
    Class Private {
;=======================================================================================
;    Private Properties
;=======================================================================================
        ; Messages
        Static TB_ADDBUTTONS            := 0x0414
        Static TB_ADDSTRING             := 0x044D ; 0x041C ANSI
        Static TB_AUTOSIZE              := 0x0421
        Static TB_BUTTONCOUNT           := 0x0418
        Static TB_CHECKBUTTON           := 0x0402
        Static TB_COMMANDTOINDEX        := 0x0419
        Static TB_CUSTOMIZE             := 0x041B
        Static TB_DELETEBUTTON          := 0x0416
        Static TB_ENABLEBUTTON          := 0x0401
        Static TB_GETBUTTON             := 0x0417
        Static TB_GETBUTTONSIZE         := 0x043A
        Static TB_GETBUTTONTEXT         := 0x044B ; 0x042D ANSI
        Static TB_GETEXTENDEDSTYLE      := 0x0455
        Static TB_GETHOTITEM            := 0x0447
        Static TB_GETIMAGELIST          := 0x0431
        Static TB_GETIMAGELISTCOUNT     := 0x0462
        Static TB_GETITEMDROPDOWNRECT   := 0x0467
        Static TB_GETITEMRECT           := 0x041D
        Static TB_GETMAXSIZE            := 0x0453
        Static TB_GETPADDING            := 0x0456
        Static TB_GETRECT               := 0x0433
        Static TB_GETROWS               := 0x0428
        Static TB_GETSTATE              := 0x0412
        Static TB_GETSTYLE              := 0x0439
        Static TB_GETSTRING             := 0x045B ; 0x045C ANSI
        Static TB_GETTEXTROWS           := 0x043D
        Static TB_HIDEBUTTON            := 0x0404
        Static TB_INDETERMINATE         := 0x0405
        Static TB_INSERTBUTTON          := 0x0443 ; 0x0415 ANSI
        Static TB_ISBUTTONCHECKED       := 0x040A
        Static TB_ISBUTTONENABLED       := 0x0409
        Static TB_ISBUTTONHIDDEN        := 0x040C
        Static TB_ISBUTTONHIGHLIGHTED   := 0x040E
        Static TB_ISBUTTONINDETERMINATE := 0x040D
        Static TB_ISBUTTONPRESSED       := 0x040B
        Static TB_MARKBUTTON            := 0x0406
        Static TB_MOVEBUTTON            := 0x0452
        Static TB_PRESSBUTTON           := 0x0403
        Static TB_SETBUTTONINFO         := 0x0440 ; 0x0442 ANSI
        Static TB_SETBUTTONSIZE         := 0x041F
        Static TB_SETBUTTONWIDTH        := 0x043B
        Static TB_SETDISABLEDIMAGELIST  := 0x0436
        Static TB_SETEXTENDEDSTYLE      := 0x0454
        Static TB_SETHOTIMAGELIST       := 0x0434
        Static TB_SETHOTITEM            := 0x0448
        Static TB_SETHOTITEM2           := 0x045E
        Static TB_SETIMAGELIST          := 0x0430
        Static TB_SETINDENT             := 0x042F
        Static TB_SETLISTGAP            := 0x0460
        Static TB_SETMAXTEXTROWS        := 0x043C
        Static TB_SETPADDING            := 0x0457
        Static TB_SETPRESSEDIMAGELIST   := 0x0468
        Static TB_SETROWS               := 0x0427
        Static TB_SETSTATE              := 0x0411
        Static TB_SETSTYLE              := 0x0438
        ; Styles
        Static TBSTYLE_ALTDRAG      := 0x0400
        Static TBSTYLE_CUSTOMERASE  := 0x2000
        Static TBSTYLE_FLAT         := 0x0800
        Static TBSTYLE_LIST         := 0x1000
        Static TBSTYLE_REGISTERDROP := 0x4000
        Static TBSTYLE_TOOLTIPS     := 0x0100
        Static TBSTYLE_TRANSPARENT  := 0x8000
        Static TBSTYLE_WRAPABLE     := 0x0200
        Static TBSTYLE_ADJUSTABLE   := 0x20
        Static TBSTYLE_BORDER       := 0x800000
        Static TBSTYLE_THICKFRAME   := 0x40000
        Static TBSTYLE_TABSTOP      := 0x10000
        ; ExStyles
        Static TBSTYLE_EX_DOUBLEBUFFER       := 0x80 ; // Double Buffer the toolbar
        Static TBSTYLE_EX_DRAWDDARROWS       := 0x01
        Static TBSTYLE_EX_HIDECLIPPEDBUTTONS := 0x10 ; // don't show partially obscured buttons
        Static TBSTYLE_EX_MIXEDBUTTONS       := 0x08
        Static TBSTYLE_EX_MULTICOLUMN        := 0x02 ; // Intended for internal use; not recommended for use in applications.
        Static TBSTYLE_EX_VERTICAL           := 0x04 ; // Intended for internal use; not recommended for use in applications.
        ; Button states
        Static TBSTATE_CHECKED       := 0x01
        Static TBSTATE_ELLIPSES      := 0x40
        Static TBSTATE_ENABLED       := 0x04
        Static TBSTATE_HIDDEN        := 0x08
        Static TBSTATE_INDETERMINATE := 0x10
        Static TBSTATE_MARKED        := 0x80
        Static TBSTATE_PRESSED       := 0x02
        Static TBSTATE_WRAP          := 0x20
        ; Button styles
        Static BTNS_BUTTON        := 0x00 ; TBSTYLE_BUTTON
        Static BTNS_SEP           := 0x01 ; TBSTYLE_SEP
        Static BTNS_CHECK         := 0x02 ; TBSTYLE_CHECK
        Static BTNS_GROUP         := 0x04 ; TBSTYLE_GROUP
        Static BTNS_CHECKGROUP    := 0x06 ; TBSTYLE_CHECKGROUP  // (TBSTYLE_GROUP | TBSTYLE_CHECK)
        Static BTNS_DROPDOWN      := 0x08 ; TBSTYLE_DROPDOWN
        Static BTNS_AUTOSIZE      := 0x10 ; TBSTYLE_AUTOSIZE    // automatically calculate the cx of the button
        Static BTNS_NOPREFIX      := 0x20 ; TBSTYLE_NOPREFIX    // this button should not have accel prefix
        Static BTNS_SHOWTEXT      := 0x40 ; // ignored unless TBSTYLE_EX_MIXEDBUTTONS is set
        Static BTNS_WHOLEDROPDOWN := 0x80 ; // draw drop-down arrow, but without split arrow section
        ; TB_GETBITMAPFLAGS
        Static TBBF_LARGE   := 0x00000001
        Static TBIF_BYINDEX := 0x80000000 ; // this specifies that the wparam in Get/SetButtonInfo is an index, not id
        Static TBIF_COMMAND := 0x00000020
        Static TBIF_IMAGE   := 0x00000001
        Static TBIF_LPARAM  := 0x00000010
        Static TBIF_SIZE    := 0x00000040
        Static TBIF_STATE   := 0x00000004
        Static TBIF_STYLE   := 0x00000008
        Static TBIF_TEXT    := 0x00000002
        ; Notifications
        Static TBN_BEGINADJUST     := -703
        Static TBN_BEGINDRAG       := -701
        Static TBN_CUSTHELP        := -709
        Static TBN_DELETINGBUTTON  := -715
        Static TBN_DRAGOUT         := -714
        Static TBN_DRAGOVER        := -727
        Static TBN_DROPDOWN        := -710
        Static TBN_DUPACCELERATOR  := -725
        Static TBN_ENDADJUST       := -704
        Static TBN_ENDDRAG         := -702
        Static TBN_GETBUTTONINFO   := -720 ; A_IsUnicode ? -720 : -700
        Static TBN_GETDISPINFO     := -717 ; -716 ANSI
        Static TBN_GETINFOTIP      := -719 ; -718 ANSI
        Static TBN_GETOBJECT       := -712
        Static TBN_HOTITEMCHANGE   := -713
        Static TBN_INITCUSTOMIZE   := -723
        Static TBN_MAPACCELERATOR  := -728
        Static TBN_QUERYDELETE     := -707
        Static TBN_QUERYINSERT     := -706
        Static TBN_RESET           := -705
        Static TBN_RESTORE         := -721
        Static TBN_SAVE            := -722
        Static TBN_TOOLBARCHANGE   := -708
        Static TBN_WRAPACCELERATOR := -726
        Static TBN_WRAPHOTITEM     := -724
;=======================================================================================
;    Meta-Functions
;
;    Properties:
;        tbHwnd:            Toolbar's Hwnd.
;        DefaultBtnInfo:    Stores information about button's original structures.
;        Presets:           This is a special object used to save and load buttons
;                               layouts. It has its own methods.
;=======================================================================================
        __New(hToolbar) {
            this.tbHwnd := hToolbar
			this.Labels := Map()
            this.DefaultBtnInfo := []
			
			; Class object nesting: Toolbar.Private / Toolbar.tbPresets
            ; this.Presets := {tbHwnd: hToolbar, Base: Toolbar.tbPresets.Prototype}
			this.Slots := Map("1","","2","","3","","4","","5","")
			; this.Presets.Labels := Map()
        }
;=======================================================================================
        __Delete() {
            ; this.RemoveAt(1, this.Length)
        ; ,   this.SetCapacity(0)
            ; this.base := ""
			this := ""
        }
;=======================================================================================
;    Private Methods
;=======================================================================================
;    Method:             SendMessage
;    Description:        Sends a message to create or modify a button.
;=======================================================================================
        SendMessage(Button, Options, Message := "", Param := "") { ; "^(\W?)[\w+)[=\s]?(.*)?:(\d+)\x28?(.*?)?\x29?$"
            If (RegExMatch(Button, "^(\W?)(\w+)[=\s]?(.*)?:(\d+)\x28?(.*?)?\x29?$", Key)) {
                idCommand := this.StringToNumber(Key.Value(2))
                iString := Key.Value(3), iBitmap := Key.Value(4)
				
				; Debug.Msg("IdC: " idCommand " / iString: " iString " / iBitmap: " iBitmap " / key5: " Key.Value(5))
				
                this.Labels[String(idCommand)] := Key.Value(2)
				; this.Presets.Labels[String(idCommand)] := Key.Value(2)
				
                Struct := this.DefineBtnStruct(TBBUTTON, iBitmap, idCommand, iString, Key.Value(5) ? Key.Value(5) : Options)
                this.DefaultBtnInfo.Push(Struct)
                If !(Key.Value(1)) && (Message) {
                    result := SendMessage(Message, Param, TBBUTTON.ptr,, "ahk_id " this.tbHwnd)
                    If (!result)
                        return false
                }
            } Else {
                Struct := this.BtnSep(TBBUTTON, Options), this.DefaultBtnInfo.Push(Struct)
                If (Message) {
                    result := SendMessage(Message, Param, TBBUTTON.ptr,, "ahk_id " this.tbHwnd)
                    If (!result)
                        return false
                }
            }
            return true
        }
;=======================================================================================
;    Method:             DefineBtnStruct
;    Description:        Creates a TBBUTTON structure.
;    Return:             An array with the button structure values.
;=======================================================================================
        DefineBtnStruct(ByRef BtnVar, iBitmap := 0, idCommand := 0, iString := "", Options := "") {
			tbState := 0, tbStyle := 0
            If IsInteger(Options)
                tbStyle := Options, tbState := Toolbar.TBSTATE_ENABLED
            Else {
                Loop Parse, Options, A_Space A_Tab
                {
                    If (Toolbar.HasProp( "TBSTATE_" A_LoopField ))
                        tbState += Toolbar.TBSTATE_%A_LoopField%
                    Else If (Toolbar.HasProp( "BTNS_" A_LoopField ) )
                        tbStyle += Toolbar.BTNS_%A_LoopField%
                    Else If (RegExMatch(A_LoopField, "i)W(\d+)-(\d+)", MW)) {
                        Long := this.MakeLong(MW.Value(1), MW.Value(2))
                        result := SendMessage(Toolbar.TB_SETBUTTONWIDTH, 0, Long,, "ahk_id " this.tbHwnd)
                    }
                }
            }
            If (iString != "") {
                BTNSTR := BufferAlloc(StrPut(iString,"UTF-16"), 0)
            ,   StrPut(iString, BTNSTR.ptr, StrPut(iString,"UTF-16"))
                result := SendMessage(Toolbar.TB_ADDSTRING, 0, BTNSTR.ptr,, "ahk_id " this.tbHwnd)
                StrIdx := result
            }
            Else
                StrIdx := -1
            BtnVar := BufferAlloc(8 + (A_PtrSize * 3), 0)
			NumPut "Int", iBitmap-1, "Int", idCommand, "Char", tbState, "Char", tbStyle, BtnVar
			NumPut "Ptr", StrIdx, BtnVar, 8 + (A_PtrSize * 2)
			
            return Map("Icon",iBitmap-1, "ID",idCommand, "State",tbState, "Style",tbStyle, "Text",iString, "Label",this.Labels[String(idCommand)])
        }
;=======================================================================================
;    Method:             DefineBtnInfoStruct
;    Description:        Creates a TBBUTTONINFO structure for a specific member.
;=======================================================================================
        DefineBtnInfoStruct(ByRef BtnVar, Member, ByRef Value) {
            Static cbSize := 16 + (A_PtrSize * 4)
            
            BtnVar := BufferAlloc(cbSize, 0)
        ,   NumPut("Uint", cbSize, BtnVar, 0)
            If (Toolbar.HasProp( "TBIF_" Member) )
                dwMask := Toolbar.TBIF_%Member%
            ,   NumPut("UInt",dwMask, BtnVar, 4)
            If (dwMask = Toolbar.TBIF_COMMAND)
                NumPut("Int", Value, BtnVar, 8) ; idCommand
            Else If (dwMask = Toolbar.TBIF_IMAGE)
                Value := Value-1
            ,   NumPut("Int", Value, BtnVar, 12) ; iImage
            Else If (dwMask = Toolbar.TBIF_STATE)
                Value := (Toolbar.StateMap.HasProp( "TBSTATE_" Value )) ? Toolbar.TBSTATE_%Value% : Value
            ,   NumPut("Char", Value, BtnVar, 16) ; fsState
            Else If (dwMask = Toolbar.TBIF_STYLE)
                Value := (Toolbar.BtnMap.HasProp( "BTNS_" Value )) ? Toolbar.BTNS_%Value% : Value
            ,   NumPut("Char", Value, BtnVar, 17) ; fsStyle
            Else If (dwMask = Toolbar.TBIF_SIZE)
                NumPut("Short", Value, BtnVar, 18) ; cx
            Else If (dwMask = Toolbar.TBIF_TEXT) {
                NumPut("UPtr", StrPtr(Value), BtnVar, 16 + (A_PtrSize * 2)) ; pszText
			}
		}
;=======================================================================================
;    Method:             BtnSep
;    Description:        Creates a TBBUTTON structure for a separator.
;    Return:             An array with the button structure values.
;=======================================================================================
        BtnSep(ByRef BtnVar, Options := "") {
            tbStyle := Toolbar.BTNS_SEP, tbState := 0
            Loop Parse, Options, A_Space A_Tab
            {
                If (Toolbar.HasProp( "TBSTATE_" A_LoopField ))
                    tbState += Toolbar.TBSTATE_%A_LoopField%
            }
            BtnVar := BufferAlloc(8 + (A_PtrSize * 3), 0)
			NumPut "Char", tbState, "Char", tbStyle, BtnVar, 8
			
            return Map("Icon",-1, "ID","", "State",tbState, "Style",tbStyle, "Text","", "Label","")
        }
;=======================================================================================
;    Method:             StringToNumber
;    Description:        Returns a number based on a string to be used as Command ID.
;=======================================================================================
        StringToNumber(String) {
			; Debug.Msg("NumToStr: " String)
		
			Number := 0
            Loop Parse, String
                Number += Ord(A_LoopField) + Number + Ord(SubStr(String, -1)) ; Number
            return SubStr(Number, 1, 4)
        }
;=======================================================================================
;    Method:             MakeLong
;    Description:        Creates a LongWord from a LoWord and a HiWord.
;=======================================================================================
        MakeLong(LoWord, HiWord) {
            return (HiWord << 16) | (LoWord & 0xffff)
        }
;=======================================================================================
;    Method:             MakeLong
;    Description:        Extracts LoWord and HiWord from a LongWord.
;=======================================================================================
        MakeShort(Long, ByRef LoWord, ByRef HiWord) {
            LoWord := Long & 0xffff
        ,   HiWord := Long >> 16
        }
    }
}