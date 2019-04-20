/*
    Recupera el tipo del objeto espesificado.
*/
GetObjectType(hObject)
{
    Return (DllCall('Gdi32.dll\GetObjectType', 'Ptr', hObject, 'UInt'))
} ;https://msdn.microsoft.com/en-us/library/dd144905(v=vs.85).aspx
