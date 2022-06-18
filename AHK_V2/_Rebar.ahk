; AHK v2
; ===========================================================================
; Example
; ===========================================================================

; #INCLUDE TheArkive_GuiCtlExt.ahk
#INCLUDE _JXON.ahk
(Rebar) ; or include at top of script

g := Gui("+Resize")
g.OnEvent("close",gui_close)
g.OnEvent("Size",gui_size)

ctl := g.AddRebar("vMyRebar")

; g.Show("w1000 h500")

g4 := Gui("","GUI#3")
g4.Add("Text","","Vertical!")
; ctl.InsertBand(gui, options, styles)
; options -> w, h, mW = min Width, mH = min Height
ctl.InsertBand(g4,"w150 h150")

g5 := Gui("","GUI#4")
g5.Add("Text","","Vertical2!")
ctl.InsertBand(g5,"w150 h150")

; ===================================================
; ===================================================
g5 := Gui("","GUI#4 cray cray") ; main GUI for 2nd band in above rebar
ctl2 := g5.AddRebar("vMyRebar BandBorders")
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; adding sub-rebar below into GUI#4
; - - - - - - - - - - - - - - - - - - - - - - - - - -
g2 := Gui("","GUI#1")
g2.Add("Text","y4","Testing Text")
c := g2.Add("DropDownList","vDrop1 y0 x+0 w100 ",["Item1","Item2"])
c.OnEvent("Change",gui_rebar_ctl)
ctl2.InsertBand(g2,"w200 h50 mW190")

g3 := Gui("","GUI#2")
g3.Add("Text","y4","Testing Text")
g3.Add("DropDownList","vDrop2 y0 x+0 w100 ",["Item1","Item2"])
ctl2.InsertBand(g3,"w200 h50 mW190")
; ===================================================
; ===================================================

ctl.InsertBand(g5,"w150 h50")
ctl.InsertBand(g4,"w150 h50","")

g.Show("w1000 h500")



gui_size(_gui, MinMax, w, h) { ; should use "pseudo styles" like "full", "toolbar", "none", and "user"
    ; For hwnd, _ctl in _gui {
        ; If (_ctl.Type = "Rebar") {
            ; _ctl.Resize()
            ; i := _gui["MyRebar"].Count
            ; Loop i {
                
            ; }
        ; }
    ; }
    
    ; ctl := _gui["MyRebar"]
    ; dbg("resize: " _gui["MyRebar"].Resize() " / " _gui.title)
}

gui_rebar_ctl(ctl, info) {
    dbg(ctl.Name " = " ctl.value " / " ctl.text)
}

gui_close(*) {
    ExitApp
}

dbg(_in) {
    OutputDebug "AHK: " _in
}


F2::{
    Global
    s := Rebar.BandStyle
    
    ; ctl.SetBandWidth(1, 200)
    
    ; g.GetPos(,,&w,&h)
    ; g.Move(,,w+1)
}
F3::{
    Global
    s := Rebar.BandStyle
    
    ctl.SetBandWidth(1, 300)
}
F12::ExitApp


; ===========================================================================
; Rebar Class
; https://docs.microsoft.com/en-us/windows/win32/controls/rebar-control-reference
; ===========================================================================
; Thanks to Pulover again for his well written AHK v1 version.
; https://github.com/Pulover/Class_Rebar
; ===========================================================================

class Rebar extends Gui.Custom {
    Static p := A_PtrSize, u := StrLen(Chr(0xFFFF))
    Static _GetRect := "", _SetRect := ""
    
    ; https://docs.microsoft.com/en-us/windows/win32/controls/bumper-rebar-control-reference-notifications
    Static wm_notify := {AutoBreak:-853, AutoSize:-834, BeginDrag:-835, ChevronPushed:-841, ChildSize:-839, DeleteBand:-838
                       , DeletingBand:-837, EndDrag:-836, GetObject:-832, HeightChange:-831, Last:-859
                       , LayoutChanged:-833, MinMax:-852, SplitterDrag:-842}
                       ; NM_CUSTOMDRAW := -12 /  NM_NCHITTEST := -14 / NM_RELEASEDCAPTURE := -16
                       
    ; https://docs.microsoft.com/en-us/windows/win32/controls/bumper-rebar-control-reference-messages
    Static msgs := {BeginDrag:0x418, DeleteBand:0x402, DragMove:0x41A, EndDrag:0x419, GetBandBorders:0x422, GetBandCount:0x40C
                  , GetBandInfo:(this.u?0x41C:0x41D), GetBandMargins:0x428, GetBarHeight:0x41B, GetBarInfo:0x403
                  , GetBkColor:0x414, GetColorScheme:0x2003, GetDropTarget:0x2004, GetExtendedStyle:0x42A
                  , GetPalette:0x426, GetRect:0x409, GetRowCount:0x40D, GetRowHeight:0x40E, GetTextColor:0x416
                  , GetToolTips:0x411, GetUnicodeFormat:0x2006, HitTest:0x408, IDtoIndex:0x410, InsertBand:(this.u?0x40A:0x401)
                  , MaximizeBand:0x41F, MinimizeBand:0x41E, MoveBand:0x427, PushChevron:0x42B, SetBandInfo:(this.u?0x40B:0x406)
                  , SetBandWidth:0x42C, SetBarInfo:0x404, SetBkColor:0x413, SetColorScheme:0x2002, SetExtendedStyle:0x429
                  , SetPalette:0x425, SetParten:0x407, SetTextColor:0x415, SetTooltips:0x412, SetUnicodeFormat:0x2005
                  , SetWindowTheme:0x200B, ShowBand:0x423, SizeToRect:0x417}
    
