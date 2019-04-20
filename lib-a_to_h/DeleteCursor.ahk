/*
    Elimina el cursor cursor espesificado.
*/
DeleteCursor(hCursor)
{
    Return (DllCall('User32.dll\DestroyCursor', 'Ptr', hCursor))
}
