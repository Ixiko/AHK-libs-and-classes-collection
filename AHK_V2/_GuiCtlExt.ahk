; ==================================================================
; GuiControl_Ext
; ==================================================================

class GuiCtl_Ext { ; apply common stuff to other gui controls
    Static __New() {
        Gui.ListBox.Prototype.GetItems := this.prototype.GetItems
        Gui.ListBox.Prototype._GetString := this.prototype._GetString
        Gui.ComboBox.Prototype.GetItems := this.prototype.GetItems
        Gui.ComboBox.Prototype._GetString := this.prototype._GetString
        
        Gui.Edit.Prototype._SetSel := this.prototype._SetSel
        Gui.Edit.Prototype._SelText := this.prototype._SelText
        Gui.ComboBox.Prototype._SetSel := this.prototype._SetSel
        Gui.ComboBox.Prototype._SelText := this.prototype._SelText
    }
    
    GetItems() {
        result := []
        Loop this.GetCount()
            result.Push(this.GetText(A_Index))
        return result
    }
    
    _GetString(getLen_msg,get_msg,row) {
        size := SendMessage(getLen_msg, row-1, 0, this.hwnd) ; GETTEXTLEN
        buf := Buffer( (size+1) * (StrLen(Chr(0xFFFF))?2:1), 0 )
        SendMessage(get_msg, row-1, buf.ptr, this.hwnd) ; GETTEXT
        return StrGet(buf)
    }
    
    _SetSel(start,end) {
        If (start="")
            start := this.SelStart
        If (end="")
            (start=-1) ? (start := end := StrLen(this.Text)) : (start=0) ? (end := 0) : (end := start)
        If !IsInteger(start) || !IsInteger(end)
            throw Error("Invalid value.  Only integers are accepted.")
        return [start,end]
    }
    
    _SelText(p*) {
        dword := SendMessage(p[1],0,0,this.hwnd) ; CB_GETEDITSEL
        range := [start := (dword & 0xFFFF), end := ((dword >> 16) & 0xFFFF)]
        
        result := ""
        Switch p[2] {
            Case "sel": result := SubStr(this.Text,range[1]+1,range[2]-range[1])
               Default: result := (p[2]="start")?start:end
        }
        return result
    }
}

class ListBox_Ext extends Gui.ListBox {
    Static __New() {
        For prop in this.Prototype.OwnProps()
            super.Prototype.%prop% := this.Prototype.%prop%
    }
    
    GetCount() => SendMessage(0x018B, 0, 0, this.hwnd) ; LB_GETCOUNT
    
    GetText(row) => this._GetString(0x18A,0x189,row) ; 0x18A > LB_GETTEXTLEN // 0x189 > LB_GETTEXT
}

class ComboBox_Ext extends Gui.ComboBox {
    Static __New() {
        super.Prototype._CurCueText := ""
        For prop in this.Prototype.OwnProps() 
            super.Prototype.%prop% := this.Prototype.%prop%
        super.Prototype.DefineProp("CueText",{Get:this.Prototype._CueText,Set:this.Prototype._CueText})
        
        super.Prototype.DefineProp("SelText",{Get:this.Prototype._SelText.Bind(,0x140,"sel")})    ; 1st param is the instance, ...
        super.Prototype.DefineProp("SelStart",{Get:this.Prototype._SelText.Bind(,0x140,"start")}) ; ... so don't overwrite it.
        super.Prototype.DefineProp("SelEnd",{Get:this.Prototype._SelText.Bind(,0x140,"end")})
        
        super.Prototype.AutoComplete := false
    }
    
    _CueText(p*) { ; thanks to AHK_user and iPhilip for this one: https://www.autohotkey.com/boards/viewtopic.php?p=426941#p426941
        If !p.Length
            return this._CurCueText
        Else SendMessage(0x1703, 0, StrPtr(this._CurCueText:=p[1]), this.hwnd)
    }
    
    check_match(t:=false) {
        For i, val in this.GetItems()
            If (InStr(val,(t?this.temp_value:this.Text))=1 && (t?this.temp_value:this.Text))
                return val
            ; If (RegExMatch(val,"i)^\Q" (t?this.temp_value:this.Text) "\E") && (t?this.temp_value:this.Text))
                ; return val
    }
    
    GetCount() => SendMessage(0x146, 0, 0, this.hwnd)  ; CB_GETCOUNT
    
    GetText(row) => this._GetString(0x149,0x148,row) ; 0x149 > CB_GETLBTEXTLEN // 0x148 > CB_GETLBTEXT
    