    ; https://docs.microsoft.com/en-us/windows/win32/controls/rebar-control-styles
    Static styles := {AutoSize:0x2000, BandBorders:0x400, DblClkToggle:0x8000, FixedOrder:0x800, RegisterDrop:0x1000
                    , Tooltips:0x100, VarHeight:0x200, VerticalGripper:0x4000, Vertical:0x80} 
    
    ; https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-rebarbandinfoa
    ; REBARBANDINFO masks corresponding to struct members
    Static BandMask := {Background:0x80 ; hmbBack
              , ChevronLocation:0x1000  ; rcChevronLocation
              , ChevronState:0x2000     ; uChevronState
              , Child:0x10              ; hwndChild
              , ChildSize:0x20          ; cxMinChild, cyMinChild, cyChild, cyMaxChild, cyIntegral
              , Colors:0x2              ; clrFore, clrBack
              , HeaderSize:0x800        ; cxHeader
              , ID:0x100                ; wID
              , IdealSize:0x200         ; cxIdeal
              , Image:0x8               ; iImage
              , LPARAM:0x400            ; lParam
              , Size:0x40               ; cx
              , Style:0x1               ; fStyle
              , Text:0x4}               ; lpText, cch
    
    ; https://docs.microsoft.com/en-us/windows/win32/controls/rebar-control-styles
    ; Rebar band styles (RB_InsertBand / 0x40A|0x401)
    Static BandStyle := {Break:0x1      ; Band is on a new line.
              , ChildEdge:0x4           ; Adds edge on top/bottom of child window.
              , FixedBmp:0x20           ; Background bmp doesn't move on resize.
              , FixedSize:0x2           ; Band can't be sized/no sizing grip.
              , GripperAlways:0x80      ; Always displays sizing grip (even with one band).
              , Hidden:0x8              ; Hides the band.
              , HideTitle:0x400         ; Hides title.
              , NoGripper:0x100         ; Band will never have a sizing gripper.
              , NoVert:0x10             ; Band not visible when vertical.
              , TopAlign:0x800          ; Keep band in top row.
              , UseChevron:0x200        ; Show chevron if band is smaller then cxIdeal.
              , VariableHeight:0x40}    ; Auto resized (via cyIntegral and cyMaxChild).
    
    ; https://docs.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-rbhittestinfo
    Static HitTestFlags := {Caption:0x2, Chevron:0x8, Client:0x3, Grabber:0x4, Nowhere:0x1, Splitter:0x10}
    
