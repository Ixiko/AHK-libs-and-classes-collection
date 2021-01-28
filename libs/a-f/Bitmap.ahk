/*
    Crea un Bitmap a partir de las coordenadas y dimensiones dadas de la pantalla.
    Parámetros:
        Rect  : Un objeto con las claves X,Y,W,H que especifican la parte de la pantalla a recuperar.
        Width : El ancho, en unidades lógicas, del rectángulo fuente.
        Height: La altura, en unidades lógicas, del rectángulo fuente.
    Ejemplo:
        CoordMode('Mouse', 'Screen')

        Size    := {W: 128, H: 128}
        Size2   := {W: Size.W//2, H: Size.H//2}
        Gui     := GuiCreate('+ToolWindow +AlwaysOnTop +Resize')
        Pic     := Gui.AddPIC('x0 y0 w' . Size.W . ' h' . Size.H)
        Gui.Show('x0 y0 w' . Size.W . ' h' . Size.H)

        Loop
        {
            If (GetKeyState('Esc'))
                ExitApp

            MouseGetPos(X, Y)
            If ((X != X2 || Y != Y2) && IsObject(Pos := Gui.ClientPos))
                Pic.Value := 'HBITMAP:' . BitmapFromScreen({X: (X2:=X)-Size2.W, Y: (Y2:=Y)-Size2.H, W: Pos.W, H: Pos.H}), Pic.Move('w' . Pos.W . ' h' . Pos.H)
        }
*/
BitmapFromScreen(Rect := "", Width := '', Height := '')
{
    Local hDC, hCDC, hBitmap, hObject

    Rect := IsObject(Rect) ? Rect : {}
    Loop Parse, 'X|Y|W|H', '|'
        If (!ObjHasKey(Rect, A_LoopField))
            Rect[A_LoopField] := SysGet(75 + A_Index)

    hDC     := DllCall('User32.dll\GetDC', 'Ptr', 0, 'Ptr')
    hCDC    := DllCall('Gdi32.dll\CreateCompatibleDC', 'Ptr', hDC, 'Ptr')
    
    If (hBitmap := CreateDIBSection(hCDC, Rect))
    {
        If (hObject := DllCall('Gdi32.dll\SelectObject', 'Ptr', hCDC, 'Ptr', hBitmap, 'Ptr'))
        {
            If (!StretchBlt(hCDC, {W: Rect.W, H: Rect.H}, hDC, {X: Rect.X, Y: Rect.Y, W: Width, H: Height}))
                DllCall('Gdi32.dll\DeleteObject', 'Ptr', hBitmap), hBitmap := 0
            DllCall('Gdi32.dll\SelectObject', 'Ptr', hCDC, 'Ptr', hObject, 'Ptr')
        }
        Else
            DllCall('Gdi32.dll\DeleteObject', 'Ptr', hBitmap), hBitmap := 0
    }

    DllCall('Gdi32.dll\DeleteDC', 'Ptr', hCDC)
    DllCall('User32.dll\ReleaseDC', 'Ptr', 0, 'Ptr', hDC)

    Return (hBitmap)
} ;https://stackoverflow.com/questions/3291167/how-can-i-take-a-screenshot-in-a-windows-application




CreateDIBSection(hDC, pBITMAPINFO, Usage := 0, ByRef pBits := 0, hSection := 0, Offset := 0)
{
    If (IsObject(pBITMAPINFO))
    {
        NumPut(VarSetCapacity(BITMAPINFO, 40, 0), &BITMAPINFO, 'UInt')                                     ;biSize
        NumPut(pBITMAPINFO.W, &BITMAPINFO + 4, 'UInt')                                                     ;biWidth
        NumPut(pBITMAPINFO.H, &BITMAPINFO + 8, 'UInt')                                                     ;biHeight
        NumPut(ObjHasKey(pBITMAPINFO, 'Planes')   ? pBITMAPINFO.Planes   : 1 , &BITMAPINFO + 12, 'UShort') ;biPlanes
        NumPut(ObjHasKey(pBITMAPINFO, 'BitCount') ? pBITMAPINFO.BitCount : 32, &BITMAPINFO + 14, 'UShort') ;biBitCount
        pBITMAPINFO := &BITMAPINFO
    }

    Return (DllCall('Gdi32.dll\CreateDIBSection', 'Ptr' , hCDC        ;hdc
                                                , 'UPtr', pBITMAPINFO ;pbmi
                                                , 'UInt', Usage       ;iUsage
                                                , 'PtrP', pBits       ;ppvBits
                                                , 'Ptr' , hSection    ;hSection
                                                , 'UInt', Offset      ;dwOffset
                                                , 'Ptr'))             ;ReturnType (DIB HANDLE)
} ;https://msdn.microsoft.com/en-us/library/dd183494(v=vs.85).aspx




