SaveHICONtoFile( hicon, iconFile ) {                                ; By SKAN | 06-Sep-2017 | goo.gl/8NqmgJ
Static CI_FLAGS:=0x2008                                             ; LR_CREATEDIBSECTION | LR_COPYDELETEORG
Local  File, Var, mDC, sizeofRGBQUAD, ICONINFO:=[], BITMAP:=[], BITMAPINFOHEADER:=[]

  File := FileOpen( iconFile,"rw" )
  If ( ! IsObject(File) )
       Return 0
  Else File.Length := 0                                             ; Delete (any existing) file contents                                                   

  VarSetCapacity(Var,32,0)                                          ; ICONINFO Structure
  If ! DllCall( "GetIconInfo", "Ptr",hicon, "Ptr",&Var )
    Return ( File.Close() >> 64 )

  ICONINFO.fIcon      := NumGet(Var, 0,"UInt")
  ICONINFO.xHotspot   := NumGet(Var, 4,"UInt")
  ICONINFO.yHotspot   := NumGet(Var, 8,"UInt")
  ICONINFO.hbmMask    := NumGet(Var, A_PtrSize=8 ? 16:12, "UPtr")
  ICONINFO.hbmMask    := DllCall( "CopyImage"                       ; Create a DIBSECTION for hbmMask
                                , "Ptr",ICONINFO.hbmMask 
                                , "UInt",0                          ; IMAGE_BITMAP
                                , "Int",0, "Int",0, "UInt",CI_FLAGS, "Ptr" ) 
  ICONINFO.hbmColor   := NumGet(Var, A_PtrSize=8 ? 24:16, "UPtr") 
  ICONINFO.hbmColor   := DllCall( "CopyImage"                       ; Create a DIBSECTION for hbmColor
                                , "Ptr",ICONINFO.hbmColor
                                , "UInt",0                          ; IMAGE_BITMAP
                                , "Int",0, "Int",0, "UInt",CI_FLAGS, "Ptr" ) 

  VarSetCapacity(Var,A_PtrSize=8 ? 104:84,0)                        ; DIBSECTION of hbmColor
  DllCall( "GetObject", "Ptr",ICONINFO.hbmColor, "Int",A_PtrSize=8 ? 104:84, "Ptr",&Var )

  BITMAP.bmType       := NumGet(Var, 0,"UInt") 
  BITMAP.bmWidth      := NumGet(Var, 4,"UInt")
  BITMAP.bmHeight     := NumGet(Var, 8,"UInt")
  BITMAP.bmWidthBytes := NumGet(Var,12,"UInt")
  BITMAP.bmPlanes     := NumGet(Var,16,"UShort")
  BITMAP.bmBitsPixel  := NumGet(Var,18,"UShort")
  BITMAP.bmBits       := NumGet(Var,A_PtrSize=8 ? 24:20,"Ptr")
  
  BITMAPINFOHEADER.biClrUsed := NumGet(Var,32+(A_PtrSize=8 ? 32:24),"UInt")
                                                                      
  File.WriteUINT(0x00010000)                                        ; ICONDIR.idReserved and ICONDIR.idType 
  File.WriteUSHORT(1)                                               ; ICONDIR.idCount (No. of images)
  File.WriteUCHAR(BITMAP.bmWidth  < 256 ? BITMAP.bmWidth  : 0)      ; ICONDIRENTRY.bWidth
  File.WriteUCHAR(BITMAP.bmHeight < 256 ? BITMAP.bmHeight : 0)      ; ICONDIRENTRY.bHeight 
  File.WriteUCHAR(BITMAPINFOHEADER.biClrUsed < 256                  ; ICONDIRENTRY.bColorCount
                ? BITMAPINFOHEADER.biClrUsed : 0)
  File.WriteUCHAR(0)                                                ; ICONDIRENTRY.bReserved
  File.WriteUShort(BITMAP.bmPlanes)                                 ; ICONDIRENTRY.wPlanes
  File.WriteUSHORT(BITMAP.bmBitsPixel)                              ; ICONDIRENTRY.wBitCount
  File.WriteUINT(0)                                                 ; ICONDIRENTRY.dwBytesInRes (filled later) 
  File.WriteUINT(22)                                                ; ICONDIRENTRY.dwImageOffset  


  NumPut( BITMAP.bmHeight*2, Var, 8+(A_PtrSize=8 ? 32:24),"UInt")   ; BITMAPINFOHEADER.biHeight should be 
                                                                    ; modified to double the BITMAP.bmHeight  

  File.RawWrite( &Var + (A_PtrSize=8 ? 32:24), 40)                  ; Writing BITMAPINFOHEADER (40  bytes)               

  If ( BITMAP.bmBitsPixel <= 8 )                                    ; Bitmap uses a Color table!
  {
      mDC := DllCall( "CreateCompatibleDC", "Ptr",0, "Ptr" )       
      DllCall( "SaveDC", "Ptr",mDC )
      DllCall( "SelectObject", "Ptr",mDC, "Ptr",ICONINFO.hbmColor )
      sizeofRGBQUAD := ( BITMAPINFOHEADER.biClrUsed * 4 )           ; Colors used x UINT (0x00bbggrr)
      VarSetCapacity( Var,sizeofRGBQUAD,0 )                         ; Array of RGBQUAD structures 
      DllCall( "GetDIBColorTable", "Ptr",mDC, "UInt",0, "UInt",BITMAPINFOHEADER.biClrUsed, "Ptr",&Var )
      DllCall( "RestoreDC", "Ptr",mDC, "Int",-1 )
      DllCall( "DeleteDC", "Ptr",mDC )
      File.RawWrite(Var, sizeofRGBQUAD)                             ; Writing Color table 
  }
    
  File.RawWrite(BITMAP.bmBits, BITMAP.bmWidthBytes*BITMAP.bmHeight) ; Writing BITMAP bits (hbmColor)

  VarSetCapacity(Var,A_PtrSize=8 ? 104:84,0)                        ; DIBSECTION of hbmMask
  DllCall( "GetObject", "Ptr",ICONINFO.hbmMask, "Int",A_PtrSize=8 ? 104:84, "Ptr",&Var )

  BITMAP := []
  BITMAP.bmHeight     := NumGet(Var, 8,"UInt")
  BITMAP.bmWidthBytes := NumGet(Var,12,"UInt")
  BITMAP.bmBits       := NumGet(Var,A_PtrSize=8 ? 24:20,"Ptr")

  File.RawWrite(BITMAP.bmBits, BITMAP.bmWidthBytes*BITMAP.bmHeight) ; Writing BITMAP bits (hbmMask)
  File.Seek(14,0)                                                   ; Seeking ICONDIRENTRY.dwBytesInRes
  File.WriteUINT(File.Length()-22)                                  ; Updating ICONDIRENTRY.dwBytesInRes
  File.Close()
  DllCall( "DeleteObject", "Ptr",ICONINFO.hbmMask  )  
  DllCall( "DeleteObject", "Ptr",ICONINFO.hbmColor )
Return True  
}