class WinClip_base
{
    __Call( aTarget, aParams* ) {
        if WinClip_base.HasOwnProp(aTarget)
            return WinClip_base[ aTarget ].Call( this, aParams* ) ;updated for AHKv2 compatibility
            ;return WinClip_base[ aTarget ].( this, aParams* )
        throw Exception( "Unknown function '" aTarget "' requested from object '" this.__Class "'", -1 )
    }
    
    Err( msg ) {
        throw Exception( this.__Class " : " msg ( A_LastError != 0 ? "`n" this.ErrorFormat( A_LastError ) : "" ), -2 )
    }
    
    ErrorFormat( error_id ) {
        VarSetStrCapacity(msg,1000)
        if !len := DllCall("FormatMessageW"
                    ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200      ;dwflags
                    ,"Ptr",0        ;lpSource
                    ,"UInt",error_id    ;dwMessageId
                    ,"UInt",0           ;dwLanguageId
                    ,"Ptr",StrPtr(msg)         ;lpBuffer
                    ,"UInt",500)            ;nSize
            return
        return  strget(StrPtr(msg),len)
    }
}

class WinClipAPI_base extends WinClip_base
{
    __Get( name ) {
        if !this.HasOwnProp(initialized)
            this.Init()
        else
            throw Exception( "Unknown field '" name "' requested from object '" this.__Class "'", -1 )
    }
}

class WinClipAPI extends WinClip_base
{
    static memcopy( dest, src, size ) {
        return DllCall( "msvcrt\memcpy", "ptr", dest, "ptr", src, "uint", size )
    }
    static GlobalSize( hObj ) {
        return DllCall( "GlobalSize", "Ptr", hObj )
    }
    static GlobalLock( hMem ) {
        return DllCall( "GlobalLock", "Ptr", hMem )
    }
    static GlobalUnlock( hMem ) {
        return DllCall( "GlobalUnlock", "Ptr", hMem )
    }
    static GlobalAlloc( flags, size ) {
        return DllCall( "GlobalAlloc", "Uint", flags, "Uint", size )
    }
    static OpenClipboard() {
        return DllCall( "OpenClipboard", "Ptr", 0 )
    }
    static CloseClipboard() {
        return DllCall( "CloseClipboard" )
    }
    static SetClipboardData( format, hMem ) {
        return DllCall( "SetClipboardData", "Uint", format, "Ptr", hMem )
    }
    static GetClipboardData( format ) {
        return DllCall( "GetClipboardData", "Uint", format ) 
    }
    static EmptyClipboard() {
        return DllCall( "EmptyClipboard" )
    }
    static EnumClipboardFormats( format ) {
        return DllCall( "EnumClipboardFormats", "UInt", format )
    }
    static CountClipboardFormats() {
        return DllCall( "CountClipboardFormats" )
    }
    static GetClipboardFormatName( iFormat ) {
        size := VarSetStrCapacity(bufName,510)
        ; size := VarSetStrCapacity(bufName,255*( A_IsUnicode ? 2 : 1 ))
        DllCall( "GetClipboardFormatName", "Uint", iFormat, "str", bufName, "Uint", size )
        return bufName
    }
    static GetEnhMetaFileBits( hemf, ByRef buf ) {
        if !( bufSize := DllCall( "GetEnhMetaFileBits", "Ptr", hemf, "Uint", 0, "Ptr", 0 ) )
            return 0
        VarSetStrCapacity(buf,bufSize)
        if !( bytesCopied := DllCall( "GetEnhMetaFileBits", "Ptr", hemf, "Uint", bufSize, "Ptr", StrPtr(buf) ) )
            return 0
        return bytesCopied
    }
    static SetEnhMetaFileBits( pBuf, bufSize ) {
        return DllCall( "SetEnhMetaFileBits", "Uint", bufSize, "Ptr", pBuf )
    }
    static DeleteEnhMetaFile( hemf ) {
        return DllCall( "DeleteEnhMetaFile", "Ptr", hemf )
    }
    static ErrorFormat(error_id) {
        VarSetStrCapacity(msg,1000)
        if !len := DllCall("FormatMessageW"
                    ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200      ;dwflags
                    ,"Ptr",0        ;lpSource
                    ,"UInt",error_id    ;dwMessageId
                    ,"UInt",0           ;dwLanguageId
                    ,"Ptr",StrPtr(msg)         ;lpBuffer
                    ,"UInt",500)            ;nSize
            return
        return  strget(StrPtr(msg),len)
    }
    static LoadDllFunction( file, function ) {
            if !hModule := DllCall( "GetModuleHandleW", "Wstr", file, "UPtr" )
                    hModule := DllCall( "LoadLibraryW", "Wstr", file, "UPtr" )
            
            ret := DllCall("GetProcAddress", "Ptr", hModule, "AStr", function, "UPtr")
            return ret
    }
    static SendMessage( hWnd, Msg, wParam, lParam ) {
         static SendMessageW

         If not SendMessageW
                SendMessageW := this.LoadDllFunction( "user32.dll", "SendMessageW" )

         ret := DllCall( SendMessageW, "UPtr", hWnd, "UInt", Msg, "UPtr", wParam, "UPtr", lParam )
         return ret
    }
    static GetWindowThreadProcessId( hwnd ) {
        return DllCall( "GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0 )
    }
    static WinGetFocus( hwnd ) {
        GUITHREADINFO_cbsize := 24 + A_PtrSize*6
        VarSetStrCapacity(GuiThreadInfo,GUITHREADINFO_cbsize)    ;GuiThreadInfoSize = 48
        NumPut(GUITHREADINFO_cbsize, GuiThreadInfo, 0, "UInt")
        threadWnd := this.GetWindowThreadProcessId( hwnd )
        if not DllCall( "GetGUIThreadInfo", "uint", threadWnd, "UPtr", StrPtr(GuiThreadInfo) )
                return 0
        return NumGet( GuiThreadInfo, 8+A_PtrSize,"UPtr")  ; Retrieve the hwndFocus field from the struct.
    }
    static GetPixelInfo( ByRef DIB ) {
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
        
        bmi := StrPtr(DIB)  ;BITMAPINFOHEADER  pointer from DIB
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
    static Gdip_Startup() {
        if !DllCall( "GetModuleHandleW", "Wstr", "gdiplus", "UPtr" )
                    DllCall( "LoadLibraryW", "Wstr", "gdiplus", "UPtr" )
        
        VarSetStrCapacity(GdiplusStartupInput,3*A_PtrSize), NumPut(1,GdiplusStartupInput ,0,"UInt") ; GdiplusVersion = 1
        pToken:=0 ;empty receiving var
        DllCall("gdiplus\GdiplusStartup", "Ptr*", pToken, "Ptr", StrPtr(GdiplusStartupInput), "Ptr", 0)
        return pToken
    }
    static Gdip_Shutdown(pToken) {
        DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
        if hModule := DllCall( "GetModuleHandleW", "Wstr", "gdiplus", "UPtr" )
            DllCall("FreeLibrary", "Ptr", hModule)
        return 0
    }
    static StrSplit(str,delim,omit := "") {
        if (strlen(delim) > 1)
        {
            ;StringReplace,str,str, delim,ƒ,1      ;■¶╬
            str := StrReplace(str, delim, "ƒ")
            delim := "ƒ"
        }
        ra := Array()
        Loop Parse str, delim, omit
            if (A_LoopField != "")
                ra.Insert(A_LoopField)
        return ra
    }
    static RemoveDubls( objArray ) {
        while True
        {
            nodubls := 1
            tempArr := Object()
            for i,val in objArray
            {
                if tempArr.HasOwnProp( val )
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
    static RegisterClipboardFormat( fmtName ) {
        return DllCall( "RegisterClipboardFormat", "ptr", StrPtr(fmtName) )
    }
    static GetOpenClipboardWindow() {
        return DllCall( "GetOpenClipboardWindow" )
    }
    static IsClipboardFormatAvailable( iFmt ) {
        return DllCall( "IsClipboardFormatAvailable", "UInt", iFmt )
    }
    static GetImageEncodersSize( ByRef numEncoders, ByRef size ) {
        return DllCall( "gdiplus\GdipGetImageEncodersSize", "Uint*", numEncoders, "UInt*", size )
    }
    static GetImageEncoders( numEncoders, size, pImageCodecInfo ) {
        return DllCall( "gdiplus\GdipGetImageEncoders", "Uint", numEncoders, "UInt", size, "Ptr", pImageCodecInfo )
    }
    static GetEncoderClsid( format, ByRef CLSID ) {
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
        VarSetStrCapacity(ImageCodecInfo,size)
        this.GetImageEncoders( num, size, StrPtr(ImageCodecInfo) )
        loop num
        {
            pici := StrPtr(ImageCodecInfo) + ( 48+7*A_PtrSize )*(A_Index-1)
            pMime := NumGet( pici+0, 32+4*A_PtrSize, "UPtr" )
            MimeType := StrGet( pMime, "UTF-16")
            if ( MimeType = format )
            {
                VarSetStrCapacity(CLSID,16)
                this.memcopy( StrPtr(CLSID), pici, 16 )
                return 1
            }
        }
        return 0
    }
}