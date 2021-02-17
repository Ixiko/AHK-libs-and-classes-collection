; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=81268
; Author:	SKAN
; Date:
; for:     	AHK_L

/*  ShutdownDialog(ChooseString)

      Shows Shut Down Windows dialog with UAC prompt like effect.

      Escape key will cancel the UI.

      Parameter ChooseString lets you preselect an option.
      For eg. ShutdownDialog("Restart") will show the dialog with Restart option selected.

      How the function works:
      The function does a full screen capture with FsGrayscale()
      Covers the entire screen with the screenshot on a always-on-top GUI. (Blocks access to all other UI elements.)
      Dims the screenshot to 50% using the technique described here.
      Simulates fade-to-gray with AnimateWindow()
      Shows the dialog


      #NoEnv
      #SingleInstance, Force

      F2::ShutdownDialog()


*/

ShutdownDialog(ChooseString:="") {
  Local
  hBM := FsGrayscale(X,Y,,,W,H)
  hFG := DllCall("CreateBitmap", "Int",1, "Int",1, "Int",1, "Int",32, "PtrP",0x79000000, "Ptr")
  Gui, New, +AlwaysOnTop +ToolWindow -Caption +E0x8000000 hwndhGui +LastFound
  Gui, Margin, 0, 0
  Gui, Add, Picture,, HBITMAP:%hBM%
  Gui, Add, Picture,xp yp wp hp BackgroundTrans, HBITMAP:%hFG%
  Gui, Show, x%X% y%Y% w%W% h%H% Hide
  DllCall("AnimateWindow", "Ptr",hGui, "Int",500, "Int",0xA0000)
  ComObjCreate("Shell.Application").ShutdownWindows()
  WinWait, Shut Down Windows
  Control, ChooseString, %ChooseString%, ComboBox1
  WinSet, AlwaysOnTop, 1
  WinWaitClose
  Gui, %hGui%:Destroy
Return
}

;-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The following function captures entire screen to a grayscale gdi bitmap.
;-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FsGrayscale(ByRef X1:=0, ByRef Y1:=0, ByRef X2:=0, ByRef Y2:=0, ByRef W:=0, ByRef H:=0) {
  Local ; Fullscreen grayscale capture.      Original: ToGrayscale() @ tiny.cc/tograyscale
  VarSetCapacity(WININFO,62), NumPut(62,WININFO,"Int"), PW:=&WININFO
  DllCall("GetWindowInfo", "Ptr",hWnd:=DllCall("GetDesktopWindow", "Ptr"), "Ptr",&WININFO)
  Loop, Parse, % "X1.Y1.X2.Y2.W.H",.
   %A_LoopField% := (A_Index<5 ? NumGet(PW+0,A_Index*4,"Int") : A_Index=5 ? X2-X1 : Y2-Y1)

  tBM := DllCall( "CopyImage", "Ptr"
       , DllCall( "CreateBitmap", "Int",1, "Int",1, "Int",0x1, "Int",8, "Ptr",0, "Ptr")
       , "Int",0, "Int",W, "Int",H, "Int",0x2008, "Ptr")

  tDC := DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  DllCall("DeleteObject", "Ptr",DllCall("SelectObject", "Ptr",tDC, "Ptr",tBM, "Ptr"))
  Loop % (255, n:=0x000000, VarSetCapacity(RGBQUAD256,256*4,0))
        Numput(n+=0x010101, RGBQUAD256, A_Index*4, "Int")
  DllCall("SetDIBColorTable", "Ptr",tDC, "Int",0, "Int",256, "Ptr",&RGBQUAD256)

  sDC := DllCall("GetDC", "Ptr",hWnd, "Ptr")
  DllCall("BitBlt", "Ptr",tDC, "Int",0,  "Int",0,  "Int",W, "Int",H
                  , "Ptr",sDC, "Int",X1, "Int",Y1, "Int",0x00CC0020)

Return (tBM, DllCall("ReleaseDC", "Ptr",hWnd, "Ptr",sDC),  DllCall("DeleteDC", "Ptr",tDC))
}
;-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
