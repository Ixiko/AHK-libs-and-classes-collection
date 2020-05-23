#NoEnv

; TestCode
; #Include Common.ahk

; fileName := "zipTest.zip"

; if !(zipFile := new 7Zip(fileName)) {
;   msgbox % "Failed loading 7Zip library"
;   ExitApp  
; }

; debug( A_LineFile )

; ExitApp

; debug( "hide           = " zipFile.option._hide() )
; debug( "yes            = " zipFile.option._yes() )
; debug( "password       = " zipFile.option._password() )
; debug( "sfx            = " zipFile.option._sfx() )
; debug( "volumeSize     = " zipFile.option._volumeSize() )
; debug( "workingDir     = " zipFile.option._workingDir() )
; debug( "compressLevel  = " zipFile.option._compressLevel() )
; debug( "compressType   = " zipFile.option._compressType() )
; debug( "recurse        = " zipFile.option._recurse() )
; debug( "includeFile    = " zipFile.option._includeFile() )
; debug( "excludeFile    = " zipFile.option._excludeFile() )
; debug( "includeArchive = " zipFile.option._includeArchive() )
; debug( "excludeArchive = " zipFile.option._excludeArchive() )
; debug( "overwrite      = " zipFile.option._overwrite() )
; debug( "extractPaths   = " zipFile.option._extractPaths() )
; debug( "output         = " zipFile.option._output() )

; debug( "fileCount : " zipFile.getFileCount() )
; debug( "version   : " zipFile.getVersion() )
; debug( "list      : " zipFile.list() )

; debug( A_ScriptDir "\ziptemp" )



; zipFile.extract( A_ScriptDir "\ziptemp" )
; zipFile.close()

; debug( "end")

; ExitApp

; debug( message ) {
;  if( A_IsCompiled == 1 )
;    return
;   message .= "`n" 
;   FileAppend %message%, * ; send message to stdout
; }


class 7Zip {

  dllName     := ""
  archiveFile := ""
  module      := 0
  option      := new 7Zip.OptionSpec()

  __New( archiveFile ) {

    currDir := FileUtil.getDir( A_LineFile )

    if (r := DllCall("LoadLibrary", "Str", currDir "\7-zip64.dll")) {
      this.dllName := "7-zip64"
    } else if (r := DllCall("LoadLibrary", "Str", currDir "\7-zip32.dll")) {
      this.dllName := "7-zip32"
    } else {
      return 0 , ErrorLevel := -1
    }

    this.module      := r
    this.archiveFile := archiveFile

  }

