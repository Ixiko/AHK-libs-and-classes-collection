/*  TheGood
    Simple file functions
    
    File_Open:      Opens a file for subsequent operations
    File_Read:      Reads bytes from a file at the current file pointer and moves the file pointer forward by the number of bytes read
    File_Write:     Writes bytes to a file at the current file pointer and moves the file pointer forward by the number of bytes written
    File_Pointer:   Moves the file pointer to a specified position
    File_Size:      Returns the size of a file
    File_Close:     Closes a file
*/

/*  sType   = One of the following strings:
                "READ"    : Opens the file for reading
                "WRITE"   : Opens the file for writing
                "READSEQ" : Opens the file for sequential reading (same as READ but offers better performance if reading will mainly be sequential)
    sFile   = File name to open
    On success, returns the file handle
    On failure, returns -1 with ErrorLevel = error code
*/
File_Open(sType, sFile) {
    
    bRead := InStr(sType, "READ")
    bSeq  := sType = "READSEQ"
    
    ;Open the file for writing with GENERIC_WRITE/GENERIC_READ, NO SHARING/FILE_SHARE_READ & FILE_SHARE_WRITE, and OPEN_ALWAYS/OPEN_EXISTING, and FILE_FLAG_SEQUENTIAL_SCAN
    hFile := DllCall("CreateFile", "Str", sFile, "UInt", bRead ? 0x80000000 : 0x40000000, "UInt", bRead ? 3 : 0, "Ptr", 0, "UInt", bRead ? 3 : 4, "UInt", bSeq ? 0x08000000 : 0, "Ptr", 0, "Ptr")
    If (hFile = -1 Or ErrorLevel) { ;Check for any error other than ERROR_FILE_EXISTS
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1 ;Return INVALID_HANDLE_VALUE
    } Else Return hFile
}

/*  hFile   = File handle
    bData   = Variable which will hold data read
    iLength = Number of bytes to read; set to 0 to read to the end
    On success, returns the number of bytes actually read
    On failure, returns -1 with ErrorLevel = error code
*/
File_Read(hFile, ByRef bData, iLength = 0) {
    
    ;Check if we're reading up to the rest of the file
    If Not iLength ;Set the length equal to the remaining part of the file
        iLength := File_Size(hFile) - File_Pointer(hFile)
    
    ;Prep the variable
    VarSetCapacity(bData, iLength, 0)
    
    ;Read the file
    r := DllCall("ReadFile", "Ptr", hFile, "Ptr", &bData, "UInt", iLength, "UInt*", iLengthRead, "Ptr", 0)
    If (Not r Or ErrorLevel) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1
    } Else Return iLengthRead
}

/*  hFile   = File handle
    ptrData = Pointer to the data to write to the file
    iLength = Number of bytes to write
    On success, returns the number of bytes actually written
    On failure, returns -1 with ErrorLevel = error code
*/
File_Write(hFile, ptrData, iLength) {
    
    ;Write to the file
    r := DllCall("WriteFile", "Ptr", hFile, "Ptr", ptrData, "UInt", iLength, "UInt*", iLengthWritten, "Ptr", 0)
    If (Not r Or ErrorLevel) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1
    } Else Return iLengthWritten
}

/*  hFile   = File handle
    iOffset = Number of bytes to move the file pointer. If iMethod = -1, then
                A positive iOffset moves the pointer forward from the beginning of the file.
                A negative iOffset moves the pointer backwards from the end of the file.
                Leave as 0 to return the current file pointer.
              If iMethod <> -1, iOffset represents the number of bytes to move the file pointer using the selected method
    iMethod = Leave as -1 for the movement to behave as described in iOffset's description
              Otherwise, explicitly set to either "BEGINNING" (or 0), "CURRENT" (or 1), or "END" (or 2):
                "BEGINNING" : Move starts from the beginning of the file. iOffset must be greater than or equal to 0.
                "CURRENT"   : Move starts from the current file pointer.
                "END"       : Move starts from the end of the file. iOffset must be less than or equal to 0.
    On success, returns the new file pointer
    On failure, returns -1 with ErrorLevel = error code
*/
File_Pointer(hFile, iOffset = 0, iMethod = -1) {
    
    ;Check if we're on auto
    If (iMethod = -1) {
        
        ;Check if we should use FILE_BEGIN, FILE_CURRENT, or FILE_END
        If (iOffset = 0)
            iMethod := 1 ;We're just retrieving the current pointer. FILE_CURRENT
        Else If (iOffset > 0)
            iMethod := 0 ;We're moving from the beginning. FILE_BEGIN
        Else If (iOffset < 0)
            iMethod := 2 ;We're moving from the end. FILE_END
    } Else If iMethod Is Not Integer
        iMethod := (iMethod = "BEGINNING" ? 0 : (iMethod = "CURRENT" ? 1 : (iMethod = "END" ? 2 : 0)))
    
    r := DllCall("SetFilePointerEx", "Ptr", hFile, "Int64", iOffset, "Int64*", iNewPointer, "UInt", iMethod)
    If (Not r Or ErrorLevel) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1
    } Else Return iNewPointer
}

/*  hFile = File handle
    On success, returns the file size
    On failure, returns -1 with ErrorLevel = error code
*/
File_Size(hFile) {
    r := DllCall("GetFileSizeEx", "Ptr", hFile, "Int64*", iFileSize)
    If (Not r Or ErrorLevel) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return -1
    } Else Return iFileSize
}

/*  hFile = File handle
    On success, returns True
    On failure, returns False
*/
File_Close(hFile) {
    If Not (r := DllCall("CloseHandle", "Ptr", hFile)) {
        ErrorLevel := ErrorLevel ? ErrorLevel : A_LastError
        Return False
    } Return True
}
