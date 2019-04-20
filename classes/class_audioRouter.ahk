#include <VA>

/*
Methods:
    setProcessToDevice(ProcessName,DeviceName:="Default Audio Device")
      This sets the specified process to be used with the specified
      audio playback device.
    
    getDeviceList()
      Returns an array object containing all available playback
      devices.

Returned error codes:
    setProcessToDevice()
      Returns string defining the error.
*/

class audioRouter {
    winId:="Audio Router ahk_class Audio Router ahk_exe Audio Router.exe"
    winRoutId:="Route Audio ahk_class #32770 ahk_exe Audio Router.exe"
    path:=""
    
    __new(path){
        if(!a_isAdmin){
            msgbox,,Error,This object requires administrative privileges.
            return
        }
        if(!fileExist(path)){
            msgbox,,Error,Path doesn't exist.
            return
        }
        detectHiddenWindows,on
        detectHiddenText,on
        setControlDelay -1
        this.path:=path
        return this
    }
    
    __delete(){
        this.killIt()
    }
    
    setProcessToDevice(procName,deviceName:="Default Audio Device"){
        if(this.runIt())
            return "Waiting for Audio Router window timed out."
        if(this._method1(procName)){
            this.killIt()
            return "Process not found in list."
        }
        if(this._selectDeviceRouteWindow(deviceName)){
            this.killIt()
            return "Waiting for Route Audio window timed out."
        }
        this.killIt()
    }

    getDeviceList(){ ;credit to qwerty12 - https://autohotkey.com/boards/viewtopic.php?p=154595#p154595
        audioDevices:=["Default Audio Device"],i:=1
        while(device:=VA_GetDevice("playback:" . i++))
            audioDevices.push(VA_GetDeviceName(device)),ObjRelease(device)
        return audioDevices
    }
    
    ; internal
    _method1(procName){
        lvc:="SysListView321"
        lvmIndex:=0
        winMenuSelectItem,% "ahk_id " . this.hwnd,% "",File,Switch View
        while(!lvh)
            controlGet,lvh,Hwnd,,% lvc,% this.winId
        controlGet,lvx,list,count,,% "ahk_id " . lvh
        controlFocus,,% "ahk_id " . lvh
        while(!lvT||!inStr(lvT,procName)){
            controlSend,,{down},% "ahk_id " . lvh
            controlGet,lvT,list,focused,,% "ahk_id " . lvh
            if(++lvmIndex>lvx)
                return 1
        }

        pos:=this.LVM_GETITEMPOSITION(lvmIndex,lvh)
        postMessage,0x203,0,pos.x&0xFFFF | pos.y<<16,,% "ahk_id " . lvh ; WM_LBUTTONDBLCLCK
    }
    
    _selectDeviceRouteWindow(deviceName){
        winWait,% this.winRoutId,,10
        if(errorlevel)
            return 1
        control,chooseString,% deviceName,ComboBox1,% this.winRoutId
        controlClick,Button1,% this.winRoutId,,,,NA
        sleep 1000
    }
    
    runIt(debug:=0){
        run,% this.path,,% debug?"":"hide",hpid
        winWait,% this.winId,,10
        if(errorlevel)
            return 1
        winGet,hhwnd,id,% this.winId
        this.pid:=hpid,this.hwnd:=hhwnd
        if(!debug){
            sysGet,width,78
            sysget,height,79
            winMove,% "ahk_id " . hhwnd,,width,height
        }
    }
    
    killIt(){
        process,close,% this.pid
        this.pid:="",this.hwnd:=""
    }
    
    ; other
    LVM_GETITEMPOSITION(itemIdx,hwnd){ ;credit to qwerty12 - https://autohotkey.com/boards/viewtopic.php?p=154570#p154570
        if (!(hProcess := DllCall("OpenProcess", "UInt", PROCESS_QUERY_INFORMATION := 0x0400 | PROCESS_VM_OPERATION := 0x0008 | PROCESS_VM_READ := 0x0010 | PROCESS_VM_WRITE := 0x0020, "Int", False, "UInt", this.pid, "Ptr"))) ; open handle to process 
            throw
        if (!(remotePoint := DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "Ptr", 8, "UInt", MEM_COMMIT := 0x00001000, "UInt", PAGE_READWRITE := 0x04, "Ptr"))) ; allocate memory inside process
            throw
        if (!DllCall("SendMessage", "Ptr", hwnd, "UInt", LVM_GETITEMPOSITION := 0x1000+16, "Ptr", itemIdx, "Ptr", remotePoint, "Ptr")) ; because I find AHK's built-in clunkier
            throw
        varSetCapacity(point,8,0)
        if (!DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", remotePoint, "Ptr", &point, "Ptr", 8, "Ptr*", br) || br != 8) ; read point structure out from process and save into local copy
            throw
;        sendMessage,% LVM_GETITEMPOSITION,% itemIndex,&point,,% "ahk_id " . hwnd ; ,% "ahk_id " . hwnd
        itemPos:={x: numGet(point,0,"Int"),y: numGet(point,4,"Int")}
        if (hProcess) {
            if (remotePoint)
                DllCall("VirtualFreeEx", "Ptr", hProcess, "Ptr", remotePoint, "Ptr", 0, "UInt", MEM_RELEASE := 0x8000) ; free allocated memory in remote process
            DllCall("CloseHandle", "Ptr", hProcess) ; close handle to remote process
        }
        return itemPos
    }
    
/*  deprecated

    getDeviceList(){
        if(this.runIt())
            return 1
        if(this._method1(this.selfProc))
            return 2
        deviceList:=[]
        winWait,% this.winRoutId,,10
        if(errorlevel)
            return 3
        loop {
            control,choose,% a_index,ComboBox1,% this.winRoutId
            if(errorlevel)
                break
            controlGetText,t,ComboBox1,% this.winRoutId
            deviceList.push(t)
        }
        this.killIt()
        return deviceList
    }
    
    _method2(procName){
        loop {
            controlGetText,cT,% "Static" . a_index,% "ahk_id " . this.hwnd
            if(errorlevel)
                break
            if(inStr(cT,procName)){
                controlClick,% "Button" . a_index+1,% "ahk_id " . this.hwnd
                controlSend,% "Button" . a_index+1,{down 3}{enter},% "ahk_id " . this.hwnd
                break
            }
        }
    }
*/
}