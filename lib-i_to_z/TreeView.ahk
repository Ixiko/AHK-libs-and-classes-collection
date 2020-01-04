; I THINK THIS FILE IS WRITTEN BY:
; Flipeador -	uno de nuestros mejores programadores ingeniosos y miembros dedicados del foro
;                  	one of our best ingenious programmers and dedicated forum members
;
; 	y sí, el español es un idioma excelente!
; 	Pero con demasiada frecuencia los 132 idiomas que hablo se mezclan con fluidez, y luego ya no entiendo nada.
;	¡Es por eso que usé Google y traduje las letras al inglés, dejando los originales en español!
;	¡Creo que no solo me siento así! ¡Por eso Flipeador no estaría tan enojado conmigo!

/*
    Elimina el elemento especificado junto con todos sus subelementos.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El identificador del elemento a eliminar. Si este valor es -65536 se eliminan todos los elementos (recomendado utilizar TV_DeleteAll).
        Childs: Si este valor es 1, solo se eliminan todos los subelementos del elemento especificado.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0. Si Childs es TRUE y no hay sub-elementos para eliminar, devuelve -1.
    ----------------------------------------------------------------------------------------------------------------------------------------
    Deletes the specified item along with all its sub-elements.
     Parameters:
         TV: The TreeView control object.
         ItemID: The identifier of the item to be deleted. If this value is -65536, all the elements are eliminated (it is recommended to use TV_DeleteAll).
         Childs: If this value is 1, only all sub-elements of the specified element are removed.
     Return:
         If it succeeds, it returns 1, otherwise it returns 0. If Childs is TRUE and there are no sub-elements to eliminate, it returns -1.
*/
TV_Delete(TV, ItemID, Childs := FALSE){
    If (Childs)
    {
        ; TVM_GETNEXTITEM message | TVGN_CHILD = 4 | TVGN_NEXT = 1
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773622(v=vs.85).aspx
        If (!ItemID := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x110A, 'UInt', 4, 'Ptr', ItemID))
            Return (-1)    ; no hay sub-elementos

        Local SubItemID
        While (SubItemID := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x110A, 'UInt', 1, 'Ptr', ItemID))
        {
            DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1101, 'Ptr', 0, 'Ptr', ItemID)
            ItemID := SubItemID
        }
    }

    ; TVM_DELETEITEM message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773560(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1101, 'Ptr', 0, 'Ptr', ItemID))
}

/*
    Elimina todos los elementos en el control TreeView especificado.
    Parámetros:
        TV: El objeto control TreeView.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    ----------------------------------------------------------------------------------------------------------------------------------------
    Remove all items in the specified TreeView control.
     Parameters:
         TV: The TreeView control object.
     Return:
         If successful, return 1, otherwise return 0.
*/
TV_DeleteAll(TV){
    Local Styles := WinGetStyle('ahk_id' . TV.Hwnd)
    ; TVM_DELETEITEM message | TVI_ROOT = -65536
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773560(v=vs.85).aspx
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773790(v=vs.85).aspx
    Local Result := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1101, 'Ptr', 0, 'Ptr', -65536)
    WinSetStyle(Styles, 'ahk_id' . TV.Hwnd)
    Return (Result)
}

/*
    Recupera el elemento actualmente seleccionado en el control TreeView especificado.
    Parámetros:
        TV: El objeto control TreeView.
    Return:
        Devuelve el identificador del elemento actual seleccionado, o cero si no hay ningún elemento seleccionado.
    ----------------------------------------------------------------------------------------------------------------------------------------
    Retrieves the currently selected item in the specified TreeView control.
     Parameters:
         TV: The TreeView control object.
     Return:
         Returns the identifier of the current selected item, or zero if no item is selected.
*/
TV_GetSelection(TV){
    ; TVM_GETNEXTITEM message | TVGN_CARET = 9
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773622(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x110A, 'Int', 9, 'Ptr', 0, 'Ptr'))
}

/*
    Recupera el primer elemento secundario del elemento especificado.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El elemento primario.
    Return:
        Devuelve el identificador del primer elemento secundario, o cero si no se ha encontrado ningún elemento secundario.
    ----------------------------------------------------------------------------------------------------------------------------------------
    Retrieves the first child of the specified element.
     Parameters:
         TV: The TreeView control object.
         ItemID: The primary element.
     Return:
         Returns the identifier of the first child element, or zero if no child element was found.
*/
TV_GetChild(TV, ItemID){
    ; TVM_GETNEXTITEM message | TVGN_CHILD = 4
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773622(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x110A, 'Int', 4, 'Ptr', ItemID, 'Ptr'))
}

/*
    Recupera el elemento padre del elemento secundario especificado.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El elemento secundario.
    Return:
        Devuelve el identificador del elemento padre, o cero si el elemento especificado no tiene un elemento padre.
    ----------------------------------------------------------------------------------------------------------------------------------------
    Retrieves the parent element of the specified child element.
     Parameters:
         TV: The TreeView control object.
         ItemID: The secondary element.
     Return:
         Returns the identifier of the parent element, or zero if the specified element does not have a parent element.
*/
TV_GetParent(TV, ItemID){
    ; TVM_GETNEXTITEM message | TVGN_PARENT = 3
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773622(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x110A, 'Int', 3, 'Ptr', ItemID, 'Ptr'))
}

