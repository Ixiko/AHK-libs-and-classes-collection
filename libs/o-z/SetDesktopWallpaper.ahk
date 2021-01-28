/*
    Cambia la imágen a mostrar como fondo de pantalla en el escritorio.
    Parámetros:
        FileName: La ruta al archivo de imágen.
    Nota:
        Para asegurarse de que la función no falle, usar una imágen BMP.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
SetDesktopWallpaper(FileName)
{
    Return (DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x0014, 'UInt', 0, 'UPtr', &FileName, 'UInt', 3))
}
