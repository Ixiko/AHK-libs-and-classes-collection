/*
    Notifica al sistema que las asociaciones de tipo de archivo han cambiado.
*/
UpdateSysAssoc()
{
    Return (DllCall('Shell32.dll\SHChangeNotify', 'UInt', 0x08000000, 'UInt', 0, 'Ptr', 0, 'Ptr', 0))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb762118%28v=vs.85%29.aspx
