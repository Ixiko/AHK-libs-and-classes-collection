GetWanIp(pDnsIp) {
    
    Local
    
    ClipBrdOld := Clipboard
    
    WaitConnectISP:
    Clipboard := ""
    RunWait, %ComSpec% /c "ping -n 1 -r 1 %pDnsIp% | clip", , Hide

    Loop, parse, % Clipboard, `n, `r
    {
        if (A_Index = 4) {
        
            if (!(WanIp := Trim(SubStr(A_LoopField, 12), " `t`n`r"))) {
                Gosub, WaitConnectISP
                break
            }
            else if (WanIp > 0) {
                Clipboard := ClipBrdOld  
                
               
            }
        }
    }
     return WanIp
}
