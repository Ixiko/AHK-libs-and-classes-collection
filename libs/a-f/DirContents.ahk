;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.

DirContents(dir, mask := "*.*", attribFilter := 0) { ; attribFilter = 0x10 to only return directories; -0x10 to return everything but directories
    local ; Force-local mode
    ; for non-recursive listing, use "" for mask
    ; beware! byref params are empty in recursive calls
    VarSetCapacity(vFINDDATA, A_IsUnicode ? 592 : 520, 0)
    ;sizeof(WIN32_FIND_DATA) = 592 (Unicode) / 520 (ASCII)

    ;typedef struct _WIN32_FIND_DATA {
    ;  DWORD    dwFileAttributes;	//	4
    ;  FILETIME ftCreationTime;	//	8
    ;  FILETIME ftLastAccessTime;	//	8
    ;  FILETIME ftLastWriteTime;	//	8
    ;  DWORD    nFileSizeHigh;	//	4
    ;  DWORD    nFileSizeLow;	//	4
    ;  DWORD    dwReserved0;	//	4
    ;  DWORD    dwReserved1;	//	4
    ;  TCHAR    cFileName[MAX_PATH];	//	MAX_PATH*(A_IsUnicode+1)
    ;  TCHAR    cAlternateFileName[14];	//	14*(A_IsUnicode+1)
    ;} WIN32_FIND_DATA, *PWIN32_FIND_DATA, *LPWIN32_FIND_DATA;

    ;MAX_PATH=260

    ;#ifdef _UNICODE
    ;typedef wchar_t TCHAR;
    ;#else
    ;typedef char TCHAR;
    ;#endif
    ;https://habrahabr.ru/post/164193/

    ;Contains a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC).
    ;typedef struct _FILETIME {
    ;  DWORD dwLowDateTime;
    ;  DWORD dwHighDateTime;
    ;} FILETIME, *PFILETIME;
    
    ;dwFileAttributes:
    ; https://msdn.microsoft.com/ru-ru/library/windows/desktop/gg258117.aspx
    ;attReadOnly	:= vAttrib & 0x1
    ;attHidden	        := vAttrib & 0x2
    ;attSystem  	:= vAttrib & 0x4
    ;attDirectory	:= vAttrib & 0x10
    ;attArchive	        := vAttrib & 0x20
    ;attNormal	        := vAttrib & 0x80
    ;attTemporary	:= vAttrib & 0x100
    ;attSparse	        := vAttrib & 0x200
    ;attReparsePoint    := vAttrib & 0x400 ; A file or directory that has an associated reparse point, or a file that is a symbolic link
    ;attCompressed	:= vAttrib & 0x800
    ;attUnindexed	:= vAttrib & 0x2000
    ;attEncrypted	:= vAttrib & 0x4000
    
    If (!(SubStr(dir, 1, 2) == "\\")) {
        If ((SubStr(dir, 1, 1) == "\")) {
            ;SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
            SplitPath A_WorkingDir, , , , , OutDrive
            dir := "\\?\" OutDrive ":" dir
        } Else If (!(SubStr(dir, 2, 1) == ":"))
            dir := "\\?\" A_WorkingDir "\" dir
        Else
            dir := "\\?\" dir
    }
    
    If (mask && SubStr(dir, 0) != "\")
        dir .= "\"
    
    hFile := DllCall("Kernel32.dll\FindFirstFile", "str", dir . mask, "ptr", &vFINDDATA)
    if (hFile = -1) {
        If (!mask) ; if recursing, it's fine when one of dirs does not contain files
            return ; Exception(A_LastError, "Kernel32.dll\FindFirstFile", dir . mask)
    } Else {
        out := []
        Loop
        {
            fname := StrGet(&vFINDDATA+44)
            if fname not in .,..
            {
                vAttrib := NumGet(&vFINDDATA)
                If (attribFilter == 0 || (attribFilter > 0 && vAttrib & attribFilter) || (attribFilter < 0 && !(vAttrib & -attribFilter)))
                    out[fname] := {vAttrib: vAttrib}
            }
        } Until !DllCall("Kernel32.dll\FindNextFile", "ptr", hFile, "ptr", &vFINDDATA)
        DllCall("Kernel32.dll\FindClose", "ptr", hFile)
    }
    If (mask) {
        If (!IsObject(out))
            out := [], outEmpty := 1
        For subdirName in DirContents(dir "*.*" , "", 0x10) {
            contents := DirContents(dir . subdirName "\", mask, attribFilter)
            If (IsObject(contents)) {
                If (!out.HasKey(subdirName))
                    out[subdirName] := {}
                out[subdirName].contents := contents
                outEmpty := 0
            }
        }
        If (outEmpty)
            out := ""
    }
    return out
}
