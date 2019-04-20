/*
    Recupera una cadena localizada. Una Cadena Localizada tiene el siguiente formato: '@[path\]dllname,-strID'.
    Parámetros:
        DllName: El archivo ejecutable que contiene el recurso de cadena.
        StrID: El identificador de la cadena a obtener.
    Return:
        Si tuvo éxito devuelve la cadena, caso contrario devuelve una cadena vacía.
    ErrorLevel:
        0 = La cadena se ha recuperado con éxito.
        1 = Hubo un error al cargar el archivo. Esto puede deberse a que el archivo especificado en DllName no existe.
        2 = Hubo un error al obtener la cadena. Esto puede deberse a que el identificador especificado en StrId no existe.
    Ejemplo:
        MsgBox(ReadLocalizedString('mswsock.dll', 60100) . '`n' . ReadLocalizedString('@`%SystemRoot`%\System32\mswsock.dll,-60100'))
*/
ReadLocalizedString(DllName, StrId := '')
{
    Local hModule, p, String

    If (StrId == '')
    {
        StrId   := SubStr(DllName, InStr(DllName, ',',, -1) + 1)
        DllName := LTrim(SubStr(DllName, 1, InStr(DllName, ',',, -1) - 1), '@')
        DllName := InStr(DllName, ':') ? DllName : StrReplace(DllName, '`%SystemRoot`%', A_WinDir,, 1)
    }
    
    ;Cargamos el archivo
    If (!(hModule := DllCall('Kernel32.dll\LoadLibraryExW', 'UPtr', &DllName, 'UInt', 0, 'UInt', 0x2, 'Ptr')))
    {
        ErrorLevel := 1
        Return ('')
    }

    ;Recupera un puntero de sólo lectura para el recurso en sí. Si no existe, LoadStringW devuelve 0
    If (!(Size := DllCall('User32.dll\LoadStringW', 'Ptr', hModule, 'UInt', Abs(StrId), 'UPtrP', p, 'Int', 0)))
    {
        DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hModule)

        ErrorLevel := 2
        Return ('')
    }

    String     := StrGet(p, Size, 'UTF-16') ;Antes de llamar a FreeLibrary y que el puntero 'p' sea liberado debemos copiar la cadena de tamaño Size (caracteres)
    DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hModule)
    ErrorLevel := 0

    Return (String)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms647486(v=vs.85).aspx
