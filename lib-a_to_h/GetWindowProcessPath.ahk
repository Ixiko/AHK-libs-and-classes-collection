/*
    Recupera la ruta de acceso completa y el nombre de archivo del módulo asociado con la ventana especificada.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
            0 = Ha ocurrido un error al intentar recuperar la información.
        [str] = Si tuvo éxito devuelve la ruta y el nombre de archivo.
    Ejemplo:
        MsgBox(GetWindowProcessPath(WinExist('A')))
*/
GetWindowProcessPath(hWnd)
{
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633522(v=vs.85).aspx
    Local ProcessID
    If (!DllCall('User32.dll\GetWindowThreadProcessId', 'Ptr', hWnd, 'UIntP', ProcessID, 'UInt'))
        Return (FALSE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684320(v=vs.85).aspx
    Local hProcess
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x1000, 'Int', FALSE, 'UInt', ProcessID, 'Ptr')))
        Return (FALSE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684919(v=vs.85).aspx
    Local Buffer
        , Length      := 2024
        , ProcessPath := FALSE
    VarSetCapacity(Buffer, Length * 2)
    If (DllCall('Kernel32.dll\QueryFullProcessImageNameW', 'Ptr', hProcess, 'UInt', 0, 'UPtr', &Buffer, 'UIntP', Length) && Length)
        ProcessPath := StrGet(&Buffer, Length, 'UTF-16')

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724211(v=vs.85).aspx
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (ProcessPath)
}
