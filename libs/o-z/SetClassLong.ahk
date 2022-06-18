SetClassLong(Hwnd, nIndex, dwNewLong:="")     {
        If ! IsInteger(dwNewLong)
             Return A_PtrSize=8  ? DllCall("User32.dll\GetClassLongPtr", "ptr",Hwnd, "int",nIndex, "uint")
                                 : DllCall("User32.dll\GetClassLong",    "ptr",Hwnd, "int",nIndex, "uint")

        Else Return A_PtrSize=8  ? DllCall("User32.dll\SetClassLongPtr", "ptr",Hwnd, "int",nIndex, "ptr",dwNewLong, "uint")
                                 : DllCall("User32.dll\SetClassLong",    "ptr",Hwnd, "int",nIndex, "ptr",dwNewLong, "uint")
}