#Include <gdiplus\ImageButton>

/*
    Muestra un diálogo para pedirle al usuario que ingrese una cadena.
    Parámetros:
        Owner  : El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
        Title  : El título de la ventana.
        Prompt : El Texto que suele ser un mensaje al usuario indicando que tipo de 'cosa' se espera que introduzca. Este es un control 'Link'.
        Default: El texto que aparecerá por defecto. Este es un control 'Edit'.
        Options: Opciones para este diálogo. Este parámetro debe ser una cadena con una o más de las siguientes palabras:
            xN / yN / wN / hN    = Las coordenadas y dimenciones de la ventana. Si no se especifica, se calcula automáticamente.
            NoPrompt             = Reemplaza el control 'Link' de Prompt y el control Edit de 'Default' por un control Edit multi-línea.
            Number               = Limita el texto que el usuario puede introducir a solo números.
            Password             = Utiliza el modo contraseña.
            ReadOnly             = Establece el control Edit a solo-lectura.
    Return:
        Si tuvo éxito y el usuario aceptó el diálogo devuelve el texto introducido por el usuario, caso contrario devuelve una cadena vacía.
    ErrorLevel:
        Si el usuario aceptó el diálogo se establece en 0, caso contrario se establece en 1. Si hubo un error se establece en 2.
*/
InputBox(Owner := 0, Title := '', Prompt := '', Default := '', Options := '')
{
    Local X               := RegExMatch(Options, 'i)X([\-\d\.]+)(p*)', t) ? ' x' . t.1  : ''
        , Y               := RegExMatch(Options, 'i)Y([\-\d\.]+)(p*)', t) ? ' y' . t.1  : ''
        , W               := RegExMatch(Options, 'i)W([\-\d\.]+)(p*)', t) ? t.1         : SysGet(78) // 100 * 40 ;W: 40%
        , H               := RegExMatch(Options, 'i)H([\-\d\.]+)(p*)', t) ? t.1         : SysGet(79) // 100 * 37 ;H: 37%
        , Number          := InStr(Options, 'Number')                     ? ' Number'   : ''
        , Password        := InStr(Options, 'Password')                   ? ' Password' : ''
        , ReadOnly        := InStr(Options, 'ReadOnly')                   ? ' ReadOnly' : ''
        , ButtonStyle     := [[0, 0x7E8DB6, 'Black', 0x242424, 2, 0x282828, 0x242424, 1], [5, 0x8392B8, 0x98A5C5, 0x242424, 2, 0x282828, 0x242424, 1], [5, 0x8392B8, 0xA9B5CF, 0x242424, 2, 0x282828, 0x242424, 1], [0, 0xCCCCCC, 'Black', 0x4A4A4A, 2, 0x282828, 0xA7B7C9, 1], [0, 0x7E8DB6, 'Black', 0x242424, 2, 0x282828, 0x404040, 2], [5, 0x8392B8, 0x98A5C5, 0x242424, 2, 0x282828, 0x242424, 1]]

    If (Owner)
    {
        Local nX, nY, nW, nH
        WinGetPos(nX, nY, nW, nH, 'ahk_id' . Owner)
        If (ErrorLevel && (ErrorLevel := 2))
            Return ('')

        nX += 5, nY += 1
        If (X == '')
            X := ' x' . (nX+W > SysGet(78) ? SysGet(78) - W : nX)
        If (Y == '')
            Y := ' y' . (nY+H > SysGet(79) ? SysGet(79) - H : nY)
    }

    Local g     := GuiCreate('-ToolWindow' . (Owner ? ' +Owner' . Owner : ''), Title)
    g.BackColor := 0x282828
    g.SetFont('s10 Italic q5', 'Segoe UI')

    if (InStr(Options, 'NoPrompt'))
        Local oEdit := g.AddEdit('x5 y5 w' . (W-10) . ' h' . (H-40) . ' WantTab T8 -Wrap c0x8694B9 Background0x282828 Multi HScroll -E0x200 Border' . ReadOnly)
    Else
    {
        Local oInfo := g.AddText('x5 y5 w' . (W-10) . ' h' . H-65 . ' c0x8694B9 BackgroundTrans', Prompt)
            , oEdit := g.AddEdit('x5 y' . (H-60) . ' w' . (W-10) . ' h25 WantTab T8 c0x8694B9 Background0x282828 -Multi -E0x200 Border' . ReadOnly . Number . Password, Default)
        DllCall('User32.dll\SendMessageW', 'Ptr', oEdit.hWnd, 'UInt', 0x1501, 'Int', TRUE, 'Str', Default) ;EM_SETCUEBANNER
    }

    Local oCancel := g.AddButton('x' . (W-105) . ' y' . (H-30) . ' w100 h25', 'Cancelar')
    ImageButton.Create(oCancel.hWnd, ButtonStyle*)

    Local oAccept := g.AddButton('x' . (W-210) . ' y' . (H-30) . ' w100 h25 Default', 'Aceptar')
    ImageButton.Create(oAccept.hWnd, ButtonStyle*)

    g.Show(x . y . ' w' . W . ' h' . H)

    Local Data := {Text: '', Error: TRUE, g: g, oEdit: oEdit}
    g.OnEvent('Close', Func('InputBox_Close').Bind(Data, TRUE))
    g.OnEvent('Escape', Func('InputBox_Close').Bind(Data, TRUE))
    oCancel.OnEvent('Click', Func('InputBox_Close').Bind(Data, TRUE))
    oAccept.OnEvent('Click', Func('InputBox_Close').Bind(Data, FALSE))

    WinWaitClose('ahk_id' . g.hWnd)
    ErrorLevel := Data.Error
    Return (ErrorLevel ? '' : Data.Text)
}




InputBox_Close(Data, Error)
{
    If (!(Data.Error := Error))
        Data.Text := Data.oEdit.Text
    Data.g.Destroy()
}
