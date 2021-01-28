/*
    Muestra un diálogo de tareas. Generalmente utilizado para informar al usuario y/o para pedir confirmación antes de realizar una determinada acción.
    Parámetros:
        Owner   : El identificador de la ventana padre de este diálogo. Este valor puede ser cero.
                  Un Array con el identificador de la ventana padre y/o el icono principal a mostrar en el diálogo. [Owner, MainIcon|IconFile|*HICON, MainIconIndex].
                  MainIcon puede ser cualquiera de los siguientes valores:
                     0xFFFE (TD_ERROR_ICON)       = Aparece un ícono de señal de stop o error en el cuadro de diálogo de tarea.
                     0xFFFF (TD_WARNING_ICON)     = Aparece un icono de signo de exclamación en el cuadro de diálogo de tarea.
                     0xFFFD (TD_INFORMATION_ICON) = Un ícono que consiste en una letra minúscula i en un círculo aparece en el cuadro de diálogo de tarea.
                     0xFFFC (TD_SHIELD_ICON)      = Aparece un icono de escudo en el cuadro de diálogo de tarea.
                  IconFile: La ruta a un archivo icono o que contenga iconos, MainIconIndex especifica el índice del icono (por defecto es 1).
                  *HICON  : Especifica un asterisco seguido del identificador de un icono. El icono no es eliminado.
        Title   : La cadena que se utilizará para el título del diálogo. Si es una cadena vacía, se utilizará el nombre del archivo ejecutable.
                  Un Array con el título y el 'subtítulo'. [Title, Subtitle].
        Content : La cadena que se visualizará como contenido principál en el diálogo para instruir al usuario qué hacer o presentar información.
                  Un Array con el texto principal e información adicional. [Content, ExpandedInformation, ExpandedControlText, CollapsedControlText, ExpandedByDefault?].
                  ExpandedControlText : La cadena que se utilizará para etiquetar el botón para contraer la información adicional.
                  CollapsedControlText: La cadena que se utilizará para etiquetar el botón para expandir la información adicional.
                  ExpandedByDefault   : Determina si la información adicinal se muestra expandida inicialmente. Por defecto es 0 (FALSE).
        Buttons : Especifica los botones comunes del diálogo, debe especificar una cadena con una o más de las palabras OK/YES/NO/CANCEL/RETRY/CLOSE, puede añadir como prefijo una 'd' para establecerlo como por defecto.
                  Un Array que especifica los distintos tipos de botones a mostrar en el diálogo. [CommonButtons, CommandLinkButtons, RadioButtons, CheckBox].
                  CommandLinkButtons: Especifica un Array con la definición de los Botones o Enlaces de Comando que se mostrarán en el diálogo. La cadena-etiqueta que inicie con '`r' será el botón por defecto.
                  RadioButtons      : Especifica un Array con la definición de los RadioButtons que se mostrarán en el diálogo. La cadena-etiqueta que inicie con '`r' será el botón marcado al inicio.
                  CheckBox          : La cadena que se utilizará para etiquetar la casilla de verificación (checkbox).
        Footer  : La cadena que se utilizará en el área del pie de página (parte inferior) del diálogo.
                  Un Array con el texto en el área de pie de página y el icono a mostrar junto a él. [FooterText, FooterIcon|IconFile|*HICON, FooterIconIndex]. Se aplica la misma lógica que en el parámetro «Owner».
        Callback: Puntero a una función de devolución de llamada definida por la aplicación; o puede especificar el nombre de una función, en cuyo caso se utilizará RegisterCallback+GlobalFree.
                  Un Array con la función de devolución de llamada y los datos de referencia definidos por la aplicación. [FuncPtr|FuncName, DataPtr|Data].
        Options : Especifica un entero que controla ciertos comportamiendos del diálogo, debe sumar los valores para combinar.
            0x0001 (TDF_ENABLE_HYPERLINKS)         = Habilita el procesamiento de hipervínculos para las cadenas especificadas en Content, ExpandedInformation y FooterText. <A HREF="executablestring">Hyperlink Text</A>.
            0x0008 (TDF_ALLOW_DIALOG_CANCELLATION) = Indica que el diálogo se debe poder cerrar usando Alt-F4, Escape y el botón de cerrar de la barra de título, incluso si no se especifica ningún botón de cancelar en CommonButtons o CommandLinkButtons.
            0x0020 (TDF_USE_COMMAND_LINKS_NO_ICON) = Indica que los botones CommandLink se deben mostrar como enlaces de comando (sin un glifo) en lugar de botones pulsadores. Al utilizar enlaces de comando, todos los caracteres hasta el primer carácter de nueva línea se tratarán como el texto principal del enlace de comando, y el resto se tratará como la nota del enlace de comando.
            0x0100 (TDF_VERIFICATION_FLAG_CHECKED) = Indica que la casilla de verificación (CheckBox) en el cuadro de diálogo está marcada cuando se muestra inicialmente el cuadro de diálogo.
            0x0200 (TDF_SHOW_PROGRESS_BAR)         = Indica que se debe mostrar una barra de progreso.
            0x0400 (TDF_SHOW_MARQUEE_PROGRESS_BAR) = Indica que se debe mostrar una barra de progreso 'a marcas' (Marquee Progress Bar).
            0x0800 (TDF_CALLBACK_TIMER)            = Indica que se debe invocar la devolución de llamada del diálogo de tareas aproximadamente cada 200 milisegundos.
            0x2000 (TDF_RTL_LAYOUT)                = Indica que el texto se muestra leyendo de derecha a izquierda.
            0x8000 (TDF_CAN_BE_MINIMIZED)          = Indica que el diálogo de tareas puede ser minimizado.
            0x01000000 (TDF_SIZE_TO_CONTENT)       = Indica que el ancho del diálogo de tareas está determinado por el ancho de su área de contenido. Este indicador se ignora si el ancho no está configurado en 0.
    Return:
        Si hubo un error devuelve el código de error (entero), si tuvo éxito devuelve un objeto con las siguientes claves.
            Button  : La cadena con el nombre del botón común precionado o el índice del botón CommandLink donde el primer botón añadido tendra el identificador 1, el segundo el identificador 2 y así suscesivamente.
            Radio   : El identificador del botón radio marcado. El primer botón radio añadido tendrá el identificador 1, el segundo el identificador 2 y así suscesivamente.
            CheckBox: Determina el estado del botón de verificación (checkbox). Si es 1, el CheckBox estaba marcado.
    Observaciones:
        Puede ejecutar la ayuda presionando la tecla F1.
        Ver ejemplo al final
*/
TaskDialog(Owner, Title, Content := '', Buttons := '', Footer := '', Callback := '', Options := 0)
{
    ; TASKDIALOGCONFIG structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787473(v=vs.85).aspx
    Local Size  := A_PtrSize == 4 ? 96 : 160    ; cbSize
        , Flags := 0    ; dwFlags
    VarSetCapacity(TASKDIALOGCONFIG, Size, 0)    ; TASKDIALOGCONFIG structure
    NumPut(Size, &TASKDIALOGCONFIG, 'UInt')    ; cbSize

    ; establecemos la ventana padre
    Local Owner2 := IsObject(Owner) && ObjLength(Owner) > 0 ? Owner[1] : 0
    NumPut(Owner2, &TASKDIALOGCONFIG + 4, 'Ptr')    ; hwndParent

    ; establecemos el icono principal
    Local MainIcon      := (IsObject(Owner) && ObjLength(Owner) > 1 ? Owner[2] : '')
    Local MainIconIndex := (IsObject(Owner) && ObjLength(Owner) > 2 ? Owner[3] :  1)
    Local MainIconType  := MainIcon == '' ? '' : (SubStr(MainIcon, 1, 1) == '*' && SubStr(MainIcon, 2) is 'Integer' ? 0 : MainIcon is 'Integer' ? 1 : 2)
    NumPut(TaskDialog_SetIcon(MainIcon, MainIconIndex, MainIconType, Flags, 0x0002), &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 24 : 36), "Ptr")    ; hMainIcon | pszMainIcon | TDF_USE_HICON_MAIN = 0x0002

    ; establecemos el título
    Local Title2 := (IsObject(Title) && ObjLength(Title) > 0 ? Title[1] : Title) . ''
    NumPut(Title2 == '' ? 0 : &Title2, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 20 : 28))    ; pszWindowTitle

    ; establecemos el subtítulo
    Local SubTitle := IsObject(Title) && ObjLength(Title) > 1 ? Title[2] . '' : ''
    NumPut(SubTitle == '' ? 0 : &SubTitle, &TASKDIALOGCONFIG + (A_PtrSize = 4 ? 28 : 44))    ; pszMainInstruction

    ; establecemos el texto principal
    Local Content2 := (IsObject(Content) && ObjLength(Content) > 0 ? Content[1] : Content) . ''
    NumPut(Content2 == '' ? 0 : &Content2, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 32 : 52))    ; pszContent

    ; establecemos la información adicional, la etiqueta del botón que la expande y la contrae, y el estado inicial (expandido o contraido)
    Local ExpandedInformation := IsObject(Content) && ObjLength(Content) > 1 ? Content[2] . '' : ''
    NumPut(ExpandedInformation == '' ? 0 : &ExpandedInformation, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 64 : 100))    ; pszExpandedInformation
    Local ExpandedControlText := IsObject(Content) && ObjLength(Content) > 2 ? Content[3] . '' : ''
    NumPut(ExpandedControlText == '' ? 0 : &ExpandedControlText, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 68 : 108))    ; pszExpandedControlText
    Local CollapsedControlText := IsObject(Content) && ObjLength(Content) > 3 ? Content[4] . '' : ''
    NumPut(CollapsedControlText == '' ? 0 : &CollapsedControlText, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 72 : 116))    ; pszCollapsedControlText
    Flags |= IsObject(Content) && ObjLength(Content) > 4 && Content[5] ? 0x0080 : 0x0000    ; TDF_EXPANDED_BY_DEFAULT = 0x0080

    ; establecemos los botones comunes
    Local DefaultButton    ; almacena el botón común por defecto (si se especificó); o cero
        , CommonButtons := IsObject(Buttons) && ObjLength(Buttons) > 0 ? TaskDialog_CommonButtons(Buttons[1], &TASKDIALOGCONFIG, DefaultButton) : 0
    NumPut(CommonButtons, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 16 : 24), 'UInt')

    ; establecemos los controles de enlace de comando (command link buttons)
    Local TASKDIALOG_BUTTON, CLButton
    If (CLButton := TASKDIALOG_BUTTON(TASKDIALOG_BUTTON, IsObject(Buttons) && ObjLength(Buttons) > 1 ? Buttons[2] : 0, DefaultButton))
        NumPut(CLButton.Count, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 36 : 60), 'UInt')    ; cButtons
      , NumPut(&TASKDIALOG_BUTTON, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 40 : 64))    ; pButtons
      , NumPut(CLButton.Default, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 44 : 72), 'Int')    ; nDefaultButton
      , Flags |= 0x0010    ; TDF_USE_COMMAND_LINKS

    ; establecemos los controles Radio Buttons
    Local TASKDIALOG_RBUTTON, RButton
    If (RButton := TASKDIALOG_BUTTON(TASKDIALOG_RBUTTON, IsObject(Buttons) && ObjLength(Buttons) > 2 ? Buttons[3] : 0))
        NumPut(RButton.Count, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 48 : 76), 'UInt')    ; cButtons
      , NumPut(&TASKDIALOG_RBUTTON, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 52 : 80))    ; pButtons
      , NumPut(RButton.Default, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 56 : 88), 'Int')    ; nDefaultRadioButton
      , Flags |= RButton.Default ? 0 : 0x4000    ; TDF_NO_DEFAULT_RADIO_BUTTON = 0x4000

    ; establecemos la etiqueta del control de verificación (checkbox)
    Local VerificationText := (IsObject(Buttons) && ObjLength(Buttons) > 3 ? Buttons[4] . '' : '')
    NumPut(VerificationText == '' ? 0 : &VerificationText, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 60 : 92))    ; pszVerificationText

    ; establecemos el texto en el área del pie de página
    Local FooterText := (IsObject(Footer) && ObjLength(Footer) > 0 ? Footer[1] : Footer) . ''
    NumPut(FooterText == '' ? 0 : &FooterText, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 80 : 132))    ; pszFooter

    ; establecemos el icono en el área de pie de página
    Local FooterIcon      := (IsObject(Footer) && ObjLength(Footer) > 1 ? Footer[2] : '')
    Local FooterIconIndex := (IsObject(Footer) && ObjLength(Footer) > 2 ? Footer[3] :  1)
    Local FooterIconType  := FooterIcon == '' ? '' : (SubStr(FooterIcon, 1, 1) == '*' && SubStr(FooterIcon, 2) is 'Integer' ? 0 : FooterIcon is 'Integer' ? 1 : 2)
    NumPut(TaskDialog_SetIcon(FooterIcon, FooterIconIndex, FooterIconType, Flags, 0x0004), &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 76 : 124), "Ptr")    ; hFooterIcon | pszFooterIcon | TDF_USE_HICON_FOOTER = 0x0004

    ; establecemos la función de devolución de llamada y los datos de referencia
    Local Callback2    := IsObject(Callback) && ObjLength(Callback) > 0 ? Callback[1] : Callback
    Local FuncPtr      := Callback2 is 'Integer' ? 0 : RegisterCallback(Callback2 == '' ? 'TaskDialog_CallbackProc' : Callback2)
    Local CallbackData := IsObject(Callback) && ObjLength(Callback) > 1 ? (Callback[2] is 'Integer' ? Callback[2] : &Callback[2]) : 0
    NumPut(FuncPtr ? FuncPtr : (Callback2 == '' ? 0 : Callback2), &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 84 : 140))
    NumPut(CallbackData, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 88 : 148))

    ; establecemos los Flags (banderas)
    NumPut(Flags | Options, &TASKDIALOGCONFIG + (A_PtrSize == 4 ? 12 : 20), 'UInt')

    ; llamamos a la función WINAPI::TaskDialogIndirect para mostrar el diálogo
    Local R, Button, Radio, Checkbox
    R := DllCall('Comctl32.dll\TaskDialogIndirect', 'UPtr', &TASKDIALOGCONFIG, 'IntP', Button, 'IntP', Radio, 'IntP', Checkbox, 'UInt')

    ; destruimos los iconos si se utilizó la función incorporada LoadPicture()
    If (MainIconType == 2)
        DllCall('User32.dll\DestroyIcon', 'Ptr', NumGet(&TASKDIALOGCONFIG + (A_PtrSize == 4 ? 24 :  36), 'Ptr'))    ; hMainIcon
    If (FooterIconType == 2)
        DllCall('User32.dll\DestroyIcon', 'Ptr', NumGet(&TASKDIALOGCONFIG + (A_PtrSize == 4 ? 76 : 124), 'Ptr'))    ; hFooterIcon

    ; liberamos la memoria utilizada al llamar a RegisterCallback
    If (FuncPtr)
        DllCall('Kernel32.dll\GlobalFree', 'UPtr', FuncPtr, 'UPtr')    ; Return: 0 = OK | FuncPtr = ERROR

    ; devolvemos el resultado
    Buttons := {1: 'OK', 6: 'YES', 7: 'NO', 2: 'CANCEL', 4: 'RETRY', 8: 'CLOSE'}
    Return R ? R : {Button: ObjHasKey(Buttons, Button) ? Buttons[Button] : Button?Button-100:0, Radio: Radio?Radio-100:0, CheckBox: Checkbox}
}





