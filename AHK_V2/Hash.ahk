;=================================================================
; CygHash(Mode,TargetType,TargetPath,HashType,DigestFile:="")
;
; * In "hash/hash-rel" mode, DigestFile is a temp file. If it is
;   not specified it will be autmatically created and deleted. If
;   it is specified, then it will be created in the specified
;   path/file name and not deleted.
;
; * In "compare" mode (folder only) DigestFile is the digest file
;   to be used to compare files in folder: TargetPath.
;
; * In "compare" mode (file only) DigestFile is the actual digest
;   to be used in a comparison for the single file.
;
; * When TargetType is file/folder then TargetPath MUST be a
;   file/folder respectively.  Otherwise the called exe might hang
;   because of an invalid path/switches combo.
;
; Mode = hash,hash-rel,compare
; - "hash" returns full-path hash data and DigestFile if specified.
; - "hash-rel" is the same but returns relative paths only
; - "compare" only returns hash data
;
; TargetType = file,folder
; - Mode:[hash/hash-rel]
;   * TargetType > "file" > returns only hash
;   * TargetType > "folder" > returns hash data and DigestFile if specified
; - Mode:[compare]
;   * TargetType > "file" > returns true/false if specified hash (defined in DigestFile) matches.
;   * TargetType > "folder" > returns files not matching any hash data defined in DigestFile.
;                             If "" is returned, then all files matched.
; NOTE: For {Mode:compare} {TargetType:folder} you must choose how to handle the data, ie
;       dump it to a file, or parse it in a script.
;    
; TargetPath = file or folder to be hashed or compared
; - if Mode is "hash/hash-rel" then this is the file/folder to be hashed.
; - if Mode is "compare" then this is the folder to compare against specified DigestFile.
;
; HashType = tiger,whirlpool,md5,sha1,sha256
;
; returns:
; - when hashing (hash/hash-rel) folder, all hash data
;   * DigestFile will remain if specified.
;   * Format: [digest]  [path...]
; - when hashing single file, only returns digest
; - when comparing (folder only), returns all mismatches
;
; If you want to compare a hash value for a single file you must
; write your own code to do this, but you can get the hash value
; of the file in question by setting Mode="compare".  You can
; use a GUI or check %clipboard% for a hash value.

;=================================================================
; Dev Notes
;=================================================================
; This library uses hash functions (binaries) provided in the Cygwin
; distributions:
;
; tigerdeep, whirlpooldeep, md5deep, sha1deep, sha256deep
;
; DLL Dependencies: cyggcc_s-seh-1.dll, cygstdc++-6.dll, cygwin1.dll
; * Available in the same "bin" folder as the binaries.
; * Just add a folder to PATH envvar that contains all exes and DLLs.

; LISTING HASHES - output digest for each file
; Syntax : sha256deep -lr . (musg set working dir for this to work)
; Syntax : sha256deep -r "C:\path" (-r recurse directories)
; - NOTE: no trailing slash needed for directories
;         output changes \ to / (not a huge deal)
;         busy files have the following msg: 
;         C:\path\to\file: Device or resource busy
;
;                                             C: \path\to\fie
; - NOTE: paths are best typed as /cygdrive/drive/path/to/file
;         This library handles the output to ensure seamless compliance
;         with typical windows file naming conventions.
;
; The -l switch only works when the working dir is being hashed and therefore
; not specified on the command line.  If you specify an absolute path you will
; get absolute paths output in the digest file regardless of -l switch.

; COMPARING HASHES - output mismatched files only
; (only list non matching or duplicate)
; duplicates can happen when file contents between 2 or more files are identical
;
; Syntax : sha256deep -M "C:\path\to\digest.file" -lrn "C:\path\to\be\hashed"

; NOTES:
; Any files opened and thus not accessible will be automatically omitted from
; the resulting digest.  These are put out to stderr, and are currently not
; handled by these functions.
;
; Only relative paths (for now) will be a part of this library.  Most file
; packages are always best handled in a relative context anyways.


; Tests
;==============================================
; result := CygHash("hash","file","C:\Users\Jeb6\Desktop\openwrt-15.05.1-mvebu-armada-xp-linksys-mamba-squashfs-factory.img","sha256","")

; correct hash
; result := CygHash("compare","file","C:\Users\Jeb6\Desktop\openwrt-15.05.1-mvebu-armada-xp-linksys-mamba-squashfs-factory.img","sha256","d5d7e0878cb4dcdf373d8d8e54ada37cc0d4b328ce54a96f253233d542d6e365")

