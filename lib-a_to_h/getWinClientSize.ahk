getWinClientSize(hwnd){
    varSetCapacity(rect,16,0)
    dllCall("GetClientRect","Ptr",hwnd,"Ptr",&rect)
    return {width: numGet(rect,8,"Int"), height: numGet(rect,12,"Int")}
}