    SetSel(start:="",end:="") {
        result := this._SetSel(start,end)
        dword := (result[1] | (result[2] << 16))
        SendMessage(0x142, 0, dword, this.hwnd) ; CB_SETEDITSEL
    }
}

class ListView_Ext extends Gui.ListView { ; Technically no need to extend classes unless
    Static __New() { ; you are attaching new base on control creation.
        For prop in this.Prototype.OwnProps()
            super.Prototype.%prop% := this.Prototype.%prop%
    }
    
    ; This was taken directly from the AutoHotkey help files.
    Checked(row) => (SendMessage(4140,row-1,0xF000,, "ahk_id " this.hwnd) >> 12) - 1 ; VM_GETITEMSTATE = 4140 / LVIS_STATEIMAGEMASK = 0xF000
    
    IconIndex(row,col:=1) { ; from "just me" LV_EX ; Link: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=69262&p=298308#p299057
        LVITEM := Buffer((A_PtrSize=8)?56:40, 0)                   ; create variable/structure
        NumPut("UInt", 0x2, "Int", row-1, "Int", col-1, LVITEM.ptr, 0)  ; LVIF_IMAGE := 0x2 / iItem (row) / column num
        NumPut("Int", 0, LVITEM.ptr, (A_PtrSize=8)?36:28)               ; iImage
        SendMessage(StrLen(Chr(0xFFFF))?0x104B:0x1005, 0, LVITEM.ptr,, "ahk_id " this.hwnd) ; LVM_GETITEMA/W := 0x1005 / 0x104B
        return NumGet(LVITEM.ptr, (A_PtrSize=8)?36:28, "Int")+1 ;iImage
    }
    
    GetColWidth(n) => SendMessage(0x101D, n-1, 0, this.hwnd)
}

class StatusBar_Ext extends Gui.StatusBar {
    Static __New() {
        For prop in this.Prototype.OwnProps()
            super.Prototype.%prop% := this.Prototype.%prop%
    }
    RemoveIcon(part:=1) {
        hIcon := SendMessage(0x414, part-1, 0, this.hwnd)
        If hIcon
            SendMessage(0x40F, part-1, 0, this.hwnd)
        return DllCall("DestroyIcon","UPtr",hIcon)
    }
}

class PicButton extends Gui.Button {
    Static __New() {
        Gui.Prototype.AddPicButton := this.AddPicButton
    }
    Static AddPicButton(sOptions:="",sPicFile:="",sPicFileOpt:="",txt:="") {
        ctl := this.Add("Button",sOptions,txt)
        ctl.base := PicButton.Prototype
        ctl.SetImg(sPicFile, sPicFileOpt)
        return ctl
    }
    SetImg(sFile, sOptions:="") { ; input params exact same as first 2 params of LoadPicture()
        Static ImgType := 0       ; thanks to teadrinker: https://www.autohotkey.com/boards/viewtopic.php?p=299834#p299834
        Static BS_ICON := 0x40, BS_BITMAP := 0x80, BM_SETIMAGE := 0xF7
        
        hImg := LoadPicture(sFile, sOptions, &_type)
        If !this.Text ; thanks to "just me" for advice on getting text and images to display
            ControlSetStyle (ControlGetStyle(this.hwnd) | (!_type?BS_BITMAP:BS_ICON)), this.hwnd
        hOldImg := SendMessage(BM_SETIMAGE, _type, hImg, this.hwnd)
        
        If (hOldImg)
            (ImgType) ? DllCall("DestroyIcon","UPtr",hOldImg) : DllCall("DeleteObject","UPtr",hOldImg)
        
        ImgType := _type ; store current img type for next call/release
    }
    Type {
        get => "PicButton"
    }
}

class SplitButton extends Gui.Button {
    Static __New() {
        super.Prototype.SetImg := PicButton.Prototype.SetImg
        Gui.Prototype.AddSplitButton := this.AddSplitButton
    }
    Static AddSplitButton(sOptions:="",sText:="",callback:="") {
        Static BS_SPLITBUTTON := 0xC
        
        ctl := this.Add("Button",sOptions,sText)
        ctl.base := SplitButton.Prototype
        
        ControlSetStyle (ControlGetStyle(ctl.hwnd) | BS_SPLITBUTTON), ctl.hwnd
        If callback
            ctl.callback := callback
          , ctl.OnNotify(-1248, ObjBindMethod(ctl,"DropCallback"))
            
        return ctl
    }
    
