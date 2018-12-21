/*    ---- EXAMPLE! ----
    Gui := GuiCreate()
    CBE := new ComboBoxEx(Gui, "x5 y5 w200 r10", "Item #0", "Item #1")
        CBE.OnCommand(1, "CBN_SELCHANGE")
        CBE.OnCommand(5, "CBN_EDITCHANGE")
    DDL := new ComboBoxEx(Gui, "x5 y50 w200 +0x3 r10 Choose0", "Item #0", "Item #1", "Item #2", "Item #3", "Item #4")
        DDL.OnCommand(1, "CBN_SELCHANGE")
    Gui.Show()
        Gui.OnEvent("Close", "ExitApp")

    CBE.SetImageList(IL_Create())
    IL_Add(CBE.GetImageList(), "shell32.dll", -4)
    IL_Add(CBE.GetImageList(), "shell32.dll", -16)

    Loop 49
        CBE.Add(-1, "Item #" . (A_Index+1),,,, 1)
    CBE.Selected := 10
    CBE.SetImage(0, 1, 1)
    CBE.SetIndent(0, 4)

    OnMessage(0x100, "WM_KEYDOWN")
    Return

    WM_KEYDOWN(VK_CODE)             ; función llamada cuando se presiona una tecla en nuestra ventana Gui
    {
        SetTimer("Timer", -50)
        return 1
        Timer()
        {
            global CBE, DDL             ; para acceder a las variables globales CBE y DDL
            static VK_DELETE := 0x2E    ; DEL Key
            if (VK_CODE == VK_DELETE)   ; si se presionó la tecla Suprimir
            {
                if (CBE.Focused == 2)        ; si el control de edición de CBE tiene el foco
                    CBE.Delete(CBE.Selected, CBE.Selected ? CBE.Selected - 1 : 0)
                else if (DDL.Focused)        ; si el control DDL tiene el foco
                    DDL.Delete(DDL.Selected, DDL.Selected ? DDL.Selected - 1 : 0)
            }
        }
    }

    CBN_SELCHANGE(GuiControl)       ; función llamada cuando se modifica el control de edición del ComboBox
    {
        GuiControl := new ComboBoxEx(GuiControl)         ; recupera el objeto ComboBoxEx
        ToolTip("CBN_SELCHANGE`n" . GuiControl.Text)     ; muestra el texto del control de edición
        SetTimer("ToolTip", -1000)
    }

    CBN_EDITCHANGE(GuiControl)     ; función llamada cuando se selecciona un elemento
    {
        GuiControl := new ComboBoxEx(GuiControl)
        ToolTip("CBN_EDITCHANGE`n[" . GuiControl.GetTextLength() . "] " . GuiControl.Text)
        SetTimer("ToolTip", -1000)
    }
*/





