/*
    Abre un directorio mediante la línea de comandos del explorador de archivos de Windows.
    Parámetros:
        DirName: La ruta al directorio.
    Return:
        Si tuvo éxito devuelve el identificador del proceso de la ventana, caso contrario devuelve 0.
*/
ExploreDir(DirName)
{   
    Local PID

    DirName := (StrLen(DirName) < 4 ? SubStr(DirName, 1, 1) . ':' : RTrim(DirName, '\'))

    If (!DirExist(DirName))
        Return (FALSE)

    Run(A_WinDir . '\explorer.exe ' . Chr(34) . DirName . Chr(34), A_WinDir, 'Max', PID)
    Return (PID)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb773581(v=vs.85).aspx





/* IGNORAR ESTO     IGNORAR ESTO
    if (DirName == -2)
    {
        DllCall('User32.dll\ShowWindow', 'Ptr', NewWindow, 'UInt', 8)
        DllCall('User32.dll\ShowWindow', 'Ptr', NewWindow, 'UInt', 3)
        WinActivate('ahk_id ' . NewWindow)
        Return (WinGetPID('ahk_id ' . NewWindow))
    }


    If (!NewWindow)
    {
        VarSetCapacity(PATH, 32767 * 2, 0)

        For Each, hWnd In WinGetList('ahk_exe ' . A_WinDir . '\explorer.exe')
        {
            ClassName := WinGetClass('ahk_id' . (hWnd+=0))

            If ((ClassName = 'Progman' || ClassName = 'WorkerW') && DirName = A_Desktop)


        }
    }


        for Each, hWnd in WinGetList('ahk_exe ' . A_WinDir . '\explorer.exe')
        {
            ClassName               := WinGetClass('ahk_id ' . (hWnd:=hWnd+0))
            if ((ClassName = 'Progman' || ClassName = 'WorkerW') && (A_Desktop = DirName))
                Return (ExploreDir(-2, hWnd))
            
            if (ClassName = 'CabinetWClass' || ClassName = 'ExploreWClass')
                for Window in ComObjCreate('Shell.Application').Windows
                    if (Window.hWnd = hWnd && (URL:=Window.LocationURL) != '') ; si LocationURL='' puede que sea 'Equipo' o una biblioteca.
                        if (DllCall('Shlwapi.dll\PathCreateFromUrlW', 'Ptr', &URL, 'Str', PATH, 'UIntP', 32767, 'UInt', 0) == FALSE && RTrim(PATH, '\') = DirName)
                            Return (ExploreDir(-2, hWnd))
        }



    NewWindow: Determina si se debe abrir siempre una nueva ventana. Por defecto, si ya hay una ventana con DirName, trae ésta al frente.
*/
