/*
Muestra el díalogo 'Abrir con...'.
Parámetros:
    Owner: El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
    FileName: La ruta a el archivo sobre el cual preguntar al usuario con que programa se debe abrir.
Return: Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
OpenWith(Owner, FileName)
{
    If (!FileExist(FileName) || DirExist(FileName))
        Return (FALSE)

    Local OPENASINFO
    VarSetCapacity(OPENASINFO, 2 * A_PtrSize + 4)
    NumPut(&FileName, &OPENASINFO)
    NumPut(0x00000004 | 0x00000001, &OPENASINFO+A_PtrSize*2, 'UInt')

    Return (!DllCall('Shell32.dll\SHOpenWithDialog', 'Ptr', Owner, 'UPtr', &OPENASINFO))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb762234(v=vs.85).aspx
