class gdipp {
    Static ObjList := []
    
    Static __New() {
        this.LoadConstants()
    }
    Static BGR_RGB(_c) { ; this conversion works both ways, it ignores 0xFF000000
        return (_c & 0xFF)<<16 | (_c & 0xFF00) | (_c & 0xFF0000)>>16 | (_c & 0xFF000000)
    }
    Static AGBR_RGBA(_c) { ; full reversal of ABGR/RGBA
        return (_c & 0xFF)<<16 | (_c & 0xFF00) | (_c & 0xFF0000)>>16 | (_c & 0xFF000000) >> 24
    }
    Static CleanUp() {
        Loop gdipp.ObjList.Length ; destroy objects in reverse of creation
            gdipp.ObjList.RemoveAt(gdipp.ObjList.Length)
    }
    Static CompatDC(in_hDC:="") {
        If (in_hDC="")
            hDC := DllCall("CreateCompatibleDC", "UPtr", 0, "UPtr")             ; mem DC
        Else If IsInteger(in_hDC)
            hDC := DllCall("CreateCompatibleDC", "UPtr", in_hDC, "UPtr")        ; DC based on input DC ptr
        Else If (IsObject(in_hDC) And in_hDC.cType = "DC")
            hDC := DllCall("CreateCompatibleDC", "UPtr", in_hDC.ptr, "UPtr")    ; DC based on input DC obj
        Else
            hDC := ""                                                           ; unsupported, throw an error
        
        If !hDC
            throw Error("Compatible DC creation failed.`r`n`r`nA_LastError:  " A_LastError)
        
        return gdipp.DC([hDC,1])
    }
    Static GetDC(in_obj:=0) {
        (Type(in_obj) = "Gui") ? (hwnd := in_obj.hwnd) : (hwnd := in_obj)
        
        hDC := DllCall("user32\GetDC", "UPtr", hwnd, "UPtr")
        if hDC {
            obj := gdipp.DC([hDC,0])
            (Type(in_obj) = "Gui") ? (obj.gui := in_obj) : (obj.gui := 0) ; if gui, attach to DC obj
            return obj
        } Else
            Msgbox "ERROR: DC not created.`r`n`r`nA_LastError:  " A_LastError
    }
    Static ImageFromFile(sFileName, ICM:=0) { ; from robodesign version
        If !FileExist(sFileName)
            throw Error("Image file does not exist:`r`n`r`n" sFileName)
        
        hModule := DllCall("LoadLibrary", "Str", "gdiplus", "UPtr") ; success > 0
        si := Buffer((A_PtrSize=8)?24:16,0), NumPut("UInt", 1, si)
        r2 := DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken:=0, "UPtr", si.ptr, "UPtr", 0) ; success = 0
        
        r1 := DllCall("gdiplus\GdipCreateBitmapFromFile" (ICM?"ICM":""), "Str", sFileName, "UPtr*", &old_image:=0)
        If !old_image
            throw Error("GDI+ Image object failed to load.") 
        
        DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UPtr", old_image, "UPtr*", &hBMP:=0, "UInt", 0)
        If !hBMP
            throw Error("GDI+ Image object conversion to HBITMAP failed.")
        
        DllCall("gdiplus\GdipDisposeImage", "UPtr", old_image)
        
        r1 := DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
        DllCall("FreeLibrary", "UPtr", hModule)
        
