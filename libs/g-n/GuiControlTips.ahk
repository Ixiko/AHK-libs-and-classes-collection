/*
    Crea ToolTip's personalizados para controles. Permite modificar el texto, título, ícono y fuente.
    CREDITS: JUSTME - http://ahkscript.org/boards/viewtopic.php?f=6&t=2598.
    Ejemplo:
        oGui    := GuiCreate('+AlwaysOnTop')
            CTT := New GuiControlTips(oGui)
            CTT.SetTitle('GuiControlsTips', 1)
            CTT.SetFont('Italic', 'Courier New')

        oButton := oGui.AddButton('w200', 'Button')
            CTT.Attach(oButton, 'My Button')

        oText   := oGui.AddText('w200 Border', 'Text!`nLine 2 ...')
            CTT.Attach(oText, 'My Text`nMultiline ...')

        oDDL    := oGui.AddDDL('w200 R3', 'Item 1||Item 2|Item 3')
            CTT.Attach(oDDL, 'My DDL')

        oGui.Show()
        WinWaitClose('ahk_id' . oGui.hWnd)
        ExitApp

        F1::CTT.Suspend('Toggle')
*/
class GuiControlTips ;WIN_V+
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    hTip        := 0                        ;El identificador de la ventana ToolTip.                                  
    hGui        := 0                        ;El identificador de la ventana GUI.
    List        := {}                       ;Objeto con los controles e información.
    IsSuspended := FALSE                    ;Determina si el ToolTip esta desactivado.
    
    
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Parámetros:
            hGui: El identificador u objeto de la ventana GUI.
            Initial: El tiempo, en milisegundos, que deberá pasar para que el ToolTip se muestre.
            AutoPop: El tiempo, en milisegundos, que el ToolTip permanece visible si el cursor está dentro del rectángulo delimitador del control.
            ReShow: El tiempo, en milisegundos, que requiere el ToolTip posterior para aparecer cuando el cursor se mueve de un control a otro.
    */
    __New(hGui, Initial := 1500, AutoPop := 5000, ReShow := 1000)
    {
        If (!IsObject(GuiFromhWnd(This.hGui := (IsObject(hGui) ? hGui.hWnd : hGui) + 0)))
            Return (FALSE)

        If (!(This.hTip := DllCall('User32.dll\CreateWindowEx', 'UInt', 0x00000008, 'Str', 'tooltips_class32', 'Ptr', 0, 'UInt', 0x80000002, 'Int', 0x80000000, 'Int', 0x80000000, 'Int', 0x80000000, 'Int', 0x80000000, 'Ptr', This.hGui, 'Ptr', 0, 'Ptr', 0, 'Ptr', 0, 'Ptr')))
            Return (FALSE)

        DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0418, 'Ptr', 0, 'Int', 0) ;TTM_SETMAXTIPWIDTH
        This.SetDelayTimes(Initial, AutoPop, ReShow)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632680(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        Local hFont

        If (hFont := DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0031, 'Ptr', 0, 'Ptr', 0, 'Ptr'))
            DllCall('Gdi32.dll\DeleteObject', 'Ptr', hFont)
        
        DllCall('User32.dll\DestroyWindow', 'Ptr', This.hTip)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632682(v=vs.85).aspx
   
   
    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Añadir un ToolTip al control especificado en este GUI. Si el control ya tiene un ToolTip asignado, se actualiza con la información especificada.
        Parámetros:
            ControlId: El identificador u objeto del control.
            Text: El texto a mostrar en el ToolTip.
            Center: Determina si el ToolTip deberá aparecer centrado con respecto al control.
        Return: Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    */
    Attach(ControlId, Text, Center := FALSE)
    {
        Local hGui := IsObject(ControlId)  ? ControlId.Gui.hWnd + 0 : DllCall('User32.dll\GetAncestor', 'Ptr', ControlId, 'UInt', 1, 'Ptr')

        ControlId := (IsObject(ControlId) ? ControlId.hWnd         : ControlId) + 0
        
        If (hGui != This.hGui)
            Return (FALSE)

        If (This.List.HasKey(ControlId))
            This.Update(ControlId, Text)
        Else
        {
            Text    .= ''
            If (WinGetClass('ahk_id' . ControlId) == 'Static')
                WinSetStyle('+0x100', 'ahk_id' . ControlId)

            NumPut(VarSetCapacity(TOOLINFO, 6*4 + 6*A_PtrSize, 0), &TOOLINFO, 'UInt')
            NumPut(0x0001 | 0x0010 | (Center ? 0x0002 : 0), &TOOLINFO + 4              , 'UInt')
            NumPut(This.hGui                              , &TOOLINFO + 2*4            , 'Ptr')
            NumPut(ControlId                              , &TOOLINFO + 2*4 + A_PtrSize, 'Ptr')
            NumPut(&Text                                  , &TOOLINFO + 2*4 + 2*A_PtrSize + 16 + A_PtrSize)

            If (!DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0432, 'Ptr', 0, 'UPtr', &TOOLINFO)) ;TTM_ADDTOOL
                Return (FALSE)

            ObjRawSet(This.List, ControlId, 0)
        }

        Return (TRUE)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb760338(v=vs.85).aspx
    
    /*
        Remueve el ToolTip asignado al control especificado.
        Parámetros:
            ControlId: El identificador u objeto del control.
        Return: Si tuvo éxito devuelve 1, caso contrario devuelve 0. Si ControlId no es un control válido o no tiene un ToolTip asignado, devuelve 0.
    */
    Detach(ControlId)
    {
        If (!This.List.HasKey(ControlId := (IsObject(ControlId) ? ControlId.hWnd : ControlId) + 0))
            Return (FALSE)

        If (WinGetClass('ahk_id' . ControlId) == 'Static')
            WinSetStyle('-0x100', 'ahk_id' . ControlId)

        NumPut(VarSetCapacity(TOOLINFO, 6*4 + 6*A_PtrSize, 0), &TOOLINFO, 'UInt')
        NumPut(0x0001 | 0x0010, &TOOLINFO + 4, 'UInt')
        NumPut(This.hGui, &TOOLINFO + 2*4, 'Ptr')
        NumPut(ControlId, &TOOLINFO + 2*4 + A_PtrSize, 'Ptr')

        DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0433, 'Ptr', 0, 'UPtr', &TOOLINFO) ;TTM_DELTOOL
        ObjDelete(This.List, ControlId)

        Return (TRUE)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb760365(v=vs.85).aspx

    /*
    Cambia el texto del ToolTip que pertenece al control especificado.
    Parámetros:
        ControlId: El identificador u objeto del control.
        NewText: El nuevo texto para este ToolTip.
    Return: Si tuvo éxito devuelve 1, caso contrario devuelve 0. Si ControlId no es un control válido o no tiene un ToolTip asignado, devuelve 0.
    */
    Update(ControlId, NewText)
    {
        If (!This.List.HasKey(ControlId := (IsObject(ControlId) ? ControlId.hWnd : ControlId) + 0))
            Return (FALSE)

        NewText .= ''

        NumPut(VarSetCapacity(TOOLINFO, 6*4 + 6*A_PtrSize, 0), &TOOLINFO, 'UInt')
        NumPut(0x0001 | 0x0010, &TOOLINFO + 4, 'UInt')
        NumPut(This.hGui, &TOOLINFO + 2*4, 'Ptr')
        NumPut(ControlId, &TOOLINFO + 2*4 + A_PtrSize, 'Ptr')
        NumPut(&NewText, &TOOLINFO + 2*4 + 2*A_PtrSize + 16 + A_PtrSize)

        DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0439, 'Ptr', 0, 'UPtr', &TOOLINFO) ;TTM_UPDATETIPTEXT

        return (TRUE)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb760427(v=vs.85).aspx
    
    /*
        Suspende, reanuda o alterna el estado actual de todos los ToolTips.
        Parámetros:
            Mode: Debe espesificar una de las siguientes palabras o valores:
                1  / On     = Suspende todos los ToolTips.
                0  / Off    = Reanuda todos los ToolTips.
                -1 / Toggle = Alterna el estado actual.
    */
    Suspend(Mode := 'On')
    {
        Mode := Mode = 'Toggle' ? -1 : Mode = 'On' ? 1 : Mode = 'Off' ? 0 : Mode
        Mode := Mode == -1 ? !(This.IsSuspended := !This.IsSuspended) : !(this.IsSuspended := !!Mode)

        DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0401, 'Int', Mode, 'Ptr', 0) ;TTM_ACTIVATE
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb760326(v=vs.85).aspx
    
    /*
        Establece los tiempos de retraso de todos los ToolTips.
        Parámetros:
            Initial: El tiempo, en milisegundos, que deberá pasar para que el ToolTip se muestre.
            AutoPop: El tiempo, en milisegundos, que el ToolTip permanece visible si el cursor está dentro del rectángulo delimitador del control.
            ReShow: El tiempo, en milisegundos, que requiere el ToolTip posterior para aparecer cuando el cursor se mueve de un control a otro.
        Nota: Si se especifica una cadena vacía el valor actual no es modificado.
    */
    SetDelayTimes(Initial := '', AutoPop := '', ReShow := '')
    {
        If (Initial != '')
            DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0403, 'Ptr', 3, 'Ptr', Initial)

        If (AutoPop != '')
            DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0403, 'Ptr', 2, 'Ptr', AutoPop)

        If (ReShow != '')
            DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0403, 'Ptr', 1 , 'Ptr', ReShow)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb760404(v=vs.85).aspx
    
    /*
        Recupera los tiempos de retraso de todos los ToolTips.
        Return: Devuelve un objeto con las claves Initial, AutoPop y ReShow. Ver el método SetDelayTimes para la descripción de las claves.
    */
    GetDelayTimes()
    {
        Return ({Initial:  DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0415, 'UInt', 3, 'Ptr', 0)
               , AutoPop:  DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0415, 'UInt', 2, 'Ptr', 0)
               , ReShow :  DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0415, 'UInt', 1, 'Ptr', 0)})
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb760390(v=vs.85).aspx

    /*
        Cambia el título y el icono mostrado en este ToolTip.
        Parámetros:
            NewTitle: El nuevo título. Si este parámetro es una cadena vacía, el título es removido.
            Icon: Un valor que identifica al icono a mostrar. Este parámetro puede ser un identificador a un icono. Si este valor es 0, el icono no es mostrado.
                1 / 4 = Icono de información pequeño/grande.
                2 / 5 = Icono de advertencia pequeño/grande.
                3 / 6 = Icono de error pequeño/grande. 
    */
    SetTitle(NewTitle, Icon := 0)
    {
        DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0421, 'UInt', Icon, 'Str', NewTitle)
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb760414(v=vs.85).aspx

    /*
        Cambia la fuente del texto de este ToolTip.
        Parámetros:
            Options: Las opciones de la fuente. Debe especificar una cadena con una o más de las siguientes palabras claves:
                sN                                 = El tamaño del texto. Por defecto es 9.
                qN                                 = La calidad de la fuente. Por defecto es 5 (ClearType).
                wN                                 = El peso del texto. 400 es normal, 600 es semi-negrita, 700 es negrita. Por defecto es 400.
                Italic / Underline / Strike / Bold = El estilo de la fuente. Cursiva / Subrayado / Tachado / Negrita.
            FontName: El nombre de la fuente. Si este parámetro es una cadena vacía, la fuente actual es removida y se reestablece a la fuente original.
        Nota: Si especifica el peso del texto (wN), 'Bold' no tiene efecto; ya que 'Bold' hace que wN sea 700 (negrita).
    */
    SetFont(Options := '', FontName := 'Segoe UI')
    {
        Local hFont, hDC, R, Size, Height, Quality, Weight, Italic, Underline, Strike

        If (hFont := DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0031, 'Ptr', 0, 'Ptr', 0, 'Ptr'))
            DllCall('Gdi32.dll\DeleteObject', 'Ptr', hFont)

        If (FontName == '')
            DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0030, 'Ptr', 0, 'Int', TRUE)
        Else
        {
            hDC       := DllCall('Gdi32.dll\CreateDCW', 'Str', 'DISPLAY', 'Ptr', 0, 'Ptr', 0, 'Ptr', 0, 'Ptr')
            R         := DllCall('Gdi32.dll\GetDeviceCaps', 'Ptr', hDC, 'Int', 90)
            DllCall('Gdi32.dll\DeleteDC', 'Ptr', hDC)
            
            Size      := RegExMatch(Options, 'i)s([\-\d\.]+)(p*)', t) ? t.1 : 10
            Height    := Round((Abs(Size) * R) / 72) * -1
            Quality   := RegExMatch(Options, 'i)q([\-\d\.]+)(p*)', t) ? t.1 : 5
            Weight    := RegExMatch(Options, 'i)w([\-\d\.]+)(p*)', t) ? t.1 : (InStr(Options, 'Bold') ? 700 : 400)
            Italic    := !!InStr(Options, 'Italic')
            Underline := !!InStr(Options, 'Underline')
            Strike    := !!InStr(Options, 'Strike')
            
            hFont     := DllCall('Gdi32.dll\CreateFontW', 'Int', Height, 'Int', 0, 'Int', 0, 'Int', 0, 'Int', Weight, 'UInt', Italic, 'UInt', Underline, 'UInt', Strike, 'UInt', 1, 'UInt', 4, 'UInt', 0, 'UInt', Quality, 'UInt', 0, 'UPtr', &FontName, 'Ptr')
            DllCall('User32.dll\SendMessageW', 'Ptr', This.hTip, 'UInt', 0x0030, 'Ptr', hFont, 'Int', TRUE)
        }
    } ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632642(v=vs.85).aspx
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ff486069(v=vs.85).aspx