; incorrect hash
; result := CygHash("compare","file","C:\Users\Jeb6\Desktop\openwrt-15.05.1-mvebu-armada-xp-linksys-mamba-squashfs-factory.img","sha256","d5d7e0878cb4dcdf373d8d8e54ada37cc0d4b328ce54a96f253233d542d6e")


; result := CygHash("hash","folder","C:\Users\Jeb6\AppData\Roaming\foobar2000","sha256","C:\Users\Jeb6\Desktop\test.sha")
; result := CygHash("hash-rel","folder","C:\Users\Jeb6\AppData\Roaming\Notepad++","sha256","C:\Users\Jeb6\Desktop\test.sha")

; result := CygHash("compare","folder","C:\Users\Jeb6\AppData\Roaming\Notepad++","sha256","C:\Users\Jeb6\Desktop\test.sha")

; result := WinPath("/cygdrive/c/Windows/System32/test.txt")
; result := WinPath("./Windows/System32/test.txt")

; MsgBox % result
; FileDelete, C:\Users\Jeb6\Desktop\result.sha
; FileAppend, %result%, C:\Users\Jeb6\Desktop\result.sha

CygHash(Mode,TargetType,TargetPath,HashType,DigestFile:="") {    
    DebugNow = 0
    DelDigest := False
    TempDigestFile = %A_WorkingDir%\TempHash.txt
    TempDigestFile2 = %A_WorkingDir%\TempHash2.txt
    TempBatchFile = %A_WorkingDir%\TempBatch.bat
    
    ; check for stuck running process, try to terminate if found
    ProcList := "md5deep.exe whirlpooldeep.exe tigerdeep.exe sha1deep.exe sha256deep.exe"
    Loop, Parse, ProcList, %A_Space%
    {
        ProcName := A_LoopField
        
        Process, Exist, %ProcName%
        If (ErrorLevel > 0) {
            Process, Close, %ProcName%
            If (ErrorLevel > 0) {
                MsgBox %ProcName% could not be terminated.  Halting.
                return
            }
        }
    }
    
    ; check for bad parameters
    If (Mode = "") {
        MsgBox CygHash(): Mode not defined.
    }
    If (TargetType = "") {
        MsgBox CygHash(): TargetType not defined.
    }
    If (TargetPath = "") {
        MsgBox CygHash(): TargetPath not defined.
    }
    If (FileExist(TargetPath) = "") {
        MsgBox CygHash(): TargetPath is invalid: %TargetPath%
    }
    If (HashType = "") {
        MsgBox CygHash(): HashType not defined.
    }
    
    ; determine exe
    If (HashType = "tiger") {
        exe := "tigerdeep.exe"
    }
    Else If (HashType = "whirlpool")
    {
        exe := "whirlpooldeep.exe"
    }
    Else If (HashType = "md5")
    {
        exe := "md5deep.exe"
    }
    Else If (HashType = "sha1")
    {
        exe := "sha1deep.exe"
    }
    Else If (HashType = "sha256")
    {
        exe := "sha256deep.exe"
    }

    switch := "-r"
    DigestTarget := CygPath(TargetPath)

    If (Mode = "hash-rel")
    {
        switch := "-lr"
        DigestTarget := "."
    }
    
    ; clear temp files
    FileDelete, %TempDigestFile2%
    FileDelete, %TempBatchFile%
    FileDelete, %TempDigestFile%
    
    If (Mode = "hash" Or Mode = "hash-rel") {
        If (TargetType = "folder") {
            FileAppend, @ECHO OFF`r`n, %TempBatchFile%
            FileAppend, CD "%TargetPath%"`r`n, %TempBatchFile%
            FileAppend, %exe% -W "%TempDigestFile%" %switch% "%DigestTarget%", %TempBatchFile%
            RunWait, %TempBatchFile%, , Hide

            FileRead, HashResult, %TempDigestFile%
            HashResult := WinPath(HashResult,TargetPath)
            
            If (DigestFile <> "") {
                FileDelete, %DigestFile%
                FileAppend, % HashResult, %DigestFile%
            }

            If (DebugNow = 0) {
                FileDelete, %TempBatchFile%
            }

            If (DebugNow = 0) {
                FileDelete, %TempDigestFile%
            }
            
            return HashResult
        }
        Else If (TargetType = "file")
        {
            FileAppend, @ECHO OFF`r`n, %TempBatchFile%
            FileAppend, %exe% -W "%TempDigestFile%" "%DigestTarget%", %TempBatchFile%
            RunWait, %TempBatchFile%, , Hide

            FileRead, HashResult, %TempDigestFile%

            Loop, Parse, HashResult, %A_Space%
            {
                HashResult := A_LoopField
                break
            }

            If (DebugNow = 0) {
                FileDelete, %TempBatchFile%
            }

            If (DebugNow = 0) {
                FileDelete, %TempDigestFile%
            }

            return HashResult
        }
    }
    Else If (Mode = "compare")
    {
        If (TargetType = "folder") {            
            FileRead, HashData, %DigestFile%
            HashData := CygPath(HashData)
            FileAppend, %HashData%, %TempDigestFile%

            FileAppend, @ECHO OFF`r`n, %TempBatchFile%
            FileAppend, %exe% -M "%TempDigestFile%" -rn "%DigestTarget%" > "%TempDigestFile2%", %TempBatchFile%
            RunWait, %TempBatchFile%, , Hide

            FileRead, HashResult, %TempDigestFile2%
            HashResult := WinPath(HashResult,TargetPath)
            FileDelete, %TempDigestFile2%

            If (DebugNow = 1) {
                FileAppend, % HashResult, %TempDigestFile2%
            }

            If (DebugNow = 0) {
                FileDelete, %TempBatchFile%
            }

            If (DebugNow = 0) {
                FileDelete, %TempDigestFile%
            }
            
            return HashResult
        }
        Else If (TargetType = "file") {
            FileAppend, @ECHO OFF`r`n, %TempBatchFile%
            FileAppend, %exe% -W "%TempDigestFile%" "%DigestTarget%", %TempBatchFile%
            RunWait, %TempBatchFile%, , Hide

            FileRead, HashResult, %TempDigestFile%

            Loop, Parse, HashResult, %A_Space%
            {
                HashResult := A_LoopField
                break
            }
            
            FileCompare := False
            If (HashResult = DigestFile) {
                FileCompare := True 
            }
            
            If (DebugNow = 0) {
                FileDelete, %TempBatchFile%
            }

            If (DebugNow = 0) {
                FileDelete, %TempDigestFile%
            }
            
            return FileCompare
        }
    } Else {
        MsgBox Invalid hash mode specified.
    }
}

