;Tested on A_AhkVersion  U64 1.1.27.06 - Windows 10 Home x64 1809
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

;Need to include your path to Gdip or have in the same directory as script
#Include ../Gdip_All.ahk

OnMessage(0x200, "OnWM_MOUSEMOVE")
OnMessage(0x20A, "OnWM_MOUSEWHEEL")

;Create a GUI
Gui Mapper: New, hWndhMap -DPIScale +OwnDialogs
Gui Show, NA w600 h600, Mapper

;Create a Layered window ontop if the GUI to draw on with the GDI+ functions
Gui 1: +E0x80000 +LastFound -Caption -DPIScale +ParentMapper
hGui := WinExist()
Gui 1: Show, NA
w:= 600, h:= 600

pToken := Gdip_Startup()
hbm := CreateDIBSection(w, h), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4)

;Create a GraphicsPath
pPath := Gdip_CreatePath() ; creates a Path (GraphicsPath object)

;Add figure to path
Gdip_StartPathFigure(pPath) ; starts a new figure in this Path
Gdip_AddPathLine(pPath, 200, 200, 400, 200)
Gdip_AddPathLine(pPath, 400, 200, 400, 400)
Gdip_AddPathLine(pPath, 400, 400, 200, 400)
Gdip_AddPathLine(pPath, 200, 400, 200, 200)
Gdip_ClosePathFigure(pPath) ; closes the current figure of this path

;Create a Pen to draw with
pPen := Gdip_CreatePen(0xff000000, 5)

;Rotate the graphic until exit
Loop {
  Gdip_GraphicsClear(G)            ; Clear the graphics
  Gdip_RotatePathAtCenter(pPath, 5)          ; Rotate the path by 5deg on its center
  Gdip_DrawPath(G, pPen, pPath)        ; draw rectangle
  UpdateLayeredWindow(hGui, hdc, 0, 0, w, h)  ; Update the layred window
  Sleep 100
}

Esc::
MapperGuiEscape:
MapperGuiClose:

;Cleanup and Exit
Gdip_DeletePen(pPen)
SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
Gdip_DeleteGraphics(G)
Gdip_Shutdown(pToken)
Gui Mapper: Destroy
ExitApp

;HitTest if the mouse in inside the graphicspath
OnWM_MOUSEMOVE(wParam, lParam, msg, hWnd) {
  Global
  
  mX := lParam & 0xFFFF  ;get low order
  mY := lParam >> 16    ;get high order

  hit := Gdip_IsVisiblePathPoint(pPath, mX, mY, G)
  Tooltip % "Hit= " hit

}

OnWM_MOUSEWHEEL(wParam, lParam, msg, hWnd) {
  Global

  mX := lParam & 0xFFFF  ;get low order
  mY := lParam >> 16    ;get high order
  delta := wParam >> 16   ;120 for zoom in, 65416 for zoom out
  
  Scale := Delta = 120 ? 0.9 : 1.1  ;Adjust scale factor
  ;TODO - Factor in the mouse coords to zoom in/out at that point

  Gdip_GraphicsClear(G)
  pMatrix := Gdip_CreateMatrix()
  
  ; Calculate center of Window which will be the center of the graphics path
  cX := w / 2
  cY := h / 2
  
  ; Move Centre point of square to origin of graphics object, then scale and then move back to original center point of square
  GDip_TranslateMatrix(pMatrix, -cX, -cY, 1)
  Gdip_ScaleMatrix(pMatrix, Scale, Scale, 1)
  GDip_TranslateMatrix(pMatrix, cX, cY, 1)
  
  ; Apply the transformations
  Gdip_TransformPath(pPath, pMatrix)
  
  ; Redraw the path and update the window
  Gdip_DrawPath(G, pPen, pPath)
  UpdateLayeredWindow(hGui, hdc, 0, 0, w, h)
}

