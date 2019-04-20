/*
    Añade un elemento en la posición especificada.
    Parámetros:
        Tab       : El objeto control TAB.
        N         : La posición en la que añadir el nuevo elemento. Si este valor es 0, el elemento se añade al último.
        Text      : El texto para este elemento.
        ImageIndex: El índice del icono en la lista de imagenes asignada a este control TAB. Si este valor es 0, el icono actual es removido del elemento.
    Return:
        Si tuvo éxito devuelve el índice del nuevo elemento, caso contrario devuelve 0.
*/
Tab_Insert(Tab, N := 0, Text := '', ImageIndex := 0)
{
    ; TCITEM structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760554(v=vs.85).aspx
    Local TCITEM
    VarSetCapacity(TCITEM, 20 + A_PtrSize*2, 0), Text .= ''
        NumPut(0x01 | 0x02 , &TCITEM                , 'UInt')    ; TCITEM.mask    --> TCIF_TEXT | TCIF_IMAGE
        NumPut(&Text       , &TCITEM+8+A_PtrSize    , 'UPtr')    ; TCITEM.pszText
        NumPut(ImageIndex-1, &TCITEM+8+A_PtrSize*2+4, 'Int' )    ; TCITEM.iImage

    ; TCM_INSERTITEMW message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760606(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x133E, 'Int', N?N-1:Tab_GetCount(Tab), 'UPtr', &TCITEM)+1)
}




/*
    Añade elementos al final del control TAB especificado.
    Parámetros:
        Tab : El objeto control TAB.
        Item: Los elementos a añadir.
    Return:
        Si tuvo éxito devuelve el índice del primer elemento añadido, caso contrario devuelve 0.
*/
Tab_Add(Tab, Item*)
{
    ; TCITEM structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760554(v=vs.85).aspx
    Local TCITEM
    VarSetCapacity(TCITEM, 20 + A_PtrSize*2, 0)
        NumPut(0x0001, &TCITEM, 'UInt')   ; TCITEM.mask --> TCIF_TEXT

    Local Each, Text
        , Index := Tab_GetCount(Tab) + 1
        , First := 0
    For Each, Text in (IsObject(Item[1]) ? Item[1] : Item)
    {
        Text .= ''
        NumPut(&Text, &TCITEM+8+A_PtrSize, 'UPtr')   ; TCITEM.pszText

        ; TCM_INSERTITEMW message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760606(v=vs.85).aspx
        If (!(Index := DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x133E, 'Int', Index, 'UPtr', &TCITEM) + 1))
            Return (0)

        If (A_Index == 1)
            First := Index
    }

    Return (First)
}




/*
    Establece la posición del elemento especificado.
    Parámetros:
        Tab : El objeto control TAB.
        N   : La posición del elemento a mover. Si este valor es 0, se utiliza la posición del elemento seleccionado.
        NewN: La nueva posición del elemento. Si este valor es 0, el elemento se posiciona al final.
    Return:
        Si tuvo éxito devuelve la nueva posición del elemento, caso contrario devuelve 0.
*/
Tab_SetPos(Tab, N := 0, NewN := 0)
{
    Local Text := Tab_GetText(Tab, N)
    If (ErrorLevel || !Tab_Delete(Tab, N))
        Return (0)

    Return (Tab_Insert(Tab, NewN?NewN:Tab_GetCount(Tab)+1, Text))
}




/*
    Recupera la posición del elemento que coincide con el texto especificado.
    Parámetros:
        Tab          : El objeto control TAB.
        Text         : El texto del elemento.
        CaseSensitive: Determina si la cadena especificada en Text es sensible a mayúsculas y minúsculas.
    Return:
        Si el elemento se ha encontrado devuelve su posición, caso contrario devuelve 0.
*/
Tab_GetPos(Tab, Text, CaseSensitive := FALSE)
{
    Loop (Tab_GetCount(Tab))
        If ((!CaseSensitive && Tab_GetText(Tab, A_Index) = Text) || (CaseSensitive && Tab_GetText(Tab, A_Index) == Text))
            Return (A_Index)
    Return (0)
}




