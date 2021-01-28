/*
    Cierra la ventana espesificada.
    Parámetros:
        hWnd     : El identificador de la ventana.
        WaitClose: Determina si se debe esperar a que la ventana se cierre. Si se utiliza, debe especificar el tiempo fuera, en segundos. Solo válido cuando Force es cero.
        Force    : Determina si se debe usar un método forzoso para cerrar la ventana. Debe espesificar uno de los siguientes valores:
            1 = Fuerza el cierre de la ventana intentando terminar su thread.
            2 = Fuerza el cierre de la ventana intentando terminar su proceso.
            3 = Una combinación de 1 y 2. Primero intenta 1, si falla, intenta 2.
    Return:
        0 = La ventana se ha cerrado con éxito. Tenga en cuenta que este valor no es 100% fiable cuando Force es cero, a menos que utilice WaitClose.
        1 = Ha ocurrido un error al cerrar la ventana. Si force es cero, este valor indica que hubo un problema al procesar el mensaje WM_CLOSE.
        2 = La ventana especificada no existe.
        3 = La ventana no se puede cerrar debido a que no responde. Este valor solo es devuelto si Force es cero.
        4 = Se ha alcanzado el tiempo fuera y la ventana aún no se ha cerrado. Este valor solo es devuelto si se especificó WaitClose.
    Observaciones:
        Cuando Force es cero y se intenta cerrar una ventana cuyo proceso se encuentra suspendido, la función devuelve 0 (éxito) cuando no es así,
            para asegurarse de que la ventana haya sido cerrada con éxito, utilize el parámetro WaitClose.
    Ejemplo:
        MsgBox(CloseWindow(WinExist('ahk_class Notepad'), 2))
*/
CloseWindow(hWnd, WaitClose := FALSE, Force := FALSE)
{
    If (!DllCall('User32.dll\IsWindow', 'Ptr', hWnd))
        Return (2)

    If (!Force)
    {
        If (DllCall('User32.dll\IsHungAppWindow', 'Ptr', hWnd))
            Return (3)

        If (!DllCall('User32.dll\PostMessageW', 'Ptr', hWnd, 'UInt', 0x0002, 'Ptr', 0, 'Ptr', 0))
            Return (1)

        Return (WaitClose ? WinWaitClose('ahk_id' . hWnd,, WaitClose) ? 0 : 4 : 0)
    }

    Local ProcessID
        , R         := 1
        , ThreadID  := DllCall('User32.dll\GetWindowThreadProcessId', 'Ptr', hWnd, 'UIntP', ProcessID, 'UInt')
    If (!ThreadID || !ProcessID)
        Return (1)

    If (Force == 1 || Force == 3)
    {
        Local hThread

        If (hThread := DllCall('Kernel32.dll\OpenThread', 'UInt', 0x0001, 'Int', FALSE, 'UInt', ThreadID, 'Ptr'))
        {
            R := !DllCall('Kernel32.dll\TerminateThread', 'Ptr', hThread, 'UInt', 0)
            DllCall('Kernel32.dll\CloseHandle', 'Ptr', hThread)
        }
    }

    If (Force == 2 || (Force == 3 && R))
    {
        Local hProcess

        If (hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x0001, 'Int', FALSE, 'UInt', ProcessID, 'Ptr'))
        {
            R := !DllCall('Kernel32.dll\TerminateProcess', 'Ptr', hProcess, 'UInt', 0)
            DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)
        }
    }

    Return (R)
}
