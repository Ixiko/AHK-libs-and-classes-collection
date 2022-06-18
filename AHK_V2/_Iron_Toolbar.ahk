;=======================================================================================
; AHK v2
;=======================================================================================
; IronToolbar (ClassToolbarWindow32)
; based on Class Toolbar by Pulover [Rodolfo U. Batista] for AHK v1.1.23.01 (https://github.com/Pulover/Class_Toolbar)
; Microsoft Docs Reference: https://docs.microsoft.com/en-us/windows/win32/controls/bumper-toolbar-toolbar-control-reference
;=======================================================================================
;=======================================================================================

; class Gui_Control_Extender extends Gui { ; Works but won't play well with other
    ; Static __New() {
        ; Gui.Prototype := this.prototype
    ; }
    ; Add(p*) {
        ; If (p[1] = "Toolbar") {
            ; new_p := []
            ; Loop p.Length
                ; If A_Index > 1
                    ; new_p.Push(p[A_Index])
                    
            ; ctl := Toolbar.AddToolbar(this, new_p*)
            
            ; return ctl
        ; } Else return super.Add(p*)
    ; }
; }

class Toolbar extends Gui.Custom { ; extends Toolbar.Private {
    Static TBBUTTON_size := ((A_PtrSize = 4) ? 20 : 32), NMHDR_size := (A_PtrSize * 3)
    
    Static styles := {AltDrag:0x400       ; Toolbar Styles https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-control-and-button-styles
                    , CustomErase:0x2000, Flat:0x800, List:0x1000, RegisterDrop:0x4000, ToolTips:0x100, Transparent:0x8000, Wrapable:0x200
                    
                    , Border:0x800000, TabStop:0x10000, ThickFrame:0x40000 ; Window Styles https://docs.microsoft.com/en-us/windows/win32/winmsg/window-styles
                    , Child:0x40000000
                    
                    , Adjustable:0x20     ; Common Control Styles https://docs.microsoft.com/en-us/windows/win32/controls/common-control-styles
                    , Bottom:0x3, Left:0x81, Right:0x83, Top:0x1, NoDivider:0x40, NoMoveX:0x82, NoMoveY:0x2, NoParentAlign:0x8, NoResize:0x4, Vert:0x80}
                    
    Static bStyles := {AutoSize:0x10      ; Toolbar Button Styles https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-control-and-button-styles
                    , Button:0, Check:0x2, CheckGroup:0x6, DropDown:0x8, Group:0x4, NoPrefix:0x20, Sep:0x1, ShowText:0x40, WholeDropDown:0x80}
    
    Static exStyles := {DoubleBuffer:0x80 ; Extended Toolbar Styles https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-extended-styles
                      , DrawDDArrows:0x01, HideClippedButtons:0x10, MixedButtons:0x08, MultiColumn:0x02, Vertical:0x04}
    
    Static states := {Checked:0x01        ; Toolbar Button States https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-button-states
                    , Ellipses:0x40, Enabled:0x04, Hidden:0x08, Marked:0x80, Pressed:0x02, Wrap:0x20, Grayed:0x10} ; TBSTATE_INDETERMINATE = Grayed = 0x10
    
    Static flags := {Large:0x1            ; TB_GETBITMAPFLAGS https://docs.microsoft.com/en-us/windows/win32/controls/tb-getbitmapflags
    
                   , ByIndex:0x80000000   ; TBBUTTONINFOA dwMask https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tbbuttoninfoa
                   , Command:0x20, Image:0x1, lParam:0x10, Size:0x40, State:0x4, Style:0x8, Text:0x2}
    
    Static wm_n := {BeginAdjust:-703      ; WM_NOTIFY Toolbar Notifications https://docs.microsoft.com/en-us/windows/win32/controls/bumper-toolbar-control-reference-notifications
                  , BeginDrag:-701, CustHelp:-709, DeletingButton:-715, DragOut:-714, DragOver:-727, DropDown:-710, DupAccelerator:-725, EndAdjust:-704
                  , EndDrag:-702, GetObject:-712, HotItemChange:-713, InitCustomize:-723, MapAccelerator:-728, QueryDelete:-707, QueryInsert:-706
                  , Reset:-705, Restore:-721, Save:-722, ToolbarChange:-708, WrapAccelerator:-726, WrapHotItem:-724, EndCustomize:2 ; TBNRF_ENDCUSTOMIZE
                  , GetButtonInfo:((A_PtrSize=8)?-720:-700), GetDispInfo:((A_PtrSize=8)?-717:-716), GetInfoTip:((StrLen(Chr(0xFFFF)))?-719:-718)
                  
                  , Char:-18 ; NM_* events https://docs.microsoft.com/en-us/windows/win32/controls/bumper-toolbar-control-reference-notifications
                  , CustomDraw:-12, KeyDown:-15, LDown:-20, ReleasedCapture:-16, ToolTipsCreated:-19, LClick:-2, LDClick:-3, RClick:-5, RDClick:-6, BN_CLICKED:2}
    
    Static messages := {AddButtons:0x414 ; Toolbar Messages https://docs.microsoft.com/en-us/windows/win32/controls/bumper-toolbar-control-reference-messages
    , AddString:(StrLen(Chr(0xFFFF))?0x044D:0x041C), AutoSize:0x421, ButtonCount:0x418, ChangeBitmap:0x42B, CheckButton:0x402, CommandToIndex:0x419
    , Customize:0x41B, DeleteButton:0x416, EnableButton:0x401, GetBitmap:0x42C, GetButton:0x417, GetButtonSize:0x43A
    , GetButtonInfo:(StrLen(Chr(0xFFFF))?0x43F:0x441)
    , GetButtonText:(StrLen(Chr(0xFFFF))?0x044B:0x042D), GetExtendedStyle:0x455, GetHotItem:0x447, GetIdealSize:0x463, GetImageList:0x431
    , GetImageListCount:0x462, GetItemDropDownRect:0x467, GetItemRect:0x41D, GetMaxSize:0x453, GetMetrics:0x465, GetPadding:0x456
    , GetRect:0x433, GetRows:0x428, GetState:0x412, GetStyle:0x439, GetString:(StrLen(Chr(0xFFFF))?0x045B:0x045C), GetTextRows:0x43D
    , HideButton:0x404, Indeterminate:0x405, InsertButton:(StrLen(Chr(0xFFFF))?0x0443:0x0415), IsButtonChecked:0x40A, IsButtonEnabled:0x40A
    , IsButtonHidden:0x40C, IsButtonHighlighted:0x40E, IsButtonIndeterminate:0x40D, IsButtonPressed:0x40B, MakeButton:0x406
    , MoveButton:0x452, PressButton:0x403, SetBitmapSize:0x420, SetButtonInfo:(StrLen(Chr(0xFFFF))?0x0440:0x0442), SetButtonSize:0x41F
    , SetButtonWidth:0x43B, SetDisabledImageList:0x436, SetExtendedStyle:0x454, SetHotImageList:0x434, SetHotItem:0x448, SetHotItem2:0x45E
    , SetImageList:0x430, SetIndent:0x42F, SetListGap:0x460, SetMaxTextRows:0x43C, SetMetrics:0x466, SetPadding:0x457, SetPressedImageList:0x468
    , SetRows:0x427, SetState:0x411, SetStyle:0x438, HitTest:0x445, GetAnchorHighlight:0x44A, SetAnchorHighlight:0x449}
    
    Static hotItemFlags := {Accelerator:0x4 ; https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-nmtbhotitem
                          , ArrowKeys:0x2, DupAccel:0x8, Entering:0x10, Leaving:0x20, LMouse:0x80, Mouse:0x1, Reselect:0x40, ToggleDropDown:0x100} ; Other:0x0
    
    Static metrics := {Pad:0x1, BarPad:0x2, ButtonSpacing:0x4}
    
    Static TbList := []
    Static padding := 7
    ; Static redraw_frequency := 5, redraw_count := 0, size_cb_set := false ; see OnMessage() entry below
    
    Static __New() {                                                    ; Need to do it this way.
        Gui.prototype.AddToolbar := ObjBindMethod(this,"AddToolbar")    ; Multiple gui subclass extensions don't play well together.
    }
    
    Static AddToolbar(in_gui:="", sOptions:="", Styles:="", MixedBtns := true, EasyMode := true) {
        _Styles := "", startStyles := "", pos := "top", exStyles := "", ShowTextStatus := false
        
        (!easyMode) ? MixedBtns := false : ""
        
        Loop Parse Trim(Styles), " "
        {
            v := A_LoopField
            If (v="DrawDDArrows" Or v="HideClippedButtons" Or v="DoubleBuffer" Or v="MixedButtons" Or v="MultiColumn" Or v="Vertical") {
                exStyles .= A_LoopField " "
                Continue
            }
            
            If easyMode {
                If (v="top" Or v="bottom" or v="left" Or v="right") {
                    pos := A_LoopField
                    Continue
                } Else {
                    If (v = "ShowText")
                        ShowTextStatus := true
                    Else {
                        _Styles .= this.hex(this.styles.%A_LoopField%) " "
                        startStyles .= A_LoopField " "
                    }
                }
            } Else
                _Styles .= this.hex(this.styles.%A_LoopField%) " "
        }
        
        If easyMode { ; final easy mode modifications
            (!InStr(Styles,"NoParentAlign")) ? (_Styles .= " " this.hex(this.styles.NoParentAlign), startStyles .= " NoParentAlign") : ""
            (!InStr(Styles,"NoResize")) ? (_Styles .= " " this.hex(this.styles.NoResize), startStyles .= " NoResize") : ""
            (!InStr(Styles,"Flat")) ? (_Styles .= " " this.hex(this.styles.Flat), startStyles .= " Flat") : ""
            
            (MixedBtns And !InStr(Styles,"MixedButtons")) ? exStyles .= "MixedButtons " : ""
        }
        
        ; wm_cmd := ObjBindMethod(this,"WM_COMMAND")
        ; OnMessage 0x111, wm_cmd
        
        ctl := in_gui.Add("Custom","ClassToolbarWindow32 " sOptions " " _Styles)
        Toolbar.TbList.Push(ctl)
        
        ctl.ShowTextStatus := ShowTextStatus, ctl.MixedBtns := MixedBtns, ctl.easyMode := easyMode, ctl.pos := pos
        ctl.exStyles := exStyles, ctl.startStyles := startStyles, ctl.counter := 1
        ctl.callback := "tbEvent", ctl.hotItem := 0, ctl.hotItemID := 0, ctl.txtSpacing := 2
        
        ctl.ImageLists := Map(), ctl.ImageLists.CaseSense := false
        ctl.IL_Default := "", ctl.IL_Hot := "", ctl.IL_Pressed := "", IL_Disabled := ""
        ctl.btns := [], ctl.btnsBackup := []
        
        For prop, value in Toolbar.wm_n.OwnProps() ; register callback for several WM_NOTIFY events
            ctl.OnNotify(value,ObjBindMethod(this,"__tbNotify"))
        
        ctl.base := Toolbar.Prototype ; attach methods
        ctl.DefineProp("Type",{Get: (_type)=>("Toolbar")}) ; redefine .Type property
        
        this.ResetStructs(ctl)
        result := ctl.SendMsg(this.messages.SetExtendedStyle, 0, this.MakeFlags(exStyles,"exStyles")) ; set exStyles
        
        ; If !this.size_cb_set { ; this almost works - but flickers like crazy, and h value is off somehow when resizing quickly
            ; OnMessage(0x214,ObjBindMethod(this,"auto_size")) ; WM_SIZING
            ; OnMessage(0x216,ObjBindMethod(this,"auto_size")) ; WM_MOVING
            ; SetWinDelay -1
            ; this.size_cb_set := true
        ; }
        
        _cb := false
        Try _cb := %ctl.callback%
        If (Type(_cb)="Func" Or Type(_cb)="BoundFunc" Or Type(_cb)="Class")
            ctl.callback := _cb ; resolve string-based callback only once
        Else ctl.callback := false
        
        (ShowTextStatus) ? ctl.ShowText(true) : ""
        
        return ctl
    }
    
    Static hex(_in) {
        return Format("0x{:X}",_in)
    }
    
    Static SizeToolbar(tbo, w, h) {
        rows := tbo.GetRows()
        If (tbo.pos = "top")
            tbo.Move(,, w, rows * tbo.h)
        Else If (tbo.pos = "bottom")
            tbo.Move(, h - (rows * tbo.h), w, rows * tbo.h)
        Else If (tbo.pos = "left")
            tb.Move(,,, h)
        Else If (tbo.pos = "right")
            tb.Move(w-tbo.w,,,h)
    }
    
    ; WM_COMMAND(wParam, lParam, msg, hwnd) {
        ; Debug.Msg(wParam " / " lParam " / " msg " / " hwnd)
    ; }
    
    Static rlu(iInput, member) { ; reverse lookup constant by value (usually only for events)
        If (iInput = "")
            return ""
        output := ""
        For prop, value in Toolbar.%member%.OwnProps() {
            If (value = iInput) {
                output := prop
                Break
            }
        }
        If !output
            Msgbox "Unknown value: " iInput " / " Format("0x{:X}",iInput) " / Type: " Type(iInput) " / Len: " StrLen(iInput)
        Else return output
    }
    
    Add(btnArray, initial:=true) {
        btnArray := Toolbar.AddConvert(this,btnArray,initial)
        
        TBBUTTON := Buffer(Toolbar.TBBUTTON_size * btnArray.Length, 0)
        offset := 0
        
        For i, b in btnArray ; add buttons
            Toolbar.Fill_TBBUTTON(this, TBBUTTON, offset, b.label, b.icon, b.idCmd, b.states, b.styles, b.iString), offset += Toolbar.TBBUTTON_size
        
        result := this.SendMsg(Toolbar.messages.AddButtons, btnArray.Length, TBBUTTON.ptr)
        this.SendMsg(Toolbar.messages.SetMaxTextRows,this.ShowTextStatus ? 1 : 0) ; set text display mode
        
        If (this.easyMode And initial)
            this.Position(this.pos), this.Position(this.pos)
         
        this.AutoSize()
    }
    
    AutoSize() { ; references to "this" in ALL non-static members are the control
        PostMessage Toolbar.messages.AutoSize, 0, 0, this.hwnd
    }
    
    ChangeBitmap(_in, img_idx) {
        btn := this._GetBtn(_in)
        return this.SendMsg(Toolbar.messages.ChangeBitmap, btn.idCmd, img_idx-1)
    }
    
    ClearButtons() {
        Loop this.Count()
            this.Delete(1)
    }
    
    CmdToIdx(idCmd) {
        return (this.SendMsg(Toolbar.messages.CommandToIndex, idCmd) + 1) << 32 >> 32
    }
    
    Check(_in,status:=false) { ; btn props: index, label, icon, states, styles, checked, idCmd, iString
        btn := this._GetBtn(_in)
        return this.SendMsg(Toolbar.messages.CheckButton, btn.idCmd, status)
    }
    
    Count() {
        return this.SendMsg(Toolbar.messages.ButtonCount)
    }
    
    Customizer() {
        files := this.ImageLists[this.IL_Default].files ; duplicate image list
        large := this.ImageLists[this.IL_Default].large, this.IL_Create("Customizer",files,large)
        
        events := ObjBindMethod(Toolbar,"CustoEvents", this) ; this will be confusing
        custo := Gui("AlwaysOnTop -MinimizeBox -MaximizeBox Owner" this.gui.hwnd,"Customizer")
        LV := custo.Add("ListView","w200 h200 vCustoList Report Checked -hdr",["Icon List"])
        LV.OnEvent("ItemCheck",events)
        LV.ModifyCol(1,170)
        LV.SetImageList(this.ImageLists["Customizer"].handle,1)
        
        btns := Toolbar.SaveNewLayout(this)
        
        For i, b in btns {
            c := !(b.states & Toolbar.states.Hidden) ? " Check" : ""
            LV.Add("Icon" b.icon c, (b.label) ? b.label : "Seperator")
        }
        custo.Add("Button","x+10 yp w100 vMoveUp","Move Up").OnEvent("click",events)
        custo.Add("Button","y+0 w100 vMoveDown","Move Down").OnEvent("click",events)
        custo.Add("Button","y+40 w100 vAddSep","Add Separator").OnEvent("click",events)
        custo.Add("Button","y+0 w100 vRemSep","Remove Seperator").OnEvent("click",events)
        custo.Add("Button","y+45 w50 vOK","OK").OnEvent("click",events)
        custo.Add("Button","x+0 w50 vCancel","Cancel").OnEvent("click",events)
        
        custo.btnsReset := Toolbar.SaveNewLayout(this)
        
        custo.Show("hide")
        this.gui.GetPos(&x,&y,&w,&h), cX := x+(w//2), cY := y+(h//2)
        custo.GetPos(,,&w,&h)
        x := cX-(w//2), y := cY-(h//2)
        custo.Show("x" x " y" y)
    }
    
    Delete(_in) {
        btn := this._GetBtn(_in)
        return this.SendMsg(Toolbar.messages.DeleteButton, btn.index-1,0)
    }
    
    EnableButton(_in, status) {
        btn := this._GetBtn(_in)
        return this.SendMsg(Toolbar.messages.EnableButton,btn.idCmd,Toolbar.MakeLong(status,0))
    }
    
    Export() {
        btns := Toolbar.SaveNewLayout(this), a := []
        For i, b in btns {
            props := Map(), props.CaseSense := false
            For prop, value in b.OwnProps()
                props[prop] := value
            a.InsertAt(i,props)
        }
        return a
    }
    
    _GetBtn(_in) {
        btns := Toolbar.SaveNewLayout(this), idx := 0, btn := ""
        If IsInteger(_in)
            btn := btns[_in]
        Else If Type(_in) = "String" {
            for i, b in btns {
                If (Type(_in)="String" And b.label=_in) Or (Type(_in)="Integer" and b.idCmd=_in) {
                    btn := b
                    break
                }
            }
        }
        If !btn {
            msgbox "Button not found!"
            return
        } Else return btn
    }
    
    GetAllButtons() {
        return Toolbar.SaveNewLayout(this)
    }
    
    GetBitmap(_in) {
        btn := this._GetBtn(_in)
        r := this.SendMsg(Toolbar.messages.GetBitmap, btn.idCmd)
        return (r > this.ImageLists[this.IL_Default].files.Length) ? 0 : r+1
    }
    
    GetMetrics(typ:="external") {
        METRICS := Buffer(bSize:=32,0)
        NumPut("UInt",bSize,"UInt",5,METRICS)
        this.SendMsg(Toolbar.messages.GetMetrics,0,METRICS.ptr)
        ext := {x:NumGet(METRICS,8,"Int"), y:NumGet(METRICS,12,"Int")}
        int := {x:NumGet(METRICS,24,"Int"), y:NumGet(METRICS,28,"Int")}
        return (typ="external") ? ext : int
    }
    
    GetRows(fix:=true) {
        rows := this.SendMsg(ToolBar.messages.GetRows)
        (fix) ? rows := rows//2+1 : "" ; by default fix rows
        return rows                    ; For some reason, rows come out to be 1, 3, 5, 9, instead of 1, 2, 3, 4
    }
    
    HideButton(_in, status) {
        btn := this._GetBtn(_in)
        result := this.SendMsg(Toolbar.messages.HideButton,btn.idCmd,Toolbar.MakeLong(status,0))
        return result
    }
    
    HitTest() {
        POINT := Buffer(8,0)
        old_mode := A_CoordModeMouse
        CoordMode "Mouse", "Client"
        MouseGetPos &x, &y
        CoordMode "Mouse", old_mode
        NumPut("UInt", x, "UInt", y, POINT)
        return this.SendMsg(Toolbar.messages.HitTest, 0, POINT.ptr)+1
    }
    
    IL_Add(ILname, icons) { ; append icons to an existing imagelist
        If !this.ImageLists.Has(ILname)
            throw Error("Image list name doesn't exist: " ILname)
        handle := this.ImageLists[ILname]
        For i, o in icons {
            a := StrSplit(o,"/"), img := a[1], icon := (a.Has(2)) ? a[2] : ""
            If (icon!="")
                IL_Add(handle,img,icon)
            Else IL_Add(handle,img)
            this.ImageLists[ILname].files.Push(o) ; append icons to file list
        }
    }
    
    IL_Create(ILname, icons, large:=false) {
        handle := IL_Create(icons.Length, 5, large)
        For i, o in icons {
            a := StrSplit(o,"/")
            img := a[1]
            icon := (a.Has(2)) ? a[2] : ""
            If (icon!="")
                idx := IL_Add(handle,img,icon)
            Else idx := IL_Add(handle,img)
            If !idx
                return false ; adding an icon failed
        }
        this.ImageLists[ILname] := {handle:handle, files:icons, large:large}
        return true ; all icons added successfully
    }
    
    IL_Destroy(ILname) {
        handle := this.ImageLists[ILname].handle
        this.ImageLists.Delete(ILname)
        return IL_Destroy(handle)
    }
    
    Import(a) {
        r := []
        For i, btn in a {
            b := {}
            For prop, value in btn
                (prop = "icon") ? b.%prop% := value-1 : b.%prop% := value
            r.InsertAt(A_Index,b)
        }
        this.Add(r,false)
    }
    
    Insert(b,idx) {
        a := Toolbar.AddConvert(this, b, true), b := a[1]
        TBBUTTON := Buffer(Toolbar.TBBUTTON_size, 0)
        Toolbar.Fill_TBBUTTON(this,TBBUTTON, offset:=0, b.label, b.icon, b.idCmd, b.states, b.styles, b.iString)
        this.SendMsg(Toolbar.messages.InsertButton, idx-1, TBBUTTON.ptr)
    }
    
    IsChecked(_in) {
        btn := this._GetBtn(_in)
        return this.SendMsg(Toolbar.messages.IsButtonChecked, btn.idCmd)
    }
    
    IsEnabled(_in) {
        btn := this._GetBtn(_in)
        return this.SendMsg(Toolbar.messages.IsButtonEnabled, btn.idCmd)
    }
    
    IsHidden(_in) {
        btn := this._GetBtn(_in)
        return this.SendMsg(Toolbar.messages.IsButtonHidden, btn.idCmd)
    }
    
    IsPressed(_in) {
        btn := this._GetBtn(_in)
        return this.SendMsg(Toolbar.messages.IsButtonPressed,btn.idCmd)
    }
    
    MixedButtons(status) {
        btns := Toolbar.SaveNewLayout(this)
        
        curExStyles := this.SendMsg(Toolbar.messages.GetExtendedStyle)
        newExStyles := (!status) ? curExStyles ^ Toolbar.exStyles.MixedButtons : curExStyles | Toolbar.exStyles.MixedButtons
        
        this.SendMsg(Toolbar.messages.SetExtendedStyle, 0, newExStyles)
        
        this.ClearButtons()
        this.Add(btns,false)
        
        If (this.easyMode)
            this.Position(this.pos), this.Position(this.pos)
    }
    
    MoveButton(_in,pos) {
        btn := this._GetBtn(_in)
        result := this.SendMsg(Toolbar.messages.MoveButton, btn.index-1, pos-1)
        return result
    }
    
    OldCustomize() {
        this.SendMsg(Toolbar.messages.Customize, 0, 0)
    }
    
    Position(p:="", repeat:=false) {
        this.pos := p
        dims := Toolbar.GetButtonDims(this) ; bWidth, bHeight, hPad, vPad
        this.gui.GetClientPos(,,&w,&h)
        
        this.h := height := dims.bHeight+Toolbar.padding ; 8px padding between btn edge and toolbar / next button?
        this.w := width  := dims.bWidth+Toolbar.padding
        
        If (p="right") {
            this.Move(w-width,0,width,h)
            this.SendMsg(Toolbar.messages.SetStyle, 0, Toolbar.MakeFlags(this.startStyles " Vert","styles"))
        } Else If (p="bottom") {
            this.Move(0,h-height,w,height)
            this.SendMsg(Toolbar.messages.SetStyle, 0, Toolbar.MakeFlags(this.startStyles,"styles"))
        } Else If (p="left") {
            this.Move(0,0,width,h)
            r := this.SendMsg(Toolbar.messages.SetStyle, 0, Toolbar.MakeFlags(this.startStyles " Vert","styles"))
        } Else { ; top
            this.Move(0,0,w,height)
            this.SendMsg(Toolbar.messages.SetStyle, 0, Toolbar.MakeFlags(this.startStyles,"styles"))
        }
        
        btns := Toolbar.SaveNewLayout(this)
        For i, b in btns { ; modify button state / add or remove "Wrap" state for orientation
            statesTxt := Toolbar.GetFlags(b.states,"states")
            
            If (p="left" Or p="right") And !InStr(statesTxt,"Wrap")
                statesTxt .= " Wrap"
            Else If (p="top" Or p="bottom") And InStr(statesTxt,"Wrap")
                statesTxt := RegExReplace(StrReplace(statesTxt,"Wrap"),"[ ]{2,}"," ")
            
            b.states := Toolbar.MakeFlags(statesTxt,"states")
        }
        
        this.ClearButtons()
        this.Add(btns, false)
        this.AutoSize()
    }
    
    SendMsg(msg, wParam:=0, lParam:=0) { ; for generic message sending
        return SendMessage(msg, wParam, lParam, this.hwnd)
    }
    
    SetBitmapSize(w, h) {
        return this.SendMsg(Toolbar.messages.SetBitmapSize, 0, Toolbar.MakeLong(w, h))
    }
    
    SetButtonSize(W, H) {
        Long := Toolbar.MakeLong(W, H)
        result := this.SendMsg(Toolbar.messages.SetButtonSize, 0, Long)
        this.Move(,,,H+8)
        ; this.Position(this.pos), this.Position(this.pos)
        return result
    }
    
    SetImageList(Default, Hot := "", Pressed := "", Disabled := "") {
        this.IL_Default := Default
        this.IL_Hot := Hot
        this.IL_Pressed := Pressed
        this.IL_Disabled := Disabled
        
                     result := this.SendMsg(Toolbar.messages.SetImageList,         0, this.ImageLists[Default].handle)
        (Hot)      ? result := this.SendMsg(Toolbar.messages.SetHotImageList,      0, this.ImageLists[Hot].handle) : ""
        (Pressed)  ? result := this.SendMsg(Toolbar.messages.SetPressedImageList,  0, this.ImageLists[Pressed].handle) : ""
        (Disabled) ? result := this.SendMsg(Toolbar.messages.SetDisabledImageList, 0, this.ImageLists[Disabled].handle) : ""
        
        If (this.easyMode)
            this.Position(this.pos), this.Position(this.pos)
        
        return result
    }
    
    SetMetrics(x, y, typ:="external") {
        METRICS := Buffer(bSize:=32,0)
        flags := (typ="external") ? 4 : 1
        NumPut("UInt",bSize,"UInt",flags,METRICS)
        
        (typ="external") ? NumPut("Int", x, "Int", y, METRICS, 24) : NumPut("Int", x, "Int", y, METRICS, 8)
        this.SendMsg(Toolbar.messages.SetMetrics,0,METRICS.ptr)
        
        this.Position(this.pos), this.Position(this.pos)
    }
    
    ShowText(status) {
        this.ShowTextStatus := status
        this.SendMsg(Toolbar.messages.SetMaxTextRows, status)
        If (this.easyMode)
            this.Position(this.pos), this.Position(this.pos)
    }
    
    Static AddConvert(ctl,btnArray,initial) {   ; for internal use only
        For i, b in btnArray {                  ; prop list: label, icon, idCmd, styles, states, iString
            If !b.HasProp("label")
                throw Error("Button data must contain a label property.")
            
            (b.label="") ? sep := true : sep := false
            (!b.HasProp("icon")) ? b.icon := 0 : b.icon -= 1
            (!b.HasProp("idCmd")) ? b.idCmd := 1000+(ctl.counter++) : ""       ; initial only
            
            If (initial And !sep) {
                (initial And !b.HasProp("states")) ? b.states := "Enabled" : ""
                (initial And ctl.easyMode And !InStr(b.states,"Enabled")) ? b.states .= " Enabled" : ""
                
                (initial And Type(b.states)="String") ? b.states := this.MakeFlags(b.states,"states") : ""  ; initial only
                
                (initial And !b.HasProp("styles")) ? b.styles := "" : ""
                (initial And !b.HasProp("styles")) ? b.styles := "AutoSize" : ""
                (initial And ctl.easyMode And !InStr(b.styles,"AutoSize")) ? b.styles .= " AutoSize" : ""
                (initial And ctl.easyMode And ctl.MixedBtns And b.icon = -2 And !InStr(b.styles,"ShowText")) ? b.styles .= " ShowText" : ""
                
                (initial And Type(b.styles)="String") ? b.styles := this.MakeFlags(b.styles,"bStyles") : "" ; initial only
            } Else If (initial and sep)
                b.styles := 1, b.states := 0
            
            (!b.HasProp("iString")) ? b.iString := -1 : ""
            (b.icon < 0) ? b.label := this.StrRpt(" ",ctl.txtSpacing) b.label : ""
            btnArray[i] := b
        }
        
        return btnArray
    }
    
    Static CustoEvents(_ctl,ctl,p*) { ; _ctl is the toolbar control
        LV := ctl.gui["CustoList"], r := LV.GetNext()
        If (!r And (InStr(ctl.Name,"move") Or InStr(ctl.Name,"sep")))
            return
        
        If (ctl.Name = "MoveUp" Or ctl.Name = "MoveDown") {
            If (r=1 And ctl.Name="MoveUp") Or (r=LV.GetCount() And ctl.Name="MoveDown")
                return
            newRow := (ctl.Name = "MoveUp") ? r-1 : r+1
            
            b := this.GetButton(_ctl, r), LV.Delete(r)
            c := !(b.states & Toolbar.states.Hidden) ? " Check" : ""
            LV.Insert(newRow,"Select Icon" (b.icon) c, (b.label) ? b.label : "Seperator")
            LV.Modify(newRow,"Vis")
            
            _ctl.SendMsg(this.messages.MoveButton, r-1, newRow-1)
            
        } Else If (ctl.Name = "Cancel") {
            _ctl.ClearButtons()
            _ctl.Add(ctl.gui.btnsReset,false)
            ctl.gui.Destroy()
        } Else If (ctl.Name = "OK") {
            _ctl.IL_Destroy("Customizer")
            ctl.gui.Destroy()
        } Else If (ctl.Name = "AddSep") {
            _ctl.Insert([{label:""}],r)
            LV.Modify(r,"Select")
            Loop LV.GetCount()
                LV.Modify(A_Index,"-Select")
            LV.Insert(r,"Select Icon0","Seperator")
        } Else If (ctl.Name = "RemSep") {
            If LV.GetText(r) != "Seperator"
                return
            _ctl.SendMsg(this.messages.DeleteButton, r-1)
            btns := this.SaveNewLayout(_ctl)
            LV.Delete(r)
        } Else If (ctl.Name = "CustoList") {
            item := p[1], checked := p.Has(2) ? p[2] : "" 
            _ctl.HideButton(item,!checked)
        }
    }
    
    Static Fill_TBBUTTON(ctl, TBBUTTON, offset, label, iBitmap, idCommand, fsState, fsStyle, iString:=-1) {
        Static encoding := !StrLen(Chr(0xFFFF)) ? "UTF-8" : "UTF-16"
        
        If (iString = -1) { ; create string and add to pool
            BTNSTR := Buffer(StrPut(label,encoding), 0)
            StrPut(label, BTNSTR.ptr, encoding)
            iString := ctl.SendMsg(this.messages.AddString, 0, BTNSTR.ptr)
        }
        
        NumPut "Int", iBitmap, "Int", idCommand, "Char", fsState, "Char", fsStyle, TBBUTTON, offset
        If iString >= 0
            NumPut "Ptr", iString, TBBUTTON, ((A_PtrSize = 4) ? 16+offset : 24+offset)
        
        return iString
    }
    
    Static GetButton(ctl, idx) { ; btn props: index, label, icon, states, styles, checked, idCmd, iString
        TBBUTTON := Buffer(Toolbar.TBBUTTON_size,0)
        r := ctl.SendMsg(this.messages.GetButton,idx-1,TBBUTTON.ptr)
        iImg := NumGet(TBBUTTON,"Int")
        idCmd := NumGet(TBBUTTON,4,"UInt")
        states := NumGet(TBBUTTON,8,"Char")
        styles := NumGet(TBBUTTON,9,"Char")
        iString := NumGet(TBBUTTON,((A_PtrSize=4)?16:24),"Ptr")
        txt := this.GetButtonText(ctl, idx)
        return {index:idx, label:txt, icon:iImg+1, states:states, styles:styles
              , checked:!!(states & Toolbar.states.Checked), idCmd:idCmd, iString:iString}
    }
    
    ; GetButtonInfo(idx, byIndex:=false) { ; need to turn this into SetButtonText()
        ; TBI := Buffer(bSize:=(A_PtrSize=4)?32:48,0)
        ; dwMask := this.Command|this.Image|this.Size|this.State|this.Style
        ; (byIndex) ? (dwMask := dwMask | this.ByIndex) : ""
        
        ; NumPut "UInt", bSize, "Int", dwMask, TBI
        ; r := this.SendMsg(this._GetButtonInfo, idx, TBI.Ptr)
        ; idCmd := NumGet(TBI, 8, "Int"), iImg  := NumGet(TBI, 12, "Int")
        ; states := NumGet(TBI, 16, "UChar"), styles := NumGet(TBI, 17, "UChar"), width  := NumGet(TBI, 18, "UShort")
        
        ; tSize := this.SendMsg(this._GetButtonText, idCmd, 0)
        ; tBuf := Buffer((tSize+1) * (StrLen(Chr(0xFFFF))?2:1),0)
        ; this.SendMsg(this._GetButtonText, idCmd, tBuf.Ptr), txt := StrGet(tBuf)
        
        ; TBBUTTON := Buffer(Toolbar.TBBUTTON_size,0)
        ; r := this.SendMsg(this._GetButton,idx,TBBUTTON.ptr)
        ; iString := NumGet(TBBUTTON,((A_PtrSize=4)?16:24),"Ptr")
        
        ; return {label:txt, icon:iImg, states:states, styles:styles, idCmd:idCmd, iString:iString} ; iString (str idx)
    ; }
    
    Static GetButtonDims(ctl) {
        btns := this.SaveNewLayout(ctl)
        
        _RECT := Buffer(16,0), bWidth := 0, bHeight := 0
        For i, b in btns {
            TBI := Buffer(bSize:=(A_PtrSize=4)?32:48,0)
            dwMask := this.flags.Style
            NumPut "UInt", bSize, "Int", dwMask, TBI
            ctl.SendMsg(this.messages.GetButtonInfo, b.idCmd, TBI.ptr)
            styles := NumGet(TBI,17,"Char")
            If (styles & Toolbar.bStyles.Sep) ; check and skip if separator
                continue
            
            r := ctl.SendMsg(this.messages.GetRect, b.idCmd, _RECT.ptr)
            l := NumGet(_RECT,0,"UInt"), t := NumGet(_RECT,4,"UInt"), r := NumGet(_RECT,8,"UInt"), b := NumGet(_RECT,12,"UInt")
            w := r-l, h := b-t
            bWidth := (bWidth < w) ? w : bWidth
            bHeight := (bHeight < h) ? h : bHeight
        }
        padding := ctl.SendMsg(this.messages.GetPadding, 0, 0), this.MakeShort(padding, &hPad, &vPad)
        dims := {bWidth:bWidth, bHeight:bHeight, hPad:hPad, vPad:vPad}, TBI := "", _RECT := ""
        return dims
    }
    
    Static GetButtonText(ctl, idx) {
        TBBUTTON := Buffer(Toolbar.TBBUTTON_size,0)
        r := ctl.SendMsg(this.messages.GetButton,idx-1,TBBUTTON.ptr)
        idCmd := NumGet(TBBUTTON,4,"UInt")
        
        tSize := ctl.SendMsg(this.messages.GetButtonText, idCmd, 0) << 32 >> 32 ; needed for 32-bit compatibility
        
        If (tSize = -1)
            return ""
        
        TBBUTTON := "", tBuf := Buffer((tSize+1) * (StrLen(Chr(0xFFFF)) ? 2 : 1),0)
        ctl.SendMsg(this.messages.GetButtonText, idCmd, tBuf.Ptr), txt := StrGet(tBuf)
        return txt
    }
    
    Static GetFlags(iInput,member) { ; return text names of properties from given input integer, must specify static member above to search
        output := ""
        For prop, value in Toolbar.%member%.OwnProps()
            (iInput & value) ? output .= prop " " : ""
        return Trim(output)
    }
    
    Static MakeFlags(sInput,member) { ; return toolbar styles integer from space delimited text input
        output := 0
        Loop Parse Trim(sInput), " "
        {
            If IsInteger(A_LoopField)
                throw Error("No numeric property: " member " / Value: " A_LoopField)
            If !A_LoopField
                Continue
            
            output := output | Toolbar.%member%.%A_LoopField%
        }
        return output
    }
    
    Static MakeLong(LoWord, HiWord) {
        return (HiWord << 16) | (LoWord & 0xffff)
    }
    
    Static MakeShort(Long, &LoWord, &HiWord) {
        LoWord := Long & 0xffff,   HiWord := Long >> 16
    }
    
    Static ResetStructs(ctl) {
        ctl.NMHDR := {hwnd:"", idFrom:"", code:""}
        ctl.NMMOUSE := {dwItemSpec:"", dwItemData:"", pointX:"", pointY:"", lParam:""}
        ctl.NMKEY := {nVKEY:"", uFlags:""}
    }
    
    Static SaveNewLayout(ctl) { ; works, but not keeping track of removed buttons yet
        btns := []
        Loop ctl.SendMsg(this.messages.ButtonCount) {
            b := this.GetButton(ctl, A_Index) ; btn props: index, label, icon, states, styles, checked, idCmd, iString
            btns.InsertAt(A_Index,b)
        }
        return btns
    }
    
    Static StrRpt(str,count) {
        result := ""
        Loop count
            result .= str
        return result
    }
    
    Static __tbNotify(ctl, lParam) {
        ; TB_HITTEST / TB_GETRECT/TB_GETITEMRECT ; https://docs.microsoft.com/en-us/windows/win32/controls/bumper-toolbar-control-reference-notifications
        Static p := A_PtrSize, encoding := !StrLen(Chr(0xFFFF)) ? "UTF-8" : "UTF-16"
        this.ResetStructs(ctl)
        
        ctl.NMHDR.hwnd   := NumGet(lParam,"Ptr")
        ctl.NMHDR.idFrom := NumGet(lParam+A_PtrSize,"UInt")
        ctl.NMHDR.code   := NumGet(lParam+(A_PtrSize * 2),"Int") ; Technically a UINT / WM_NOTIFY msg code
        
        event := this.rlu(ctl.NMHDR.code,"wm_n") ; lookup event name
        
        If (ctl.NMHDR.code = 0 or ctl.NMHDR.code = "" Or event = "")
            return
        
        o := {event:event, eventInt:ctl.NMHDR.code
            , index:0, idCmd:0, label:"", checked:0, dims:{x:0, y:0, w:0, h:0} ; data for clicked/hovered button | old: rect:{t:"", b:"", r:"", l:""}
            , hoverFlags:"", hoverFlagsInt:0                        ; more specific hover data
            , vKey:-1, char:-1                                      ; when hovering + keystroke, these are populated
            , oldIndex:0, oldIdCmd:0, oldLabel:""}                  ; for initially dragged button, or previous hot item
        
        Switch event {
            ; WM_NOTIFY msgs ; https://docs.microsoft.com/en-us/windows/win32/controls/bumper-toolbar-control-reference-notifications
            Case "LClick", "LDClick", "LDown", "RClick", "RDClick":
                ctl.NMMOUSE.dwItemSpec := NumGet(lParam+Toolbar.NMHDR_size,"Ptr")
                ctl.NMMOUSE.dwItemData := NumGet(lParam+Toolbar.NMHDR_size+A_PtrSize,"UPtr")
                ctl.NMMOUSE.pointX := NumGet(lParam+Toolbar.NMHDR_size+(A_PtrSize * 2),"UInt")
                ctl.NMMOUSE.pointY := NumGet(lParam+Toolbar.NMHDR_size+(A_PtrSize * 2)+4,"UInt")
                ctl.NMMOUSE.dwHitInfo := NumGet(lParam+Toolbar.NMHDR_size+(A_PtrSize * 2)+8,"UInt")
                
                b := this.GetButton(ctl, ctl.CmdToIdx(ctl.NMMOUSE.dwItemSpec))
                o.idCmd := b.idCmd, o.index := b.index, o.label := b.label
                
            Case "Char":
                ; https://docs.microsoft.com/en-us/windows/win32/controls/nm-char-toolbar
                char := NumGet(lParam+Toolbar.NMHDR_size,"UInt")
                dwItemPrev := NumGet(lParam+Toolbar.NMHDR_size+4,"Int") ; dwItemNext seems to alwys be -1
                b := this.GetButton(ctl, ctl.CmdToIdx(dwItemPrev))
                o.char := char, o.idCmd := dwItemPrev, o.index := b.index, o.label := b.label
            
            Case "BeginDrag", "DragOut", "DeletingButton", "DropDown":
                ; NMTOOLBAR struct ; https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-nmtoolbara
                idCmd := NumGet(lParam+Toolbar.NMHDR_size,"Int")
                b := this.GetButton(ctl, ctl.CmdToIdx(idCmd))
                o.index := b.index, o.idCmd := b.idCmd, o.label := b.label
            
            Case "EndDrag":
                ; https://docs.microsoft.com/en-us/windows/win32/controls/tbn-enddrag ; NMTOOLBAR struct, but treat this one differently
                b := {index:0, label:"", icon:0, idCmd:0, styles:0, states:0, iString:-2} ; setup blank button, just in case
                oldIdCmd := NumGet(lParam,Toolbar.NMHDR_size,"Int")                       ; treat iItem as "old ID" becuase it is
                (this.hotItem) ? b := this.GetButton(ctl, this.hotItem) : ""              ; record latest hot item as current index and idCmd
                bOld := this.GetButton(ctl, ctl.CmdToIdx(oldIdCmd))
                o.index := b.index, o.idCmd := b.idCmd, o.label := b.label
                o.oldIdCmd := oldIdCmd, o.oldIndex := bOld.index, o.oldLabel := bOld.label
            
            Case "HotItemChange", "DragOver":
                ; NMTBHOTITEM struct ; https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-nmtbhotitem
                idOld := NumGet(offset := lParam+Toolbar.NMHDR_size,"Int")
                idNew := NumGet(offset+4,"Int")
                b := this.GetButton(ctl, ctl.CmdToIdx(idNew))
                bOld := this.GetButton(ctl, ctl.CmdToIdx(idOld))
                dwFlags := NumGet(lParam+Toolbar.NMHDR_size+8,"UInt")
                txtFlags := this.GetFlags(dwFlags,"hotItemFlags")
                this.hotItem := b.index, this.hotItemID := b.idCmd
                
                o.index := b.index, o.idCmd := b.idCmd, o.label := b.label
                o.hoverFlags := txtFlags, o.hoverFlagsInt := dwFlags
                o.oldIndex := bOld.index, o.oldIdCmd := bOld.idCmd, o.oldLabel := bOld.label
            
            Case "KeyDown":
                ; https://docs.microsoft.com/en-us/windows/win32/controls/nm-keydown-toolbar
                ctl.NMKEY.nVKEY  := NumGet(lParam+Toolbar.NMHDR_size,"UInt")
                ctl.NMKEY.uFlags := NumGet(lParam+Toolbar.NMHDR_size+4,"UInt")
                o.vKey := ctl.NMKEY.nVKEY
            
            ; ===================================================================================
            ; === Customizer Events - these may go away, my custom customizer is better...... ===
            ; ===================================================================================
            
            Case "EndAdjust": ; * customizer ; https://docs.microsoft.com/en-us/windows/win32/controls/tbn-endadjust
                ; this.btns := this.SaveNewLayout()
            
            Case "GetButtonInfo": ; * customizer ; https://docs.microsoft.com/en-us/windows/win32/controls/tbn-getbuttoninfo
                iItem := NumGet(lParam+Toolbar.NMHDR_size,"Int")
                If (iItem = ctl.Count())
                    return false
                
                b := this.GetButton(ctl, iItem+1)
                this.Fill_TBBUTTON(ctl, lParam, Toolbar.NMHDR_size+A_PtrSize, b.label, b.icon, b.idCmd, b.states, b.styles, b.iString)
                return true
                
            Case "InitCustomize": ; * customizer ; https://docs.microsoft.com/en-us/windows/win32/controls/tbn-initcustomize
                return 1
            
            Case "QueryInsert": ; * customizer ; https://docs.microsoft.com/en-us/windows/win32/controls/tbn-queryinsert
                return true
            
            Case "QueryDelete": ; * customizer ; https://docs.microsoft.com/en-us/windows/win32/controls/tbn-querydelete
                return true
            
            Case "Reset": ; * customizer ; https://docs.microsoft.com/en-us/windows/win32/controls/tbn-reset
                ; this.Position(this.pos)
                return true
            
            Case "ToolbarChange": ; * customizer ; https://docs.microsoft.com/en-us/windows/win32/controls/tbn-toolbarchange
                return true
            
            Default:
                this.ResetStructs(ctl)
        }
        
        If (o.idCmd) {
            Static RECT := Buffer(16,0)
            r := ctl.SendMsg(this.messages.GetRect, b.idCmd, RECT.ptr)
            L := NumGet(RECT,"Int"), T := NumGet(RECT,4,"Int"), R := NumGet(RECT,8,"Int"), B := NumGet(RECT,12,"Int")
            o.dims := {x:L, y:T, b:B, w:(R-L), h:(B-T)}
        }
        
        (cb := ctl.callback) ? cb(ctl, lParam, o) : ""
    }
}

