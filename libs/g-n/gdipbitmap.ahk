; GDIplus library cooked down from the Gdip standard library
; originally from tiq, maintained by Marius Sucan:
; https://github.com/marius-sucan/AHK-GDIp-Library-Compilation
; Thank you all!

gdipbitmap_from_area(x, y, w, h, Raster:="") {
    ; Get bitmap from area defined by string separated by delimiter (default is pipe: "|")
    ; x: top-left-x position
    ; y: top-left-y positoon
    ; w: width
    ; h: height
    ; Raster: raster operation code. See BitBlt function doc.
    hhdc := 0
    Static Ptr := "UPtr"

    chdc := CreateCompatibleDC()
    hbm := CreateDIBSection(w, h, chdc)
    obm := SelectObject(chdc, hbm)
    hhdc := GetDC()

    BitBlt(chdc, 0, 0, w, h, hhdc, x, y, Raster)
    ReleaseDC(hhdc)

    pBitmap := gdipbitmap_from_HBITMAP(hbm)
    SelectObject(chdc, obm)
    DeleteObject(hbm)
    DeleteDC(hhdc)
    DeleteDC(chdc)
    return pBitmap
}

gdipbitmap_from_coords_string(coords, delimiter:="|", Raster:="") {
    ; Get bitmap from area defined by string separated by delimiter (default is pipe: "|")
    ; For example: "100|100|320|240"
    ; Where the fields are top-left-x|top-left-y|width|height.
    arr := StrSplit(coords, delimiter)
    return gdipbitmap_from_area(arr[1], arr[2], arr[3], arr[4], Raster)
}

gdipbitmap_from_screens(Raster:="") {
    ; Get a bitmap from all available screens.
    ; may contain blank areas when screens have different sizes.
    screen_get_virtual_size(x, y, w, h)
    return gdipbitmap_from_area(x, y, w, h, Raster)
}

gdipbitmap_from_screen(screen_number:=1, Raster:="") {
    ; Get a bitmap from a given monitor or screen number.
    M := GetMonitorInfo(screen_number)
    x := M.Left, y := M.Top
    w := M.Right-M.Left, h := M.Bottom-M.Top
    return gdipbitmap_from_area(x, y, w, h, Raster)
}

gdipbitmap_from_handle(hwnd) {
    ; Get the area of a given handle, make sure its visible and
    ; shoot a bitmap from that area.
    window_activate(hwnd)
    geometry := window_get_geometry(hwnd)
    return gdipbitmap_from_area(geometry.x, geometry.y, geometry.w, geometry.h)
}

gdipbitmap_from_HBITMAP(hBitmap, Palette:=0) {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
        pBitmap := 0
        DllCall("gdiplus\GdipCreateBitmapFromHBITMAP"
        , Ptr, hBitmap
        , Ptr, Palette
    , A_PtrSize ? "UPtr*" : "uint*"
        , pBitmap)
    return pBitmap
}

gdipbitmap_to_HBITMAP(pBitmap, Background:=0xffffffff) {
    ; background should be zero, to not alter alpha channel of the image
    hBitmap := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap"
    , "UPtr", pBitmap
    , "UPtr*", hBitmap
    , "int", Background)
    return hBitmap
}