/*
    Recupera la posición del elemento seleccionado en el control TAB especificado.
    Parámetros:
        Tab: El objeto control TAB.
    Return:
        Devuelve la posición del elemento seleccionado, o cero si no hay ningún elemento seleccionado.
*/
Tab_GetSelection(Tab)
{
    ; TCM_GETCURSEL message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760583(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x130B, 'Ptr', 0, 'Ptr', 0)+1)   
}




/*
    Selecciona el elemento especificado.
    Parámetros:
        Tab: El objeto control TAB.
        N  : La posición del elemento a seleccionar.
    Return:
        Si tuvo éxito devuelve la posición del elemento seleccionado anteriormente, caso contrario devuelve 0.
*/
Tab_SetSelection(Tab, N)
{
    ; TCM_SETCURSEL message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760612(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x130C, 'Int', N-1, 'Ptr', 0)+1)
}




/*
    Recupera la cantidad de elementos o filas en el control TAB especificado.
    Parámetros:
        Tab : El objeto control TAB.
        Rows: Si se establece en 1, la función devuelve el número de filas en el control, que es siempre 1 si el control TAB no tiene el estilo TCS_MULTILINE.
    Return:
        Devuelve la cantidad de elementos en el control.
    Observaciones:
        Solo los controles TAB que tengan el estilo TCS_MULTILINE (0x200) pueden tener más de una fila.
*/
Tab_GetCount(Tab, Rows := FALSE)
{
    If (Rows)
        ; TCM_GETROWCOUNT message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760596(v=vs.85).aspx
        Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x132C, 'Ptr', 0, 'Ptr', 0))

    ; TCM_GETITEMCOUNT message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760592(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x1304, 'Ptr', 0, 'Ptr', 0))
}




/*
    Elimina el elemento especificado.
    Parámetros:
        Tab: El objeto control TAB.
        N  : La posición del elemento a eliminar. Si este valor es 0, se utiliza la posición del elemento seleccionado.
    Return:
        Si tuvo éxito devuelve la posición que ocupaba el elemento eliminado, caso contrario devuelve 0.
*/
Tab_Delete(Tab, N := 0)
{
    ; TCM_DELETEITEM message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760577(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x1308, 'Int', N:=(N?N:Tab_GetSelection(Tab))-1, 'Ptr', 0) ? N+1 : 0)
}




/*
    Elimina todo los elementos en el control TAB especificado.
    Parámetros:
        Tab: El objeto control TAB.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
Tab_DeleteAll(Tab)
{
    ; TCM_DELETEALLITEMS message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760575(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x1309, 'Ptr', 0, 'Ptr', 0))
}




/*
    Establece el texto del elemento especificado.
    Parámetros:
        Tab    : El objeto control TAB.
        N      : La posición del elemento. Si este valor es 0, se utiliza la posición del elemento seleccionado.
        NewText: El nuevo texto para el elemento.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
Tab_SetText(Tab, N := 0, NewText := '')
{
    ; TCITEM structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760554(v=vs.85).aspx
    Local TCITEM
    VarSetCapacity(TCITEM, 20 + A_PtrSize*2, 0), NewText .= ''
        NumPut(0x000001, &TCITEM            , 'UInt')   ; TCITEM.mask    --> TCIF_TEXT
        NumPut(&NewText, &TCITEM+8+A_PtrSize, 'UPtr')   ; TCITEM.pszText

    ; TCM_SETITEMW message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760631(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x133D, 'Int', (N?N:Tab_GetSelection(Tab))-1, 'UPtr', &TCITEM))
}




/*
    Recupera el texto del elemento especificado.
    Parámetros:
        Tab    : El objeto control TAB.
        N      : La posición del elemento. Si este valor es 0, se utiliza la posición del elemento seleccionado.
    Return:
        Si tuvo éxito devuelve el texto del elemento especificado, caso contrario devuelve una cadena vacía.
    ErrorLevel:
        Si hubo un error se establece en 1, caso contrario se establece en 0.
*/
Tab_GetText(Tab, N := 0)
{
    ; TCITEM structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760554(v=vs.85).aspx
    Local TCITEM
    VarSetCapacity(TCITEM, 20 + A_PtrSize*2, 0)
        NumPut(0x00001, &TCITEM              , 'UInt')   ; TCITEM.mask       --> TCIF_TEXT
        VarSetCapacity(Buffer, 1000, 0)
        NumPut(&Buffer, &TCITEM+8+A_PtrSize  , 'UPtr')   ; TCITEM.pszText
        NumPut(500    , &TCITEM+8+A_PtrSize*2, 'Int' )   ; TCITEM.cchTextMax --> sizeof(Buffer)//2

    ; TCM_GETITEMW message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760589(v=vs.85).aspx
    If (!DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x133C, 'Int', (N?N:Tab_GetSelection(Tab))-1, 'UPtr', &TCITEM))
    {
        ErrorLevel := TRUE
        Return ('')
    }

    ErrorLevel := FALSE
    Return (StrGet(&Buffer, 'UTF-16'))
}




