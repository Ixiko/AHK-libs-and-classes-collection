class WinClip extends WinClip_base
{
    static isinstance := 1
    static allData := ""

    ; static __New()
    ; {
        ; this.isinstance := 1
        ; this.allData := ""
    ; }
 
    static _toclipboard( ByRef data, size )
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
            WinClipAPI.memcopy( pData, data.Ptr + offset, dataSize )
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
    
    static _fromclipboard( ByRef clipData )
    {
        if !WinClipAPI.OpenClipboard()
            return 0
        nextformat := 0
        objFormats := object()
        clipSize := 0
        formatsNum := 0
        while ( nextformat := WinClipAPI.EnumClipboardFormats( nextformat ) )
        {
            if this.skipFormats.Has( nextformat )
            ; if this.skipFormats.HasOwnProp( nextformat )
                continue
            if ( dataHandle := WinClipAPI.GetClipboardData( nextformat ) )
            {
                pObjPtr := 0, nObjSize := 0
                if ( nextformat == this.ClipboardFormats.CF_ENHMETAFILE )
                {
                    if ( bufSize := WinClipAPI.GetEnhMetaFileBits( dataHandle, hemfBuf ) )
                        pObjPtr := StrPtr(hemfBuf), nObjSize := bufSize
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
        {
            WinClipAPI.CloseClipboard()
            return 0
        }
        ; p structSize ;682
        clipData := BufferAlloc(structSize)
        ; VarSetStrCapacity(clipData,structSize)
        ; array in form of:
        ; format   UInt
        ; dataSize UInt
        ; data     Byte[]
        offset := 0
        ; p objFormats
        for fmt, params in objFormats.OwnProps()
        {
            ; p fmt, params
            NumPut("UInt",fmt,clipData,offset)
            offset += 4
            NumPut("UInt",params.size,clipData,offset)
            offset += 4
            WinClipAPI.memcopy( clipData.Ptr + offset, params.handle, params.size )
            offset += params.size
            WinClipAPI.GlobalUnlock( params.handle )
        }
        WinClipAPI.CloseClipboard()
        return structSize
    }
    
    static _IsInstance( funcName )
    {
        if !this.isinstance
        {
            throw Exception( "Error in '" funcName "':`nInstantiate the object first to use this method!", -1 )
            ; return 0
        }
        return 1
    }
    
    static _loadFile( filePath, ByRef Data )
    {
        f := FileOpen( filePath, "r","CP0" )
        if !IsObject( f )
            return 0
        f.Pos := 0
        dataSize := f.RawRead( Data, f.Length )
        f.close()
        return dataSize
    }

    static _saveFile( filepath, byRef data, size )
    {
        f := FileOpen( filepath, "w","CP0" )
        bytes := f.RawWrite( StrPtr(data), size )
        f.close()
        return bytes
    }

    static _setClipData( ByRef data, size )
    {
        if !size
            return 0
        ; if !ObjSetCapacity( this, "allData", size )
            ; return 0
        this["allData"].Size := size

        if !( pData := StrPtr(this["allData"]) )
            return 0
        WinClipAPI.memcopy( pData, StrPtr(data), size )
        return size
    }
    
    static _getClipData( ByRef data )
    {
        if !( clipSize := this["allData"].Size )
            return 0
        if !( pData := StrPtr(this["allData"]) )
            return 0
        VarSetStrCapacity(data,clipSize)
        WinClipAPI.memcopy( StrPtr(data), pData, clipSize )
        return clipSize
    }
    
    static __Delete()
    {
        this["allData"].Size := 0
        return
    }
    
    static _parseClipboardData( ByRef data, size )
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
            params["buffer"].Size := dataSize
            pBuf := StrPtr(params["buffer"])
            WinClipAPI.memcopy( pBuf, StrPtr(data) + offset, dataSize )
            formats[ fmt ] := params
            offset += dataSize
        }
        return formats
    }
    
    static _compileClipData( ByRef out_data, objClip )
    {
        if !IsObject( objClip )
            return 0
        ;calculating required data size
        clipSize := 0
        for fmt, params in objClip.OwnProps()
            clipSize += 8 + params.size
        out_data:=BufferAlloc(clipSize)
        offset := 0
        for fmt, params in objClip.OwnProps()
        {
            NumPut("UInt",fmt,out_data,offset)
            offset += 4
            NumPut("UInt",params.size,out_data,offset)
            offset += 4
            WinClipAPI.memcopy( out_data.Ptr + offset, params["buffer"], params.size )
            offset += params.size
        }
        return clipSize
    }
    
    static GetFormats()
    {
        if !( clipSize := this._fromclipboard( clipData ) )
            return 0
        return this._parseClipboardData( clipData, clipSize )
    }
    
    static iGetFormats()
    {
        this._IsInstance( A_ThisFunc )
        if !( clipSize := this._getClipData( clipData ) )
            return 0
        return this._parseClipboardData( clipData, clipSize )
    }
    
    static Snap( ByRef data )
    {
        return this._fromclipboard( data )
    }
    
    static iSnap()
    {
        this._IsInstance( A_ThisFunc )
        if !( dataSize := this._fromclipboard( clipData ) )
            return 0
        return this._setClipData( clipData, dataSize )
    }

    static Restore( ByRef clipData )
    {
        clipSize := VarSetStrCapacity(clipData )
        return this._toclipboard( clipData,clipSize )
    }

    static iRestore()
    {
        this._IsInstance( A_ThisFunc )
        if !( clipSize := this._getClipData( clipData ) )
            return 0
        return this._toclipboard( clipData)
    }

    static Save( filePath )
    {
        if !( size := this._fromclipboard( data ) )
            return 0
        return this._saveFile( filePath, data, size )
    }
    
    static iSave( filePath )
    {
        this._IsInstance( A_ThisFunc )
        if !( clipSize := this._getClipData( clipData ) )
                    return 0
        return this._saveFile( filePath, clipData, clipSize )
    }

    static Load( filePath )
    {
        if !( dataSize := this._loadFile( filePath, dataBuf ) )
            return 0
        return this._toclipboard( dataBuf, dataSize )
    }

    static iLoad( filePath )
    {
        this._IsInstance( A_ThisFunc )
        if !( dataSize := this._loadFile( filePath, dataBuf ) )
            return 0
        return this._setClipData( dataBuf, dataSize )
    }

    static Clear()
    {
        if !WinClipAPI.OpenClipboard()
            return 0
        WinClipAPI.EmptyClipboard()
        WinClipAPI.CloseClipboard()
        return 1
    }
    
    static iClear()
    {
        this._IsInstance( A_ThisFunc )
        this["allData"].Size := 0
    }
    
    static Copy( timeout := 1, method := 1 )
    {
        this.Snap( data )
        this.Clear()    ;clearing the A_Clipboard
        if( method = 1 )
            SendInput "^{Ins}"
        else
            SendInput "^{vk43sc02E}" ;ctrl+c
        ClipWait timeout, 1
        if ( ret := this._isClipEmpty() )
            this.Restore( data )
        return !ret
    }
    
    static iCopy( timeout := 1, method := 1 )
    {
        this._IsInstance( A_ThisFunc )
        this.Snap( data )
        this.Clear()    ;clearing the A_Clipboard
        if( method = 1 )
            SendInput "^{Ins}"
        else
            SendInput "^{vk43sc02E}" ;ctrl+c
        ClipWait timeout, 1
        bytesCopied := 0
        if !this._isClipEmpty()
        {
            this.iClear()   ;clearing the variable containing the A_Clipboard data
            bytesCopied := this.iSnap()
        }
        this.Restore( data )
        return bytesCopied
    }
    
    static Paste( plainText := "", method := 1 )
    {
        ret := 0
        if ( plainText != "" )
        {
            this.Snap( data )
            this.Clear()
            ret := this.SetText( plainText )
        }
        if( method = 1 )
            SendInput "+{Ins}"
        else
            SendInput "^{vk56sc02F}" ;ctrl+v
        this._waitClipReady( 3000 )
        if ( plainText != "" )
        {
            this.Restore( data )
        }
        else
            ret := !this._isClipEmpty()
        return ret
    }
    
    static iPaste( method := 1 )
    {
        this._IsInstance( A_ThisFunc )
        this.Snap( data )
        if !( bytesRestored := this.iRestore() )
            return 0
        if( method = 1 )
            SendInput "+{Ins}"
        else
            SendInput "^{vk56sc02F}" ;ctrl+v
        this._waitClipReady( 3000 )
        this.Restore( data )
        return bytesRestored
    }
    
    static IsEmpty()
    {
        return this._isClipEmpty()
    }
    
    static iIsEmpty()
    {
        return !this.iGetSize()
    }
    
    static _isClipEmpty()
    {
        return !WinClipAPI.CountClipboardFormats()
    }
    
    static _waitClipReady( timeout := 10000 )
    {
        start_time := A_TickCount
        sleep 100
        while ( WinClipAPI.GetOpenClipboardWindow() && ( A_TickCount - start_time < timeout ) )
            sleep 100
    }

    static iSetText( textData )
    {
        if ( textData = "" )
            return 0
        this._IsInstance( A_ThisFunc )
        clipSize := this._getClipData( clipData )
        if !( clipSize := this._appendText( clipData, clipSize, textData, 1 ) )
            return 0
        return this._setClipData( clipData, clipSize )
    }
    
    static SetText( textData )
    {
        if ( textData = "" )
            return 0
        clipSize :=  this._fromclipboard( clipData )
        if !( clipSize := this._appendText( clipData, clipSize, textData, 1 ) )
            return 0
        return this._toclipboard( clipData, clipSize )
    }

    static GetRTF()
    {
        if !( clipSize := this._fromclipboard( clipData ) )
            return ""
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, "Rich Text Format" ) )
            return ""
        return strget( StrPtr(out_data), out_size, "CP0" )
    }
    
    static iGetRTF()
    {
        this._IsInstance( A_ThisFunc )
        if !( clipSize := this._getClipData( clipData ) )
            return ""
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, "Rich Text Format" ) )
            return ""
        return strget( StrPtr(out_data), out_size, "CP0" )
    }
    
    static SetRTF( textData )
    {
        if ( textData = "" )
            return 0
        clipSize :=  this._fromclipboard( clipData )
        if !( clipSize := this._setRTF( clipData, clipSize, textData ) )
                    return 0
        return this._toclipboard( clipData, clipSize )
    }
    
    static iSetRTF( textData )
    {
        if ( textData = "" )
            return 0
        this._IsInstance( A_ThisFunc )
        clipSize :=  this._getClipData( clipData )
        if !( clipSize := this._setRTF( clipData, clipSize, textData ) )
                    return 0
        return this._setClipData( clipData, clipSize )
    }

    static _setRTF( ByRef clipData, clipSize, textData )
    {
        objFormats := this._parseClipboardData( clipData, clipSize )
        uFmt := WinClipAPI.RegisterClipboardFormat( "Rich Text Format" )
        objFormats[ uFmt ] := object()
        sLen := StrLen( textData )
        objFormats[ uFmt ]["buffer"].Size := sLen
        StrPut( textData, StrPtr(objFormats[ uFmt ]["buffer"]), sLen, "CP0" )
        objFormats[ uFmt ].size := sLen
        return this._compileClipData( clipData, objFormats )
    }

    static iAppendText( textData )
    {
        if ( textData = "" )
            return 0
        this._IsInstance( A_ThisFunc )
        clipSize := this._getClipData( clipData )
        if !( clipSize := this._appendText( clipData, clipSize, textData ) )
            return 0
        return this._setClipData( clipData, clipSize )
    }
    
    static AppendText( textData )
    {
        if ( textData = "" )
            return 0
        clipSize :=  this._fromclipboard( clipData )
        if !( clipSize := this._appendText( clipData, clipSize, textData ) )
            return 0
        return this._toclipboard( clipData, clipSize )
    }

    static SetHTML( html, source := "" )
    {
        if ( html = "" )
            return 0
        clipSize :=  this._fromclipboard( clipData )
        if !( clipSize := this._setHTML( clipData, clipSize, html, source ) )
            return 0
        return this._toclipboard( clipData, clipSize )
    }

    static iSetHTML( html, source := "" )
    {
        if ( html = "" )
            return 0
        this._IsInstance( A_ThisFunc )
        clipSize := this._getClipData( clipData )
        if !( clipSize := this._setHTML( clipData, clipSize, html, source ) )
            return 0
        return this._setClipData( clipData, clipSize )
    }

    static _calcHTMLLen( num )
    {
        while ( StrLen( num ) < 10 )
            num := "0" . num
        return num
    }

    static _setHTML( ByRef clipData, clipSize, htmlData, source )
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

        ;replace literal continuation section to make cross-compatible with v1 and v2
        html := "Version:0.9`r`n"
        html .= "StartHTML:" . StartHTML . "`r`n"
        html .= "EndHTML:" . EndHTML . "`r`n"
        html .= "StartFragment:" . StartFragment . "`r`n"
        html .= "EndFragment:" . EndFragment . "`r`n"
        html .= "SourceURL:" . source . "`r`n"
        html .= "<html>`r`n"
        html .= "<body>`r`n"
        html .= "<!--StartFragment-->`r`n"
        html .= htmlData . "`r`n"
        html .= "<!--EndFragment-->`r`n"
        html .= "</body>`r`n"
        html .= "</html>`r`n"

        sLen := StrPut( html, encoding )
        ; p objFormats[ uFmt ].buffer := BufferAlloc(sLen)
        objFormats[ uFmt ].buffer := BufferAlloc(sLen)
        ; objFormats[ uFmt ]["buffer"].Size := sLen
        StrPut( html, objFormats[ uFmt ].buffer, sLen, encoding )

        objFormats[ uFmt ].size := sLen
        
        return this._compileClipData( clipData, objFormats )
    }
    
    static _appendText( ByRef clipData, clipSize, textData, IsSet := 0 )
    {
        objFormats := this._parseClipboardData( clipData, clipSize )
        uFmt := this.ClipboardFormats.CF_UNICODETEXT
        str := ""
        if ( objFormats.HasOwnProp( uFmt ) && !IsSet )
            str := strget( StrPtr(objFormats[ uFmt ]["buffer"]), "UTF-16" )
        else
            objFormats[ uFmt ] := object()
        str .= textData
        sLen := ( StrLen( str ) + 1 ) * 2
        objFormats[ uFmt ]["buffer"].Size := sLen
        StrPut( str, StrPtr(objFormats[ uFmt ]["buffer"]), sLen, "UTF-16" )
        objFormats[ uFmt ].size := sLen
        return this._compileClipData( clipData, objFormats )
    }
    
    static _getFiles( pDROPFILES )
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
    
    static _setFiles( ByRef clipData, clipSize, files, append := 0, isCut := 0 )
    {
        objFormats := this._parseClipboardData( clipData, clipSize )
        uFmt := this.ClipboardFormats.CF_HDROP
        if ( append && objFormats.HasOwnProp( uFmt ) )
            prevList := this._getFiles( StrPtr(objFormats[ uFmt ]["buffer"]) ) "`n"
        objFiles := WinClipAPI.StrSplit( prevList . files, "`n", A_Space A_Tab )
        objFiles := WinClipAPI.RemoveDubls( objFiles )
        if !objFiles.MaxIndex()
            return 0
        objFormats[ uFmt ] := object()
        DROP_size := 20 + 2
        for i,str in objFiles
            DROP_size += ( StrLen( str ) + 1 ) * 2
        VarSetStrCapacity(DROPFILES,DROP_size)
        NumPut("UInt",20,DROPFILES,0)  ;offset
        NumPut("uchar",1,DROPFILES,16) ;NumPut("UInt",20,DROPFILES,0)
        offset := StrPtr(DROPFILES) + 20
        for i,str in objFiles
        {
            StrPut( str, offset, "UTF-16" )
            offset += ( StrLen( str ) + 1 ) * 2
        }
        objFormats[ uFmt ]["buffer"].Size := DROP_size
        WinClipAPI.memcopy( StrPtr(objFormats[ uFmt ]["buffer"]), StrPtr(DROPFILES), DROP_size )
        objFormats[ uFmt ].size := DROP_size
        prefFmt := WinClipAPI.RegisterClipboardFormat( "Preferred DropEffect" )
        objFormats[ prefFmt ] := { size : 4 }
        objFormats[ prefFmt ]["buffer"].Size := 4
        NumPut("UInt",isCut ? 2 : 5,StrPtr(objFormats[ prefFmt ]["buffer"]),0)
        return this._compileClipData( clipData, objFormats )
    }
    
    static SetFiles( files, isCut := 0 )
    {
        if ( files = "" )
            return 0
        clipSize := this._fromclipboard( clipData )
        if !( clipSize := this._setFiles( clipData, clipSize, files, 0, isCut ) )
            return 0
        return this._toclipboard( clipData, clipSize )
    }
    
    static iSetFiles( files, isCut := 0 )
    {
        this._IsInstance( A_ThisFunc )
        if ( files = "" )
            return 0
        clipSize := this._getClipData( clipData )
        if !( clipSize := this._setFiles( clipData, clipSize, files, 0, isCut ) )
            return 0
        return this._setClipData( clipData, clipSize )
    }
    
    static AppendFiles( files, isCut := 0 )
    {
        if ( files = "" )
            return 0
        clipSize := this._fromclipboard( clipData )
        if !( clipSize := this._setFiles( clipData, clipSize, files, 1, isCut ) )
            return 0
        return this._toclipboard( clipData, clipSize )
    }
    
    static iAppendFiles( files, isCut := 0 )
    {
        this._IsInstance( A_ThisFunc )
        if ( files = "" )
            return 0
        clipSize := this._getClipData( clipData )
        if !( clipSize := this._setFiles( clipData, clipSize, files, 1, isCut ) )
            return 0
        return this._setClipData( clipData, clipSize )
    }
    
    static GetFiles()
    {
        if !( clipSize := this._fromclipboard( clipData ) )
            return ""
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_HDROP ) )
            return ""
        return this._getFiles( StrPtr(out_data) )
    }
    
    static iGetFiles()
    {
        this._IsInstance( A_ThisFunc )
        if !( clipSize := this._getClipData( clipData ) )
            return ""
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_HDROP ) )
            return ""
        return this._getFiles( StrPtr(out_data) )
    }
    
    static _getFormatData( ByRef out_data, ByRef data, size, needleFormat )
    {
        needleFormat := (IsInteger( needleFormat ) ? needleFormat : WinClipAPI.RegisterClipboardFormat( needleFormat ))
        if !needleFormat
            return 0
        offset := 0
        while ( offset < size )
        {
            ; Source: Type: Object or Integer
            ; but data is String
            ; p data=="" ;1
            if !( fmt := NumGet( data, offset, "UInt" ) )
                break
            offset += 4
            if !( dataSize := NumGet( data, offset, "UInt" ) )
                break
            offset += 4
            if ( fmt == needleFormat )
            {
                VarSetStrCapacity(out_data,dataSize)
                WinClipAPI.memcopy( StrPtr(out_data), data.Ptr + offset, dataSize )
                return dataSize
            }
            offset += dataSize
        }
        return 0
    }
    
    static _DIBtoHBITMAP( ByRef dibData )
    {
        ;http://ebersys.blogspot.com/2009/06/how-to-convert-dib-to-bitmap.html
        pPix := WinClipAPI.GetPixelInfo( dibData )
        gdip_token := WinClipAPI.Gdip_Startup()
        pBitmap:=0 ;empty receiving var
        DllCall("gdiplus\GdipCreateBitmapFromGdiDib", "Ptr", StrPtr(dibData), "Ptr", pPix, "Ptr*", pBitmap )
        hBitmap:=0 ;empty receiving var
        DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "Ptr*", hBitmap, "int", 0xffffffff )
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
        WinClipAPI.Gdip_Shutdown( gdip_token )
        return hBitmap
    }
    
    static GetBitmap()
    {
        if !( clipSize := this._fromclipboard( clipData ) )
            return ""
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_DIB ) )
            return ""
        return this._DIBtoHBITMAP( out_data )
    }
    
    static iGetBitmap()
    {
        this._IsInstance( A_ThisFunc )
        if !( clipSize := this._getClipData( clipData ) )
            return ""
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_DIB ) )
            return ""
        return this._DIBtoHBITMAP( out_data )
    }
    
    static _BITMAPtoDIB( bitmap, ByRef DIB )
    {
        if !bitmap
            return 0
        if !IsInteger( bitmap )
        {
            gdip_token := WinClipAPI.Gdip_Startup()
            pBitmap:=0 ;empty receiving var
            DllCall("gdiplus\GdipCreateBitmapFromFileICM", "wstr", bitmap, "Ptr*", pBitmap )
            hBitmap:=0 ;empty receiving var
            DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "Ptr*", hBitmap, "int", 0xffffffff )
            DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
            WinClipAPI.Gdip_Shutdown( gdip_token )
            bmMade := 1
        }
        else
            hBitmap := bitmap, bmMade := 0
        if !hBitmap
                return 0
        ;http://www.codeguru.com/Cpp/G-M/bitmap/article.php/c1765
        if !( hdc := DllCall( "GetDC", "Ptr", 0 ) )
            Goto _BITMAPtoDIB_cleanup
        hPal := DllCall( "GetStockObject", "UInt", 15 ) ;DEFAULT_PALLETE
        hPal := DllCall( "SelectPalette", "ptr", hdc, "ptr", hPal, "Uint", 0 )
        DllCall( "RealizePalette", "ptr", hdc )
        size := DllCall( "GetObject", "Ptr", hBitmap, "Uint", 0, "ptr", 0 )
        VarSetStrCapacity(bm,size)
        DllCall( "GetObject", "Ptr", hBitmap, "Uint", size, "ptr", StrPtr(bm) )
        biBitCount := NumGet( bm, 16, "UShort" )*NumGet( bm, 18, "UShort" )
        nColors := (1 << biBitCount)
    if ( nColors > 256 ) 
        nColors := 0
    bmiLen  := 40 + nColors * 4
        VarSetStrCapacity(bmi,bmiLen)
        ;BITMAPINFOHEADER initialization
        NumPut("Uint",40,bmi,0)
        NumPut( NumGet( bm, 4, "Uint" ), bmi, 4, "Uint" )   ;width
        NumPut( biHeight := NumGet( bm, 8, "Uint" ), bmi, 8, "Uint" ) ;height
        NumPut("UShort",1,bmi,12)
        NumPut("UShort",biBitCount,bmi,14)
        NumPut("UInt",0,bmi,16) ;compression must be BI_RGB

        ; Get BITMAPINFO. 
        if !DllCall("GetDIBits"
                            ,"ptr",hdc
                            ,"ptr",hBitmap
                            ,"uint",0 
                            ,"uint",biHeight
                            ,"ptr",0      ;lpvBits 
                            ,"ptr",StrPtr(bmi)  ;lpbi 
                            ,"uint",0)    ;DIB_RGB_COLORS
            Goto _BITMAPtoDIB_cleanup
        biSizeImage := NumGet( StrPtr(bmi), 20, "UInt" )
        if ( biSizeImage = 0 )
        {
            biBitCount := numget( StrPtr(bmi), 14, "UShort" )
            biWidth := numget( StrPtr(bmi), 4, "UInt" )
            biHeight := numget( StrPtr(bmi), 8, "UInt" )
            biSizeImage := (((( biWidth * biBitCount + 31 ) & ~31 ) >> 3 ) * biHeight )
            ;~ dwCompression := numget( bmi, 16, "UInt" )
            ;~ if ( dwCompression != 0 ) ;BI_RGB
                ;~ biSizeImage := ( biSizeImage * 3 ) / 2
            NumPut("UInt",biSizeImage,StrPtr(bmi),20)
        }
        DIBLen := bmiLen + biSizeImage
        VarSetStrCapacity(DIB,DIBLen)
        WinClipAPI.memcopy( StrPtr(DIB), StrPtr(bmi), bmiLen )
        if !DllCall("GetDIBits"
                            ,"ptr",hdc
                            ,"ptr",hBitmap
                            ,"uint",0 
                            ,"uint",biHeight
                            ,"ptr",StrPtr(DIB) + bmiLen     ;lpvBits 
                            ,"ptr",StrPtr(DIB)  ;lpbi 
                            ,"uint",0)    ;DIB_RGB_COLORS
            Goto _BITMAPtoDIB_cleanup
