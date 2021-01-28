/* ===========================================================================================================
				v0.1
				by majkinetor

--- Functions ---

BitBlt                  ( hdcDest, nXDest, nYDest, nWidth, nHeight , hdcSrc, nXSrc, nYSrc, dwRop )
CreateCompatibleBitmap  ( hDC, nWidth, nHeight )
CreateCompatibleDC      ( hDC )
CreateSolidBrush        ( crColor )
CreatePen               ( fnPenStyle, nWidth, crColor )
DrawEdge                ( hdc, qrc, edge, grfFlags)
DrawFocusRect           ( hdc, lprc)
DrawFrameControl        ( hDC, lprc, uType, ustate )
DrawIconEx              ( hDC, xLeft, yTop, hIcon, cxWidth, cyWidth, istepIfAniCur, hbrFlickerFreeDraw, diFlags )
DestroyIcon				( hIcon )
DeleteDc				( hdC )
DeleteObject			( hObject )
DrawText                ( hDC, lpString, nCount, lpRect, uFormat )
Ellipse                 ( hdc, nLeftRect, nTopRect, nRightRect, nBottomRect)
InvertRect              ( hdc, lprec )
InvalidateRect			( hWnd, lpRect, bErase )
LoadImage				( hinst, lpszName, uType, cxDesired, cyDesired, fuLoad
FillRect                ( hDC, lpRec, hBr )
FrameRect               ( hDC, lprc, hbr)
GetBkColor				( hdc )
GetBkMode				( hdc )
GetDC                   ( hwnd )
GetSysColor             ( nIndex )
GetTextExtentPoint32    ( hDC, lpString, cbString, lpSize )
GetSysColorBrush        ( nIndex )
GdiFlush				( )
GdiGetBatchLimit		( )
GdiSetBatchLimit		( dwLimit )
MoveToEx				( hdc, X, Y, lpPoint)
LineTo					( hdc, nXEnd, nYEnd)
Pie                     ( hdc, nLeftRect, nTopRect, nRightRect, nBottomRect, nXRadial1, nYRadial1, nXRadial2, nYRadial2 )
PatBlt					( hdc, nXLeft, nYLeft,  nWidth,  nHeight, dwRop)
Rectangle               ( hdc, nLeftRect, nTopRect, nRightRect, nBottomRect)
RedrawWindow			( hWnd, lprcUpdate, hrgnUpdate, flags)
RoundRect               ( hdc, nLeftRect, nTopRect, nRightRect, nBottomRect)
SelectObject            ( hDC, hgdiobj )
SetBkColor              ( hDC, crColor )
SetBKMode               ( hDC, iBkMode )
SetTextColor            ( hDC, crColor )
TextOut                 ( hDC, nXStart, nYStart, lpString, cbString )


--- Structs ---

RECT
SIZE

--- User ---

DrawText                ( hDC, str, X, Y, W, H, options=0 )       ;DrawText helper
FillRect                ( hdc, X, Y, W, H, hBrush)                ;FillRect helper
LoadIcon                ( pPath )                                 ;wrapper for LoadImage for an icon

============================================================================================================
*/

API_GdiGetBatchLimit(){
	return DllCall("GdiGetBatchLimit")
}

API_GdiSetBatchLimit( dwLimit ) {
	return DllCall("GdiSetBatchLimit", "uint", dwLimit)
}

API_GdiFlush(){
	return DllCall("GdiFlush")
}

API_InvalidateRect( hWnd, lpRect, bErase) {
	return DllCall("InvalidateRect", "uint", hWnd, "uint", lpRect, "uint", bErase)
}

API_RedrawWindow(hWnd, lprcUpdate, hrgnUpdate, flags) {
	return DllCall("RedrawWindow", "uint", hWnd, "uint", lprcUpdate, "uint", hrgnUpdate, "uint", flags)
}

API_GetBkColor( hdc ) {
	return DllCall("GetBkColor", "uint", hdc )
}

API_GetBkMode( hdc ) {
	return DllCall("GetBkMode", "uint", hdc )
}

