; Title:   	IsAlphaBitmap(hBM) : Returns true if a GDI Bitmap is alpha transparent
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=80920&sid=db7efdf0ea113168e23aceabd7ef068f
; Author:	SKAN
; Date:   	11.09.2020
; for:     	AHK_L

/*


*/

IsAlphaBitmap(sBM) {                                        ; v0.95 by SKAN on D39C/D39O @ tiny.cc/t80920
Local
  VarSetCapacity(BITMAP, 32, 0)
  Res := DllCall("GetObject", "Ptr",sBM, "Int",A_PtrSize=8? 32:24, "Ptr",&BITMAP)
  Bpp := NumGet(BITMAP,18,"UShort")
  If (Res=0|| Bpp<32)
    Return 0

  W := NumGet(BITMAP,04,"UInt"), Plane := NumGet(BITMAP,16,"UShort"),  WBytes := NumGet(BITMAP,12,"UInt")
  H := NumGet(BITMAP,08,"UInt"), Bytes := WBytes*H,                    HalfSz := Bytes/2
  VarSetCapacity(BITMAPINFO, 40, 0), pBits:=0
  NumPut(Bpp,NumPut(Plane,NumPut(0-H,NumPut(W,NumPut(40,BITMAPINFO,"Int"),"Int"),"Int"),"Short"),"Short")
  tBM := DllCall("CreateDIBSection"
               , "Ptr",0, "Ptr",&BITMAPINFO, "Int",0, "PtrP",pBits, "Ptr",0, "Int", 0, "Ptr")
  tDC := DllCall("CreateCompatibleDC", "Ptr",0, "Ptr"),  DllCall("SaveDC", "Ptr",tDC)
  sDC := DllCall("CreateCompatibleDC", "Ptr",0, "Ptr"),  DllCall("SaveDC", "Ptr",sDC)
  DllCall("SelectObject", "Ptr",tDC, "Ptr",tBM)
  DllCall("SelectObject", "Ptr",sDC, "Ptr",sBM)
  DllCall("GdiAlphaBlend", "Ptr",tDC, "Int",0, "Int",0, "Int",W, "Int",H
                         , "Ptr",sDC, "Int",0, "Int",0, "Int",W, "Int",H, "Int",0x01FF0000)
  DllCall("RestoreDC", "Ptr",sDC, "Int",-1),             DllCall("DeleteDC", "Ptr",sDC)
  DllCall("RestoreDC", "Ptr",tDC, "Int",-1),             DllCall("DeleteDC", "Ptr",tDC)
  IsAplha := NumGet(pBits+0,"UInt") ? 1
          :  !(DllCall("ntdll\RtlCompareMemory", "Ptr",pBits, "Ptr",pBits+1, "Ptr",Bytes-1)=Bytes-1)
  DllCall("DeleteObject", "Ptr",tBM)
Return IsAplha
}