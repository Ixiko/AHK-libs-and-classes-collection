/* ComboBox / DropDownList Manipulation functions
- heresy

-Common Parameters
    Control : ClassNN of Control (default=ComboBox1)
    Window : WinTitle of the window (default=ahk_class AutoHotkeyGUI)
    Pos : Sel of the Box, usually starts from 0 (-1 = currentsel by default)
    String : String to be added/inserted/modified with 

-Functions
    CB_Get(Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Return current selected position
    CB_Set(Pos=0, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Set selected position to %Position%
    CB_Add(String="", Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Add %String% to the end
    CB_Insert(String="", Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Insert %String% at specified %Position%
    CB_Modify(String="", Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Modify entry of specified %Position% to %String%
    CB_Delete(Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Delete entry of specified %Position%
    CB_Reset(Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Reset (delete all)
    CB_Find(String, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Find position of %String%
    CB_FindExact(String, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Same as above but more accuracy
    CB_Select(String, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Find %String% and Select automatically
        equivalent to (GuiControl, ChooseString, ControlID, String)
    CB_Show(Flag=True, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Show DropDown or Hide(Flag=False)
    CB_GetCount(Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Return total count of the entries
    CB_GetText(Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Return text of the specified %Position%
    CB_GetTexts(delimiter="`n", Control="ComboBox1", Window="ahk_class AutoHotkeyGUI")
        Return text of all entries
*/

CB_Get(Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    SendMessage, 0x147,,, %Control%, %Window% ;CB_GETCURSEL
    Return Errorlevel
}

CB_Set(Pos=0, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    SendMessage, 0x14E, %Pos%,, %Control%, %Window% ;CB_SETCURSEL
    Return Errorlevel
}

CB_Add(String="", Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    SendMessage, 0x143,, &String, %Control%, %Window% ;CB_ADDSTRING
    Result := Errorlevel
    CB_Set(Errorlevel, Control, Window)
    Return Result    
}

CB_Insert(String="", Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    if Pos=-1
        Pos := CB_Get(Control, Window)
    SendMessage, 0x14A, %Pos%, &String, %Control%, %Window% ;CB_INSERTSTRING
    Result := Errorlevel
    CB_Set(Pos, Control, Window)
    Return Result    
}

CB_Modify(String="", Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    if Pos=-1
        Pos := CB_Get(Control, Window)
    SendMessage, 0x144, %Pos%,, %Control%, %Window% ;CB_DELETESTRING
    SendMessage, 0x14A, %Pos%, &String, %Control%, %Window% ;CB_INSERTSTRING
    Result := Errorlevel
    CB_Set(Pos, Control, Window)
    Return Result
}

CB_Delete(Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    if Pos=-1
        Pos := CB_Get(Control, Window)
    SendMessage, 0x144, %Pos%,, %Control%, %Window% ;CB_DELETESTRING
    Result := Errorlevel
    CB_Set(Pos, Control, Window)
    Return Result
}

CB_Reset(Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    SendMessage, 0x14B,,, %Control%, %Window% ;CB_RESETCONTENT
    Return Errorlevel    
}

CB_Find(String, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    SendMessage, 0x14C,, &String, %Control%, %Window%
    Result := Errorlevel
    Return (Result > CB_GetCount(Control, Window)) ? -1 : Result
}

CB_FindExact(String, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    SendMessage, 0x158,, &String, %Control%, %Window%
    Result := Errorlevel
    Return (Result > CB_GetCount(Control, Window)) ? -1 : Result 
}

CB_Select(String, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    SendMessage, 0x14D,, &String, %Control%, %Window%
    Return Errorlevel
}

CB_Show(Flag=True, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    SendMessage, 0x14F, %Flag%,, %Control%, %Window% ;CB_SHOWDROPDOWN
    Return Errorlevel
}

CB_GetCount(Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    SendMessage, 0x146,,, %Control%, %Window% ;CB_GETCOUNT
    Return Errorlevel    
}

CB_GetText(Pos=-1, Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    if Pos=-1
        Pos := CB_Get(Control, Window)
    SendMessage, 0x149, %Pos%,, %Control%, %Window% ;CB_GETLBTEXTLEN
    VarSetCapacity(buffer, Errorlevel) ;prepare buffer
    SendMessage,0x148, %Pos%, &buffer, %Control%, %Window% ;CB_GETLBTEXT
    Return buffer
}

CB_GetTexts(delimiter="`n", Control="ComboBox1", Window="ahk_class AutoHotkeyGUI"){
    Loop, % CB_GetCount(Control, Window)
    {
        SendMessage, 0x149, % A_Index-1,, %Control%, %Window% ;CB_GETLBTEXTLEN
        VarSetCapacity(buffer, Errorlevel) ;prepare buffer
        SendMessage, 0x148, % A_Index-1, &buffer, %Control%, %Window% ;CB_GETLBTEXT
        Result .= buffer . delimiter
        VarSetCapacity(buffer,0) ;empty for next wheel
    }
    StringTrimRight, Result, Result, % StrLen(delimiter) ;remove tail
    Return Result
}