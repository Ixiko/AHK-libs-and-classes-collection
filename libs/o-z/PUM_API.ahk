class PUM_base
{
  __Call( aTarget, aParams* ) {
    if ObjHasKey( PUM_base, aTarget )
      return PUM_base[ aTarget ].( this, aParams* )
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

class pumAPI_base extends PUM_base
{
  __Get( name ) {
    if !ObjHasKey( this, initialized )
      this.Init()
    else
      throw Exception( "Unknown field '" name "' requested from object '" this.__Class "'", -1 )
  }
}

class pumAPI extends pumAPI_base
{
  Init()
  {
    this.LoadDllFunction( "User32.dll", "DrawIconEx" )
    this.LoadDllFunction( "Gdi32.dll", "ExcludeClipRect" )
    this.LoadDllFunction( "Gdi32.dll", "SetBkColor" )
    this.LoadDllFunction( "Gdi32.dll", "SetTextColor" )
    this.LoadDllFunction( "User32.dll", "FrameRect" )
    this.LoadDllFunction( "User32.dll", "InflateRect" )
    this.LoadDllFunction( "User32.dll", "DrawEdge" )
    this.LoadDllFunction( "Gdi32.dll", "DeleteDC" )
    this.LoadDllFunction( "User32.dll", "ReleaseDC" )
    this.LoadDllFunction( "Gdi32.dll", "BitBlt" )
    this.LoadDllFunction( "User32.dll", "FillRect" )
    this.LoadDllFunction( "Gdi32.dll", "CreateCompatibleDC" )
    this.LoadDllFunction( "Gdi32.dll", "CreateCompatibleBitmap" )
    this.LoadDllFunction( "User32.dll", "SetRect" )
    this.LoadDllFunction( "User32.dll", "DrawFrameControl" )
    this.LoadDllFunction( "User32.dll", "GetSysColorBrush" )
    this.LoadDllFunction( "User32.dll", "GetSysColor" )
    this.LoadDllFunction( "Gdi32.dll", "CreateSolidBrush" )
    this.LoadDllFunction( "Gdi32.dll", "DeleteObject" )
    this.LoadDllFunction( "Gdi32.dll", "SelectObject" )
    this.LoadDllFunction( "User32.dll", "GetDC" )
    this.LoadDllFunction( "Gdi32.dll", "GetTextExtentPoint32W" )
    this.LoadDllFunction( "User32.dll", "CopyImage" )
    this.LoadDllFunction( "user32.dll", "PrivateExtractIconsW" )
    this.LoadDllFunction( "user32.dll", "DestroyIcon" )
    this.LoadDllFunction( "user32.dll", "SystemParametersInfoW" )
    this.LoadDllFunction( "Gdi32.dll", "CreateFontIndirectW" )
    this.LoadDllFunction( "gdiplus.dll", "GdiplusStartup" )
    this.LoadDllFunction( "gdiplus.dll", "GdiplusShutdown" )
    this.LoadDllFunction( "gdiplus.dll", "GdipCreateBitmapFromFileICM" )
    this.LoadDllFunction( "gdiplus.dll", "GdipCreateHICONFromBitmap" )
    this.LoadDllFunction( "gdiplus.dll", "GdipDisposeImage" )
    this.LoadDllFunction( "User32.dll", "DrawTextExW" )
    this.LoadDllFunction( "User32.dll", "DestroyWindow" )
    
    this.LoadDllFunction( "User32.dll", "GetMenuItemRect" )
    this.LoadDllFunction( "User32.dll", "CreatePopupMenu" )
    this.LoadDllFunction( "User32.dll", "DestroyMenu" )
    this.LoadDllFunction( "User32.dll", "DeleteMenu" )
    this.LoadDllFunction( "User32.dll", "RemoveMenu" )
    this.LoadDllFunction( "User32.dll", "SetMenuInfo" )
    this.LoadDllFunction( "User32.dll", "SetMenuItemInfoW" )
    this.LoadDllFunction( "User32.dll", "GetMenuItemInfoW" )
    this.LoadDllFunction( "User32.dll", "GetMenuInfo" )
    this.LoadDllFunction( "User32.dll", "GetMenuItemCount" )
    this.LoadDllFunction( "User32.dll", "GetMenuItemID" )
    this.LoadDllFunction( "User32.dll", "GetSubMenu" )
    this.LoadDllFunction( "User32.dll", "IsMenu" )
    this.LoadDllFunction( "User32.dll", "EndMenu" )
    this.LoadDllFunction( "User32.dll", "InsertMenuItemW" )
    this.LoadDllFunction( "User32.dll", "TrackPopupMenuEx" )
    this.LoadDllFunction( "Gdi32.dll", "GetDeviceCaps" )
    this.LoadDllFunction( "Kernel32.dll", "MulDiv" )
    this.LoadDllFunction( "Shlwapi.dll", "PathFindExtensionW" )
    this.initialized := 1
  }
  
  LoadDllFunction( file, function ) 
  {
    if !hModule := DllCall( "GetModuleHandleW", "Wstr", file, "UPtr" )
        hModule := DllCall( "LoadLibraryW", "Wstr", file, "UPtr" )
	
    ret := DllCall("GetProcAddress", "Ptr", hModule, "AStr", function, "UPtr")
    if !ret
      this.Err( "Could not load function '" function "'" )
    else
      this[ "p" function ] := ret
  }
  
  SetTimer( funcName, time = "" )
  {
      static st_timers := object(), st_cb := object()
      if !IsFunc( funcName )
          throw Exception( "Non existent function used for timer: " funcName, -1 )
      if st_timers.HasKey( funcName )
      {
          if ( time = "" )    ;just return parameters of active timer
              return st_timers[ funcName ]
          if ( time = "nOFF" && !( st_timers[ funcName ].delay < 0 ) )
              return
          DllCall( "KillTimer", "ptr", 0, "uint", st_timers[ funcName ].tID )
          st_timers.Remove( funcName )
      }
      if time is integer
          if ( time != 0 )
          {
              address := st_cb.hasKey( funcName ) ? st_cb[ funcName ] : ( st_cb[ funcName ] := RegisterCallback( funcName, "", 4 ) )
              timerID := DllCall( "SetTimer", "ptr", 0, "UInt", 0, "Uint", abs(time), "ptr", address )
              st_timers[ funcName ] := { tID : timerID, delay : time }
          }
      return
  }
  DrawIconEx( hDC, xLeft, yTop, hIcon ) {
    return DllCall( this.pDrawIconEx,"Ptr", hDC,"int", xLeft,"int", yTop,"Ptr", hIcon,"int",  0,"int",  0,"uint", 0,"Ptr", 0,"uint", 3 )
  }
  ExcludeClipRect( hDC, left, top, right, bottom ) {
    return DllCall( this.pExcludeClipRect, "Ptr", hDC, "Int", left, "Int", top, "Int", right, "Int", bottom )
  }
  SetBkColor( hDC, clr ) {
    return DllCall( this.pSetBkColor, "Ptr", hDC, "UInt", clr )
  }
  SetTextColor( hDC, clr ) {
    return DllCall( this.pSetTextColor, "Ptr", hDC, "UInt", clr )
  }
  FrameRect( hDC, pRECT, clr ) {
    ret := DllCall( this.pFrameRect, "Ptr", hDC, "Ptr", pRECT, "Ptr", hBrush := this.CreateSolidBrush( clr ) )
    this.DeleteObject( hBrush )
    return ret
  }
  InflateRect( pRECT, x, y )
  {
    return DllCall( this.pInflateRect, "Ptr", pRECT, "int", x, "int", y )
  }
  DrawEdge( hDC, pRECT ) {
    return DllCall( this.pDrawEdge, "Ptr", hDC, "Ptr", pRECT, "UInt", (0x0002 | 0x0004), "UInt", 0x0002 )
  }
  DeleteDC( hDC ) {
    return DllCall( this.pDeleteDC, "Ptr", hDC )
  }
  ReleaseDC( hDC, hWnd ) {
    return DllCall( this.pReleaseDC, "Ptr", hWnd, "Ptr", hDC )
  }
  BitBlt( hdcDest, nXDest, nYDest, nWidth, nHeight, hdcSrc, nXSrc, nYSrc, dwRop ) {
    return DllCall( this.pBitBlt, "Ptr", hdcDest, "UInt",nXDest, "UInt",nYDest, "UInt",nWidth, "UInt",nHeight, "Ptr", hdcSrc, "UInt",nXSrc, "UInt",nYSrc, "UInt",dwRop )
  }
  FillRect( hDC, pRECT, Clr ) {
    ret := DllCall( this.pFillRect, "Ptr", hDC, "Ptr", pRECT, "Ptr", hBrush := this.CreateSolidBrush( Clr ) )
    this.DeleteObject( hBrush )
    return ret
  }
  CreateCompatibleDC( hDC ) {
    return DllCall( this.pCreateCompatibleDC, "Ptr", hDC )
  }
  CreateCompatibleBitmap( hDC, w, h ) {
    return DllCall( this.pCreateCompatibleBitmap, "Ptr", hDC, "UInt", w, "Uint", h )
  }
  SetRect( ByRef rect, left, top, right, bottom ) {
    VarSetCapacity( rect, 16, 0 )
    return DllCall( this.pSetRect, "Ptr", &rect, "UInt", left, "UInt", top, "UInt", right, "UInt", bottom )
  }
  DrawFrameControl( hDC, pRECT, uType, uState ) {
    return DllCall( this.pDrawFrameControl, "Ptr", hDC, "Ptr", pRECT, "UInt", uType, "UInt", uState )
  }
  GetSysColorBrush( nIndex ) {
    return DllCall( this.pGetSysColorBrush, "UInt", nIndex )
  }
  GetSysColor( nIndex ) {
    return DllCall( this.pGetSysColor, "UInt", nIndex )
  }
  CreateSolidBrush( clr ) {
    return DllCall( this.pCreateSolidBrush, "Uint", clr )
  }
  DeleteObject( hObj ) {
    return DllCall( this.pDeleteObject, "Ptr", hObj )
  }
  SelectObject( hDC, hObj ) {
    return DllCall( this.pSelectObject, "Ptr", hDC, "Ptr", hObj )
  }
  GetDC( hwnd ) {
    return DllCall( this.pGetDC, "Ptr", hwnd )
  }
  GetTextExtentPoint32( hDC, string ) {
    VarSetCapacity( pSize, 8, 0 )
    DllCall( this.pGetTextExtentPoint32W, "Ptr", hDC, "Ptr", &string, "UInt", StrLen( string ), "Ptr", &pSize )
    return { cx : NumGet( &pSize, 0, "UInt" ), cy : NumGet( &pSize, 4, "UInt" ) }
  }
  max( var1, var2 ) {
    return var1>var2?var1:var2
  }
  IsInteger( var ) {
    if var is integer
      return True
    else 
      return False
  }
  isEmpty( var ) {
    return ( var = "" ? True : False )
  }
  IconGetPath(Ico) {
    spec := Ico
    pos := InStr(Ico, ":", 0, 0)
    if (pos > 4)
      spec := substr(Ico,1,pos-1)
    return this.PathUnquoteSpaces( spec )
  }
  IconGetIndex(Ico) {	
    pos := InStr(Ico, ":", 0, 0)
    if (pos > 4)
    {
      ind := substr(Ico,pos+1)
      if !ind
        ind := 0
      return ind
    }
  }
  IconCopy(handle,size,type = 1,flags = 0x8) {	;type: 1 - IMAGE_ICON, 2 - IMAGE_CURSOR, 0 - IMAGE_BITMAP, 0x8 = LR_COPYDELETEORG 	
    return DllCall( this.pCopyImage, "Ptr", handle, "uint", type, "int", size, "int", size, "UInt",flags)
  }
  IconExtract( icoPath, size = 32 ) {
      pPath := this.IconGetPath( icoPath )
      pNum := this.IconGetIndex( icoPath )
      pNum := pNum = "" ? 0 : pNum
      ;http://msdn.microsoft.com/en-us/library/ms648075%28v=VS.85%29.aspx
      DllCall( this.pPrivateExtractIconsW, "Str", pPath, "UInt", pNum, "UInt", size, "UInt", size, "Ptr*", handle, "Ptr", 0,"UInt",1, "UInt", 0 )
      if !handle
      {
          SplitPath, pPath,,,Ext
          if (Ext = "exe")
              DllCall( this.pPrivateExtractIconsW, "Str", "shell32.dll", "UInt", 2, "UInt", size, "UInt", size, "Ptr*", handle, "Ptr", 0,"UInt",1, "UInt", 0 )
      }
      return handle
  }
  PathUnquoteSpaces( path )
  {
      path := Trim( path )
      regex = O)^\s*"+(.*?)"+\s*$
      if RegExMatch( path, regex, match )
          path := match[1]
      return path
  }
  PathFindExtension( sPath )
  {
    return DllCall( this.pPathFindExtensionW, "ptr", &sPath )
  }
  PathGetExt( sPath )
  {
    sPath := this.PathUnquoteSpaces( sPath )
    if this.IsEmpty( sPath )
      return ""
    ext := StrGet( this.PathFindExtension( sPath ), "UTF-16" )
    return SubStr( ext, 2 ) ;getting extension without dot
  }
  DestroyIcon( hIcon ) {
    return DllCall( this.pDestroyIcon, "Ptr", hIcon )
  }
  Free(byRef var) {
    VarSetCapacity(var,0)
    return
  }
  GetSysFont( ByRef LOGFONT ) {
    VarSetCapacity(LOGFONT, 92, 0)
    return DllCall( this.pSystemParametersInfoW, "Uint", 0x001F, "UInt", 92, "Ptr", &LOGFONT, "UInt", 0 ) ? &LOGFONT : 0
  }
  CreateFontIndirect( pLOGFONT ) {
    return DllCall( this.pCreateFontIndirectW, "Ptr", pLOGFONT )
  }
  Gdip_Startup() {
    VarSetCapacity(GdiplusStartupInput , 3*A_PtrSize, 0), NumPut(1,GdiplusStartupInput ,0,"UInt") ; GdiplusVersion = 1
    DllCall( this.pGdiplusStartup, "Ptr*", pToken, "Ptr", &GdiplusStartupInput, "Ptr", 0)
    return pToken
  }
  Gdip_Shutdown( pToken ) {
    DllCall( this.pGdiplusShutdown, "Ptr", pToken)
    return 0
  }
  RGBtoBGR( bgr_clr ) {
    return ( bgr_clr & 0xFF0000 ) >> 16 | ( bgr_clr & 0x00FF00 ) | ( bgr_clr & 0x0000FF ) << 16
  }
  DrawText( hDC, text, pRect, flags ) {
    return DllCall( this.pDrawTextExW,"Ptr", hDC, "wstr", text, "Uint", -1, "Ptr", pRect, "Uint", flags, "Ptr", 0 )
  }
  DestroyWindow( hwnd ) {
    return DllCall( this.pDestroyWindow, "Ptr", hwnd )
  }
  GetDeviceCaps( hWnd = 0, flags = 90 ) {
    return DllCall( this.pGetDeviceCaps, "Ptr", DllCall( "GetDC", "Ptr", hWnd ), "uint", flags )
  }
  MulDiv( a, b, c ) {
    return DllCall( this.pMulDiv, "int", a, "int", b, "int", c )
  }
  obj2LOGFONT( obj, ByRef LOGFONT ) {
    if !IsObject( obj )
      obj := this.Str2Dict( obj )
    if ( VarSetCapacity( LOGFONT ) != 92 )
      VarSetCapacity( LOGFONT, 92, 0 )
    if ObjHasKey( obj, "height" )
    {
      NumPut( -this.MulDiv( abs(obj["height"]), this.GetDeviceCaps(), 72 )
            , LOGFONT, 0, "Int" )
    }
    if ObjHasKey( obj, "width" )
      NumPut( obj["width"], LOGFONT, 4, "UInt" )
    if ObjHasKey( obj, "Escapement" )
      NumPut( obj["Escapement"], LOGFONT, 8, "UInt" )
    if ObjHasKey( obj, "Orientation" )
      NumPut( obj["Orientation"], LOGFONT, 12, "UInt" )
    if ObjHasKey( obj, "Weight" )
      NumPut( obj["Weight"], LOGFONT, 16, "UInt" )
    if ObjHasKey( obj, "Italic" )
      NumPut( obj["Italic"], LOGFONT, 20, "UChar" )
    if ObjHasKey( obj, "Underline" )
      NumPut( obj["Underline"], LOGFONT, 21, "UChar" )
    if ObjHasKey( obj, "strike" )
      NumPut( obj["strike"], LOGFONT, 22, "UChar" )
    if ObjHasKey( obj, "OutPrecision" )
      NumPut( obj["OutPrecision"], LOGFONT, 24, "UChar" )
    if ObjHasKey( obj, "ClipPrecision" )
      NumPut( obj["ClipPrecision"], LOGFONT, 25, "UChar" )
    if ObjHasKey( obj, "PitchAndFamily" )
      NumPut( obj["PitchAndFamily"], LOGFONT, 27, "UChar" )
    if ObjHasKey( obj, "CharSet" )
      NumPut( obj["CharSet"], LOGFONT, 23, "UChar" )
    if ObjHasKey( obj, "Quality" )
      NumPut( obj["Quality"], LOGFONT, 26, "UChar" )
    if ObjHasKey( obj, "name" )
      StrPut( obj["name"], &LOGFONT + 28, 32, "UTF-16" )
  }
  LOGFONT2obj( ByRef LOGFONT ) {
    if ( VarSetCapacity( LOGFONT ) != 92 )
      return 0
    obj := object()
    obj["height"] := abs( this.MulDiv( abs( NumGet( LOGFONT, 0, "Int" ) )
                        , 72, this.GetDeviceCaps() ) )
    obj["width"] := NumGet( LOGFONT, 4, "Int" )
    obj["Escapement"] := NumGet( LOGFONT, 8, "Int" )
    obj["Orientation"] := NumGet( LOGFONT, 12, "Int" )
    obj["Weight"] := NumGet( LOGFONT, 16, "Int" )
    obj["italic"] := NumGet( LOGFONT, 20, "UChar" )
    obj["underline"] := NumGet( LOGFONT, 21, "UChar" )
    obj["strike"] := NumGet( LOGFONT, 22, "UChar" )
    obj["CharSet"] := NumGet( LOGFONT, 23, "UChar" )
    obj["OutPrecision"] := NumGet( LOGFONT, 24, "UChar" )
    obj["ClipPrecision"] := NumGet( LOGFONT, 25, "UChar" )
    obj["Quality"] := NumGet( LOGFONT, 26, "UChar" )
    obj["PitchAndFamily"] := NumGet( LOGFONT, 27, "UChar" )
    obj["name"] := StrGet( &LOGFONT + 28, 32, "UTF-16" )
    return obj
  }
  Dict2Str( obj, delim = "|", separ = ":" ) {
    fstr := ""
    for key,val in obj
      fstr .= ( fstr ? delim : "" ) key separ val
    return fstr
  }
  Str2Dict( fstr, delim = "|", separ = ":" ) {
    obj := object()
    for i,pair in StrSplit( fstr, delim, A_Space A_Tab )
    {
      ar := StrSplit( pair, separ, A_Space A_Tab )
      obj[ ar[1] ] := ar[2]
    }
    return obj
  }
  
;//////////////////////////////////// PUM functions
  _GetItemPosByID( hMenu, itemID )
  {
    if ( ( nCount := this._GetMenuItemCount( hMenu ) ) != -1 )
    {
      loop,% nCount
      {
        nPos := A_Index-1   ;pos is zero-based
        if (( rID := this._GetMenuItemID( hMenu, nPos ) ) == -1 )    ;if this item is submenu :/
          rID := this._GetItem( hMenu, nPos ).id
        if ( itemID == rID )
          return nPos
      }
    }
    return -1
  }
  _GetItemRect( hMenu, nPos )
  {
    VarSetCapacity( RECT, 16, 0 )
    if DllCall( this.pGetMenuItemRect, "Ptr", 0, "Ptr", hMenu, "UInt", nPos, "Ptr", &RECT ) 
    {
      objRect := { left : numget( RECT, 0, "UInt" )
                  ,top : numget( RECT, 4, "UInt" )
                  ,right : numget( RECT, 8, "UInt" )
                  ,bottom : numget( RECT, 12, "UInt" ) }
      return objRect
    }
    return 0
  }
  _GetMenuItems( hMenu )
  {
    arrItems := Object()
    if ( ( nCount := this._GetMenuItemCount( hMenu ) ) != -1 )
    {
      loop,% nCount
      {
        nPos := A_Index-1   ;pos is zero-based
        if ( item := this._GetItem( hMenu, nPos ) )
          arrItems[ A_Index ] := item
      }
    }
    return arrItems
  }
  _GetMenuFromHandle( hMenu ) {
    cbSize := this.MENUINFOsize
    fMask := this.MIM_MENUDATA
    VarSetCapacity( MENUINFO, cbSize, 0 )
    NumPut( cbSize, MENUINFO, 0, "UInt")
    NumPut( fMask, MENUINFO, 4, "UInt")
    this._GetMenuInfo( hMenu, MENUINFO )
    if ( objPtr := NumGet( &MENUINFO, 16+2*A_PtrSize, "UPtr" ) )
      obj := object( objPtr )
    return obj
  }
  
  _GetItem( hMenu, nItem, fByPos = True ) {
    cbsize := this.MENUITEMINFOsize
    VarSetCapacity( MENUITEMINFO, cbsize, 0 )
    fMask := this.MIIM_DATA
    NumPut( cbsize, MENUITEMINFO, 0, "UInt" )
    NumPut( fMask, MENUITEMINFO, 4, "UInt" )
    if this._GetMenuItemInfo( hMenu, nItem, fByPos, MENUITEMINFO )
    {
      if ( objPtr := NumGet( MENUITEMINFO, 16+4*A_PtrSize, "Ptr" ) )
        return object( objPtr )
    }
  }

  _loadIcon( pPath, pSize ) {
    if !pPath
      return 0
    if this.IsInteger( pPath )                 ;if icon handle were passed
      return this.IconCopy( pPath, pSize, 1, 0 )  ;will not delete original icon handle
    if ( this.IconGetIndex( pPath ) = "" 
      && !( this.PathGetExt( pPath ) ~= "i)^(ico|cur|ani)$" ) )
    {
      ;~ gdip_token := Gdip_Startup()
      DllCall( this.pGdipCreateBitmapFromFileICM, "wstr", pPath, "Ptr*", pBitmap )
      DllCall( this.pGdipCreateHICONFromBitmap, "Ptr", pBitmap, "Ptr*", hIcon )
      DllCall( this.pGdipDisposeImage, "Ptr", pBitmap )
      ;~ Gdip_Shutdown( gdip_token )
      hIcon := this.IconCopy( hIcon, pSize )
      return hIcon
    }
    else
      return this.IconExtract( pPath, pSize )
  }

  ;////////////////// WINAPI
  _CreatePopupMenu() {
    return DllCall( this.pCreatePopupMenu, "Ptr" )
  }
  _DestroyMenu( hMenu ) {
    return DllCall( this.pDestroyMenu, "Ptr", hMenu )
  }
  ;deletes item and associated menu
  _DeleteItem( hMenu, itemID, flag = 0 ) {    ;0 means deletion by ID, otherewise by pos
    return DllCall( this.pDeleteMenu, "Ptr", hMenu, "UInt", ItemID, "UInt", flag?0x400:0 ) 
  }
    ;deletes item, but detach associated menu
  _RemoveItem( hMenu, itemID, flag = 0 ) {    ;0 means deletion by ID, otherewise by pos
    return DllCall( this.pRemoveMenu, "Ptr", hMenu, "UInt", ItemID, "UInt", flag?0x400:0 ) 
  }
  _SetMenuInfo( hMenu, MENUINFO_ptr ) {
    return DllCall( this.pSetMenuInfo, "Ptr", hMenu, "Ptr", MENUINFO_ptr )
  }
  _SetMenuItemInfo( hMenu, itemID, fByPosition, MENUITEMINFO_ptr ) {
  return DllCall( this.pSetMenuItemInfoW, "Ptr", hMenu, "uint", itemID, "uint", fByPosition, "Ptr", MENUITEMINFO_ptr)
  }
  _GetMenuItemInfo( hMenu, uItem, fByPosition, ByRef MENUITEMINFO ) {
    return DllCall( this.pGetMenuItemInfoW, "Ptr", hMenu, "uint", uItem, "uint", fByPosition, "Ptr", &MENUITEMINFO )
  }
  _GetMenuInfo( hMenu, ByRef MENUINFO ) {
    return DllCall( this.pGetMenuInfo, "Ptr", hMenu, "Ptr", &MENUINFO )
  }
  _GetMenuItemCount( hMenu ) {
    return DllCall( this.pGetMenuItemCount, "Ptr", hMenu )
  }
  _GetMenuItemID( hMenu, nPos ) {
    return DllCall( this.pGetMenuItemID, "Ptr", hMenu, "Uint", nPos )
  }
  _GetSubMenu( hMenu, nPos ) {
    return DllCall( this.pGetSubMenu, "Ptr", hMenu, "Uint", nPos )
  }
  _IsMenu( hMenu ) {
    return DllCall( this.pIsMenu, "Ptr", hMenu )
  }
  _EndMenu() {
    return DllCall( this.pEndMenu )
  }
  _insertMenuItem( hMenu, prevID, fByPos, MENUITEMINFO_ptr ) {
     return DllCall( this.pInsertMenuItemW,"Ptr", hMenu,"uint", prevID,"uint", fByPos,"Ptr", MENUITEMINFO_ptr )
  }
  _TrackPopupMenuEx( hMenu, uFlags, X, Y, hWnd ) {
    return DllCall( this.pTrackPopupMenuEx, "Ptr", hMenu, "uint", uFlags, "int", X, "int", Y, "Ptr", hWnd, "Ptr", 0)
  }
  
  _msgMonitor( state ) 
  {
    static WM_MENUSELECT:= 0x11F
    ,WM_MEASUREITEM	    := 0x2C
    ,WM_DRAWITEM		:= 0x2B
    ,WM_ENTERMENULOOP	:= 0x211
    ,WM_INITMENUPOPUP	:= 0x117
    ,WM_UNINITMENUPOPUP := 0x125
    ,WM_EXITMENULOOP	:= 0x212
    ,WM_MENUCOMMAND	    := 0x126
    ,WM_MENURBUTTONUP   := 0x0122
    ,WM_CONTEXTMENU	    := 0x7b
    ,WM_MBUTTONDOWN	    := 0x207
    ,WM_MENUCHAR		:= 0x120
    
    static oldMeasure, oldDraw, oldrbutton, oldMButton, oldMenuChar

    if (state)	{
        OnMessage(WM_ENTERMENULOOP, "PUM_OnEnterLoop")
        oldMeasure := OnMessage(WM_MEASUREITEM,	"PUM_OnMeasure")
        oldDraw := OnMessage(WM_DRAWITEM,		"PUM_OnDraw")
        OnMessage(WM_MENUSELECT,    "PUM_OnSelect")
        OnMessage(WM_INITMENUPOPUP, "PUM_OnInit")
        OnMessage(WM_UNINITMENUPOPUP,"PUM_OnUninit")
        oldrbutton := OnMessage(WM_MENURBUTTONUP,	"PUM_OnRButtonUp")
        oldMButton := OnMessage(WM_MBUTTONDOWN,	"PUM_OnSelect")
        oldMenuChar := OnMessage(WM_MENUCHAR,		"PUM_OnMenuChar")
        OnMessage(WM_EXITMENULOOP,	"PUM_OnExitLoop")
    }
    else {
        OnMessage(WM_ENTERMENULOOP, "")
        OnMessage(WM_MEASUREITEM,	oldMeasure )
        OnMessage(WM_DRAWITEM, oldDraw)
        OnMessage(WM_INITMENUPOPUP, "")
        OnMessage(WM_MENUSELECT, 	"")
        OnMessage(WM_EXITMENULOOP, 	"")
        OnMessage(WM_UNINITMENUPOPUP, "")
        OnMessage(WM_MENURBUTTONUP, oldrbutton )
        OnMessage(WM_MBUTTONDOWN, oldMButton )
        OnMessage(WM_MENUCHAR, oldMenuChar )
    }
  }
  
    ; menu constants
  static MNS_AUTODISMISS := 0x10000000 ;Menu automatically ends when mouse is outside the menu for approximately 10 seconds.
  ,MNS_CHECKORBMP := 0x04000000        ;The same space is reserved for the check mark and the bitmap. If the check mark is drawn, the bitmap is                                  not. 
  ,MNS_DRAGDROP := 0x20000000          ;Menu items are OLE drop targets or drag sources. Menu owner receives WM_MENUDRAG and WM_MENUGETOBJECT messages.
  ,MNS_MODELESS := 0x40000000          ;Menu is modeless; that is, there is no menu modal message loop while the menu is active.
  ,MNS_NOCHECK := 0x80000000           ;No space is reserved to the left of an item for a check mark.
  ,MNS_NOTIFYBYPOS := 0x08000000       ;Menu owner receives a WM_MENUCOMMAND message instead of a WM_COMMAND message when the user makes a selection.
  ,MFT_MENUBREAK := 0x00000040
  ,MFT_MENUBARBREAK := 0x00000020
  ,MFT_OWNERDRAW := 0x00000100
  ,MFT_SEPARATOR := 0x00000800
  ,MFT_RIGHTORDER := 0x00002000
  ,MIIM_DATA := 0x00000020
  ,MIIM_STRING := 0x00000040
  ,MIIM_FTYPE := 0x00000100
  ,MIIM_ID := 0x00000002
  ,MIIM_STATE := 0x00000001
  ,MIIM_SUBMENU := 0x00000004
  ,MIIM_BITMAP := 0x00000080
  ,MENUITEMINFOsize := 16+8*A_PtrSize
  ,MENUINFOsize := 16+3*A_PtrSize
  ,HBMMENU_CALLBACK := -1
  ,MIM_BACKGROUND := 0x00000002
  ,MIM_STYLE := 0x00000010
  ,MIM_MAXHEIGHT := 0x00000001 
  ,MIM_MENUDATA := 0x00000008
  ,ODA_DRAWENTIRE := 0x0001
  ,ODA_SELECT := 0x0002
  ,ODA_FOCUS := 0x0004
  ,MFS_DISABLED := 0x3
  
}
