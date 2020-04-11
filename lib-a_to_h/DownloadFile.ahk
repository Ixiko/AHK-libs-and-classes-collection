/*
    Descarga un archivo de internet.
    Parámetros:
        Url      : El URL del archivo.
        FileName : La ruta del archivo destino.
        Overwrite: Debe especificar uno de los siguientes valores:
            0 = Si el archivo ya existe, la función falla y devuelve -1.
            1 = Si el archivo ya existe, es sobre-escrito.
            2 = Si el archivo ya existe, se añaden los nuevos datos sin modificar los datos actuales.
        MaxSize  : La cantidad máxima a leer, en bytes. Si este valor es 0, se lee todo el archivo.
        BlockSize: La cantidad de bytes que se deben recuperar por cada iteración que lee el archivo. Mayor valor mejorará en gran medida el rendimiento, aunque esto depende de la velocidad de descarga.
        CallBack : Función que recibe información de la descarga. Si esta función devuelve 1, la descarga es cancelada. Recibe los siguientes parámetros:
            NumberOfBytesRead      = La cantidad de bytes leídos; que es lo mismo que la cantidad de bytes escritos en el archivo.
            NumberOfBytesAvailable = El tamaño total del archivo, en bytes. [ESTE VALOR NO ES FIABLE, POR LO QUE Percentage TAMPOCO LO ES]
            Percentage             = El porcentaje total completado, donde un valor '>= 100.00 %' indica que la descarga ha sido completada.
    Return:
        Si tuvo éxito devuelve la cantidad de bytes escritos, caso contrario devuelve uno de los siguientes valores de error:
            -1 = El archivo especificado en FileName es inválido o hubo un error al crear o abrir el archivo.
            -2 = Error al intentar inicializar el uso de las funciones WinINet.
            -3 = Error al intentar abrir la URL especificada.
            -4 = La descarga ha sido cancelada mediante CallBack. ErrorLevel se establece en la cantidad de bytes escritos.
    Observaciones:
        El archivo especificado en FileName es bloqueado contra operaciones de escritura y borrado durante la operación de descarga.
        Para un mejor rendimiento, BlockSize siempre debe ser mayor o igual a la velocidad de descarga. Por defecto descarga 1MB Max. por cada iteración.
    Ejemplo 1:
        Url         := 'https://autohotkey.com/download/2.0/version.txt' ;archivo a descargar
        FileName    := A_Desktop . '\~tmp.txt'                           ;guardar en...
        ReturnValue := DownloadFile(Url, FileName, 1, 0, 1, Func('Progress'))
        MsgBox('ReturnValue: ' . ReturnValue)

        Progress(NumberOfBytesRead, NumberOfBytesAvailable, Percentage)
        {
            ToolTip('Percentage: ' . Round(Percentage, 2) . ' %`nNumberOfBytesRead: ' . NumberOfBytesRead . '`nNumberOfBytesAvailable: ' . NumberOfBytesAvailable)
            Sleep(500)
        }
    Ejemplo 2:
        Url         := 'https://autohotkey.com/download/ahk-install.exe' ;archivo a descargar
        FileName    := A_Desktop . '\~AutoHotkey.exe'                    ;guardar en...
        ReturnValue := DownloadFile(Url, FileName, 1, 0, 1000, Func('Progress'))
        MsgBox('ReturnValue: ' . ReturnValue)

        Progress(NumberOfBytesRead, NumberOfBytesAvailable, Percentage)
        {
            ToolTip('Percentage: ' . Round(Percentage, 2) . ' %`nNumberOfBytesRead: ' . NumberOfBytesRead . '`nNumberOfBytesAvailable: ' . NumberOfBytesAvailable)
            Return (GetKeyState('ESC'))                                  ;presione la tecla ESC para cancelar la descarga (el archivo puede quedar obsoleto)
        }
*/
DownloadFile(Url, FileName, Overwrite := TRUE, MaxSize := 0, BlockSize := 1000000, CallBack := 0) {

    Local hModule, hInternet, hUrl, Percentage, WinHttpReq, NumberOfBytesAvailable, Buffer, NumberOfBytesRead, BytesRead

    ; Si FileName es un directorio devolvemos -1. O si FileName ya existe y Overwrite=0 devolvemos -1.
    If (DirExist(FileName) || (!Overwrite && FileExist(FileName)))
        Return (-1)

    ; Abrimos el archivo para escritura
    If (!IsObject(File := FileOpen(FileName, (Overwrite == 2 ? 'a' : 'w') . '-wd')))
        Return (-1)

    hModule := DllCall('Kernel32.dll\LoadLibraryW', 'Str', 'WinINet.dll', 'Ptr')

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa385096(v=vs.85).aspx
    If (!(hInternet := DllCall('WinINet.dll\InternetOpenW', 'Str', 'Microsoft Internet Explorer', 'UInt', 4, 'Ptr', 0, 'Ptr', 0, 'UInt', 0, 'Ptr')))
    {
        DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hModule)
        Return (-2)
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa385098(v=vs.85).aspx
    ; INTERNET_FLAG_DONT_CACHE = 0x04000000
    If (!(hUrl := DllCall('WinINet.dll\InternetOpenUrlW', 'Ptr', hInternet, 'Str', URL, 'Ptr', 0, 'UInt', 0, 'UInt', 0x04000000, 'UInt', 0, 'Ptr')))
    {
        DllCall('WinINet.dll\InternetCloseHandle', 'Ptr', hInternet)
        DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hModule)
        Return (-3)
    }

    If (CallBack)
    {
        Percentage := 0

        ; Este método parece ser mas fiable que utilizando 'WinINet\InternetQueryDataAvailable' para recuperar el tamaño del archivo
        WinHttpReq             := ComObjCreate('WinHttp.WinHttpRequest.5.1')
        WinHttpReq.Open('HEAD', Url, FALSE)
        WinHttpReq.Send()
        NumberOfBytesAvailable := WinHttpReq.GetResponseHeader('Content-Length') ;bytes

        If (!NumberOfBytesAvailable) ;DllCall('WinINet.dll\InternetQueryDataAvailable', 'Ptr', hUrl, 'UIntP', NumberOfBytesAvailable, 'UInt', 0, 'UInt', 0)
        {
            DllCall('WinINet.dll\InternetCloseHandle', 'Ptr', hUrl)
            DllCall('WinINet.dll\InternetCloseHandle', 'Ptr', hInternet)
            DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hModule)
            Return (0)
        }
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa385103(v=vs.85).aspx
    NumberOfBytesRead := 0
    VarSetCapacity(Buffer, BlockSize, 0)
    Loop
    {
        If (!DllCall('WinINet.dll\InternetReadFile', 'Ptr', hUrl, 'UPtr', &Buffer, 'UInt', BlockSize, 'UIntP', BytesRead) || !BytesRead)
            Break

        If (MaxSize && NumberOfBytesRead + BytesRead > MaxSize)
            BytesRead := (NumberOfBytesRead + BytesRead) - ((NumberOfBytesRead + BytesRead) - MaxSize)

        NumberOfBytesRead += BytesRead
        File.RawWrite(&Buffer, BytesRead)

        If (CallBack)
        {
            If (CallBack.Call(NumberOfBytesRead, NumberOfBytesAvailable, Percentage += (100.0 / NumberOfBytesAvailable) * BlockSize) == 1)
            {
                ErrorLevel        := NumberOfBytesRead
                NumberOfBytesRead := -4
                Break
            }
        }

        If (NumberOfBytesRead == MaxSize)
            Break
    }

    DllCall('WinINet.dll\InternetCloseHandle', 'Ptr', hUrl)
    DllCall('WinINet.dll\InternetCloseHandle', 'Ptr', hInternet)
    DllCall('Kernel32.dll\FreeLibrary', 'Ptr', hModule)

    Return (NumberOfBytesRead)
}














/*
    WinHttpReq := ComObjCreate('WinHttp.WinHttpRequest.5.1')

    WinHttpReq.Open('HEAD', Url, FALSE)
    WinHttpReq.Send()
    Length := WinHttpReq.GetResponseHeader('Content-Length')

    WinHttpReq.Open('GET', Url, FALSE)

    For Header, Value In Headers
        WinHttpReq.SetRequestHeader(Header, Value)

    WinHttpReq.Send()

    ADODBObj      := ComObjCreate('ADODB.Stream')
    ADODBObj.Type := 1

    ADODBObj.Open()
    ADODBObj.Write(WinHttpReq.ResponseBody)

    ADODBObj.SaveToFile(FileName, Overwrite ? 2 : 1)
    ADODBObj.Close()
*/