API_DeleteObject(hObject) {
    return DllCall("DeleteObject", "UInt", hObject)
}

API_LineTo(hdc, nXEnd, nYEnd) {
    return DllCall("LineTo", "UInt", hDC, "UInt", nXEnd, "UInt", nYEnd)
}

API_MoveToEx(hdc, X, Y, lpPoint) {
	return DllCall("MoveToEx", "UInt", hdc, "Uint", X, "Uint", Y, "Uint", lpPoint )
}


API_LoadImage( hinst, lpszName, uType, cxDesired, cyDesired, fuLoad ){
	return DllCall("LoadImage", "uint", hinst, "str", lpszName, "uint", uType, "int", cxDesired, "int", cyDesired, "uint", fuLoad)
}


API_PatBlt(hdc, nXLeft, nYLeft,  nWidth,  nHeight, dwRop) {
	return DllCall("PatBlt", "uint", hdc, "int", nXLeft, "int", nYLeft, "int", nWidth, "int", nHeight, "uint", dwRop)
}

API_DeleteDC(hDC){
	return DllCall("DeleteDC", "uint", hDC)
}


Draw_Init() {
global

    ;DrawText constants
    DT_BOTTOM           = 0x8
    DT_CALCRECT         = 0x400
    DT_CENTER           = 0x1
    DT_EDITCONTROL      = 0x2000
    DT_END_ELLIPSIS     = 0x8000
    DT_EXPANDTABS       = 0x40
    DT_EXTERNALLEADING  = 0x200
    DT_INTERNAL         = 0x1000
    DT_LEFT             = 0x0
    DT_NOCLIP           = 0x100
    DT_RIGHT            = 0x2
    DT_SINGLELINE       = 0x20
    DT_TABSTOP          = 0x80
    DT_TOP              = 0x0
    DT_VCENTER          = 0x4
    DT_WORDBREAK        = 0x10
    DT_WORD_ELLIPSIS    = 0x40000

    ;colors
    COLOR_3DDKSHADOW            = 21
    COLOR_3DLIGHT               = 22
    COLOR_ACTIVEBORDER          = 10
    COLOR_ACTIVECAPTION         = 2
    COLOR_APPWORKSPACE          = 12
    COLOR_BACKGROUND            = 1
    COLOR_BTNFACE               = 15
    COLOR_BTNHIGHLIGHT          = 20
    COLOR_BTNSHADOW             = 16
    COLOR_BTNTEXT               = 18
    COLOR_CAPTIONTEXT           = 9
    COLOR_GRAYTEXT              = 17
    COLOR_HIGHLIGHT             = 13
    COLOR_HIGHLIGHTTEXT         = 14
    COLOR_HOTLIGHT              = 26
    COLOR_INACTIVEBORDER        = 11
    COLOR_INACTIVECAPTION       = 3
    COLOR_INACTIVECAPTIONTEXT   = 19
    COLOR_INFOBK                = 24
    COLOR_INFOTEXT              = 23
    COLOR_MENU                  = 4
    COLOR_MENUTEXT              = 7
    COLOR_WINDOW                = 5
    COLOR_WINDOWFRAME           = 6
    COLOR_WINDOWTEXT            = 8
    COLOR_3DFACE                := COLOR_BTNFACE
    COLOR_3DHIGHLIGHT           := COLOR_BTNHIGHLIGHT
    COLOR_3DHILIGHT             := COLOR_BTNHIGHLIGHT
    COLOR_3DSHADOW              := COLOR_BTNSHADOW
    COLOR_BTNHILIGHT            := COLOR_BTNHIGHLIGHT
    COLOR_DESKTOP               := COLOR_BACKGROUND

    ;DrawFrameControl constants
    DFC_BUTTON          = 4
    DFC_CAPTION         = 1
    DFC_MENU            = 2
    DFC_POPUPMENU       = 5
    DFC_SCROLL          = 3
    DFCS_ADJUSTRECT     = 0x2000
    DFCS_BUTTON3STATE   = 0x8
    DFCS_BUTTONCHECK    = 0x0
    DFCS_BUTTONPUSH     = 0x10
    DFCS_BUTTONRADIO    = 0x4
    DFCS_BUTTONRADIOIMAGE  = 0x1
    DFCS_BUTTONRADIOMASK  = 0x2
    DFCS_CAPTIONCLOSE   = 0x0
    DFCS_CAPTIONMAX     = 0x2
    DFCS_CAPTIONHELP    = 0x4
    DFCS_CAPTIONMIN     = 0x1
    DFCS_CAPTIONRESTORE = 0x3
    DFCS_CHECKED        = 0x400
    DFCS_FLAT           = 0x4000
    DFCS_HOT            = 0x1000
    DFCS_MENUARROW      = 0x0
    DFCS_INACTIVE       = 0x100
    DFCS_MENUARROWRIGHT  = 0x4
    DFCS_MENUBULLET     = 0x2
    DFCS_MENUCHECK      = 0x1
    DFCS_MONO           = 0x8000
    DFCS_PUSHED         = 0x200
    DFCS_SCROLLCOMBOBOX = 0x5
    DFCS_SCROLLDOWN     = 0x1
    DFCS_SCROLLLEFT     = 0x2
    DFCS_SCROLLRIGHT    = 0x3
    DFCS_SCROLLSIZEGRIP = 0x8
    DFCS_SCROLLSIZEGRIPRIGHT  = 0x10
    DFCS_SCROLLUP       = 0x0
    DFCS_TRANSPARENT    = 0x800

    ;draw edge constants
    BF_ADJUST                = 0x2000
    BF_BOTTOM                = 0x8
    BF_DIAGONAL              = 0x10
    BF_FLAT                  = 0x4000
    BF_LEFT                  = 0x1
    BF_MIDDLE                = 0x800
    BF_MONO                  = 0x8000
    BF_RIGHT                 = 0x4
    BF_SOFT                  = 0x1000
    BF_TOP                   = 0x2
    BF_TOPLEFT               := (BF_TOP | BF_LEFT)
    BF_TOPRIGHT              := (BF_TOP | BF_RIGHT)
    BDR_INNER                = 0xC
    BDR_OUTER                = 0x3
    BDR_RAISED               = 0x5
    BDR_RAISEDINNER          = 0x4
    BDR_RAISEDOUTER          = 0x1
    BDR_SUNKEN               = 0xA
    BDR_SUNKENINNER          = 0x8
    BDR_SUNKENOUTER          = 0x2
    BF_BOTTOMLEFT                   := (BF_BOTTOM | BF_LEFT)
    BF_BOTTOMRIGHT                  := (BF_BOTTOM | BF_RIGHT)
    BF_DIAGONAL_ENDBOTTOMLEFT       := (BF_DIAGONAL | BF_BOTTOM | BF_LEFT)
    BF_DIAGONAL_ENDBOTTOMRIGHT      := (BF_DIAGONAL | BF_BOTTOM | BF_RIGHT)
    BF_DIAGONAL_ENDTOPLEFT          := (BF_DIAGONAL | BF_TOP | BF_LEFT)
    BF_DIAGONAL_ENDTOPRIGHT         := (BF_DIAGONAL | BF_TOP | BF_RIGHT)
    BF_RECT                         := (BF_LEFT | BF_TOP | BF_RIGHT | BF_BOTTOM)
    EDGE_BUMP                       := (BDR_RAISEDOUTER | BDR_SUNKENINNER)
    EDGE_ETCHED                     := (BDR_SUNKENOUTER | BDR_RAISEDINNER)
    EDGE_RAISED                     := (BDR_RAISEDOUTER | BDR_RAISEDINNER)
    EDGE_SUNKEN                     := (BDR_SUNKENOUTER | BDR_SUNKENINNER)

    ;createPen constants
    PS_DASH             = 1
    PS_DOT              = 2
    PS_DASHDOT          = 3
    PS_DASHDOTDOT       = 4
    PS_NULL             = 5
    PS_INSIDEFRAME      = 6


}

