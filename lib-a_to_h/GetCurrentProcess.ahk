/*
    Recupera un pseudo-HANDLE al proceso actual.
    Return:
        Devuelve siempre -1, pero se recomienda utilizar esta función en lugar de una 'constante = -1' debido a que este valor puede ser cambiado en futuras versiones de Windows.
*/
GetCurrentProcess()
{
    Return (DllCall('Kernel32.dll\GetCurrentProcess', 'Ptr'))
}
