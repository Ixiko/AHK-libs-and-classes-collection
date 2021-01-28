/*  Windows Color Picker Plus (by rbrtryn)
    https://autohotkey.com/board/topic/91229-windows-color-picker-plus/

    Edited by me lemasato:
        BGR2RGB():
        Use Format() to convert the value to hex instead of SetFormat
*/

/*  SAMPLE EXAMPLE

    Gui +hwndGuiHwnd
    Gui Color, 0x888888, ControlColor
    Gui Show, w500 h500
    Colors := [0x00FF00, 0xFF0000, 0xFF00FF]
    MyColor := ChooseColor(0xFF, GuiHwnd, , ,Colors*)
    Gui Color, %MyColor%
    MsgBox % ErrorLevel "`n" MyColor
    ExitApp
*/


/*!
    Function: ChooseColor([pRGB, hOwner, DlgX, DlgY, Palette])
        Displays a standard Windows dialog for choosing colors.

    Parameters:
        pRGB - The initial color to display in the dialog in RGB format.
               The default setting is Black.
        hOwner - The Window ID of the dialog's owner, if it has one. Defaults to
                0, i.e. no owner. If specified DlgX and DlgY are ignored.
        DlgX, DlgY - The X and Y coordinates of the upper left corner of the 
                     dialog. Both default to 0.
        Palette - An array of up to 16 RGB color values. These become the 
                  initial custom colors in the dialog.

    Remarks:
        The custom colors in the dialog are remembered between calls.
        
        If the user selects OK, the Palette array (if it exists) will be loaded 
        with the custom colors from the dialog. 

    Returns:
        If the user selects OK, the selected color is returned in RGB format 
        and ErrorLevel is set to 0. Otherwise, the original pRGB value is 
        returned and ErrorLevel is set to 1.
*/
ChooseColor(pRGB := 0, hOwner := 0, DlgX := 0, DlgY := 0, Palette*)
{
    static CustColors    ; Custom colors are remembered between calls
    static SizeOfCustColors := VarSetCapacity(CustColors, 64, 0)
    static StructSize := VarSetCapacity(ChooseColor, 9 * A_PtrSize, 0)

    
    
    CustData := (DlgX << 16) | DlgY    ; Store X in high word, Y in the low word

;___Load user's custom colors
    for Index, Value in Palette
        NumPut(BGR2RGB(Value), CustColors, (Index - 1) * 4, "UInt")

;___Set up a ChooseColor structure as described in the MSDN
    NumPut(StructSize, ChooseColor, 0, "UInt")
    NumPut(hOwner, ChooseColor, A_PtrSize, "UPtr")
    NumPut(BGR2RGB(pRGB), ChooseColor, 3 * A_PtrSize, "UInt")
    NumPut(&CustColors, ChooseColor, 4 * A_PtrSize, "UPtr")
    NumPut(0x113, ChooseColor, 5 * A_PtrSize, "UInt")
    NumPut(CustData, ChooseColor, 6 * A_PtrSize, "UInt")
    NumPut(RegisterCallback("ColorWindowProc"), ChooseColor, 7 * A_PtrSize, "UPtr")

;___Call the function
    ErrorLevel := ! DllCall("comdlg32\ChooseColor", "UPtr", &ChooseColor, "UInt")

;___Save the changes made to the custom colors
    if not ErrorLevel
        Loop 16
            Palette[A_Index] := BGR2RGB(NumGet(CustColors, (A_Index - 1) * 4, "UInt"))

    ; My tests
    ; ChooseColor := BGR2RGB(NumGet(ChooseColor, 3 * A_PtrSize, "UINT"))
    ; msgbox % ChooseColor " - " 1
    ; ChooseColor := Format("{1:#x}", NumGet(ChooseColor, 3 * A_PtrSize, "UINT"))
    ; msgbox % ChooseColor " - " 2
    ; chooseColor := BGR2RGB(ChooseColor)
    ; msgbox % ChooseColor " - " 3


    
    ; msgbox % chooseColor
    ; chooseColor := Format("{1:#x}", chooseColor)
    ; msgbox % chooseColor
    ; chooseColor := BGR2RGB(NumGet(ChooseColor, 3 * A_PtrSize, "UINT"))

    ; Original
    ; msgbox % ChooseColor " - " A_PtrSize
    ; SetFormat, Integer, H
    ChooseColor := BGR2RGB(NumGet(ChooseColor, 3 * A_PtrSize, "UINT"))
    ; SetFormat, Integer, D
    ; msgbox % ChooseColor




        
    return ChooseColor
}

/*!
    Function: ColorWindowProc(hwnd, msg, wParam, lParam)
        Callback function used to modify the Color dialog before it is displayed

    Parameters:
        hwnd - Handle to the Color dialog window.
        msg - The message sent to the window.
        wParam - The handle to the control that has the keyboard focus.
        lParam - A pointer to the ChooseColor structure associated with the 
                 Color dialog.

    Remarks:
        This is intended to be a private function, called only by ChooseColor. 
        In response to a WM_INITDIALOG message, this function can be used to 
        modify the Color dialog before it is displayed. Currently it just moves 
        the window to a new X, Y location.

    Returns:
        If the hook procedure returns zero, the default dialog box procedure 
        also processes the message. Otherwise, the default dialog box procedure 
        ignores the message.
*/
ColorWindowProc(hwnd, msg, wParam, lParam)
{
    static WM_INITDIALOG := 0x0110
    
    if (msg <> WM_INITDIALOG)
        return 0
    
    hOwner := NumGet(lParam+0, A_PtrSize, "UPtr")
    if (hOwner)
        return 0

    DetectSetting := A_DetectHiddenWindows
    DetectHiddenWindows On
    CustData := NumGet(lParam+0, 6 * A_PtrSize, "UInt")
    DlgX := CustData >> 16, DlgY := CustData & 0xFFFF
    WinMove ahk_id %hwnd%, , %DlgX%, %DlgY%
    
    DetectHiddenWindows %DetectSetting%
    return 0
}

/*!
    Function: BGR2RGB(Color)
        Converts a BGR color value to a RGB one or vice versa.

    Parameters:
        Color - The BGR or RGB value to convert

    Returns:
        The converted value.
*/
BGR2RGB(Color)
{
    
    ret := Format("{1:#.6x}", (Color & 0xFF000000) 
         | ((Color & 0xFF0000) >> 16) 
         |  (Color & 0x00FF00) 
         | ((Color & 0x0000FF) << 16))

    return ret
}
