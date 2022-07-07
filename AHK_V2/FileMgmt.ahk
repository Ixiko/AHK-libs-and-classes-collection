#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#INCLUDE C:\Users\UserData\DEV\AHK\00_INCLUDE\MyLibraries\TheArkyTekt_Tokens.ahk
#INCLUDE C:\Users\UserData\DEV\AHK\00_INCLUDE\MyLibraries\TheArkyTekt_Hash.ahk

SrcDir := "C:\Users\Jeb6\AppData\Roaming\foobar2000"
DestDir := "D:\_BACKUP_\BackupScriptDest"

qt2(InStr) {
    return Chr(34) . InStr . Chr(34)
}

nl2() {
    return Chr(13) . Chr(10)
}

xsync(SrcDir,DestDir,True)

xsync(SrcDir,DestDir,CleanDir:=False) {
    DebugNow := 0
    DebugList := "HashMismatchList"
    Bytes := 0
    SrcFolderStruct := ""
    DestFolderStruct := ""
    FileCopyList := ""
    TempDigest := A_WorkingDir . "\TempDigest.txt"
    ; make src folder heirarchy list first
    Loop, Files, %SrcDir%\*, DR
    {
        If (SrcFolderStruct = "") {
            SrcFolderStruct := A_LoopFileFullPath
        } Else {
            SrcFolderStruct .= Chr(13) . Chr(10) . A_LoopFileFullPath
        }
    }
    
    If (CleanDir = True) {
        ; list folders in dest
        Loop, Files, %DestDir%\*, DR
        {
            If (DestFolderStruct = "") {
                DestFolderStruct := A_LoopFileFullPath
            } Else {
                DestFolderStruct .= Chr(13) . Chr(10) . A_LoopFileFullPath
            }
        }
        
        ; MsgBox DestFolderStruct: %DestFolderStruct%
        
        ; delete dest folders not in src list
        Loop, Parse, DestFolderStruct, `r, `n
        {
            CurDestFolder := StrReplace(A_LoopField,DestDir,"")
            m := False
            
            ; look for match in src folder list
            Loop, Parse, SrcFolderStruct, `r, `n
            {
                CurSrcFolder := StrReplace(A_LoopField,SrcDir,"")
                ; MsgBox % "Dest: " . qt2(CurDestFolder) . nl2() . "Src: " . qt2(CurSrcFolder)
                
                If (CurSrcFolder = CurDestFolder) {
                    m := True
                    ; MsgBox MATCH
                    break
                }
            }
            
            ; MsgBox % "m: " . m . nl2() . "Fldr: " . CurDestFolder
            ; remove if match found
            If (m = False And CurDestFolder <> "") {
                FileRemoveDir, %A_LoopField%, 1
            }
        }
    }
    
    ; create folder heirarchy in dest
    Loop, Parse, SrcFolderStruct, `r, `n
    {
        If (A_LoopField <> "") {
            DestItem := StrReplace(A_LoopField,SrcDir,DestDir)
            FileCreateDir, %DestItem%
        }
    }
    
    ; create / compare hashes
    
    ; hash Src folder (to temp file - relative paths)
    ; compare to test folder > output var
    ; parse output var
    ; copy each file parsed (substitution needed)
    ; done
    
    
}