StretchBlt(hDCDest, RectDest, hDCSrc, RectSrc, Raster := 0xCC0020)
{
    If (ObjHasKey(RectSrc, 'W') && ObjHasKey(RectSrc, 'H'))
        Return (DllCall('Gdi32.dll\StretchBlt', 'Ptr', hDCDest                                   ;hdcDest
                                              , 'Int', ObjHasKey(RectDest, 'X') ? RectDest.X : 0 ;nXOriginDest
                                              , 'Int', ObjHasKey(RectDest, 'Y') ? RectDest.Y : 0 ;nYOriginDest
                                              , 'Int', RectDest.W                                ;nWidthDest
                                              , 'Int', RectDest.H                                ;nHeightDest
                                              , 'Ptr', hDCSrc                                    ;hdcSrc
                                              , 'Int', ObjHasKey(RectSrc, 'X')  ? RectSrc.X  : 0 ;nXOriginSrc
                                              , 'Int', ObjHasKey(RectSrc, 'Y')  ? RectSrc.Y  : 0 ;nYOriginSrc
                                              , 'Int', RectSrc.H == '' ? RectDest.H : RectSrc.H  ;nWidthSrc
                                              , 'Int', RectSrc.H == '' ? RectDest.H : RectSrc.H  ;nHeightSrc
                                              , 'UInt', Raster))                                 ;dwRop

    Return (DllCall('Gdi32.dll\BitBlt', 'Ptr', hDCDest                                             ;hdcDest
                                      , 'Int', ObjHasKey(RectDest, 'X') ? RectDest.X : 0          ;nXOriginDest
                                      , 'Int', ObjHasKey(RectDest, 'Y') ? RectDest.Y : 0          ;nYOriginDest
                                      , 'Int', RectDest.W                                         ;nWidthDest
                                      , 'Int', RectDest.H                                         ;nHeightDest
                                      , 'Ptr', hDCSrc                                             ;hdcSrc
                                      , 'Int', ObjHasKey(RectSrc, 'X')  ? RectSrc.X  : 0          ;nXOriginSrc
                                      , 'Int', ObjHasKey(RectSrc, 'Y')  ? RectSrc.Y  : 0          ;nYOriginSrc
                                      , 'UInt', Raster))                                          ;dwRop
} ;https://msdn.microsoft.com/en-us/library/dd145120(v=vs.85).aspx




SetStretchBltMode(hDC, StretchMode)
{
    Return (DllCall('Gdi32.dll\SetStretchBltMode', 'Ptr', hDC, 'Int', StretchMode))
}




/*
    Recupera un Bitmap desde el portapapeles, si lo hay.
    Return:
        Si tuvo éxito devuelve el identificador del Bitmap.
    Ejemplo:
        SendInput('{PrintScreen}'), ClipWait(2, 1)
        Gui := GuiCreate()
        Gui.AddPIC('x0 y0', 'HBITMAP:' . BitmapFromClipboard())
        Gui.Show()
*/
BitmapFromClipboard()
{
    If (!DllCall('User32.dll\IsClipboardFormatAvailable', 'UInt', 8))
        Return (0)

    If (!DllCall('User32.dll\OpenClipboard', 'Ptr', A_ScriptHwnd))
        Return (0)
    
    Local hBitmap := DllCall('User32.dll\GetClipboardData', 'UInt', 2, 'Ptr')
    DllCall('User32.dll\CloseClipboard')

    Return (hBitmap)
}




