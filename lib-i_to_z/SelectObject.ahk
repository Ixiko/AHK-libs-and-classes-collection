/*
    Selecciona un objeto en el contexto de dispositivo espesificado. El objeto nuevo reemplaza el objeto anterior del mismo tipo.
*/
SelectObject(hDC, hObject)
{
    Return (DllCall('Gdi32.dll\SelectObject', 'Ptr', hDC, 'Ptr', hObject, 'Ptr'))
} ;https://msdn.microsoft.com/en-us/library/dd162957(v=vs.85).aspx
