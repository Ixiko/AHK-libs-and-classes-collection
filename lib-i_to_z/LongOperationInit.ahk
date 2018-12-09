LongOperationInit(ByRef msg,ByRef tick_now){
    static POINT:="x,y",tagMSG:="HWND hwnd,UINT message,WPARAM wParam,LPARAM lParam,DWORD time,LongOperationInit(POINT) pt"
    msg:=Struct(tagMSG),tick_now:=0
}
