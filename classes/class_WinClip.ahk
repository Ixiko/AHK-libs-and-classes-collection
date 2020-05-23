class WinClip extends WinClip_base
{
  __New()
  {
    this.isinstance := 1
    this.allData := ""
  }

  _toclipboard( ByRef data, size )
  {
    if !WinClipAPI.OpenClipboard()
      return 0
    offset := 0
    lastPartOffset := 0
    WinClipAPI.EmptyClipboard()
    while ( offset < size )
    {
      if !( fmt := NumGet( data, offset, "UInt" ) )
        break
      offset += 4
      if !( dataSize := NumGet( data, offset, "UInt" ) )
        break
      offset += 4
      if ( ( offset + dataSize ) > size )
        break
      if !( pData := WinClipAPI.GlobalLock( WinClipAPI.GlobalAlloc( 0x0042, dataSize ) ) )
      {
        offset += dataSize
        continue
      }
      WinClipAPI.memcopy( pData, &data + offset, dataSize )
      if ( fmt == this.ClipboardFormats.CF_ENHMETAFILE )
        pClipData := WinClipAPI.SetEnhMetaFileBits( pData, dataSize )
      else
        pClipData := pData
      if !pClipData
        continue
      WinClipAPI.SetClipboardData( fmt, pClipData )
      if ( fmt == this.ClipboardFormats.CF_ENHMETAFILE )
        WinClipAPI.DeleteEnhMetaFile( pClipData )
      WinClipAPI.GlobalUnlock( pData )
      offset += dataSize
      lastPartOffset := offset
    }
    WinClipAPI.CloseClipboard()
    return lastPartOffset
  }

  _fromclipboard( ByRef clipData )
  {
    if !WinClipAPI.OpenClipboard()
      return 0
    nextformat := 0
    objFormats := object()
    clipSize := 0
    formatsNum := 0
    while ( nextformat := WinClipAPI.EnumClipboardFormats( nextformat ) )
    {
      if this.skipFormats.hasKey( nextformat )
        continue
      if ( dataHandle := WinClipAPI.GetClipboardData( nextformat ) )
      {
        pObjPtr := 0, nObjSize := 0
        if ( nextFormat == this.ClipboardFormats.CF_ENHMETAFILE )
        {
          if ( bufSize := WinClipAPI.GetEnhMetaFileBits( dataHandle, hemfBuf ) )
            pObjPtr := &hemfBuf, nObjSize := bufSize
        }
        else if ( nSize := WinClipAPI.GlobalSize( WinClipAPI.GlobalLock( dataHandle ) ) )
          pObjPtr := dataHandle, nObjSize := nSize
        else
          continue
        if !( pObjPtr && nObjSize )
          continue
        objFormats[ nextformat ] := { handle : pObjPtr, size : nObjSize }
        clipSize += nObjSize
        formatsNum++
      }
    }
    structSize := formatsNum*( 4 + 4 ) + clipSize  ;allocating 4 bytes for format ID and 4 for data size
    if !structSize
      return 0
    VarSetCapacity( clipData, structSize, 0 )
    ; array in form of:
    ; format   UInt
    ; dataSize UInt
    ; data     Byte[]
    offset := 0
    for fmt, params in objFormats
    {
      NumPut( fmt, &clipData, offset, "UInt" )
      offset += 4
      NumPut( params.size, &clipData, offset, "UInt" )
      offset += 4
      WinClipAPI.memcopy( &clipData + offset, params.handle, params.size )
      offset += params.size
      WinClipAPI.GlobalUnlock( params.handle )
    }
    WinClipAPI.CloseClipboard()
    return structSize
  }

  _IsInstance( funcName )
  {
    if !this.isinstance
    {
      throw Exception( "Error in '" funcName "':`nInstantiate the object first to use this method!", -1 )
      return 0
    }
    return 1
  }

  _loadFile( filePath, ByRef Data )
  {
    f := FileOpen( filePath, "r","CP0" )
    if !IsObject( f )
      return 0
    dataSize := f.RawRead( Data, f.Length )
    f.close()
    return dataSize
  }

  _saveFile( filepath, byRef data, size )
  {
    f := FileOpen( filepath, "w","CP0" )
    bytes := f.RawWrite( &data, size )
    f.close()
    return bytes
  }

  _setClipData( ByRef data, size )
  {
    if !size
      return 0
    if !ObjSetCapacity( this, "allData", size )
      return 0
    if !( pData := ObjGetAddress( this, "allData" ) )
      return 0
    WinClipAPI.memcopy( pData, &data, size )
    return size
  }

  _getClipData( ByRef data )
  {
    if !( clipSize := ObjGetCapacity( this, "allData" ) )
      return 0
    if !( pData := ObjGetAddress( this, "allData" ) )
      return 0
    VarSetCapacity( data, clipSize, 0 )
    WinClipAPI.memcopy( &data, pData, clipSize )
    return clipSize
  }

  _parseClipboardData( ByRef data, size )
  {
    offset := 0
    formats := object()
    while ( offset < size )
    {
      if !( fmt := NumGet( data, offset, "UInt" ) )
        break
      offset += 4
      if !( dataSize := NumGet( data, offset, "UInt" ) )
        break
      offset += 4
      if ( ( offset + dataSize ) > size )
        break
      params := { name : this._getFormatName( fmt ), size : dataSize }
      ObjSetCapacity( params, "buffer", dataSize )
      pBuf := ObjGetAddress( params, "buffer" )
      WinClipAPI.memcopy( pBuf, &data + offset, dataSize )
      formats[ fmt ] := params
      offset += dataSize
    }
    return formats
  }

  _compileClipData( ByRef out_data, objClip )
  {
    if !IsObject( objClip )
      return 0
    ; calculating required data size
    clipSize := 0
    for fmt, params in objClip
      clipSize += 8 + params.size
    VarSetCapacity( out_data, clipSize, 0 )
    offset := 0
    for fmt, params in objClip
    {
      NumPut( fmt, out_data, offset, "UInt" )
      offset += 4
      NumPut( params.size, out_data, offset, "UInt" )
      offset += 4
      WinClipAPI.memcopy( &out_data + offset, ObjGetAddress( params, "buffer" ), params.size )
      offset += params.size
    }
    return clipSize
  }

  GetFormats()
  {
    if !( clipSize := this._fromclipboard( clipData ) )
      return 0
    return this._parseClipboardData( clipData, clipSize )
  }

  iGetFormats()
  {
    this._IsInstance( A_ThisFunc )
    if !( clipSize := this._getClipData( clipData ) )
      return 0
    return this._parseClipboardData( clipData, clipSize )
  }

  Snap( ByRef data )
  {
    return this._fromclipboard( data )
  }

  iSnap()
  {
    this._IsInstance( A_ThisFunc )
    if !( dataSize := this._fromclipboard( clipData ) )
      return 0
    return this._setClipData( clipData, dataSize )
  }

  Restore( ByRef clipData )
  {
    clipSize := VarSetCapacity( clipData )
    return this._toclipboard( clipData, clipSize )
  }

  iRestore()
  {
    this._IsInstance( A_ThisFunc )
    if !( clipSize := this._getClipData( clipData ) )
      return 0
    return this._toclipboard( clipData, clipSize )
  }

  Save( filePath )
  {
    if !( size := this._fromclipboard( data ) )
      return 0
    return this._saveFile( filePath, data, size )
  }

  iSave( filePath )
  {
    this._IsInstance( A_ThisFunc )
    if !( clipSize := this._getClipData( clipData ) )
          return 0
    return this._saveFile( filePath, clipData, clipSize )
  }

  Load( filePath )
  {
    if !( dataSize := this._loadFile( filePath, dataBuf ) )
      return 0
    return this._toclipboard( dataBuf, dataSize )
  }

  iLoad( filePath )
  {
    this._IsInstance( A_ThisFunc )
    if !( dataSize := this._loadFile( filePath, dataBuf ) )
      return 0
    return this._setClipData( dataBuf, dataSize )
  }

  Clear()
  {
    if !WinClipAPI.OpenClipboard()
      return 0
    WinClipAPI.EmptyClipboard()
    WinClipAPI.CloseClipboard()
    return 1
  }

  iClear()
  {
    this._IsInstance( A_ThisFunc )
    ObjSetCapacity( this, "allData", 0 )
  }

  Copy( timeout = 1 )
  {
    this.Snap( data )
    this.Clear()    ;clearing the clipboard
    ; ~ SendInput, ^{vk43sc02E} ;ctrl+c
    SendInput, ^{Ins}
    ClipWait,% timeout, 1
    if ( ret := this._isClipEmpty() )
      this.Restore( data )
    return !ret
  }

  iCopy( timeout = 1 )
  {
    this._IsInstance( A_ThisFunc )
    this.Snap( data )
    this.Clear()    ;clearing the clipboard
    ; ~ SendInput, ^{vk43sc02E} ;ctrl+c
    SendInput, ^{Ins}
    ClipWait,% timeout, 1
    bytesCopied := 0
    if !this._isClipEmpty()
    {
      this.iClear()   ;clearing the variable containing the clipboard data
      bytesCopied := this.iSnap()
    }
    this.Restore( data )
    return bytesCopied
  }

  Paste( plainText = "" )
  {
    ret := 0
    if ( plainText != "" )
    {
      this.Snap( data )
      this.Clear()
      ret := this.SetText( plainText )
    }
    ; ~ SendInput, ^{vk56sc02F} ;ctrl+v
    SendInput, +{Ins}
    this._waitClipReady( 3000 )
    if ( plainText != "" )
    {
      this.Restore( data )
    }
    else
      ret := !this._isClipEmpty()
    return ret
  }

  iPaste()
  {
    this._IsInstance( A_ThisFunc )
    this.Snap( data )
    if !( bytesRestored := this.iRestore() )
      return 0
    ; ~ SendInput, ^{vk56sc02F} ;ctrl+v
    SendInput, +{Ins}
    this._waitClipReady( 3000 )
    this.Restore( data )
    return bytesRestored
  }

  IsEmpty()
  {
    return this._isClipEmpty()
  }

  iIsEmpty()
  {
    return !this.iGetSize()
  }

  _isClipEmpty()
  {
    return !WinClipAPI.CountClipboardFormats()
  }

  _waitClipReady( timeout = 10000 )
  {
    start_time := A_TickCount
    sleep 100
    while ( WinClipAPI.GetOpenClipboardWindow() && ( A_TickCount - start_time < timeout ) )
      sleep 100
  }

  iSetText( textData )
  {
    if ( textData = "" )
      return 0
    this._IsInstance( A_ThisFunc )
    clipSize := this._getClipData( clipData )
    if !( clipSize := this._appendText( clipData, clipSize, textData, 1 ) )
      return 0
    return this._setClipData( clipData, clipSize )
  }

  SetText( textData )
  {
    if ( textData = "" )
      return 0
    clipSize :=  this._fromclipboard( clipData )
    if !( clipSize := this._appendText( clipData, clipSize, textData, 1 ) )
      return 0
    return this._toclipboard( clipData, clipSize )
  }

  GetRTF()
  {
    if !( clipSize := this._fromclipboard( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, "Rich Text Format" ) )
      return ""
    return strget( &out_data, out_size, "CP0" )
  }

  iGetRTF()
  {
    this._IsInstance( A_ThisFunc )
    if !( clipSize := this._getClipData( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, "Rich Text Format" ) )
      return ""
    return strget( &out_data, out_size, "CP0" )
  }

  SetRTF( textData )
  {
    if ( textData = "" )
      return 0
    clipSize :=  this._fromclipboard( clipData )
    if !( clipSize := this._setRTF( clipData, clipSize, textData ) )
          return 0
    return this._toclipboard( clipData, clipSize )
  }

  iSetRTF( textData )
  {
    if ( textData = "" )
      return 0
    this._IsInstance( A_ThisFunc )
    clipSize :=  this._getClipData( clipData )
    if !( clipSize := this._setRTF( clipData, clipSize, textData ) )
          return 0
    return this._setClipData( clipData, clipSize )
  }

  _setRTF( ByRef clipData, clipSize, textData )
  {
    objFormats := this._parseClipboardData( clipData, clipSize )
    uFmt := WinClipAPI.RegisterClipboardFormat( "Rich Text Format" )
    objFormats[ uFmt ] := object()
    sLen := StrLen( textData )
    ObjSetCapacity( objFormats[ uFmt ], "buffer", sLen )
    StrPut( textData, ObjGetAddress( objFormats[ uFmt ], "buffer" ), sLen, "CP0" )
    objFormats[ uFmt ].size := sLen
    return this._compileClipData( clipData, objFormats )
  }

  iAppendText( textData )
  {
    if ( textData = "" )
      return 0
    this._IsInstance( A_ThisFunc )
    clipSize := this._getClipData( clipData )
    if !( clipSize := this._appendText( clipData, clipSize, textData ) )
      return 0
    return this._setClipData( clipData, clipSize )
  }

  AppendText( textData )
  {
    if ( textData = "" )
      return 0
    clipSize :=  this._fromclipboard( clipData )
    if !( clipSize := this._appendText( clipData, clipSize, textData ) )
      return 0
    return this._toclipboard( clipData, clipSize )
  }

  SetHTML( html, source = "" )
  {
    if ( html = "" )
      return 0
    clipSize :=  this._fromclipboard( clipData )
    if !( clipSize := this._setHTML( clipData, clipSize, html, source ) )
      return 0
    return this._toclipboard( clipData, clipSize )
  }

  iSetHTML( html, source = "" )
  {
    if ( html = "" )
      return 0
    this._IsInstance( A_ThisFunc )
    clipSize := this._getClipData( clipData )
    if !( clipSize := this._setHTML( clipData, clipSize, html, source ) )
      return 0
    return this._setClipData( clipData, clipSize )
  }

  _calcHTMLLen( num )
  {
    while ( StrLen( num ) < 10 )
      num := "0" . num
    return num
  }

  _setHTML( ByRef clipData, clipSize, htmlData, source )
  {
    objFormats := this._parseClipboardData( clipData, clipSize )
    uFmt := WinClipAPI.RegisterClipboardFormat( "HTML Format" )
    objFormats[ uFmt ] := object()
    encoding := "UTF-8"
    htmlLen := StrPut( htmlData, encoding ) - 1   ;substract null
    srcLen := 2 + 10 + StrPut( source, encoding ) - 1      ;substract null
    StartHTML := this._calcHTMLLen( 105 + srcLen )
    EndHTML := this._calcHTMLLen( StartHTML + htmlLen + 76 )
    StartFragment := this._calcHTMLLen( StartHTML + 38 )
    EndFragment := this._calcHTMLLen( StartFragment + htmlLen )
    html =
    ( Join`r`n
Version:0.9
StartHTML:%StartHTML%
EndHTML:%EndHTML%
StartFragment:%StartFragment%
EndFragment:%EndFragment%
SourceURL:%source%
<html>
<body>
<!--StartFragment-->
%htmlData%
<!--EndFragment-->
</body>
</html>
    )
    sLen := StrPut( html, encoding )
    ObjSetCapacity( objFormats[ uFmt ], "buffer", sLen )
    StrPut( html, ObjGetAddress( objFormats[ uFmt ], "buffer" ), sLen, encoding )
    objFormats[ uFmt ].size := sLen
    return this._compileClipData( clipData, objFormats )
  }

  _appendText( ByRef clipData, clipSize, textData, IsSet = 0 )
  {
    objFormats := this._parseClipboardData( clipData, clipSize )
    uFmt := this.ClipboardFormats.CF_UNICODETEXT
    str := ""
    if ( objFormats.haskey( uFmt ) && !IsSet )
      str := strget( ObjGetAddress( objFormats[ uFmt ],  "buffer" ), "UTF-16" )
    else
      objFormats[ uFmt ] := object()
    str .= textData
    sLen := ( StrLen( str ) + 1 ) * 2
    ObjSetCapacity( objFormats[ uFmt ], "buffer", sLen )
    StrPut( str, ObjGetAddress( objFormats[ uFmt ], "buffer" ), sLen, "UTF-16" )
    objFormats[ uFmt ].size := sLen
    return this._compileClipData( clipData, objFormats )
  }

  _getFiles( pDROPFILES )
  {
    fWide := numget( pDROPFILES + 0, 16, "uchar" ) ;getting fWide value from DROPFILES struct
    pFiles := numget( pDROPFILES + 0, 0, "UInt" ) + pDROPFILES  ;getting address of files list
    list := ""
    while numget( pFiles + 0, 0, fWide ? "UShort" : "UChar" )
    {
      lastPath := strget( pFiles+0, fWide ? "UTF-16" : "CP0" )
      list .= ( list ? "`n" : "" ) lastPath
      pFiles += ( StrLen( lastPath ) + 1 ) * ( fWide ? 2 : 1 )
    }
    return list
  }

  _setFiles( ByRef clipData, clipSize, files, append = 0, isCut = 0 )
  {
    objFormats := this._parseClipboardData( clipData, clipSize )
    uFmt := this.ClipboardFormats.CF_HDROP
    if ( append && objFormats.haskey( uFmt ) )
      prevList := this._getFiles( ObjGetAddress( objFormats[ uFmt ], "buffer" ) ) "`n"
    objFiles := WinClipAPI.StrSplit( prevList . files, "`n", A_Space A_Tab )
    objFiles := WinClipAPI.RemoveDubls( objFiles )
    if !objFiles.MaxIndex()
      return 0
    objFormats[ uFmt ] := object()
    DROP_size := 20 + 2
    for i,str in objFiles
      DROP_size += ( StrLen( str ) + 1 ) * 2
    VarSetCapacity( DROPFILES, DROP_size, 0 )
    NumPut( 20, DROPFILES, 0, "UInt" )  ;offset
    NumPut( 1, DROPFILES, 16, "uchar" ) ;NumPut( 20, DROPFILES, 0, "UInt" )
    offset := &DROPFILES + 20
    for i,str in objFiles
    {
      StrPut( str, offset, "UTF-16" )
      offset += ( StrLen( str ) + 1 ) * 2
    }
    ObjSetCapacity( objFormats[ uFmt ], "buffer", DROP_size )
    WinClipAPI.memcopy( ObjGetAddress( objFormats[ uFmt ], "buffer" ), &DROPFILES, DROP_size )
    objFormats[ uFmt ].size := DROP_size
    prefFmt := WinClipAPI.RegisterClipboardFormat( "Preferred DropEffect" )
    objFormats[ prefFmt ] := { size : 4 }
    ObjSetCapacity( objFormats[ prefFmt ], "buffer", 4 )
    NumPut( isCut ? 2 : 5, ObjGetAddress( objFormats[ prefFmt ], "buffer" ), 0 "UInt" )
    return this._compileClipData( clipData, objFormats )
  }

  SetFiles( files, isCut = 0 )
  {
    if ( files = "" )
      return 0
    clipSize := this._fromclipboard( clipData )
    if !( clipSize := this._setFiles( clipData, clipSize, files, 0, isCut ) )
      return 0
    return this._toclipboard( clipData, clipSize )
  }

  iSetFiles( files, isCut = 0 )
  {
    this._IsInstance( A_ThisFunc )
    if ( files = "" )
      return 0
    clipSize := this._getClipData( clipData )
    if !( clipSize := this._setFiles( clipData, clipSize, files, 0, isCut ) )
      return 0
    return this._setClipData( clipData, clipSize )
  }

  AppendFiles( files, isCut = 0 )
  {
    if ( files = "" )
      return 0
    clipSize := this._fromclipboard( clipData )
    if !( clipSize := this._setFiles( clipData, clipSize, files, 1, isCut ) )
      return 0
    return this._toclipboard( clipData, clipSize )
  }

  iAppendFiles( files, isCut = 0 )
  {
    this._IsInstance( A_ThisFunc )
    if ( files = "" )
      return 0
    clipSize := this._getClipData( clipData )
    if !( clipSize := this._setFiles( clipData, clipSize, files, 1, isCut ) )
      return 0
    return this._setClipData( clipData, clipSize )
  }

  GetFiles()
  {
    if !( clipSize := this._fromclipboard( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_HDROP ) )
      return ""
    return this._getFiles( &out_data )
  }

  iGetFiles()
  {
    this._IsInstance( A_ThisFunc )
    if !( clipSize := this._getClipData( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_HDROP ) )
      return ""
    return this._getFiles( &out_data )
  }

  _getFormatData( ByRef out_data, ByRef data, size, needleFormat )
  {
    needleFormat := WinClipAPI.IsInteger( needleFormat ) ? needleFormat : WinClipAPI.RegisterClipboardFormat( needleFormat )
    if !needleFormat
      return 0
    offset := 0
    while ( offset < size )
    {
      if !( fmt := NumGet( data, offset, "UInt" ) )
        break
      offset += 4
      if !( dataSize := NumGet( data, offset, "UInt" ) )
        break
      offset += 4
      if ( fmt == needleFormat )
      {
        VarSetCapacity( out_data, dataSize, 0 )
        WinClipAPI.memcopy( &out_data, &data + offset, dataSize )
        return dataSize
      }
      offset += dataSize
    }
    return 0
  }

  _DIBtoHBITMAP( ByRef dibData )
  {
    ; http://ebersys.blogspot.com/2009/06/how-to-convert-dib-to-bitmap.html
    pPix := WinClipAPI.GetPixelInfo( dibData )
    gdip_token := WinClipAPI.Gdip_Startup()
    DllCall("gdiplus\GdipCreateBitmapFromGdiDib", "Ptr", &dibData, "Ptr", pPix, "Ptr*", pBitmap )
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "Ptr*", hBitmap, "int", 0xffffffff )
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    WinClipAPI.Gdip_Shutdown( gdip_token )
    return hBitmap
  }

  GetBitmap()
  {
    if !( clipSize := this._fromclipboard( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_DIB ) )
      return ""
    return this._DIBtoHBITMAP( out_data )
  }

  iGetBitmap()
  {
    this._IsInstance( A_ThisFunc )
    if !( clipSize := this._getClipData( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_DIB ) )
      return ""
    return this._DIBtoHBITMAP( out_data )
  }

  _BITMAPtoDIB( bitmap, ByRef DIB )
  {
    if !bitmap
      return 0
    if !WinClipAPI.IsInteger( bitmap )
    {
      gdip_token := WinClipAPI.Gdip_Startup()
      DllCall("gdiplus\GdipCreateBitmapFromFileICM", "wstr", bitmap, "Ptr*", pBitmap )
      DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "Ptr*", hBitmap, "int", 0xffffffff )
      DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
      WinClipAPI.Gdip_Shutdown( gdip_token )
      bmMade := 1
    }
    else
      hBitmap := bitmap, bmMade := 0
    if !hBitmap
        return 0
    ; http://www.codeguru.com/Cpp/G-M/bitmap/article.php/c1765
    if !( hdc := DllCall( "GetDC", "Ptr", 0 ) )
      goto, _BITMAPtoDIB_cleanup
    hPal := DllCall( "GetStockObject", "UInt", 15 ) ;DEFAULT_PALLETE
    hPal := DllCall( "SelectPalette", "ptr", hdc, "ptr", hPal, "Uint", 0 )
    DllCall( "RealizePalette", "ptr", hdc )
    size := DllCall( "GetObject", "Ptr", hBitmap, "Uint", 0, "ptr", 0 )
    VarSetCapacity( bm, size, 0 )
    DllCall( "GetObject", "Ptr", hBitmap, "Uint", size, "ptr", &bm )
    biBitCount := NumGet( bm, 16, "UShort" )*NumGet( bm, 18, "UShort" )
    nColors := (1 << biBitCount)
    if ( nColors > 256 )
        nColors := 0
    bmiLen  := 40 + nColors * 4
    VarSetCapacity( bmi, bmiLen, 0 )
    ; BITMAPINFOHEADER initialization
    NumPut( 40, bmi, 0, "Uint" )
    NumPut( NumGet( bm, 4, "Uint" ), bmi, 4, "Uint" )   ;width
    NumPut( biHeight := NumGet( bm, 8, "Uint" ), bmi, 8, "Uint" ) ;height
    NumPut( 1, bmi, 12, "UShort" )
    NumPut( biBitCount, bmi, 14, "UShort" )
    NumPut( 0, bmi, 16, "UInt" ) ;compression must be BI_RGB

    ; Get BITMAPINFO.
    if !DllCall("GetDIBits"
              ,"ptr",hdc
              ,"ptr",hBitmap
              ,"uint",0
              ,"uint",biHeight
              ,"ptr",0      ;lpvBits
              ,"ptr",&bmi  ;lpbi
              ,"uint",0)    ;DIB_RGB_COLORS
      goto, _BITMAPtoDIB_cleanup
    biSizeImage := NumGet( &bmi, 20, "UInt" )
    if ( biSizeImage = 0 )
    {
      biBitCount := numget( &bmi, 14, "UShort" )
      biWidth := numget( &bmi, 4, "UInt" )
      biHeight := numget( &bmi, 8, "UInt" )
      biSizeImage := (((( biWidth * biBitCount + 31 ) & ~31 ) >> 3 ) * biHeight )
      ; ~ dwCompression := numget( bmi, 16, "UInt" )
      ; ~ if ( dwCompression != 0 ) ;BI_RGB
        ; ~ biSizeImage := ( biSizeImage * 3 ) / 2
      numput( biSizeImage, &bmi, 20, "UInt" )
    }
    DIBLen := bmiLen + biSizeImage
    VarSetCapacity( DIB, DIBLen, 0 )
    WinClipAPI.memcopy( &DIB, &bmi, bmiLen )
    if !DllCall("GetDIBits"
              ,"ptr",hdc
              ,"ptr",hBitmap
              ,"uint",0
              ,"uint",biHeight
              ,"ptr",&DIB + bmiLen     ;lpvBits
              ,"ptr",&DIB  ;lpbi
              ,"uint",0)    ;DIB_RGB_COLORS
      goto, _BITMAPtoDIB_cleanup