/*
    :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    :::: FUNCIONES PARA USO INTERNO DE LA FUNCIÓN TaskDialog. IGNORAR!
    :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
TASKDIALOG_BUTTON(ByRef TASKDIALOG_BUTTON, Buttons, Default := 0)
{
    If (!IsObject(Buttons) || ObjLength(Buttons) == 0)
        Return 0

    Local Offset  := -A_PtrSize
    VarSetCapacity(TASKDIALOG_BUTTON, (4 + A_PtrSize) * ObjLength(Buttons))
    Loop (ObjLength(Buttons))
    {
        If (SubStr(Buttons[A_Index], 1, 1) == '`r')
            Default := 100 + A_Index, Buttons[A_Index] := SubStr(Buttons[A_Index], 2)
        NumPut(100 + A_Index, &TASKDIALOG_BUTTON + (Offset += A_PtrSize), 'Int')    ; nButtonID
        NumPut(ObjGetAddress(Buttons, A_Index), &TASKDIALOG_BUTTON + (Offset += 4))    ; pszButtonText
    }

    Return {Count: ObjLength(Buttons), Default: Default}
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb787475(v=vs.85).aspx

TaskDialog_CommonButtons(Value, TASKDIALOGCONFIG, ByRef DefaultButton)
{
    If (Value is 'Number')    ; permite utilizar un entero para determinar los botones normales mostrados en el diálogo; en lugar de una cadena con el nombre de los botones
        Return Value
    ;                                 IDOK          |         IDYES          |         IDNO            |        IDCANCEL         |          IDRETRY         |         IDCLOSE
    NumPut(DefaultButton := InStr(Value, 'dOK') ? 1 : InStr(Value, 'dY') ? 6 : InStr(Value, 'dNO') ? 7 : InStr(Value, 'dCA') ? 2 : InStr(Value, 'dRE') ? 4 : InStr(Value, 'dCL') ? 8 : 0
            , TASKDIALOGCONFIG + (A_PtrSize == 4 ? 44 : 72), 'Int')    ; nDefaultButton
    ;          TDCBF_OK_BUTTON      |    TDCBF_YES_BUTTON     |     TDCBF_NO_BUTTON      |    TDCBF_CANCEL_BUTTON   |    TDCBF_RETRY_BUTTON     |    TDCBF_CLOSE_BUTTON
    Return (InStr(Value, 'OK')?1:0) | (InStr(Value, 'Y')?2:0) | (InStr(Value, 'NO')?4:0) | (InStr(Value, 'CA')?8:0) | (InStr(Value, 'RE')?16:0) | (InStr(Value, 'CL')?32:0)
}

TaskDialog_SetIcon(Icon, IconIndex, ByRef IconType, ByRef Flags, Flag)
{
    Flags |= IconType == '' || IconType == 1 ? 0 : Flag    ; TDF_USE_HICON_MAIN = 0x0002 | TDF_USE_HICON_FOOTER = 0x0004

    If (IconType == '')    ; sin icono
        Return 0
    If (IconType == 0)    ; *HICON
        Return SubStr(Icon, 2)
    If (IconType == 1)
        Return Icon    ; iconos predefinidos (error, advertencia, información, escudo, ..)

    Local HICON := LoadPicture(Icon, 'Icon' . IconIndex, ImageType)
    If (!HICON || ImageType != 1)    ; si fallo al cargar el icono o si el archivo no es un icono
    {
        If (HICON)
            DllCall(ImageType ? 'User32.dll\DestroyCursor' : 'Gdi32.dll\DeleteObject', 'Ptr', HICON)
        IconType := ''    ; sin icono
        Return 0
    }

    Return HICON    ; HICON = LoadPicture()
}

TaskDialog_CallbackProc(Hwnd, Notification, wParam, lParam, RefData)
{
    If (Notification == 3)    ; TDN_HYPERLINK_CLICKED
        Run(StrGet(lParam, 'UTF-16'))

    Return 0
}





/*
    :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    :::: EJEMPLO
    :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/
/*
; establecemos las parámetros y opciones del diálogo
Owner        := 0
MainIcon     := 0xFFFC    ; TD_SHIELD_ICON
Title        := 'Título del diálogo'
Subtitle     := '# Mi Subtitulo =D'    ; MainInstruction
Content      := 'Contenido principal del diálogo! | Presiona F1 para ver la ayuda!`nVisita <A HREF="https://autohotkey.com">AutoHotkey</A>' 
ExpInfo      := 'Mostrando la información adicional'    ; ExpandedInformation
Buttons      := 'dOK YES NO CANCEL RETRY CLOSE'    ; dOK = Default OK
CLButtons    := ['Command Link #1', 'Command Link #2`nInformación adicional :)']
RButtons     := ['Radio Button #1', '`rRadio Button #2']    ; `r = Default
CButton      := 'Casilla de verificación (checkbox)'    ; CheckBox Control
FooterText   := 'Texto en el área de pie de página'
FooterIcon   := A_ComSpec    ; LoadPicture() + DestroyIcon()
Callback     := 'TaskDialog_CallbackProc2'
CallbackData := {Help: 'Hola, soy una ayuda =D', Bye: 'Bye Bye!'}
Options      := 0x0001 | 0x0008 | 0x0100 | 0x0200 | 0x0400 | 0x0800 | 0x8000

; mostramos el diálogo y almacenamos el valor devuelto en la variable 'R'
R := TaskDialog([Owner,MainIcon], [Title,Subtitle], [Content,ExpInfo], [Buttons,CLButtons,RButtons,CButton], [FooterText,FooterIcon], [Callback,CallbackData], Options)
MsgBox(!IsObject(R) ? 'ERROR #' . R : 'Button: ' . R.Button . '`nRadio: ' . R.Radio . '`nCheckBox: ' . R.CheckBox)
ExitApp

; Función de devolución de llamada del diálogo
; Hwnd: El identificador de la ventana de diálogo de tarea.
; Notification: Código de notificación, ver referencia.
; wParam / lParam: Especifica información adicional, depende del valor de Notification.
; RefData: Puntero a datos específicos de la aplicación.
; Referencia: https://msdn.microsoft.com/en-us/library/windows/desktop/bb760542(v=vs.85).aspx
TaskDialog_CallbackProc2(Hwnd, Notification, wParam, lParam, RefData)
{
    Local CallbackData := Object(RefData)

    If (Notification == 2)    ; TDN_BUTTON_CLICKED
        MsgBox('Button Clicked: ' . wParam,, 'Owner' . Hwnd)
    Else If (Notification == 3)    ; TDN_HYPERLINK_CLICKED
        Run(StrGet(lParam, 'UTF-16'))
    Else If (Notification == 5)    ; TDN_DESTROYED
        MsgBox(CallbackData.Bye)
    Else If (DllCall('User32.dll\IsWindowVisible', 'Ptr', Hwnd) && Notification == 6)    ; TDN_RADIO_BUTTON_CLICKED
        MsgBox('RadioButton #' . wParam,, 'Owner' . Hwnd)
    Else If (Notification == 7)    ; TDN_DIALOG_CONSTRUCTED
        Return 0
    Else If (Notification == 8)    ; TDN_VERIFICATION_CLICKED
        MsgBox('CheckBox: ' . wParam,, 'Owner' . Hwnd)
    Else If (Notification == 9)    ; TDN_HELP (F1)
        MsgBox(CallbackData.Help,, 'Owner' . Hwnd)
    Else If (Notification == 10)    ; TDN_EXPANDO_BUTTON_CLICKED
        ToolTip(wParam ? 'Mostrando la info adicional' : 'Ocultando la info adicional'), SetTimer('ToolTip', -1000)

    return 0 ;CONSTANTS: https://searchcode.com/codesearch/view/77005279/
}
*/
