/*
    Abre un directorio en el Explorador de Archivos de Windows y selecciona archivos y carpetas.
    Parámetros:
        DirName: La ruta del directorio a abrir.
        Files  : Un 'Array' con el nombre de los archivos o carpetas a seleccionar. Si se trata de un único archivo, espesificar una cadena. Los archivos que no existan son omitidos.
        Flags  : Opciones. Debe espesificar uno de los siguientes valores:
            0x0001 = Seleccione un elemento y pone su nombre en el modo de edición. sólo se puede utilizar cuando se selecciona un solo elemento
            0x0002 = Seleccione el elemento o los elementos en el escritorio en lugar de en una ventana de Explorador de Windows. si el escritorio está detrás de las ventanas abiertas, no se hará visible.
    Return:
        -3 = El directorio especificado no existe.
        -2 = No se ha encontrado ningun archivo válido para seleccionar en el directori especificado.
        -1 = Ha ocurrido un error.
         0 = La operación se ha realizado correctamente.
    Ejemplo:
        MsgBox(OpenFolderAndSelectItems(A_WinDir, ['explorer.exe', 'hh.exe', 'system32']))
*/
OpenFolderAndSelectItems(DirName, Files, Flags := 0)
{
    Local Items, Each, FileName, ITEMLIST, PIDL, R

    If (!DirExist(DirName))
        Return (-3)
    
    DirName := StrLen(DirName) < 4 ? SubStr(DirName, 1, 1) . ':' : RTrim(DirName, '\')
    Items   := []

    For Each, FileName In (IsObject(Files) ? Files : [Files])
        If (FileExist(DirName . '\' . FileName))
            Items.Push(FileName)

    If (!Items.MaxIndex())
        Return (-2)

    VarSetCapacity(ITEMLIST, Items.MaxIndex() * A_PtrSize)

    For Each, FileName In Items
    {
        DllCall('Shell32.dll\SHParseDisplayName', 'Str', DirName . '\' . FileName, 'Ptr', 0, 'PtrP', PIDL, 'UInt', 0, 'Ptr', 0)
        NumPut(PIDL, &ITEMLIST + (A_Index - 1) * A_PtrSize, 'Ptr')
    }
    
    DllCall('Ole32.dll\CoInitializeEx', 'Ptr', 0, 'UInt', 0)
    DllCall('Shell32.dll\SHParseDisplayName', 'UPtr', &DirName, 'Ptr', 0, 'PtrP', PIDL, 'UInt', 0, 'Ptr', 0)
    R := DllCall('Shell32.dll\SHOpenFolderAndSelectItems', 'Ptr', PIDL, 'UInt', Items.MaxIndex(), 'UPtr', &ITEMLIST, 'UInt', Flags)
    
    DllCall('Ole32.dll\CoTaskMemFree', 'Ptr', PIDL)
    Loop (Items.MaxIndex())
        DllCall('Ole32.dll\CoTaskMemFree', 'Ptr', NumGet(&ITEMLIST + (A_Index - 1) * A_PtrSize, 'Ptr'))
    DllCall('Ole32.dll\CoUninitialize')

    Return (R ? -1 : 0)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb762232(v=vs.85).aspx
