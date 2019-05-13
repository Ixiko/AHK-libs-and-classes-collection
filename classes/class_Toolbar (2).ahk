/*    ---- EXAMPLE ----
Gui := GuiCreate()
TB1 := new Toolbar(Gui, "x5 y5 w550 h40 Border Tooltips")
SendMessage(0x043C, 0, 0,, "ahk_id " TB1.hwnd)
    TB1.OnEvent("Click", "Toolbar_Event_Click")
TB2 := new Toolbar(Gui, "x5 y50 w550 h" . SysGet(11) . " Border")
    TB2.OnEvent("Click", "Toolbar_Event_Click")
TB3 := new Toolbar(Gui, "x5 y87 w40 h360 Border Vertical")
    TB3.OnEvent("Click", "Toolbar3_Event_Click")

TB1.SetImageList(IL_Create())
Loop 10 + 10 + 10 + 10
    IL_Add(TB1.GetImageList(), "shell32.dll", -A_Index)

Loop 10
    TB1.Add(, A_Index = 1 && "Button " . A_Index, A_Index-1,,, 1000+A_Index, 2000+A_Index)
TB1.SetButtonSize(55, 40)
TB1.AutoSize()

TB2.SetImageList(TB1.GetImageList())
Loop 10
    TB2.Add(, String(A_Index), 10+A_Index,,, 3000+A_Index, 4000+A_Index)
TB2.Add()
Loop 8
    TB2.Add(, String(A_Index), 20+A_Index,,, 5000+A_Index, 6000+A_Index)
TB2.SetButtonSize(SysGet(11), SysGet(11))
; TB2.AutoSize()

TB3.SetImageList(TB1.GetImageList())
Loop 9
    TB3.Add(, 0, 30+A_Index, "Wrap",,, A_Index)    ; 4 = TBSTATE_ENABLED | 0x20 = TBSTATE_WRAP (for vertical ToolBars)
TB3.SetButtonSize(40, 40)
TB3.AutoSize()

Gui.Show("w560 h452")
    Gui.OnEvent("Close", "ExitApp")
return

Toolbar_Event_Click(TB, Identifier, Data, X, Y, IsRightClick)
{
    ToolTip "TB.Type " . TB.Type . "`nIdentifier " . Identifier . "`nData " . Data . "`n(X;Y) " . X . ";" . Y . "`nIsRightClick " . IsRightClick
    SetTimer("ToolTip", -1000)
}

Toolbar3_Event_Click(TB, Identifier, Data, X, Y, IsRightClick)
{
    TB.CheckButton(Identifier, -1)
}
*/