gdipbitmap_to_file(pBitmap, sOutput, Quality:=75) {
    ; Save a bitmap to a file in any supported format onto disk.
    ;
    ; pBitmap   Pointer to a bitmap
    ; sOutput   Name of the file that the bitmap will be saved to. Supported extensions are:
    ;           .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG.
    ; Quality   If saving as jpg (.JPG,.JPEG,.JPE,.JFIF) then quality can be
    ;           1-100 with default at maximum quality.
    ;
    ; return    If the function succeeds, the return value is zero, otherwise:
    ;		    -1 = Extension supplied is not a supported file format
    ;		    -2 = Could not get a list of encoders on system
    ;		    -3 = Could not find matching encoder for specified file format
    ;		    -4 = Could not get WideChar name of output file
    ;		    -5 = Could not save file to disk
    ;
    ; notes	    This function will use the extension supplied from the sOutput
    ;           parameter to determine the output format.
    Ptr := A_PtrSize ? "UPtr" : "UInt" ;
    nCount := 0
    nSize := 0
    _p := 0

    SplitPath sOutput,,, Extension
    re := "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$"
    if !RegExMatch(Extension, re)
        return -1

    Extension := "." Extension

    DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
    VarSetCapacity(ci, nSize)
    DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
    if !(nCount && nSize)
        return -2 ;

    If (A_IsUnicode) {
        StrGet_Name := "StrGet"

        N := (A_AhkVersion < 2) ? nCount : "nCount" ;
        Loop %N%
        {
            sString := %StrGet_Name%(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
            if !InStr(sString, "*" Extension)
                continue

            pCodec := &ci+idx
            break
        }
    } else {
        N := (A_AhkVersion < 2) ? nCount : "nCount"
        Loop %N%
        {
            Location := NumGet(ci, 76*(A_Index-1)+44)
            nSize := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "uint", 0, "int", 0, "uint", 0, "uint", 0)
            VarSetCapacity(sString, nSize)
            DllCall("WideCharToMultiByte", "uint", 0, "uint", 0, "uint", Location, "int", -1, "str", sString, "int", nSize, "uint", 0, "uint", 0)
            if !InStr(sString, "*" Extension)
                continue

            pCodec := &ci+76*(A_Index-1)
            break
        }
    }

    if !pCodec
        return -3

    if (Quality != 75) {
        Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
        if RegExMatch(Extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$") {
            DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
            VarSetCapacity(EncoderParameters, nSize, 0)
            DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr
            , pCodec, "uint", nSize, Ptr, &EncoderParameters)
            nCount := NumGet(EncoderParameters, "UInt")
            N := (A_AhkVersion < 2) ? nCount : "nCount"
            Loop %N%
            {
                elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
                if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
                {
                    _p := elem+&EncoderParameters-pad-4
                    NumPut(Quality, NumGet(NumPut(4, NumPut(1, _p+0)+20, "UInt")), "UInt")
                    break
                }
            }
        }
    }

    if (!A_IsUnicode)
    {
        nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, 0, "int", 0)
        VarSetCapacity(wOutput, nSize*2)
        DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, &wOutput, "int", nSize)
        VarSetCapacity(wOutput, -1)
        if !VarSetCapacity(wOutput)
           return -4
        _E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &wOutput, Ptr, pCodec, "uint", _p ? _p : 0)
    }
    else
        _E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &sOutput, Ptr, pCodec, "uint", _p ? _p : 0)

    return _E ? -5 : 0
}

gdipbitmap_set_clipboard(pBitmap) {
    ; Put a given bitmap to the clipboard.
    ; modified by Marius Șucan to have this function report errors
    Static Ptr := "UPtr"
    off1 := A_PtrSize = 8 ? 52 : 44
    off2 := A_PtrSize = 8 ? 32 : 24

    pid := DllCall("GetCurrentProcessId","uint")
    hwnd := WinExist("ahk_pid " . pid)
    r1 := DllCall("OpenClipboard", Ptr, hwnd)
    If !r1
        Return -1

    hBitmap := gdipbitmap_to_HBITMAP(pBitmap, 0)
    If !hBitmap {
        DllCall("CloseClipboard")
        Return -3
    }

    r2 := DllCall("EmptyClipboard")
    If !r2 {
        DeleteObject(hBitmap)
        DllCall("CloseClipboard")
        Return -2
    }

    DllCall("GetObject"
    , Ptr, hBitmap, "int"
    , VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0)
    , Ptr, &oi)
    hdib := DllCall("GlobalAlloc", "uint", 2, Ptr
    , 40+NumGet(oi, off1, "UInt"), Ptr)
    pdib := DllCall("GlobalLock", Ptr, hdib, Ptr)

    DllCall("RtlMoveMemory", Ptr, pdib, Ptr, &oi+off2, Ptr, 40)
    DllCall("RtlMoveMemory", Ptr, pdib+40, Ptr
    , NumGet(oi, off2 - A_PtrSize, Ptr), Ptr
    , NumGet(oi, off1, "UInt"))
    DllCall("GlobalUnlock", Ptr, hdib)

    DeleteObject(hBitmap)
    r3 := DllCall("SetClipboardData", "uint", 8, Ptr, hdib) ; CF_DIB = 8
    DllCall("CloseClipboard")
    DllCall("GlobalFree", Ptr, hdib)
    E := r3 ? 0 : -4 ; 0 - success
    Return E
}

