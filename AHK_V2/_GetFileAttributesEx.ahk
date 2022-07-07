; AHK v2
; =====================================================================================
; === Example 1 =======================================================================
; =====================================================================================
; fileList := []

; MsgBox "Making a list of files in C:\Windows\*`r`n`r`nThis list should be about 280,000 files and will take about 15-30 seconds."

; Loop Files "C:\Windows\*", "R"
    ; fileList.Push(A_LoopFileFullPath) ; := A_LoopFileFullPath

; MsgBox "File list made ... starting benchmark."

; curTime := A_TickCount

; Loop fileList.Length { ; pick ONLY ONE of these to test
    ; obj := GetFileAttributesEx(fileList[A_Index],"CWS") ; ACWTS / CWS
    ;;;;;;;;;; obj := ahk_attribs(fileList[A_Index]) ; AHK FileGet... functions
    ;;;;;;;;;; obj := ahk_attribs2(fileList[A_Index]) ; AHK File Loop method
; }

; ahk_attribs(inFile) { ; normal AHK functions
    ; If !FileExist(inFile)
        ; return
    ; size := FileGetSize(inFile)
    ; cTime := FileGetTime(inFile, "C")
    ; wTime := FileGetTime(inFile, "M")
    
    ; return {cTime:cTime, wTime:wTime, size:size}
; }

; ahk_attribs2(inFile) {
    ; If !FileExist(inFile)
        ; return
    ; Loop Files inFile
    ; {
        ; result := {  aTime:A_LoopFileTimeAccessed
                  ; ,  cTime:A_LoopFileTimeCreated
                  ; ,  wTime:A_LoopFileTimeModified
                  ; ,   size:A_LoopFileSize
                  ; , attrib:A_LoopFileAttrib}
    ; }
    
    ; return result
; }

; msgbox "Total: " fileList.Length "`r`n`r`nElapsed: " (A_TickCount - curTime)/1000

; === Benchmarks ======================================================================
; 280,361 -  8.77s  / 8.89s  calling GetFileAttributesEx(file,"CSW")
; 280,361 - 11.09s  / 11.14s calling GetFileAttributesEx(file,"ACWTS")
; 280,361 - 28.08s  / 28.38s calling same properties ahk_attribs() (Size/Modified/Created)
; 280,340 - 52.296s / 52.50s calling ahk_attribs2() all properties
; =====================================================================================
; === Example 2 =======================================================================
; =====================================================================================

; fName := A_ScriptDir "\" A_ScriptName ; current script file
; o := GetFileAttributesEx(fName,"ACWTS")

; attr := ""
; For i, attrib in o.attr
    ; attr .= attrib "`r`n"

; MsgBox "attributes:`r`n" attr "`r`n"
     ; . "CreationTime:`r`n" o.cTime "`r`n`r`n"
     ; . "AccessTime:`r`n" o.aTime "`r`n`r`n"
     ; . "WriteTime:`r`n" o.wTime "`r`n`r`n"
     ; . "size: " o.size

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
    bFileAttribs := Buffer(bSize,0) ; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfileattributesexw
    r := DllCall("GetFileAttributesExW","Str","\\?\" inFile,"Int",0,"Ptr",p2 := bFileAttribs.ptr)
    
    AttrList := [], aTime := "", cTime := "", wTime := "", fileSize := "", fileSize := 0
    Loop Parse sOptions
    {
        Switch A_LoopField {
            Case "T":
                iAttribs := NumGet(bFileAttribs,"UInt")
                For attrib, value in attr.OwnProps()
                    If (value & iAttribs)
                        AttrList.Push(attrib)
            Case "C": cTime := FileTimeToSystemTime(p2+4)
            Case "A": aTime := FileTimeToSystemTime(p2+12)
            Case "W": wTime := FileTimeToSystemTime(p2+20)
            Case "S": fileSize := (NumGet(bFileAttribs,28,"UInt") << 32) | NumGet(bFileAttribs,32,"UInt")
        }
    }
    
    return {attr:AttrList, cTime:cTime, aTime:aTime, wTime:wTime, size:fileSize}
    
    FileTimeToSystemTime(ptr) {         
        SYSTEMTIME := Buffer(16,0) ; https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-systemtime
        r := DllCall("FileTimeToSystemTime","Ptr",ptr,"Ptr",SYSTEMTIME.ptr) ; https://docs.microsoft.com/en-us/windows/win32/api/timezoneapi/nf-timezoneapi-filetimetosystemtime
        SYSTIME2 := Buffer(16,0)
        r := DllCall("SystemTimeToTzSpecificLocalTime","Ptr",0,"Ptr",SYSTEMTIME.ptr,"Ptr",SYSTIME2.Ptr) ; https://docs.microsoft.com/en-us/windows/win32/api/timezoneapi/nf-timezoneapi-systemtimetotzspecificlocaltime
        
        year := NumGet(SYSTIME2,"UShort"),                      hour := Format("{:02d}",NumGet(SYSTIME2,8,"UShort"))
        month := Format("{:02d}",NumGet(SYSTIME2,2,"UShort")),  minute := Format("{:02d}",NumGet(SYSTIME2,10,"UShort"))
        day := Format("{:02d}",NumGet(SYSTIME2,6,"UShort")),    second := Format("{:02d}",NumGet(SYSTIME2,12,"UShort"))
        
        return year month day hour minute second
    }
}