#Include ..\gdiplus\ImageButton.ahk

/*
    Crea una ventana de mensaje cerca del icono de la bandeja o área de notificación.
    Parámetros:
        Title  : El título a mostrar en el diálogo.
        Message: El mensaje para el usuario.
        Icon   : El icono a mostrar. Puede ser la ruta a un archivo o el identificador a un icono o bitmap.
        Options: Especifica una cadena con una o más de las palabras claves descritas a continuación.
            wN / hN  = Las dimensiones de la ventana. Si no se especifica, se calcula automáticamente.
            IconN    = Si se especifica un archivo que contiene iconos en “Icon”, especifica el índice. Por defecto es 1.
            tN       = El tiempo, en milisegundos, que deben pasar para que la ventana se destruya automáticamente. Por defecto no se establece.
            OwnerN   = El identificador de la ventana propietaria. Por defecto es 0.
    Observaciones:
        Si se especifico un tiempo fuera, la ventana no será destruida en caso de que el cursor se encuentre sobre ella.
    Ejemplo:
        TrayTipEx('TrayTipEx Window Title! #1', '<A HREF="https://autohotkey.com">Visita AutoHotkey.com</A>', A_WinDir . '\explorer.exe')
        TrayTipEx('TrayTipEx Window Title! #2', 'TrayTipEx Window Text!.', A_WinDir . '\regedit.exe', 't3')
        TrayTipEx('TrayTipEx Window Title! #3', 'TrayTipEx Window Text!.', A_ComSpec)
*/
TrayTipEx(Title, Message, Icon := '', Options := ''){

    Static TrayTips := {}    ; almacena todos los TrayTips activos, la clave es el identificador de la ventana y su valor el objeto GUI

    ; sumamos el alto de todas las ventanas TrayTips existentes +2xC/U para luego calcular la posición «Y» de la nueva ventana TrayTip para que no tape a las ya existentes
    Local X := 0, Y := 0
    For WindowId, GuiObj in TrayTips
        Y += GuiObj.ClientPos.H + 2    ; 2 = separación vertical entre cada ventana TrayTip

    ; comprobamos el parámetro «Icon»
    Local HICON := Icon is 'Number' ? Icon : 0
    If (!HICON && (!FileExist(Icon) || DirExist(Icon)))
        Icon := A_IsCompiled ? A_ScriptFullPath : A_AhkPath

    ; recuperamos las opciones
    Local M
        , W         := RegExMatch(Options, 'i)W([\-\d\.]+)(p*)'    , M) ? M[1]            : SysGet(78) // 100 * 40    ; 40% del ancho total
        , H         := RegExMatch(Options, 'i)H([\-\d\.]+)(p*)'    , M) ? M[1]            : SysGet(79) // 100 * 15    ; 15% del alto total
        , Timeout   := RegExMatch(Options, 'i)T([\-\d\.]+)(p*)'    , M) ? M[1]            : 0                         ; el tiempo fuera | 0 = sin
        , IconIndex := RegExMatch(Options, 'i)Icon([\-\d\.]+)(p*)' , M) ? M[1]            : 1                         ; el índice del icono
        , Owner     := RegExMatch(Options, 'i)Owner([\-\d\.]+)(p*)', M) ? ' Owner' . M[1] : ''                        ; el identificador de la ventana propietaria
    Local ImageType := HICON ? (DllCall('Gdi32.dll\GetObjectType', 'Ptr', HICON, 'UInt') == 7 ? 'HBITMAP' : 'HICON') : ''    ; OBJ_BITMAP = 7
    IconIndex := HICON ? '' : ' Icon' . IconIndex

    ; creamos el GUI | nuestra nueva ventana TrayTip :)
    Local Gui := GuiCreate('-DPIScale +ToolWindow -Caption +AlwaysOnTop' . Owner)
    TrayTips[Gui.Hwnd] := Gui    ; añadimos el GUI a la lista
    Gui.BackColor := 0x282828    ; el color de fondo (oscuro =D)
    Gui.SetFont('s9 q5', 'Segoe UI')    ; cambiamos la fuente
    Gui.AddPic('x8 y8 w70 h70 vpic' . IconIndex, HICON ? '*' . ImageType . ':' . HICON : Icon)    ; añadimos la imagen/icono a mostrar
    Gui.AddLink('x87 y32 w' . (W-51) . ' h' . (H-30) . ' vmsg c0xFFFFFF', Trim(Message, '`r`n`t '))    ; añadimos el mansaje para el usuario
    Gui.AddButton('x' . (W-25) . ' y2 w24 h24 vx', 'X')
    ImageButton.Create(Gui.Control['x'].Hwnd, [0, 0x282828,  'Black', 0xDFDFFF, 2, 0x282828, 0x282828, 1]
                                            , [0, 0x282828, 0x3C3C3C, 0xFF0000, 2, 0x282828, 0x282828, 1]
                                            , [0, 0x282828, 0x464646, 0xFF0000, 2, 0x282828, 0x282828, 1]
                                            , [0, 0xCCCCCC,  'Black', 0x4A4A4A, 2, 0x282828, 0xA7B7C9, 1]
                                            , [0, 0x282828,  'Black', 0xDFDFFF, 2, 0x282828, 0x282828, 2]
                                            , [0, 0x282828,  'Black', 0xFF0000, 2, 0x282828, 0x282828, 1] )    ; establecemos el estilo del botón cerrar X
    Gui.AddText('x1 y1 w' . (W-1) . ' h' . (H-1) . ' Border BackGroundTrans')    ; añadimos un fino borde a la ventana
    Gui.SetFont('s10 Bold', 'Segoe Print')    ; cambiamos la fuente
    Gui.AddText('x87 y8 w' . (W-125) . ' h22 c0x0080FF', Trim(Title))    ; añadimos el título

    SoundPlay(A_WinDir . '\media\notify.wav')    ; reproducimos un sonido para alertar al usuario del TrayTip

    ; recuperamos las dimensiones del monitor donde se visualiza la ventana TrayTip y las utilizamos para ajustar las coordenadas X,Y
    Local MONITORINFO
    NumPut(VarSetCapacity(MONITORINFO, 40, 0), &MONITORINFO, "UInt")
    DllCall('User32.dll\GetMonitorInfoW', 'Ptr', DllCall('User32.dll\MonitorFromWindow', 'Ptr', Gui.Hwnd, 'UInt', 2, 'Ptr'), 'Ptr', &MONITORINFO)
    Local W2 := NumGet(&MONITORINFO + 28, 'Int')
        , H2 := NumGet(&MONITORINFO + 32, 'Int')
    X := W2 - W - 5, Y := H2 - H - 5 - Y

    Gui.Show('x' . X . ' y' . Y . ' w' . W . ' h' . H . ' Hide')    ; establecemos la posición y dimensiones de la ventana TrayTip
    DllCall('User32.dll\AnimateWindow', 'Ptr', Gui.Hwnd, 'UInt', 500, 'UInt', 0xA0000)    ; mostramos la ventana con una animación de 500 milisegundos
    WinSetRegion('1-1 w' . W . ' h' . H . ' r6-6', 'ahk_id' . Gui.Hwnd)    ; redondeamos las puntas de la ventana
    WinSetTransparent(240, "ahk_Id" . Gui.Hwnd)    ; añadimos un poco de transparencia a la ventana (WINAPI::AnimateWindow no funciona bien si la ventana es transparente)
    WinRedraw('ahk_Id' . Gui.Hwnd)    ; redibujamos toda la ventana ya que la función WINAPI::AnimateWindow a veces causa que los controles se visualizen mal

    ; establecemos datos comunes que serán pasados a las funciónes asociadas a la ventana TrayTip
    Local Data := {TrayTips: TrayTips, Gui: Gui, TimeoutFunc: 0, X: X, H: H2}

    ; establecemos el tiempo fuera, si se especificó
    If (Timeout)
        SetTimer(Data.TimeoutFunc := Func('TrayTipEx_Timeout').Bind(Data), Timeout * -1000)

    ; establecemos algunos eventos de la ventana y controles
    Gui.OnEvent('Close', Func('TrayTipEx_Close').Bind(Data))    ; al cerrar la ventana
    Gui.Control['X'].OnEvent('Click', Func('TrayTipEx_Close').Bind(Data))    ; al cerrar la ventana desde el botón X
    Gui.Control['pic'].OnEvent('Click', 'TrayTipEx_Move')    ; permite mover la ventana arrastrando la imagen/icono

    ; devolvemos el objeto GUI
    Return Gui
}

