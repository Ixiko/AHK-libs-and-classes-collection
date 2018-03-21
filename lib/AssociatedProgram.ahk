;-- Function: AssociatedProgram
;-- Description: Returns the full path of the program (if any) associated to
;   a file extension (p_FileExt).
;-- Original author: TheGood
;       http://www.autohotkey.com/forum/viewtopic.php?p=363558#363558
;-- Modified by: Eruyome
;-- Programming note: AssocQueryStringA is never called because it returns
;   invalid results on Windows XP.
AssociatedProgram(p_FileExt) {
    program := ""
    ext     := p_FileExt
    Static ASSOCSTR_EXECUTABLE:=2

    ;-- Workaround for AutoHotkey Basic
    PtrType:=A_PtrSize ? "Ptr":"UInt"

    ;-- File extension
    if SubStr(p_FileExt,1,1)<>"."
        p_FileExt:="." . p_FileExt  ;-- Prepend dot

    ;-- If needed, convert file extension to Unicode
    l_FileExtW:=p_FileExt
    if not A_IsUnicode
        {
        nSize:=StrLen(p_FileExt)+1          ;-- Size in chars including terminating null
        VarSetCapacity(l_FileExtW,nSize*2)  ;-- Size in bytes
        DllCall("MultiByteToWideChar","UInt",0,"UInt",0,PtrType,&p_FileExt,"Int",-1,PtrType,&l_FileExtW,"Int",nSize)
        }

    ;-- Get the full path to the program
    VarSetCapacity(l_EXENameW,65536,0)      ;-- Size allows for 32K characters
    DllCall("shlwapi.dll\AssocQueryStringW"
        ,"UInt",0                           ;-- ASSOCF flags
        ,"UInt",ASSOCSTR_EXECUTABLE         ;-- ASSOCSTR flags
        ,PtrType,&l_FileExtW                ;-- pszAssoc (file extension used)
        ,PtrType,0                          ;-- pszExtra (not used)
        ,PtrType,&l_EXENameW                ;-- pszOut (output string)
        ,PtrType . "*",65536)               ;-- pcchOut (len of the output string)

    ;-- If needed, convert result back to ANSI
    if A_IsUnicode
        program := l_EXENameW
     else {
        nSize:=DllCall("WideCharToMultiByte","UInt",0,"UInt",0,PtrType,&l_EXENameW,"Int",-1,PtrType,0,"Int",0,PtrType,0,PtrType,0)
            ;-- Returns the number of bytes including the terminating null

        VarSetCapacity(l_EXEName,nSize)
        DllCall("WideCharToMultiByte","UInt",0,"UInt",0,PtrType,&l_EXENameW,"Int",-1,PtrType,&l_EXEName,"Int",nSize,PtrType,0,PtrType,0)
        program := l_EXEName
    }
    
    app1 := AssocQueryApp(ext)
    app2 := DefaultProgramUserChoice(ext)
    app := (app2 and app1 != app2) ? app2 : app1
    program := (program != app) ? app : program

    Return program
}

AssocQueryApp(ext) {
    RegRead, type, HKCR, .%ext%
    RegRead, act , HKCR, %type%\shell
    If ErrorLevel
        act = open
    RegRead, cmd , HKCR, %type%\shell\%act%\command
    app := Trim(RegExReplace(cmd, """(.*?)"".*","$1"))
    Return, app
}

DefaultProgramUserChoice(ext) {
	; Find the Registry key name for the default browser
    Try {
        RegRead, AppKeyName, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%ext%\UserChoice, Progid

        ; Find the executable command associated with the above Registry key
        RegRead, AppFullCommand, HKEY_CLASSES_ROOT, %AppKeyName%\shell\open\command

        ; The above RegRead will return the path and executable name of the application contained within quotes and optional parameters
        ; We only want the text contained inside the first set of quotes which is the path and executable
        ; Find the ending quote position (we know the beginning quote is in position 0 so start searching at position 1)
        StringGetPos, pos, AppFullCommand, ",,1

        ; Decrement the found position by one to work correctly with the StringMid function
        pos := --pos

        ; Extract and return the path and executable of the browser
        StringMid, AppPathandEXE, AppFullCommand, 2, %pos%
    } Catch e {

    }
	Return AppPathandEXE
}