    Drop() => this.DropCallback(this,0)
    
    DropCallback(ctl, lParam) {
        ctl.GetPos(&x,&y,,&h)
        f := this.callback, f(ctl,{x:x, y:y+h})
    }
    Type {
        get => "SplitButton"
    }
}

class ToggleButton extends Gui.Checkbox {
    Static __New() {
        super.Prototype.SetImg := PicButton.Prototype.SetImg
        Gui.Prototype.AddToggleButton := this.AddToggleButton
    }
    Static AddToggleButton(sOptions:="",sText:="") {
        ctl := this.Add("Checkbox",sOptions " +0x1000",sText)
        ctl.base := ToggleButton.Prototype
        return ctl
    }
    Type {
        get => "ToggleButton"
    }
}

class Edit_Ext extends Gui.Edit {
    Static __New() {
        super.Prototype._CurCueText := "" ; for easy get/read
        super.Prototype._CueOption := false
        For prop in this.Prototype.OwnProps()
            super.Prototype.%prop% := this.prototype.%prop%
        
        super.Prototype.DefineProp("CueText",{Get:this.Prototype._CueText,Set:this.Prototype._CueText})
        
        super.Prototype.DefineProp("SelText",{Get:this.Prototype._SelText.Bind(,0xB0,"sel")}) ; this is also caret position
        super.Prototype.DefineProp("SelStart",{Get:this.Prototype._SelText.Bind(,0xB0,"start")})
        super.Prototype.DefineProp("SelEnd",{Get:this.Prototype._SelText.Bind(,0xB0,"end")})
    }
    
    Append(txt, top := false) {
        txtLen := SendMessage(0x000E, 0, 0,,this.hwnd)           ;WM_GETTEXTLENGTH
        pos := (!top) ? txtLen : 0
        SendMessage(0x00B1, pos, pos,,this.hwnd)           ;EM_SETSEL
        SendMessage(0x00C2, False, StrPtr(txt),,this.hwnd)    ;EM_REPLACESEL
    }
    
    _CueText(p*) { ; thanks to AHK_user and iPhilip for this one: https://www.autohotkey.com/boards/viewtopic.php?p=426941#p426941
        If !p.Length
            return this._CurCueText
        Else If (p.Length = 2)
            SendMessage(0x1501, (this._CueOption := (p[2]?p[2]:0)), StrPtr(this._CurCueText:=p[1]), this.hwnd)
    }
    
    SetCueText(txt,option:=false) => SendMessage(0x1501, this._CueOption:=option, StrPtr(this._CurCueText:=txt), this.hwnd)
    
    SetSel(start:="",end:="") {
        result := this._SetSel(start,end)
        SendMessage(0xB1, result[1], result[2], this.hwnd) ; EM_SETSEL
    }
}

; ==================================================================
; Gui_Ext
; ==================================================================

class Gui_Ext extends Gui {
    Static __New() {
        Gui.Prototype := this.Prototype
    }
    Add(p*) {
        ctl := super.Add(p*)
        
        If (p[1] = "ComboBox") {
            ctl.temp_value := ""
            ctl.OnEvent("change",AutoCompCb)
            OnMessage(0x102,ComboChar) ; WM_CHAR
        }
        
        return ctl
        
        AutoCompCb(ctl, info) {
            If ctl.temp_value { ; temp_value
                ctl.Text := ctl.temp_value
                If (match := ctl.check_match()) {
                    ctl.Text := match
                    ctl.SetSel(StrLen(ctl.temp_value),0xFFFF)
                }
            }
        }
        
        ComboChar(wParam, lParam, msg, hwnd) { ; WM_CHAR callback
            ctl := GuiCtrlFromHwnd(hwnd)
            If (ctl.Type = "ComboBox" && ctl.AutoComplete) {
                start := SubStr(ctl.Text,1,ctl.SelStart)
                end   := SubStr(ctl.Text,ctl.SelEnd+1)
                sel   := ctl.SelText
                
                If (char := (wParam=8) ? "" : Chr(wParam)) {
                    ctl.temp_value := (ctl.SelStart=0 && ctl.Text!=ctl.SelText) ? (sel char) : (start char end)
                    ctl.temp_value := (!ctl.check_match(true)) ? "" : ctl.temp_value
                } Else ctl.temp_value := ""
            } ; dbg("temp_value: '" ctl.temp_value "' / do_select: " ctl.do_select " / selStart: " ctl.SelStart " / selEnd: " ctl.SelEnd)
        }
    }
}