/*
    Recupera el elemento hermano anterior del elemento especificado.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El identificador del elemento.
    Return:
        Devuelve el identificador del elemento hermano anterior, o cero si el elemento especificado no tiene un elemento hermano anterior.
    ----------------------------------------------------------------------------------------------------------------------------------------
    Retrieves the previous sister element of the specified element.
     Parameters:
         TV: The TreeView control object.
         ItemID: The identifier of the element.
     Return:
         Returns the identifier of the previous sibling element, or zero if the specified element does not have a previous sibling element.
*/
TV_GetPrev(TV, ItemID, Visible := FALSE){
    ; TVM_GETNEXTITEM message | TVGN_PREVIOUS = 2 | TVGN_PREVIOUSVISIBLE = 7
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773622(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x110A, 'Int', Visible?7:2, 'Ptr', ItemID, 'Ptr'))
}

/*
    Recupera el elemento hermano siguiente del elemento especificado.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El identificador del elemento. Si este valor es 0, la función devuelve el identificador del primer elemento en la lista.
        Type  : El tipo de elemento a recuperar. Por defecto recupera el elemento siguiente a ItemID. Puede ser uno de los siguientes valores:
            0xB (TVGN_NEXTSELECTED) = Recupera el siguiente elemento seleccionado.
            0x6 (TVGN_NEXTVISIBLE)  = Recupera el siguiente elemento visible.
            0x5 (TVGN_FIRSTVISIBLE) = Recupera el primer elemento que es visible.
            0xA (TVGN_LASTVISIBLE)  = Recupera el último elemento expandido.
            Para más valores ver 'https://msdn.microsoft.com/en-us/library/windows/desktop/bb773622(v=vs.85).aspx'.
    Return:
        Devuelve el identificador del elemento hermano siguiente, o cero si el elemento especificado no tiene un elemento hermano siguiente.
*/
TV_GetNext(TV, ItemID := 0, Type := 1){
    ; TVM_GETNEXTITEM message | TVGN_NEXT = 1 | TVGN_ROOT = 0
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773622(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x110A, 'Int', ItemID==0?0:Type, 'Ptr', ItemID, 'Ptr'))
}

/*
    Comienza o finaliza la edición del texto del elemento especificado.
    Parámetros:
        TV     : El objeto control TreeView.
        ItemID : El identificador del elemento a editar. El elemento es automáticamente seleccionado y puesto en foco.
        Discard: Si este valor es 1 y ya hay una operación de edición, los cambios anteriores son automáticamente descartados.
        Wait   : Si este valor es 1, la función espera a que el usuario termine de editar el elemento. ErrorLevel se establece en el nuevo texto.
        Seconds: Si Wait es 1, este valor indica la cantidad de segundos a esperar, si es una cadena vacía espera indefinidamente. Si se alcanzó el tiempo fuera, la función devuelve 0.
    Return:
        Si tuvo éxito devuelve el identificador del control Edit, caso contrario devuelve 0.
        Si Wait es 1, este identificador no es válido, solo útil para determinar si tuvo éxito (no se alcanzó el tiempo fuera, si se estableció) o no.
    Observaciones:
        Al llamar a esta función, el control TreeView automáticamente toma el foco para asegurarse de que TVM_EDITLABEL no falle.
        Si el control no tiene el estilo TVS_EDITLABELS (8. AHK = '-ReadOnly'), la función devuelve 0.
        El identificador del control Edit devuelto solo es válido durante la operación de edición.
        Si ItemID es una cadena vacía, la operación de edición actual (si la hay) es cancelada. La función devuelve 1 en caso de éxito (había una operación de edición), o cero de lo contrario.
    Ejemplo:
        ToolTip('Return: ' . TV_EditLabel(TV, TV.GetSelection(),, TRUE, 5) . '`nErrorLevel: ' . ErrorLevel)
*/
TV_EditLabel(TV, ItemID := '', Discard := FALSE, Wait := FALSE, Seconds := ''){
    If (ItemID == '')
        ; TVM_ENDEDITLABELNOW message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773564(v=vs.85).aspx
        Return (!DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1116, 'Int', TRUE, 'Ptr', 0))

    DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1116, 'Int', !!Discard, 'Ptr', 0)
    TV.Focus()

    ; TVM_EDITLABELW message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773562(v=vs.85).aspx
    Local hEdit := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1141, 'Ptr', 0, 'Ptr', ItemID, 'Ptr')
    If (Wait && hEdit)
    {
        WinWaitClose('ahk_id' . hEdit,, Seconds)
        ErrorLevel := ErrorLevel ? DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1116, 'Int', TRUE, 'Ptr', hEdit:=0) : TV.GetText(ItemID)
    }

    Return (hEdit)
}

