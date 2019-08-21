; NOTE: Windows RS5 insider builds breaks virtual-desktop-accessor.dll

/**                             ;SAMPLE
#include reloadAsAdmin.ahk
reloadAsAdmin()
global A_ScriptPID := ProcessExist()
#include Timer.ahk
#include Toast.ahk
Taskview.init()

1::msgbox("Is Pinned Window? " Taskview.isPinnedWindow(winExist("A")) "`nIs Pinned App " Taskview.isPinnedApp(winExist("A")) "`nCurrent Desktop " Taskview.getCurrentDesktopNumber() "`nNo of Desktops " Taskview.getDesktopCount())

2::TaskView.pinWindowToggle(winExist("A"))
+2::TaskView.pinWindow(winExist("A"))
^2::TaskView.unPinWindow(winExist("A"))

3::TaskView.pinAppToggle(winExist("A"))
+3::TaskView.pinApp(winExist("A"))
^3::TaskView.unPinApp(winExist("A"))

4::TaskView.goToDesktopNumber(2)
5::TaskView.moveWindowToDesktopNumber(2,winExist("A"))
6::TaskView.goToDesktopPrev()
7::TaskView.goToDesktopNext()
8::TaskView.moveToDesktopPrev(winExist("A"))
9::TaskView.moveToDesktopNext(winExist("A"))
/**/

class TaskView { ; There should only be one object for this
    static proc:=[]
    init(){ ; SHOULD be called
        return this.__new()
    }
    __new(){
        hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\Lib\virtual-desktop-accessor.dll", "Ptr")
       ,fList:=[ "GetCurrentDesktopNumber","GetDesktopCount","GoToDesktopNumber"
               ,"IsWindowOnDesktopNumber","MoveWindowToDesktopNumber"
               ,"IsPinnedWindow","PinWindow","UnPinWindow","IsPinnedApp","PinApp","UnPinApp"
               ,"RegisterPostMessageHook","UnregisterPostMessageHook","RestartVirtualDesktopAccessor" ]

        for _,fName in fList
            this.proc[fName]:= DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", fName, "Ptr")

        this.toast:=new Toast({life:1000})
       ,DllCall(this.proc["RegisterPostMessageHook"], "Int", A_ScriptHwnd+(0x1000<<32), "Int", 0x1400 + 30)
       ,OnMessage(0x1400 + 30, ObjBindMethod(this,"_onDesktopSwitch"))
       ,OnMessage(DllCall("user32\RegisterWindowMessage", "Str", "TaskbarCreated"), ObjBindMethod(this,"_onExplorerRestart"))
    }

    _onExplorerRestart(wParam, lParam, msg, hwnd) {
        global RestartVirtualDesktopAccessorProc
        DllCall(this.proc["RestartVirtualDesktopAccessor"], "UInt", result)
    }
    _onDesktopSwitch(wParam,lParam){
        return this.toast.show("Desktop " lParam+1)
    }

    __Call(fname,hwnd:=""){
        if hwnd
             return DllCall(this.proc[fName], "UInt", hwnd)
        else return DllCall(this.proc[fName])
    }
    /* ; Same as
    isPinnedWindow(hwnd){
        return DllCall(this.proc["IsPinnedWindow"], "UInt", hwnd)
    }
    isPinnedApp(hwnd){
        return DllCall(this.proc["IsPinnedApp"], "UInt", hwnd)
    }
    pinWindow(hwnd){
        return DllCall(this.proc["PinWindow"], "UInt", hwnd)
    }
    unPinWindow(hwnd){
        return DllCall(this.proc["UnPinWindow"], "UInt", hwnd)
    }
    pinApp(hwnd){
        return DllCall(this.proc["PinApp"], "UInt", hwnd)
    }
    unPinApp(hwnd){
        return DllCall(this.proc["UnPinApp"], "UInt", hwnd)
    }
    getDesktopCount(){
        return DllCall(this.proc["GetDesktopCount"])
    } */
    getCurrentDesktopNumber(){
        return DllCall(this.proc["GetCurrentDesktopNumber"]) + 1
    }

    _desktopNumber(n, wrap:=True){
        max:=this.getDesktopCount()
        if wrap {
            while n<=0
                n+=max
            return mod(n-1, max) +1
        }

        if n<=0
            return 1
        if n>max {
            loop n-max
                send("#^d")       ; Create extra desktops
            sleep(100)
        }
        return n
    }
    goToDesktopNumber(n, wrap:=True) {
        if (! n is "number")
            return 0
        n:=this._desktopNumber(n, wrap)
       ,DllCall(this.proc["GoToDesktopNumber"], "Int", n-1)
        return n
    }
    moveWindowToDesktopNumber(n, win_hwnd, wrap:=True){
        if (! n is "number")
            return 0
        n:=this._desktopNumber(n,wrap)
       ,DllCall(this.proc["MoveWindowToDesktopNumber"], "UInt", win_hwnd, "UInt", n-1)
        return n
    }

    goToDesktopPrev(wrap:=True) {
        return this.goToDesktopNumber(this.getCurrentDesktopNumber()-1, wrap)
    }
    goToDesktopNext(wrap:=True) {
        return this.goToDesktopNumber(this.getCurrentDesktopNumber()+1, wrap)
    }
    moveToDesktopPrev(win_hwnd, wrap:=True) {
        n:=this.getCurrentDesktopNumber()-1
        if this.moveWindowToDesktopNumber(n, win_hwnd, wrap) {
            this.goToDesktopNumber(n,wrap)
           ,WinActivate("ahk_id " win_hwnd)
            return n
        } else return 0
    }
    moveToDesktopNext(win_hwnd, wrap:=True) {
        n:=this.getCurrentDesktopNumber()+1
        if this.moveWindowToDesktopNumber(n, win_hwnd, wrap) {
            this.goToDesktopNumber(n,wrap)
           ,WinActivate("ahk_id " win_hwnd)
            return n
        } else return 0
    }

    pinWindowToggle(hwnd){
        if this.isPinnedWindow(hwnd)
            this.unPinWindow(hwnd)
        else
            this.pinWindow(hwnd)
        return this.isPinnedWindow(hwnd)
    }
    pinAppToggle(hwnd){
        if this.isPinnedApp(hwnd)
            this.unPinApp(hwnd)
        else
            this.pinApp(hwnd)
        return this.isPinnedApp(hwnd)
    }
}