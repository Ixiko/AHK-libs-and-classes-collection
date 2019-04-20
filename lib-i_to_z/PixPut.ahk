/*
     ____  _      ____        __
    / __ \(_)  __/ __ \__  __/ /_             Bitmap Static Control -  Ver 1.0
   / /_/ / / |/_/ /_/ / / / / __/      www.autohotkey.com/forum/viewtopic.php?t=59248
  / ____/ />  </ ____/ /_/ / /_          Suresh Kumar A N ( arian.suresh@gmail.com )
 /_/   /_/_/|_/_/    \__,_/\__/          Created: 14-Jun-2010 | LastMod: 14-Jun-2010

 PixPut() simplifies Drawing Colored Horizontal/Vertical lines and Solid Rectangles on GUI

*/

PixPut( Hwnd, ColorRef=0, X=0, Y=0, W=1, H=1, IsChild=0 ) {          ; Puts a Pixel on GUI
 Static BMD, pBMD             ;     by applying a single colored Bitmap on  Static Control
 If ! VarSetCapacity( BMD )
 VarSetCapacity( BMD,58,0 ), pBMD := NumPut( ColorRef, NumPut( 4, NumPut( 0x18000100000001
 , NumPut( 0x100000028, BMD, 14, "Int64" ), 0, "Int64" ) + 8 ) + 12 ) - 58    ; BitMapData
 Else NumPut( ColorRef, BMD, 54 )
 hBMP := DllCall( "CreateDIBitmap", UInt, hDC := DllCall("GetDC",UInt,hwnd )
                , UInt,pBMD+14,UInt,4, UInt,pBMD+54, UInt,pBMD+14, UInt,1 )
 cHwnd := IsChild ? Hwnd : DllCall( "CreateWindowEx", UInt,0, Str,"Static", Int,0
         , UInt,0x4000010E, Int,X, Int,Y, UInt,1, UInt,1, UInt,hWnd, Int,0, Int,0, Int,0 )
 DllCall( "ReleaseDC", UInt,hWnd, UInt,hDC )
 DllCall( "SetProp", UInt,cHwnd, Str,"PixPut", UInt,hBMP )
 DllCall( "SendMessageA", UInt,cHwnd, UInt,0x172, UInt,0, UInt,hBMP )
 DllCall( "SetWindowPos", UInt,cHwnd, UInt,1, Int,X, Int,Y, Int,W, Int,H, UInt,0x40 )
Return cHwnd
}
 
PixClr( cHwnd, ColorRef=0 ) { ;     Changes the Color of existing PixPut() created control
 If hBMP := DllCall( "GetProp", UInt,cHwnd, Str,"PixPut" ) {
    ControlGetPos, X, Y, W, H,, ahk_id %cHwnd%
    PixPut( cHwnd, ColorRef, X, Y, W, H, True )
    DllCall( "DeleteObject", UInt,hBMP )
}}

PixRmv( cHwnd ) {             ;     Destroys a single control created by PixPut()
 If hBMP := DllCall( "GetProp", UInt,cHwnd, Str,"PixPut" )
    DllCall( "DeleteObject", UInt,hBMP )
  , DllCall( "RemoveProp", UInt,cHwnd, Str,"PixPut" )
Return hBMP ? !!DllCall( "DestroyWindow", UInt,cHwnd ) : 0
}

PixRmvAll( Hwnd ) {           ;     Destroys all controls created by PixPut().
 Critical                     ;     Call this function before ExitApp or Gui,Destroy
 WinGet, CtrlList, ControlListHwnd, ahk_id %hwnd%   ; Depends on 'DetectHiddenWindows, On'
 Loop, Parse, CtrlList, `n
   If hBMP := DllCall( "GetProp", UInt,A_LoopField, Str,"PixPut" )
      DllCall( "DeleteObject", UInt,hBMP ),
    , DllCall( "RemoveProp", UInt,A_LoopField, Str,"PixPut" )
    , DllCall( "DestroyWindow", UInt,A_LoopField )
}

PixLst( Hwnd ) {              ;     Returns all Control Hwnds created by PixPut()
 Critical
 WinGet, CtrlList, ControlListHwnd, ahk_id %hwnd%
 Loop, Parse, CtrlList, `n
   PixLst .= DllCall( "GetProp", UInt,A_LoopField, Str,"PixPut" ) ? "`n" A_LoopField :
Return SubStr( PixLst,2 )
}