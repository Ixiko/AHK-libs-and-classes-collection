IsDoubleClick(MSec = 300) {
    Return (A_ThisHotKey = A_PriorHotKey) && (A_TimeSincePriorHotkey < MSec)
}

IsDoubleClickEx(MSec = 300) {
    preHotkey := RegExReplace(A_PriorHotkey, "i) Up$")
    Return (A_ThisHotKey = preHotkey) && (A_TimeSincePriorHotkey < MSec)
}
