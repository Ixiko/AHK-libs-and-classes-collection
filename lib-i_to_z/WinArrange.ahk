; Credits: https://autohotkey.com/board/topic/80580-how-to-programmatically-tile-cascade-windows/

WinArrange( TC=1, aStr="", VH=0x1, Rect="", hWnd=0x0 )  {
 CreateArray( aRect, Rect )                  ; Create a RECT structure.   
 IfEqual,   Rect,, SetEnv, lpRect, 0         ; determining whether lpRect is NULL  
 IfNotEqual,Rect,, SetEnv, lpRect, % &aRect  ; or a pointer to the RECT Structure.
 cKids := CreateArray( aKids, aStr )         ; Create an Array of window handles. 
 IfEqual,   aStr,, SetEnv, lpKids, 0         ; determining whether lpKids is NULL
 IfNotEqual,aStr,, SetEnv, lpKids, % &aKids  ; or a pointer to the array of handles.
If ( TC= 1 ) {                               ; then the windows have to be Tiled
 Return DllCall("TileWindows",Int,hWnd,UInt,VH,UInt,lpRect,Int,cKids,Int,lpKids)
} Else {                                     ; the windows have to be Cascaded
 IfNotEqual, VH, 4,  SetEnv,VH,0 ; If VH is 4, windows will be cascaded in ZORDER
 Return DllCall("CascadeWindows",Int,hWnd,UInt,VH,UInt,lpRect,Int,cKids,Int,lpKids)
}  }

CreateArray( ByRef Arr, aStr="", Size=4 ) { ; complicated variant of InsertInteger()
 IfEqual, aStr,,  Return 0 ; aStr will be a pipe delimited string of integer values.
 StringReplace, aStr, aStr, |, |, All UseErrorlevel ; Calculating the no. of pipes. 
 aFields := errorLevel + 1 ; errorlevel is no. of pipes, +1 results in no of fields.
 VarSetCapacity( Arr, ( aFields*Size ), 0 ) ; Initialise var length and zero fill it.
 Loop, Parse, aStr, |
   {
     Loop %Size%  
        DllCall( "RtlFillMemory", UInt, &Arr+(0 pOffset)+A_Index-1 ; Thanks to Laszlo
        , UInt,1, UChar, A_LoopField >> 8*(A_Index-1) & 0xFF )
     pOffset += %Size%
   } Return aFields
}
