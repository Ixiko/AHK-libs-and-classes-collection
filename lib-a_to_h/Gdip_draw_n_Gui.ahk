#NoEnv

If (!pToken := Gdip_Startup()){
  MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system!
  ExitApp
}



Gui, Add, GroupBox, x506 y7 w110 h490 , AHK Arena
Gui, Add, Text, x516 y147 w90 h170 vp1text, Player 1
Gui, Add, Text, x516 y327 w90 h160 vp2text, Player 2
Gui, Add, Text, x516 y27 w90 h110 , MainText
; Generated using SmartGUI Creator 4.0
Gui, Show, x124 y78 h505 w625, New GUI Window

HWND := WinExist("A")                                       ; Get the HWND of our Window




; ++++++  GDI Stuff starts here +++++++++


hdc_WINDOW      := GetDC(HWND)                              ; MASTER DC on our Window
; we create a
; 2nd DC, (as a frame) to  draw shapes on.
; So, If we want to show our Frame in the GUI, we have to copy (BitBlt) our Frame DC
; over the Window DC. This is done in the DRAW_SCENE Sub.


; This is our frame
hbm_main := CreateDIBSection(502, 502)              ; 500 x 500 is the size of our GDI image
hdc_main := CreateCompatibleDC()
obm      := SelectObject(hdc_main, hbm_main)
G        := Gdip_GraphicsFromHDC(hdc_main)          ; Getting a Pointer to our bitmap
Gwindow  := Gdip_GraphicsFromHDC(hdc_WINDOW) ;pointer directly to the window for background




;some brushes

   pBWHITE              := Gdip_BrushCreateSolid(0xffFFFFFF)
   pBGREEN		:= Gdip_BrushCreateSolid(0xff00FF00)
   pPBLACK		:= Gdip_CreatePen(0xff000000, 1)
   pBERASER		:= Gdip_BrushCreateSolid(0x00000000) ; fully transparent brush 'eraser'
   
   
   ; Now we draw on our background:
   
  Gdip_FillRectangle(Gwindow,pBWHITE,0,0,500,500)    ;white background

drawvarY = 0
drawvarX = 0
Loop 25
{ 
Gdip_DrawLine(Gwindow, pPBLACK, drawvarY,0,drawvarY,500)
Gdip_DrawLine(Gwindow, pPBLACK, 0,drawvarX,500,drawvarX)    ;gridlines
drawvarY += 20
drawvarX += 20
}


; now we draw our shape onto the frame above the window

Gdip_FillRectangle(G,pBGREEN,95,95,30,30)    ;green small rectangle

; we have to BitBlt() this frame to our Window DC -
; actually, this is often done with a settimer:
   
SetTimer,DRAW_SCENE, 20

; now to erase and redraw this shape:
msgbox, move?

   Gdip_SetSmoothingMode(G, 1)   ; turn off aliasing
   Gdip_SetCompositingMode(G, 1) ; set to overdraw
   
; delete previous graphic and redraw background
posx = 95
posy = 95
posw = 30
posh = 30
   
   ; delete whatever has been drawn here


Gdip_FillRectangle(G, pBERASER, posx, posy, posw, posh)

   Gdip_SetCompositingMode(G, 0) ; switch off overdraw
Gdip_FillRectangle(G,pBGREEN,posx+20,posy+20,area,area)
return     
   
   



;draws the scene
DRAW_SCENE:
   BitBlt(hdc_WINDOW,0, 0, 502,502, hdc_main,0,0) ;position of the GDI Image in the GUI
return