/*
   Selects an object in the specified device context. The new object replaces the previous object of the same type.
*/
SelectObject(hDC, hObject){
    Return (DllCall('Gdi32.dll\SelectObject', 'Ptr', hDC, 'Ptr', hObject, 'Ptr'))
} ;https://msdn.microsoft.com/en-us/library/dd162957(v=vs.85).aspx
