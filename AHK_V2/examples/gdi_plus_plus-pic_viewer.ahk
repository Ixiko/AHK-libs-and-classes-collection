#INCLUDE gdi_plus_plus.ahk
; #INCLUDE gdip_class.ahk
; #INCLUDE TheArkive_WIC.ahk


OnExit(On_Exit)

cols := 4
rows := 4
go := false

g := Gui("+Resize -DpiScale")
g.Add("Button",,"This is a test button.")

g.OnEvent("size",gui_resize)
OnMessage(0x232,resize_done) ; WM_EXITSIZEMOVE := 0x0232

g.OnEvent("close",gui_close)
g.OnEvent("escape",gui_close)

g.Show("w1200 h800")
g.GetClientPos(&_x, &_y, &_w, &_h)

gui_close(*) {
    ExitApp
}

hDC := gdipp.GetDC(g)

; msgbox "hDC ptr: " hDC.ptr " / " gdipp.ObjList.Length
; hDC2 := gdipp.GetDC(0)


; sFile := "C:\Users\Jeb8\Desktop\STAR_WARS_BATTLEFRONT_sci_fi_1swbattlefront_action_fighting_futuristic_shooter_15600x11400.jpg" ; <---- pick a file to open
sFile := "C:\Users\Jeb8\Desktop\folder_ico.png"
; If !sFile {
    ; msgbox "pick a file first!  edit the script."
    ; return
; }
img := gdipp.ImageFromFile(sFile) ; <---- pick a file to open

; Some suggestions for big files to test with:
; https://www.wallpaperup.com/931329/STAR_WARS_BATTLEFRONT_sci-fi_1swbattlefront_action_fighting_futuristic_shooter.html
; https://www.desktopbackground.org/download/7680x4320/2015/04/02/926533_ultra-high-resolution-wallpapers-10240-6400-high-definition_10240x6400_h.jpg

; ==============================================================
; test saving - needs gdip_class.ahk (not available for now)
; ==============================================================
; gdi := gdip.Startup()
; gdip_bmp := gdi.BitmapFromHBITMAP(img2.ptr)
; gdip_bmp.SaveImage("test.png")
; msgbox "saved"
; gdip_bmp.Destroy()
; gdi.Shutdown()
; ==============================================================
; image scaling / brush fill
; ==============================================================

d := img.ScaleToRect(_w,_h)
; brush := hDC.CreateBrush(0x080808)

; hDC.StretchBltMode := 4

oldBrush := hDC.SelectObject(hDC.DcBrush)
hDC.BrushColor := 0xFF0000

hDC.SelectObject(hDC.DcPen)
hDC.PenColor := 0xFF00
; msgbox "oldBrush: " oldBrush



; brush.color := 0xFF0000


hDC.FillRect([300,300,700,200])
hDC.Ellipse([200,500,200,200])

; hDC.StretchBltMode := 4
; hDC.DrawStretch(img,d.rect)
; hDC.StretchBltMode := 3

hDC.Move(50,50)
hDC.LineTo(500,500)

; msgbox "brush:`r`n`r`n"
     ; . Format("0x{:06X}",brush.color) "`r`n"
     ; . brush.style[1] "`r`n" ; use prop[1] to show text description of a value
     ; . brush.hatch[1]        ; if no description is found, the numerical value is returned

; ==============================================================
; 
; ==============================================================

; hDC.ExcludeClipRect(d.rect)
; hDC.FillRect()
sleep 500 ; prevents extra resize events firing on startup
go := true

gui_resize(_gui, MinMax, Width, Height) {
    Global
    Static last_min_max := MinMax
    
    ; If go {
        ; Local rgn
        ; rgn := hDC.CreateRectRgn()  ; create new clipping region
        ; lastRgn := hDC.SelectObject(rgn)       ; set clipping region (client window size)
        
        ; d := img.ScaleToRect(width,height)
        
        ; r1 := hDC.DrawStretch(img,d.rect) ; change to width,height to disable scaling
        
        ; hDC.ExcludeClipRect(d.rect) ; exclude img rect
        ; hDC.FillRect() ; ... then fill
        
        ; If (last_min_max != MinMax) { ; catch min/max event
            ; hDC.SelectObject(rgn)
            ; r1 := hDC.DrawStretchDelay(img,d.rect) ; change to width,height to disable scaling
        ; }
    ; }
    ; last_min_max := MinMax
}

resize_done(wParam, lParam, msg, hwnd) {
    global
    
    ; If go {
        ; g.GetClientPos(&_x, &_y, &_w, &_h)
        ; d := img.ScaleToRect(_w,_h)
        
        ; Local rgn
        ; rgn := hDC.CreateRectRgn()                  ; recreate clipping region (to be drawn in - the window size)
        
        ; hDC.SelectObject(rgn)                       ; reselect rgn into DC
        ; hDC.DrawStretchDelay(img,d.rect) ; change to width,height to disable scaling
    ; }
}


On_Exit(ExitReason, ExitCode) {
    ; msgbox "doing cleanup"
    gdipp.CleanUp()
}

F2::{
    Global
    
    rgn := hDC.CreateRectRgn()  ; create new clipping region
    hDC.SelectObject(rgn)       ; set clipping region (client window size)
    
    g.GetPos(,,&width,&height)
    d := img.ScaleToRect(width,height)
    hDC.DrawStretch(img,[d.x,d.y,d.w,d.h]) ; change to width,height to disable scaling
    
    hDC.ExcludeClipRect([d.x,d.y,d.x+d.w,d.y+d.h]) ; exclude img rect
    hDC.FillRect() ; ... then fill
    
    ; If (last_min_max != MinMax) { ; catch min/max event
        ; hDC.SelectObject(rgn)
        ; r1 := hDC.DrawStretchDelay(img,[d.x,d.y,d.w,d.h]) ; change to width,height to disable scaling
    ; }
    
    ; ===========================================================================
    ; rgn := hDC.CreateRectRgn()    ; recreate clipping region (to be drawn in - the window size in this case)
    ; hDC.SelectObject(rgn)         ; reselect rgn into DC
    
    ; hDC3 := hDC.CompatDC()
    ; msgbox "gui w/h: " hDC.gW " / " hDC.gH 
    
    ; new_img := hDC3.CreateDIBSection(hDC.gW,hDC.gH)
    ; new_img.GetInfo()
    
    ; hDC3.SelectObject(new_img)
    ; msgbox "Draw: " hDC3.Draw(hDC)
    
    ; hDC3.Destroy()
    
    ; new_img.CopyToClipboard("DDB")

    
    ; hDC.FillRect()
    ; ===========================================================================
    ; simple clone (to DDB) and copy to clipboard
    ; ===========================================================================
    ; img.GetInfo()
    ; new_img := img.Clone()
    ; new_img.GetInfo()
    ; new_img.CopyToClipboard()
    
    ; ===========================================================================
    ; copy img to another img via Bitblt - then to clipboard (DIB)
    ; ===========================================================================
    ; img.GetInfo()
    
    ; hDC3 := hDC.CompatDC()
    ; new_img := hDC3.CreateDIBSection(img.w,img.h)
    ; hDC3.SelectObject(new_img)
    ; msgbox "Draw: " hDC3.Draw(img)
    
    ; hDC3.Destroy()
    
    ; new_img.CopyToClipboard()
}

F3::{
    Global
    ; g.GetClientPos(&_x, &_y, &_w, &_h)
    ; d := img.ScaleToRect(_w,_h)
    ; hDC.Draw(new_bmp) ; change to width,height to disable scaling
}

dbg(_in) {
    OutputDebug "AHK: " _in 
}