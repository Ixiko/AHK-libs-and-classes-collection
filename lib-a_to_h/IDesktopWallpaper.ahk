/* EXAMPLE
dw := new IDesktopWallpaper
dw.GetMonitorDevicePathAt(0, MonitorID)
MsgBox MonitorID
dw.GetWallpaper(MonitorID, Wallpaper)
MsgBox Wallpaper
ExitApp
*/
Class IDesktopWallpaper
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New()
    {
        this.IDesktopWallpaper := ComObjCreate("{C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD}", "{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}")

        For Each, Method in ["SetWallpaper","GetWallpaper","GetMonitorDevicePathAt","GetMonitorDevicePathCount","GetMonitorRECT","SetBackgroundColor","GetBackgroundColor","SetPosition","GetPosition","SetSlideshow", "GetSlideshow","SetSlideshowOptions","GetSlideshowOptions","AdvanceSlideshow","GetStatus","Enable"]
            ObjRawSet(this, "p" . Method, NumGet(NumGet(this.IDesktopWallpaper), (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775771(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.IDesktopWallpaper)
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    _R(R, pBuffer, ByRef Var := "", Error := "")
    {
        If (R == 0)
        {
            If (IsByRef(Var))
                Var := StrGet(pBuffer, "UTF-16")
            DllCall("Kernel32.dll\GlobalFree", "UPtr", pBuffer, "UPtr")
        }
        Else If (IsByRef(Var))
            Var := Error
        Return R
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Establece el fondo de escritorio.
        Parámetros:
            MonitorID: El identificador del monitor. Este valor se puede obtener a través de GetMonitorDevicePathAt. Establezca este valor en NULL para establecer la imagen en todos los monitores.
            Wallpaper: La ruta completa del archivo de imagen de fondo de pantalla.
    */
    SetWallpaper(MonitorID, Wallpaper)
    {
        Return DllCall(this.pSetWallpaper, "UPtr", this.IDesktopWallpaper, "Ptr", MonitorID, "UPtr", &Wallpaper, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706962(v=vs.85).aspx

    /*
        Obtiene el fondo de escritorio actual.
        Parámetros:
            MonitorID: El identificador del monitor. Este valor se puede obtener a través de GetMonitorDevicePathAt.
                       Este valor se puede establecer en NULL. En ese caso, si se muestra una sola imagen de fondo de pantalla en todos los monitores del sistema, el método devuelve con éxito.
                       Si este valor se establece en NULL y diferentes monitores muestran diferentes fondos de pantalla o se está ejecutando una presentación de diapositivas, el método devuelve S_FALSE.
            Wallpaper: Recibe la ruta completa del archivo de imagen de fondo de pantalla.
                       Esta imagen podría mostrarse actualmente en todos los monitores del sistema, no solo en el monitor especificado en el parámetro MonitorID.
                       Esta cadena estará vacía si no se muestra una imagen de fondo de pantalla o si un monitor muestra un color sólido. La cadena también estará vacía si el método falla.
    */
    GetWallpaper(MonitorID, ByRef Wallpaper)
    {
        Return this._R(DllCall(this.pGetWallpaper, "UPtr", this.IDesktopWallpaper, "UPtr", &MonitorID, "UPtrP", pBuffer, "UInt"), pBuffer, Wallpaper)
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706957(v=vs.85).aspx

    /*
        Recupera el identificador de uno de los monitores del sistema.
        Parámetros:
            MonitorIndex: El número del monitor. LLame a GetMonitorDevicePathCount para determinar el número total de monitores.
            MonitorID   : Recibe el identificador del monitor.
    */
    GetMonitorDevicePathAt(MonitorIndex, ByRef MonitorID)
    {
        Return this._R(DllCall(this.pGetMonitorDevicePathAt, "UPtr", this.IDesktopWallpaper, "UInt", MonitorIndex, "UPtrP", pBuffer, "UInt"), pBuffer, MonitorID)
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706950(v=vs.85).aspx

    /*
        Recupera la cantidad de monitores que están asociados con el sistema.
        Parámetros:
            Count: Recibe la cantidad de monitores.
    */
    GetMonitorDevicePathCount(ByRef Count)
    {
        Return DllCall(this.pGetMonitorDevicePathCount, "UPtr", this.IDesktopWallpaper, "UIntP", Count, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706951(v=vs.85).aspx

    /*
        Recupera el rectángulo de visualización del monitor especificado.
        Parámetros:
            MonitorID: El identificador del monitor a consultar. Puede obtener este valor a través de GetMonitorDevicePathAt.
            RECT     : Recibe una estructura RECT con el rectángulo de visualización del monitor especificado, en coordenadas de pantalla.
    */
    GetMonitorRECT(MonitorID, ByRef RECT)
    {
        VarSetCapacity(RECT, 16)
        Return DllCall(this.pGetMonitorRECT, "UPtr", this.IDesktopWallpaper, "UPtr", &MonitorID, "UPtr", &RECT, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706952(v=vs.85).aspx

    /*
        Establece el color que está visible en el escritorio cuando no se muestra ninguna imagen o cuando se ha desactivado el fondo del escritorio. Este color también se usa como borde cuando el fondo de escritorio no llena toda la pantalla.
        Parámetros:
            Color: Especifica el valor de color RGB de fondo.
    */
    SetBackgroundColor(Color)
    {
        Return DllCall(this.pSetBackgroundColor, "UPtr", this.IDesktopWallpaper, "UInt", Color, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706958(v=vs.85).aspx

    /*
        Recupera el color que está visible en el escritorio cuando no se muestra ninguna imagen o cuando se ha desactivado el fondo del escritorio. Este color también se usa como borde cuando el fondo de escritorio no llena toda la pantalla.
        Parámetros:
            Color: recibe el valor de color RGB. Si este método falla, este valor se establece en 0.
    */
    GetBackgroundColor(ByRef Color)
    {
        Return DllCall(this.pGetBackgroundColor, "UPtr", this.IDesktopWallpaper, "UIntP", Color, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706949(v=vs.85).aspx

    /*
        Establece la opción de visualización para la imagen de fondo de escritorio, determinando si la imagen debe estar centrada, en mosaico o estirada.
        Parámetros:
            Position: Uno de los valores de la enumeración DESKTOP_WALLPAPER_POSITION que especifica cómo se mostrará la imagen en los monitores del sistema.
                0 (DWPOS_CENTER)  = Centrar la imagen; no estirar.
                1 (DWPOS_TILE)    = Coloca la imagen en forma de mosaico en todos los monitores.
                2 (DWPOS_STRETCH) = Estira la imagen para que encaje exactamente en el monitor.
                3 (DWPOS_FIT)     = Estira la imagen exactamente a la altura o el ancho del monitor sin cambiar su relación de aspecto ni recortar la imagen. Esto puede dar como resultado barras de buzón de color en cada lado o arriba y abajo de la imagen.
                4 (DWPOS_FILL)    = Estira la imagen para llenar la pantalla, recortando la imagen según sea necesario para evitar barras de buzón.
                5 (DWPOS_SPAN)    = Divide una sola imagen en todos los monitores conectados al sistema.
    */
    SetPosition(Position)
    {
        Return DllCall(this.pSetPosition, "UPtr", this.IDesktopWallpaper, "Int", Position, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706959(v=vs.85).aspx

    /*
        Recupera el valor de visualización actual para la imagen de fondo del escritorio.
        Parámetros:
            Position: Recibe uno de los valores de la enumeración DESKTOP_WALLPAPER_POSITION que especifican cómo se muestra la imagen en los monitores del sistema.
    */
    GetPosition(ByRef Position)
    {
        Return DllCall(this.pGetPosition, "UPtr", this.IDesktopWallpaper, "IntP", Position, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706953(v=vs.85).aspx

    /*
        Especifica las imágenes que se usarán para la presentación de diapositivas de fondo de escritorio.
        Parámetros:
            pShellItemArray: Un puntero a un objeto IShellItemArray que contiene las imágenes de diapositivas. Este array puede contener elementos individuales almacenados en el mismo contenedor (archivos almacenados en una carpeta), o puede contener un único elemento que es el contenedor en sí (una carpeta que contiene imágenes). Cualquier otra configuración del array hará que este método falle.
    */
    SetSlideshow(pShellItemArray)
    {
        Return DllCall(this.pSetSlideshow, "UPtr", this.IDesktopWallpaper, "UPtr", pShellItemArray, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706960(v=vs.85).aspx

    /*
        Obtiene las imágenes que se muestran en la presentación de diapositivas de fondo de escritorio.
        Parámetros:
            pShellItemArray: Recibe un puntero a un objeto IShellItemArray que, cuando este método regresa correctamente, recibe los elementos que componen la presentación de diapositivas. Este array puede contener elementos individuales almacenados en el mismo contenedor, o puede contener un único elemento que es el contenedor en sí.
    */
    GetSlideshow(ByRef pShellItemArray)
    {
        Return DllCall(this.pGetSlideshow, "UPtr", this.IDesktopWallpaper, "UPtrP", pShellItemArray, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706954(v=vs.85).aspx

    /*
        Establece la configuración de presentación de diapositivas de fondo de escritorio para reproducción aleatoria y sincronización.
        Parámetros:
            Options      : Establézcalo en 0 para deshabilitar la reproducción aleatoria o en el siguiente valor.
                0x01 (DSO_SHUFFLEIMAGES) = Habilitar shuffle; avanzar a través de la presentación de diapositivas en un orden aleatorio.
            SlideshowTick: La cantidad de tiempo, en milisegundos, entre las transiciones de la imagen.
    */
    SetSlideshowOptions(Options, SlideshowTick)
    {
        Return DllCall(this.pSetSlideshowOptions, "UPtr", this.IDesktopWallpaper, "UInt", Options, "UInt", SlideshowTick, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706961(v=vs.85).aspx

    /*
        Obtiene la configuración actual de presentación de diapositivas de fondo de escritorio para mezclar y sincronizar.
        Parámetros:
            Options      : Recibe 0 para indicar que shuffle está deshabilitado o el siguiente valor.
                 0x01 (DSO_SHUFFLEIMAGES) = Shuffle está habilitado; las imágenes se muestran en orden aleatorio.
            SlideshowTick: Recibe el intervalo entre transiciones de imagen, en milisegundos.
    */
    GetSlideshowOptions(ByRef Options, ByRef SlideshowTick)
    {
        Return DllCall(this.pGetSlideshowOptions, "UPtr", this.IDesktopWallpaper, "UIntP", Options, "UIntP", SlideshowTick, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706955(v=vs.85).aspx
    
    /*
        Cambia el fondo de pantalla en un monitor específico a la siguiente imagen en la presentación de diapositivas.
        Parámetros:
            MonitorID: El identificador del monitor en el que cambiar la imagen del fondo de pantalla. Este valor se puede obtener a través del método GetMonitorDevicePathAt. Si este parámetro se establece en NULL, se usa el monitor programado para cambiar a continuación.
            Direction: La dirección en que debe avanzar la presentación de diapositivas. Uno de los siguientes valores DESKTOP_SLIDESHOW_DIRECTION:
                0 (DSD_FORWARD)  = Avance la presentación de diapositivas hacia adelante.
                1 (DSD_BACKWARD) = Avance la presentación de diapositivas hacia atrás.
    */
    AdvanceSlideshow(MonitorID, Direction)
    {
        Return DllCall(this.pAdvanceSlideshow, "UPtr", this.IDesktopWallpaper, "UPtr", &MonitorID, "UInt", Direction, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706947(v=vs.85).aspx
    
    /*
        Obtiene el estado actual de la presentación de diapositivas.
        Parámetros:
            State: Un valor DESKTOP_SLIDESHOW_STATE que, cuando este método retorna exitosamente, recibe uno o más de los siguientes indicadores.
                0x01 (DSS_ENABLED)                    = Las presentaciones de diapositivas están habilitadas.
                0x02 (DSS_SLIDESHOW)                  = Una presentación de diapositivas está configurada actualmente.
                0x04 (DSS_DISABLED_BY_REMOTE_SESSION) = Una sesión remota ha deshabilitado temporalmente la presentación de diapositivas.
    */
    GetStatus(ByRef State)
    {
        Return DllCall(this.pGetStatus, "UPtr", this.IDesktopWallpaper, "UIntP", State, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706956(v=vs.85).aspx
    
    /*
        Activa o desactiva el fondo del escritorio.
        Parámetros:
            Enable: TRUE para habilitar el fondo del escritorio, FALSE para deshabilitarlo.
    */
    Enable(Enable)
    {
        Return DllCall(this.pEnable, "UPtr", this.IDesktopWallpaper, "Int", Enable, "UInt")
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706948(v=vs.85).aspx
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/hh706946(v=vs.85).aspx
