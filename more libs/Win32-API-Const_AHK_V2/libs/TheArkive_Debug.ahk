class Debug {
    Static _gui := "", hwnd := 0, ctlHwnd := 0
    Static StartMakingGui := 0, locked := 1
    
    Static Msg(str, TimeStamp := true) {
        this.makeGui()
        
        If (TimeStamp) ; append timestamp + str
            str := "[" A_Hour ":" A_Min ":" A_Sec "] " str "`r`n"
        
        If (this.hwnd)
            this.AppendTxt(this.ctlHwnd,StrPtr(str))
    }
    
    Static makeGui() {
        If (WinExist("ahk_id " this.hwnd))
            return
        
        If (this.hwnd Or this.StartMakingGui) ; skip making the GUI
            return
        
        this.StartMakingGui := 1
        
        guiClose := ObjBindMethod(this,"gClose")
        this.guiClose := guiClose
        guiSize := ObjBindMethod(this,"gSize")
        this.guiSize := guiSize
        ctlEvent := ObjBindMethod(this,"event")
        this.ctlEvent := ctlEvent
        
        ArkDebugObj := Gui.New("+Resize +AlwaysOnTop","TheArkyTekt Debug Window")
        ArkDebugObj.OnEvent("close", this.guiClose)
        ArkDebugObj.OnEvent("size", this.guiSize)
        
        ArkDebugObj.SetFont("s11","Courier New")
        ctl := ArkDebugObj.Add("Button","vCopy x5 y5 Section","Copy to Clipboard").OnEvent("Click",ctlEvent)
        ctl := ArkDebugObj.Add("Button","vClear yp x+5","Clear Window").OnEvent("Click",ctlEvent)
        
        ctl := ArkDebugObj.Add("Edit","vEditBox xs y+0 w700 h500 Multi ReadOnly")
        this.ctlHwnd := ctl.hwnd, ctl := ""
        
        ArkDebugObj.Show("NA NoActivate")
        
        this.locked := 0
        this.hwnd := ArkDebugObj.hwnd
        this.locked := 1
        
        this._gui := ArkDebugObj
    }
    
    Static gClose(g) {
        this._gui.Destroy()
        this.hwnd := 0, this.ctlHwnd := 0
        this.StartMakingGui := 0
    }
    
    Static gSize(g, MinMax, Width, Height) {
        ; msgbox "in size"
        x := "", y := "", w := "", h := "", ctl := ""
        w := Width - 10, h := Height - 10 - 40
        ctl := g["EditBox"]
        ctl.GetPos(x,y)
        ctl.Move(x,y,w,h)
    }
    
    Static AppendTxt(hEdit, ptrText, loc:="bottom") {
        charLen := SendMessage(0x000E, 0, 0,, "ahk_id " hEdit)                        ;WM_GETTEXTLENGTH
        If (loc = "bottom")
            SendMessage 0x00B1, charLen, charLen,, "ahk_id " hEdit    ;EM_SETSEL
        Else If (loc = "top")
            SendMessage 0x00B1, 0, 0,, "ahk_id " hEdit
        SendMessage 0x00C2, False, ptrText,, "ahk_id " hEdit            ;EM_REPLACESEL
    }
    
    Static event(ctl,info) {
        If (ctl.Name = "Copy")
            A_Clipboard := ctl.gui["EditBox"].Value
        Else If (ctl.Name = "Clear")
            ctl.gui["EditBox"].Value := ""
    }
}