gdipbitmap_from_clipboard() {
    ; Try to get bitmap data from the clipboard.
    ; modified by Marius Șucan

    Static Ptr := "UPtr"
    pid := DllCall("GetCurrentProcessId","uint")
    hwnd := WinExist("ahk_pid " . pid)
    ; CF_DIB = 8
    if !DllCall("IsClipboardFormatAvailable", "uint", 8) {
        ; CF_BITMAP = 2
        if DllCall("IsClipboardFormatAvailable", "uint", 2) {
            if !DllCall("OpenClipboard", Ptr, hwnd) {
                return -1
            }

            hData := DllCall("User32.dll\GetClipboardData", "UInt", 0x0002, "UPtr")
            hBitmap := DllCall("User32.dll\CopyImage", "UPtr", hData, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2004, "Ptr")
            DllCall("CloseClipboard")
            pBitmap := gdipbitmap_from_HBITMAP(hBitmap)
            DeleteObject(hBitmap)
            return pBitmap
        }
        return -2
    }

    if !DllCall("OpenClipboard", Ptr, hwnd)
        return -1

    hBitmap := DllCall("GetClipboardData", "uint", 2, Ptr)
    if !hBitmap {
        DllCall("CloseClipboard")
        return -3
    }

    DllCall("CloseClipboard")
    If hBitmap
    {
        ; This function can return a completely empty/transparent bitmap
        pBitmap := gdipbitmap_CreateARGBFromHBITMAP(hBitmap)
        If pBitmap
            isUniform := gdipbitmap_TestUniformity(pBitmap, 7, maxLevelIndex)

        If (pBitmap && isUniform=1 && maxLevelIndex<=2)
        {
            gdip_disposeimage(pBitmap)
            pBitmap := gdipbitmap_from_HBITMAP(hBitmap)
        }
        DeleteObject(hBitmap)
    }

    if !pBitmap
        return -4

    return pBitmap
}

gdipbitmap_TestUniformity(pBitmap, HistogramFormat:=3, ByRef maxLevelIndex:=0, ByRef maxLevelPixels:=0) {
    ; Tests if the given pBitmap is in a single shade [color] or not.
    ;
    ; If HistogramFormat parameter is set to 3, the function
    ; retrieves the intensity/gray histogram and checks
    ; how many pixels are for each level [0, 255].
    ;
    ; If all pixels are found at a single level,
    ; the return value is 1, because the pBitmap is considered
    ; uniform, in a single shade.
    ;
    ; One can set the HistogramFormat to 4 [R], 5 [G], 6 [B] or 7 [A]
    ; to test for the uniformity of a specific channel.
    ;
    ; A threshold value of 0.0005% of all the pixels, is used.
    ; This is to ensure that a few pixels do not change the status.
    LevelsArray := []
    maxLevelIndex := maxLevelPixels := nrPixels := 9
    gdipbitmap_get_dimensions(pBitmap, Width, Height)
    gdip_get_histogram(pBitmap, HistogramFormat, LevelsArray, 0, 0)
    Loop 256
    {
        nrPixels := Round(LevelsArray[A_Index - 1])
        If (nrPixels>0)
            histoList .= nrPixels "." A_Index - 1 "|"
    }
    Sort histoList, NURD|
    histoList := Trim(histoList, "|")
    histoListSortedArray := StrSplit(histoList, "|")
    maxLevel := StrSplit(histoListSortedArray[1], ".")
    maxLevelIndex := maxLevel[2]
    maxLevelPixels := maxLevel[1]
    ; ToolTip, % maxLevelIndex " -- " maxLevelPixels " | " histoListSortedArray[1] "`n" histoList, , , 3
    pixelsThreshold := Round((Width * Height) * 0.0005) + 1
    If (Floor(histoListSortedArray[2])<pixelsThreshold)
        Return 1
    Else
        Return 0
}

