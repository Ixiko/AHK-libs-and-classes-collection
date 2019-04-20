
GetWindowClassStyle(hWnd) {                                                             ;--  Retrieves the class style of the specified window.
    /*
    Retrieves the class style of the specified window.
     Parameters:
         hWnd: The identifier of the window.
     Return:
         If successful, it returns the style, otherwise it returns an empty string.
*/
    
    If (A_PtrSize == 4)
        Local R := DllCall('User32.dll\GetClassLongW', 'Ptr', hWnd, 'Int', -26, 'UInt')
    Else
        Local R := DllCall('User32.dll\GetClassLongPtrW', 'Ptr', hWnd, 'Int', -26, 'UPtr')

    Return (!R && A_LastError ? '' : R)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633581(v=vs.85).aspx
