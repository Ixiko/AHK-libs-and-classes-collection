/*
    Crea una fuente lógica con las características especificadas. La fuente lógica puede seleccionarse posteriormente como fuente para cualquier dispositivo.
    Parámetros:
        Options: Opciones, estas son las palabras claves válidas.
            sN                                  = El tamaño del texto. El valor predeterminado es 10.
            wN                                  = El peso o grosor del texto. El valor predeterminado es 400 (Normal).
            csN                                 = El conjunto de caracteres. El valor predeterminado es 1 (DEFAULT_CHARSET).
            qN                                  = La calidad del texto. El valor predeterminado es 5 (CLEARTYPE_QUALITY).
            Bold / Italic / Underline / Strike  = Los efecto del texto, pueden ser negrita, cursiva, subrayado, tachado respectivamente. El valor predeterminado es 0 (Normal. Sin efectos).
        FontName: El nombre de la fuente. El valor predeterminado es 'Arial'.
    Return:
        Si tuvo éxito devuelve el identificador de la fuente, caso contrario devuelve 0.
*/
CreateFont(Options := '', FontName := 'Arial')
{
    Local t
        , hDC := DllCall('Gdi32.dll\CreateDCW', 'Str', 'DISPLAY', 'Ptr', 0, 'Ptr', 0, 'Ptr', 0, 'Ptr')
        , n   := DllCall('Gdi32.dll\GetDeviceCaps', 'Ptr', hDC, 'Int', 90)

    DllCall('Gdi32.dll\DeleteDC', 'Ptr', hDC)

    Return ( DllCall('Gdi32.dll\CreateFontW', 'Int' , -Round((Abs(RegExMatch(Options, 'i)s([\-\d\.]+)(p*)', t) ? t[1] : 10) * n) / 72)           ;nHeight
                                            , 'Int' , 0                                                                                          ;nWidth
                                            , 'Int' , 0                                                                                          ;nEscapement
                                            , 'Int' , 0                                                                                          ;nOrientation
                                            , 'Int' , RegExMatch(Options, 'i)w([\-\d\.]+)(p*)', t) ? t[1] : (InStr(Options, 'Bold') ? 700 : 400) ;fnWeight
                                            , 'UInt', !!InStr(Options, 'Italic')                                                                 ;fdwItalic
                                            , 'UInt', !!InStr(Options, 'Underline')                                                              ;fdwUnderline
                                            , 'UInt', !!InStr(Options, 'Strike')                                                                 ;fdwStrikeOut
                                            , 'UInt', RegExMatch(Options, 'i)cs([\-\d\.]+)(p*)', t) ? t[1] : 1                                   ;fdwCharSet
                                            , 'UInt', 4                                                                                          ;fdwOutputPrecision
                                            , 'UInt', 0                                                                                          ;fdwClipPrecision
                                            , 'UInt', RegExMatch(Options, 'i)q([\-\d\.]+)(p*)', t) ? t[1] : 5                                    ;fdwQuality
                                            , 'UInt', 0                                                                                          ;fdwPitchAndFamily
                                            , 'UPtr', &FontName                                                                                  ;lpszFace
                                            , 'Ptr') )                                                                                           ;ReturnType
} ;https://msdn.microsoft.com/en-us/library/dd183499(v=vs.85).aspx




/*
    Recupera el nombre de la fuente especificada.
    Parámetros:
        hFont: El identificador de la fuente.
    Return:
        Si tuvo éxito devuelve el nombre de la fuente, caso contrario devuelve una cadena vacía.
*/
GetFontName(hFont)
{
    Local hDC, hObject, Buffer, Size

    If (!(hDC := DllCall('User32.dll\GetDC', 'Ptr', 0, 'Ptr')))
        Return ('')

    If ( !(hObject := DllCall('Gdi32.dll\SelectObject', 'Ptr', hDC, 'Ptr', hFont, 'Ptr'))
          || !(Size := DllCall('Gdi32.dll\GetTextFace', 'Ptr', hDC, 'Ptr', 0, 'Ptr', 0))  )
    {
        If (hObject)
            DllCall('Gdi32.dll\SelectObject', 'Ptr', hDC, 'Ptr', hObject, 'Ptr')
        DllCall('User32.dll\ReleaseDC', 'Ptr', 0, 'Ptr', hDC)
        Return ('')
    }

    VarSetCapacity(Buffer, Size * 2)

    Size := DllCall('Gdi32.dll\GetTextFace', 'Ptr', hDC, 'Ptr', Size, 'UPtr', &Buffer)
    
    DllCall('Gdi32.dll\SelectObject', 'Ptr', hDC, 'Ptr', hObject, 'Ptr')
    DllCall('User32.dll\ReleaseDC', 'Ptr', 0, 'Ptr', hDC)

    Return (Size ? StrGet(&Buffer, Size, 'UTF-16') : '')
} ;https://msdn.microsoft.com/en-us/library/dd144940(v=vs.85).aspx