Class ComboBoxEx
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    static psendmsg := DllCall("Kernel32.dll\GetProcAddress", "Ptr", DllCall("Kernel32.dll\GetModuleHandle", "Str", "User32.dll", "Ptr"), "AStr", "SendMessageW", "UPtr")
    static CtrlList := {}    ; almacena una lista con todos los controles: {ControlID:ComboBoxExObj}.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    /*
        Añade un control ComboBoxEx en la ventana GUI especificada.
        Parámetros:
            Gui:
                El objeto de ventana GUI. También puede especificar un objeto control existente (o su identificador).
            Options:
                Las opciones para el nuevo control. A continuación se describen algunas opciones "especiales". El valor por defecto es CBS_DROPDOWN.
                0x1 (CBS_SIMPLE)       = Muestra el cuadro de lista en todo momento. La selección actual en el cuadro de lista se muestra en el control de edición.
                0x2 (CBS_DROPDOWN)     = El cuadro de lista no se muestra a menos que el usuario seleccione un ícono al lado del control de edición.
                0x3 (CBS_DROPDOWNLIST) = Similar a CBS_DROPDOWN, excepto que el control de edición se reemplaza por un elemento de texto estático que muestra la selección actual en el cuadro de lista.
                Para especificar la opción CBS_SIMPLE especificar en las opciones "-0x2". Para CBS_DROPDOWNLIST especificar "+0x3".
                ChooseN  = El elemento que estará seleccionado por defecto. N es el índice basado en cero del elemento a seleccionar.
            Items:
                Una lista de elementos a añadir en el control.
    */
    __New(Gui, Options := "", Items*)
    {
        if (ObjHasKey(ComboBoxEx.CtrlList, IsObject(Gui) ? Gui.Hwnd : Gui))
            return ComboBoxEx.CtrlList[IsObject(Gui) ? Gui.Hwnd : Gui]

        ; ComboBoxEx Control Reference
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775740.aspx
        this.ctrl := Gui.AddCustom("ClassComboBoxEx32 +0x40 +0x2 " . (RegExMatch(Options, "i)\bh(\d+)\b")?"+0x400 ":"") . Options)
        this.hWnd := this.ctrl.Hwnd
        this.gui  := Gui
        this.Type := "ComboBoxEx"

        ; tagCOMBOBOXEXITEMA structure
        ; https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/ns-commctrl-tagcomboboxexitema
        ; CBEIF_TEXT  = 0x00000001 | CBEIF_LPARAM        = 0x00000020 | CBEIF_INDENT  = 0x00000010
        ; CBEIF_IMAGE = 0x00000002 | CBEIF_SELECTEDIMAGE = 0x00000004 | CBEIF_OVERLAY = 0x00000008
        this.COMBOBOXEXITEM := {Buffer: ""}
        ObjSetCapacity(this.COMBOBOXEXITEM, "Buffer", A_PtrSize == 4 ? 36 : 56)
        Local p := ObjGetAddress(this.COMBOBOXEXITEM, "Buffer")
        Local k := "", v := this.COMBOBOXEXITEM.Ptr := p
        For k, v in {mask: p, iItem: p+A_PtrSize, pszText: p+A_PtrSize*2, cchTextMax: p+A_PtrSize*3, iImage: p+A_PtrSize*3+4, iSelectedImage: p+A_PtrSize*3+8, iOverlay: p+A_PtrSize*3+12, iIndent: p+A_PtrSize*3+16, lParam: p+A_PtrSize*4+16}
            ObjRawSet(this.COMBOBOXEXITEM, k, v)

        ObjRawSet(this.CtrlList, this.hWnd, this)   ; añade este control a la lista
        this.SetItemHeight(SysGet(49) + 2 * 2)      ; ajusta el alto de lo elementos en la lista para la correcta visualización de iconos pequeños
        this.ExStyle := 0x8                         ; quita limites de tamaño vertical

        ; establece la altura del control
        local foo := "", bar := ""
        if (RegExMatch(Options, "i)\bh(\d+)\b", foo))
        {
            if (foo[1] >= (bar := this.GetItemHeight()))    ; an application must ensure that the height of the selection field is not smaller than the height of a particular list item.
            {
                while (this.pos.h != foo[1] && this.SetItemHeight(bar+A_Index-1, -1))
                    continue
            }
        }

        ; añade los elementos especificados y selecciona el elemento especificado
        If (ObjLength(Items))
        {
            For foo, bar in Items
                this.Add(foo-1, String(bar))
            If (RegExMatch(Options, "i)\bchoose(\d+)\b", foo))
                this.Selected := foo[1]
        }
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Elimina el control.
    */
    Destroy()
    {
        ObjDelete(this.CtrlList, this.hWnd)
        DllCall("User32.dll\DestroyWindow", "Ptr", this.hWnd)
    }

    /*
        Añade un elemento en la posición especificada.
        Parámetros:
            Item:
                El índice basado en cero del nuevo elemento. Para insertar un elemento al final de la lista, establezca el parámetro en -1.
            Text:
                El texto del nuevo elemento. Puede ser una cadena vacía. Puede haber elementos con el mismo texto. Este parámetro debe ser una cadena.
            Image:
                El índice basado en cero de una imagen dentro de la lista de imágenes. La imagen especificada se mostrará para el elemento cuando no esté seleccionado.
            SelImage:
                El índice basado en cero de una imagen dentro de la lista de imágenes. La imagen especificada se mostrará para el elemento cuando se seleccione.
            Overlay:
                El índice basado en una sola imagen dentro de la lista de imágenes.
            Indent:
                El número de espacios de sangría para mostrar en el elemento. Cada sangría es igual a 10 píxeles.
            lParam:
                Un valor específico para el elemento.
        Return:
            Devuelve el índice en el que se insertó el nuevo elemento si fue exitoso, o -1 en caso contrario.
    */
    Add(Item := -1, ByRef Text := "", Image := 0, SelImage := 0, Overlay := 0, Indent := 0, lParam := 0)
    {
        ; CBEM_INSERTITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-insertitem
        NumPut(0x31 | (Image==-1?0:2) | (SelImage==-1?0:4) | (Overlay==-1?0:8), this.COMBOBOXEXITEM.mask, "UInt")    ; UINT mask
      , NumPut(Item    , this.COMBOBOXEXITEM.iItem         , "Ptr" )   ; INT_PTR iItem
      , NumPut(&Text   , this.COMBOBOXEXITEM.pszText       , "UPtr")   ; LPSTR   pszText
      , NumPut(Indent  , this.COMBOBOXEXITEM.iIndent       , "Int" )   ; int     iIndent
      , NumPut(lParam  , this.COMBOBOXEXITEM.lParam        , "Ptr" )   ; LPARAM  lParam
      , NumPut(Image   , this.COMBOBOXEXITEM.iImage        , "Int")    ; int     iImage
      , NumPut(SelImage, this.COMBOBOXEXITEM.iSelectedImage, "Int")    ; int     iSelectedImage
      , NumPut(Overlay , this.COMBOBOXEXITEM.iOverlay      , "Int")    ; int     iOverlay
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x40B, "Ptr", 0, "UPtr", this.COMBOBOXEXITEM.Ptr)
    }

    /*
        Recupera el texto del elemento expecificado.
        Parámetros:
            Item:
                El índice basado en cero del elemento cuyo texto se va a recuperar. Establecer el parámetro en -1 recuperará el elemento que se muestra en el control de edición.
            Length:
                La cantidad máxima de caracteres a recuperar. Si este parámetro es -1, recupera el texto entero.
        Return:
            Si tuvo éxito devuelve el texto del elemento. Si hubo un error devuelve una cadena vacía.
            ErrorLevel se establece en cero si tuvo éxito, o un valor distinto de cero si hubo un error.
    */
    GetText(Item := -1, Length := -1)
    {
        ; CB_GETLBTEXTLEN message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775864(v=vs.85).aspx
        local len := Length == -1 ? DllCall(this.psendmsg, "Ptr", this.Hwnd, "UInt", 0x149, "Ptr", Item, "Ptr", 0) : Integer(Length)
        if (((len == -1 || Length < -1) && (ErrorLevel := 1)) || !len)    ; si la longitud del texto es cero o hubo un error, devolvemos directamente una cadena vacía
            return ""

        ; CBEM_GETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-getitem
        NumPut(1, this.COMBOBOXEXITEM.mask, "UInt")
      , NumPut(Item, this.COMBOBOXEXITEM.iItem, "Ptr")
        local Buffer := ""
        VarSetCapacity(Buffer, len * 2 + 2)    ; +2 = \0
      , NumPut(&Buffer, this.COMBOBOXEXITEM.pszText, "UPtr")
      , NumPut(len + 1, this.COMBOBOXEXITEM.cchTextMax, "Int")
      , ErrorLevel := !DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x40D, "Ptr", 0, "UPtr", this.COMBOBOXEXITEM.Ptr)
        return ErrorLevel ? "" : StrGet(&Buffer, len, "UTF-16")
    }

    /*
        Recupera la cantidad de caracteres en el texto asignado al elemento especificado.
        Parámetros:
            Item:
                El índice basado en cero del elemento cuya cantidad de caracteres en el texto se va a recuperar. -1 para el control de edición.
        Return:
            Devuelve la cantidad de caracteres en el texto. Si el elemento especificado no existe, devuelve -1.
    */
    GetTextLength(Item := -1)
    {
        ; CB_GETLBTEXTLEN message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775864(v=vs.85).aspx
        return DllCall(this.psendmsg, "Ptr", this.Hwnd, "UInt", 0x149, "Ptr", Item, "Ptr", 0)
    }

    /*
        Establece el texto del elemento especificado.
        Parámetros:
            Item:
                El índice basado en cero del elemento cuyo texto se va a cambiar. Establecer el parámetro en -1 establecerá el elemento que se muestra en el control de edición.
        Return:
            Devuelve un valor distinto de cero si tiene éxito, o cero de lo contrario.
    */
    SetText(Item := -1, ByRef Text := "")
    {
        ; CBEM_SETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-setitem
        NumPut(1, this.COMBOBOXEXITEM.mask, "UInt")
      , NumPut(Item, this.COMBOBOXEXITEM.iItem, "Ptr")
      , NumPut(&Text, this.COMBOBOXEXITEM.pszText, "UPtr")
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x40C, "Ptr", 0, "UPtr", this.COMBOBOXEXITEM.Ptr)
    }

    /*
        Elimina el elemento especificado en la lista.
        Parámetros:
            Item:
                El índice basado en cero del elemento a eliminar.
            Select:
                Cuando elimina un elemento, el texto en el control de edición se mantiene. Si el control tiene el estilo CBS_DROPDOWNLIST, el control queda en blanco (sin elemento seleccionado).
                Si es un entero, especifica el índice basado en cero del elemento a seleccionar una vez eliminado el elemento especificado.
                Si es una cadena, especifica el nuevo texto en el control de edición a establecer una vez eliminado el elemento especificado. No es válido si el control tiene el estilo CBS_DROPDOWNLIST.
        Return:
            Devuelve el número de elementos restantes en la lista.
    */
    Delete(Item, Select := -1)
    {
        ; CBEM_DELETEITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-deleteitem
        local ret := DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x144, "Ptr", Item, "Ptr", 0)
        if (Type(Select) == "Integer" && Select != -1)
            this.Selected := Select
        else if (Type(Select) == "String")
            this.SetEditText(Select)
        return ret
    }

    /*
        Elimina todos los elementos en la lista y edita el control de edición.
        Parámetros:
            EditText:
                El texto a establecer en el control de edición. Por defecto no se ve afectado. Debe especificar una cadena.
        Return:
            El mensaje siempre devuelve 0 (CB_OKAY).
    */
    DeleteAll(EditText := 0)
    {
        ; CB_RESETCONTENT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-resetcontent
        local ret := DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x14B, "Ptr", 0, "Ptr", 0)
        if (Type(EditText) == "String")
            this.SetEditText(EditText)
        return ret
    }

    /*
        Recupera la cantidad de elementos actualmente en la lista.
    */
    GetCount()
    {
        ; CB_GETCOUNT message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775841(v=vs.85).aspx
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x146, "Ptr", 0, "Ptr", 0)
    }

    /*
        Encuentra el índice basado en cero del primer elemento cuyo texto que coincide con la cadena especificada.
        Parámetros: 
            Text:
                El texto del elemento que se va a buscar.
            Item:
                El índice basado en cero del elemento desde el cual empezar a buscar (inclusive).
                Cuando la búsqueda llega al final, continúa desde la parte superior hasta el elemento especificado.
                Puede especificar un objeto con las claves Start y End que especifican el rango exacto en el que realizar la búsqueda.
            Mode:
                Determina el comportamiento de la búsqueda. Debe especificar uno de los siguientes valores.
                0 = Busca el elemento cuyo texto coincide exactamente con la cadena especificada. Este es el modo por defecto.
                1 = Busca el elemento cuyo texto comience por la cadena especificada. 
                2 = Busca el elemento cuyo texto coincida de forma parcial con la cadena especificada.
            CaseSensitive:
                Especifica si la búsqueda distingue entre minúsculas y mayúsculas. Por defecto es cero (FALSE).
            Length:
                La cantidad de caracteres que se va a recuperar al realizar la comparación. Este parámetro solo es válido con los modos 0 y 2.
        Return:
            El valor de retorno es el índice basado en cero del elemento coincidente. -1 si la búsqueda no ha tenido éxito.
    */
    FindString(Text, Item := 0, Mode := 0, CaseSensitive := FALSE, Length := -1)
    {
        local len := StrLen(Text), itm := IsObject(Item) ? Item : {start: Item, end: -1}
        Loop (this.GetCount())
        {
            if (A_Index - 1 < itm.start)
                continue
            if (A_Index - 1 == itm.end)
                break
            if (Mode == 2 && InStr(this.GetText(A_Index-1,Length), Text, CaseSensitive))
            || (Mode != 2 && ( (CaseSensitive  && Text == this.GetText(A_Index-1,Mode?len:Length))
                          ||   (!CaseSensitive && Text  = this.GetText(A_Index-1,Mode?len:Length)) ))
                return A_Index - 1
        }
        return IsObject(Item) ? -1 : this.FindString(Text, {start: 0, end: itm.start}, Mode, CaseSensitive)
    }

    /*
        Obtiene el identificador del control de edición. Un control ComboBoxEx utiliza un cuadro de edición cuando se establece en el estilo CBS_DROPDOWN.
    */
    GetEditControl()
    {
        ; CBEM_GETEDITCONTROL message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-geteditcontrol
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x407, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Determina si el usuario ha cambiado el texto en el control de edición.
    */
    HasEditChanged()
    {
        ; CBEM_HASEDITCHANGED message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-haseditchanged
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x40A, "Ptr", 0, "Ptr", 0)
    }

    /*
        Recupera las posiciones de carácter inicial y final de la selección actual en el control de edición.
        Return:
            Devuelve un objeto con las claves Start y End indicando el carácter inicial y final respectivamente.
    */
    GetEditSel()
    {
        ; CB_GETEDITSEL message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775853(v=vs.85).aspx
        local StartingPos := 0, EndingPos := 0
        DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x140, "UIntP", StartingPos, "UIntP", EndingPos)
        return {Start: StartingPos, End: EndingPos}
    }

    /*
        Selecciona carácteres en el control de edición.
        Parámetros:
            StartingPos:
                La posición basada en cero del caracter que indica el comienzo de la selección. Si este parámetro es -1 se remueve la selección actual, si la hay.
            EndingPos:
                La posición basada en cero del caracter que indica el final de la selección. Si este parámetro es -1 se seleccionan todos los caracteres a partir de StartingPos.
        Return:
            Si se envia a un control ComboBox devuelve TRUE, si se envía a un control DropDownList devuelve -1 (CB_ERR).
    */
    SetEditSel(StartingPos, EndingPos)
    {
        ; CB_SETEDITSEL message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775903(v=vs.85).aspx
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x142, "Ptr", 0, "Int", (StartingPos & 0xFFFF) | (EndingPos & 0xFFFF) << 16)
    }

    /*
        Recupera el texto en el control de edición. Un control ComboBoxEx utiliza un cuadro de edición cuando se establece en el estilo CBS_DROPDOWN.
    */
    GetEditText()
    {
        return this.GetText(-1)    ; ControlGetText(, "ahk_id" . this.GetEditControl())
    }

    /*
        Establece el texto en el control de edición. Un control ComboBoxEx utiliza un cuadro de edición cuando se establece en el estilo CBS_DROPDOWN.
        Parámetros:
            Text:
                El texto a establecer.
    */
    SetEditText(ByRef Text)
    {
        return this.SetText(-1, String(Text))    ; DllCall("User32.dll\SetWindowTextW", "Ptr", this.hWnd, "UPtr", &Text)
    }

    /*
        Obtiene el identificador para el control ComboBox hijo.
    */
    GetComboControl()
    {
        ; CBEM_GETCOMBOCONTROL message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-getcombocontrol
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x406, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Establece el número de espacios de sangría para mostrar en el elemento especificado.
    */
    SetIndent(Item, Indent)
    {
        ; CBEM_SETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-setitem
        NumPut(0x10  , this.COMBOBOXEXITEM.mask          , "UInt")   ; UINT    mask
      , NumPut(Item  , this.COMBOBOXEXITEM.iItem         , "Ptr" )   ; INT_PTR iItem
      , NumPut(Indent, this.COMBOBOXEXITEM.iIndent       , "Int" )   ; int     iIndent
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x40C, "Ptr", 0, "UPtr", this.COMBOBOXEXITEM.Ptr)
    }

    /*
        Establece la imagen en el elemento especificado.
    */
    SetImage(Item, Image := -1, SelImage := -1, Overlay := -1)
    {
        ; CBEM_SETITEM message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-setitem
        NumPut(0xE     , this.COMBOBOXEXITEM.mask          , "UInt")   ; UINT    mask
      , NumPut(Item    , this.COMBOBOXEXITEM.iItem         , "Ptr" )   ; INT_PTR iItem
      , NumPut(Image   , this.COMBOBOXEXITEM.iImage        , "Int" )   ; int     iImage
      , NumPut(SelImage, this.COMBOBOXEXITEM.iSelectedImage, "Int" )   ; int     iSelectedImage
      , NumPut(Overlay , this.COMBOBOXEXITEM.iOverlay      , "Int" )   ; int     iOverlay
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x40C, "Ptr", 0, "UPtr", this.COMBOBOXEXITEM.Ptr)
    }

    /*
        Quita una imagen en la lista de imagenes asignada al control.
        Parámetros:
            Index:
                El índice basado en cero de la imagen a eliminar en la lista de imagenes actualmente asignada al control.
        Return:
            Si tuvo éxito devuelve un valor distinto de cero, o cero en caso contrario.
    */
    RemoveImage(Index)
    {
        ; ImageList_Remove function
        ; https://docs.microsoft.com/es-es/windows/desktop/api/commctrl/nf-commctrl-imagelist_remove
        return DllCall("Comctl32.dll\ImageList_Remove", "Ptr", this.GetImageList(), "Int", Index)
    }

    /*
        Recupera el identificaador de la lista de imagenes asignada al control.
    */
    GetImageList()
    {
        ; CBEM_GETIMAGELIST message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-getimagelist
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x403, "Ptr", 0, "Ptr", 0, "Ptr")
    }

    /*
        Establece una lista de imágenes en el control.
        Parámetros:
            ImageList:
                El identificador de la lista de imagenes.
        Return:
            Devuelve el identificador de la lista de imágenes previamente asociada con el control, o devuelve 0 (NULL) si no se estableció previamente una lista de imágenes.
    */
    SetImageList(ImageList)
    {
        ; CBEM_SETIMAGELIST message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775787.aspx
        local hgt := [this.GetItemHeight(-1), this.GetItemHeight(0)]
        local ret := DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x402, "Ptr", 0, "Ptr", ImageList, "Ptr")
        this.SetItemHeight(hgt[1], -1), this.SetItemHeight(hgt[2], 0)
        return ret
    }

    /*
        Determina la altura de los elementos de la lista o el campo de selección en el control.
        Parámetros:
            Ver el método SetItemHeight.
    */
    GetItemHeight(Component := 0)
    {
        ; CB_GETITEMHEIGHT message
        ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-getitemheight
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x154, "Ptr", Component, "Ptr", 0)
    }

    /*
        Establece el alto de los elementos de la lista o el campo de selección.
        Parámetros:
            Height:
                Especifica la altura, en píxeles.
            Component:
                Debe ser -1 para establecer la altura del campo de selección.
                Debe ser cero para establecer la altura de los elementos de la lista. Este es el valor por defecto.
                Si el control tiene el estilo CBS_OWNERDRAWVARIABLE, este parámetro indica el índice basado en cero de un elemento específico de lista.
        Return:
            Si tuvo éxito devuelve la altura, o cero en caso contrario.
    */
    SetItemHeight(Height, Component := 0)
    {
        ; CB_SETITEMHEIGHT message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775911(v=vs.85).aspx
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x153, "Ptr", Component, "Ptr", Height) == -1 ? FALSE : Height
    }

    /*
        Recupera el valor proporcionado por la aplicación asociado con el elemento especificado en el control.
        Parámetros:
            Item:
                El índice basado en cero del elemento cuyo valor asociado se va a recuperar.
        Return:
            El valor de retorno es el valor asociado con el elemento. Si ocurre un error, es -1 (CB_ERR).
            El valor asociado con los elementos por defecto es cero (esto no es fiable).
    */
    GetItemData(Item)
    {
        ; CB_GETITEMDATA message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775859(v=vs.85).aspx
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x150, "Ptr", Item, "Ptr", 0, "Ptr")
    }

    /*
        Establece el valor asociado con el elemento especificado en el control.
        Parámetros:
            Item:
                El índice basado en cero del elemento cuyo valor asociado se va a cambiar.
            Data:
                Especifica el nuevo valor para asociar con el elemento. Este parámetro debe ser un entero (normalmente positivo).
                Si desea asociar una cadena u objeto con el elemento, especifique una dirección de memoria o puntero.
                Si va a incluir un objeto, para evitar que AHK lo libere, utilize la función incorporada ObjAddRef(). Utilize la función incorporada Object() para recuperar el objeto.
        Return:
            Si ocurre un error, el valor de retorno es -1 (CB_ERR).
    */
    SetItemData(Item, Data := 0)
    {
        ; CB_SETITEMDATA message
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775909(v=vs.85).aspx
        return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x151, "Ptr", Item, "Ptr", Data)
    }

    /*
        Determina si el contenido puede ser redibujado después de un cambio.
        Return:
            Devuelve cero si procesa este mensaje.
    */
    SetRedraw(State)
    {
        ; WM_SETREDRAW message
        ; https://docs.microsoft.com/en-us/windows/desktop/gdi/wm-setredraw
        return DllCall("User32.dll\SendMessageW", "Ptr", this.hWnd, "UInt", 0xB, "Ptr", State, "Ptr", 0)
    }

    /*
        Vuelve a dibujar el área ocupada por el control.
    */
    Redraw()
    {
        ; InvalidateRect function
        ; https://docs.microsoft.com/es-es/windows/desktop/api/winuser/nf-winuser-invalidaterect
        return DllCall("User32.dll\InvalidateRect", "Ptr", this.hWnd, "UPtr", 0, "Int", TRUE)
    }

    /*
        Establece el foco del teclado en el control.
    */
    Focus()
    {
        this.ctrl.Focus()
        return this
    }

    /*
        Cambia la fuente.
    */
    SetFont(Options, FontName := "")
    {
        this.ctrl.SetFont(Options, FontName)
        return this
    }

    /*
        Mueve y/o cambia el tamaño del control, opcionalmente lo vuelve a dibujar.
    */
    Move(Pos, Draw := FALSE)
    {
        this.ctrl.Move(Pos, Draw)
        return this
    }

    /*
        ComboBox Control Notifications:
            https://docs.microsoft.com/es-es/windows/desktop/Controls/bumper-combobox-control-reference-notifications
    */
    OnCommand(NotifyCode, Callback, AddRemove := 1)
    {
        this.ctrl.OnCommand(NotifyCode, Callback, AddRemove)
        return this
    }


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Recupera o establece el índice basado en cero del elemento actualmente seleccionado.
        get:
            El valor de retorno es el índice basado en cero del elemento seleccionado actualmente. Si ningún elemento esta seleccionado, es -1 (CB_ERR).
        set:
            Si tuvo éxito el valor devuelve el índice del elemento seleccionado. Si el valor es mayor que el número de elementos en la lista o si es 1, devuelve -1 (CB_ERR) y la selección se borra.
    */
    Selected[]
    {
        get {
            ; CB_GETCURSEL message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-getcursel
            return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x147, "Ptr", 0, "Ptr", 0)
        }
        set {
            ; CB_SETCURSEL message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cb-setcursel
            return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x14E, "Ptr", value, "Ptr", 0)
        }
    }

    /*
        Determina si el control tiene el estilo CBS_DROPDOWNLIST.
    */
    IsDDL[]
    {
        get {
            return !this.GetEditControl()
        }
    }

    /*
        Recupera o establece los estilos extendidos que están en uso en el control.
        set:
            Devuelve un valor que contiene los estilos extendidos previamente utilizados para el control.
    */
    ExStyle[]
    {
        get {
            ; CBEM_GETEXTENDEDSTYLE message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-getextendedstyle
            return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x409, "Ptr", 0, "Ptr", 0, "UInt")
        }
        set {
            ; CBEM_SETEXTENDEDSTYLE message
            ; https://docs.microsoft.com/es-es/windows/desktop/Controls/cbem-setextendedstyle
            return DllCall(this.psendmsg, "Ptr", this.hWnd, "UInt", 0x40E, "UInt", 0, "UInt", value, "UInt")
        }
    }

    /*
        Recupera o establece el texto en el control de edición.
    */
    Text[]
    {
        get {
            return this.GetText(this.IsDDL ? this.Selected : -1)
        }
        set {
            this.SetText(this.IsDDL ? this.Selected : -1, String(value))
            return value
        }
    }

    /*
        Recupera la posición y dimensiones del control.
    */
    Pos[]
    {
        get {
            return this.ctrl.Pos
        }
    }

    /*
        Determina si el control tiene el foco del teclado.
        Devuelve 0 si el control no tiene el foco.
        Devuelve 1 si el control ComboBox tiene el foco.
        Devuelve 2 si el control Edit tiene el foco.
    */
    Focused[]
    {
        get {
            local Hwnd := ControlGetHwnd(ControlGetFocus("ahk_id" . this.Gui.Hwnd), "ahk_id" . this.Gui.Hwnd)
            return Hwnd == this.GetComboControl() ? 1 : Hwnd == this.GetEditControl() ? 2 : Hwnd == this.hWnd ? 3 : 0
        }
    }

    /*
        Recupera o establece el estado de visibilidad del control.
        get:
            Devuelve cero si la ventana no es visible, 1 en caso contrario.
        set:
            Si la ventana estaba visible anteriormente, el valor de retorno es distinto de cero.
            Si la ventana estaba previamente oculta, el valor de retorno es cero.
    */
    Visible[]
    {
        get {
            ; IsWindowVisible function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633530(v=vs.85).aspx
            return DllCall("User32.dll\IsWindowVisible", "Ptr", this.hWnd)
        }
        set {
            ; ShowWindow function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633548(v=vs.85).aspx
            return DllCall("User32.dll\ShowWindow", "Ptr", this.hWnd, "Int", Value ? 8 : 0)
        }
    }

    /*
        Recupera o establece el estado habilitado/deshabilitado del control.
        get:
            Si la ventana esta habilitada devuelve un valor distinto de cero, o cero en caso contrario.
        set:
            Si la ventana estaba deshabilitada, el valor de retorno es distinto de cero.
            Si la ventana estaba habilitada, el valor de retorno es cero.
    */
    Enabled[]
    {
        get {
            ; IsWindowEnabled function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646303(v=vs.85).aspx
            return DllCall("User32.dll\IsWindowEnabled", "Ptr", this.hWnd)
        }
        set {
            ; EnableWindow function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646291(v=vs.85).aspx
            return DllCall("User32.dll\EnableWindow", "Ptr", this.hWnd, "Int", !!Value)
        }
    }
}

ComboBoxCreate(Gui, Options := "", Items*)
{
    return new ComboBoxEx(Gui, Options, Items*)
}
