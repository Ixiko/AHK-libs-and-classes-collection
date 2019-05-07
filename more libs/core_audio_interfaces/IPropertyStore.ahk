Class IPropertyStore
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ptr)
    {
        this.ptr := ptr

        For Each, Method in ['GetCount','GetAt','GetValue','SetValue','Commit']
            ObjRawSet(this, 'p' . Method, NumGet(NumGet(this.ptr) + (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761474(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.ptr)
    }


    ; ===================================================================================================================
    ; HELPER METHODS
    ; ===================================================================================================================
    /*
        Recupera el nombre del dispositivo desde una estructura PROPVARIANT y libera la memoria.
        Parámetros:
            pPROPVARIANT: Un puntero a la estructura PROPVARIANT. Este método devuelve el nombre del dispositivo y libera la memoria.
    */
    GetDeviceName(pPROPVARIANT)
    {
        Local DeviceName := StrGet(NumGet(pPROPVARIANT + 8), 'UTF-16')
        DllCall('Ole32.dll\CoTaskMemFree', 'UPtr', NumGet(pPROPVARIANT + 8))
        Return DeviceName
    }

    /*
        Crea una estructura PROPERTYKEY o recupera información de una.
        Parámetros:
            GUID       : Si se va a crear especifica una cadena GUID. Si se va a recuperar información especifica un puntero a una estructura PROPERTYKEY.
            PID        : El identificador de la propiedad. Este parámetro solo es válido si se va a crear la estructura.
            PROPERTYKEY: Recibe la estructura PROPERTYKEY. Si se especifica, se asume que se va a crear la estructura.
        Return:
            Si se va a crear la estructura, devuelve un puntero a ella; caso contrario devuelve un objeto con las claves {GUID,PID}.
    */
    PROPERTYKEY(GUID, PID := 0, ByRef PROPERTYKEY := '')
    {
        If (IsByRef(PROPERTYKEY))
        {
            VarSetCapacity(PROPERTYKEY, 20)
            DllCall('Ole32.dll\CLSIDFromString', 'UPtr', &GUID, 'UPtr', &PROPERTYKEY)
            NumPut(PID, &PROPERTYKEY + 16, 'UInt')
            Return &PROPERTYKEY
        }

        VarSetCapacity(sGUID, 78)
        DllCall('Ole32.dll\StringFromGUID2', 'UPtr', GUID, 'UPtr', &sGUID, 'Int', 39)
        Return {GUID: StrGet(&sGUID, 'UTF-16'), PID: NumGet(GUID + 16, 'UInt')}
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Obtiene el número de propiedades adjuntas al archivo.
    */
    GetCount(ByRef Props)
    {
        Return DllCall(this.pGetCount, 'UPtr', this.ptr, 'UIntP', Props, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761472(v=vs.85).aspx

    /*
        Obtiene una clave de propiedad de la matriz de propiedades de un elemento.
        Parámetros:
            Prop: El índice de la clave de propiedad en el array de estructuras PROPERTYKEY. Este es un índice basado en cero.
    */
    GetAt(Prop, ByRef PROPERTYKEY)
    {
        If (!(PROPERTYKEY is 'Integer'))
            VarSetCapacity(PROPERTYKEY, 20)
        Return DllCall(this.pGetAt, 'UPtr', this.ptr, 'UInt', Prop, 'UPtr', PROPERTYKEY is 'Integer' ? PROPERTYKEY : &PROPERTYKEY, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761471(v=vs.85).aspx

    /*
        Obtiene datos para una propiedad específica.
        Parámetros:
            PROPERTYKEY: Un puntero a la estructura PROPERTYKEY. Esta estructura contiene un identificador único para la propiedad en cuestión.
            PROPVARIANT: Recibe una estructura PROPVARIANT que contiene los datos de la propiedad.
                         Si esta estructura recibe un puntero, deberá liberar la memoria utilizando DllCall('Ole32.dll\CoTaskMemFree', 'UPtr', NumGet(&PROPVARIANT + 8)).
                         Puede utilizar el método GetDeviceName(&PROPVARIANT) para recuperar el nombre del dispositivo y liberar la memoria.
    */
    GetValue(pPROPERTYKEY, ByRef PROPVARIANT)
    {
        If (!(PROPVARIANT is 'Integer'))
            VarSetCapacity(PROPVARIANT, A_PtrSize == 4 ? 16 : 24)
        Return DllCall(this.pGetValue, 'UPtr', this.ptr, 'UPtr', pPROPERTYKEY, 'UPtr', PROPVARIANT is 'Integer' ? PROPVARIANT : &PROPVARIANT, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761473(v=vs.85).aspx

    /*
        Establece un nuevo valor de propiedad o reemplaza o elimina un valor existente.
    */
    SetValue(pPROPERTYKEY, pPROPVARIANT)
    {
        Return DllCall(this.pSetValue, 'UPtr', this.ptr, 'UPtr', pPROPERTYKEY, 'UPtr', pPROPVARIANT, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761475(v=vs.85).aspx

    /*
        Guarda un cambio de propiedad.
    */
    Commit()
    {
        Return DllCall(this.pCommit, 'UPtr', this.ptr, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761470(v=vs.85).aspx
}
