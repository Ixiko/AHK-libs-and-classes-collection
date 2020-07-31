; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

hWnd_to_hBmp( hWnd:=-1, Client:=0, A:="", C:="" ) {      ; By SKAN C/M on D295|D299 @ bit.ly/2lyG0sN

; Capture fullscreen, Window, Control or user defined area of these

  A      := IsObject(A) ? A : StrLen(A) ? StrSplit( A, ",", A_Space ) : {},     A.tBM := 0
  Client := ( ( A.FS := hWnd=-1 ) ? False : !!Client ), A.DrawCursor := "DrawCursor"
  hWnd   := ( A.FS ? DllCall( "GetDesktopWindow", "UPtr" ) : WinExist( "ahk_id" . hWnd ) )

  A.SetCapacity( "WINDOWINFO", 62 ),  A.Ptr := A.GetAddress( "WINDOWINFO" ) 
  A.RECT := NumPut( 62, A.Ptr, "UInt" ) + ( Client*16 )  

  If  ( DllCall( "GetWindowInfo",   "Ptr",hWnd, "Ptr",A.Ptr )
    &&  DllCall( "IsWindowVisible", "Ptr",hWnd )
    &&  DllCall( "IsIconic",        "Ptr",hWnd ) = 0 ) 
    {
        A.L := NumGet( A.RECT+ 0, "Int" ),     A.X := ( A.1 <> "" ? A.1 : (A.FS ? A.L : 0) )  
        A.T := NumGet( A.RECT+ 4, "Int" ),     A.Y := ( A.2 <> "" ? A.2 : (A.FS ? A.T : 0 )) 
        A.R := NumGet( A.RECT+ 8, "Int" ),     A.W := ( A.3  >  0 ? A.3 : (A.R - A.L - Round(A.1)) ) 
        A.B := NumGet( A.RECT+12, "Int" ),     A.H := ( A.4  >  0 ? A.4 : (A.B - A.T - Round(A.2)) )
        
        A.sDC := DllCall( Client ? "GetDC" : "GetWindowDC", "Ptr",hWnd, "UPtr" )
        A.mDC := DllCall( "CreateCompatibleDC", "Ptr",A.sDC, "UPtr")
        A.tBM := DllCall( "CreateCompatibleBitmap", "Ptr",A.sDC, "Int",A.W, "Int",A.H, "UPtr" )

        DllCall( "SaveDC", "Ptr",A.mDC )
        DllCall( "SelectObject", "Ptr",A.mDC, "Ptr",A.tBM )
        DllCall( "BitBlt",       "Ptr",A.mDC, "Int",0,   "Int",0, "Int",A.W, "Int",A.H
                               , "Ptr",A.sDC, "Int",A.X, "Int",A.Y, "UInt",0x40CC0020 )  

        A.R := ( IsObject(C) || StrLen(C) ) && IsFunc( A.DrawCursor ) ? A.DrawCursor( A.mDC, C ) : 0
        DllCall( "RestoreDC", "Ptr",A.mDC, "Int",-1 )
        DllCall( "DeleteDC",  "Ptr",A.mDC )   
        DllCall( "ReleaseDC", "Ptr",hWnd, "Ptr",A.sDC )
    }        
Return A.tBM
}