gdipbitmap_CreateARGBFromHBITMAP(hImage) {
    ; Create bitmap with transparency. By iseahound found on:
    ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63345
    ; part of https://github.com/iseahound/Graphics/blob/master/lib/Graphics.ahk

    ; struct BITMAP - https://docs.microsoft.com/en-us/windows/desktop/api/wingdi/ns-wingdi-tagbitmap
    DllCall("GetObject"
    , "ptr", hImage
    , "int", VarSetCapacity(dib, 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize)
    , "ptr", &dib) ; sizeof(DIBSECTION) = x86:84, x64:104
    width := NumGet(dib, 4, "uint")
    height := NumGet(dib, 8, "uint")
    bpp := NumGet(dib, 18, "ushort")

    ; Fallback to built-in method if pixels are not ARGB.
    if (bpp!=32)
        return gdipbitmap_from_HBITMAP(hImage)

    ; Create a handle to a device context and associate the hImage.
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hImage)

    ; Buffer the hImage with a top-down device independent bitmap via negative height.
    ; Note that a DIB is an hBitmap, pixels are formatted as pARGB, and has a pointer to the bits.
    cdc := CreateCompatibleDC(hdc)
    hbm := CreateDIBSection(width, -height, hdc, 32, pBits)
    ob2 := SelectObject(cdc, hbm)

    ; Create a new Bitmap (different from an hBitmap) which holds ARGB pixel values.
    pBitmap := gdipbitmap_create(width, height)

    ; Create a Scan0 buffer pointing to pBits. The buffer has pixel format pARGB.
    CreateRect(Rect, 0, 0, width, height)
    VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)
    , NumPut( width, BitmapData, 0, "uint") ; Width
    , NumPut( height, BitmapData, 4, "uint") ; Height
    , NumPut( 4 * width, BitmapData, 8, "int") ; Stride
    , NumPut( 0xE200B, BitmapData, 12, "int") ; PixelFormat
    , NumPut( pBits, BitmapData, 16, "ptr") ; Scan0
    DllCall("gdiplus\GdipBitmapLockBits"
    , "ptr", pBitmap
    , "ptr", &Rect
    , "uint", 6 ; ImageLockMode.UserInputBuffer | ImageLockMode.WriteOnly
    , "int", 0xE200B ; Format32bppPArgb
    , "ptr", &BitmapData)

    ; Ensure that our hBitmap (hImage) is top-down by copying it to a top-down bitmap.
    BitBlt(cdc, 0, 0, width, height, hdc, 0, 0)

    ; Convert the pARGB pixels copied into the device independent bitmap (hbm) to ARGB.
    DllCall("gdiplus\GdipBitmapUnlockBits", "ptr",pBitmap, "ptr",&BitmapData)

    ; Cleanup the buffer and device contexts.
    SelectObject(cdc, ob2)
    DeleteObject(hbm)
    DeleteDC(cdc)
    SelectObject(hdc, obm)
    DeleteDC(hdc)

    return pBitmap
}

