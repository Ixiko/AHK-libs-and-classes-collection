SetTrayNumber(Number, TextColour=0xff000000, BackgroundColour=0xffffffff) {
;http://www.autohotkey.com/board/topic/23666-write-2-digit-numbers-to-the-system-tray-icon/#entry417583
StringLen, NumLen, Number
    if (NumLen = 3) {
        Size := 8
        Y := "y3"
    }
    else if (NumLen = 1) {
        Size := 12
        Y := "y1"
    }
    else {
        Size := 10
        Y := "y3"
    }
    if !hFamily := Gdip_FontFamilyCreate("Arial")
        return -2
    Gdip_DeleteFontFamily(hFamily)
    pBitmap := Gdip_CreateBitmap(16, 16), G := Gdip_GraphicsFromImage(pBitmap)
    Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(BackgroundColour), 0, 0, 16, 16)
    Gdip_DeleteBrush(pBrush)
    pBrush := Gdip_BrushCreateSolid(TextColour)
    Gdip_TextToGraphics(G, Number, "x0 w16 h16 r4 Center Bold c" pBrush "s" Size Y, "Arial")
    Gdip_DeleteBrush(pBrush)
    hIcon := Gdip_CreateHICONFromBitmap(pBitmap)
    Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)

    /*
    ---------------32/64-bit compatibility fix by just me---------------
    http://www.autohotkey.com/board/topic/95183-function-using-gdip-and-dll-x64-compatibility/
    Thanks to just me, Rijul Ahuja, and HotKeyIt for their time and help
    --------------------------------------------------------------------

    http://msdn.microsoft.com/en-us/library/windows/desktop/bb773352(v=vs.85).aspx
    typedef struct _NOTIFYICONDATA {
        DWORD cbSize;                     ; A_PtrSize (64-bit alignment)
        HWND  hWnd;                       ; A_PtrSize
        UINT  uID;                        ; 4
        UINT  uFlags;                     ; 4
        UINT  uCallbackMessage;           ; A_PtrSize (64-bit alignment)
        HICON hIcon;                      ; A_PtrSize
        TCHAR szTip[64];                  ; 64 / 128
        DWORD dwState;                    ; 4
        DWORD dwStateMask;                ; 4
        TCHAR szInfo[256];                ; 256 / 512
        union {                           ; 4
            UINT uTimeout;
            UINT uVersion;
        };
        TCHAR szInfoTitle[64];            ; 64 / 128
        DWORD dwInfoFlags;                ; 4
        GUID  guidItem;                   ; 16
        HICON hBalloonIcon;               ; A_PtrSize  <- Vista +
        } NOTIFYICONDATA, *PNOTIFYICONDATA;
    */
    ; Sizes
    sizeT := A_IsUnicode ? 2 : 1 ; size of a TCHAR
    sizeNID := A_PtrSize
            + A_PtrSize
            + 4
            + 4
            + A_PtrSize
            + A_PtrSize
            + (64 * sizeT)
            + 4
            + 4
            + (256 * sizeT)
            + 4
            + (64 * sizeT)
            + 4
            + 16
            + A_PtrSize
    ; Offsets
    offWnd := A_PtrSize
    offID  := offWnd + A_PtrSize
    offFlags := offID + 4
    offIcon  := offFlags + 4 + A_PtrSize
    ; API call
    VarSetCapacity(NID, sizeNID, 0)
    NumPut(sizeNID, NID, 0, "UInt")
    NumPut(A_ScriptHwnd, NID, offWnd, "Ptr")
    NumPut(1028, NID, offID, "UInt")
    NumPut(0x2, NID, offFlags, "UInt")
    NumPut(hIcon, NID, offIcon, "Ptr")
    DllCall("Shell32.dll\Shell_NotifyIcon", "UInt", 0x1, "Ptr", &NID)
;-------------------------------------------------------------------

    DestroyIcon(hIcon)
    return 0
}
