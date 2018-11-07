class WinClip_base
{
  __Call( aTarget, aParams* ) {
    if ObjHasKey( WinClip_base, aTarget )
      return WinClip_base[ aTarget ].( this, aParams* )
    throw Exception( "Unknown function '" aTarget "' requested from object '" this.__Class "'", -1 )
  }
  
  Err( msg ) {
    throw Exception( this.__Class " : " msg ( A_LastError != 0 ? "`n" this.ErrorFormat( A_LastError ) : "" ), -2 )
  }
  
  ErrorFormat( error_id ) {
    VarSetCapacity(msg,1000,0)
    if !len := DllCall("FormatMessageW"
          ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200		;dwflags
          ,"Ptr",0		;lpSource
          ,"UInt",error_id	;dwMessageId
          ,"UInt",0			;dwLanguageId
          ,"Ptr",&msg			;lpBuffer
          ,"UInt",500)			;nSize
      return
    return 	strget(&msg,len)
  }
}

class WinClipAPI_base extends WinClip_base
{
  __Get( name ) {
    if !ObjHasKey( this, initialized )
      this.Init()
    else
      throw Exception( "Unknown field '" name "' requested from object '" this.__Class "'", -1 )
  }
}

class WinClipAPI extends WinClip_base
{
  memcopy( dest, src, size ) {
    return DllCall( "msvcrt\memcpy", "ptr", dest, "ptr", src, "uint", size )
  }
  GlobalSize( hObj ) {
    return DllCall( "GlobalSize", "Ptr", hObj )
  }
  GlobalLock( hMem ) {
    return DllCall( "GlobalLock", "Ptr", hMem )
  }
  GlobalUnlock( hMem ) {
    return DllCall( "GlobalUnlock", "Ptr", hMem )
  }
  GlobalAlloc( flags, size ) {
    return DllCall( "GlobalAlloc", "Uint", flags, "Uint", size )
  }
  OpenClipboard() {
    return DllCall( "OpenClipboard", "Ptr", 0 )
  }
  CloseClipboard() {
    return DllCall( "CloseClipboard" )
  }
  SetClipboardData( format, hMem ) {
    return DllCall( "SetClipboardData", "Uint", format, "Ptr", hMem )
  }
  GetClipboardData( format ) {
    return DllCall( "GetClipboardData", "Uint", format ) 
  }
  EmptyClipboard() {
    return DllCall( "EmptyClipboard" )
  }
  EnumClipboardFormats( format ) {
    return DllCall( "EnumClipboardFormats", "UInt", format )
  }
  CountClipboardFormats() {
    return DllCall( "CountClipboardFormats" )
  }
  GetClipboardFormatName( iFormat ) {
    size := VarSetCapacity( bufName, 255*( A_IsUnicode ? 2 : 1 ), 0 )
    DllCall( "GetClipboardFormatName", "Uint", iFormat, "str", bufName, "Uint", size )
    return bufName
  }
  GetEnhMetaFileBits( hemf, ByRef buf ) {
    if !( bufSize := DllCall( "GetEnhMetaFileBits", "Ptr", hemf, "Uint", 0, "Ptr", 0 ) )
      return 0
    VarSetCapacity( buf, bufSize, 0 )
    if !( bytesCopied := DllCall( "GetEnhMetaFileBits", "Ptr", hemf, "Uint", bufSize, "Ptr", &buf ) )
      return 0
    return bytesCopied
  }
  SetEnhMetaFileBits( pBuf, bufSize ) {
    return DllCall( "SetEnhMetaFileBits", "Uint", bufSize, "Ptr", pBuf )
  }
  DeleteEnhMetaFile( hemf ) {
    return DllCall( "DeleteEnhMetaFile", "Ptr", hemf )
  }
  ErrorFormat(error_id) {
    VarSetCapacity(msg,1000,0)
    if !len := DllCall("FormatMessageW"
          ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200		;dwflags
          ,"Ptr",0		;lpSource
          ,"UInt",error_id	;dwMessageId
          ,"UInt",0			;dwLanguageId
          ,"Ptr",&msg			;lpBuffer
          ,"UInt",500)			;nSize
      return
    return 	strget(&msg,len)
  }
  IsInteger( var ) {
    if var is integer
      return True
    else 
      return False
  }
  LoadDllFunction( file, function ) {
      if !hModule := DllCall( "GetModuleHandleW", "Wstr", file, "UPtr" )
          hModule := DllCall( "LoadLibraryW", "Wstr", file, "UPtr" )
      
      ret := DllCall("GetProcAddress", "Ptr", hModule, "AStr", function, "UPtr")
      return ret
  }
  SendMessage( hWnd, Msg, wParam, lParam ) {
     static SendMessageW

     If not SendMessageW
        SendMessageW := this.LoadDllFunction( "user32.dll", "SendMessageW" )

     ret := DllCall( SendMessageW, "UPtr", hWnd, "UInt", Msg, "UPtr", wParam, "UPtr", lParam )
     return ret
  }
  GetWindowThreadProcessId( hwnd ) {
    return DllCall( "GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0 )
  }
  WinGetFocus( hwnd ) {
    GUITHREADINFO_cbsize := 24 + A_PtrSize*6
    VarSetCapacity( GuiThreadInfo, GUITHREADINFO_cbsize, 0 )	;GuiThreadInfoSize = 48
    NumPut(GUITHREADINFO_cbsize, GuiThreadInfo, 0, "UInt")
    threadWnd := this.GetWindowThreadProcessId( hwnd )
    if not DllCall( "GetGUIThreadInfo", "uint", threadWnd, "UPtr", &GuiThreadInfo )
        return 0
    return NumGet( GuiThreadInfo, 8+A_PtrSize,"UPtr")  ; Retrieve the hwndFocus field from the struct.
  }
  GetPixelInfo( ByRef DIB ) {
    ;~ typedef struct tagBITMAPINFOHEADER {
    ;~ DWORD biSize;              0
    ;~ LONG  biWidth;             4
    ;~ LONG  biHeight;            8
    ;~ WORD  biPlanes;            12
    ;~ WORD  biBitCount;          14
    ;~ DWORD biCompression;       16
    ;~ DWORD biSizeImage;         20
    ;~ LONG  biXPelsPerMeter;     24
    ;~ LONG  biYPelsPerMeter;     28
    ;~ DWORD biClrUsed;           32
    ;~ DWORD biClrImportant;      36
    
    bmi := &DIB  ;BITMAPINFOHEADER  pointer from DIB
    biSize := numget( bmi+0, 0, "UInt" )
    ;~ return bmi + biSize
    biSizeImage := numget( bmi+0, 20, "UInt" )
    biBitCount := numget( bmi+0, 14, "UShort" )
    if ( biSizeImage == 0 )
    {
      biWidth := numget( bmi+0, 4, "UInt" )
      biHeight := numget( bmi+0, 8, "UInt" )
      biSizeImage := (((( biWidth * biBitCount + 31 ) & ~31 ) >> 3 ) * biHeight )
      numput( biSizeImage, bmi+0, 20, "UInt" )
    }
    p := numget( bmi+0, 32, "UInt" )  ;biClrUsed
    if ( p == 0 && biBitCount <= 8 )
      p := 1 << biBitCount
    p := p * 4 + biSize + bmi
    return p
  }
  Gdip_Startup() {
    if !DllCall( "GetModuleHandleW", "Wstr", "gdiplus", "UPtr" )
          DllCall( "LoadLibraryW", "Wstr", "gdiplus", "UPtr" )
    
    VarSetCapacity(GdiplusStartupInput , 3*A_PtrSize, 0), NumPut(1,GdiplusStartupInput ,0,"UInt") ; GdiplusVersion = 1
    DllCall("gdiplus\GdiplusStartup", "Ptr*", pToken, "Ptr", &GdiplusStartupInput, "Ptr", 0)
    return pToken
  }
  Gdip_Shutdown(pToken) {
    DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
    if hModule := DllCall( "GetModuleHandleW", "Wstr", "gdiplus", "UPtr" )
      DllCall("FreeLibrary", "Ptr", hModule)
    return 0
  }
  StrSplit(str,delim,omit = "") {
    if (strlen(delim) > 1)
    {
      StringReplace,str,str,% delim,ƒ,1 		;■¶╬
      delim = ƒ
    }
    ra := Array()
    loop, parse,str,% delim,% omit
      if (A_LoopField != "")
        ra.Insert(A_LoopField)
    return ra
  }
  RemoveDubls( objArray ) {
    while True
    {
      nodubls := 1
      tempArr := Object()
      for i,val in objArray
      {
        if tempArr.haskey( val )
        {
          nodubls := 0
          objArray.Remove( i )
          break
        }
        tempArr[ val ] := 1
      }
      if nodubls
        break
    }
    return objArray
  }
  RegisterClipboardFormat( fmtName ) {
    return DllCall( "RegisterClipboardFormat", "ptr", &fmtName )
  }
  GetOpenClipboardWindow() {
    return DllCall( "GetOpenClipboardWindow" )
  }
  IsClipboardFormatAvailable( iFmt ) {
    return DllCall( "IsClipboardFormatAvailable", "UInt", iFmt )
  }
  GetImageEncodersSize( ByRef numEncoders, ByRef size ) {
    return DllCall( "gdiplus\GdipGetImageEncodersSize", "Uint*", numEncoders, "UInt*", size )
  }
  GetImageEncoders( numEncoders, size, pImageCodecInfo ) {
    return DllCall( "gdiplus\GdipGetImageEncoders", "Uint", numEncoders, "UInt", size, "Ptr", pImageCodecInfo )
  }
  GetEncoderClsid( format, ByRef CLSID ) {
    ;format should be the following
    ;~ bmp
    ;~ jpeg
    ;~ gif
    ;~ tiff
    ;~ png
    if !format
      return 0
    format := "image/" format
    this.GetImageEncodersSize( num, size )
    if ( size = 0 )
      return 0
    VarSetCapacity( ImageCodecInfo, size, 0 )
    this.GetImageEncoders( num, size, &ImageCodecInfo )
    loop,% num
    {
      pici := &ImageCodecInfo + ( 48+7*A_PtrSize )*(A_Index-1)
      pMime := NumGet( pici+0, 32+4*A_PtrSize, "UPtr" )
      MimeType := StrGet( pMime, "UTF-16")
      if ( MimeType = format )
      {
        VarSetCapacity( CLSID, 16, 0 )
        this.memcopy( &CLSID, pici, 16 )
        return 1
      }
    }
    return 0
  }
}