/*
    Recupera el identificador del control Edit siendo utilizado durante la edición del texto de un elemento en el control TreeView especificado.
    Parámetros:
        TV: El objeto control TreeView.
    Return:
        Si tuvo éxito devuelve el identificador del control, caso contrario devuelve 0.
*/
TV_GetEdit(TV){
    ; TVM_GETEDITCONTROL message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773576(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', Msg, 'Ptr', 0x110F, 'Ptr', 0, 'Ptr'))
}

/*
    Asegura de que el elemento especificado es visible, expandiendo el elemento padre o desplazando las barras de desplazamiento.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El identificador del elemento a editar.
        Mode  : Si este valor es 1 y es posible, asegura de que el elemento se muestre en la parte superior del control.
    Return:
        Devuelve un valor distinto de cero si el sistema desplazó las barras y no se expandieron los elementos. De lo contrario devuelve cero.
*/
TV_EnsureVisible(TV, ItemID, Mode := 0){
    If (Mode)
        ; TVM_SELECTITEM message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773736(v=vs.85).aspx
        Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x110B, 'UInt', 5, 'Ptr', ItemID))

    ; TVM_ENSUREVISIBLE message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773566(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1114, 'Ptr', 0, 'Ptr', ItemID))
}

/*
    Expande o contrae la lista de elementos secundarios asociados con el elemento primario especificado, si los hubiere.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El identificador del elemento padre.
        Action: La acción a realizar. Debe especificar uno de los siguientes valores:
            -1 = Contrae la lista si se encuentra expandida, o la expande si se encuentra contraída.
             0 = Contrae la lista de elementos asociados con el elemento padre especificado en ItemID.
             1 = Expande la lista de elementos asociados con el elemento padre especificado en ItemID.
    Return:
        Si tuvo éxito devuelve un valor distinto de cero, caso contrario devuelve 0.
*/
TV_Expand(TV, ItemID, Action := 1){
    ; TVM_EXPAND message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773568(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1102, 'Ptr', {-1:3,0:1:1:2}[Action], 'Ptr', ItemID))
}

/*
    Recupera el color del texto en el control TreeView especificado.
    Parámetros:
        TV: El objeto control TreeView.
    Return:
        Devuelve el color RGB del texto.
*/
TV_GetTextColor(TV){
    ; TVM_GETTEXTCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773633(v=vs.85).aspx
    Local Color := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1120, 'Ptr', 0, 'Ptr', 0)
    Return (Color > 0 ? (Color & 255) << 16 | (Color & 65280) | (Color >> 16) : 0)    ; BGR --> RGB
}

/*
    Establece el color del texto en el control TreeView especificado.
    Parámetros:
        TV   : El objeto control TreeView.
        Color: El nuevo color del texto en el control.
    Return:
        Devuelve el color RGB de fondo anterior.
    Observaciones:
        Cuando llama a esta función, automáticamente se redibuja el control una vez se establece el nuevo color, para asegurarse de que se visualiza correctamente.
*/
TV_SetTextColor(TV, Color := 0x000000){
    ; TVM_SETTEXTCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773769(v=vs.85).aspx
    Color := ((Color & 255) << 16) | (((Color >> 8) & 255) << 8) | (Color >> 16)    ; RGB --> BGR
    Color := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x111E, 'Ptr', 0, 'Int', Color)

    ; InvalidateRect function
    ; https://msdn.microsoft.com/en-us/library/dd145002(v=vs.85).aspx
    DllCall('User32.dll\InvalidateRect', 'Ptr', TV.Hwnd, 'UPtr', 0, 'Int', TRUE)

    Return (Color > 0 ? (Color & 255) << 16 | (Color & 65280) | (Color >> 16) : 0)    ; BGR --> RGB
}

/*
    Recupera el color de fondo del control TreeView especificado.
    Parámetros:
        TV: El objeto control TreeView.
    Return:
        Devuelve el color RGB de fondo.
    Nota:
        Utilizamos TVM_SETBKCOLOR y no TVM_GETBKCOLOR debido a que TVM_GETBKCOLOR devuelve siempre cero.
*/
TV_GetBkColor(TV){
    ; TVM_SETBKCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773741(v=vs.85).aspx
    Local Color := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x111D, 'Ptr', 0, 'Int', -1)
    DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x111D, 'Ptr', 0, 'Int', Color)
    Return (Color > -1 ? (Color & 255) << 16 | (Color & 65280) | (Color >> 16) : 0xFFFFFF)    ; BGR --> RGB
}

/*
    Establece el color de fondo del control TreeView especificado.
    Parámetros:
        TV   : El objeto control TreeView.
        Color: El nuevo color de fondo para el control.
    Return:
        Devuelve el color RGB de fondo anterior.
    Observaciones:
        Cuando llama a esta función, automáticamente se redibuja el control una vez se establece el nuevo color, para asegurarse de que se visualiza correctamente.
*/
TV_SetBkColor(TV, Color := 0xFFFFFF){
    ; TVM_SETBKCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773741(v=vs.85).aspx
    Color := ((Color & 255) << 16) | (((Color >> 8) & 255) << 8) | (Color >> 16)    ; RGB --> BGR
    Color := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x111D, 'Ptr', 0, 'Int', Color)

    ; InvalidateRect function
    ; https://msdn.microsoft.com/en-us/library/dd145002(v=vs.85).aspx
    DllCall('User32.dll\InvalidateRect', 'Ptr', TV.Hwnd, 'UPtr', 0, 'Int', TRUE)

    Return (Color > -1 ? (Color & 255) << 16 | (Color & 65280) | (Color >> 16) : 0xFFFFFF)    ; BGR --> RGB
}

/*
    Recupera el color de las líneas en el control TreeView especificado.
    Parámetros:
        TV: El objeto control Treeview.
    Return:
        Devuelve el color RGB de las líneas.
*/
TV_GetLineColor(TV){
    ; TVM_SETLINECOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773619(v=vs.85).aspx
    Local Color := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1129, 'Ptr', 0, 'Ptr', 0)
    Return (Color > 0 ? (Color & 255) << 16 | (Color & 65280) | (Color >> 16) : 0)    ; BGR --> RGB
}