API_GetDC( hwnd ) {
    return DllCall("GetDC", "uint", hwnd)
}
API_CreatePen( fnPenStyle, nWidth, crColor ) {
    return DllCall("CreatePen", "int", fnPenStyle, "int", nWidth, "int", crColor)
}
API_Ellipse(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect) {
    return DllCall("Ellipse", "uint", hDC, "int", nLeftRect, "int", nTopRect, "int", nRightRect, "int", nBottomRect)
}
API_FrameRect(hDC, lprc, hbr) {
    return DllCall("FrameRect", "uint", hDC, "uint", lprc, "uint", hbr)
}
API_Rectangle(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect) {
    return DllCall("Rectangle", "uint", hDC, "int", nLeftRect, "int", nTopRect, "int", nRightRect, "int", nBottomRect)
}
API_RoundRect(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect) {
    return DllCall("RoundRect", "uint", hDC, "int", nLeftRect, "int", nTopRect, "int", nRightRect "int", nBottomRect)
}
API_Pie( hdc, nLeftRect, nTopRect, nRightRect, nBottomRect, nXRadial1, nYRadial1, nXRadial2, nYRadial2 ) {
    return DllCall("Pie", "uint", hDC, "int", nLeftRect, "int", nTopRect, "int", nRightRect, "int", nBottomRect
                    , "int", nXRadial1, "int", nYRadial1, "int", nXRadial2, "int", nYRadial2 )
}
API_InvertRect( hdc, lprec ) {
    return DllCall("InvertRect", "uint", hdc, "uint", lprec )
}
API_BitBlt( hdcDest, nXDest, nYDest, nWidth, nHeight , hdcSrc, nXSrc, nYSrc, dwRop ) {
    return DllCall("BitBlt"
             , "uint",hdcDest,"int", nXDest, "int", nYDest, "int", nWidth, "int", nHeight
             , "uint",hdcSrc, "int", nXSrc, "int", nYSrc  , "uint", dwRop)
}
API_CreateCompatibleBitmap( hdc , nWidth, nHeight ) {
    return DllCall("CreateCompatibleBitmap", "uint",hdc, "int", nWidth, "int",nHeight)
}
API_CreateCompatibleDC(hDC) {
    return DllCall("CreateCompatibleDC", "uint", hDC)
}
API_CreateSolidBrush(crColor) {
    return DllCall("CreateSolidBrush", "uint", crColor)
}
API_DrawEdge(hdc, qrc, edge, grfFlags) {
    return DllCall("DrawEdge", "uint", hdc, "uint", qrc, "uint", edge, "uint", grfFlags)

}
API_DrawFocusRect(hdc, lprc) {
    return DllCall("DrawFocusRect", "uint", hdc, "uint", lprc)
}
API_DrawFrameControl(hDC, lprc, uType, ustate) {
    return DllCall("DrawFrameControl", "uint", hDC, "uint", lprc, "uint", uType, "uint", uState)
}
API_DrawIconEx( hDC, xLeft, yTop, hIcon, cxWidth, cyWidth, istepIfAniCur, hbrFlickerFreeDraw, diFlags) {
    return DllCall("DrawIconEx"
            ,"uint", hDC
            ,"uint", xLeft
            ,"uint", yTop
            ,"uint", hIcon
            ,"int",  cxWidth
            ,"int",  cyWidth
            ,"uint", istepIfAniCur
            ,"uint", hbrFlickerFreeDraw
            ,"uint", diFlags )
}
API_DestroyIcon(hIcon) {
	return	DllCall("DestroyIcon", "uint", hIcon)
}