_BITMAPtoDIB_cleanup:
        if bmMade
            DllCall( "DeleteObject", "ptr", hBitmap )
        DllCall( "SelectPalette", "ptr", hdc, "ptr", hPal, "Uint", 0 )
        DllCall( "RealizePalette", "ptr", hdc )
        DllCall("ReleaseDC","ptr",hdc)
        ; if ( A_ThisLabel = "_BITMAPtoDIB_cleanup" )
            return 0
        ; return DIBLen
    }
    
    static _setBitmap( ByRef DIB, DIBSize, ByRef clipData, clipSize )
    {
        objFormats := this._parseClipboardData( clipData, clipSize )
        uFmt := this.ClipboardFormats.CF_DIB
        objFormats[ uFmt ] := { size : DIBSize }
        objFormats[ uFmt ]["buffer"].Size := DIBSize
        WinClipAPI.memcopy( StrPtr(objFormats[ uFmt ]["buffer"]), StrPtr(DIB), DIBSize )
        return this._compileClipData( clipData, objFormats )
    }
    
    static SetBitmap( bitmap )
    {
        if ( DIBSize := this._BITMAPtoDIB( bitmap, DIB ) )
        {
            clipSize := this._fromclipboard( clipData )
            if ( clipSize := this._setBitmap( DIB, DIBSize, clipData, clipSize ) )
                return this._toclipboard( clipData, clipSize )
        }
        return 0
    }
    
    static iSetBitmap( bitmap )
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
    
    static GetText()
    {
        if !( clipSize := this._fromclipboard( clipData ) )
            return ""
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_UNICODETEXT ) )
            return ""
        return strget( StrPtr(out_data), out_size / 2, "UTF-16" )
    }

    static iGetText()
    {
        this._IsInstance( A_ThisFunc )
        if !( clipSize := this._getClipData( clipData ) )
            return ""
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, this.ClipboardFormats.CF_UNICODETEXT ) )
            return ""
        return strget( StrPtr(out_data), out_size / 2, "UTF-16" )
    }
    
    static GetHtml()
    {
        if !( clipSize := this._fromclipboard( clipData ) )
            return ""
        ; p clipSize ; clipSize works ; 612, 3312
        ; p clipData ; ""
        ; p type(clipData) ; String WEIRD
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, "HTML Format" ) )
            return ""
        return strget( StrPtr(out_data), out_size, "CP0" )
    }
    
    static iGetHtml()
    {
        this._IsInstance( A_ThisFunc )
        if !( clipSize := this._getClipData( clipData ) )
            return ""
        if !( out_size := this._getFormatData( out_data, clipData, clipSize, "HTML Format" ) )
            return ""
        return strget( StrPtr(out_data), out_size, "CP0" )
    }
    
    static _getFormatName( iformat )
    {
        if this.formatByValue.HasOwnProp( iformat )
            return this.formatByValue[ iformat ]
        else
            return WinClipAPI.GetClipboardFormatName( iformat )
    }
    
    static iGetData( ByRef Data )
    {
        this._IsInstance( A_ThisFunc )
        return this._getClipData( Data )
    }
    
    static iSetData( ByRef data )
    {
        this._IsInstance( A_ThisFunc )
        return this._setClipData( data, VarSetStrCapacity(data ) )
    }
    
    static iGetSize()
    {
        this._IsInstance( A_ThisFunc )
        return this["alldata"].Size
    }
    
    static HasFormat( fmt )
    {
        if !fmt
            return 0
        return WinClipAPI.IsClipboardFormatAvailable( IsInteger( fmt ) ? fmt : WinClipAPI.RegisterClipboardFormat( fmt )  )
    }
    
    static iHasFormat( fmt )
    {
        this._IsInstance( A_ThisFunc )
        if !( clipSize := this._getClipData( clipData ) )
            return 0
        return this._hasFormat( clipData,clipSize)
    }

    static _hasFormat( ByRef data, size, needleFormat )
    {
        needleFormat := IsInteger( needleFormat ) ? needleFormat : WinClipAPI.RegisterClipboardFormat( needleFormat )
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
    
    static iSaveBitmap( filePath, format )
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
        pBitmap:=0 ;empty receiving var
        DllCall("gdiplus\GdipCreateBitmapFromGdiDib", "Ptr", StrPtr(DIB), "Ptr", WinClipAPI.GetPixelInfo( DIB ), "Ptr*", pBitmap )
        DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "wstr", filePath, "Ptr", StrPtr(CLSID), "Ptr", 0 )
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
        WinClipAPI.Gdip_Shutdown( gdip_token )
        return 1
    }
    
    static SaveBitmap( filePath, format )
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
        pBitmap:=0 ;empty receiving var
        DllCall("gdiplus\GdipCreateBitmapFromGdiDib", "Ptr", StrPtr(DIB), "Ptr", WinClipAPI.GetPixelInfo( DIB ), "Ptr*", pBitmap )
        DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "wstr", filePath, "Ptr", StrPtr(CLSID), "Ptr", 0 )
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
                                ,CF_GDIOBJFIRST : 0x0300 ;Start of a range of integer values for application-defined GDI object A_Clipboard formats. The end of the range is CF_GDIOBJLAST.Handles associated with A_Clipboard formats in this range are not automatically deleted using the GlobalFree function when the A_Clipboard is emptied. Also, when using values in this range, the hMem parameter is not a handle to a GDI object, but is a handle allocated by the GlobalAlloc function with the GMEM_MOVEABLE flag.
                                ,CF_GDIOBJLAST : 0x03FF ;See CF_GDIOBJFIRST.
                                ,CF_HDROP : 15 ;A handle to type HDROP that identifies a list of files. An application can retrieve information about the files by passing the handle to the DragQueryFile function.
                                ,CF_LOCALE : 16 ;The data is a handle to the locale identifier associated with text in the A_Clipboard. When you close the A_Clipboard, if it contains CF_TEXT data but no CF_LOCALE data, the system automatically sets the CF_LOCALE format to the current input language. You can use the CF_LOCALE format to associate a different locale with the A_Clipboard text. An application that pastes text from the A_Clipboard can retrieve this format to determine which character set was used to generate the text. Note that the A_Clipboard does not support plain text in multiple character sets. To achieve this, use a formatted text data type such as RTF instead. The system uses the code page associated with CF_LOCALE to implicitly convert from CF_TEXT to CF_UNICODETEXT. Therefore, the correct code page table is used for the conversion.
                                ,CF_METAFILEPICT : 3 ;Handle to a metafile picture format as defined by the METAFILEPICT structure. When passing a CF_METAFILEPICT handle by means of DDE, the application responsible for deleting hMem should also free the metafile referred to by the CF_METAFILEPICT handle.
                                ,CF_OEMTEXT : 7 ;Text format containing characters in the OEM character set. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
                                ,CF_OWNERDISPLAY : 0x0080 ;Owner-display format. The A_Clipboard owner must display and update the A_Clipboard viewer window, and receive the WM_ASKCBFORMATNAME, WM_HSCROLLCLIPBOARD, WM_PAINTCLIPBOARD, WM_SIZECLIPBOARD, and WM_VSCROLLCLIPBOARD messages. The hMem parameter must be NULL.
                                ,CF_PALETTE : 9 ;Handle to a color palette. Whenever an application places data in the A_Clipboard that depends on or assumes a color palette, it should place the palette on the A_Clipboard as well.If the A_Clipboard contains data in the CF_PALETTE (logical color palette) format, the application should use the SelectPalette and RealizePalette functions to realize (compare) any other data in the A_Clipboard against that logical palette.When displaying A_Clipboard data, the A_Clipboard always uses as its current palette any object on the A_Clipboard that is in the CF_PALETTE format.
                                ,CF_PENDATA : 10 ;Data for the pen extensions to the Microsoft Windows for Pen Computing.
                                ,CF_PRIVATEFIRST : 0x0200 ;Start of a range of integer values for private A_Clipboard formats. The range ends with CF_PRIVATELAST. Handles associated with private A_Clipboard formats are not freed automatically; the A_Clipboard owner must free such handles, typically in response to the WM_DESTROYCLIPBOARD message.
                                ,CF_PRIVATELAST : 0x02FF ;See CF_PRIVATEFIRST.
                                ,CF_RIFF : 11 ;Represents audio data more complex than can be represented in a CF_WAVE standard wave format.
                                ,CF_SYLK : 4 ;Microsoft Symbolic Link (SYLK) format.
                                ,CF_TEXT : 1 ;Text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data. Use this format for ANSI text.
                                ,CF_TIFF : 6 ;Tagged-image file format.
                                ,CF_UNICODETEXT : 13 ;Unicode text format. Each line ends with a carriage return/linefeed (CR-LF) combination. A null character signals the end of the data.
                                ,CF_WAVE : 12 } ;Represents audio data in one of the standard wave formats, such as 11 kHz or 22 kHz PCM.
    
    static                       WM_COPY := 0x301
                                ,WM_CLEAR := 0x0303
                                ,WM_CUT := 0x0300
                                ,WM_PASTE := 0x0302
    
    static skipFormats := Map(      2      , 0 ;"CF_BITMAP"
                                ,17     , 0 ;"CF_DIBV5"
                                ,0x0082 , 0 ;"CF_DSPBITMAP"
                                ,0x008E , 0 ;"CF_DSPENHMETAFILE"
                                ,0x0083 , 0 ;"CF_DSPMETAFILEPICT"
                                ,0x0081 , 0 ;"CF_DSPTEXT"
                                ,0x0080 , 0 ;"CF_OWNERDISPLAY"
                                ,3      , 0 ;"CF_METAFILEPICT"
                                ,7      , 0 ;"CF_OEMTEXT"
                                ,1      , 0 ) ;"CF_TEXT"
                                                            
    static formatByValue := Map(    2 , "CF_BITMAP"
                                ,8 , "CF_DIB"
                                ,17 , "CF_DIBV5"
                                ,5 , "CF_DIF"
                                ,0x0082 , "CF_DSPBITMAP"
                                ,0x008E , "CF_DSPENHMETAFILE"
                                ,0x0083 , "CF_DSPMETAFILEPICT"
                                ,0x0081 , "CF_DSPTEXT"
                                ,14 , "CF_ENHMETAFILE"
                                ,0x0300 , "CF_GDIOBJFIRST"
                                ,0x03FF , "CF_GDIOBJLAST"
                                ,15 , "CF_HDROP"
                                ,16 , "CF_LOCALE"
                                ,3 , "CF_METAFILEPICT"
                                ,7 , "CF_OEMTEXT"
                                ,0x0080 , "CF_OWNERDISPLAY"
                                ,9 , "CF_PALETTE"
                                ,10 , "CF_PENDATA"
                                ,0x0200 , "CF_PRIVATEFIRST"
                                ,0x02FF , "CF_PRIVATELAST"
                                ,11 , "CF_RIFF"
                                ,4 , "CF_SYLK"
                                ,1 , "CF_TEXT"
                                ,6 , "CF_TIFF"
                                ,13 , "CF_UNICODETEXT"
                                ,12 , "CF_WAVE" )
}