/*
    Establece el color de las líneas del control TreeView especificado.
    Parámetros:
        TV   : El objeto control TreeView.
        Color: El nuevo color de las líneas en el control.
    Return:
        Devuelve el color RGB de las líneas anterior.
    Observaciones:
        Cuando llama a esta función, automáticamente se redibuja el control una vez se establece el nuevo color, para asegurarse de que se visualiza correctamente.
*/
TV_SetLineColor(TV, Color){
    ; TVM_SETLINECOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773764(v=vs.85).aspx
    Color := ((Color & 255) << 16) | (((Color >> 8) & 255) << 8) | (Color >> 16)    ; RGB --> BGR
    Color := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1128, 'Ptr', 0, 'Int', Color)

    ; InvalidateRect function
    ; https://msdn.microsoft.com/en-us/library/dd145002(v=vs.85).aspx
    DllCall('User32.dll\InvalidateRect', 'Ptr', TV.Hwnd, 'UPtr', 0, 'Int', TRUE)

    Return (Color > 0 ? (Color & 255) << 16 | (Color & 65280) | (Color >> 16) : 0)    ; BGR --> RGB
}

/*
    Recupera la cantidad de elementos en el control TreeView especificado.
    Parámetros:
        TV  : El objeto control TreeView.
        Type: Especifica el tipo de situación que deben tener los elementos a contar. Si es una cadena vacía se recuperan todos los elementos, O puede ser:
            S / Selected = Recupera la cantidad de elementos seleccionados.
            V / Visible  = Recupera la cantidad de elementos que pueden ser completamente visibles en la ventana cliente del control.
    Return:
        Devuelve la cantidad de elementos.
*/
TV_GetCount(TV, Type := ''){
    If (Type == '')
        ; TVM_GETCOUNT message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773572(v=vs.85).aspx
        Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1105, 'Ptr', 0, 'Ptr', 0, 'UInt'))

    Else If (Type = 'S' || Type = 'Selected')
        ; TVM_GETSELECTEDCOUNT message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773629(v=vs.85).aspx
        Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1146, 'Ptr', 0, 'Ptr', 0, 'UInt'))

    Else If (Type = 'V' || Type = 'Visible')
        ; TVM_GETVISIBLECOUNT message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773731(v=vs.85).aspx
        Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1110, 'Ptr', 0, 'Ptr', 0, 'UInt'))

    Else
        Throw Exception('TV_GetCount invalid parameter (2)',, Type)
}

/*
    Selecciona el elemento especificado, desplaza el elemento en vista o vuelve a dibujar el elemento del estilo utilizado para indicar el destino de una operación de arrastrar y soltar.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El elemento en el cual aplicar la acción especificada. Si este valor es 0, se remueve la selección actual, si la hay.
        Action: Especifica la acción a realizar para el elemento especificado. Debe especificar uno de los siguientes valores:
            0x8009 = Establece la selección en el elemento especificado. Nota: el valor 0x8000 es opcional, se asegura de no expandir el elemento.
            0x0008 = Vuelve a dibujar el elemento especificado en el estilo utilizado para indicar el destino de una operación de arrastrar y soltar.
            0x0005 = Asegura que el elemento especificado está visible y, si es posible, lo muestra en la parte superior de la ventana del control.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
TV_Select(TV, ItemID := 0, Action := 0x8009){
    ; TVM_SELECTITEM message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773736(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x110B, 'UInt', Action, 'Ptr', ItemID))
}

/*
    Ordena los subelementos del elemento padre especificado.
    Parámetros:
        TV       : El objeto control TreeView.
        ItemID   : El identificador del elemento padre, todos sus subelementos serán ordenados. Omitir este parámetro para ordenar todos los elementos.
        Recursive: Especifica si el ordenamiento es recursivo. Establecer en 1 para ordenar todos los niveles de subelementos bajo el elemento padre especificado.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Notas:
        Para el uso de los parámetros 'Callback' y 'pData' ver 'https://msdn.microsoft.com/en-us/library/windows/desktop/bb773785(v=vs.85).aspx'.
        Ejemplo:
            MsgBox(TV_Sort(TV,,, 'CompareFunc'))
            CompareFunc(lParam1, lParam2, lParamSort)
            {
                Return (1) ;invierte el orden de los elementos (el último pasa a estar en la primera posición, ...)
            }
*/
TV_Sort(TV, ItemID := -65536, Recursive := FALSE, Callback := 0, pData := 0){
    If (Callback)
    {
        ; TVSORTCB structure
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773462(v=vs.85).aspx
        Local TVSORTCB
        VarSetCapacity(TVSORTCB, A_PtrSize*3, 0)
        NumPut(ItemID, &TVSORTCB, 'Ptr')    ; TVSORTCB.hParent
        NumPut(Type(Callback)=='Integer'?Callback+(Recursive:=0):Recursive:=RegisterCallback(Callback), &TVSORTCB+A_PtrSize, 'UPtr')    ; TVSORTCB.lpfnCompare
        NumPut(pData, &TVSORTCB+A_PtrSize*2, 'UPtr')    ; TVSORTCB.lParam

        ; TVM_SORTCHILDRENCB message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773785(v=vs.85).aspx
        Local Result := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1115, 'Ptr', 0, 'UPtr', &TVSORTCB)
        If (Recursive)
            DllCall('Kernel32.dll\GlobalFree', 'UPtr', Recursive, 'UPtr')

        Return (Result)
    }

    ; TVM_SORTCHILDREN message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773782(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1113, 'Int', Recursive, 'Ptr', ItemID))
}

