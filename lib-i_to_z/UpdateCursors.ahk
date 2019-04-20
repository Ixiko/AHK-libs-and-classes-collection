/*
    Vuelve a cargar los cursores del sistema
*/
UpdateCursors()
{
    Return (DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x0057, 'UInt', 0, 'Ptr', 0, 'UInt', 0)) ;SPI_SETCURSORS
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx
