/*
    Copia una imágen.
    Parámetros:
        hImage: El identificador de la imágen a copiar.
        Type  : El tipo de imágen especificada en hImage. Puede ser uno de los siguientes valores:
            0 = Bitmap.
            1 = Icon.
            2 = Cursor.
        Width : El nuevo ancho deseado. Si este valor es 0 no se modifica.
        Height: El nuevo alto deseado. Si este valor es 0 no se modifica.
        Flags : Opciones. Puede ser uno o una combinación de los siguientes valores:
            0x00000008 = LR_COPYDELETEORG.
            0x00004000 = LR_COPYFROMRESOURCE.
            0x00000004 = LR_COPYRETURNORG.
            0x00002000 = LR_CREATEDIBSECTION.
            0x00000040 = LR_DEFAULTSIZE.
            0x00000001 = LR_MONOCHROME.
    Return:
        Si tuvo éxito devuelve el identificador de la nueva imágen, caso contrario devuelve 0.
*/
CopyImage(hImage, Type := 0, NewWidth := 0, NewHeight := 0, Flags := 0x2004)
{
    Return (DllCall('User32.dll\CopyImage', 'Ptr' , hImage    ;hImage
                                          , 'UInt', Type      ;uType
                                          , 'Int' , NewWidth  ;cxDesired
                                          , 'Int' , NewHeight ;cyDesired
                                          , 'UInt', Flags     ;fuFlags
                                          , 'Ptr') )          ;ReturnType (HANDLE)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms648031(v=vs.85).aspx