        return gdipp.Bitmap([hBMP,0]) ; bitmap_new
    }
    Static ObjLookup(in_ptr) {
        For i, obj in this.ObjList
            If (in_ptr = obj.ptr)
                return obj
        return "" ; if no match
    }
    
    ; ===================================================================
    ; Base Obj
    ; ===================================================================
    class base_obj {
        __New(p*) { ; p1 = _gdipp // p2 = ptr
            this.ptr := p[1][1] ; obj pointer
            this.temp := false  ; is obj temp or no?
            
            If (this.cType = "DC") { ; GetDC = 0 // CreateCompatibleDC = 1
                (p[1][2]=0) ? (this.release := "ReleaseDC") : (p[1][2]=1) ? (this.release := "DeleteDC") : ""
                this.StretchBltMode := 3 ; 3 = ColorOnColor / 4 = Halftone - 3 is a good default for speed
                this.gui := {hwnd:0}
                this.StockObjects := Map(), this.StockObjects.CaseSense := false
            } Else If (this.cType != "DC")
                this.CurDC := 0
            
            t := this.GetObjectType()
            If (t="Bitmap") Or (t="Pen") Or (t="Brush") Or (t="ExtPen") Or (t="Font") ; maybe missing HPALLETTE
                this.GetObject()
            
            gdipp.ObjList.Push(this)
        }
        __Delete() {
            this.ByeBye()
        }
        ByeBye() {
            r := ""
            ; If !this.ptr Or this.HasProp("gui") ; DC from hwnd is destroyed as window is destroyed
                ; return
            
            If (this.cType = "DC") {
                ; For name, ptr in this.StockObjects              ; clean up ejected stock objects
                    ; DllCall("DeleteObject", "UPtr", ptr)
                If (this.release = "ReleaseDC")
                    r1 := DllCall("ReleaseDC", "UPtr", this.gui.hwnd, "UPtr", this.ptr)
                Else
                    r1 := DllCall("DeleteDC", "UPtr", this.ptr)
            } Else
                r1 := DllCall("DeleteObject", "UPtr", this.ptr)
            
            If (r1="")
                throw Error("Error on obj release, or object not yet supported."
                          ,,"Obj Type: " this.cType "`r`nObj Ptr: " this.ptr)
        }
        Clean_Up() {
            Loop gdipp.ObjList.Length {
                obj := gdipp.ObjList[i := A_Index]
                If (obj.ptr = this.ptr) {
                    gdipp.ObjList.RemoveAt(i)
                    Break
                }
            }
        }
        Destroy() {
            this.Clean_Up()
        }
        GetInfo(in_ptr:="") {
            obj_type := this.GetObjectType()
            
            oi_size := DllCall("GetObject", "UPtr", (in_ptr?in_ptr:this.ptr), "Int", 0, "UPtr", 0)
            oi:=Buffer((A_PtrSize = 8) ? 104 : 84, 0)
            DllCall("GetObject", "UPtr", (in_ptr?in_ptr:this.ptr), "Int", oi.size, "UPtr", oi.ptr)
            
            msgbox "Return Size: " oi_size "`r`n`r`n"
                 . "Type: " NumGet(oi,0,"UInt") "`r`n"
                 . "Width: " NumGet(oi, 4, "UInt") "`r`n"
                 . "Height: " NumGet(oi, 8, "UInt") "`r`n"
                 . "Stride: " NumGet(oi, 12, "UInt") "`r`n"
                 . "Planes: " NumGet(oi, 16, "UShort") "`r`n"
                 . "bpp: " NumGet(oi, 18, "UShort") "`r`n"
                 . "bPtr: " NumGet(oi, 24, "UPtr") "`r`n`r`n"
                 
                 . "DIBSECTION struct:`r`n"
                 . "Struct: " NumGet(oi,32,"UInt") "`r`n"
                 . "Width: " NumGet(oi, 36, "UInt") "`r`n"
                 . "Height: " NumGet(oi, 40, "UInt") "`r`n"
                 . "Planes: " NumGet(oi, 44, "UShort") "`r`n"
                 . "bpp: " NumGet(oi, 46, "UShort") "`r`n"
                 . "Comp: " NumGet(oi, 48, "UInt") "`r`n"
                 . "Size: " NumGet(oi, 52, "UInt") "`r`n"
                 . "ClrUsed: " NumGet(oi, 60, "UInt") "`r`n"
                 . "ClrImportant: " NumGet(oi, 64, "UInt")
        }
        GetObject(in_ptr:="", show:=false) { ; get/refresh object properties
            iSize := DllCall("GetObject", "UPtr", (in_ptr ? in_ptr : this.ptr), "UInt", 0, "UPtr", 0)
            
            obj_type := this.GetObjectType()
            If (obj_type = "Bitmap")
                iSize := (A_PtrSize = 8) ? 104 : 84
            
            info  := Buffer(iSize,0)
            iWritten := DllCall("GetObject", "UPtr", (in_ptr ? in_ptr : this.ptr), "UInt", iSize, "UPtr", info.ptr)
            
            first_elem := NumGet(info,"UInt")
            
            If (this.cType = "Bitmap" And first_elem = 0) {
                this.__w      := NumGet(info,4,"UInt")
                this.__h      := NumGet(info,8,"UInt")
                this.__stride := NumGet(info,12,"UInt")
                this.__planes := NumGet(info,16,"UShort")
                this.__bpp    := NumGet(info,18,"UShort")
                this.__bPtr   := NumGet(info,(A_PtrSize=8)?24:20, "UPtr")
                
                If (!this.__bPtr) { ; for DDB
                    this.__bpp := this.__stride
                    this.__stride := Round(this.__w * (this.__bpp/8))
                }
            } Else If (this.cType = "Brush") {
                this.__style := NumGet(info,"UInt")
                this.__color := NumGet(info,4,"UInt")
                this.__hatch := NumGet(info,8,"UPtr")
            }
            info := ""
            ; need to add more entries for pens, brush, etc...
        }
        GetObjectType(in_ptr:="") {
            Static types := ["Pen","Brush","DC","MetaDC","PAL","Font","Bitmap","Region"
                           , "MetaFile","MemDC","ExtPen","EnhMetaDC","EnhMetaFIle","ColorSpace"]
            
            result := DllCall("gdi32\GetObjectType", "UPtr", in_ptr ? in_ptr : this.ptr)
            return (!result) ? 0 : types[result]
        }
        GetStockObject(i) {
            return DllCall("gdi32\GetStockObject", "Int", i)
        }
        TempObj(in_obj, op:="Draw") { ; we'll see how this goes...
            If (in_obj.cType = "DC")
                tempObj := in_obj
            Else { ; select obj into temporary DC
                this.SelectObject(tempObj := this.CompatDC(), in_obj)
                tempObj.temp := true
            }
            
            return tempObj
        }
        cType {
            get => StrReplace(this.__Class,"gdipp.","")
        }
    }
    
    ; ===================================================================
    ; Bitmap obj
    ; ===================================================================
    class Bitmap extends gdipp.base_obj {
        Clone(_type:="DIB", delete:=false) {
            flags := (_type="DIB") ? 0x2000 : 0                         ; 0x2000 = LR_CREATEDIBSECTION
            flags := (delete) ? (flags | 0x8) : flags                   ; 0x8 = LR_COPYDELETEORG
            handle := DllCall("user32\CopyImage", "UPtr", this.ptr      ; image handle
                                                , "UInt", 0             ; type / 0 = BITMAP / 1 = ICON / 2 = CURSOR
                                                , "Int",  0, "Int", 0   ; cx / cy image size if icon
                                                , "UInt", flags)
            return gdipp.Bitmap([handle,0])
        }
        CopyToClipboard(_type:="DIB") { ; thanks to guest3456 (mmikeww) for several details to this function
            r1 := DllCall("OpenClipboard", "UPtr", 0) ; 0 = current application
            r2 := DllCall("EmptyClipboard")
            If !r2 {
                msgbox "Error:  Clipboard could not be emptied."
                DllCall("CloseClipboard")
                Return
            }
            
            If (this.bPtr And _type="DIB") {    ; If bPtr exists, then it's a DIB...
                clip_type := 8 ; CF_DIB
                bmp := this.Pack()              ; use Pack() method
            } Else {                            ; ... if not, it's a DDB.
                clip_type := 2 ; CF_BITMAP
                bmp := this.Clone("DDB") ; uses Clone() and DllCall(user32\CopyImage)
            }
            
            DllCall("SetClipboardData", "uint", clip_type, "UPtr", bmp.ptr)
            DllCall("CloseClipboard")
        }
        Pack() { ; returns packed dib
            oi:=Buffer((A_PtrSize = 8) ? 104 : 84, 0)
            DllCall("GetObject", "UPtr", this.ptr, "int", oi.Size, "UPtr", oi.ptr)
            pDib := Buffer(40+this.size)
            r0 := DllCall("RtlMoveMemory", "UPtr", pDib.ptr, "UPtr", oi.ptr+((A_PtrSize=8)?32:24), "UPtr", 40)
            r1 := DllCall("RtlMoveMemory", "UPtr", pDib.ptr+40, "UPtr", this.bPtr, "UPtr", this.size)
            return pDib
        }
        ScaleToRect(w,h:=0) {
            w := Round(w)
            (h=0) ? h:=w : ""
            h := Round(h)
            
            xR := w/this.w, yR := h/this.h      ; Define xRatio and yRatio for resize.
            smallest := (xR<yR) ? "xR" : "yR"   ; Identify smallest ratio.
            
            new_W := Round(this.w * %smallest%) ; Apply ratios.
            new_H := Round(this.h * %smallest%)
            (w-new_W=1) ? new_W += 1 : ""       ; Check for 1 px diff on both x and y axis.
            (h-new_H=1) ? new_H += 1 : ""
            
            new_X := (new_W=w) ? 0 : ((w//2)-(new_W//2))    ; Set new x.
            new_Y := (new_H=h) ? 0 : ((h//2)-(new_H//2))    ; Set new y.
            return {x:new_X, y:new_Y, w:new_W, h:new_H, rect:[new_X,new_Y,new_W,new_H]}
        }
        bpp {
            get => this.__bpp
        }
        bPtr { ; pointer to bitmap data
            get => this.__bPtr
        }
        planes { ; this is usually 1
            get => this.__planes
        }
        size {
            get => this.__h * this.__stride
        }
        stride {
            get => this.__stride
        }
        type {
            get => (this.bPtr) ? "DIB" : "DDB"
        }
        w {
            get => this.__w
        }
        h {
            get => this.__h
        }
    }
    
    ; ===================================================================
    ; Brush - mostly LOGBRUSH
    ; ===================================================================
    ; Brush & Hatch Styles: https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-logbrush
    ;   - Brush: DibPattern, DibPattern8x8, DibPatternPT, Hatched, Hollow, Pattern, Pattern8x8, Solid (default)
    ;   - Hatch: BDiagonal, Cross, DiagCross, FDiagonal, Horizontal (default), Vertical
    ;   NOTE: For corresponding integer values, see constants below in .LoadConstants() method.
    class Brush extends gdipp.base_obj {
        
    }
    
    ; ===================================================================
    ; Device Context obj
    ; ===================================================================
    class DC extends gdipp.base_obj { ; maybe have param to specify BltStretchMode()
        delayMethod := "" ; for delayed drawing
        delayParams := ""
        
        __Call(_method, p) { ; so far this is for DelayDraw*() functions only...
            If !this.HasMethod(method := StrReplace(_method,"Delay","")) {
                msgbox "Invalid method called: " _method
                return
            } Else
                SetTimer ObjBindMethod(this,"DelayDraw", method, p), -1
        }
        Clone() {
            return this.CompatDC()
        }
        CompatDC(in_hDC:="") {
            If (in_hDC="")
                hDC := DllCall("CreateCompatibleDC", "UPtr", this.ptr, "UPtr")      ; DC based on parent obj DC
            Else If IsInteger(in_hDC)
                hDC := DllCall("CreateCompatibleDC", "UPtr", in_hDC, "UPtr")        ; DC based on input DC ptr (including 0 for mem DC)
            Else If (IsObject(in_hDC) And in_hDC.cType = "DC")
                hDC := DllCall("CreateCompatibleDC", "UPtr", in_hDC.ptr, "UPtr")    ; DC based on input DC obj
            Else
                hDC := ""                                                           ; unsupported, throw an error
            
            If !hDC
                throw Error("Compatible DC creation failed.`r`n`r`nA_LastError:  " A_LastError)
            
            return gdipp.DC([hDC,1])
        }
        CreateBrush(_ColorRef:=0x000000, _type:="solid", _hatch:="Horizontal") {
            LOGBRUSH := Buffer((A_PtrSize=8)?16:12,0)
            
            BR_TYPE  := IsInteger(_type) ? _type : gdipp.BrushTypes[_type]
            COLORREF := gdipp.BGR_RGB(_ColorRef) ; reverse input RGB to BGR, leave alpha
            HS_TYPE  := IsInteger(_hatch) ? _hatch : gdipp.HatchTypes[_hatch]
            
            NumPut("UInt", BR_TYPE, "UInt", COLORREF, "UPtr", HS_TYPE, LOGBRUSH) ; HS_TYPE can also be a ptr to a packed DIB
            
            pLogbrush := DllCall("gdi32\CreateBrushIndirect", "UPtr", LOGBRUSH.ptr)
            return gdipp.Brush([pLogbrush,0])
        }
        CreateBitmap(w, h) {
            hBMP := DllCall("gdi32\CreateCompatibleBitmap", "UPtr", this.ptr, "Int", w, "Int", h)
            return gdipp.Bitmap([hBMP,0])
        }
        CreateDIBSection(w, h, bpp:=32) {
            bi := Buffer(40, 0)
            NumPut("UInt", 40       ; struct size
                  ,"UInt", w        ; image width
                  ,"UInt", h        ; image height
                  ,"UShort", 1      ; planes
                  ,"UShort", bpp    ; bpp / color depth
                  ,"UInt", 0, bi)   ; 
            
            hBMP := DllCall("gdi32\CreateDIBSection", "UPtr", this.ptr
                                                    , "UPtr", bi.ptr    ; BITMAPINFO
                                                    , "UInt", Usage:=0
                                                    , "UPtr*", &ppvBits:=0
                                                    , "UPtr", hSection:=0
                                                    , "UInt", OffSet:=0, "UPtr")
            return gdipp.Bitmap([hBMP,0])
        }
        
        CreateRectRgn(a:=0) {
            (!a) ? (a:=[0,0,this.w,this.h]) : ""
            If a.Length != 4
                throw Error("Invalid RECT array.`r`n`r`nThis parameter needs 4 elements:`r`n`r`nLeft, Top, Right, Bottom")
            hRgn := DllCall("gdi32\CreateRectRgn", "Int", a[1], "Int", a[2], "Int", a[3], "Int", a[4])
            return gdipp.Region([hRgn,0])
        }
        
        DelayDraw(method, params) {             ; Specifically for applying mode 4 (Halftone) on a Draw operation.
            old_mode := this.StretchBltMode     ; Usually this mode will cause a massive slow down by comparison. These Draw*Delay()
            this.StretchBltMode := 4            ; variant methods are best used when this is a sort of "final" drawing operation (like
            this.%method%(params*)              ; exiting a sizing loop in a window).  In the case of exiting a window sizing loop,
            this.StretchBltMode := old_mode     ; this prevents the window from possibly freezing.
        }
        Draw(in_obj, _d:=0, _s:=0, Raster:=0) { ; thanks to mmikeww, GeekDude, and robodesign for some details on this func
            (!_d) ? (_d := [0,0]) : ""
            (_d.Length=2) ? (_d.Push(in_obj.w), _d.Push(in_obj.h)) : ""
            (!_s) ? _s := [0,0] : ""
            
            tempObj := this.TempObj(in_obj) ; wrap non-DC Obj into temp DC or just return input DC
            
            r1 := DllCall("gdi32\BitBlt", "UPtr", this.ptr,    "int", _d[1], "int", _d[2], "int", _d[3], "int", _d[4] ; dest DC
                                        , "UPtr", tempObj.ptr, "int", _s[1], "int", _s[2] ; src DC
                                        , "UInt", Raster?Raster:0x00CC0020)
            
            (tempObj.cType = "DC" And tempObj.temp) ? tempObj.Destroy() : "" ; destroy temp DC
            return r1
        }
        DrawAlpha(in_obj, _d:=0, alpha:=255, _s:=0) { ; thanks to mmikeww, GeekDude, and robodesign for some details on this func
            (!_d) ? (_d := [0,0]) : ""
            (_d.Length=2) ? (_d.Push(in_obj.w), _d.Push(in_obj.h)) : ""
            (!_s) ? _s := [0,0,in_obj.w,in_obj.h] : ""
            
            tempObj := this.TempObj(in_obj) ; wrap non-DC Obj into temp DC or just return input DC
            
            r1 := DllCall("msimg32\AlphaBlend", "UPtr", this.ptr,    "int", _d[1], "int", _d[2], "int", _d[3], "int", _d[4] ; dest DC
                                              , "UPtr", tempObj.ptr, "int", _s[1], "int", _s[2], "int", _s[3], "int", _s[4] ; src DC
                                              , "UInt", alpha<<16|1<<24)
            
            (tempObj.cType = "DC" And tempObj.temp) ? tempObj.Destroy() : "" ; destroy temp DC
            return r1
        }
        DrawStretch(in_obj, _d:=0, _s:=0, Raster:=0) { ; thanks to mmikeww, GeekDude, and robodesign for some details on this func
            (!_d) ? (_d := [0,0]) : ""
            (_d.Length=2) ? (_d.Push(in_obj.w), _d.Push(in_obj.h)) : ""
            (!_s) ? _s := [0,0,in_obj.w,in_obj.h] : ""
            
            tempObj := this.TempObj(in_obj) ; wrap non-DC Obj into temp DC or just return input DC
            
            r1 := DllCall("gdi32\StretchBlt", "UPtr", this.ptr,    "int", _d[1], "int", _d[2], "int", _d[3], "int", _d[4] ; dest DC
                                            , "UPtr", tempObj.ptr, "int", _s[1], "int", _s[2], "int", _s[3], "int", _s[4] ; src DC
                                            , "UInt", Raster ? Raster : 0x00CC0020)
            
            (tempObj.cType = "DC" And tempObj.temp) ? tempObj.Destroy() : "" ; destroy temp DC
            return r1
        }
        DrawTrans(in_obj, _d:=0, _s:=0, trans_color:=0) { ; thanks to GeekDude and robodesign for his comments on this func
            (!_d) ? (_d := [0,0]) : ""
            (_d.Length=2) ? (_d.Push(in_obj.w), _d.Push(in_obj.h)) : ""
            (!_s) ? _s := [0,0,in_obj.w,in_obj.h] : ""
            
            tempObj := this.TempObj(in_obj) ; wrap non-DC Obj into temp DC or just return input DC
            
            r1 := DllCall("msimg32\TransparentBlt", "UPtr", this.ptr,    "int", _d[1], "int", _d[2], "int", _d[3], "int", _d[4] ; dest DC
                                                  , "UPtr", tempObj.ptr, "int", _s[1], "int", _s[2], "int", _s[3], "int", _s[4] ; src DC
                                                  , "UInt", trans_color)
            
            (tempObj.cType = "DC" And tempObj.temp) ? tempObj.Destroy() : "" ; destroy temp DC
            return r1
        }
        Ellipse(s) {
            If Type(s) != "Array" Or s.Length != 4
                throw Error("Invalid RECT parameter.",,"Format: [x, y, w, h]")
            
            s[3] := s[1] + s[3] ; convert x, y, w, h to...
            s[4] := s[2] + s[4] ; ... Left, Top, Right, Bottom
            
            return DllCall("gdi32\Ellipse", "UPtr", this.ptr
                                          , "Int", s[1], "Int", s[2], "Int", s[3], "Int", s[4]) ; Left, Top, Right, Bottom
        }
        ExcludeClipRect(a) {
            If Type(a) != "Array" Or a.Length != 4
                throw Error("Invalid RECT array.`r`n`r`nThis parameter needs 4 elements:`r`n`r`nLeft, Top, Right, Bottom")
            
            a[3] := a[1] + a[3] ; convert x, y, w, h to...
            a[4] := a[2] + a[4] ; ... Left, Top, Right, Bottom
            
            return DllCall("gdi32\ExcludeClipRect", "UPtr", this.ptr
                                                  , "Int", a[1], "Int", a[2], "Int", a[3], "Int", a[4]) ; Left, Top, Right, Bottom
        }
        FillRect(_RECT:=0, hBrush:=0) {
            (!_RECT) ? (_RECT := [0,0,this.w,this.h]) : "" ; apply to full DC when _RECT omitted
            
            RECT := Buffer(16,0)
            For i, value in _RECT
                NumPut("UInt", value, RECT, (A_Index-1) * 4)
            
            _brush := (!hBrush) ? hDC.DcBrush : hBrush.ptr ; use CurBrush or use specified brush
            If !_brush
                throw Error("Invalid brush selected for operation.")
            
            return DllCall("user32\FillRect", "UPtr", this.ptr, "UPtr", RECT.ptr, "UPtr", _brush)
        }
        Flush() {
            return DllCall("gdi32\GdiFlush")
        }
        GetBitmap(w:=0, h:=0, _type:="DIB", Raster:=0) { ; considering:   _type:="DIB", always use default raster?
            If (!w and !h and this.gui.hwnd)
                this.gui.GetClientPos(,,&w,&h)
            Else if (!w and !h)
                w := this.w, h := this.h
            
            If (_type="DIB")
                new_BMP := this.CreateDIBSection(w, h) ; CreateBitmap / CreateDIBSection
            Else
                new_BMP := this.CreateBitmap(w, h)
            
            tempDC := this.CompatDC()
            tempDC.SelectObject(new_BMP)
            tempDC.Draw(this)
            tempDC.Destroy()
            
            return new_BMP
        }
        LineTo(x, y) {
            return DllCall("gdi32\LineTo", "UPtr", this.ptr, "Int", x, "Int", y)
        }
        Move(x, y, get_last:=false) {
            If (get_last) {
                POINT := Buffer(8,0)
                get_last := POINT.ptr
            }
            result := DllCall("gdi32\MoveToEx", "UPtr", this.ptr, "Int", x, "Int", y, "UPtr", get_last)
            (get_last) ? get_last := [NumGet(POINT,"UInt"), NumGet(POINT,4,"UInt")] : ""
            return get_last
        }
        SelectObject(p*) {
            If (p.Length = 1)
                DC := this, CurObj := p[1]
            Else If (p.Length = 2)
                DC := p[1], CurObj := p[2]
            Else If (!p.Length Or p.Length > 2)
                throw Error("Invalid number of parameters.")
            
            If IsInteger(CurObj) {          ; stock object
                ; If (stock_obj := gdipp.GetFlag(CurObj,"StockObjectPtrs"))
                    ; this.StockObjects.Delete(stock_obj) ; remove stock object from "ejected list"
                old_ptr := DllCall("gdi32\SelectObject", "UPtr", DC.ptr, "UPtr", in_ptr := CurObj)
            } Else {                        ; wrapped object
                CurObj.CurDC := DC          ; set obj.CurDC in the obj
                old_ptr := DllCall("gdi32\SelectObject", "UPtr", DC.ptr, "UPtr", in_ptr := CurObj.ptr)
            }
            
            If (old_obj_class := gdipp.ObjLookup(old_ptr))
                old_obj_class.CurDC := 0                ; reset .CurDC in old_obj_class if exist
            ; Else If (stock_obj := gdipp.GetFlag(old_ptr,"StockObjectPtrs"))
                ; this.StockObjects[stock_obj] := old_ptr ; catalog stock obj in "ejected list"
            
            If (IsObject(CurObj) And CurObj.cType = "Region")
                CurObj.Destroy()
            
            return old_ptr
        }
        SetBrushOrg(x, y, get_last:=false) {
            If (get_last) {
                POINT := Buffer(8,0)
                get_last := POINT.ptr
            }
            result := DllCall("gdi32\SetBrushOrgEx", "UPtr", this.ptr, "Int", x, "Int", y, "UPtr", get_last)
            (get_last) ? get_last := [NumGet(POINT,"UInt"), NumGet(POINT,4,"UInt")] : ""
            return get_last
        }
        
        ; ====================================================================
        ; DC Properties
        ; ====================================================================
        
        ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getgraphicsmode
        GraphicsMode { ; GM_COMPATIBLE = 1 (default) /// GM_ADVANCED = 2
            set => DllCall("gdi32\SetGraphicsMode", "UPtr", this.ptr, "Int", value)
            get => DllCall("gdi32\GetGraphicsMode", "UPtr", this.ptr)
        }
        
        ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getmapmode
        ; MM_ANISOTROPIC         8  Allows x/y coords to be adjusted independently.
        ;                        
        ; MM_ISOTROPIC           7  Ensures a 1:1 apsect ratio.
        ;                        
        ; MM_TEXT (default)      1  Useful for drawing on varied pixel size (from
        ;                           device to device.
        ;                        
        ; MM_HIENGLISH           5  Useful for drawing in inches/millimeters.
        ; MM_HIMETRIC            3
        ; MM_LOENGLISH           4
        ; MM_LOMETRIC            2
        ; MM_TWIPS               6
        MapMode {
            set => DllCall("gdi32\SetMapMode", "UPtr", this.ptr, "Int", value)
            get => DllCall("gdi32\GetMapMode", "UPtr", this.ptr)
        }
        
        ;https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-setmapperflags
        ;
        ; Specifies whether the font mapper should attempt to match a font's aspect ratio to the current device's
        ; aspect ratio. If bit zero is set, the mapper selects only matching fonts.
        MapperFlags {
            set => DllCall("gdi32\SetMapperFlags", "UPtr", this.ptr, "UInt", value)
            get => DllCall("gdi32\GetMapperFlags", "UPtr", this.ptr)
        }
        
        ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getstretchbltmode
        ; BLACKONWHITE        = 1
        ; WHITEONBLACK        = 2
        ; COLORONCOLOR        = 3 (default for all DC's in this lib)
        ; HALFTONE            = 4
        ; STRETCH_ANDSCANS    = BLACKONWHITE
        ; STRETCH_DELETESCANS = COLORONCOLOR
        ; STRETCH_HALFTONE    = HALFTONE
        ; STRETCH_ORSCANS     = WHITEONBLACK
        ;
        ; Without ColorOnColor or Halftone set, you are likely to get color distortion,
        ; especially if you are trying to draw an image loaded from a 24-bit source,
        ; like JPEG.
        StretchBltMode {
            set => DllCall("gdi32\SetStretchBltMode", "UPtr", this.ptr, "Int", value)
            get => DllCall("gdi32\GetStretchBltMode", "UPtr", this.ptr)
        }
        
        ; ====================================================================
        ; Stock Object pointers
        ; ====================================================================
        AnsiFixedFont {
            get => DllCall("gdi32\GetStockObject", "Int", 11)
        }
        AnsiVarFont {
            get => DllCall("gdi32\GetStockObject", "Int", 12)
        }
        BlackBrush {
            get => DllCall("gdi32\GetStockObject", "Int", 4)
        }
        BlackPen {
            get => DllCall("gdi32\GetStockObject", "Int", 7)
        }
        DcBitmap {
            get => DllCall("gdi32\GetStockObject", "Int", 21) ; not documented
        }
        DcBrush {
            get => DllCall("gdi32\GetStockObject", "Int", 18)
        }
        DcColorSpace {
            get => DllCall("gdi32\GetStockObject", "Int", 20) ; not documented
        }
        DcPen {
            get => DllCall("gdi32\GetStockObject", "Int", 19)
        }
        DefaultDeviceFont {
            get => DllCall("gdi32\GetStockObject", "Int", 14)
        }
        DefaultGuiFont {
            get => DllCall("gdi32\GetStockObject", "Int", 17)
        }
        DefaultPallette {
            get => DllCall("gdi32\GetStockObject", "Int", 15)
        }
        DkGrayBrush {
            get => DllCall("gdi32\GetStockObject", "Int", 3)
        }
        GrayBrush {
            get => DllCall("gdi32\GetStockObject", "Int", 2)
        }
        LtGrayBrush {
            get => DllCall("gdi32\GetStockObject", "Int", 1)
        }
        NullBrush {
            get => DllCall("gdi32\GetStockObject", "Int", 5) ; aka Hollow_Brush
        }
        NullPen {
            get => DllCall("gdi32\GetStockObject", "Int", 8)
        }
        OemFixedFont {
            get => DllCall("gdi32\GetStockObject", "Int", 10)
        }
        SystemFixedFont {
            get => DllCall("gdi32\GetStockObject", "Int", 16)
        }
        SystemFont {
            get => DllCall("gdi32\GetStockObject", "Int", 13)
        }
        WhiteBrush {
            get => DllCall("gdi32\GetStockObject", "Int", 0)
        }
        WhitePen {
            get => DllCall("gdi32\GetStockObject", "Int", 6)
        }
        
        ; ====================================================================
        ; Stock Object properties
        ; ====================================================================
        BgMode {
            get {
                return DllCall("gdi32\GetBkMode", "UPtr", this.ptr) ; Transparent = 1 // Opaque = 2
            }
            set {
                DllCall("gdi32\SetBkMode", "UPtr", this.ptr, "Int", value)
            }
        }
        BgColor {
            get {
                return gdipp.BGR_RGB(DllCall("gdi32\GetBkColor", "UPtr", this.ptr))
            }
            set {
                DllCall("gdi32\SetBkColor", "UPtr", this.ptr, "Int", gdipp.BGR_RGB(value))
            }
        }
        BrushColor {
            get => gdipp.BGR_RGB(DllCall("gdi32\GetDCBrushColor", "UPtr", this.ptr))
            set => DllCall("gdi32\SetDCBrushColor", "UPtr", this.ptr, "Int", gdipp.BGR_RGB(value))
        }
        PenColor {
            get => gdipp.BGR_RGB(DllCall("gdi32\GetDCPenColor", "UPtr", this.ptr))
            set => DllCall("gdi32\SetDCPenColor", "UPtr", this.ptr, "Int", gdipp.BGR_RGB(value))
        }
        
        ; ====================================================================
        ; properties from GetDeviceCaps
        ; ====================================================================
        AspectX {
            get => gdipp.GetDeviceCaps(this.ptr, 40)
        }
        AspectY {
            get => gdipp.GetDeviceCaps(this.ptr, 42)
        }
        AspectXY {
            get => gdipp.GetDeviceCaps(this.ptr, 44)
        }
        BltAlignment {
            get => gdipp.GetDeviceCaps(this.ptr, 119)
        }
        bpp {
            get => gdipp.GetDeviceCaps(this.ptr, 12)
        }
        ColorRes {
            get => this.GetDeviceCaps(this.ptr, 108)
        }
        DpiX {
            get => this.GetDeviceCaps(this.ptr, 88)
        }
        DpiY {
            get => this.GetDeviceCaps(this.ptr, 90)
        }
        DesktopH {
            get => this.GetDeviceCaps(this.ptr, 117)
        }
        DesktopW {
            get => this.GetDeviceCaps(this.ptr, 118)
        }
        DriverVersion {
            get => this.GetDeviceCaps(this.ptr, 0)
        }
        mmX {
            get => this.GetDeviceCaps(this.ptr, 4)
        }
        mmY {
            get => this.GetDeviceCaps(this.ptr, 6)
        }
        NumBrushes {
            get => this.GetDeviceCaps(this.ptr, 16)
        }
        NumColors {
            get => this.GetDeviceCaps(this.ptr, 24)
        }
        NumFonts {
            get => this.GetDeviceCaps(this.ptr, 22)
        }
        NumMarkers {
            get => this.GetDeviceCaps(this.ptr, 20)
        }
        NumPens {
            get => this.GetDeviceCaps(this.ptr, 18)
        }
        PaletteSize {
            get => this.GetDeviceCaps(this.ptr, 104)
        }
        PDeviceSize {
            get => this.GetDeviceCaps(this.ptr, 26)
        }
        PhysicalOffsetX {
            get => this.GetDeviceCaps(this.ptr, 112)
        }
        PhysicalOffsetY {
            get => this.GetDeviceCaps(this.ptr, 113)
        }
        PhysicalW {
            get => this.GetDeviceCaps(this.ptr, 110)
        }
        PhysicalH {
            get => this.GetDeviceCaps(this.ptr, 111)
        }
        Planes {
            get => this.GetDeviceCaps(this.ptr, 14)
        }
        ScalingFactorX {
            get => this.GetDeviceCaps(this.ptr, 114)
        }
        ScalingFactorY {
            get => this.GetDeviceCaps(this.ptr, 115)
        }
        VRefresh {
            get => this.GetDeviceCaps(this.ptr, 116)
        }
        w {
            get => this.GetDeviceCaps(this.ptr, 8)
        }
        h {
            get => this.GetDeviceCaps(this.ptr, 10)
        }
        gW { ; get attached gui width, if gui attached
            get {
                If (!this.gui.hwnd)
                    return 0
                Else {
                    this.gui.GetClientPos(,,&w)
                    return w
                }
            }
        }
        gH { ; get attached gui height, if gui attached
            get {
                If (!this.gui.hwnd)
                    return 0
                Else {
                    this.gui.GetClientPos(,,,&h)
                    return h
                }
            }
        }
        
        GetDeviceCaps(hdc, index) { ; (https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getdevicecaps)
            return DllCall("gdi32\GetDeviceCaps", "UPtr", hDC, "int", index) ; thanks to mmikeww, GeekDude, and robodesign for these docs!
        }
    }
    
    ; ===================================================================
    ; Font
    ; ===================================================================
    class Font extends gdipp.base_obj {
        
    }
    
    ; ===================================================================
    ; Pen
    ; ===================================================================
    class Pen extends gdipp.base_obj {
        
    }
    
    ; ===================================================================
    ; Region
    ; ===================================================================
    class Region extends gdipp.base_obj {
        
    }
    
    ; =============================================================================================
    ; method for loading constants - so we can turn CaseSense off in Map()
    ; =============================================================================================
    Static LoadConstants() {
        ; Brush Types (0-3, 5-8) ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-logbrush
        bt := Map(), bt.CaseSense := false
          bt["Solid"]         := 0
        , bt["Hollow"]        := 1
        , bt["Hatched"]       := 2
        , bt["Pattern"]       := 3
        , bt["DibPattern"]    := 5
        , bt["DibPatternPT"]  := 6
        , bt["Pattern8x8"]    := 7 
        , bt["DibPattern8x8"] := 8
        this.BrushTypes := bt
        
        ; Hatch Styles (0-5) ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-logbrush
        ht := Map(), ht.CaseSense := false
          ht["Horizontal"] := 0
        , ht["Vertical"]   := 1
        , ht["FDiagonal"]  := 2
        , ht["BDiagonal"]  := 3
        , ht["Cross"]      := 4
        , ht["DiagCross"]  := 5
        this.HatchTypes := ht
        
        ; Stock Object types (1-14) ; https://docs.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-getstockobject
        so := Map(), so.CaseSense := false
          so["WhiteBrush"]        := 0
        , so["LtGrayBrush"]       := 1
        , so["GrayBrush"]         := 2
        , so["DkGrayBrush"]       := 3
        , so["BlackBrush"]        := 4
        , so["HollowBrush"]       := 5 ; a.k.a. NULL_BRUSH
        , so["WhitePen"]          := 6
        , so["BlackPen"]          := 7
        , so["NullPen"]           := 8
        , so["_Unknown_9"]        := 9 ; always returns 0 (so far)
        , so["OemFixedFont"]      := 10
        , so["AnsiFixedFont"]     := 11
        , so["AnsiVarFont"]       := 12
        , so["SystemFont"]        := 13
        , so["DefaultDeviceFont"] := 14
        , so["DefaultPallette"]   := 15
        , so["SystemFixedFont"]   := 16
        , so["DefaultGuiFont"]    := 17
        , so["DcBrush"]           := 18
        , so["DcPen"]             := 19
        , so["DcColorSpace"]      := 20 ; not documented
        , so["DcBitmap"]          := 21 ; not documented
        this.StockObjectTypes := so
        
        sop := Map(), sop.CaseSense := false ; StockObjectPtrs
        For name, val in so
            If (name != "_Unknown_9")
                sop[name] := DllCall("gdi32\GetStockObject", "Int", val)
        this.StockObjectPtrs := sop
    }
    Static GetFlag(iInput,member) { ; reverse lookup for Map() constants
        For prop, value in gdipp.%member%
            If (iInput = value)
                return prop
        return "" ; if no match
        ; throw Error("GetFlag() method:  Value not listed.`r`n`r`nValue:  " iInput)
    }
    Static InArray(arr,in_val) {
        For i, value in arr
            If (in_val = value)
                return i
        return false ; if no match
    }
    
    ; ===================================================================
    ; GDIP sub class
    ; ===================================================================
    class p {
        Static Startup() {
            this.hModule := DllCall("LoadLibrary", "Str", "gdiplus", "UPtr") ; success > 0
            Static si := Buffer((A_PtrSize=8)?24:16,0)
            NumPut("UInt", 1, si)
            r2 := DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken:=0, "UPtr", si.ptr, "UPtr", 0) ; success = 0
            this.token := pToken
        }
        Static Shutdown() {
            r1 := DllCall("gdiplus\GdiplusShutdown", "UPtr", this.token)
        }
    }
}


; ===============================================================================
; ===============================================================================
; Common Structures in Class wrappers
; ===============================================================================
; ===============================================================================

class LOGFONT {
    __New() {
    
    }
    
}

/**
 * Bilinear resize ARGB image.
 * pixels is an array of size w * h.
 * Target dimension is w2 * h2.
 * w2 * h2 cannot be zero.
 * 
 * @param pixels Image pixels.
 * @param w Image width.
 * @param h Image height.
 * @param w2 New width.
 * @param h2 New height.
 * @return New array with size w2 * h2.
 */
 
; public int[] resizeBilinear(int[] pixels, int w, int h, int w2, int h2) {
    ; int[] temp = new int[w2*h2] ;
    ; int a, b, c, d, x, y, index ;
    ; float x_ratio = ((float)(w-1))/w2 ;
    ; float y_ratio = ((float)(h-1))/h2 ;
    ; float x_diff, y_diff, blue, red, green ;
    ; int offset = 0 ;
    ; for (int i=0;i<h2;i++) {
        ; for (int j=0;j<w2;j++) {
            ; x = (int)(x_ratio * j) ;
            ; y = (int)(y_ratio * i) ;
            ; x_diff = (x_ratio * j) - x ;
            ; y_diff = (y_ratio * i) - y ;
            ; index = (y*w+x) ;                
            ; a = pixels[index] ;
            ; b = pixels[index+1] ;
            ; c = pixels[index+w] ;
            ; d = pixels[index+w+1] ;

            ; // blue element
            ; // Yb = Ab(1-w)(1-h) + Bb(w)(1-h) + Cb(h)(1-w) + Db(wh)
            ; blue = (a&0xff)*(1-x_diff)*(1-y_diff) + (b&0xff)*(x_diff)*(1-y_diff) +
                   ; (c&0xff)*(y_diff)*(1-x_diff)   + (d&0xff)*(x_diff*y_diff);

            ; // green element
            ; // Yg = Ag(1-w)(1-h) + Bg(w)(1-h) + Cg(h)(1-w) + Dg(wh)
            ; green = ((a>>8)&0xff)*(1-x_diff)*(1-y_diff) + ((b>>8)&0xff)*(x_diff)*(1-y_diff) +
                    ; ((c>>8)&0xff)*(y_diff)*(1-x_diff)   + ((d>>8)&0xff)*(x_diff*y_diff);

            ; // red element
            ; // Yr = Ar(1-w)(1-h) + Br(w)(1-h) + Cr(h)(1-w) + Dr(wh)
            ; red = ((a>>16)&0xff)*(1-x_diff)*(1-y_diff) + ((b>>16)&0xff)*(x_diff)*(1-y_diff) +
                  ; ((c>>16)&0xff)*(y_diff)*(1-x_diff)   + ((d>>16)&0xff)*(x_diff*y_diff);

            ; temp[offset++] = 
                    ; 0xff000000 | // hardcode alpha
                    ; ((((int)red)<<16)&0xff0000) |
                    ; ((((int)green)<<8)&0xff00) |
                    ; ((int)blue) ;
        ; }
    ; }
    ; return temp ;
; }