/*
    Establece el estado de resaltado del elemento especificado.
    Parámetros:
        Tab    : El objeto control TAB.
        N      : La posición del elemento. Si este valor es 0, se utiliza la posición del elemento seleccionado.
        State  : El estado a establecer. Debe ser TRUE o FALSE.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
Tab_Highlight(Tab, N := 0, State := TRUE)
{
    ; TCM_HIGHLIGHTITEM message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760602(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x1333, 'Int', (N?N:Tab_GetSelection(Tab))-1, 'UInt', !!State))
}




/*
    Establece una lista de imágenes al control TAB especificado.
    Parámetros:
        Tab      : El objeto control TAB.
        ImageList: El identificador de la lista de imágenes.
    Return:
        Devuelve el identificador a la lista de imágenes anterior o cero si no hay ninguna lista de imágenes anterior.
*/
Tab_SetImageList(Tab, ImageList)
{
    ; TCM_SETIMAGELIST message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760629(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x1303, 'Ptr', 0, 'Ptr', ImageList, 'Ptr'))
}




/*
    Recupera el identificador de la lista de imágenes asignada al control TAB especificado.
    Parámetros:
        Tab: El objeto control TAB.
    Return:
        Si tuvo éxito devuelve el identificador, caso contrario devuelve 0.
*/
Tab_GetImageList(Tab)
{
    ; TCM_GETIMAGELIST message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760588(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x1302, 'Ptr', 0, 'Ptr', 0, 'Ptr'))
}




/*
    Establece un icono al elemento especificado.
    Parámetros:
        Tab       : El objeto control TAB.
        N         : La posición del elemento. Si este valor es 0, se utiliza la posición del elemento seleccionado.
        ImageIndex: El índice del icono en la lista de imagenes asignada a este control TAB. Si este valor es 0, el icono actual es removido del elemento.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
Tab_SetImageIndex(Tab, N := 0, ImageIndex := 0)
{
    ; TCITEM structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760554(v=vs.85).aspx
    Local TCITEM
    VarSetCapacity(TCITEM, 20 + A_PtrSize*2, 0), Text .= ''
        NumPut(0x0002      , &TCITEM                , 'UInt')   ; TCITEM.mask   --> TCIF_IMAGE
        NumPut(ImageIndex-1, &TCITEM+8+A_PtrSize*2+4, 'Int')    ; TCITEM.iImage

    ; TCM_SETITEMW message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760631(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x133D, 'Int', (N?N:Tab_GetSelection(Tab))-1, 'UPtr', &TCITEM))
}




/*
    Recupera el rectángulo delimitador del elemento especificado.
    Parámetros:
        Tab: El objeto control TAB.
        N  : La posición del elemento. Si este valor es 0, se utiliza la posición del elemento seleccionado.
    Return:
        Si tuvo éxito devuelve un objeto con las claves X|Y|W|H, caso contrario devuelve 0.
*/
Tab_GetRect(Tab, N := 0)
{
    ; RECT structure
    ; https://msdn.microsoft.com/en-us/library/dd162897(v=vs.85).aspx
    Local RECT
    VarSetCapacity(RECT, 16)

    ; TCM_GETITEMRECT message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760594(v=vs.85).aspx
    If (!DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x130A, 'Int', (N?N:Tab_GetSelection(Tab))-1, 'UPtr', &RECT))
        Return (FALSE)

    Return ({ X: NumGet(&RECT   , 'Int')
            , Y: NumGet(&RECT+4 , 'Int')
            , W: NumGet(&RECT+8 , 'Int') - NumGet(&RECT  , 'Int')
            , H: NumGet(&RECT+12, 'Int') - NumGet(&RECT+4, 'Int') })
}




