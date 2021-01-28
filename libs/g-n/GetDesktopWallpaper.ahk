/*
    Recupera la ruta a la imágen usada actualmente como fondo de pantalla en el escritorio.
    Return:
        Si tuvo éxito devuelve la ruta al archivo, caso contrario devuelve una cadena vacía.
*/
GetDesktopWallpaper()
{
    Local Buffer
    
    VarSetCapacity(Buffer, 2000, 0)

    If (!DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x0073, 'UInt', 1000, 'UPtr', &Buffer, 'UInt', 0))
        Return ('')
    
    Return (StrGet(&Buffer, 'UTF-16'))
}