/*
    Enumera todas las fuentes instaladas en el sistema.
    Parámetros:
        FontName / CharSet: Filtra las fuentes a este nombre y/o conjunto de caracteres especificado.
    Return:
        0       = Error.
        [array] = Si tuvo éxito devuelve un Array de objetos con la información de la fuente. Ver función EnumFontFamExProc para las claves disponibles.
    Ejemplo:
        Gui := GuiCreate(), List := {}
        LV  := Gui.AddListView('x0 y0 w950 h500 Sort', 'FaceName|Size|Style|Script')
        For Each, Font in EnumFontFamilies()
        {
            If (SubStr(Font.FaceName, 1, 1) == '@')
                Continue
            If (ObjHasKey(List, Font.FullName))
                LV.Modify(List[Font.FullName], 'Col4', LV.GetText(List[Font.FullName], 4) . ' | ' . Font.Script)
            Else
                RowNumber := LV.Add(, Font.FaceName, Font.Size, Font.Style, Font.Script)
            List[Font.FullName] := RowNumber
        }
        Loop (LV.GetCount('Col'))
            LV.ModifyCol(A_Index, 'AutoHdr')
        Gui.Show('w950 h500', 'EnumFontFamiliesExW'), List := ''
        WinWaitClose('ahk_id' . Gui.Hwnd)
        ExitApp
*/
EnumFontFamilies(FontName := '', CharSet := 1)
{
    Local hDC, LOGFONT, Address, Data

    If (!(hDC := DllCall('User32.dll\GetDC', 'Ptr', 0, 'Ptr')))
        Return (FALSE)

    VarSetCapacity(LOGFONT, 92, 0)
    NumPut(CharSet , &LOGFONT + 23, 'UChar')
    StrPut(FontName, &LOGFONT + 28, 'UTF-16')
    
    Address := RegisterCallback('EnumFontFamExProc',,, DllCall('Gdi32.dll\GetDeviceCaps', 'Ptr', hDC, 'Int', 90))
    Data    := []

    DllCall('Gdi32.dll\EnumFontFamiliesExW', 'Ptr' , hDC      ;hdc
                                           , 'UPtr', &LOGFONT ;lpLogfont
                                           , 'UPtr', Address  ;lpEnumFontFamExProc
                                           , 'UPtr', &Data    ;lParam
                                           , 'UInt', 0)       ;dwFlags

    DllCall('Kernel32.dll\GlobalFree', 'Ptr',  Address, 'Ptr')
    DllCall('User32.dll\ReleaseDC', 'Ptr', 0, 'Ptr', hDC)

    Return (Data.Length() ? Data : FALSE)
} ;https://msdn.microsoft.com/en-us/library/dd162620(v=vs.85).aspx

EnumFontFamExProc(LOGFONT, TEXTMETRIC, FontType, lParam)
{
    Object(lParam).Push({ Height        : NumGet(LOGFONT      , 'Int')    ;lfHeight
                        , Width         : NumGet(LOGFONT +   4, 'Int')    ;lfWidth
                        , Escapement    : NumGet(LOGFONT +   8, 'Int')    ;Escapement
                        , Orientation   : NumGet(LOGFONT +  12, 'Int')    ;lfOrientation
                        , Weight        : NumGet(LOGFONT +  16, 'Int')    ;lfWeight
                        , Italic        : NumGet(LOGFONT +  20, 'UChar')  ;lfItalic
                        , Underline     : NumGet(LOGFONT +  21, 'UChar')  ;lfUnderline
                        , Strike        : NumGet(LOGFONT +  22, 'UChar')  ;lfStrikeOut
                        , CharSet       : NumGet(LOGFONT +  23, 'UChar')  ;lfCharSet
                        , OutPrecision  : NumGet(LOGFONT +  24, 'UChar')  ;lfOutPrecision
                        , ClipPrecision : NumGet(LOGFONT +  25, 'UChar')  ;lfClipPrecision
                        , Quality       : NumGet(LOGFONT +  26, 'UChar')  ;lfQuality
                        , PitchAndFamily: NumGet(LOGFONT +  27, 'UChar')  ;lfPitchAndFamily
                        , FaceName      : StrGet(LOGFONT +  28, 'UTF-16') ;lfFaceName[LF_FACESIZE=32]
                        , FullName      : StrGet(LOGFONT +  92, 'UTF-16') ;elfFullName[LF_FULLFACESIZE=64]
                        , Style         : StrGet(LOGFONT + 220, 'UTF-16') ;elfStyle[LF_FACESIZE=32]
                        , Script        : StrGet(LOGFONT + 284, 'UTF-16') ;elfScript[LF_FACESIZE=32]

                        , FontType      : FontType                      ;FontType. 1=RASTER_FONTTYPE. 2=DEVICE_FONTTYPE. 4=TRUETYPE_FONTTYPE.

                        , Size          : Round((NumGet(TEXTMETRIC, 'Int') - NumGet(TEXTMETRIC + 12, 'Int')) * 72 / A_EventInfo) }) ;Height-InternalLeading

    Return (TRUE)
} ;https://msdn.microsoft.com/en-us/library/dd162618(v=vs.85).aspx




