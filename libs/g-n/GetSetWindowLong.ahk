GetWindowLong(hWnd, nIndex) {
    return DllCall("GetWindowLong", "UInt", hWnd, "Int", nIndex)
}
SetWindowLong(hWnd, nIndex, Value) {
    return DllCall("GetWindowLong", "UInt", hWnd, "Int", nIndex, "Int", Value)
}