TrayTipEx_Move(CtrlObj){
    DllCall('User32.dll\PostMessageW', 'Ptr', CtrlObj.Gui.Hwnd, 'UInt', 0x00A1, 'UInt', 2, 'Ptr', 0)    ; permite mover la ventana arrastrando el control especificado (CtrlObj::pic)
}

TrayTipEx_Timeout(Data){
    Critical    ; previene que el thread actual sea interrumpido por otro, esto evita mensajes de error al manipular el objeto GUI
    ; evitamos cerrar la ventana si el cursor se encuentra sobre ella con un retraso de 500 milisegundos
    Local WindowId
    Loop
        MouseGetPos(,, WindowId), Sleep(500)
    Until (WindowId != Data.Gui.Hwnd)

    TrayTipEx_Close(Data)    ; cerramos la ventana
}

TrayTipEx_Close(Data) {   ; EN FUTURAS ACTUALIZACIÓNES SE MEJORARÁ EL ALGORITMO PARA RE-UBICAR LAS VENTANAS TRAYTIPS AL ELIMINAR UNA

    Critical    ; previene que el thread actual sea interrumpido por otro, esto evita mensajes de error al manipular el objeto GUI
    If (IsObject(Data.TimeoutFunc))    ; al cerrar la ventana, comprobamos si se ha establecido un tiempo fuera, si es así, lo eliminamos y liberamos el objeto Func()
        SetTimer(Data.TimeoutFunc, 'Delete')

    Data.TrayTips.Delete(Data.Gui.Hwnd)    ; eliminamos esta ventana de la lista de TrayTips
    Try    ; evitamos mostrar un error si la ventana ya ha sido destruida
    {
        WinSetTransparent('Off', 'ahk_id' . Data.Gui.Hwnd)    ; quitamos la transparencia para evitar el mal funcionamiento de WINAPI::AnimateWindow
        DllCall('User32.dll\AnimateWindow', 'Ptr', Data.Gui.Hwnd, 'UInt', 500, 'UInt', 0x90000)    ; ocultamos la ventana con una animación de 500 milisegundos
        Data.Gui.Destroy()    ; destruimos la ventana
    }

    ; al eliminar la ventana, debemos acomodar a todas las demás ventanas TrayTips para que alguna, si la hay, ocupe su lugar
    Local NY, ClientPos, Y := 0    ; 'Y' almacena la suma de la altura de cada ventana TrayTip en el bucle For
    For WindowId, Gui in Data.TrayTips    ; buscamos en todas las ventanas TrayTips existentes
    {
        ClientPos := Gui.ClientPos    ; almacena las dimensiones de la ventana TrayTip actual (sin incluir barra de título y bordes)
        NY := Data.H - 5 - ClientPos.H - Y    ; 'Data.H' contiene la altura del monitor donde se visualizan las ventanas TrayTips para este Script
                                              ; '5' representa el espaciado entre la ventana más próxima a la parte inferior de la pantalla (para que no quede fea pegada con el límite del monitor)
                                              ; 'ClientPos.H' representa la altura de la ventana TrayTip actual en el bucle For
                                              ; 'Y' contiene la suma de la altura de todas las ventanas TrayTips anteriores, para evitar taparlas y acomodarlas correctamente
                                              ; Todo esto da como resultado la posición 'Y' nueva para esta ventana TrayTip que será almacenada en la variable 'NY'
        Loop    ; ajustamos la posición de la ventana moviendola de a 1 pixel para dar un efecto de 'animación'
            Gui.Show('y'  . ((ClientPos.Y > NY)     ? (ClientPos.Y -= 1) : (ClientPos.Y < NY)     ? (ClientPos.Y += 1) : ClientPos.Y)
                   . ' x' . ((ClientPos.X > Data.X) ? (ClientPos.X -= 1) : (ClientPos.X < Data.X) ? (ClientPos.X += 1) : ClientPos.X))
          , Sleep(!Mod(A_Index, 10))    ; retraso (para la 'animación')
        Until (ClientPos.Y == NY && ClientPos.X == Data.X)
        Y += ClientPos.H + 2
    }
}
