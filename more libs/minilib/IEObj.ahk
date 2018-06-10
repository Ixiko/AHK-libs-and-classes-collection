#include *i <userAgents>
class IEObj {
    
    __new(){
        detectHiddenWindows on
        return this
    }
    
    __delete(){
        this.quit()
    }
    
    ; methods
    init(private:=0,extensionsOff:=0){
        this.init:=0
        ;static url:="about:InPrivate"
        
        run,% "Iexplore.exe " . (extenstionsOff?"-extoff ":"") . (private?"-private ":"") . "-noframemerging about:blank",,,wbpid
        this.wbpid:=wbpid
        ;winWait,% "ahk_pid " . this.wbpid
        while(!isObject(this.wb:=this.IEGetbyURL("about:blank")))
            sleep 100
        this.wb.silent:=1
        this.wb.visible:=0
        ;i+=this.navToUrl("www.google.com")
        return
    }
    
    init2(){
        this.init:=1
        this.wb:=comObjCreate("InternetExplorer.Application")
        winGet,wbpid,pid,% "ahk_id " . wb.wb.hwnd
        this.wbpid:=wbpid
        this.wb.silent:=1
        return
    }
    
    ; wb functions
    waitLoad(timeout:=15000){
        static sleepTime:=100

        t:=0
        timeout/=sleepTime
        try{
            while((++t<timeout) && (this.wb.readyState!=4 || this.wb.document.readyState!="complete"))
                sleep sleepTime
        }catch{
            return 1
        }
        return (t>=timeout?1:0)
    }
    
    navToUrl(url,timeout:=15000,userAgent:="",attempts:=1){
        t:=0
        try{
            loop{
                this.wb.navigate(url,0,0,0,userAgent)
                i:=this.waitLoad(timeout)
            }until !i || ++t>=attempts
        }catch{
            return 1
        }
        return i
    }
    
    ; etc
    quit(){
        if(!this.init){
            while(processExist(this.wbpid)){
                process,close,% this.wbpid
                sleep 1000
            }
        }else{
            this.wb.quit()
            sleep 1000
            try{
                while(winExist("ahk_id " . this.wb.hwnd)){
                    process,close,% "ahk_id " . this.wb.hwnd
                    sleep 1000
                }
            }
        }
    }
    
    IEGetbyURL(URL) {	; http://www.autohotkey.com/board/topic/102723-ieget-via-url-instead-of-name/#entry636586
        for pwb in comObjCreate("Shell.Application").Windows
            ;msgbox % pwb.LocationURL
            if (pwb.LocationURL = URL and InStr(pwb.FullName, "iexplore.exe") > 0)
                return pwb
    }
    
    err(desc){
        msgbox,,Error,% desc
    }
}