API_DrawText( hDC, lpString, nCount, lpRect, uFormat )   {
    Return DllCall("DrawText", "uint", hDC, "str", lpString, "int", nCount, "uint", lpRect, "uint", uFormat)
  }
API_FillRect(hDC, lpRec, hBr) {
    return, DllCall("FillRect", "uint", hDC, "uint", lpRec, "uint", hBr)
}
API_GetTextExtentPoint32(hDC, lpString, cbString, lpSize) {
    return, DllCall("GetTextExtentPoint32A", "uint", hDC, "str", lpString, "int", cbString, "uint", lpSize)
}
API_GetSysColor( nIndex ) {
    return DllCall("GetSysColor", "int", nIndex)
}

API_GetSysColorBrush( nIndex ) {
    return DllCall("GetSysColorBrush", "int", nIndex)
}
API_SetBkColor( hDC, crColor ) {
    return, DllCall("SetBkColor", "uint", hDC, "uint", crColor)
}
API_SetBKMode(hDC, iBkMode) {
    return, DllCall("SetBkMode", "uint", hDC, "int", iBkMode)
}
API_SetTextColor(hDC, crColor) {
    return, DllCall("SetTextColor", "uint", hDC, "uint", crColor)
}
API_SelectObject( hDC, hgdiobj ) {
    return DllCall("SelectObject", "uint", hDC, "uint", hgdiobj)
}
API_TextOut(hDC, nXStart, nYStart, lpString, cbString) {
    return DllCall("TextOut"
            ,"uint", hDC
            ,"uint", nXStart
            ,"uint", nYStart
            ,"str",  lpString
            ,"uint", cbString)
}
; Load icon from the the file
USR_LoadIcon(pPath) {
    return  DllCall( "LoadImage"
                     , "uint", 0
                     , "str", pPath
                     , "uint", 2                ; IMAGE_ICON
                     , "int", 0
                     , "int", 0
                     , "uint", 0x10 | 0x20)     ; LR_LOADFROMFILE | LR_TRANSPARENT
}
; Use 4 coordinates instead of RECT structure and skip string length
USR_DrawText(hDC, str, X, Y, W, H, options=0) {
    global

    API_Draw_rect_left  := X
    API_Draw_rect_top   := Y
    API_Draw_rect_Right := X + W
    API_Draw_rect_Bottom := Y + H

    RECT_Set("API_Draw_rect")
    API_SetBKMode( hDC, 1 )
    return API_DrawText( hDC, str, StrLen(str), &API_Draw_rect_c, options)
}
; Use 4 coordinates instead of RECT structure
USR_FillRect( hdc, X, Y, W, H, hBrush) {
    global

    API_Draw_rect_left  := X
    API_Draw_rect_top   := Y
    API_Draw_rect_Right := X + W
    API_Draw_rect_Bottom := Y + H

    RECT_Set("API_Draw_rect")
    API_SetBKMode( hDC, 1 )
    return, DllCall("FillRect", "uint", hDC, "uint", &API_Draw_rect_c , "uint", hBrush)
}



