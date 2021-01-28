/*
    Elimina un objeto pen, brush, font, bitmap, region, o palette; liberando todos los recursos del sistema asociados con el objeto.
*/
DeleteObject(hObject)
{
    Return (DllCall('Gdi32.dll\DeleteObject', 'Ptr', hObject))
} ;https://msdn.microsoft.com/en-us/library/dd183539(v=vs.85).aspx