/*
    Calcula el ancho y el alto que requiere un texto para ser mostrado completamente en una fuente específica y recupera información adicional de la fuente.
    Parámetros:
        hFont : El identificador de la fuente.
        String: La cadena con el texto a medir.
    Return:
        Si tiene éxito devuelve un objeto con las siguientes claves:
            W / H                       = El ancho y alto respectivamente.
            Weight                      = El peso de la fuente. 400 es normal, 600 es semi-negrita y 700 es negrita.
            Italic / Underline / Strike = Determina si el formato de fuente es cursiva, subrayado o tachado respectivamente.
            Size                        = El tamaño de la fuente.
            CharSet                     = El conjunto de caracteres.
        Si hubo un error, devuelve 0.
    Nota:
        Si la fuente tiene subrayado, el alto recuperado pede que necesite incrementarse.
    Test:
        MsgBox(IsObject(GetFontTextSize(CreateFont(), 'Hola Mundo!')))
*/
GetFontTextSize(hFont, String)
{
    Local hDC, hObject, Size, TEXTMETRIC, n

    hDC     := DllCall('User32.dll\GetDC', 'Ptr', 0, 'Ptr')
    n       := DllCall('Gdi32.dll\GetDeviceCaps', 'Ptr', hDC, 'Int', 90)
    hObject := DllCall('Gdi32.dll\SelectObject', 'Ptr', hDC, 'Ptr', hFont, 'Ptr')
    If (!hObject || !(Size := GetTextExtentPoint(hDC, String)))
    {
        If (hObject)
            DllCall('Gdi32.dll\SelectObject', 'Ptr', hDC, 'Ptr', hObject, 'Ptr')
        DllCall('User32.dll\ReleaseDC', 'Ptr', 0, 'Ptr', hDC)
        Return (FALSE)
    }

    VarSetCapacity(TEXTMETRIC, 57, 0)
    DllCall('Gdi32.dll\GetTextMetricsW', 'Ptr', hDC, 'UPtr', &TEXTMETRIC)

    DllCall('Gdi32.dll\SelectObject', 'Ptr', hDC, 'Ptr', hObject, 'Ptr')
    DllCall('User32.dll\ReleaseDC', 'Ptr', 0, 'Ptr', hDC)

    Return ({ Size     : Round((NumGet(&TEXTMETRIC, 'Int') - NumGet(&TEXTMETRIC + 12, 'Int')) * 72 / n)
            , W        : NumGet(&TEXTMETRIC + 20, 'Int')   + Size.W
            , H        : NumGet(&TEXTMETRIC     , 'Int')   + NumGet(&TEXTMETRIC + 16, 'Int')
            , Weight   : NumGet(&TEXTMETRIC + 28, 'Int')
            , Italic   : NumGet(&TEXTMETRIC + 52, 'UChar')
            , Underline: NumGet(&TEXTMETRIC + 53, 'UChar')
            , Strike   : NumGet(&TEXTMETRIC + 54, 'UChar')
            , CharSet  : NumGet(&TEXTMETRIC + 56, 'UChar') })
}




/*
    Calcula el ancho y el alto de la cadena especificada.
    Parámetros:
        hDC   : El identificador al contexto de dispositivo.
        String: La cadena de texto.
    Return:
        0     = Error.
        [obj] = Si tuvo éxito devuelve un objeto con las claves W y H.
*/
GetTextExtentPoint(hDC, String)
{
    Local SIZE

    String .= ''
    VarSetCapacity(SIZE, 8)

    If (!DllCall('Gdi32.dll\GetTextExtentPoint32W', 'Ptr' , hDC            ;hdc
                                                  , 'UPtr', &String        ;lpString
                                                  , 'Int' , StrLen(String) ;c
                                                  , 'UPtr', &SIZE))        ;lpSize
        Return (FALSE)

    Return ({ W: NumGet(&SIZE    , 'Int')
            , H: NumGet(&SIZE + 4, 'Int') })
} ;https://msdn.microsoft.com/en-us/library/dd144938(v=vs.85).aspx




/*
    Clona una fuente.
    Parámetros:
        hFont: El identificador de la fuente.
    Return:
        Si tuvo éxito devuelve el identificador de la nueva fuente, caso contrario devuelve 0.
*/
CloneFont(hFont)
{
    Local LOGFONT, Size

    VarSetCapacity(LOGFONT, 92, 0)
    If (!(Size := DllCall('Gdi32.dll\GetObjectW', 'Ptr', hFont, 'Int', 0, 'Ptr', 0, 'UInt')))
        Return (FALSE)
    
    DllCall('Gdi32.dll\GetObjectW', 'Ptr', hFont, 'Int', Size, 'UPtr', &LOGFONT, 'UInt')

    Return (DllCall('Gdi32.dll\CreateFontIndirect', 'UPtr', &LOGFONT, 'Ptr'))
}