    Static __New() {                                                ; Need to do it this way.
        Gui.prototype.AddRebar := ObjBindMethod(this,"AddRebar")    ; Multiple gui subclass extensions don't play well together.
    }
    Static AddRebar(_gui:="", sOptions:="") {
        default_styles := Rebar.TransFlags("styles","DblClkToggle") " -Theme +E0x2000000 0x2000000"
        
        vert := x := y := w := h := 0
        maxRows := 1, RebarStyles := ""
        a := StrSplit(sOptions," ")
        Loop a.Length {
            If !(val := a[i := A_Index])
                Continue
            
            If (RegExMatch(val,"i)^v[a-z_](\w+)?") ; vCtlName
              And (val != "Vertical")
              And (val != "VerticalGripper"))
                default_styles := val " " default_styles
            Else If Rebar.styles.HasProp(val) {             ; capture/separate vertical and other actual styles
                (val="Vertical") ? vert := true : ""
                RebarStyles .= ((RebarStyles)?" ":"") val
            } Else If RegExMatch(val, "i)^x(\d+)$", &_m)
                x := _m[1]
            Else If RegExMatch(val, "i)^y(\d+)$", &_m)
                y := _m[1]
            Else If RegExMatch(val, "i)^w(\-?\d+)$", &_m)
                w := _m[1]
            Else If RegExMatch(val, "i)^h(\-?\d+)$", &_m)
                h := _m[1]
            Else If RegExMatch(val, "i)^r(\d+)$", &_m) And (val != "RegisterDrop")
                maxRows := _m[1]
        }
        _styles := Rebar.TransFlags("styles",RebarStyles)   ; convert Rebar styles to string 0xHEX
        
        ctl := _gui.Add("Custom","ClassReBarWindow32 " default_styles (_styles?" " _styles:"")) ; add RebarStyles
        ctl.__counter := 0 ; for adding Band IDs, NOT for counting rebar controls
        
        ctl.maxRows := maxRows
        ctl.__vertical := vert
        ctl.x := x, ctl.y := y, ctl.w := w, ctl.h := h
        
        For prop, val in this.wm_notify.OwnProps() ; Register events
            ctl.OnNotify(val,ObjBindMethod(this,"Rebar_OnNotify"))
        
        ctl.gui.OnEvent("size",ObjBindMethod(this,"Rebar_AutoSize"))
        
        ctl.base := Rebar.Prototype ; attach methods -> causes "this" (in below methods) to refer to ctl, not Rebar class
        ctl.bands := []
        
        return ctl
    }
    Static Rebar_OnNotify(ctl, lParam) {
        Static wm_n := Rebar.wm_notify, s := Rebar.BandStyle
        
        msg := NumGet(lParam,A_PtrSize*2,"UPtr") << 32 >> 32
        msg_str := Rebar.Lookup("wm_notify",msg)
        
        ; dbg("Event: " msg_str " / " msg)
        
        If (msg = wm_n.ChildSize) {
            NMRB_ChildSize := Rebar.NMREBARCHILDSIZE(lParam)
            id := NMRB_ChildSize.wID
            rcChild := NMRB_ChildSize.rcChild
            rcBand := NMRB_ChildSize.rcBand
            ; dbg("rcChild: " jxon_dump(rcChild))
            ; dbg("rcBand: " jxon_dump(rcBand) " / " ctl.gui.title)
            
            ; dbg("resize? " ctl._sms(Rebar.msgs.SetBandWidth, 0, 140))
            
        } Else If (msg = wm_n.AutoSize) {
            ; rcTarget / rcActual
            _aSize := Rebar.NMRBAUTOSIZE(lParam)
            rcTarget := _aSize.rcTarget
            rcActual := _aSize.rcActual
            ; dbg("rcTarget: " jxon_dump(rcTarget))
            ; dbg("rcActual: " jxon_dump(rcActual) " / " ctl.gui.title)
            
            ; dbg("resize? " ctl._sms(Rebar.msgs.SetBandWidth, 0, 140))
        } Else If (msg = wm_n.LayoutChanged) {
            If ((rows := ctl.Rows) > ctl.maxRows) {
                Loop rows
                    If (A_Index > 1) And ((_s := ctl.Style[A_Index]) & s.Break)
                        ctl.Style[A_Index] := _s ^ s.Break
            }
        }
        
        ; dbg("==================================")
    }
    Static Rebar_AutoSize(_gui, MinMax, w, h) {
        For hwnd, ctl in _gui {
            If (ctl.Type = "Rebar") {
                ctl.Resize()
            }
        }
    }
    Static LookUp(member, value) {
        For prop, val in Rebar.%member%.OwnProps()
            If (val = value)
                return prop
        return ""
    }
    Static MakeFlags(member, values) {
        a := StrSplit(values," "), b := []
        For i, val in a
            (val) ? b.push(val) : ""
        
        flags := 0
        For i, val in b {
            If !Rebar.%member%.HasProp(val)
                throw Error("Invalid property specified for: " member,,"Unknown property: " val)
            
            flags := flags | Rebar.%member%.%val%
        }
        return flags
    }
    Static TransFlags(member, values) { ; translate text flags into hex for control creation
        a := StrSplit(values," "), b := []
        For i, val in a
            (val) ? b.push(val) : ""
        
        str := ""
        For i, val in b {
            If !Rebar.%member%.HasProp(val)
                throw Error("Invalid property specified for: " member,,"Unknown property: " val)
            
            str .= ((i=1)?"":" ") Format("0x{:X}",Rebar.%member%.%val%)
        }
        
        return str
    }
    