/*
    Copia un Bitmap en el portapapeles.
    Parámetros:
        hBitmap: El identificador del Bitmap.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Ejemplo:
        MsgBox(BitmapToClipboard(LoadPicture(FileSelect(), 'GDI+')))
*/
BitmapToClipboard(hBitmap)
{
    ; DIBSECTION structure
    ; https://msdn.microsoft.com/en-us/library/dd183567(v=vs.85).aspx
    Local DIBSECTION
        , DIBSECTION_Size := A_PtrSize == 4 ? 84 : 104 ;sizeof(DIBSECTION)

    ; Retrieves information for the specified bitmap.
    ; https://msdn.microsoft.com/en-us/library/dd144904(v=vs.85).aspx
    VarSetCapacity(DIBSECTION, DIBSECTION_Size, 0)
    If (!DllCall('Gdi32.dll\GetObjectW', 'Ptr' , hBitmap         ;hgdiobj    --> HBITMAP
                                       , 'Int' , DIBSECTION_Size ;cbBuffer   --> sizeof(DIBSECTION)
                                       , 'UPtr', &DIBSECTION     ;lpvObject  --> DIBSECTION
                                       , 'UInt'))                ;ReturnType
        Return (FALSE)

    ; DIBSECTION structure
    ; https://msdn.microsoft.com/en-us/library/dd183567(v=vs.85).aspx 

    ; BITMAP structure
    ; https://msdn.microsoft.com/en-us/library/dd183371(v=vs.85).aspx
    Local pBits := NumGet(&DIBSECTION + (A_PtrSize == 4 ? 20 : 24)) ;DIBSECTION.BITMAP.bmBits

    ; BITMAPINFOHEADER structure
    ; https://msdn.microsoft.com/en-us/library/dd183376(v=vs.85).aspx
    Local BITMAPINFOHEADER_Size := 40 ;sizeof(BITMAPINFOHEADER) --> BITMAPINFOHEADER.biSize
        , SizeImage := NumGet(&DIBSECTION + (A_PtrSize == 4 ? 44 : 52), 'UInt') ;DIBSECTION.BITMAPINFOHEADER.biSizeImage
    If (!SizeImage)
        Return (FALSE)

    ; -
    Local Mem_Size := BITMAPINFOHEADER_Size + SizeImage
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366574(v=vs.85).aspx
        , hMem     := DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x2, 'UPtr', Mem_Size, 'Ptr') ;GMEM_MOVEABLE
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366584(v=vs.85).aspx
        , pMem     := DllCall('Kernel32.dll\GlobalLock', 'Ptr', hMem, 'UPtr')
    
    ; https://msdn.microsoft.com/es-ar/library/wes2t00f.aspx
    DllCall('msvcrt.dll\memcpy_s', 'UPtr', pMem                                   ;dest       --> pMem
                                 , 'UPtr', Mem_Size                               ;destSize   --> sizeof(pMem)
                                 , 'UPtr', &DIBSECTION + 24 + (A_PtrSize - 4) * 2 ;src        --> DIBSECTION.BITMAPINFOHEADER
                                 , 'UPtr', BITMAPINFOHEADER_Size                  ;count      --> sizeof(BITMAPINFOHEADER)
                                 , 'Cdecl')                                       ;ReturnType

    DllCall('msvcrt.dll\memcpy_s', 'UPtr', pMem + BITMAPINFOHEADER_Size ;dest       --> pMem + sizeof(BITMAPINFOHEADER)
                                 , 'UPtr', Mem_Size                     ;destSize   --> sizeof(pMem)
                                 , 'UPtr', pBits                        ;src        --> DIBSECTION.BITMAP.bmBits
                                 , 'UPtr', SizeImage                    ;count      --> DIBSECTION.BITMAPINFOHEADER.biSizeImage
                                 , 'Cdecl')                             ;ReturnType

    ; Decrements the lock count associated with a memory object that was allocated with GMEM_MOVEABLE. 
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366595(v=vs.85).aspx
    DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', hMem)

    ; Opens the clipboard for examination and prevents other applications from modifying the clipboard content.
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms649048(v=vs.85).aspx
    If (DllCall('User32.dll\OpenClipboard', 'Ptr', A_ScriptHwnd))
    {
        ; Empties the clipboard and frees handles to data in the clipboard.
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms649037(v=vs.85).aspx
        DllCall('User32.dll\EmptyClipboard')

        ; Places data on the clipboard in a specified clipboard format. 
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms649051(v=vs.85).aspx
        If (DllCall('User32.dll\SetClipboardData', 'UInt', 8   ;uFormat    --> CF_DIB (a memory object containing a BITMAPINFO structure followed by the bitmap bits)
                                                 , 'Ptr', hMem ;hMem
                                                 , 'Ptr'))     ;ReturnType --> HANDLE (if the function succeeds, the return value is the handle to the data)
            ; If SetClipboardData succeeds, the system owns the object identified by the hMem parameter.
            ; The application may not write to or free the data once ownership has been transferred to the system.
        {
            ; Closes the clipboard.
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms649035(v=vs.85).aspx
            DllCall('User32.dll\CloseClipboard')    
            Return (TRUE)
        }

        DllCall('User32.dll\CloseClipboard')
    }

    ; ERROR! free hMem
    DllCall('Kernel32.dll\GlobalFree', 'Ptr', hMem, 'Ptr')
    Return (FALSE)
}