  /**
  * list files in archive
  *
  * @param {String} archiveFile
  * @return {String} response on success, 0 on failure.
  * 
  */
  list() {
    commandline := "l """ this.archiveFile """"
    commandline .= this.option._hide()
    commandline .= this.option._password()
    return this._run( commandline )
  }

  /**
  * add file to archive
  * 
  * @param {String} file     file to add
  * @return {String} response on success, 0 on failure.
  */
  add( file ) {
    commandline  = "a """ this.archiveFile """ """ file """"
    commandline .= this.option._hide()
    commandline .= this.option._password()
    commandline .= this.option._compressLevel()
    commandline .= this.option._compressType()
    commandline .= this.option._recurse()
    commandline .= this.option._sfx()
    commandline .= this.option._workingDir()
    commandline .= this.option._includeFile()
    commandline .= this.option._excludeFile()
    return this._run( commandline )
  }

  /**
  * delete file to archive
  * 
  * @param {String} file  fileName to delete
  * @return {String} response on success, 0 on failure.
  */  
  delete( file ) {
    commandline  = "d """ this.archiveFile """ """ file """"
    commandline .= this.option._hide()
    commandline .= this.option._password()
    commandline .= this.option._compressLevel()
    commandline .= this.option._compressType()
    commandline .= this.option._recurse()
    commandline .= this.option._sfx()
    commandline .= this.option._workingDir()
    commandline .= this.option._includeFile()
    commandline .= this.option._excludeFile()
    return this._run( commandline )
  }

  /**
  * extract files from archive
  *
  * @param {String} path   directory to extract files
  * @return {String} response on success, 0 on failure.
  */
  extract( path="" ) {
    commandline := ( this.option.extractPaths ? "x" : "e" ) " """ this.archiveFile """"
    commandline .= this.option._hide()
    commandline .= this.option._recurse()
    commandline .= this.option._overwrite()
    commandline .= this.option._password()
    commandline .= this.option._workingDir()
    commandline .= this.option._hide()
    commandline .= this.option._yes()
    commandline .= this.option._includeArchive()
    commandline .= this.option._excludeArchive()
    commandline .= this.option._includeFile()
    commandline .= this.option._excludeFile()

    if ( path != "" ) {
      FileCreateDir, % path
      commandline .= " -o""" path """"
    }

    return this._run( commandline )
  }

  /**
  * check archive integrity
  *
  * @return {Boolean} true on success, false otherwise
  */
  checkArchive() {
    Return DllCall( this.dllName "\SevenZipCheckArchive", "AStr", this.archiveFile, "int", 0 )
  }

  /**
  * get type of archive
  *
  * @return {Number}
  *   0 : Unknown type
  *   1 : ZIP type
  *   2 : 7Z type
  *  -1 : Failure
  */
  getArchiveType() {
    Return DllCall( this.dllName "\SevenZipGetArchiveType", "AStr", this.archiveFile )
  }

  /**
  * get number of files in archive
  *
  * @return {Number} number of files
  */
  getFileCount() {
    Return DllCall( this.dllName "\SevenZipGetFileCount", "AStr", this.archiveFile )
  }

  ;
  ; Function: 7Zip_ConfigDialog
  ; Description:
  ;      Shows the about dialog for 7-zip32.dll
  ; Syntax: 7Zip_ConfigDialog(hWnd)
  ; Parameters:
  ;      hWnd - handle of owner window
  ;
  configDialog() {
    Return DllCall( this.dllName "\SevenZipConfigDialog", "Ptr", 0, "ptr",0, "int",0 )
  }

  queryFunctionList( iFunction = 0 ) {
    Return DllCall( this.dllName "\SevenZipQueryFunctionList", "int", iFunction )
  }

  /*
  * get version of 7-zip32.dll
  *
  * @return {String} version
  */
  getVersion() {
    aRet := DllCall( this.dllName "\SevenZipGetVersion", "Short" )
    Return SubStr(aRet,1,1) . "." . SubStr(aRet,2)
  }

  /*
  * get sub version of 7-zip32.dll
  *
  * @return {String} subversion
  */
  getSubVersion() {
    return DllCall( this.dllName "\SevenZipGetSubVersion", "Short" )
  }

  /**
  * free 7-zip32.dll library in memory.
  */
  close() {
    DllCall("FreeLibrary", "Ptr", this.option.hwnd)
    this.module      := 0
    this.archiveFile := ""
  }

  ;
  ; Function: 7Zip_SetOwnerWindowEx
  ; Description:
  ;      Appoints the call-back function in order to receive the information of the compressing/unpacking
  ; Syntax: 7Zip_SetOwnerWindowEx(hWnd, sProcFunc)
  ; Parameters:
  ;      sProcFunc - Callback function name
  ;      hWnd - handle of window (calling application), can be 0
  ; Return Value:
  ;      True on success, false otherwise
  ; Related: 7Zip_KillOwnerWindowEx
  ; Example:
  ;      file:example_callback.ahk
  ;
  setOwnerWindowEx( sProcFunc ) {
    Address := RegisterCallback(sProcFunc, "F", 4)
    Return DllCall( this.dllName "\SevenZipSetOwnerWindowEx","Ptr", 0 , "ptr", Address )
  }

  ;
  ; Function: 7Zip_KillOwnerWindowEx
  ; Description:
  ;      Removes the callback
  ; Syntax: 7Zip_KillOwnerWindowEx(hWnd)
  ; Parameters:
  ;      hWnd - Handle to parent or owner window
  ; Return Value:
  ;      True on success, false otherwise
  ; Related: 7Zip_SetOwnerWindowEx
  ;
  killOwnerWindowEx() {
    Return DllCall( this.dllName "\SevenZipKillOwnerWindowEx" , "Ptr", 0 )
  }



  ; FUNCTIONS BELOW - CREDIT TO LEXIKOS -------------------------------------------------------

  ;
  ; Function: 7Zip_OpenArchive
  ; Description:
  ;      Open archive and return handle for use with 7Zip_FindFirst
  ; Syntax: 7Zip_OpenArchive(archiveFile, [hWnd])
  ; Parameters:
  ;      archiveFile - Path of archive
  ;      hWnd - Handle of calling window
  ; Return Value:
  ;      Handle for use with 7Zip_FindFirst function, 0 on error.
  ; Remarks:
  ;      Nil
  ; Related: 7Zip_CloseArchive, 7Zip_FindFirst , File Info Functions
  ; Example:
  ;      hArc := 7Zip_OpenArchive("C:\Path\To\Archive.7z")
  ;
  openArchive( archiveFile ) {
    Return DllCall( this.dllName "\SevenZipOpenArchive", "Ptr", 0, "AStr", archiveFile, "int", 0 )
  }

  ;
  ; Function: 7Zip_CloseArchive
  ; Description:
  ;      Closes the archive handle
  ; Syntax: 7Zip_CloseArchive(hArc)
  ; Parameters:
  ;      hArc - Handle retrived from 7Zip_OpenArchive
  ; Return Value:
  ;      -1 on error
  ; Remarks:
  ;      Nil
  ; Related: 7Zip_OpenArchive
  ; Example:
  ;      7Zip_CloseArchive(hArc)
  ;
  closeArchive( archiveFile ) {
    Return DllCall( this.dllName "\SevenZipCloseArchive", "Ptr", 0, "AStr", archiveFile, "int", 0 )
  }

  ;
  ; Function: 7Zip_FindFirst
  ; Description:
  ;      Find first file for search criteria in archive
  ; Syntax: 7Zip_FindFirst(hArc, sSearch, [o7zip__info])
  ; Parameters:
  ;      hArc - handle of archive (returned from 7Zip_OpenArchive)
  ;      sSearch - Search string (wildcards allowed)
  ;      o7zip__info - (Optional) Name of object to recieve details of file.
  ; Return Value:
  ;      Object with file details on success. If 3rd param was 0, returns true on success. False on failure.
  ; Remarks:
  ;      If third param is omitted, details are returned in a new object.
  ;      If it is set to 0, details are not retrieved. (You can use the other functions to get details.)
  ; Related: 7Zip_FindNext , 7Zip_OpenArchive , File Info Functions
  ; Example:
  ;      file:example_archive_info.ahk
  ;
  findFirst( hArc, sSearch, o7zip__info="" ) {
    if (o7zip__info == 0) {
      r := DllCall(this.dllName "\SevenZipFindFirst", "Ptr", hArc, "AStr", sSearch, "ptr", 0)
      return ( r ? 0 : 1 ), ErrorLevel := (r ? r : ErrorLevel)
    }
    if ! IsObject(o7zip__info)
      o7zip__info := {}
    VarSetCapacity(tINDIVIDUALINFO , 558, 0)
    If DllCall(this.dllName "\SevenZipFindFirst", "Ptr", hArc, "AStr", sSearch, "ptr", &tINDIVIDUALINFO)
      Return 0
    o7zip__info.OriginalSize   := NumGet(tINDIVIDUALINFO , 0, "UInt")
    o7zip__info.CompressedSize := NumGet(tINDIVIDUALINFO , 4, "UInt")
    o7zip__info.CRC            := NumGet(tINDIVIDUALINFO , 8, "UInt")
  ; uFlag                      := NumGet(tINDIVIDUALINFO , 12, "UInt") ;always 0
  ; uOSType                    := NumGet(tINDIVIDUALINFO , 16, "UInt") ;always 0  
    o7zip__info.Ratio          := NumGet(tINDIVIDUALINFO , 20, "UShort")
    o7zip__info.Date           := this._dosDateTimeToStr(NumGet(tINDIVIDUALINFO , 22, "UShort"),NumGet(tINDIVIDUALINFO , 24, "UShort"))
    o7zip__info.FileName       := StrGet(&tINDIVIDUALINFO+26 ,513,"CP0")
    o7zip__info.Attribute      := StrGet(&tINDIVIDUALINFO+542,8  ,"CP0")
    o7zip__info.Mode           := StrGet(&tINDIVIDUALINFO+550,8  ,"CP0")
    
    return o7zip__info
  }

  ;
  ; Function: 7Zip_FindNext
  ; Description:
  ;      Find next file for search criteria in archive
  ; Syntax: 7Zip_FindNext(hArc, [o7zip__info])
  ; Parameters:
  ;      hArc - handle of archive (returned from 7Zip_OpenArchive)
  ;      o7zip__info - (Optional) Name of object to recieve details of file.
  ; Return Value:
  ;      Object with file details on success. If 2nd param was 0, returns true on success. False on failure.
  ; Remarks:
  ;      If second param is omitted, details are returned in a new object. 
  ;      If it is set to 0, details are not retrieved. (You can use the other functions to get details.)
  ; Related: 7Zip_FindFirst , 7Zip_OpenArchive, File Info Functions
  ; Example:
  ;      file:example_archive_info.ahk
  ;
  findNext( hArc, o7zip__info="" ) {
    if (o7zip__info = 0)
    {
      r := DllCall(this.dllName "\SevenZipFindFirst", "Ptr", hArc, "AStr", sSearch, "ptr", 0)
      return ( r ? 0 : 1 ), ErrorLevel := (r ? r : ErrorLevel)
    }
    if !IsObject(o7zip__info)
      o7zip__info := {}
    VarSetCapacity(tINDIVIDUALINFO , 558, 0)
    if DllCall(this.dllName "\SevenZipFindNext","Ptr", hArc, "ptr", &tINDIVIDUALINFO)
      Return 0 

    o7zip__info.OriginalSize   := NumGet(tINDIVIDUALINFO , 0, "UInt")
    o7zip__info.CompressedSize := NumGet(tINDIVIDUALINFO , 4, "UInt")
    o7zip__info.CRC            := NumGet(tINDIVIDUALINFO , 8, "UInt")
    o7zip__info.Ratio          := NumGet(tINDIVIDUALINFO , 20, "UShort")
    o7zip__info.Date           := this._dosDateTimeToStr(NumGet(tINDIVIDUALINFO , 22, "UShort"),NumGet(tINDIVIDUALINFO , 24, "UShort"))  
    o7zip__info.FileName       := StrGet(&tINDIVIDUALINFO+26 ,513,"CP0")
    o7zip__info.Attribute      := StrGet(&tINDIVIDUALINFO+542,8  ,"CP0")
    o7zip__info.Mode           := StrGet(&tINDIVIDUALINFO+550,8  ,"CP0")
    
    return o7zip__info
  }

  ;
  ; Function: File Info Functions
  ; Description:
  ;      Using handle hArc, get info of file(s) in archive.
  ; Syntax: 7Zip_<InfoFunction>(hArc)
  ; Parameters:
  ;      7Zip_GetFileName - Get file name
  ;      7Zip_GetArcOriginalSize - Original size of file
  ;      7Zip_GetArcCompressedSize - Compressed size
  ;      7Zip_GetArcRatio - Compression ratio
  ;      7Zip_GetDate - Date
  ;      7Zip_GetTime - Time
  ;      7Zip_GetCRC - File CRC
  ;      7Zip_GetAttribute - File Attribute
  ;      7Zip_GetMethod - Compression method (LZMA or PPMD)
  ; Return Value:
  ;      -1 on error
  ; Remarks:
  ;      See included example for details
  ; Related: 7Zip_OpenArchive , 7Zip_FindFirst
  ; Example:
  ;      file:example_archive_info.ahk
  ;
  getFileName(hArc) {
    VarSetCapacity( tNameBuffer,513 )
    If !DllCall(this.dllName "\SevenZipGetFileName", "Ptr", hArc, "ptr", &tNameBuffer, "int", 513)
      Return StrGet(&tNameBuffer,513,"CP0")
  }

  getArcOriginalSize(hArc) {
    Return DllCall(this.dllName "\SevenZipGetArcOriginalSize", "Ptr", hArc)
  }

  getArcCompressedSize(hArc) {
    Return DllCall(this.dllName "\SevenZipGetArcCompressedSize", "Ptr", hArc)
  }

  getArcRatio(hArc) {
    Return DllCall(this.dllName "\SevenZipGetArcRatio", "Ptr", hArc, "short")
  }

  getDate(hArc) {
    Return this._dosDate(DllCall(this.dllName "\SevenZipGetDate", "Ptr", hArc, "Short"))
  }

  getTime(hArc) {
    Return this._dosTime(DllCall(this.dllName "\SevenZipGetTime", "Ptr", hArc, "Short"))
  }

  getCRC(hArc) {
    Return DllCall(this.dllName "\SevenZipGetCRC", "Ptr", hArc, "UInt")
  }

  getAttribute(hArc) {
    return DllCall(this.dllName "\SevenZipGetAttribute", "Ptr", hArc)
  }

  getMethod(hArc) {
    VarSetCapacity(sBUFFER,8)
    if !DllCall(this.dllName "\SevenZipGetMethod" , "Ptr", hArc , "ptr", &sBuffer,"int", 8)
      Return StrGet(&sBUFFER, 8, "CP0")
  }

  ; FUNCTIONS FOR INTERNAL USE --------------------------------------------------------------------------------------------------
  _run( commandLine ) {
    debug( commandLine )
    nSize := 32768
    VarSetCapacity(tOutBuffer,nSize)
    retVal := DllCall(this.dllName "\SevenZip", "Ptr", ""
            ,"AStr", commandLine
            ,"Ptr", &tOutBuffer
            ,"Int", nSize)
    If ! ErrorLevel
      return StrGet(&tOutBuffer,nSize,"CP0"), ErrorLevel := retVal
    else
      return 0
  }

  _dosDate( ByRef DosDate ) {
    day   := DosDate & 0x1F
    month := (DosDate<<4) & 0x0F
    year  := ((DosDate<<8) & 0x3F) + 1980
    return "" . year . "/" . month . "/" . day
  }

  _dosTime( ByRef DosTime ) {
    sec   := (DosTime & 0x1F) * 2
    min   := (DosTime<<4) & 0x3F
    hour  := (DosTime<<10) & 0x1F
    return "" . hour . ":" . min . ":" . sec
  }

  _dosDateTimeToStr( ByRef DosDate, ByRef DosTime ) {
    VarSetCapacity(FileTime,8)
    DllCall("DosDateTimeToFileTime", "UShort", DosDate, "UShort", DosTime, "UInt", &FileTime)
    VarSetCapacity(SystemTime, 16, 0)
    If (!NumGet(FileTime,"UInt") && !NumGet(FileTime,4,"UInt"))
     Return 0
    DllCall("FileTimeToSystemTime", "PTR", &FileTime, "PTR", &SystemTime)
    Return NumGet(SystemTime,6,"short") ;date
      . "/" . NumGet(SystemTime,2,"short") ;month
      . "/" . NumGet(SystemTime,0,"short") ;year
      . " " . NumGet(SystemTime,8,"short") ;hours
      . ":" . ((StrLen(tvar := NumGet(SystemTime,10,"short")) = 1) ? "0" . tvar : tvar) ;minutes
      . ":" . ((StrLen(tvar := NumGet(SystemTime,12,"short")) = 1) ? "0" . tvar : tvar) ;seconds
    ;      . "." . NumGet(SystemTime,14,"short") ;milliseconds
  }

  class OptionSpec {

    hide           := true    ;Callback is called (bool);a,d,e,x,u
    yes            := 0       ;assume Yes on all queries;e,x
    password       := ""      ;Password (string);a,d,e,x,u
    SFX            := ""      ;Self extracting archive module name (string);a,u
    volumeSize     := 0       ;Create volumes of specified sizes (integer);a
    workingDir     := ""      ;Sets working directory for temporary base archive (string);a,d,e,x,u
    compressLevel  := 5       ;0-9 (level);a,d,u
    compressType   := "zip"   ;7z,gzip,zip,bzip2,tar,iso,udf (string);a
    recurse        := 0       ;0:Disable, 1:Enable, 2:Enable only for wildcard names;a,d,e,x,u
    includeFile    := ""      ;Specifies filenames and wildcards or list file that specify processed files (string);a,d,e,x,u
    excludeFile    := ""      ;Specifies what filenames or (and) wildcards must be excluded from operation (string);a,d,e,x,u
    includeArchive := ""      ;Include archive filenames (string);e,x
    excludeArchive := ""      ;Exclude archive filenames (string);e,x
    overwrite      := 0       ;0:Overwrite All, 1:Skip extracting of existing, 2:Auto rename extracting file, 3:auto rename existing file;e,x
    extractPaths   := 1       ;Extract full paths (default 1);e,x
    output         := ""      ;Output directory (string);e,x
    
    toOption( key, val ) {
      return val ? " -" key val : ""
    }

    toBooleanOption( key, val ) {
      return val ? " -" key : ""  
    }

    toIncludeOption( key, val ) {
      if ! (val)
        return
        val := """" val """"
      return (SubStr(val,1,1) == "@") ? " -" key val : " -" key "!" val
    }

    _hide() {
      return this.toBooleanOption( "hide", this.hide )
    }

    _yes() {
      return this.toBooleanOption( "y", this.yes )
    }

    _password() {
      return this.toOption( "p", this.password )
    }

    _sfx() {
      return FileExist(this.SFX) ? " -sfx" . this.SFX : ""
    }

    _volumeSize() {
      return this.toOption( "v", this.volumeSize )
    }

    _workingDir() {
      return this.toOption( "w", this.workingDir )
    }

    _compressLevel() {
      return this.toOption( "mx", this.compressLevel )
    }

    _compressType() {
      return this.toOption( "t", this.compressType )
    }

    _recurse() {
      if this.recurse = 1
        return " -r"
      if this.recurse = 2
        return " -r0"
      Else
        return " -r-"
    }

    _includeFile() {
      return this.toIncludeOption( "i", this.includeFile )
    }

    _excludeFile() {
      return this.toIncludeOption( "x", this.excludeFile )
    }

    _includeArchive() {
      return this.toIncludeOption( "ai", this.includeArchive )
    }

    _excludeArchive() {
      return this.toIncludeOption( "ax", this.excludeArchive )
    }

    _overwrite() {
      if (this.overwrite = 0)
        return " -aoa"
      else if (this.overwrite = 1)
        return " -aos"
      else if (this.overwrite = 2)
        return " -aou"
      else if (this.overwrite = 3)
        return " -aot"
      Else
        return " -aoa"
    }

    _extractPaths() {
      return this.toOption( "o", this.extractPaths )
    }

    _output() {
      return this.toOption( "o", this.output )
    }

  }

}