/*
============================================================
            STRUCT
=============================================================
*/

;typedef struct _RECT {
;  LONG left;
;  LONG top;
;  LONG right;
;  LONG bottom;
;} RECT, *PRECT;
RECT_Set(var) {
    global

    VarSetCapacity(%var%_c, 16 , 0)
    InsertInteger(%var%_left,   %var%, 0)
    InsertInteger(%var%_top,    %var%, 4)
    InsertInteger(%var%_right,  %var%, 8)
    InsertInteger(%var%_bottom, %var%, 12)
}

RECT_Get(var) {
    global

    %var%_left   := ExtractInteger(%var%, 0)
    %var%_top    := ExtractInteger(%var%, 4)
    %var%_right  := ExtractInteger(%var%, 8)
    %var%_bottom := ExtractInteger(%var%, 12)
}

;typedef struct tagSIZE {
    ;  LONG cx;
    ;  LONG cy;
    ;} SIZE, *PSIZE;
SIZE_Get(var) {
    global
    %var%_cx := ExtractInteger(%var%,0)
    %var%_cy := ExtractInteger(%var%,4)
}

SIZE_Set(var) {
   global

   VarSetCapacity(%var%_c, 4, 0)
   InsertInteger(%var%_cx, %var%, 0)
   InsertInteger(%var%_cy, %var%, 4)
}