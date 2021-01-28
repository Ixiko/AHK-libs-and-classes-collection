/*
    Vuelve a cargar los iconos del sistema
*/
UpdateIcons()
{
    Return (DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x0058, 'UInt', 0, 'Ptr', 0, 'UInt', 0)) ;SPI_SETICONS
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx
