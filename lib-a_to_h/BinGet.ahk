; ----------------------------------------------------------------------------------------------------------------------
; Name .........: BinGet library
; Description ..: This library is a collection of functions that return different kind of data from binary buffers.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 ANSI/Unicode
; Author .......: Cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Jan. 22, 2015 - v0.1   - First version.
; ..............: Jul. 30, 2015 - v0.1.1 - Added error management.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: BinGet_Bitmap
; Description ..: Create a bitmap from a binary buffer and return a handle to it.
; Parameters ...: adrBuf - Pointer to the binary data buffer containing the bitmap.
; ..............: szBuf  - Size of the buffer.
; Return .......: Handle to the bitmap on success, 0 on error.
; Code from ....: SKAN - http://goo.gl/iknYZB
; ----------------------------------------------------------------------------------------------------------------------
BinGet_Bitmap(adrBuf, szBuf)
{
    If ( hGlob := DllCall( "GlobalAlloc", UInt,2, UInt,szBuf, Ptr ) ) ; GMEM_MOVEABLE = 2
        pGlob := DllCall( "GlobalLock", Ptr,hGlob, Ptr )
      , DllCall( "RtlMoveMemory", Ptr,pGlob, Ptr,adrBuf, UInt,szBuf )
      , DllCall( "GlobalUnlock", Ptr,hGlob )
    Else Return 0, ErrorLevel := "GlobalAlloc: error allocating memory`nLast error = " A_LastError
    
    If ( ( e := DllCall( "ole32.dll\CreateStreamOnHGlobal", Ptr,hGlob, Int,1, PtrP,pStream ) ) != 0 )
        Return 0, ErrorLevel := "CreateStreamOnHGlobal: error creating stream`nReturn value = " e

    If ( hGdip := DllCall( "LoadLibrary", Str,"Gdiplus.dll" ) )
    {
        VarSetCapacity( si, 16, 0 ), NumPut( 1, si, "UChar" )
        If ( ( e := DllCall( "Gdiplus.dll\GdiplusStartup", PtrP,gdipToken, Ptr,&si, Ptr,0 ) ) == 0 )
            DllCall( "Gdiplus.dll\GdipCreateBitmapFromStream",  Ptr,pStream, PtrP,pBitmap )
          , DllCall( "Gdiplus.dll\GdipCreateHBITMAPFromBitmap", Ptr,pBitmap, PtrP,hBitmap, UInt,0 )
          , DllCall( "Gdiplus.dll\GdipDisposeImage", Ptr,pBitmap )
          , DllCall( "Gdiplus.dll\GdiplusShutdown", Ptr,gdipToken )
        Else Return 0, ErrorLevel := "GdiplusStartup: error starting Gdiplus`nReturn value = " e
        
        DllCall( "FreeLibrary", Ptr,hGdip )
    } Else Return 0, ErrorLevel := "LoadLibrary: error loading Gdiplus.dll`nLast error = " A_LastError
    
    ObjRelease(pStream)
    Return hBitmap ? hBitmap : 0
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: BinGet_Icon
; Description ..: Create an icon from a binary buffer and return a handle to it.
; Parameters ...: adrBuf     - Pointer to the binary data buffer containing the icon.
; ..............: nIconWidth - Width of the desired icon (used to retrieve the icon inside a multi-icon file).
; ..............: szBuf      - If the buffer contains raw, single icon data, we can specify its size and avoid data 
; ..............:              structure parsing. This can be useful when loading icon resources (type 3) from PE files.
; Return .......: Handle to the icon on success, 0 on error.
; Remarks ......: The function is based on the implicit structure of an icon file (.ico):
; ..............: ICONDIR structure:
; ..............: { sizeof(ICONDIR) = 6 + sizeof(ICONDIRENTRY) * n
; ..............:   Offset Type         Name           Description
; ..............:   00     WORD         idReserved     // Reserved (must be 0).
; ..............:   02     WORD         idType         // Resource type (1 for icons).
; ..............:   04     WORD         idCount        // How many images?
; ..............:   06     ICONDIRENTRY idEntries[n]   // The entries for each icon.
; ..............: }
; ..............: ICONDIRENTRY structure:
; ..............: { sizeof(ICONDIRENTRY) = 16
; ..............:   Offset Type         Name           Description
; ..............:   06     BYTE         bWidth;        // Width, in pixels, of the image.
; ..............:   07     BYTE         bHeight;       // Height, in pixels, of the image.
; ..............:   08     BYTE         bColorCount;   // Number of colors in image (0 if >=8bpp).
; ..............:   09     BYTE         bReserved;     // Reserved.
; ..............:   10     WORD         wPlanes;       // Color Planes.
; ..............:   12     WORD         BitCount;      // Bits per pixel.
; ..............:   14     DWORD        dwBytesInRes;  // How many bytes in this resource?
; ..............:   18     DWORD        dwImageOffset; // Where in the file is this image?
; ..............: }
; Info .........: CreateIconFromResourceEx function - https://goo.gl/Fij4ZA
; ----------------------------------------------------------------------------------------------------------------------
BinGet_Icon(adrBuf, nIconWidth, szBuf:=0)
{
    If ( !szBuf )
    {
        Loop % NumGet( adrBuf+0, 4, "UShort" )
        {
            nOfft := 6 + 16*(A_Index-1)
            If ( NumGet( adrBuf+0, nOfft, "UChar" ) == nIconWidth )
            {
                szBuf  := NumGet( adrBuf+0, nOfft+8,  "UInt" )
                adrBuf += NumGet( adrBuf+0, nOfft+12, "UInt" )
                Break
            }
        }
    }
    ; VERSION = 0x30000
    Return DllCall( "CreateIconFromResourceEx", Ptr,adrBuf, UInt,szBuf, Int,1, UInt,0x30000
                                              , Int,nIconWidth, Int,nIconWidth, UInt,0 )
}
