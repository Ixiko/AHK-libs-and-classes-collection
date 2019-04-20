#include <_MemoryLibrary>

class threadMan {
    ahkDllPath:=
    dllObj:=
    tHandle:=
    quitTimeout:=1000
    
    ; meta-functions
    
    __New(ahkDllPath,isResource=0){
        this.ahkDllPath:=ahkDllPath
;        if(isResource)
;            readResource(dlldata,ahkDllPath)
;        else
            fileRead,dlldata,% "*c " . ahkDllPath
        this.dllObj:=new _MemoryLibrary(&dlldata)
    }
    
    __Delete(){
        this.quit(this.quitTimeout)
        this.dllObj.free()
        this.dllObj:=this.tHandle:=""
    }
    
    ; methods
    
    newFromText(codeStr,options="",params=""){
        if(this.status())
            return 1
        this.tHandle:=dllCall(this.dllObj.getProcAddress("ahktextdll"),"Str",codeStr,"Str",options,"Str",params,"Cdecl UPtr")
    }
    
    newFromFile(filePath,options="",params=""){
        if(this.status())
            return 1
        this.tHandle:=dllCall(this.dllObj.getProcAddress("ahkdll"),"Str",filePath,"Str",options,"Str",params,"Cdecl UPtr")
    }
    
    addScript(codeStr,execute=0){
        return dllCall(this.dllObj.getProcAddress("addScript"),"Str",codeStr,"Uchar",execute,"Cdecl UPtr")
    }
    
    ; ignoreError: 0=signal an error if there was problem adding file
    ;              1=ignore error
    ;              2=remove script lines added by previous calls to addFile() and start executing at the first line in the new script
    addFile(filePath,includeAgain=0,ignoreError=0){
        return dllCall(this.dllObj.getProcAddress("addFile"),"Str",filePath,"Uchar",includeAgain,"Uchar",ignoreError,"Cdecl UPtr")
    }
    
    waitQuit(timeout="",sleepAccuracy=100){
        if(timeout)
            while(this.status() && timePast < timeout){
                sleep sleepAccuracy
                timePast+=sleepAccuracy
            }
        else
            while(this.status())
                sleep sleepAccuracy
        return this.status()
    }
    
    quit(timeout=0){
        dllCall(this.dllObj.getProcAddress("ahkTerminate"),"Int",timeout,"Cdecl Int")
    }
    
    status(){
        return dllCall(this.dllObj.getProcAddress("ahkReady"))
    }
    
    reload(){
        dllCall(this.dllObj.getProcAddress("ahkReload"))
    }
    
    pause(pauseState:="tog"){
        if(pauseState="tog"){
            pauseState:=!this.pauseState()
            ;pauseState:=!pauseState
        }
        pauseState:=dllCall(this.dllObj.getProcAddress("ahkPause"),"Str",pauseState,"Cdecl Int")
        return pauseState
    }
    
    pauseState(){
        return dllCall(this.dllObj.getProcAddress("ahkPause"),"Str","","Cdecl Int")
    }
    
    state(){
        running:=this.status()
        if(running){
            pauseState:=this.pauseState()
            suspendState:=this.varGet("a_isSuspended")
            return pauseState?(suspendState?"P/S":"Paused"):(suspendState?"Suspended":"Running")
        }
        return "Stopped"
    }
    
    exec(codeStr){
        if(this.pauseState())
            msgbox,,Error,Code can not be executed while thread is paused.
        else
            return dllCall(this.dllObj.getProcAddress("ahkExec"),"Str",codeStr)
    }
    
    execLine(linePointer="",mode="",wait=""){
        if(this.pauseState())
            msgbox,,Error,Code can not be executed while thread is paused.
        else
            return dllCall(this.dllObj.getProcAddress("ahkExecuteLine"),"UPtr",linePointer,"UInt",mode,"UInt",wait,"Cdecl UPtr")
    }
    
    execLabel(label,wait=0){
        if(this.pauseState())
            msgbox,,Error,Code can not be executed while thread is paused.
        else
            return dllCall(this.dllObj.getProcAddress("ahkLabel"),"Str",label,"UInt",wait,"Cdecl UInt")
    }
    
    execFunc(func,params*){
        if(this.pauseState()){
            msgbox,,Error,Code can not be executed while thread is paused.
            return
        }
        
        if(!params.length())
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Cdecl UInt")
        if(params.length()=1)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Cdecl UInt")
        if(params.length()=2)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Str",params[2],"Cdecl UInt")
        if(params.length()=3)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Cdecl UInt")
        if(params.length()=4)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Cdecl UInt")
        if(params.length()=5)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Cdecl UInt")
        if(params.length()=6)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Cdecl UInt")
        if(params.length()=7)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Str",params[7],"Cdecl UInt")
        if(params.length()=8)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Str",params[7],"Str",params[8],"Cdecl UInt")
        if(params.length()=9)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Str",params[7],"Str",params[8],"Str",params[9],"Cdecl UInt")
        if(params.length()=10)
            return dllCall(this.dllObj.getProcAddress("ahkFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Str",params[7],"Str",params[8],"Str",params[9],"Str",params[10],"Cdecl UInt")
    }
    
    execAFunc(func,params*){
        if(!params.length())
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Cdecl UInt")
        if(params.length()=1)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Cdecl UInt")
        if(params.length()=2)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Str",params[2],"Cdecl UInt")
        if(params.length()=3)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Cdecl UInt")
        if(params.length()=4)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Cdecl UInt")
        if(params.length()=5)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Cdecl UInt")
        if(params.length()=6)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Cdecl UInt")
        if(params.length()=7)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Str",params[7],"Cdecl UInt")
        if(params.length()=8)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Str",params[7],"Str",params[8],"Cdecl UInt")
        if(params.length()=9)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Str",params[7],"Str",params[8],"Str",params[9],"Cdecl UInt")
        if(params.length()=10)
            return dllCall(this.dllObj.getProcAddress("ahkPostFunction"),"Str",func,"Str",params[1],"Str",params[2],"Str",params[3],"Str",params[4],"Str",params[5],"Str",params[6],"Str",params[7],"Str",params[8],"Str",params[9],"Str",params[10],"Cdecl UInt")
    }
    
    varSet(varName,varVal){
        return dllCall(this.dllObj.getProcAddress("ahkassign"),"Str",varName,"Str",varVal)
    }

    varGet(varName,pointer=0){
        return dllCall(this.dllObj.getProcAddress("ahkgetvar"),"Str",varName,"UInt",pointer,"Cdecl Str")
    }
}