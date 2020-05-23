/*           ,---,                                          ,--,
           ,--.' |                                        ,--.'|
           |  |  :                      .--.         ,--, |  | :
  .--.--.  :  :  :                    .--,`|       ,'_ /| :  : '
 /  /    ' :  |  |,--.  ,--.--.       |  |.   .--. |  | : |  ' |
|  :  /`./ |  :  '   | /       \      '--`_ ,'_ /| :  . | '  | |
|  :  ;_   |  |   /' :.--.  .-. |     ,--,'||  ' | |  . . |  | :
 \  \    `.'  :  | | | \__\/: . .     |  | '|  | ' |  | | '  : |__
  `----.   \  |  ' | : ," .--.; |     :  | |:  | : ;  ; | |  | '.'|
 /  /`--'  /  :  :_:,'/  /  ,.  |   __|  : ''  :  `--'   \;  :    ;
'--'.     /|  | ,'   ;  :   .'   \.'__/\_: |:  ,      .-./|  ,   /
  `--'---' `--''     |  ,     .-./|   :    : `--`----'     ---`-'
                      `--`---'     \   \  /
                                    `--`-'
------------------------------------------------------------------
Function: 7-zip32.dll wrapper library
Author  : shajul (with generous help from Lexikos)
Requires: Autohotkey_L
URL: http://www.autohotkey.com/forum/viewtopic.php?t=69249
------------------------------------------------------------------
*/