    BarHeight {
        get => this._sms(Rebar.msgs.GetBarHeight)
    }
    BarInfo {
        get {
            REBARINFO := Rebar.REBARINFO()
            this._sms(Rebar.msgs.GetBarInfo,0,REBARINFO.ptr)
            return REBARINFO
        }
    }
    BkColor {
        get => Format("0x{:06X}",this._RGB_BGR(this._sms(Rebar.msgs.GetBkColor)))
        set => this._sms(Rebar.msgs.SetBkColor, 0, this._RGB_BGR(value))
    }
    ; ChildEdge[n] {                      ; DOESN'T WORK (as far as i can tell)
        ; get => !!(this.Style[n] & 0x4)  ; check ChildEdge flag
        ; set {
            ; s := this.style[n]
            ; If (value) And !(s & 0x4)
                ; this.Style[n] := s | 0x4
            ; Else If (!value) And (s & 0x4)
                ; this.Style[n] := s ^ 0x4
        ; }
    ; }
    Count {
        get => this._sms(Rebar.msgs.GetBandCount)
    }
    Delete(n) {
        return this._sms(Rebar.msgs.DeleteBand, n-1)
    }
    GetBandInfo(n) {
        Static u := Rebar.u
        mask := 0
        For prop, val in Rebar.BandMask.OwnProps()
            mask := mask | val
        
        REBARBANDINFO := Rebar.REBARBANDINFO()
        REBARBANDINFO.fMask := Rebar.BandMask.Text
        
        this._sms(Rebar.msgs.GetBandInfo, n-1, REBARBANDINFO.ptr)
        cch := REBARBANDINFO.cch
        
        REBARBANDINFO := Rebar.REBARBANDINFO()
        REBARBANDINFO.fMask := mask
        REBARBANDINFO.cch := cch
        
        TEXT := Buffer((u)?(cch+1)*2:(cch+1),0)
        REBARBANDINFO.lpText := TEXT.ptr
        
        this._sms(Rebar.msgs.GetBandInfo, n-1, REBARBANDINFO.ptr)
        return REBARBANDINFO
    }
    GetBandBorders(n) {
        RECT := Buffer(16,0), a := []
        this._sms(Rebar.msgs.GetBandBorders, n-1, RECT.ptr)
        return this._GetRect(RECT)
    }
    Hidden[n] {
        get => !!(this.Style[n] & 0x8) ; check hidden flag
        set {
            s := this.style[n]
            If (value) And !(s & 0x8)
                this.Style[n] := s | 0x8
            Else If (!value) And (s & 0x8)
                this.Style[n] := s ^ 0x8
        }
    }
    HideTitle[n] {
        get => !!(this.Style[n] & 0x400) ; check title hidden flag
        set {
            s := this.style[n]
            If (value) And !(s & 0x400)
                this.Style[n] := s | 0x400
            Else If (!value) And (s & 0x400)
                this.Style[n] := s ^ 0x400
        }
    }
    HitTest {
        get {
            Static flags := {Caption:0x2, Chevron:0x8, Client:0x3, Grabber:0x4, Nowhere:0x1, Splitter:0x10}
            
            HITTESTINFO := Rebar.HITTESTINFO()
            CoordMode "Mouse", "Client"
            MouseGetPos &x, &y
            HITTESTINFO.Point := [x, y]
            
            this._sms(Rebar.msgs.HitTest, 0, HITTESTINFO.ptr)
            iBand := (HITTESTINFO.iBand << 32 >> 32)+1, flag := ""
            For prop, val in flags.OwnProps()
                If (val = HITTESTINFO.flags)
                    flag := prop
            
            return {x:x, y:y, flag:flag, band:iBand}
        }
    }
    id(n) {
        REBARBANDINFO := Rebar.REBARBANDINFO()
        REBARBANDINFO.fMask := Rebar.BandMask.ID
        this._sms(Rebar.msgs.GetBandInfo, n-1, REBARBANDINFO.ptr)
        return REBARBANDINFO.wID
    }
    
    
    ; InsertBand(_gui, iW:=0, iH:=0, pos:=-1, mW:="", mH:="", maxH:=0, styles:="") { ; 8 params!
    InsertBand(_gui, sOptions:="", styles:="") {
        Static m := Rebar.BandMask, s := Rebar.BandStyle, u := Rebar.u
        this.__counter++ ; for wID
        
        this.__w := 0, this.__h := 0, this.__minW := 0, this.__minH := 0
        pos := -1
        _styles := Rebar.MakeFlags("BandStyle", styles)
        
        a := StrSplit(sOptions," ")
        Loop a.Length {
            If !(val := a[A_Index])
                Continue
            If RegExMatch(val,"i)^w(\d+)$",&_m)
                this.__w := _m[1]
            Else If RegExMatch(val,"i)^h(\d+)$",&_m)
                this.__h := _m[1]
            Else If RegExMatch(val,"i)^pos(\d+)$",&_m)
                pos := _m[1]
            Else If RegExMatch(val,"i)^mW(\d+)$",&_m)
                this.__minW := _m[1]
            Else If RegExMatch(val,"i)^mH(\d+)$",&_m)
                this.__minH := _m[1]
        }
        
        ; If this.__vertical
            ; _temp := this.__w, this.__w := this.__h, this.__h := _temp
        
        Style := DllCall("User32\GetWindowLongPtr", "UPtr", _gui.hwnd, "Int", -16)
        If (Style & 0xC00000) && !(r := DllCall("User32\SetWindowLongPtr" ; removing Caption
                                   , "UPtr", _gui.hwnd, "Int", -16, "UInt", Style ^ 0xC00000))
            throw Error("Extended style not removed (WS_CAPTION = 0xC00000).")
        
        this.bands.Push(_gui), id := this.bands.Length
        
        ; ==========================================================================
        ; Use these style titles for "styles" param
        ; ==== masks ====                                         ; ==== styles ====
        ; Style           :0x1    fStyle                          ; Break          :0x1   ; Band is on a new line.
        ; Colors          :0x2    clrFore, clrBack                ; ChildEdge      :0x4   ; Adds edge on top/bottom of child window.
        ; Text            :0x4    lpText, cch                     ; FixedBmp       :0x20  ; Background bmp doesn't move on resize.
        ; Image           :0x8    iImage                          ; FixedSize      :0x2   ; Band can't be sized/no sizing grip.
        ; Child           :0x10   hwndChild                       ; GripperAlways  :0x80  ; Always displays sizing grip (even with one band).
        ; ChildSize       :0x20   cxMinChild, cyMinChild, cyChild ; Hidden         :0x8   ; Hides the band.
        ;                         cyMaxChild, cyIntegral          ; HideTitle      :0x400 ; Hides title.
        ; Size            :0x40   cx                              ; NoGripper      :0x100 ; Band will never have a sizing gripper.
        ; Background      :0x80   hmbBack                         ; NoVert         :0x10  ; Band not visible when vertical.
        ; ID              :0x100  wID                             ; TopAlign       :0x800 ; Keep band in top row.
        ; IdealSize       :0x200  cxIdeal                         ; UseChevron     :0x200 ; Show chevron if band is smaller then cxIdeal.
        ; LPARAM          :0x400  lParam                          ; VariableHeight :0x40  ; Auto resized (via cyIntegral and cyMaxChild).
        ; HeaderSize      :0x800  cxHeader
        ; ChevronLocation :0x1000 rcChevronLocation
        ; ChevronState    :0x2000 uChevronState
        
        RBI := Rebar.REBARBANDINFO()
        
        RBI.fMask  := m.Style | m.Child | m.Size | m.ID ; | m.ChildSize ; | m.IdealSize
        RBI.fStyle := s.UseChevron | s.ChildEdge | s.VariableHeight | _styles
        
        If (_gui.Title) {
            buf := Buffer((StrLen(_gui.Title)+1) * (u?2:1),0)
            StrPut(_gui.Title, buf)
            
            RBI.lpText := buf.ptr
            RBI.cch := StrLen(_gui.Title)
            RBI.fMask := RBI.fMask | m.Text
        }
        
        RBI.hwndChild := _gui.hwnd
        ; RBI.cxMinChild := this.__w ; if no min width, return initial width
        ; RBI.cyMinChild := this.__h ; if no min height, return initial height
        RBI.cx := this.__w
        ; RBI.cyChild := this.__h
        ; RBI.cyMaxChild := maxH
        ; RBI.cyIntegral := this.__h
        
        RBI.wID := this.__counter
        ; RBI.cxIdeal := this.__w
        
        ; msgbox "pos: " pos "`r`n"
             ; . "w: " this.__w "`r`n"
             ; . "h: " this.__h "`r`n"
        
        ; typedef struct tagREBARBANDINFOA { offset[32/64]      size[32/64]
          ; UINT     cbSize;                |0                  4
          ; UINT     fMask;                 |4                  8           see above
          ; UINT     fStyle;                |8                  12          see above
          ; COLORREF clrFore;               |12                 16
          ; COLORREF clrBack;               |16                 20
          ; LPSTR    lpText;                |20/24 <----.-----> 24/32       ptr to Text string for Bar
          ; UINT     cch;                   |24/32 -----`       28/36       lenth of text string ^
          ; int      iImage;                |28/36              32/40       image index from imageList
          ; HWND     hwndChild;             |32/40 <----------- 36/48       child window handle to apply to bar
          ; UINT     cxMinChild;            |36/48              40/52       min width of child window (limits the bar)
          ; UINT     cyMinChild;            |40/52              44/56       min height of child window (limits the bar)
          ; UINT     cx;                    |44/56              48/60       length of band (or height if vertical)
          ; HBITMAP  hbmBack;               |48/64 <----------- 52/72       HBITMAP for bar background image
          ; UINT     wID;                   |52/72              56/76       app defined ID
          ; UINT     cyChild;               |56/76              60/80       Initial height of band ONLY if RBBS_VARIABLEHEIGHT style applied
          ; UINT     cyMaxChild;            |60/80              64/84       Max height of band ONLY if RBBS_VARIABLEHEIGHT style applied
          ; UINT     cyIntegral;            |64/84              68/88       Step value to grow or shrink ONLY if RBBS_VARIABLEHEIGHT style applied
          ; UINT     cxIdeal;               |68/88              72/92       Used with RB_MAXIMIZEBAND.
          ; LPARAM   lParam;                |72/96 <----------- 76/104      app defined value
          ; UINT     cxHeader;              |76/104             80/108      space between Band and Child window edges
          ; RECT     rcChevronLocation;     |80/108  (size=16)  96/124      
          ; UINT     uChevronState;         |96/124             100/128     Chevron states: ++
        ; } REBARBANDINFOA, *LPREBARBANDINFOA; ++ https://docs.microsoft.com/en-us/windows/win32/winauto/object-state-constants
        
        return this._sms(Rebar.msgs.InsertBand, pos, RBI.ptr)
    }
    GetBandRect(n) {
        RECT := Buffer(16,0)
        this._sms(Rebar.msgs.GetRect,n-1,RECT.ptr)
        return this._GetRect(RECT)
    }
    MaximizeBand(n) {
        return this._sms(Rebar.msgs.MaximizeBand, n-1)
    }
    MinimizeBand(n) {
        return this._sms(Rebar.msgs.MinimizeBand, n-1)
    }
    MoveBand(n, p) {
        return this._sms(Rebar.msgs.MoveBand, n-1, p-1)
    }
    Resize(RECT:="", ctl:="") {
        If (!ctl) {
            ctl := this
            ctl.gui.GetPos(,,&_w,&_h)
            
            w := _w, h := _h
            
            w := (ctl.w<=0) ? _w + ctl.w : ctl.w + ctl.x
            h := (ctl.h<=0) ? _h + ctl.h : ctl.h + ctl.y 
            
            (!RECT) ? RECT := ctl._SetRect([0, 0, w, h]) : ""
            
        }
        
        r := ctl._sms(Rebar.msgs.SizeToRect, 0, RECT.ptr)
        dbg("w: " w " / h: " h " / " ctl.gui.Title " / resize: " r)
        
        ; Loop ctl.Count { ; loop through bands, look for sub-gui with sub-rebar and resize
            ; RECT := Buffer(16,0)                           ; each iteration is a separate band...
            ; ctl._sms(Rebar.msgs.GetRect, A_Index-1, RECT.ptr)   ; get current band dims RECT
            ; id := ctl.id(A_Index)                               ; get current band ID
            ; _gui := ctl.bands[id]                               ; "extract" sub-gui in this band
            
            ; For hwnd, _ctl in _gui          ; Loop through GUI controls
                ; If (_ctl.Type = "Rebar")    ; look for only Rebars
                    ; ctl.Resize(RECT, _ctl)  ; resize that rebar according to above RECT
        ; }
        
        return ; return something?
    }
    RowHeight(n) {
        return this._sms(Rebar.msgs.GetRowHeight, n-1)
    }
    Rows {
        get => this._sms(Rebar.msgs.GetRowCount)
    }
    SetBandWidth(n, width) {
        return this._sms(Rebar.msgs.SetBandWidth,n-1,width)
    }
    SetParent(hParent) {
        return this._sms(Rebar.msgs.SetParent, hParent)
    }
    ShowBand(n, show:=true) {
        this._sms(Rebar.msgs.ShowBand, n-1, show)
    }
    Style[n] {
        get {
            Static s := Rebar.BandStyle, m := Rebar.BandMask
            REBARBANDINFO := Rebar.REBARBANDINFO()
            REBARBANDINFO.fMask := m.Style
            this._sms(Rebar.msgs.GetBandInfo, n-1, REBARBANDINFO.ptr)
            return REBARBANDINFO.fStyle
        }
        set {
            Static s := Rebar.BandStyle, m := Rebar.BandMask
            REBARBANDINFO := Rebar.REBARBANDINFO()
            REBARBANDINFO.fMask := m.Style
            REBARBANDINFO.fStyle := value
            this._sms(Rebar.msgs.SetBandInfo, n-1, REBARBANDINFO.ptr)
        }
    }
    Type {
        get => "Rebar"
    }
    UseChevron[n] {
        get => !!(this.Style[n] & 0x200) ; check UseChevron flag
        set {
            s := this.style[n]
            If (value) And !(s & 0x200)
                this.Style[n] := s | 0x200
            Else If (!value) And (s & 0x200)
                this.Style[n] := s ^ 0x200
        }
    }
    
    _GetRect(RECT) { ; returns array with 4 elements L/T/R/B
        a := []
        Loop 4
            a.Push(NumGet(RECT, (A_Index - 1) * 4, "UInt"))
        return a
    }
    _SetRect(_RECT) { ; returns struct, accepts array with L/T/R/B values
        If (Type(_RECT) != "Array") Or (_RECT.Length != 4)
            throw Error("Inalid input for this property.",,"The input for this property must be a linear array with 4 values:`r`n`r`n[1, 2, 3, 4]")
        
        RECT := Buffer(16,0)
        Loop 4
            NumPut("UInt", _RECT[A_Index], RECT, (A_Index - 1) * 4)
        
        return RECT
    }
    
    _RGB_BGR(_in) {
        return (_in & 0xFF) << 16 | (_in & 0xFF00) | (_in >> 16)
    }
    _sms(msg, wParam:=0, lParam:=0) {
        return SendMessage(msg, wParam, lParam, this.hwnd)
    }
    
    class struct_base {
        __New(_ptr := 0) { ; 1st param in subclass is parent class
            If !_ptr {
                If (this.__Class = "Rebar.REBARBANDINFO")
                    this.struct := Buffer((A_PtrSize=4)?100:128,0)
                Else If (this.__Class = "Rebar.NMREBARCHILDSIZE")
                    this.struct := Buffer((A_PtrSize=4)?52:64,0)
                Else If (this.__Class = "Rebar.NMRBAUTOSIZE")
                    this.struct := Buffer((A_PtrSize=4)?48:64,0)
                Else If (this.__Class = "Rebar.REBARINFO")
                    this.struct := Buffer((A_PtrSize=4)?12:16,0)
                Else If (this.__Class = "Rebar.HITTESTINFO")
                    this.struct := Buffer((A_PtrSize=4)?12:16,0)
                
                this.ptr := this.struct.ptr
                NumPut("UInt", this.struct.size, this.struct)
            } Else
                this.ptr := _ptr
        }
        _GetRect(_ptr, offset:=0) {
            a := []
            Loop 4
                a.Push(NumGet(_ptr, offset + ((A_Index-1) * 4), "UInt"))
            return a
        }
        _SetRect(value, _ptr, offset:=0) {
            If (Type(value) != "Array") Or (value.Length != 4)
                throw Error("Inalid input for this property.",,"The input for this property must be a linear array with 4 values:`r`n`r`n[1, 2, 3, 4]")
            
            Loop 4
                NumPut("UInt", value[A_Index], _ptr, offset + ((A_Index-1) * 4))
        }
    }
    
    class REBARBANDINFO extends Rebar.struct_base {
        size {
            get => NumGet(this.ptr, 0, "UInt")
            set => NumPut("UInt", value, this.ptr, 0)
        }
        fMask {
            get => NumGet(this.ptr, 4, "UInt")
            set => NumPut("UInt", value, this.ptr, 4)
        }
        fStyle {
            get => NumGet(this.ptr, 8, "UInt")
            set => NumPut("UInt", value, this.ptr, 8)
        }
        clrFore {
            get => NumGet(this.ptr, 12, "UInt")
            set => NumPut("UInt", value, this.ptr, 12)
        }
        clrBack {
            get => NumGet(this.ptr, 16, "UInt")
            set => NumPut("UInt", value, this.ptr, 16)
        }
        lpText {
            get => NumGet(this.ptr, (A_PtrSize=4)?20:24, "UPtr")
            set => NumPut("UPtr", value, this.ptr, (A_PtrSize=4)?20:24)
        }
        cch {
            get => NumGet(this.ptr, (A_PtrSize=4)?24:32, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?24:32)
        }
        text {
            get {
                If (this.lpText && this.cch)
                    return StrGet(this.lpText)
                Else
                    return ""
            }
        }
        iImage {
            get => NumGet(this.ptr, (A_PtrSize=4)?28:36, "Int")
            set => NumPut("Int", value, this.ptr, (A_PtrSize=4)?28:36)
        }
        hwndChild {
            get => NumGet(this.ptr, (A_PtrSize=4)?32:40, "UPtr")
            set => NumPut("UPtr", value, this.ptr, (A_PtrSize=4)?32:40)
        }
        cxMinChild {
            get => NumGet(this.ptr, (A_PtrSize=4)?36:48, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?36:48)
        }
        cyMinChild {
            get => NumGet(this.ptr, (A_PtrSize=4)?40:52, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?40:52)
        }
        cx {
            get => NumGet(this.ptr, (A_PtrSize=4)?44:56, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?44:56)
        }
        hbmBack {
            get => NumGet(this.ptr, (A_PtrSize=4)?48:64, "UPtr")
            set => NumPut("UPtr", value, this.ptr, (A_PtrSize=4)?48:64)
        }
        wID {
            get => NumGet(this.ptr, (A_PtrSize=4)?52:72, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?52:72)
        }
        cyChild {
            get => NumGet(this.ptr, (A_PtrSize=4)?56:76, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?56:76)
        }
        cyMaxChild {
            get => NumGet(this.ptr, (A_PtrSize=4)?60:80, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?60:80)
        }
        cyIntegral {
            get => NumGet(this.ptr, (A_PtrSize=4)?64:84, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?64:84)
        }
        cxIdeal {
            get => NumGet(this.ptr, (A_PtrSize=4)?68:88, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?68:88)
        }
        lParam {
            get => NumGet(this.ptr, (A_PtrSize=4)?72:96, "UPtr")
            set => NumPut("UPtr", value, this.ptr, (A_PtrSize=4)?72:96)
        }
        cxHeader {
            get => NumGet(this.ptr, (A_PtrSize=4)?76:104, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?76:104)
        }
        rcChevronLocation { ; offset = [x86]80 : [x64]108
            get => this._GetRect(this.ptr, (A_PtrSize=4)?80:108)
            set => this._SetRect(value, this.ptr, (A_PtrSize=4)?80:108)
        }
        uChevronState {
            get => NumGet(this.ptr, (A_PtrSize=4)?96:124, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?96:124)
        }
    }
    
    class NMREBARCHILDSIZE extends Rebar.struct_base {
        uBand {
            get => NumGet(this.ptr, (A_PtrSize=4)?12:24, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?12:24)
        }
        wID {
            get => NumGet(this.ptr, (A_PtrSize=4)?16:28, "UInt")
            set => NumPut("UInt", value, this.ptr, (A_PtrSize=4)?16:28)
        }
        rcChild {
            get => this._GetRect(this.ptr, (A_PtrSize=4)?20:32)
            set => this._SetRect(value, this.ptr, (A_PtrSize=4)?20:32)
        }
        rcBand {
            get => this._GetRect(this.ptr, (A_PtrSize=4)?36:48)
            set => this._SetRect(value, this.ptr, (A_PtrSize=4)?36:48)
        }
    }
    
    class NMRBAUTOSIZE extends Rebar.struct_base {
        fChanged {
            get => this._GetRect(this.ptr, (A_PtrSize=4)?12:24)
            set => this._SetRect(value, this.ptr, (A_PtrSize=4)?12:24)
        }
        rcTarget {
            get => this._GetRect(this.ptr, (A_PtrSize=4)?16:28)
            set => this._SetRect(value, this.ptr, (A_PtrSize=4)?16:28)
        }
        rcActual {
            get => this._GetRect(this.ptr, (A_PtrSize=4)?32:44)
            set => this._SetRect(value, this.ptr, (A_PtrSize=4)?32:44)
        }
    }
    
    class REBARINFO extends Rebar.struct_base {
        cbSize {
            get => NumGet(this.ptr, 0, "UInt")
            set => NumPut("UInt", value, this.ptr, 0)
        }
        fMask {
            get => NumGet(this.ptr, 4, "UInt")
            set => NumPut("UInt", value, this.ptr, 4)
        }
        handle {
            get => NumGet(this.ptr, 8, "UPtr")
            set => NumPut("UPtr", value, this.ptr, 8)
        }
    }
    
    class HITTESTINFO extends Rebar.struct_base {
        Point {
            get => [NumGet(this.ptr,"UInt"), NumGet(this.ptr,4,"UInt")]
            set {
                NumPut("UInt", value[1], this.ptr, 0)
                NumPut("UInt", value[2], this.ptr, 4)
            }
        }
        flags {
            get => NumGet(this.ptr, 8, "UInt")
        }
        iBand {
            get => NumGet(this.ptr, 12, "UInt")
        }
    }
}

; typedef struct _RB_HITTESTINFO {
      ; POINT pt;                       |   0       8       mouse x/y
      ; UINT  flags;                    |   8       12      see static HitTestFlags above
      ; int   iBand;                    |   12      16      0-based index of band, or -1 for no band
    ; } RBHITTESTINFO, *LPRBHITTESTINFO;

; typedef struct tagREBARINFO {  offset     size
  ; UINT       cbSize;          |0          4
  ; UINT       fMask;           |4          8
; #if ...
  ; HIMAGELIST himl;            |8          12/16
; #else
  ; HANDLE     himl;
; #endif
; } REBARINFO, *LPREBARINFO;

; typedef struct tagNMRBAUTOSIZE {   offset     size
  ; NMHDR hdr;                      |0          12/24
  ; BOOL  fChanged;                 |12/24      16/28
  ; RECT  rcTarget;                 |16/28      32/44
  ; RECT  rcActual;                 |32/44      48/60 (48/64)
; } NMRBAUTOSIZE, *LPNMRBAUTOSIZE;

; typedef struct tagNMREBARCHILDSIZE {   offset     size
  ; NMHDR hdr;                          |0          12/24
  ; UINT  uBand;                        |12/24      16/28
  ; UINT  wID;                          |16/28      20/32
  ; RECT  rcChild;                      |20/32      36/48
  ; RECT  rcBand;                       |36/48      52/64
; } NMREBARCHILDSIZE, *LPNMREBARCHILDSIZE;



; typedef struct tagREBARINFO { offset      size
  ; UINT       cbSize;      |   0           4
  ; UINT       fMask;       |   4           8           RBIM_IMAGELIST (only this value)
  ; HIMAGELIST himl;        |   8           12/16       img list handle
; } REBARINFO, *LPREBARINFO;





; typedef struct tagNMREBARCHEVRON {     offset     size
  ; NMHDR  hdr;                         |0          12/24
  ; UINT   uBand;                       |12/24      16/28   Band index sending notification
  ; UINT   wID;                         |16/28      20/32   App specified Band ID
  ; LPARAM lParam;                      |20/32      24/40   App specified value
  ; RECT   rc;                          |24/40      32/48   area covered by chevron
  ; LPARAM lParamNM;                    |32/48      36/56   on RBN_CHEVRONPUSHED from RB_PUSHCHEVRON, contains lAppValue (otherwise 0)
; } NMREBARCHEVRON, *LPNMREBARCHEVRON;