/*
    Recupera información en base a las coordenadas relativas al área del control TreeView especificado.
    Parámetros:
        TV: El objeto control TreeView.
        X : La coordenada X. Relativa al área del control.
        Y : La coordenada Y. Relativa al área del control.
    Return:
        Devuelve un objeto con las siguientes claves:
            Item  = El identificador del elemento, o 0 si no hay ningún elemento en las coordenadas especificadas.
            Flags = Devuelve un valor con información adicional. Estos son los valores válidos:
                0x001 (TVHT_NOWHERE)         = En el área de cliente, pero debajo del último elemento.
                0x002 (TVHT_ONITEMICON)      = En el mapa de bits asociado a un elemento.
                0x004 (TVHT_ONITEMLABEL)     = En la etiqueta (cadena) asociada a un elemento.
                0x008 (TVHT_ONITEMINDENT)    = En la sangría asociada a un elemento.
                0x010 (TVHT_ONITEMBUTTON)    = En el botón asociado a un elemento.
                0x020 (TVHT_ONITEMRIGHT)     = En el área a la derecha de un elemento.
                0x040 (TVHT_ONITEMSTATEICON) = En el icono de estado de un elemento que se encuentra en un estado definido por el usuario.
                0x046 (TVHT_ONITEM)          = En el mapa de bits o etiqueta asociada a un elemento.
                0x100 (TVHT_ABOVE)           = Por encima del área del cliente.
                0x200 (TVHT_BELOW)           = Por debajo del área del cliente.
                0x400 (TVHT_TORIGHT)         = A la derecha del área del cliente.
                0x800 (TVHT_TOLEFT)          = A la izquierda del área del cliente.
            X | Y = Estas claves se establecen en las coordenadas del cursor utilizadas. Útil cuando se omiten los parámetros 'X' y 'Y'.
        Si hubo un error devuelve 0.
    Observaciones:
        Si 'X' y 'Y' se omiten, se tienen en cuenta las coordenadas del cursor.
*/
TV_HitTest(TV, X := '', Y := ''){
    If (X == '' && Y == '')
    {
        ; POINT structure
        ; https://msdn.microsoft.com/en-us/library/dd162805(v=vs.85).aspx
        Local POINT
        VarSetCapacity(POINT, 8)
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648390(v=vs.85).aspx
        DllCall('User32.dll\GetCursorPos', 'UPtr', &POINT)
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd162952(v=vs.85).aspx
        If (!DllCall('User32.dll\ScreenToClient', 'Ptr', TV.Hwnd, 'UPtr', &POINT))
            Return (FALSE)
        X := NumGet(&POINT, 'Int'), Y := NumGet(&POINT+4, 'Int') ;x,y
    }

    ; TVHITTESTINFO structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773448(v=vs.85).aspx
    Local TVHITTESTINFO
    VarSetCapacity(TVHITTESTINFO, 12 + A_PtrSize)
    NumPut(X, &TVHITTESTINFO  , 'Int') ;pt.x
    NumPut(Y, &TVHITTESTINFO+4, 'Int') ;pt.y

    ; TVM_HITTEST message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773732(v=vs.85).aspx
    Return ({ Item : DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1111, 'Ptr', 0, 'UPtr', &TVHITTESTINFO, 'Ptr')    ;item
            , Flags: NumGet(&TVHITTESTINFO+8, 'UInt')                                                                               ;flags
            , X    : X                                                                                                              ;X
            , Y    : Y                                                                                                           }) ;y
}

/*
    Recupera el rectángulo delimitador del elemento especificado e indica si el elemento está visible.
    Parámetros:
        TV     : El objeto control TreeView.
        ItemID : El identificador del elemento.
        Portion: Especifica la porción del elemento a tener en cuenta. 0 indica todo el elemento, 1 indica solo el texto del elemento.
    Return:
        Si tuvo éxito y el elemento es visible devuelve un objeto con las claves X|Y|W|H. Si hubo un error devuelve 0.
*/
TV_GetRect(TV, ItemID, Portion := 0){
    ; RECT structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd162897(v=vs.85).aspx
    Local RECT
    VarSetCapacity(RECT, 16, 0)
    NumPut(ItemID, &RECT, 'Ptr')

    ; TVM_GETITEMRECT message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773610(v=vs.85).aspx
    If (!DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1104, 'Int', Portion, 'UPtr', &RECT))
        Return (FALSE)

    Return ({ X: NumGet(&RECT   , 'Int')
            , Y: NumGet(&RECT+4 , 'Int')
            , W: NumGet(&RECT+8 , 'Int') - NumGet(&RECT  , 'Int')
            , H: NumGet(&RECT+12, 'Int') - NumGet(&RECT+4, 'Int') })
}