; internal function for conversion of paths to cygwin format
CygPath(InPath) {
    return "/cygdrive/" . StrReplace(StrReplace(InPath,"\","/"),":","")
}

; internal function for conversion of paths from cygwin to windows format
WinPath(InPath,TargetPath:="") {
    If (TargetPath <> "") {
        SplitPath, TargetPath, , , , , Drv
        Drv := StrReplace(Drv,":","")
        result := StrReplace(InPath,"/cygdrive/" . Drv . "/",Drv . ":\")
    }

    result := StrReplace(result,"/","\")
    
    return result
}

; Posted by Laslo on Autohotkey Formus
; https://autohotkey.com/board/topic/16409-md5/
;
; sData can be a string or file data.
;
; File Data:
; - FileGetSize, OutVar, Filename
; - FileRead, OutVar, FileName

; sData = string or file data
; SID = 3 - MD5 / 4 - SHA
; State = Load / Unload

; Hash(ByRef sData, SID = 3, State:="",handle:="") { ; SID = 3: MD5, 4: SHA1
    ; If (State = "Load") {
        ; hModule := DllCall("LoadLibrary","Str","advapi32.dll","Ptr")
        ; return hModule
    ; }
    ; Else If (State = "Unload")
    ; {
        ; DllCall("FreeLibrary","Ptr",handle)
        ; MsgBox % "Unload Error: " . ErrorLevel
    ; } Else {
        ; nLen := VarSetCapacity(sData)
        ; DllCall("advapi32\CryptAcquireContextA", UIntP,hProv, UInt,0, UInt,0, UInt,1, UInt,0xF0000000)
        ; DllCall("advapi32\CryptCreateHash", UInt,hProv, UInt,0x8000|0|SID, UInt,0, UInt,0, UIntP, hHash)

        ; DllCall("advapi32\CryptHashData", UInt,hHash, UInt,&sData, UInt,nLen, UInt,0)

        ; DllCall("advapi32\CryptGetHashParam", UInt,hHash, UInt,2, UInt,0, UIntP,nSize, UInt,0)
        ; VarSetCapacity(HashVal, nSize, 0)
        ; DllCall("advapi32\CryptGetHashParam", UInt,hHash, UInt,2, UInt,&HashVal, UIntP,nSize, UInt,0)

        ; DllCall("advapi32\CryptDestroyHash", UInt,hHash)
        ; DllCall("advapi32\CryptReleaseContext", UInt,hProv, UInt,0)

        ; IFormat := A_FormatInteger
        ; SetFormat Integer, H
        ; Loop %nSize%
          ; sHash .= SubStr(*(&HashVal+A_Index-1)+0x100,-1)
        ; SetFormat Integer, %IFormat%
        ; Return sHash
    ; }
; }