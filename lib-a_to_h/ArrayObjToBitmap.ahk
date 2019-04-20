/*
    Convierte un objeto COM SafeArray a un Bitmap.
    Parámetros:
        ArrayObj: El objeto COM SafeArray.
    Return:
        0     = Ha ocurrido un error.
        [num] = Si tuvo éxito devuelve el identificador a un Bitmap.
    Notas:
        Puede utilizar la función Base64ToArrayObj incluida en 'crt\Base64.ahk' para obtener el objeto Array.
    Observaciones:
        Cuando no utilize mas el Bitmap, debe eliminarlo llamando a 'DeleteObject'.
*/
ArrayObjToBitmap(ArrayObj)
{
    Local Vector, Picture, hBitmap

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms630513(v=vs.85).aspx
    Try Vector := ComObjCreate('WIA.Vector')
    If (!IsObject(Vector))
        Return (0)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms630518(v=vs.85).aspx
    Vector.BinaryData := ArrayObj

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms630524(v=vs.85).aspx
    Picture := Vector.Picture

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648031(v=vs.85).aspx
    hBitmap := DllCall('User32.dll\CopyImage', 'Ptr' , Picture.Handle     ;hImage
                                             , 'UInt', 0                  ;uType     --> IMAGE_BITMAP
                                             , 'Int' , 0                  ;cxDesired
                                             , 'Int' , 0                  ;cyDesired
                                             , 'UInt', 0x2000 | 0x8 | 0x4 ;fuFlags   --> LR_CREATEDIBSECTION | LR_COPYDELETEORG | LR_COPYRETURNORG
                                             , 'Ptr')                     ;ReturnType (HANDLE)

    Return (hBitmap)
}
