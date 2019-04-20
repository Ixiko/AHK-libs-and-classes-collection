Class IMMDeviceCollection
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ptr)
    {
        this.ptr := ptr

        For Each, Method in ['GetCount','Item']
            ObjRawSet(this, 'p' . Method, NumGet(NumGet(this.ptr) + (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/dd371396(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.ptr)
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Recupera un recuento de los dispositivos en la colección de dispositivos.
        Parámetros:
            Devices: Recibe la cantidad de dispositivos en la colección de dispositivos.
    */
    GetCount(ByRef Devices)
    {
        Return DllCall(this.pGetCount, 'UPtr', this.ptr, 'UIntP', Devices, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd371397(v=vs.85).aspx

    /*
        Recupera un puntero al elemento especificado en la colección de dispositivos.
        Parámetros:
            Device    : El número de dispositivo. Si la colección contiene n dispositivos, los dispositivos están numerados de 0 a n-1.
            oIMMDevice: Recibe la interfaz IMMDevice del elemento especificado en la colección de dispositivos.
    */
    Item(Device, ByRef oIMMDevice)
    {
        Local pIMMDevice, R := DllCall(this.pItem, 'UPtr', this.ptr, 'UInt', Device, 'UPtrP', pIMMDevice, 'UInt')
        oIMMDevice := R == 0 ? new IMMDevice(pIMMDevice) : FALSE
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd371398(v=vs.85).aspx
}