gdip_get_histogram(pBitmap, whichFormat, ByRef newArrayA, ByRef newArrayB, ByRef newArrayC) {
    ; by swagfag in July 2019
    ; source https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62550
    ; modified by Marius Șucan
    ; whichFormat = 2;  histogram for each channel: R, G, B
    ; whichFormat = 3;  histogram of the luminance/brightness of the image
    ; Return: Status enumerated return type; 0 = OK/Success
    Static sizeofUInt := 4

    ; HistogramFormats := {ARGB: 0, PARGB: 1, RGB: 2, Gray: 3, B: 4, G: 5, R: 6, A: 7}
    z := DllCall("gdiplus\GdipBitmapGetHistogramSize", "UInt", whichFormat, "UInt*", numEntries)

    newArrayA := [], newArrayB := [], newArrayC := []
    VarSetCapacity(ch0, numEntries * sizeofUInt, 0)
    VarSetCapacity(ch1, numEntries * sizeofUInt, 0)
    VarSetCapacity(ch2, numEntries * sizeofUInt, 0)
    If (whichFormat=2)
        r := DllCall("gdiplus\GdipBitmapGetHistogram", "Ptr", pBitmap, "UInt", whichFormat, "UInt", numEntries, "Ptr", &ch0, "Ptr", &ch1, "Ptr", &ch2, "Ptr", 0)
    Else If (whichFormat>2)
        r := DllCall("gdiplus\GdipBitmapGetHistogram", "Ptr", pBitmap, "UInt", whichFormat, "UInt", numEntries, "Ptr", &ch0, "Ptr", 0, "Ptr", 0, "Ptr", 0)

    Loop %numEntries%
    {
        i := A_Index - 1
        r := NumGet(&ch0+0, i * sizeofUInt, "UInt")
        newArrayA[i] := r

        If (whichFormat=2) {
            g := NumGet(&ch1+0, i * sizeofUInt, "UInt")
            b := NumGet(&ch2+0, i * sizeofUInt, "UInt")
            newArrayB[i] := g
            newArrayC[i] := b
        }
    }
    Return r
}

gdipbitmap_get_dimensions(pBitmap, ByRef Width, ByRef Height) {
    ; Give the width and height of a bitmap
    ;
    ; pBitmap            Pointer to a bitmap
    ; Width              ByRef variable. This variable will be set to the width of the bitmap
    ; Height             ByRef variable. This variable will be set to the height of the bitmap
    ;
    ; return             GDI+ status enumeration return value
    If StrLen(pBitmap) < 3
        Return -1

    Width := 0, Height := 0
    E := gdip_get_image_dimension(pBitmap, Width, Height)
    Width := Round(Width)
    Height := Round(Height)
    return E
}

gdip_get_image_dimension(pBitmap, ByRef w, ByRef h) {
    Static Ptr := "UPtr"
    return DllCall("gdiplus\GdipGetImageDimension", Ptr, pBitmap, "float*", w, "float*", h)
}

gdipbitmap_create(Width, Height, PixelFormat:=0, Stride:=0, Scan0:=0) {
    ; Create a new 32-ARGB bitmap.
    ; modified by Marius Șucan
    pBitmap := 0
    If !PixelFormat
        PixelFormat := 0x26200A ; 32-ARGB

    DllCall("gdiplus\GdipCreateBitmapFromScan0"
    , "int", Width
    , "int", Height
    , "int", Stride
    , "int", PixelFormat
    , "UPtr", Scan0
    , "UPtr*", pBitmap)
    Return pBitmap
}