/*
    Recupera el texto del elemento especificado.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El identificador del elemento.
        Length: La longitud máxima del texto a recuperar, en caracteres. Por defecto solo recupera los primeros 1000 caracteres.
    Return:
        Si tuvo éxito devuelve el texto del elemento, caso contrario devuelve una cadena vacía.
    ErrorLevel:
        Si hubo un error se establece en 1, caso contrario se establece en 0.
*/
TV_GetText(TV, ItemID, Length := 1000){
    ; TVITEM structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773456(v=vs.85).aspx
    Local TVITEM, Buffer
    VarSetCapacity(Buffer, Length * 2 + 2, 0)
    VarSetCapacity(TVITEM, 28 + A_PtrSize*3, 0)
    NumPut(0x0001  , &TVITEM              , 'UInt')    ; TVITEM.mask       --> TVIF_TEXT
    NumPut(ItemID  , &TVITEM+A_PtrSize    , 'Ptr' )    ; TVITEM.hItem
    NumPut(&Buffer , &TVITEM+A_PtrSize*2+8, 'UPtr')    ; TVITEM.pszText
    NumPut(Length+1, &TVITEM+A_PtrSize*3+8, 'Int' )    ; TVITEM.cchTextMax --> sizeof(Buffer) // 2

    ; TVM_GETITEMW message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773596(v=vs.85).aspx
    If (!DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x113E, 'Ptr', 0, 'UPtr', &TVITEM) && (ErrorLevel := TRUE))
        Return ('')

    VarSetCapacity(Buffer, -1)
    ErrorLevel := FALSE
    Return (Buffer)
}

/*
    Establece el texto del elemento expecificado.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: El identificador del elemento.
        Text  : El nuevo texto para el elemento.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
TV_SetText(TV, ItemID, Text := ''){
    ; TVITEM structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773456(v=vs.85).aspx
    Local TVITEM
    VarSetCapacity(TVITEM, 28 + A_PtrSize*3, 0), Text .= ''
    NumPut(0x0001, &TVITEM              , 'UInt')    ; TVITEM.mask    --> TVIF_TEXT
    NumPut(ItemID, &TVITEM+A_PtrSize    , 'Ptr' )    ; TVITEM.hItem
    NumPut(&Text , &TVITEM+A_PtrSize*2+8, 'UPtr')    ; TVITEM.pszText

    ; TVM_SETITEMW message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773758(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x113F, 'Ptr', 0, 'UPtr', &TVITEM))
}

/*
    Añade un nuevo elemento en el control TreeView especificado.
    Parámetros:
        TV          : El objeto control TreeView.
        Text        : El texto de este nuevo elemento.
        hParent     : El identificador del elemento padre. Si este valor es 0 o -65536, el nuevo elemento se añade en la raíz del control TreeView.
        hInsertAfter: El identificador del elemento después del cual se debe añadir el nuevo elemento, o puede ser uno de los siguientes valores:
            -65535 (TVI_FIRST) = Añade el elemento al comienzo de la lista.
            -65534 (TVI_LAST)  = Añade el elemento al final de la lista.
            -65536 (TVI_ROOT)  = Añade el elemento como elemento raíz.
            -65533 (TVI_SORT)  = Añade el elemento en la lista en orden alfabético.
    Nota:
        Utilizamos la version ANSI de TVM_INSERTITEM junto con TVM_SETITEMW debido a que la versión unicode de TVM_INSERTITEM por algún motivo que desconozco falla.
*/
TV_Insert(TV, Text := '', hParent := -65536, hInsertAfter := -65534){
    ; TVINSERTSTRUCT structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773452(v=vs.85).aspx
    Local TVINSERTSTRUCT
    VarSetCapacity(TVINSERTSTRUCT, 28 + A_PtrSize*5, 0)
    NumPut(hParent     , &TVINSERTSTRUCT          , 'Ptr')    ; TVINSERTSTRUCT.hParent
    NumPut(hInsertAfter, &TVINSERTSTRUCT+A_PtrSize, 'Ptr')    ; TVINSERTSTRUCT.hInsertAfter

    ; TVM_INSERTITEMA message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773733(v=vs.85).aspx
    Local hItem := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1100, 'Ptr', 0, 'UPtr', &TVINSERTSTRUCT, 'Ptr')
    If (!hItem)
        Return (FALSE)

    If ((Text.='') != '')
    {
        ; TVITEM structure
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773456(v=vs.85).aspx
        NumPut(0x001, &TVINSERTSTRUCT+A_PtrSize*2  , 'UInt')    ; TVINSERTSTRUCT.TVITEM.mask    --> TVIF_TEXT
        NumPut(hItem, &TVINSERTSTRUCT+A_PtrSize*3  , 'Ptr' )    ; TVINSERTSTRUCT.TVITEM.hItem
        NumPut(&Text, &TVINSERTSTRUCT+A_PtrSize*4+8, 'UPtr')    ; TVINSERTSTRUCT.TVITEM.pszText

        ; TVM_SETITEMW message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773758(v=vs.85).aspx
        DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x113F, 'Ptr', 0, 'UPtr', &TVINSERTSTRUCT+A_PtrSize*2)
    }

    Return (hItem)
}

/*
    Recupera la longitud, en píxeles, de separación de los elementos secundarios con respecto a sus elementos primarios.
    Parámetros:
        TV: El objeto control TreeView.
    Return:
        Devuelve la longitud de separación, en píxeles.
*/
TV_GetIndent(TV){
; TVM_GETINDENT message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773588(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1106, 'Ptr', 0, 'Ptr', 0))
}