/* PROPERTIES OF .opt ----------------------------------------------------------------------------------------------------------
Hide           ;Callback is called (bool);a,d,e,x,u
CompressLevel  ;0-9 (level);a,d,u
CompressType   ;7z,gzip,zip,bzip2,tar,iso,udf (string);a
Recurse        ;0 - Disable, 1 - Enable, 2 - Enable only for wildcard names;a,d,e,x,u
IncludeFile    ;Specifies filenames and wildcards or list file that specify processed files (string);a,d,e,x,u
ExcludeFile    ;Specifies what filenames or (and) wildcards must be excluded from operation (string);a,d,e,x,u
Password       ;Password (string);a,d,e,x,u
SFX            ;Self extracting archive module name (string);a,u
VolumeSize     ;Create volumes of specified sizes (integer);a
WorkingDir     ;Sets working directory for temporary base archive (string);a,d,e,x,u
ExtractPaths   ;Extract with full paths. Default is yes (bool);e,x
Output         ;Output directory (string);e,x
Overwrite      ;0 - Overwrite All, 1 - Skip extracting of existing, 2 - Auto rename extracting file, 3 - auto rename existing file;e,x
IncludeArchive ;Include archive filenames (string);e,x
ExcludeArchive ;Exclude archive filenames (string);e,x
Yes            ;assume Yes on all queries;e,x
-------------------------------------------------------------------------------------------------------------------------------
*/
7Zip_Init(sDllPath = "7-zip32.dll") {
	/*                              	DESCRIPTION

			 Function: 7Zip_Init
			 Description:
			      Initiate 7Zip (must be called only if 7-zip32.dll is not in same folder as script)
			 Syntax: 7Zip_Init([sDllPath])
			 Parameters:
			      sDllPath - (Optional) Path to 7-zip32.dll
			 Return Value:
			      Helper Object on success, 0 on failure
			 Remarks:
			      Object properties are mentioned below.
			 Related: 7Zip_Close
			 Example:
			      file:example.ahk

	*/

  global 7Zip_
  If 7Zip_._hModule
    return 7Zip_
  if !( r := DllCall("LoadLibrary", "Str", sDllPath) )
    return 0 , ErrorLevel := -1
  If !IsObject(7Zip_)
    7Zip_ := Object()

  7Zip_._hModule := r

  ;--- Default options
  7Zip_["opt","Hide"]      := 0       ;Callback is called (bool);a,d,e,x,u
  7Zip_.opt.CompressLevel  := 5       ;0-9 (level);a,d,u
  7Zip_.opt.CompressType   := "zip"   ;7z,gzip,zip,bzip2,tar,iso,udf (string);a
  7Zip_.opt.Recurse        := 0       ;0 - Disable, 1 - Enable, 2 - Enable only for wildcard names;a,d,e,x,u
  7Zip_.opt.IncludeFile    := ""      ;Specifies filenames and wildcards or list file that specify processed files (string);a,d,e,x,u
  7Zip_.opt.ExcludeFile    := ""      ;Specifies what filenames or (and) wildcards must be excluded from operation (string);a,d,e,x,u
  7Zip_.opt.Password       := ""      ;Password (string);a,d,e,x,u
  7Zip_.opt.SFX            := ""      ;Self extracting archive module name (string);a,u
  7Zip_.opt.VolumeSize     := 0       ;Create volumes of specified sizes (integer);a
  7Zip_.opt.WorkingDir     := ""      ;Sets working directory for temporary base archive (string);a,d,e,x,u
  7Zip_.opt.ExtractPaths   := 1       ;Extract full paths (default 1);e,x
  7Zip_.opt.Output         := ""      ;Output directory (string);e,x
  7Zip_.opt.Overwrite      := 0       ;0 - Overwrite All, 1 - Skip extracting of existing, 2 - Auto rename extracting file, 3 - auto rename existing file;e,x
  7Zip_.opt.IncludeArchive := ""      ;Include archive filenames (string);e,x
  7Zip_.opt.ExcludeArchive := ""      ;Exclude archive filenames (string);e,x
  7Zip_.opt.Yes            := 0       ;assume Yes on all queries;e,x

  7Zip_.FNAME_MAX32 := 512   ;Filename string max
  ;--- File attributes constants ---
  7Zip_.FA_RDONLY    := 0x01 ;Readonly
  7Zip_.FA_HIDDEN    := 0x02 ;Hidden
  7Zip_.FA_SYSTEM    := 0x04 ;System file
  7Zip_.FA_LABEL     := 0x08 ;Volume label
  7Zip_.FA_DIREC     := 0x10 ;Directory
  7Zip_.FA_ARCH      := 0x20 ;Retention bit
  7Zip_.FA_ENCRYPTED := 0x40 ;password protected

  return 7Zip_
}
7Zip_List(sArcName, hWnd=0) {
	/*                              	DESCRIPTION

			 Function: 7Zip_List
			 Description:
			      List files in an archive
			 Syntax: 7Zip_Add(hWnd, sArcName)
			 Parameters:
			      sArcName - Name of archive to list
			      hWnd - handle of window (calling application), can be 0
			 Return Value:
			      Response buffer (string) on success, 0 on failure.
			 Related:
			 Remarks:
			      Errorlevel is set to returned value of the function on success.

	*/

  global 7Zip_
  if !7Zip_Init()
    return 0

  opt := 7Zip_.opt
  commandline  = l "%sArcName%"
  commandline .= opt.Hide ? " -hide" : ""
  commandline .= opt.Password ? " -p" . opt.Password : ""

  return 7Zip__SevenZip(commandline)
}
7Zip_Add(sArcName, sFileName, hWnd=0) {
  global 7Zip_
  if !7Zip_Init()
    return 0 , ErrorLevel := -1
  opt := 7Zip_.opt
  commandline  = a "%sArcName%" "%sFileName%"
  commandline .= opt.Hide ? " -hide" : ""
  commandline .= " -mx" . opt.CompressLevel
  commandline .= " -t" . opt.CompressType
  commandline .= 7Zip__Recursion()
  commandline .= opt.Password ? " -p" . opt.Password : ""
  commandline .= FileExist(opt.SFX) ? " -sfx" . opt.SFX : ""
  commandline .= opt.VolumeSize ? " -v" . opt.VolumeSize : ""
  commandline .= opt.WorkingDir ? " -w" . opt.WorkingDir : ""

  if opt.IncludeFile
    commandline .= ( SubStr(opt.IncludeFile,1,1) = "@" ) ? " -i""" . opt.IncludeFile . """" : " -i!""" . opt.IncludeFile . """"
  if opt.ExcludeFile
    commandline .= ( SubStr(opt.ExcludeFile,1,1) = "@" ) ? " -x""" . opt.ExcludeFile . """" : " -x!""" . opt.ExcludeFile . """"

  return 7Zip__SevenZip(commandline)
}
7Zip_Delete(sArcName, sFileName, hWnd=0) {
	/*                              	DESCRIPTION

			 Function: 7Zip_Delete
			 Description:
			      Add files to archive
			 Syntax: 7Zip_Delete(hWnd, sArcName, sFileName)
			 Parameters:
			      sArcName - Name of the archive
							      hWnd - handle of window (calling application), can be 0
			 Return Value:
							 Remarks:
							 Related: 7Zip_Update , 7Zip_Add

	*/

  global 7Zip_
  if !7Zip_Init()
    return 0 , ErrorLevel := -1
  opt := 7Zip_.opt, nSize := 32768
  commandline  = d "%sArcName%" "%sFileName%"
  commandline .= opt.Hide ? " -hide" : ""
  commandline .= " -mx" . opt.CompressLevel
  commandline .= 7Zip__Recursion()
  commandline .= opt.Password ? " -p" . opt.Password : ""
  commandline .= opt.WorkingDir ? " -w" . opt.WorkingDir : ""

  if opt.IncludeFile
    commandline .= ( SubStr(opt.IncludeFile,1,1) = "@" ) ? " -i""" . opt.IncludeFile . """" : " -i!""" . opt.IncludeFile . """"
  if opt.ExcludeFile
    commandline .= ( SubStr(opt.ExcludeFile,1,1) = "@" ) ? " -x""" . opt.ExcludeFile . """" : " -x!""" . opt.ExcludeFile . """"

  return 7Zip__SevenZip(commandline)
}
7Zip_Extract(sArcName, hWnd=0) {
	/*                              	DESCRIPTION

			 Function: 7Zip_Extract
			 Description:
			      Extract files from archive
			 Syntax: 7Zip_Extract(hWnd, sArcName)
			 Parameters:
			      sArcName - Name of archive to extract
			      hWnd - handle of window (calling application), can be 0
			 Return Value:
			      Response buffer (string) on success, 0 on failure.
			 Remarks:
			      Errorlevel is set to returned value of the function on success.
			      Note that output folder can be specified as a property
			 Related: 7Zip_Update , 7Zip_Delete

	*/

  global 7Zip_
  if !7Zip_Init()
    return 0 , ErrorLevel := -1
  opt := 7Zip_.opt, nSize := 32768
  commandline := opt.ExtractPaths ? "x """ . sArcName . """" : "e """ . sArcName . """"
  commandline .= opt.Hide ? " -hide" : ""
  commandline .= 7Zip__Recursion()
  commandline .= opt.Output ? " -o""" . opt.Output . """" : ""
  commandline .= 7Zip__Overwrite()
  commandline .= opt.Password ? " -p" . opt.Password : ""
  commandline .= opt.WorkingDir ? " -w" . opt.WorkingDir : ""
  commandline .= opt.Yes ? " -y" : ""

  if opt.IncludeArchive
    commandline .= ( SubStr(opt.IncludeArchive,1,1) = "@" ) ? " -ai""" . opt.IncludeArchive . """" : " -ai!""" . opt.IncludeArchive . """"
  if opt.ExcludeArchive
    commandline .= ( SubStr(opt.ExcludeArchive,1,1) = "@" ) ? " -ax""" . opt.ExcludeArchive . """" : " -ax!""" . opt.ExcludeArchive . """"

  if opt.IncludeFile
    commandline .= ( SubStr(opt.IncludeFile,1,1) = "@" ) ? " -i""" . opt.IncludeFile . """" : " -i!""" . opt.IncludeFile . """"
  if opt.ExcludeFile
    commandline .= ( SubStr(opt.ExcludeFile,1,1) = "@" ) ? " -x""" . opt.ExcludeFile . """" : " -x!""" . opt.ExcludeFile . """"

  return 7Zip__SevenZip(commandline)
}
7Zip_Update(sArcName, sFileName, hWnd=0) {
	/*                              	DESCRIPTION

			 Function: 7Zip_Update
			 Description:
			      Update files to an archive
			 Syntax: 7Zip_Update(hWnd, sArcName, sFileName)
			 Parameters:
			      sArcName - Name of archive to be updated
			      sFileName - Files to add
			      hWnd - handle of window (calling application), can be 0
			 Return Value:
			      Response buffer (string) on success, 0 on failure.
			 Remarks:
			      Errorlevel is set to returned value of the function on success.
			 Related: 7Zip_Add , 7Zip_Delete

	*/

  global 7Zip_
  if !7Zip_Init()
    return 0 , ErrorLevel := -1
  opt := 7Zip_.opt
  commandline  = a "%sArcName%" "%sFileName%"
  commandline .= opt.Hide ? " -hide" : ""
  commandline .= " -mx" . opt.CompressLevel
  commandline .= 7Zip__Recursion()
  commandline .= opt.Password ? " -p" . opt.Password : ""
  commandline .= FileExist(opt.SFX) ? " -sfx" . opt.SFX : ""
  commandline .= opt.WorkingDir ? " -w" . opt.WorkingDir : ""

  if opt.IncludeFile
    commandline .= ( SubStr(opt.IncludeFile,1,1) = "@" ) ? " -i""" . opt.IncludeFile . """" : " -i!""" . opt.IncludeFile . """"
  if opt.ExcludeFile
    commandline .= ( SubStr(opt.ExcludeFile,1,1) = "@" ) ? " -x""" . opt.ExcludeFile . """" : " -x!""" . opt.ExcludeFile . """"
  return 7Zip__SevenZip(commandline)
}
7Zip_SetOwnerWindowEx(sProcFunc, hWnd=0) {
	/*                              	DESCRIPTION

			 Function: 7Zip_SetOwnerWindowEx
			 Description:
			      Appoints the call-back function in order to receive the information of the compressing/unpacking
			 Syntax: 7Zip_SetOwnerWindowEx(hWnd, sProcFunc)
			 Parameters:
			      sProcFunc - Callback function name
			      hWnd - handle of window (calling application), can be 0
			 Return Value:
			      True on success, false otherwise
			 Related: 7Zip_KillOwnerWindowEx
			 Example:
			      file:example_callback.ahk

	*/

  Address := RegisterCallback(sProcFunc, "F", 4)
  Return DllCall("7-zip32\SevenZipSetOwnerWindowEx","Ptr", hWnd , "ptr", Address)
}
7Zip_KillOwnerWindowEx(hWnd) {
	/*                              	DESCRIPTION

			 Function: 7Zip_KillOwnerWindowEx
			 Description:
			      Removes the callback
			 Syntax: 7Zip_KillOwnerWindowEx(hWnd)
			 Parameters:
			      hWnd - Handle to parent or owner window
			 Return Value:
			      True on success, false otherwise
			 Related: 7Zip_SetOwnerWindowEx

	*/

  Return DllCall("7-zip32\SevenZipKillOwnerWindowEx" , "Ptr", hWnd)
}
7Zip_CheckArchive(sArcName) {
	/*                              	DESCRIPTION


			 Function: 7Zip_CheckArchive
			 Description:
			      Check archive integrity
			 Syntax: 7Zip_CheckArchive(sArcName)
			 Parameters:
			      sArcName - Name of archive to be created
			 Return Value:
			      True on success, false otherwise


	*/

  Return DllCall("7-zip32\SevenZipCheckArchive", "AStr", sArcName, "int", 0)
}
7Zip_GetArchiveType(sArcName) {
	/*                              	DESCRIPTION


			 Function: 7Zip_GetArchiveType
			 Description:
			      Get the type of archive
			 Syntax: 7Zip_GetArchiveType(sArcName)
			 Parameters:
			      sArcName - Name of archive
			 Return Value:
			      0 - Unknown type
			      1 - ZIP type
			      2 - 7Z type
			      -1 - Failure


	*/

  Return DllCall("7-zip32\SevenZipGetArchiveType", "AStr", sArcName)
}
7Zip_GetFileCount(sArcName) {
	/*                              	DESCRIPTION


			 Function: 7Zip_GetFileCount
			 Description:
			      Get the number of files in archive
			 Syntax: 7Zip_GetFileCount(sArcName)
			 Parameters:
			      sArcName - Name of archive
			 Return Value:
			      Count on success, -1 otherwise


	*/

  Return DllCall("7-zip32\SevenZipGetFileCount", "AStr", sArcName)
}
7Zip_ConfigDialog(hWnd) {
	/*                              	DESCRIPTION


			 Function: 7Zip_ConfigDialog
			 Description:
			      Shows the about dialog for 7-zip32.dll
			 Syntax: 7Zip_ConfigDialog(hWnd)
			 Parameters:
			      hWnd - handle of owner window


	*/

  Return DllCall("7-zip32\SevenZipConfigDialog", "Ptr", hWnd, "ptr",0, "int",0)
}
7Zip_QueryFunctionList(iFunction = 0) {
  Return DllCall("7-zip32\SevenZipQueryFunctionList", "int", iFunction)
}
7Zip_GetVersion() {
	/*                              	DESCRIPTION


			 Function: 7Zip_GetVersion
			 Description:
			      Version of 7-zip32.dll
			 Syntax: 7Zip_GetVersion()
			 Return Value:
			      Version string


	*/

  aRet := DllCall("7-zip32\SevenZipGetVersion", "Short")
  Return SubStr(aRet,1,1) . "." . SubStr(aRet,2)
}
7Zip_GetSubVersion() {
	/*                              	DESCRIPTION


			 Function: 7Zip_GetSubVersion
			 Description:
			      Subversion of 7-zip32.dll
			 Syntax: 7Zip_GetSubVersion()
			 Return Value:
			      Subversion string


	*/

  return DllCall("7-zip32\SevenZipGetSubVersion", "Short")
}
7Zip_Close() {
	/*                              	DESCRIPTION


			 Function: 7Zip_Close
			 Description:
			      Free 7-zip32.dll library
			 Syntax: 7Zip_Close()


	*/

  global 7Zip_
  DllCall("FreeLibrary", "Ptr", 7Zip_._hModule)
  7Zip_ := ""
}

; FUNCTIONS BELOW - CREDIT TO LEXIKOS -------------------------------------------------------
7Zip_OpenArchive(sArcName, hWnd=0) {

	/*                              	DESCRIPTION


			 Function: 7Zip_OpenArchive
			 Description:
			      Open archive and return handle for use with 7Zip_FindFirst
			 Syntax: 7Zip_OpenArchive(sArcName, [hWnd])
			 Parameters:
			      sArcName - Path of archive
			      hWnd - Handle of calling window
			 Return Value:
			      Handle for use with 7Zip_FindFirst function, 0 on error.
			 Remarks:
			      Nil
			 Related: 7Zip_CloseArchive, 7Zip_FindFirst , File Info Functions
			 Example:
			      hArc := 7Zip_OpenArchive("C:\Path\To\Archive.7z")


	*/

  Return DllCall("7-zip32\SevenZipOpenArchive", "Ptr", hWnd, "AStr", sArcName, "int", 0)
}
7Zip_CloseArchive(hArc) {

	/*                              	DESCRIPTION


			 Function: 7Zip_CloseArchive
			 Description:
			      Closes the archive handle
			 Syntax: 7Zip_CloseArchive(hArc)
			 Parameters:
			      hArc - Handle retrived from 7Zip_OpenArchive
			 Return Value:
			      -1 on error
			 Remarks:
			      Nil
			 Related: 7Zip_OpenArchive
			 Example:
			      7Zip_CloseArchive(hArc)


	*/


  Return DllCall("7-zip32\SevenZipCloseArchive", "Ptr", hArc)
}
7Zip_FindFirst(hArc, sSearch, o7zip__info="") {

	/*                              	DESCRIPTION


			 Function: 7Zip_FindFirst
			 Description:
			      Find first file for search criteria in archive
			 Syntax: 7Zip_FindFirst(hArc, sSearch, [o7zip__info])
			 Parameters:
			      hArc - handle of archive (returned from 7Zip_OpenArchive)
			      sSearch - Search string (wildcards allowed)
			      o7zip__info - (Optional) Name of object to recieve details of file.
			 Return Value:
			      Object with file details on success. If 3rd param was 0, returns true on success. False on failure.
			 Remarks:
			      If third param is omitted, details are returned in a new object.
			      If it is set to 0, details are not retrieved. (You can use the other functions to get details.)
			 Related: 7Zip_FindNext , 7Zip_OpenArchive , File Info Functions
			 Example:
			      file:example_archive_info.ahk


	*/


  if (o7zip__info = 0)
  {
    r := DllCall("7-zip32\SevenZipFindFirst", "Ptr", hArc, "AStr", sSearch, "ptr", 0)
    return ( r ? 0 : 1 ), ErrorLevel := (r ? r : ErrorLevel)
  }
  if !IsObject(o7zip__info)
    o7zip__info := Object()
  VarSetCapacity(tINDIVIDUALINFO , 558, 0)

  If DllCall("7-zip32\SevenZipFindFirst", "Ptr", hArc, "AStr", sSearch, "ptr", &tINDIVIDUALINFO)
    Return 0
  o7zip__info.OriginalSize   := NumGet(tINDIVIDUALINFO , 0, "UInt")
  o7zip__info.CompressedSize := NumGet(tINDIVIDUALINFO , 4, "UInt")
  o7zip__info.CRC            := NumGet(tINDIVIDUALINFO , 8, "UInt")
; uFlag                      := NumGet(tINDIVIDUALINFO , 12, "UInt") ;always 0
; uOSType                    := NumGet(tINDIVIDUALINFO , 16, "UInt") ;always 0
  o7zip__info.Ratio          := NumGet(tINDIVIDUALINFO , 20, "UShort")
  o7zip__info.Date           := 7Zip_DosDateTimeToStr(NumGet(tINDIVIDUALINFO , 22, "UShort"),NumGet(tINDIVIDUALINFO , 24, "UShort"))
  o7zip__info.FileName       := StrGet(&tINDIVIDUALINFO+26 ,513,"CP0")
  o7zip__info.Attribute      := StrGet(&tINDIVIDUALINFO+542,8  ,"CP0")
  o7zip__info.Mode           := StrGet(&tINDIVIDUALINFO+550,8  ,"CP0")

  return o7zip__info
}
7Zip_FindNext(hArc, o7zip__info="") {

	/*                              	DESCRIPTION

			 Function: 7Zip_FindNext
			 Description:
			      Find next file for search criteria in archive
			 Syntax: 7Zip_FindNext(hArc, [o7zip__info])
			 Parameters:
			      hArc - handle of archive (returned from 7Zip_OpenArchive)
			      o7zip__info - (Optional) Name of object to recieve details of file.
			 Return Value:
			      Object with file details on success. If 2nd param was 0, returns true on success. False on failure.
			 Remarks:
			      If second param is omitted, details are returned in a new object.
			      If it is set to 0, details are not retrieved. (You can use the other functions to get details.)
			 Related: 7Zip_FindFirst , 7Zip_OpenArchive, File Info Functions
			 Example:
			      file:example_archive_info.ahk

	*/


  if (o7zip__info = 0)
  {
    r := DllCall("7-zip32\SevenZipFindFirst", "Ptr", hArc, "AStr", sSearch, "ptr", 0)
    return ( r ? 0 : 1 ), ErrorLevel := (r ? r : ErrorLevel)
  }
  if !IsObject(o7zip__info)
    o7zip__info := Object()
  VarSetCapacity(tINDIVIDUALINFO , 558, 0)
  if DllCall("7-zip32\SevenZipFindNext","Ptr", hArc, "ptr", &tINDIVIDUALINFO)
    Return 0

  o7zip__info.OriginalSize   := NumGet(tINDIVIDUALINFO , 0, "UInt")
  o7zip__info.CompressedSize := NumGet(tINDIVIDUALINFO , 4, "UInt")
  o7zip__info.CRC            := NumGet(tINDIVIDUALINFO , 8, "UInt")
  o7zip__info.Ratio          := NumGet(tINDIVIDUALINFO , 20, "UShort")
  o7zip__info.Date           := 7Zip_DosDateTimeToStr(NumGet(tINDIVIDUALINFO , 22, "UShort"),NumGet(tINDIVIDUALINFO , 24, "UShort"))
  o7zip__info.FileName       := StrGet(&tINDIVIDUALINFO+26 ,513,"CP0")
  o7zip__info.Attribute      := StrGet(&tINDIVIDUALINFO+542,8  ,"CP0")
  o7zip__info.Mode           := StrGet(&tINDIVIDUALINFO+550,8  ,"CP0")

  return o7zip__info
}

	/*     DESCRIPTION of Function: File Info Functions


			 Description:
			      Using handle hArc, get info of file(s) in archive.
			 Syntax: 7Zip_<InfoFunction>(hArc)
			 Parameters:
			      7Zip_GetFileName - Get file name
			      7Zip_GetArcOriginalSize - Original size of file
			      7Zip_GetArcCompressedSize - Compressed size
			      7Zip_GetArcRatio - Compression ratio
			      7Zip_GetDate - Date
			      7Zip_GetTime - Time
			      7Zip_GetCRC - File CRC
			      7Zip_GetAttribute - File Attribute
			      7Zip_GetMethod - Compression method (LZMA or PPMD)
			 Return Value:
			      -1 on error
			 Remarks:
			      See included example for details
			 Related: 7Zip_OpenArchive , 7Zip_FindFirst
			 Example:
			      file:example_archive_info.ahk


	*/

7Zip_GetFileName(hArc) {
  VarSetCapacity(tNameBuffer,513)
  If !DllCall("7-zip32\SevenZipGetFileName", "Ptr", hArc, "ptr", &tNameBuffer, "int", 513)
    Return StrGet(&tNameBuffer,513,"CP0")
}
7Zip_GetArcOriginalSize(hArc) {
  Return DllCall("7-zip32\SevenZipGetArcOriginalSize", "Ptr", hArc)
}
7Zip_GetArcCompressedSize(hArc) {
  Return DllCall("7-zip32\SevenZipGetArcCompressedSize", "Ptr", hArc)
}
7Zip_GetArcRatio(hArc) {
  Return DllCall("7-zip32\SevenZipGetArcRatio", "Ptr", hArc, "short")
}
7Zip_GetDate(hArc) {
  Return 7Zip_DosDate(DllCall("7-zip32\SevenZipGetDate", "Ptr", hArc, "Short"))
}
7Zip_GetTime(hArc) {
  Return 7Zip_DosTime(DllCall("7-zip32\SevenZipGetTime", "Ptr", hArc, "Short"))
}
7Zip_GetCRC(hArc) {
  Return DllCall("7-zip32\SevenZipGetCRC", "Ptr", hArc, "UInt")
}
7Zip_GetMoreCRC(7zipDll, FileName, sSearch := "") {
	if !hArc := DllCall(7zipDll . "\SevenZipOpenArchive", "ptr", 0, "astr", FileName, "int", 0)
		throw "SevenZipOpenArchive fail"

	VarSetCapacity(info, 558, 0)
	ret := DllCall(7zipDll . "\SevenZipFindFirst", "ptr", hArc, "astr", sSearch, "ptr", &info)

	result := []
	while (ret = 0) {
		result[A_Index, "CRC"     ] := Format("{:X}", NumGet(info, 8, "uint"))
		result[A_Index, "FileName"] := StrGet(&info+26, 513, "cp0")
		ret := DllCall(7zipDll . "\SevenZipFindNext", "ptr", hArc, "ptr", &info)
	}

	DllCall(7zipDll . "\SevenZipCloseArchive", "ptr", hArc)
	return result.MaxIndex() ? result : ""
}
7Zip_GetAttribute(hArc) {
  return DllCall("7-zip32\SevenZipGetAttribute", "Ptr", hArc)
}
7Zip_GetMethod(hArc) {
  VarSetCapacity(sBUFFER,8)
  if !DllCall("7-zip32\SevenZipGetMethod" , "Ptr", hArc , "ptr", &sBuffer,"int", 8)
    Return StrGet(&sBUFFER, 8, "CP0")
}

; FUNCTIONS FOR INTERNAL USE --------------------------------------------------------------------------------------------------
7Zip__SevenZip(sCommand) {
  nSize := 32768
  VarSetCapacity(tOutBuffer,nSize)
  aRet := DllCall("7-zip32\SevenZip", "Ptr", hWnd
          ,"AStr", sCommand
          ,"Ptr", &tOutBuffer
          ,"Int", nSize)
  If !ErrorLevel
    return StrGet(&tOutBuffer,nSize,"CP0"), ErrorLevel := aRet
  else
    return 0
}
7Zip__Recursion() {
  global 7Zip_
    if 7Zip.opt.Recurse = 1
      Return " -r"
    if 7Zip.opt.Recurse = 2
      Return " -r0"
    Else
      Return " -r-"
}
7Zip__Overwrite() {
  global 7Zip_
  if (7Zip_.opt.Overwrite = 0)
    Return " -aoa"
  else if (7Zip_.opt.Overwrite = 1)
    Return " -aos"
  else if (7Zip_.opt.Overwrite = 2)
    Return " -aou"
  else if (7Zip_.opt.Overwrite = 3)
    Return " -aot"
  Else
    Return " -aoa"
}
7Zip_DosDate(ByRef DosDate) {
  day   := DosDate & 0x1F
  month := (DosDate<<4) & 0x0F
  year  := ((DosDate<<8) & 0x3F) + 1980
  return "" . year . "/" . month . "/" . day
}
7Zip_DosTime(ByRef DosTime) {
  sec   := (DosTime & 0x1F) * 2
  min   := (DosTime<<4) & 0x3F
  hour  := (DosTime<<10) & 0x1F
  return "" . hour . ":" . min . ":" . sec
}
7Zip_DosDateTimeToStr( ByRef DosDate, ByRef DosTime) {
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