_BITMAPtoDIB_cleanup:
    if bmMade
      DllCall( "DeleteObject", "ptr", hBitmap )
    DllCall( "SelectPalette", "ptr", hdc, "ptr", hPal, "Uint", 0 )
    DllCall( "RealizePalette", "ptr", hdc )
    DllCall("ReleaseDC","ptr",hdc)
    if ( A_ThisLabel = "_BITMAPtoDIB_cleanup" )
      return 0
    return DIBLen
  }

  _setBitmap( ByRef DIB, DIBSize, ByRef clipData, clipSize )
  {
    objFormats := this._parseClipboardData( clipData, clipSize )
    uFmt := this.ClipboardFormats.CF_DIB
    objFormats[ uFmt ] := { size : DIBSize }
    ObjSetCapacity( objFormats[ uFmt ], "buffer", DIBSize )
    WinClipAPI.memcopy( ObjGetAddress( objFormats[ uFmt ], "buffer" ), &DIB, DIBSize )
    return this._compileClipData( clipData, objFormats )
  }

  SetBitmap( bitmap )
  {
    if ( DIBSize := this._BITMAPtoDIB( bitmap, DIB ) )
    {
      clipSize := this._fromclipboard( clipData )
      if ( clipSize := this._setBitmap( DIB, DIBSize, clipData, clipSize ) )
        return this._toclipboard( clipData, clipSize )
    }
    return 0
  }

  iSetBitmap( bitmap )
  {
    this._IsInstance( A_ThisFunc )
    if ( DIBSize := this._BITMAPtoDIB( bitmap, DIB ) )
    {
      clipSize := this._getClipData( clipData )
      if ( clipSize := this._setBitmap( DIB, DIBSize, clipData, clipSize ) )
        return this._setClipData( clipData, clipSize )
    }
    return 0
  }

  GetText()
  {
    if !( clipSize := this._fromclipboard( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_UNICODETEXT ) )
      return ""
    return strget( &out_data, out_size, "UTF-16" )
  }

  iGetText()
  {
    this._IsInstance( A_ThisFunc )
    if !( clipSize := this._getClipData( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_UNICODETEXT ) )
      return ""
    return strget( &out_data, out_size, "UTF-16" )
  }

  GetHtml()
  {
    if !( clipSize := this._fromclipboard( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, "HTML Format" ) )
      return ""
    return strget( &out_data, out_size, "CP0" )
  }

  iGetHtml()
  {
    this._IsInstance( A_ThisFunc )
    if !( clipSize := this._getClipData( clipData ) )
      return ""
    if !( out_size := this._getFormatData( out_data, clipData, clipSize, "HTML Format" ) )
      return ""
    return strget( &out_data, out_size, "CP0" )
  }

  _getFormatName( iformat )
  {
    if this.formatByValue.HasKey( iformat )
      return this.formatByValue[ iformat ]
    else
      return WinClipAPI.GetClipboardFormatName( iformat )
  }

  iGetData( ByRef Data )
  {
    this._IsInstance( A_ThisFunc )
    return this._getClipData( Data )
  }

  iSetData( ByRef data )
  {
    this._IsInstance( A_ThisFunc )
    return this._setClipData( data, VarSetCapacity( data ) )
  }

  iGetSize()
  {
    this._IsInstance( A_ThisFunc )
    return ObjGetCapacity( this, "alldata" )
  }

  HasFormat( fmt )
  {
    if !fmt
      return 0
    return WinClipAPI.IsClipboardFormatAvailable( WinClipAPI.IsInteger( fmt ) ? fmt
                                                                                  : WinClipAPI.RegisterClipboardFormat( fmt )  )
  }

  iHasFormat( fmt )
  {
    this._IsInstance( A_ThisFunc )
    if !( clipSize := this._getClipData( clipData ) )
      return 0
    return this._hasFormat( clipData, clipSize, fmt )
  }

  _hasFormat( ByRef data, size, needleFormat )
  {
    needleFormat := WinClipAPI.IsInteger( needleFormat ) ? needleFormat
                                                                  : WinClipAPI.RegisterClipboardFormat( needleFormat )
    if !needleFormat
      return 0
    offset := 0
    while ( offset < size )
    {
      if !( fmt := NumGet( data, offset, "UInt" ) )
        break
      if ( fmt == needleFormat )
        return 1
      offset += 4
      if !( dataSize := NumGet( data, offset, "UInt" ) )
        break
      offset += 4 + dataSize
    }
    return 0
  }

  iSaveBitmap( filePath, format )
  {
    this._IsInstance( A_ThisFunc )
    if ( filePath = "" || format = "" )
      return 0
    if !( clipSize := this._getClipData( clipData ) )
      return 0
    if !( DIBsize := this._getFormatData( DIB, clipData, clipSize, this.ClipboardFormats.CF_DIB ) )
      return 0
    gdip_token := WinClipAPI.Gdip_Startup()
    if !WinClipAPI.GetEncoderClsid( format, CLSID )
      return 0
    DllCall("gdiplus\GdipCreateBitmapFromGdiDib", "Ptr", &DIB, "Ptr", WinClipAPI.GetPixelInfo( DIB ), "Ptr*", pBitmap )
    DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "wstr", filePath, "Ptr", &CLSID, "Ptr", 0 )
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    WinClipAPI.Gdip_Shutdown( gdip_token )
    return 1
  }

  SaveBitmap( filePath, format )
  {
    if ( filePath = "" || format = "" )
      return 0
    if !( clipSize := this._fromclipboard( clipData ) )
      return 0
    if !( DIBsize := this._getFormatData( DIB, clipData, clipSize, this.ClipboardFormats.CF_DIB ) )
      return 0
    gdip_token := WinClipAPI.Gdip_Startup()
    if !WinClipAPI.GetEncoderClsid( format, CLSID )
      return 0
    DllCall("gdiplus\GdipCreateBitmapFromGdiDib", "Ptr", &DIB, "Ptr", WinClipAPI.GetPixelInfo( DIB ), "Ptr*", pBitmap )
    DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "wstr", filePath, "Ptr", &CLSID, "Ptr", 0 )
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    WinClipAPI.Gdip_Shutdown( gdip_token )
    return 1
  }

  static ClipboardFormats := { CF_BITMAP : 2 ;A handle to a bitmap (HBITMAP).
                              ,CF_DIB : 8  ;A memory object containing a BITMAPINFO structure followed by the bitmap bits.
                              ,CF_DIBV5 : 17 ;A memory object containing a BITMAPV5HEADER structure followed by the bitmap color space information and the bitmap bits.
                              ,CF_DIF : 5 ;Software Arts' Data Interchange Format.
                              ,CF_DSPBITMAP : 0x0082 ;Bitmap display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in bitmap format in lieu of the privately formatted data.
                              ,CF_DSPENHMETAFILE : 0x008E ;Enhanced metafile display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in enhanced metafile format in lieu of the privately formatted data.
                              ,CF_DSPMETAFILEPICT : 0x0083 ;Metafile-picture display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in metafile-picture format in lieu of the privately formatted data.
                              ,CF_DSPTEXT : 0x0081 ;Text display format associated with a private format. The hMem parameter must be a handle to data that can be displayed in text format in lieu of the privately formatted data.
                              ,CF_ENHMETAFILE : 14 ;A handle to an enhanced metafile (HENHMETAFILE).
                              ,CF_GDIOBJFIRST : 0x0300 ;Start of a range of integer values for application-defined GDI object clipboard formats. The end of the range is CF_GDIOBJLAST.Handles associated with clipboard formats in this range are not automatically deleted using the GlobalFree function when the clipboard is emptied. Also, when using values in this range, the hMem parameter is not a handle to a GDI object, but is a handle allocated by the GlobalAlloc function with the GMEM_MOVEABLE flag.
                              ,CF_GDIOBJLAST : 0x03FF ;See CF_GDIOBJFIRST.
                              ,CF_HDROP : 15 ;A handle to type HDROP that identifies a list of files. An application can retrieve information about the files by passing the handle to the DragQueryFile function.
                              ,CF_LOCALE : 16 ;The data is a handle to the locale identifier associated with text in the clipboard. When you close the clipboard, if it contains CF_TEXT data but no CF_LOCALE data, the system automatically sets the CF_LOCALE format to the current input language. You can use the CF_LOCALE format to associate a different locale with the clipboard text. An application that pastes text from the clipboard can retrieve this format to determine which character set was used to generate the text. Note that the clipboard does not support plain text in multiple character sets. To achieve this, use a formatted text data type such as RTF instead. The system uses the code page associated with CF_LOCALE to implicitly convert from CF_TEXT to CF_UNICODETEXT. Therefore, the correct code page table is used for the conversion.
                              ,CF_METAFILEPICT : 3 ;Handle to a metafile picture format as defined by the METAFILEPICT structure. When passing a CF_METAFILEPICT handle by means of DDE, the application responsible for deleting hMem should also free the metafile referred to by the CF_METAFILEPICT handle.
                              ,CF_OEMTEXT : 7 ;Text format containing characters in the OEM character set. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
                              ,CF_OWNERDISPLAY : 0x0080 ;Owner-display format. The clipboard owner must display and update the clipboard viewer window, and receive the WM_ASKCBFORMATNAME, WM_HSCROLLCLIPBOARD, WM_PAINTCLIPBOARD, WM_SIZECLIPBOARD, and WM_VSCROLLCLIPBOARD messages. The hMem parameter must be NULL.
                              ,CF_PALETTE : 9 ;Handle to a color palette. Whenever an application places data in the clipboard that depends on or assumes a color palette, it should place the palette on the clipboard as well.If the clipboard contains data in the CF_PALETTE (logical color palette) format, the application should use the SelectPalette and RealizePalette functions to realize (compare) any other data in the clipboard against that logical palette.When displaying clipboard data, the clipboard always uses as its current palette any object on the clipboard that is in the CF_PALETTE format.
                              ,CF_PENDATA : 10 ;Data for the pen extensions to the Microsoft Windows for Pen Computing.
                              ,CF_PRIVATEFIRST : 0x0200 ;Start of a range of integer values for private clipboard formats. The range ends with CF_PRIVATELAST. Handles associated with private clipboard formats are not freed automatically; the clipboard owner must free such handles, typically in response to the WM_DESTROYCLIPBOARD message.
                              ,CF_PRIVATELAST : 0x02FF ;See CF_PRIVATEFIRST.
                              ,CF_RIFF : 11 ;Represents audio data more complex than can be represented in a CF_WAVE standard wave format.
                              ,CF_SYLK : 4 ;Microsoft Symbolic Link (SYLK) format.
                              ,CF_TEXT : 1 ;Text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data. Use this format for ANSI text.
                              ,CF_TIFF : 6 ;Tagged-image file format.
                              ,CF_UNICODETEXT : 13 ;Unicode text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
                              ,CF_WAVE : 12 } ;Represents audio data in one of the standard wave formats, such as 11 kHz or 22 kHz PCM.

  static WM_COPY := 0x301
        ,WM_CLEAR := 0x0303
        ,WM_CUT := 0x0300
        ,WM_PASTE := 0x0302

  static skipFormats := {   2      : 0 ;"CF_BITMAP"
                              ,17     : 0 ;"CF_DIBV5"
                              ,0x0082 : 0 ;"CF_DSPBITMAP"
                              ,0x008E : 0 ;"CF_DSPENHMETAFILE"
                              ,0x0083 : 0 ;"CF_DSPMETAFILEPICT"
                              ,0x0081 : 0 ;"CF_DSPTEXT"
                              ,0x0080 : 0 ;"CF_OWNERDISPLAY"
                              ,3      : 0 ;"CF_METAFILEPICT"
                              ,7      : 0 ;"CF_OEMTEXT"
                              ,1      : 0 } ;"CF_TEXT"

  static formatByValue := { 2 : "CF_BITMAP"
                              ,8 : "CF_DIB"
                              ,17 : "CF_DIBV5"
                              ,5 : "CF_DIF"
                              ,0x0082 : "CF_DSPBITMAP"
                              ,0x008E : "CF_DSPENHMETAFILE"
                              ,0x0083 : "CF_DSPMETAFILEPICT"
                              ,0x0081 : "CF_DSPTEXT"
                              ,14 : "CF_ENHMETAFILE"
                              ,0x0300 : "CF_GDIOBJFIRST"
                              ,0x03FF : "CF_GDIOBJLAST"
                              ,15 : "CF_HDROP"
                              ,16 : "CF_LOCALE"
                              ,3 : "CF_METAFILEPICT"
                              ,7 : "CF_OEMTEXT"
                              ,0x0080 : "CF_OWNERDISPLAY"
                              ,9 : "CF_PALETTE"
                              ,10 : "CF_PENDATA"
                              ,0x0200 : "CF_PRIVATEFIRST"
                              ,0x02FF : "CF_PRIVATELAST"
                              ,11 : "CF_RIFF"
                              ,4 : "CF_SYLK"
                              ,1 : "CF_TEXT"
                              ,6 : "CF_TIFF"
                              ,13 : "CF_UNICODETEXT"
                              ,12 : "CF_WAVE" }
}

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
          ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200        ;dwflags
          ,"Ptr",0        ;lpSource
          ,"UInt",error_id    ;dwMessageId
          ,"UInt",0            ;dwLanguageId
          ,"Ptr",&msg            ;lpBuffer
          ,"UInt",500)            ;nSize
      return
    return     strget(&msg,len)
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
          ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM := 0x00001000 | FORMAT_MESSAGE_IGNORE_INSERTS := 0x00000200        ;dwflags
          ,"Ptr",0        ;lpSource
          ,"UInt",error_id    ;dwMessageId
          ,"UInt",0            ;dwLanguageId
          ,"Ptr",&msg            ;lpBuffer
          ,"UInt",500)            ;nSize
      return
    return     strget(&msg,len)
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
    VarSetCapacity( GuiThreadInfo, GUITHREADINFO_cbsize, 0 )    ;GuiThreadInfoSize = 48
    NumPut(GUITHREADINFO_cbsize, GuiThreadInfo, 0, "UInt")
    threadWnd := this.GetWindowThreadProcessId( hwnd )
    if not DllCall( "GetGUIThreadInfo", "uint", threadWnd, "UPtr", &GuiThreadInfo )
        return 0
    return NumGet( GuiThreadInfo, 8+A_PtrSize,"UPtr")  ; Retrieve the hwndFocus field from the struct.
  }
  GetPixelInfo( ByRef DIB ) {
    ; ~ typedef struct tagBITMAPINFOHEADER {
    ; ~ DWORD biSize;              0
    ; ~ LONG  biWidth;             4
    ; ~ LONG  biHeight;            8
    ; ~ WORD  biPlanes;            12
    ; ~ WORD  biBitCount;          14
    ; ~ DWORD biCompression;       16
    ; ~ DWORD biSizeImage;         20
    ; ~ LONG  biXPelsPerMeter;     24
    ; ~ LONG  biYPelsPerMeter;     28
    ; ~ DWORD biClrUsed;           32
    ; ~ DWORD biClrImportant;      36

    bmi := &DIB  ;BITMAPINFOHEADER  pointer from DIB
    biSize := numget( bmi+0, 0, "UInt" )
    ; ~ return bmi + biSize
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
      StringReplace,str,str,% delim,ƒ,1         ;■¶╬
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
    ; format should be the following
    ; ~ bmp
    ; ~ jpeg
    ; ~ gif
    ; ~ tiff
    ; ~ png
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