/*
    Establece la longitud, en píxeles, de separación de los elementos secundarios con respecto a sus elementos primarios.
    Parámetros:
        TV    : El objeto control TreeView.
        Indent: La nueva longitud de separación, en píxeles. El valor por defecto es 19. El valor mínimo normalmente es 5 (puede variar).
    Return:
        Devuelve la longitud de separación anterior.
*/
TV_SetIndent(TV, Indent := 19){
    ; TVM_GETINDENT message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773588(v=vs.85).aspx
    Local n := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1106, 'Ptr', 0, 'Ptr', 0)

    ; TVM_SETINDENT message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773750(v=vs.85).aspx
    DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1107, 'Int', Indent, 'Ptr', 0)

    Return (n)
}

/*
    Recupera el color utilizado para dibujar la marca de inserción en el control TreeView especificado.
    Parámetros:
        TV: El objeto control TreeView.
    Return:
        Devuelve el color RGB utilizado para dibujar la marca de inserción.
*/
TV_GetInsertMarkColor(TV){
    ; TVM_GETINSERTMARKCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773590(v=vs.85).aspx
    Local Color := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1126, 'Ptr', 0, 'Ptr', 0)
    Return (Color > 0 ? ((Color & 255) << 16 | (Color & 65280) | (Color >> 16)) : 0)    ; BGR --> RGB
}

/*
    Establece el color utilizado para dibujar la marca de inserción en el control TreeView especificado.
    Parámetros:
        TV   : El objeto control TreeView.
        Color: El nuevo color RGB para la marca de inserción. El color por defecto es gris (0x696969).
    Return:
        Devuelve el color RGB anterior de la marca de inserción.
*/
TV_SetInsertMarkColor(TV, Color := 0x696969){
    ; TVM_SETINSERTMARKCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773755(v=vs.85).aspx
    Color := ((Color & 255) << 16) | (((Color >> 8) & 255) << 8) | (Color >> 16)    ; RGB --> BGR
    Color := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1125, 'Ptr', 0, 'Int', Color)
    Return (Color > 0 ? ((Color & 255) << 16 | (Color & 65280) | (Color >> 16)) : 0)    ; BGR --> RGB
}

/*
    Establece la marca de inserción en el control TreeView especificado.
    Parámetros:
        TV    : El objeto control TreeView.
        ItemID: Especifica el elemento en el que insertar la marca de inserción. Si este valor es 0, la marca de inserción es removida.
        Pos   : Especifica si la marca se posiciona antes o despues del elemento especificado. Si es 0 se posiciona antes, si es 1 se posiciona después.
    Return:
        Devuelve un valor distinto de cero si tuvo éxito. De lo contrario devuelve cero.
*/
TV_SetInsertMark(TV, ItemID := 0, Pos := 0){
    ; TVM_SETINSERTMARK message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773753(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x111A, 'Int', !!Pos, 'Ptr', ItemID))
}

/*
    Recupera la cadena de búsqueda incremental para el control TreeView especificado.
    Parámetros:
        TV: El objeto control TreeView.
    Return:
        Devuelve la cadena de búsqueda incremental. Si el control TreeView no está en modo de búsqueda incremental, el valor de retorno es una cadena vacía.
    Observaciones:
        La cadena de búsqueda incremental se crea cuando el usuario escribe para buscar un elemento y el control TreeView tiene el foco.
        La cadena de búsqueda incremental se elimina en poco más de 1 segundo.
*/
TV_GetISearchStr(TV){
    ; TVM_GETISEARCHSTRINGW message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773592(v=vs.85).aspx
    Local Length := DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1140, 'Ptr', 0, 'UPtr', 0)
    If (!Length)
        Return ('')

    Local Buffer
    VarSetCapacity(Buffer, (Length * 2) + 2)
    DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1140, 'Ptr', 0, 'UPtr', &Buffer)
    VarSetCapacity(Buffer, -1)

    Return (Buffer)
}

/*
    Recupera la altura de los elementos en el control TreeView especificado.
    Parámetros:
        TV: El objeto control TreeView.
    Return:
        Devuelve la altura de los elementos, en píxeles.
*/
TV_GetHeight(TV){
    ; TVM_GETITEMHEIGHT message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773599(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x111C, 'Ptr', 0, 'Ptr', 0))
}

/*
    Establece la altura de los elementos en el control TreeView especificado.
    Parámetros:
        TV    : El objeto control TreeView.
        Height: La nueva altura para los elementos, en píxeles. Valores menor a 1 se establecen en 1, si es -1 usa el valor predeterminado. Si este valor no es par y el control no tiene el estilo TVS_NONEVENHEIGHT, este valor se redondeará al valor par más cercano.
    Return:
        Devuelve la altura de los elementos anterior, en píxeles.
*/
TV_SetHeight(TV, Height := -1){
    ; TVM_SETITEMHEIGHT message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773761(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x111B, 'Int', Height, 'Ptr', 0))
}