CreateCompatibleDC(hdc:=0) {
    ; Create a memory device context (DC) compatible with the specified device.
    ;
    ; If this handle is 0 (by default), the function creates a memory device context
    ; compatible with the application's current screen.
    ; hdc		Handle to an existing device context.
    ; return	Handle to a device context or 0 on failure.
    return DllCall("CreateCompatibleDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}

SelectObject(hdc, hgdiobj) {
    ; Select object into the specified device context (DC).
    ; The new object replaces the previous object of the same type.
    ;
    ; hdc       Handle to a DC
    ; hgdiobj   A handle to the object to be selected into the DC
    ;
    ; return    If the selected object is not a region and the function succeeds,
    ;           the return value is a handle to the object being replaced.
    ;
    ; notes     The specified object must have been created by using one of the following functions
    ;           Bitmap - CreateBitmap, CreateBitmapIndirect, CreateCompatibleBitmap, CreateDIBitmap,
    ;           CreateDIBSection (A single bitmap cannot be selected into more than one DC at the
    ;           same time)
    ;           Brush - CreateBrushIndirect, CreateDIBPatternBrush, CreateDIBPatternBrushPt,
    ;           CreateHatchBrush, CreatePatternBrush, CreateSolidBrush
    ;           Font - CreateFont, CreateFontIndirect
    ;           Pen - CreatePen, CreatePenIndirect
    ;           Region - CombineRgn, CreateEllipticRgn, CreateEllipticRgnIndirect, CreatePolygonRgn,
    ;           CreateRectRgn, CreateRectRgnIndirect
    ;
    ; notes     If the selected object is a region and the function succeeds,
    ;           the return value is one of the following value.
    ;
    ; NULLREGION    = 1 Region is empty
    ; SIMPLEREGION  = 2 Region consists of a single rectangle
    ; COMPLEXREGION = 3 Region consists of more than one rectangle
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    return DllCall("SelectObject", Ptr, hdc, Ptr, hgdiobj)
}

DeleteObject(hObject) {
    ; Delete logical pen, brush, font, bitmap, region, or palette, freeing all system resources
    ; associated with the object.
    ; After the object is deleted, the specified handle is no longer valid.
    ;
    ; hObject   Handle to a logical pen, brush, font, bitmap, region, or palette to delete.
    ;
    ; return    Nonzero indicates success. Zero indicates that the specified handle is not valid
    ; or that the handle is currently selected into a device context.
    return DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hObject)
}

GetDC(hwnd:=0) {
    ; Retrieve handle to a display device context (DC) for the client area of the specified window.
    ; The display device context can be used in subsequent graphics display interface (GDI)
    ; functions to draw in the client area of the window.
    ;
    ; hwnd	  Handle to the window whose device context is to be retrieved. If this value is NULL,
    ;         GetDC retrieves the device context for the entire screen.
    ;
    ; return  The handle the device context for the specified window's client area indicates
    ;         success. NULL indicates failure.
    return DllCall("GetDC", A_PtrSize ? "UPtr" : "UInt", hwnd)
}

GetDCEx(hwnd, flags:=0, hrgnClip:=0) {
    ; DCX_CACHE = 0x2
    ; DCX_CLIPCHILDREN = 0x8
    ; DCX_CLIPSIBLINGS = 0x10
    ; DCX_EXCLUDERGN = 0x40
    ; DCX_EXCLUDEUPDATE = 0x100
    ; DCX_INTERSECTRGN = 0x80
    ; DCX_INTERSECTUPDATE = 0x200
    ; DCX_LOCKWINDOWUPDATE = 0x400
    ; DCX_NORECOMPUTE = 0x100000
    ; DCX_NORESETATTRS = 0x4
    ; DCX_PARENTCLIP = 0x20
    ; DCX_VALIDATE = 0x200000
    ; DCX_WINDOW = 0x1
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    return DllCall("GetDCEx", Ptr, hwnd, Ptr, hrgnClip, "int", flags)
}

ReleaseDC(hdc, hwnd:=0) {
    ; Release device context (DC), freeing it for use by other applications.
    ;
    ; The effect of ReleaseDC depends on the type of device context.
    ; The application must call the ReleaseDC function for each call to the
    ; GetWindowDC function and for each call to the GetDC function that
    ; retrieves a common device context. An application cannot use the ReleaseDC
    ; function to release a device context that was created by calling the
    ; CreateDC function; instead, it must use the DeleteDC function.
    ;
    ; hdc		Handle to the device context to be released.
    ; hwnd		Handle to the window whose device context is to be released.
    ;
    ; return	1 = released
    ;			0 = not released
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    return DllCall("ReleaseDC", Ptr, hwnd, Ptr, hdc)
}

DeleteDC(hdc) {
    ; Deletes the specified device context (DC)
    ;
    ; An application must not delete a DC whose handle was obtained by calling
    ; the GetDC function. Instead, it must call the ReleaseDC function to free the DC.
    ;
    ; hdc		A handle to the device context.
    ;
    ; return	If the function succeeds, the return value is nonzero.
    return DllCall("DeleteDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}

GetMonitorInfo(MonitorNum) {
    Monitors := MDMF_Enum()
    for k,v in Monitors
        if (v.Num = MonitorNum)
    return v
}

CreateRect(ByRef name, x, y, w, h) {
    ; Create a Rect object, containing a coordinates & dimensions of a rectangle
    ;
    ; name	    Name to call the RectF object
    ; x			x-coordinate of the upper left corner of the rectangle
    ; y			y-coordinate of the upper left corner of the rectangle
    ; w			Width of the rectangle
    ; h			Height of the rectangle
    ; return	No return value
    VarSetCapacity(name, 16)
    NumPut(x, name, 0, "uint")
    NumPut(y, name, 4, "uint")
    NumPut(w, name, 8, "uint")
    NumPut(h, name, 12, "uint")
}

CreateDIBSection(w, h, hdc:="", bpp:=32, ByRef ppvBits:=0) {
    ; Create a DIB (Device Independent Bitmap) that applications can write to directly.
    ;
    ; w			width of the bitmap to create
    ; h			height of the bitmap to create
    ; hdc		a handle to the device context to use the palette from
    ; bpp		bits per pixel (32 = ARGB)
    ; ppvBits	A pointer to a variable that receives a pointer to the location of
    ;           the DIB bit values. ppvBits will receive the location of pixels in the DIB.
    ; return	DIB. A gdi bitmap.
    Ptr := A_PtrSize ? "UPtr" : "UInt" ;

    hdc2 := hdc ? hdc : GetDC()
    VarSetCapacity(bi, 40, 0)

    NumPut(w, bi, 4, "uint")
    , NumPut(h, bi, 8, "uint")
    , NumPut(40, bi, 0, "uint")
    , NumPut(1, bi, 12, "ushort")
    , NumPut(0, bi, 16, "uInt")
    , NumPut(bpp, bi, 14, "ushort")

    hbm := DllCall("CreateDIBSection"
    , Ptr, hdc2
    , Ptr, &bi
    , "uint", 0
    , A_PtrSize ? "UPtr*" : "uint*", ppvBits
    , Ptr, 0
    , "uint", 0, Ptr)

    if !hdc
        ReleaseDC(hdc2)
    return hbm
}

BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="") {
    ; Perform a bit-block transfer of the color data corresponding to a rectangle.
    ; of pixels from the specified source device context into a destination device context.
    ;
    ; dDC					handle to destination DC
    ; dx					x-coord of destination upper-left corner
    ; dy					y-coord of destination upper-left corner
    ; dw					width of the area to copy
    ; dh					height of the area to copy
    ; sDC					handle to source DC
    ; sx					x-coordinate of source upper-left corner
    ; sy					y-coordinate of source upper-left corner
    ; Raster				raster operation code
    ;
    ; return				If the function succeeds, the return value is nonzero
    ;
    ; notes					If no raster operation is specified, then SRCCOPY is used, which copies the source directly to the destination rectangle
    ;
    ; BLACKNESS				= 0x00000042
    ; NOTSRCERASE			= 0x001100A6
    ; NOTSRCCOPY			= 0x00330008
    ; SRCERASE				= 0x00440328
    ; DSTINVERT				= 0x00550009
    ; PATINVERT				= 0x005A0049
    ; SRCINVERT				= 0x00660046
    ; SRCAND				= 0x008800C6
    ; MERGEPAINT			= 0x00BB0226
    ; MERGECOPY				= 0x00C000CA
    ; SRCCOPY				= 0x00CC0020
    ; SRCPAINT				= 0x00EE0086
    ; PATCOPY				= 0x00F00021
    ; PATPAINT				= 0x00FB0A09
    ; WHITENESS				= 0x00FF0062
    ; CAPTUREBLT			= 0x40000000
    ; NOMIRRORBITMAP		= 0x80000000
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    return DllCall("gdi32\BitBlt"
    , Ptr, dDC
    , "int", dx, "int", dy
    , "int", dw, "int", dh
    , Ptr, sDC
    , "int", sx, "int", sy
    , "uint", Raster ? Raster : 0x00CC0020)
}
