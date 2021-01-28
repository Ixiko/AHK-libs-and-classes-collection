; Title:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=83269
; Link:
; Author:
; Date:
; for:     	AHK_L

/*		This lib offers 3 benefits:


		Collects all file properties in one call.
		Allows calling any combination of properties.
		50%+ faster compared to built-in AHK functions when looping through an array of files.
		Calling fewer properties is a bit faster than calling all of them.
		NOTE: This is not meant to be used inside a file loop. Only use this with an array ([] or {}) list of files. You will most likely notice a speed difference more when looping through at least hundreds of thousands of files.

		Usage:
		Code: Select all - Toggle Line numbers

		Usage:
		obj := GetFileAttributesEx(FileName, Properties := "ACWTS")

		obj.aTime    obj.size
		obj.cTime    obj.attrib (this property is an array[])
		obj.wTime
		Properties parameter:
		A = accessed time
		C = creation time
		W = write time (modified time)
		T = file attributes
		S = file size
		By default, all properties are called.

*/

/*
; AHK v1
; =====================================================================================
; === Example 1 =======================================================================
; =====================================================================================
; #NoEnv
; SetBatchLines, -1 ; required for fastest execution
; fileList := []

; Loop, Files, C:\Windows\*, R
    ; fileList.Push(A_LoopFileFullPath) ; := A_LoopFileFullPath

; MsgBox File list made ... starting benchmark.

; curTime := A_TickCount

; Loop, % fileList.Length() { ; run only one of these
    ; obj := GetFileAttributesEx(fileList[A_Index],"ACWTS") ; ACWTS / CWS
    ; obj := ahk_attribs(fileList[A_Index]) ; single ahk functions
    ; obj := ahk_attribs2(fileList[A_Index]) ; ahk file loop
; }

; ahk_attribs(inFile) { ; normal AHK functions
    ; If !FileExist(inFile)
        ; return
    ; FileGetSize, size, %inFile%
    ; FileGetTime, cTime, %inFile%, C
    ; FileGetTime, wTime, %inFile%, M

    ; return {cTime:cTime, wTime:wTime, size:size}
; }

; ahk_attribs2(inFile) {
    ; Loop, Files, inFile
    ; {
        ; result := {  aTime:A_LoopFileTimeAccessed
                  ; ,  cTime:A_LoopFileTimeCreated
                  ; ,  wTime:A_LoopFileTimeModified
                  ; ,   size:A_LoopFileSize
                  ; , attrib:A_LoopFileAttrib}
    ; }

    ; return result
; }

; msgbox % "Total: " fileList.Length() "`r`n`r`nElapsed: " (A_TickCount - curTime)/1000

; === Benchmarks ======================================================================
; 280,362 - 8.78s    / 8.83s  calling GetFileAttributesEx(file,"CSW")
; 280,362 - 10.95s   / 10.98s calling GetFileAttributesEx(file,"ACWTS")
; 280,362 - 28.297s  / 28.64s calling same properties ahk_attribs() (CSW)
; 280,337 - 28.09s   / 28.38s calling all properties ahk_attribs2() (ACWTS)
; =====================================================================================
; === Example 2 =======================================================================
; =====================================================================================

; fName := A_ScriptDir "\" A_ScriptName ; current script file
; o := GetFileAttributesEx(fName,"ACWTS")

; attr := ""
; For i, attrib in o.attr
    ; attr .= attrib "`r`n"

; MsgBox % "attributes:`r`n" attr "`r`n"
     ; . "CreationTime:`r`n" o.cTime "`r`n`r`n"
     ; . "AccessTime:`r`n" o.aTime "`r`n`r`n"
     ; . "WriteTime:`r`n" o.wTime "`r`n`r`n"
     ; . "size: " o.size
*/


; ====================================================================================
; GetFileAttributesEx() by TheArkive (requested by robodesign
; - Thanks to robodesign for testing, benchmarking, and assistance with optimizations.
;   His work took this already fast function and knocked of several seconds.
; ====================================================================================
GetFileAttributesEx(inFile,sOptions:="ACWTS") { ; A = access time / C = create time / W = write (modified) time / T = attributes / S = file size
    Static attr := { Archive:0x20 ; https://docs.microsoft.com/en-us/windows/win32/fileio/file-attribute-constants
            , Compressed:0x800, Device:0x40, Directory:0x10, Encrypted:0x4000, Hidden:0x2, integ_stream:0x8000, Normal:0x80, NotContentIndexed:0x2000
            , NoScrubData:0x20000, Offline:0x1000, ReadOnly:0x1, RecallOnDataAccess:0x400000, RecallOnOpen:0x40000, ReparsePoint:0x400, SparseFile:0x200
            , System:0x4, Temporary:0x100, Virtual:0x10000}

    ; Static attr := { ReadOnly:0x1 ; short list
            ; , Archive:0x20, System:0x4, Hidden:0x2, Normal:0x80, Directory:0x10, Offline:0x1000, Compressed:0x800, Temporary:0x100, Encrypted:0x4000}

    Static bSize := (A_PtrSize=8)?40:36
    VarSetCapacity(bFileAttribs,bSize,0) ; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfileattributesexw
    r := DllCall("GetFileAttributesExW","Str","\\?\" inFile,"Int",0,"Ptr",p2 := &bFileAttribs) ; (A_IsUnicode ? "W" : "A") ; (A_IsUnicode ? "\\?\" : "")

    AttrList := [], aTime := "", cTime := "", wTime := "", fileSize := "", fileSize := 0
    Loop, Parse, sOptions
    {
        Switch A_LoopField {
            Case "T":
                iAttribs := NumGet(bFileAttribs,"UInt")
                For attrib, value in attr
                    If (value & iAttribs)
                        AttrList[A_Index] := attrib
            Case "C": cTime := FileTimeToSystemTime(p2+4)
            Case "A": aTime := FileTimeToSystemTime(p2+12)
            Case "W": wTime := FileTimeToSystemTime(p2+20)
            Case "S": fileSize := (NumGet(bFileAttribs,28,"UInt") << 32) | NumGet(bFileAttribs,32,"UInt")
        }
    }

    return {attr:AttrList, cTime:cTime, aTime:aTime, wTime:wTime, size:fileSize}
}

FileTimeToSystemTime(ptr) {
    VarSetCapacity(SYSTEMTIME,16,0) ; https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-systemtime
    r := DllCall("FileTimeToSystemTime","Ptr",ptr,"Ptr",&SYSTEMTIME) ; https://docs.microsoft.com/en-us/windows/win32/api/timezoneapi/nf-timezoneapi-filetimetosystemtime

    VarSetCapacity(SYSTIME2,16,0)
    r := DllCall("SystemTimeToTzSpecificLocalTime","Ptr",0,"Ptr",&SYSTEMTIME,"Ptr",&SYSTIME2) ; https://docs.microsoft.com/en-us/windows/win32/api/timezoneapi/nf-timezoneapi-systemtimetotzspecificlocaltime

    year := NumGet(SYSTIME2,"UShort"),                      hour := Format("{:02d}",NumGet(SYSTIME2,8,"UShort"))
    month := Format("{:02d}",NumGet(SYSTIME2,2,"UShort")),  minute := Format("{:02d}",NumGet(SYSTIME2,10,"UShort"))
    day := Format("{:02d}",NumGet(SYSTIME2,6,"UShort")),    second := Format("{:02d}",NumGet(SYSTIME2,12,"UShort"))

    return year month day hour minute second
}