/*
    Recupera información en base a las coordenadas relativas al área del control TAB especificado.
    Parámetros:
        Tab: El objeto control TAB.
        X  : La coordenada X. Relativa al área del control.
        Y  : La coordenada Y. Relativa al área del control.
    Return:
        Devuelve un objeto con las siguientes claves:
            Index = El índice del elemento (posición), o 0 si no hay ningún elemento en las coordenadas especificadas.
            Flags = Devuelve un valor con información adicional. Estos son los valores válidos:
                1 (TCHT_NOWHERE)     = La posición no se encuentra sobre un elemento.
                2 (TCHT_ONITEMICON)  = La posición se encuentra sobre el icono de un elemento.
                4 (TCHT_ONITEMLABEL) = La posición se encuentra sobre el texto de un elemento.
                6 (TCHT_ONITEM)      = La posición se encuentra sobre un elemento, pero no sobre su icono o sobre su texto.
        Si hubo un error devuelve 0.
    Observaciones:
        Si 'X' y 'Y' se omiten, se tienen en cuenta las coordenadas del cursor.
*/
Tab_HitTest(Tab, X := '', Y := '')
{
    If (X == '' && Y == '')
    {
        ; POINT structure
        ; https://msdn.microsoft.com/en-us/library/dd162805(v=vs.85).aspx
        Local POINT
        VarSetCapacity(POINT, 8)
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648390(v=vs.85).aspx
        DllCall('User32.dll\GetCursorPos', 'UPtr', &POINT)
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd162952(v=vs.85).aspx
        If (!DllCall('User32.dll\ScreenToClient', 'Ptr', Tab.Hwnd, 'UPtr', &POINT))
            Return (FALSE)
        X := NumGet(&POINT, 'Int'), Y := NumGet(&POINT+4, 'Int') ;x,y
    }

    ; TCHITTESTINFO structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760553(v=vs.85).aspx
    Local TCHITTESTINFO
    VarSetCapacity(TCHITTESTINFO, 12)
    NumPut(X, &TCHITTESTINFO  , 'Int') ;pt.x
    NumPut(Y, &TCHITTESTINFO+4, 'Int') ;pt.y

    ; TCM_HITTEST message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760604(v=vs.85).aspx
    Return ({ Index: DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x130D, 'Ptr', 0, 'UPtr', &TCHITTESTINFO) + 1
            , Flags: NumGet(&TCHITTESTINFO+8, 'UInt')                                                                          }) ;flags
}




/*
    Establece el ancho y la altura de los elementos en el control TAB especificado.
    Parámetros:
        Tab   : El objeto control TAB.
        Width : El nuevo ancho deseado. Este valor solo tiene efecto si el control TAB tiene el estilo TCS_FIXEDWIDTH (0x400).
        Height: El nuevo alto deseado. El alto por defecto es 18.
    Return:
        Devuelve un objeto con las claves W|H que contienen el ancho y alto anterior.
*/
Tab_SetSize(Tab, Width := 0, Height := 18)
{
    ; TCM_SETITEMSIZE message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760635(v=vs.85).aspx
    Local Size := DllCall('User32.dll\SendMessageW', 'Ptr', Tab.Hwnd, 'UInt', 0x1329, 'Ptr', 0, 'Int', (Width&0xFFFF)|(Height<<16))

    Return ({ W: Size & 0xFFFF
            , H: Size >> 16    })
}
