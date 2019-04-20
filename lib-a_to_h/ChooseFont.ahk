/*
Muestra un diálogo para pedirle al usuario que selecciona fuente y color.
Parámetros:
    Owner: El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
    FontName: El nombre de la fuente seleccionada por defecto.
    Options: Opciones para este diálogo. Este parámetro debe ser una cadena con una o más de las siguientes palabras:
        sN                                   = Número entero que reprecenta el tamaño del texto.
        Bold / Italic / Underline / strike   = El estilo del texto. Negrita, cursiva, subrayado, tachado; respectivamente.
        wN                                   = El peso del texto. 400 es normal. 600 es semi-negrita. 700 es negrita.
        cN                                   = El color RGB del texto.
        csN                                  = El conjunto de caracteres.
    Flags: Otras opciones. Espesificar uno o más de los siguientes valores:
        0x00000200 = Muestra el botón Aplicar.
        0x00000004 = Muestra el botón Ayuda.
        0x00040000 = Muestra únicamente las fuentes de tipo 'TrueType'.
        0x00004000 = Muestra las fuentes 'fixed-pitch'.
        0x02000000 = Muestra las fuentes marcadas como ocultas en el panel de control.
        0x01000000 = El diálogo no muestra fuentes orientadas de forma vertical.
        0x00000100 = Habilita el subrayado, tachado y seleccion de color. Este es el valor por defecto.
        0x00010000 = La fuente debe existir. Este es el valor por defecto.
*/
ChooseFont(Owner := 0, FontName := "Arial", Options := "", Flags := 0x10100)
{
    hDC         := DllCall("Gdi32.dll\CreateDCW", "Str", "DISPLAY", "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
    LogPixelsY  := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hDC, "Int", 90)
    DllCall("Gdi32.dll\DeleteDC", "Ptr", hDC)

    Size        := RegExMatch(Options, "i)s([\-\d\.]+)(p*)", t)     ? Round((t.1 * LogPixelsY) / 72)    : Round((10 * LogPixelsY) / 72)
    Weight      := RegExMatch(Options, "i)w([\-\d\.]+)(p*)", t)     ? t.1                               : (InStr(Options, "Bold") ? 700 : 400)
    CharSet     := RegExMatch(Options, "i)cs([\-\d\.]+)(p*)", t)    ? t.1                               : 1
    Color       := RegExMatch(Options, "i)c([\-\d\.xa-f]+)(p*)", t) ? t.1+0                             : 0x000000
    Flags       |= 0x00000041

    VarSetCapacity(LOGFONT, 92, 0)
    NumPut(Size, LOGFONT, 0, "Int")
    NumPut(Weight, LOGFONT, 16, "Int")
    NumPut(!!InStr(Options, "Italic"), LOGFONT, 20, "UChar")
    NumPut(!!InStr(Options, "Underline"), LOGFONT, 21, "UChar")
    NumPut(!!InStr(Options, "Strike"), LOGFONT, 22, "UChar")
    NumPut(CharSet, LOGFONT, 23, "UChar")
    StrPut(FontName, &LOGFONT + 28, StrLen(FontName) + 1, "UTF-16")

    NumPut(VarSetCapacity(CHOOSEFONT, A_PtrSize = 8 ? 104 : 60, 0), CHOOSEFONT, 0, "UInt")
    NumPut(Owner, CHOOSEFONT, A_PtrSize, "Ptr")
    NumPut(&LOGFONT, CHOOSEFONT, 3*A_PtrSize, "Ptr")
    NumPut(Flags, CHOOSEFONT, 4*A_PtrSize + 4, "UInt")
    NumPut(((Color & 255) << 16) | (((Color >> 8) & 255) << 8) | (Color >> 16), CHOOSEFONT, 4*A_PtrSize + 2*4, "UInt")

    If (DllCall("comdlg32.dll\ChooseFontW", "Ptr", &CHOOSEFONT))
    {
        Font            := {}
        Font.Color      := Format("0x{:06X}", ((BGR:=NumGet(CHOOSEFONT, 4*A_PtrSize + 2*4, "UInt")) & 255) << 16 | (BGR & 65280) | (BGR >> 16))
        Font.Size       := NumGet(CHOOSEFONT, A_PtrSize=8?32:16, "Int") // 10
        Loop Parse, "Height.Width.Escapement.Orientation.Weight.Italic", "."
            Font[A_LoopField]   := NumGet(LOGFONT, (A_Index - 1) * 4, A_Index == 6 ? "UChar" : "Int")
        Loop Parse, "Underline.Strike.CharSet.OutPrecision.ClipPrecision.Quality.PitchAndFamily", "."
            Font[A_LoopField]   := NumGet(LOGFONT, 20 + A_Index, "UChar")
        Font.FontName   := StrGet(&LOGFONT + 28)
        Font.Bold       := Font.Weight == 700
    }

    Return (IsObject(Font) ? Font : FALSE)
}