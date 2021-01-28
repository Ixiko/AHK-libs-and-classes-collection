/*
    Muestra un diálogo para pedirle al usuario que seleccione un color.
    Parámetros:
        Owner  : El identificador de la ventana propietaria del diálogo. Este valor puede ser cero.
        Color  : El color RGB seleccionado por defecto al crear el diálogo. Si este valor es -1, automáticamente se lee el último color seleccionado.
        Palette: Un array con un máximo de 16 colores a mostrar en la paleta de colores. Si este valor es 0, se lee la paleta de colores guardada.
    Return:
        La función devuelve -1 si el usuario canceló el diálogo. En caso contrario devuelve el color RGB (0x000000).
    Observaciones:
        El color seleccionado y la paleta de colores son automáticamente guardadas en un archivo cuando el usuario acepta el diálogo.
*/
ChooseColor(Owner := 0, Color := -1, Palette := 0)
{
    Local CfgFile := A_AppData . '\AutoHotkey\Temp\ChooseColor.ini'
        , Flags   := 0x00000100 | 0x00000010 | 0x00000001    ; CC_ANYCOLOR | CC_ENABLEHOOK | CC_RGBINIT

    Color   := Color == -1 ? IniRead(CfgFile, 'Default', 'Color', 0) : ((Color & 255) << 16) | (((Color >> 8) & 255) << 8) | (Color >> 16)
    Palette := IsObject(Palette) ? Palette : []

    If (!FileExist(CfgFile))
    {
        DirCreate(SubStr(CfgFile, 1, -16))
        FileOpen(CfgFile, 'w', 'CP0')
    }
    
    ; CUSTOM structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd183449(v=vs.85).aspx
    Local CUSTOM
    Loop (VarSetCapacity(CUSTOM, 16 * A_PtrSize) // A_PtrSize)
    {
        If (A_Index > Palette.Length() || Palette[A_Index] == '' || Palette[A_Index] < 0)
            NumPut(IniRead(CfgFile, 'Palette', A_Index, 0), &CUSTOM + (A_Index - 1) * 4, 'UInt')
        Else
            NumPut(((Palette[A_Index] & 255) << 16) | (((Palette[A_Index] >> 8) & 255) << 8) | (Palette[A_Index] >> 16), &CUSTOM + (A_Index - 1) * 4, 'UInt')
    }
    
    ; CHOOSECOLOR structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646830(v=vs.85).aspx
    Local CHOOSECOLOR
        , Address := RegisterCallback('ChooseColor_Callback')
    NumPut(VarSetCapacity(CHOOSECOLOR, 9 * A_PtrSize, 0), CHOOSECOLOR, 0, 'UInt')
    NumPut(Owner  , &CHOOSECOLOR+A_PtrSize  , 'Ptr' )    ;CHOOSECOLOR.hwndOwner
    NumPut(Color  , &CHOOSECOLOR+A_PtrSize*3, 'Ptr' )    ;CHOOSECOLOR.rgbResult
    NumPut(&CUSTOM, &CHOOSECOLOR+A_PtrSize*4, 'UPtr')    ;CHOOSECOLOR.lpCustColors
    NumPut(Flags  , &CHOOSECOLOR+A_PtrSize*5, 'UInt')    ;CHOOSECOLOR.Flags
    NumPut(0      , &CHOOSECOLOR+A_PtrSize*6, 'UPtr')    ;CHOOSECOLOR.lCustData
    NumPut(Address, &CHOOSECOLOR+A_PtrSize*7, 'UPtr')    ;CHOOSECOLOR.lpfnHook

    ; ChooseColor function
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646912(v=vs.85).aspx
    Local Result := DllCall('ComDlg32.dll\ChooseColorW', 'UPtr', &CHOOSECOLOR)
    
    ; GlobalFree function
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366579(v=vs.85).aspx
    If (DllCall('Kernel32.dll\GlobalFree', 'UPtr', Address, 'UPtr'))
        Throw Exception('GlobalFree could not release the global memory object.',, 'WINAPI::ChooseColor CHOOSECOLOR.lpfnHook' . ' --> ' . Address)

    If (Result)
    {
        IniWrite(Color := NumGet(&CHOOSECOLOR+A_PtrSize*3, 'UInt'), CfgFile, 'Default', 'Color')
        
        Loop (16)
            IniWrite(NumGet(&CUSTOM + (A_Index - 1) * 4, 'UInt'), CfgFile, 'Palette', A_Index)
    }

    Return (Result ? Format('0x{:06X}', (Color & 255) << 16 | (Color & 65280) | (Color >> 16)) : -1)
}




; CCHookProc callback function
; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646908(v=vs.85).aspx
ChooseColor_Callback(hdlg, uiMsg, wParam, lParam)
{
    ; WM_INITDIALOG message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645428(v=vs.85).aspx
    If (uiMsg == 0x0110)
    {
        DetectHiddenWindows(TRUE)
        WinActivate('ahk_id' . hdlg)
    }

    ; WM_CTLCOLORDLG message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms645417(v=vs.85).aspx
    If (uiMsg == 0x0136)
    {
    }

    Return (0)
}