Class Toolbar
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static CtrlList := {}    ; stores a list with all the controls Toolbar {ControlID: ToolbarObj}


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Add a toolbar in the specified GUI window.
        Parameters:
            Gui:
                The GUI window object. You can also specify an existing control object (or its identifier).
            Options:
                The options for the new control.
    */
    __New(Gui, Options := "")
    {
        if (Type(Gui) != "Gui")
        {
            Gui := IsObject(Gui) ? Gui.Hwnd : Gui
            local hWnd := 0, obj := ""
            For hWnd, obj in Toolbar.CtrlList
                if (hWnd == Gui)
                    return obj
            return 0
        }

        local Style := 0x40000000 | 0x02000000 | 0x8 | 0x40 | 0x4
        Style |= (InStr(Options, "Menu")                            ? 0x800|0x1000|0x04000000 :0)
               | (InStr(Options, "Vertical")                        ? 0x00080                 :0)
               | (InStr(Options, "Wrapable")                        ? 0x00200                 :0)
               | (InStr(Options, "Tabstop")                         ? 0x10000                 :0)
               | (InStr(Options, "Nodivider")                       ? 0x00040                 :0)
               | (InStr(Options, "Adjustable")                      ? 0x00020                 :0)
               | (InStr(Options, "Tooltips")                        ? 0x00100                 :0)
               | (InStr(Options, "List") && !InStr(Options, "Menu") ? 0x01000                 :0)
               | (InStr(Options, "Flat")                            ? 0x00800                 :0)
               | (InStr(Options, "Bottom")                          ? 0x00003                 :0)
               | (InStr(Options, "Transparent")                     ? 0x08000                 :0)
        local k := "", v := ""
        For k, v in ["Menu","Vertical","Wrapable","Tabstop","Nodivider","Adjustable","Tooltips","List","Flat","Bottom","Transparent"]
            Options := RegExReplace(Options, "i)\b" . v . "\b")

        ; Toolbar Control Reference
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/bumper-toolbar-toolbar-control-reference
        this.ctrl := Gui.AddCustom("ClassToolbarWindow32 +0x" . Format("{:X}", Style) . A_Space . Options)
        this.hWnd := this.ctrl.Hwnd
        this.gui  := Gui
        this.Type := "Toolbar"

        this.Buffer := ""
        ObjSetCapacity(this, "Buffer", 48)
        this.ptr := ObjGetAddress(this, "Buffer")

        this.ExStyle := 8
        this.Callback := {NM_CLICK: 0}
        this.ctrl.OnNotify(-2, ObjBindMethod(this, "EventHandler", -2))
        this.ctrl.OnNotify(-5, ObjBindMethod(this, "EventHandler", -5))
        ObjRawSet(Toolbar.CtrlList, this.hWnd, this)

        ; TB_BUTTONSTRUCTSIZE message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-buttonstructsize
        DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x41E, "UInt", 8 + 3*A_PtrSize, "Ptr", 0)
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    EventHandler(NotifyCode, GuiControl, lParam)
    {
        local ret := 0    ; FALSE = allow default processing of the click
        if (NotifyCode == -2 || NotifyCode == -5)    ; -2 = NM_CLICK | -5 = NM_RCLICK
        {
            if (this.Callback.NM_CLICK)
            {
                ret := this.Callback.NM_CLICK.Call( this
                                                  , NumGet(lParam+3*A_PtrSize  , "Ptr" )     ; NMMOUSE.dwItemSpec
                                                  , NumGet(lParam+4*A_PtrSize  , "UPtr")     ; NMMOUSE.dwItemData
                                                  , NumGet(lParam+5*A_PtrSize  , "Int" )     ; NMMOUSE.pt.x
                                                  , NumGet(lParam+5*A_PtrSize+4, "Int" )     ; NMMOUSE.pt.y
                                                  , NotifyCode == -5 )                       ; IsRightClick
            }

        }
        return ret is "integer" ? ret : 0
    }

    _State(ByRef State)
    {
        return State is "integer" ? State : ( (InStr(State, "Checked")       ? 0x01 : 0x00)
                                            | (InStr(State, "Disabled")      ? 0x00 : 0x04)
                                            | (InStr(State, "Hidden")        ? 0x08 : 0x00)
                                            | (InStr(State, "Indeterminate") ? 0x10 : 0x00)
                                            | (InStr(State, "Pressed")       ? 0x02 : 0x00)
                                            | (InStr(State, "Wrap")          ? 0x20 : 0x00)
                                            | (InStr(State, "Marked")        ? 0x80 : 0x00)
                                            | (InStr(State, "Elipses")       ? 0x40 : 0x00) )
    }

    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Remove the control.
    */
    Destroy()
    {
        ObjDelete(Toolbar.CtrlList, this.hWnd)
      , DllCall("User32.dll\DestroyWindow", "Ptr", this.hWnd)
    }

    /*
        Add an element in the specified position.
        Parameters:
            Item:
                The zero-based index of the new element. To insert an element at the end of the list, set the parameter to -1.
            Text:
                The text of the new element. It can be an empty string or a memory address if it is an integer type number.
                Specify the integer type zero number to leave the button without an assigned string. When you call the GetTextLength method, it will return -1.
                If you set this parameter in the TAB character, add a separator. This is the default value.
            Image:
                The zero-based index of an image within the list of images. The value -2 indicates that the button should not show any image (this is the default value).
                If a separator is to be added, this parameter determines the width of the separator, in pixels. By default it is 5 pixels (value -2).
            State:
                Set the status for the button. Reference: "https://docs.microsoft.com/es-es/windows/desktop/Controls/toolbar-button-states".
                This parameter is ignored if a separator is to be added.
                You can specify one or more of the following words or an integer that defines the states.
                Checked = The button stays highlighted.
                Disabled = The button is disabled.
                Hidden = The button is hidden.
                Indeterminate = The text of the button is always gray and when the cursor is positioned above the button it is not highlighted.
                Pressed = The button is initially set. One click will return it to its normal state.
                Wrap = The button is followed by a line break. This style is necessary for Toolbars with vertical buttons.
                Marked = The button is marked. The interpretation of a marked element depends on the application.
                Ellipses = The text of the button is cut and an ellipsis is displayed.
            Style:
                Define the style of the button. Reference: "https://docs.microsoft.com/es-es/windows/desktop/Controls/toolbar-control-and-button-styles".
            Data:
                An unsigned integer defined by the user for the button. Useful to assign data to a button, passing a memory address.
                This number is 4 bytes in AHK 32-bit and 8 bytes in AHK 64-bit.
            Identifier:
                Command identifier associated with the button. This identifier is used in a WM_COMMAND message when the button is pressed. It must be a 4-byte integer.
                This parameter is not suitable for passing memory addresses. Use the "Data" parameter to associate data with the button.
        Return:
            If successful, it returns a non-zero value.
    */
    Add(Item := -1, Text := "`t", Image := -2, State := 4, Style := 0, Data := 0, Identifier := 0)
    {
        ; _TBBUTTON structure
        ; https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/ns-commctrl-_tbbutton
        NumPut(Text == "`t" ? (Image == -2 ? 5 : Image) : Image, this.ptr, "Int")
      , NumPut(Identifier, this.ptr + 4, "Int")
      , NumPut(Text == "`t" ? 0x04 : this._State(State), this.ptr + 8, "UCHar")
      , NumPut(Text == "`t" ? 0x01 : Style, this.ptr + 9, "UCHar")
      , NumPut(Data, this.ptr + 8 + A_PtrSize, "UPtr")
      , NumPut(Type(Text) == "Integer" ? Text : Text == "`t" ? 0 : &Text, this.ptr + 8 + 2 * A_PtrSize, "UPtr")

        ; TB_INSERTBUTTON message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-insertbutton
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x443, "Ptr", Item, "UPtr", this.ptr)
    }
    
    /*
        Retrieve information on the specified button.
        Return:
            If successful, it returns an object with the keys: Image, ID, State, Style, Data and Text. Otherwise, it returns zero.
    */
    GetButton(Item)
    {
        ; TB_GETBUTTON message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getbutton
        if (!DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x417, "Ptr", Item, "Ptr", this.ptr))
            return FALSE
        return { Image: NumGet(this.ptr            , "Int"  )
               ,    ID: NumGet(this.ptr+4          , "Int"  ) 
               , State: NumGet(this.ptr+8          , "UChar")
               , Style: NumGet(this.ptr+9          , "UChar")
               ,  Data: NumGet(this.ptr+8+A_PtrSize, "UPtr" )
               ,  Text: StrGet(NumGet(this.ptr+8+2*A_PtrSize, "UPtr")||(&""), "UTF-16") }
    }

    /*
        Retrieves the display text on the specified button.
        Parameters:
            Length:
                The maximum number of characters to recover. If this parameter is -1, it retrieves the entire text.
        Return:
            If successful, return the text on the button. Otherwise, it returns an empty string.
            ErrorLevel is set to a non-zero value if there was an error, or zero otherwise.
            Note that if ErrorLevel is not zero, it does not necessarily mean that the message failed, it may be that the button does not have an assigned string.
    */
    GetText(Identifier, Length := -1)
    {
        ; TB_GETBUTTONTEXT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getbuttontext
        local len := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x44B, "Ptr", Identifier, "Ptr", 0, "Ptr")
        if ((len == -1 && (ErrorLevel := TRUE)) || !len)
            return ""
        local buffer := ""
        VarSetCapacity(buffer, len * 2 + 2)
      , ErrorLevel := !DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x44B, "Ptr", Identifier, "UPtr", &buffer, "Ptr")
        return ErrorLevel ? "" : Length == -1 ? StrGet(&buffer, len, "UTF-16") : SubStr(StrGet(&buffer, len, "UTF-16"), 1, Length)
    }

    /*
        Retrieve the number of characters in the text assigned to the specified button.
        Return:
            Returns the number of characters in the text. If there was an error or the button does not have an assigned string, it returns -1.
    */
    GetTextLength(Identifier)
    {
        ; TB_GETBUTTONTEXT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getbuttontext
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x44B, "Ptr", Identifier, "Ptr", 0, "Ptr")
    }

    /*
        Set the information for an existing button in the toolbar.
        Parameters:
            See the Toolbar :: Add method for parameter information.
            Command is the new identifier (Identifier) ​​for the button.
            State must be an integer and not a string (as another option) as in the Toolbar: Add method.
            Width is the width of the button.
            The default values ​​of the parameters indicate that the current value should not be modified.
        Return:
            Returns non-zero if successful, or zero otherwise.
    */
    SetButton(Identifier, Command := "", Image := -3, State := "", Style := "", Width := -1, Data := "", Text := -1)
    {
        ; TB_SETBUTTONINFO message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setbuttoninfo
        NumPut(A_PtrSize == 4 ? 32 : 48, this.ptr, "UInt")
      , NumPut((Type(Text)=="Integer"&&Text<0?0:2) | (Command==""?0:0x20) | (Image<-2?0:1) | (State==""?0:4) | (Style==""?0:8) | (Width<0?0:0x40) | (Data==""?0:0x10), this.ptr+4, "UInt")
      , NumPut(Command == "" ? 0 : Command, this.ptr+8, "Int")
      , NumPut(Image, this.ptr+12, "Int")
      , NumPut(State == "" ? 0 : State, this.ptr+16, "UChar")
      , NumPut(Style == "" ? 0 : Style, this.ptr+17, "UChar")
      , NumPut(Width, this.ptr+18, "UShort")
      , NumPut(Data == "" ? 0 : Data, this.ptr+16+A_PtrSize, "UChar")
      , NumPut(Type(Text) == "Integer" ? Text : &Text, this.ptr+16+2*A_PtrSize, "UPtr")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x440, "Ptr", Identifier, "UPtr", this.ptr)
    }

    /*
        Set the display text on the specified button.
        Parameters:
            Text:
                The text for the button. It can be an empty string or a memory address if it is an integer type number.
                Specify the integer type zero number to leave the button without an assigned string. When you call the GetTextLength method, it will return -1.
        Return:
            Returns non-zero if successful, or zero otherwise.
    */
    SetText(Identifier, Text := "")
    {
        ; TB_SETBUTTONINFO message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setbuttoninfo
        NumPut(((A_PtrSize==4?32:48) & 0xFFFFFFFF) | ((2 & 0xFFFFFFFF) << 32), this.ptr, "UInt64")    ; 2 = TBIF_TEXT
      , NumPut(Type(Text) == "Integer" ? Text : &Text, this.ptr+16+2*A_PtrSize, "UPtr")
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x440, "Ptr", Identifier, "UPtr", this.ptr)
    }
    
    /*
        Sets maximum number of text rows for button captions.
        Parameters:
            MaxRows:
                Maximum number of text rows. If omitted defaults to 0.
        Return:
            Returns non-zero if successful, or zero otherwise.
    */
    SetMaxTextRows(MaxRows := 0)
    {
        return SendMessage(0x043C, MaxRows, 0,, "ahk_id " this.hWnd)
    }

    /*
        Retrieve the current width and height of the buttons on the toolbar, in pixels.
        Return:
            Returns an object with the keys «W» and «H».
    */
    GetButtonSize()
    {
        ; TB_GETBUTTONSIZE message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getbuttonsize
        local size := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x43A, "Ptr", 0, "Ptr", 0, "UInt")
        return {W: size & 0xFFFF, H: (size >> 16) & 0xFFFF}
    }

    /*
        Set the actual size of the buttons in the toolbar.
        Observations:
            TB_SETBUTTONSIZE should generally be called after adding buttons.
    */
    SetButtonSize(Width := "", Height := "")
    {
        local size := this.GetButtonSize()
        Width := Width == "" ? size.W : Width, Height := Height == "" ? size.H : Height
        ; TB_SETBUTTONSIZE message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setbuttonsize
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x41F, "Ptr", 0, "UInt", (Width & 0xFFFF) | ((Height & 0xFFFF) << 16))
    }

    /*
        Sets the minimum and maximum width of the buttons in the toolbar control.
        Return:
            Returns non-zero if successful, or zero otherwise.
    */
    SetButtonWidth(Min, Max)
    {
        ; TB_SETBUTTONWIDTH message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setbuttonwidth
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x43B, "Ptr", 0, "UInt", (Min & 0xFFFF) | ((Max & 0xFFFF) << 16))
    }

    /*
        Get the ideal size of the toolbar.
        Return:
            Returns an object with the Width and Height keys. If there was an error, the value of the keys is set to zero.
    */
    GetIdealSize()
    {
        ; TB_GETIDEALSIZE message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getidealsize
        local W := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x463, "Ptr", 0, "UPtr", this.ptr)
        local H := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x463, "Ptr", 1, "UPtr", this.ptr + 4)
        return {W: W?NumGet(this.ptr, "Int"):0, H: H?NumGet(this.ptr+8, "Int"):0}
    }

    /*
        Retrieves the zero-based index of the active item in the toolbar.
        Return:
            Returns the index of the active element, or -1 if there is no active element set.
            Toolbar controls that do not have the TBSTYLE_FLAT style do not have active elements.
    */
    GetHotItem()
    {
        ; TB_GETHOTITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-gethotitem
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x447, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Retrieve the bounding rectangle of a button in the toolbar.
        Return:
            If successful, return an object with the keys: L (left), T (top), R (right) and B (bottom).
    */
    GetItemRect(Item)
    {
        ; TB_GETITEMRECT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getitemrect
        local ret := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x41D, "Ptr", Item, "UPtr", this.ptr)
        return ret ? {L: NumGet(this.ptr, "Int"), T: NumGet(this.ptr+4, "Int"), R: NumGet(this.ptr+8, "Int"), B: NumGet(this.ptr+12, "Int")} : 0
    }

    /*
        Retrieves a pointer to the IDropTarget interface for the toolbar control.
        ErrorLevel is set to an HRESULT error code.
        IDropTarget is used by the toolbar when objects are dragged or dropped on it.
    */
    GetObject()
    {
        ; TB_GETOBJECT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getobject
        DllCall("Ole32.dll\CLSIDFromString", "Str", "{00000122-0000-0000-C000-000000000046}", "UPtr", this.ptr)
        local IDropTarget := 0
        ErrorLevel := DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x43E, "UPtr", this.ptr, "PtrP", IDropTarget, "UInt")
        return IDropTarget
    }
    
    /*
        Remove a button from the toolbar.
        Return:
            Returns a non-zero value if successful.
    */
    Delete(Item)
    {
        ; TB_DELETEBUTTON message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-deletebutton
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x416, "Ptr", Item, "Ptr", 0)
    }

    /*
        Remove all buttons from the toolbar.
        Return:
            Returns the number of buttons removed.
    */
    DeleteAll()
    {
        local i := this.GetCount()
        Loop i
            this.Delete(0)
        return i
    }

    /*
        Retrieves the zero-based index for the button associated with the specified command identifier.
        Return:
            Returns the index based on zero for the button or -1 if the specified command identifier is not valid.
    */
    CommandToIndex(Identifier)
    {
        ; TB_COMMANDTOINDEX message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787305(v=vs.85).aspx
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x419, "Ptr", Identifier, "Ptr", 0)
    }

    /*
        Retrieves the command identifier associated with the zero-based index of the specified button.
        Return:
            Returns the command identifier for the button or an empty string if the specified zero-based index is not valid.
    */
    IndexToCommand(Item)
    {
        ; TB_GETBUTTON message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getbutton
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x417, "Ptr", Item, "Ptr", this.ptr) ? NumGet(this.ptr+4, "Int") : ""
    }

    /*
        Retrieve the number of buttons currently in the toolbar.
    */
    GetCount()
    {
        ; TB_BUTTONCOUNT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-buttoncount
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x418, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Check or uncheck a given button in the toolbar.
        Parameters:
            Check:
                Indicates whether to mark or unmark the specified button. Specify -1 to invert the current state.
    */
    CheckButton(Identifier, Check := TRUE)
    {
        ; TB_CHECKBUTTON message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-checkbutton
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x402, "Ptr", Identifier, "Ptr", Check == -1 ? !this.IsButtonChecked(Identifier) : !!Check)
    }

    /*
        Determines whether the button specified in the toolbar is marked.
        Return:
            Returns a non-zero value if the button is checked, or zero otherwise.
    */
    IsButtonChecked(Identifier)
    {
        ; TB_ISBUTTONCHECKED message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-isbuttonchecked
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x40A, "Ptr", Identifier, "Ptr", 0)
    }

    /*
        Enables or disables the button specified in the toolbar.
        Parameters:
            Enable:
                Indicates whether to enable or disable the specified button. Specify -1 to invert the current state.
    */
    EnableButton(Identifier, Enable := TRUE)
    {
        ; TB_ENABLEBUTTON message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-enablebutton
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x401, "Ptr", Identifier, "Ptr", Enable == -1 ? !this.IsButtonEnabled(Identifier) : !!Enable)
    }

    /*
        Determines whether the button specified in the toolbar is enabled.
        Return:
            Returns a non-zero value if the button is enabled, or zero otherwise.
    */
    IsButtonEnabled(Identifier)
    {
        ; TB_ISBUTTONENABLED message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-isbuttonenabled
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x409, "Ptr", Identifier, "Ptr", 0)
    }

    /*
        Show or hide the button specified in the toolbar.
        Parameters:
            Show:
                Indicates whether to show or hide the specified button. Specify -1 to invert the current state.
    */
    ShowButton(Identifier, Show := TRUE)
    {
        ; TB_HIDEBUTTON message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-hidebutton
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x404, "Ptr", Identifier, "Ptr", Show == -1 ? !this.IsButtonVisible(Identifier) : !!Show)
    }

    /*
        Determines whether the button specified in the toolbar is visible.
        Return:
            Returns a non-zero value if the button is visible, or zero otherwise.
    */
    IsButtonVisible(Identifier)
    {
        ; TB_ISBUTTONHIDDEN message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-isbuttonhidden
        return !DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x40C, "Ptr", Identifier, "Ptr", 0)
    }

    /*
        Causes the resizing of the toolbar.
        Observations:
            An application sends the TB_AUTOSIZE message after having the size of the toolbar change by setting the size of the button or bitmap or adding strings for the first time.
        Return:
            It always returns the Toolbar object.
    */
    AutoSize()
    {
        ; TB_AUTOSIZE message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-autosize
        DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x421, "Ptr", 0, "Ptr", 0)
    }

    /*
        Displays the Customize Toolbar dialog box.
    */
    Customize()
    {
        ; TB_CUSTOMIZE message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-customize
        DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x41B, "Ptr", 0, "Ptr", 0)
    }

    /*
        Redraw the area occupied by the control.
    */
    Redraw()
    {
        ; InvalidateRect function
        ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-invalidaterect
        return DllCall("User32.dll\InvalidateRect", "Ptr", this.hWnd, "UPtr", 0, "Int", TRUE)
    }

    /*
        Sets the focus of the keyboard on the control.
    */
    Focus()
    {
        this.ctrl.Focus()
    }

    /*
        Sets the font of the control
    */
    SetFont(Options, FontName := "")
    {
        this.ctrl.SetFont(Options, FontName)
    }

    /*
        Move and/or change the size of the control, optionally redraw it.
    */
    Move(Pos, Draw := FALSE)
    {
        this.ctrl.Move(Pos, Draw)
    }

    /*
        Registers a function to be called when an event occurs.
        Parameters:
            EventName:
                The type of event must be one of the chains specified below.
                Click = When the user presses the left or right click on any part of the control.
                         The function to call receives the parameters: Callback (CtrlObj, Identifier, Data, X, Y, IsRightClick).
            Callback:
                The name or reference to a function to call. Specify an empty string to eliminate the function of the record.
                Below are the common parameters between all the events that the function receives.
                CtrlObj = Receives the Toolbar object in which the message occurred.
                Identifier = The command identifier of the button where the click occurred.
                Data = An unsigned integer assigned to the button.
                X / Y = The coordinates of the cursor relative to the control area.
        Toolbar Control Notifications:
            https://docs.microsoft.com/es-es/windows/desktop/Controls/bumper-toolbar-control-reference-notifications
    */
    OnEvent(EventName, Callback)
    {
        If (EventName = "Click")
            this.Callback.NM_CLICK := Type(Callback) != "String" ? Callback : Callback == "" ? 0 : Func(Callback)
        else
            throw Exception("Class Toolbar::OnEvent invalid parameter #1", -1)
    }

    /*
        Sets the list of images that the toolbar uses to show the buttons that are in their default state.
        Parameters:
            ImageList:
                The identifier of the image list.
            Index:
                The index of the list.
        Return:
            Returns the identifier of the image list previously associated with the control, or returns 0 (NULL) if a list of images was not previously established.
            If the Destroy parameter is non-zero, it returns a non-zero value if it succeeded.
    */
    SetImageList(ImageList, Index := 0)
    {
        ; TB_SETIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x430, "Ptr", Index, "Ptr", ImageList, "Ptr")
    }

    /*
        Sets the list of images that the toolbar uses to show the buttons that are in the pressed state.
    */
    SetPressedImageList(ImageList, Index := 0)
    {
        ; TB_SETPRESSEDIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setpressedimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x468, "Ptr", Index, "Ptr", ImageList, "Ptr")
    }

    /*
        Sets the list of images that the toolbar control will use to display the shortcut buttons.
    */
    SetHotImageList(ImageList)
    {
        ; TB_SETHOTIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-sethotimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x434, "Ptr", 0, "Ptr", ImageList, "Ptr")
    }

    /*
        Sets the list of images that the toolbar control will use to display disabled buttons.
    */
    SetDisabledImageList(ImageList)
    {
        ; TB_SETDISABLEDIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setdisabledimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x436, "Ptr", 0, "Ptr", ImageList, "Ptr")
    }

    /*
        Retrieves the list of images used by the toolbar control to display the buttons in their default state.
        A toolbar control uses this list of images to show the buttons when they are not active or disabled.
    */
    GetImageList()
    {
        ; TB_GETIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x431, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Gets the list of images that the toolbar control uses to show buttons in the pressed state.
    */
    GetPressedImageList()
    {
        ; TB_GETPRESSEDIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getpressedimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x469, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Retrieves the list of images used by the toolbar control to display quick access buttons.
    */
    GetHotImageList()
    {
        ; TB_GETHOTIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-gethotimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x435, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Retrieves the list of images used by the toolbar control to display the inactive buttons.
    */
    GetDisabledImageList()
    {
        ; TB_GETDISABLEDIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getdisabledimagelist
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x437, "Ptr", 0, "Ptr", 0, "Ptr")
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Retrieve or set the styles that are in use in the control.
        set:
            Returns a value that contains the styles previously used for the control.
    */
    Style[]
    {
        get {
            ; TB_GETSTYLE message
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787350(v=vs.85).aspx
            return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x439, "Ptr", 0, "Ptr", 0, "UInt")
        }
        set {
            ; TB_SETSTYLE message
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787459(v=vs.85).aspx
            return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x438, "Ptr", 0, "UInt", value, "UInt")
        }
    }

    /*
        Retrieves or sets the extended styles that are in use in the control.
        set:
            Returns a value that contains the extended styles previously used for the control.
    */
    ExStyle[]
    {
        get {
            ; TB_GETEXTENDEDSTYLE message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-getextendedstyle
            return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x455, "Ptr", 0, "Ptr", 0, "UInt")
        }
        set {
            ; TB_SETEXTENDEDSTYLE message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/tb-setextendedstyle
            return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0x454, "Ptr", 0, "UInt", value, "UInt")
        }
    }

    /*
        Retrieves the position and dimensions of the control.
    */
    Pos[]
    {
        get {
            return this.ctrl.Pos
        }
    }

    /*
        Determines if the control has keyboard focus.
    */
    Focused[]
    {
        get {
            return this.ctrl.Focused
        }
    }

    /*
        Retrieves or sets the visibility status of the control.
        get:
            Returns zero if the window is not visible, 1 otherwise.
        set:
            If the window was previously visible, the return value is nonzero.
            If the window was previously hidden, the return value is zero.
    */
    Visible[]
    {
        get {
            ; IsWindowVisible function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633530(v=vs.85).aspx
            return DllCall("User32.dll\IsWindowVisible", "Ptr", this.hWnd)
        }
        set {
            ; ShowWindow function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633548(v=vs.85).aspx
            return DllCall("User32.dll\ShowWindow", "Ptr", this.hWnd, "Int", Value ? 8 : 0)
        }
    }

    /*
        Retrieves or sets the enabled / disabled state of the control.
        get:
            If the window is enabled, it returns a non-zero value, or zero otherwise.
        set:
            If the window was disabled, the return value is non-zero.
            If the window was enabled, the return value is zero.
    */
    Enabled[]
    {
        get {
            ; IsWindowEnabled function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646303(v=vs.85).aspx
            return DllCall("User32.dll\IsWindowEnabled", "Ptr", this.hWnd)
        }
        set {
            ; EnableWindow function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646291(v=vs.85).aspx
            return DllCall("User32.dll\EnableWindow", "Ptr", this.hWnd, "Int", !!Value)
        }
    }
}