/*
    Recupera el identificador a la lista de imagenes asignada al control TreeView especificado.
    Parámetros:
        TV  : El objeto control TreeView.
        Type: El tipo de lista de imagenes a recuperar. Debe ser uno de los siguientes valores:
            0 (TVSIL_NORMAL) = Indica la lista de imágenes normal, que contiene imágenes seleccionadas, no seleccionadas y de superposición.
            2 (TVSIL_STATE)  = Indica la lista de imágenes de estado. Puede utilizar imágenes de estado para indicar estados de elementos definidos por la aplicación. Se muestra una imagen de estado a la izquierda de la imagen seleccionada o no seleccionada de un elemento.
    Return:
        Devuelve el identificador de la lista de imagenes, o cero si el control TreeView no tiene ninguna lista de imagenes asignada.
*/
TV_GetImageList(TV, Type := 0){
    ; TVM_GETIMAGELIST message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773585(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1108, 'Int', Type, 'Ptr', 0, 'Ptr'))
}

/*
    Establece la lista de imagenes en el control TreeView especificado.
    Parámetros:
        TV       : El objeto control TreeView.
        ImageList: El identificador de la nueva lista de imagenes. Si este valor es 0, la lista de imagenes actual es removida, si la hay.
        Type: El tipo de lista de imagenes a establecer. Debe ser uno de los siguientes valores:
            0 (TVSIL_NORMAL) = Indica la lista de imágenes normal, que contiene imágenes seleccionadas, no seleccionadas y de superposición.
            2 (TVSIL_STATE)  = Indica la lista de imágenes de estado. Puede utilizar imágenes de estado para indicar estados de elementos definidos por la aplicación. Se muestra una imagen de estado a la izquierda de la imagen seleccionada o no seleccionada de un elemento.
    Return:
        Devuelve el identificador de la lista de imagenes asignada anteriormente, o cero si no tenía ninguna lista de imagenes asignada.
*/
TV_SetImageList(TV, ImageList := 0, Type := 0){
    ; TVM_SETIMAGELIST message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773747(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x1109, 'Int', Type, 'Ptr', ImageList, 'Ptr'))
}

/*
    Recuper la ruta completa del elemento especificado.
    Parámetros:
        TV       : El objeto control TreeView.
        ItemID   : El identificador del elemento.
        Delimiter: La cadena a utilizar como separador.
    Return:
        Devuelve la ruta completa de ItemID.
*/
TV_GetPath(TV, ItemID, Delimiter := '\'){
    If (TV_GetText(TV, ItemID) == '' && ErrorLevel)
        Return ('')

    Local Path
    Loop
        Path := TV_GetText(TV, ItemID) . Delimiter . Path
    Until (ErrorLevel || !(ItemID := TV_GetParent(TV, ItemID)))

    Return (SubStr(Path, 1, -StrLen(Delimiter)))
}

/*  NO FUNCIONA COMO CORRESPONDE! NO FUNCIONA CON SUB-ITEMS! NO SE PUEDEN MOVER LOS ELEMENTOS! (TÍPICO DE WINDOWS) NO COPIA SUB-ELEMENTOS NI ICONOS!
    Comienza una operación de arrastrar y soltar para el elemento bajo el cursor.
    Parámetros:
        TV: El objeto control TreeView.
    Observaciones:
        Esta función normalmente debe ser llamada cuando se procesa el mensaje TVN_BEGINDRAG. Ver el ejemplo.
    Return:
        Devuelve el identificador del nuevo elemento, o cero si no se ha realizado ninguna operación.
    Ejemplo:
        TV.OnNotify(-456, Func('TVN_BEGINDRAG')) ;TVN_BEGINDRAG notification code: https://msdn.microsoft.com/es-es/library/bb773504
        TVN_BEGINDRAG(TV, pNMTREEVIEW)
        {
            TV_DragDrop(TV)
        }
*/
TV_DragDrop(TV){
    Local HitTest, Rect, Pos
        , ItemID := TV_GetSelection(TV)    ; el identificador del ememento que se va a mover
        , H      := TV.Pos.H               ; la altura del control TreeView, para determinar si se debe desplazar la barra vertical hacia abajo.

    While (GetKeyState('LButton'))
    {
        If ((HitTest := TV_HitTest(TV)) && HitTest.Item)
        {
            If (HitTest.Y < 5 || HitTest.Y > H-5)    ; arriba || abajo
                DllCall('User32.dll\PostMessageW', 'Ptr', TV.Hwnd, 'UInt', 0x0115, 'Int', HitTest.Y > H-5, 'Ptr', 0)
            TV_Select(TV, HitTest.Item, 8)
            Rect := TV_GetRect(TV, HitTest.Item)
            TV_SetInsertMark(TV, HitTest.Item, Pos := HitTest.Y-Rect.Y > Rect.H//2-1)
        }
        Else
            TV_SetInsertMark(TV)
        Sleep(100)
    } TV_SetInsertMark(TV), TV_Select(TV,, 8)

    Local NewItemID := 0
    If (HitTest && HitTest.Item)
    {
        TV.Opt('-Redraw')
        Local PrevID       := Pos ? 0              : TV_GetPrev(TV, HitTest.Item)
            , hInsertAfter := Pos ? (HitTest.Item) : (PrevID ? PrevID : -65535)
        NewItemID := TV_Insert(TV, TV_GetText(TV, ItemID),, hInsertAfter)
        TV_Delete(TV, ItemID)
        TV.Opt('+Redraw')
        TV_Select(TV, NewItemID), TV_EnsureVisible(TV, NewItemID)
    }

    Return (NewItemID)
}
