/*	File path function group (Path.ahk)
    
   Use API in DllCall (correspond to \ dame characters)
   (It should not cause garbled characters newly in this function unless there is a problem with the higher-level argument)
   Global variable: none
   Dependence of each function: None (Only required functions can be cut out and used in Copy)

    AHKL Ver: 1.1.08.01
    Language: English translated from Japanease
    Platform: WinNT IE 4 or higher (using SHLWAPI.DLL)
    Author: eamat. 2008.01.30

 2008.12.10
 Fixed comment 2009.01.24
 2009.06.20 Function name modification PathIs_Relative () → Path_IsRelative ()
 2009.07.26 Parameter modification Path_Canonicalize ()
 2009.10.22 SplitPath () addition (Compatible with AHK original SplitPath command)
 2012.08.20 UTF-8 preserved provisional
 2012.11.08 Unicode compatible DllCall end A deletion (A, W automatic discrimination)
             msvcrt.dll \ _mbscpy obsolete UInt & → Str
             MAX_PATH 260 → 520

_PathAutoExecuteSample:
    ; Command line test
    ; Please drag some file to this file (path.ahk) and start it.
    if (! _ PathCommandLineCheck ()) {

        ; Function return value check sample (It is noticeable)
        _PathTest ()
    }
return

*/

; ================================================= ============================
; Determination system (existence check)
; ================================================= ============================
; --- check for existence of file Return value 0: none 1: yes ---
; 1 is also returned when a directory is specified. It is OK even UNC pass (\\% A_ComputerName% \ hoge.txt etc)
Path_FileExists (path) {
    Return DllCall ("SHLWAPI.DLL \ PathFileExists", Str, path, Int)
}

; --- Check if directory exists Return value 0: None Other than 0: Yes ---
; UNC path (\\% A_ComputerName% \ etc.) is OK
; The trailing \ may or may not have a pattern
Path_IsDirectory (path) {
    Return DllCall ("SHLWAPI.DLL \ PathIsDirectory", Str, path, Int)
}

; ---- whether it exists UNC (network) path 0: None 1: yes ---
Path_IsUNCServerShare (path) {
    Return DllCall ("SHLWAPI.DLL \ PathIsUNCServerShare", Str, path, Int)
}
/ *
 ; Why does not it work out
; --- Whether the existing folder has system folder attribute ---
Path_IsSystemFolder (path = "", Attr = 0) {
 ; Return DllCall ("SHLWAPI.DLL \ PathIsSystemFolder", Str, path, UInt, Attr, Int)
}
 * /

; ================================================= ============================
; Judgment system (character string description rule check)
; ※ It is not a judgment whether it is a path that does not actually exist
; ================================================= ============================
; ------------------------------------------------------------------- ----------
; Whether the character string is only a file name specification (whether delimiters such as ":" or "\" are included)
; Return value 0: ":" or "\" Present 1: File name only
; ------------------------------------------------------------------- ----------
Path_IsFileSpec (path) {
    Return DllCall ("SHLWAPI.DLL \ PathIsFileSpec", Str, path, Int)
}

; ------------------------------------------------------------------- -----------------
; Determine whether the beginning of the specified path begins with the character string specified by Prefix
; prefix: "C: \\" or "." or ".." or ".. \\"
; Return value 0: No 1: Yes
; ------------------------------------------------------------------- -----------------
Path_IsPrefix (prefix, path) {
    Return DllCall ("SHLWAPI.DLL \ PathIsPrefix", Str, prefix, Str, path, Int)
}

; ----- Determine if the string is relative path or absolute path 0: Absolute 1: Relative ---
Path_IsRelative (path) {
    Return DllCall ("SHLWAPI.DLL \ PathIsRelative", Str, path, Int)
}

; ----- Judge whether the string is the root 0: invalid 1: valid ---
Path_IsRoot (path) {
    Return DllCall ("SHLWAPI.DLL \ PathIsRoot", Str, path, Int)
}

; ----- Judge whether two path strings have the same root element 0: invalid 1: valid ---
Path_IsSameRoot (path1, path2) {
    Return DllCall ("SHLWAPI.DLL \ PathIsSameRoot", Str, path 1, Str, path 2, Int)
}
; --- Can the string be interpreted as a URL 0: Can not 1: Can - -
Path_IsURL (url) {
    Return DllCall ("SHLWAPI.DLL \ PathIsURL", Str, url, Int)
}

; ========= Network Path ===========
; --- Whether the string is UNC (network path) 0: Invalid 1: Enabled ---
; Only judgment of description format, there is no judgment as to whether path is not actually present
Path_IsUNC (path) {
    Return DllCall ("SHLWAPI.DLL \ PathIsUNC", Str, path, Int)
}

; --- Whether the string is UNC (network path) with server path only 0: invalid 1: enabled ---
; ex) \\ hoge: 1
; \\: 1
; \ \ hoge \: 0
Path_IsUNCServer (path) {
    Return DllCall ("SHLWAPI.DLL \ PathIsUNCServer", Str, path, Int)
}

; ------------------------------------------------------------------- -----------------------
; Does the specified file name match the file specification using wildcards?
; filename: file name
; spec: file spec (such as * .txt or a? c.exe)
; Return value 0: No match 1: to
; ------------------------------------------------------------------- -----------------------
Path_MatchSpec (filename, spec) {
    return DllCall ("SHLWAPI.DLL \ PathMatchSpec", Str, filename, Str, spec, Int)
}

; ------------------------------------------------------------------- -----------------------
; Determine how you can use it when using the character c as a path.
; c: character to be determined (char)
;
; Return value: Bit mask value of judgment result, combination of the following flags
;
; GCT_INVALID 0x00 characters are not valid on the path
; GCT_LFNCHAR 0x01 character is valid for long file name
; GCT_SEPARATOR 0x08 character is the path separator
; GCT_SHORTCHAR 0x02 characters are valid for short file name (8.3)
; GCT_WILD 0x04 character is a wildcard character (*?)
; ------------------------------------------------------------------- -----------------------
Path_GetCharType (c) {
    return DllCall ("SHLWAPI.DLL \ PathGetCharType", Char, Asc (c), Uint)
}

; ================================================= ============================
; Conversion system
; ================================================= ============================
; --- Return long file name (※ Win 95 not supported) ---
Path_GetLongPathName (filePath) {
    VarSetCapacity (dstPath, 260 * 2)
    DllCall ("GetLongPathName", str, filePath, str, dstPath, Uint, 260 * 2)
    return dstPath
}

; --- Return 8.3 format file name (※ Win 95 not supported) ---
Path_GetShortPathName (filePath) {
    VarSetCapacity (dstPath, 260 * 2)
    DllCall ("GetShortPathName", str, filePath, str, dstPath, Uint, 260 * 2)
    return dstPath
}

; ---- Generate full path (current Dir is appended) ----
Path_SearchAndQualify (file) {
    VarSetCapacity (t, 260 * 2, 0); ↓ Hangs unless it is specified as half of the secured value
    DllCall ("SHLWAPI.DLL \ PathSearchAndQualify", Str, file, str, t, UInt, 260)
    return t
}

/ * Why does not it work out
; --- convert all letters to lowercase letters to unify the format of the path (deletion root character)
Path_MakePretty (path) {
    DllCall ("SHLWAPI.DLL \ PathMakePretty", Str, path)
    return path
}
* /

; - - Append a backslash to the end of the path name -----
Path_AddBackslash (path) {
    DllCall ("SHLWAPI.DLL \ PathAddBackslash", Str, path)
    return path
}
; --- Delete trailing backslash of pathname ---
Path_RemoveBackslash (path) {
    DllCall ("SHLWAPI.DLL \ PathRemoveBackslash", Str, path)
    return path
}

; --- Remove the first and last space from the string (Trim?) ---
Path_RemoveBlanks (path) {
    DllCall ("SHLWAPI.DLL \ PathRemoveBlanks", Str, path)
    return path
}

; ---- Include with "" when the path name contains spaces ---
Path_QuoteSpaces (path) {
    DllCall ("SHLWAPI.DLL \ PathQuoteSpaces", Str, path)
    return path
}
; ---- Remove the mark from the path name enclosed in "-" ---
Path_UnquoteSpaces (path) {
    DllCall ("SHLWAPI.DLL \ PathUnquoteSpaces", Str, path)
    return path
}

; ------------------------------------------------------------------- ----------
; Obtain a path name with only the extension changed from the full path name
; path Target path
; ext Extensions to change
; ------------------------------------------------------------------- ----------
Path_RenameExtension (path, ext) {
    ext: = ("."! = SubStr (ext, 1, 1))? "." ext: ext; ".
    DllCall ("SHLWAPI.DLL \ PathRenameExtension", Str, path, Str, ext)
    Return path
}

; ================================================= ============================
; Extraction system
; ================================================= ============================
; ---- Get route information from path name -----
; ex) c: \ hoge.txt -> c: \
Path_StripToRoot (path) {
    DllCall ("SHLWAPI.DLL \ PathStripToRoot", Str, path)
    return path
}

; ---- Get the drive number from the path name (drive a: → 0 when error: -1) -----
Path_GetDriveNumber (path) {
    Return DllCall ("SHLWAPI.DLL \ PathGetDriveNumber", Str, path, Int)
}

; ---- Retrieve only the file name from the full path name -----
Path_FindFileName (path) {
    Return DllCall ("SHLWAPI.DLL \ PathFindFileName", Str, path, Str)
}

; - - Deletes the path part from the specified file name -----
; (Path_FindFileName () and the same result?)
Path_StripPath (path) {
    DllCall ("SHLWAPI.DLL \ PathStripPath", Str, path)
    return path
}

; ------------------------------------------------------------------- -------------
; Retrieve directory from full path name
; * Delete \ and the file name after it from the path
; \ Nothing Please note that specifying DIR will destroy the last folder!
; ex c: \ foo \ bar \ hoge.txt -> c: \ foo \ bat
; c: \ foo \ bar \ -> c: \ foo \ bar
; c: \ foo \ bar -> c: \ foo
; ------------------------------------------------------------------- -------------
Path_RemoveFileSpec (path) {
    DllCall ("SHLWAPI.DLL \ PathRemoveFileSpec", Str, path)
    return path
}

; ---- Exclude share name part from path ---
Path_SkipRoot (path) {
   return DllCall ("SHLWAPI.DLL \ PathSkipRoot", Str, path, Str)
}

; ---- Retrieve only the extension from the full path name ------
Path_FindExtension (path) {
    Return DllCall ("SHLWAPI.DLL \ PathFindExtension", Str, path, Str)
}

; ---- Get the path name without the extension from the full path name ----
Path_RemoveExtension (path) {
    DllCall ("SHLWAPI.DLL \ PathRemoveExtension", Str, path)
    return path
}

; ----- Extract command line arguments from the command statement specified by Path ---
Path_GetArgs (path) {
    return DllCall ("SHLWAPI.DLL \ PathGetArgs", Str, path, str)
}

; --- Delete the argument part from the command sentence specified by Path ---
Path_RemoveArgs (path) {
    DllCall ("SHLWAPI.DLL \ PathRemoveArgs", Str, path)
    return path
}

; ------------------------------------------------------------------- ----------
; Shrink the file path string to the specified length
; path Target path
; ext How many characters to shrink
; ------------------------------------------------------------------- ----------
Path_CompactPathEx (Path, Max) {
    ; * It is garbled if there are double-byte characters → if it is U version it's okay 2012.11.06
    VarSetCapacity (t, 260 * 2, 0)
    DllCall ("SHLWAPI.DLL \ PathCompactPathEx", Str, t, Str, path, UInt, max, Uint, "\")
    Return t
}

; ------------------------------------------------------------------- ----------
; Get common directory name from the beginning of two path names
; p1 p2 Comparison target path
; ------------------------------------------------------------------- ----------
Path_CommonPrefix (p1, p2) {
    VarSetCapacity (t, 260 * 2, 0)
    DllCall ("SHLWAPI.DLL \ PathCommonPrefix", Str, p1, Str, p2, str, t)
    Return t
}

/ *; Value can not be obtained. Abandon
Path_FIndOnPath (file, paths) {
    a: = DllCall ("SHLWAPI.DLL \ PathFIndOnPath", Str, file, str, paths, Int)
    return file
}
* /

; ================================================= ============================
Relative path related
; ================================================= ============================
; ------------------------------------------------------------------- -----
; Create Relative Path
; From: Base path
; To: Relative path
; atr: specify file attribute
; Directory 0x10 (FILE_ATTRIBUTE_DIRECTORY)
; File 0x20 (FILE_ATTRIBUTE_ARCHIVE)
; ------------------------------------------------------------------- -----
Path_RelativePathTo (From, atrFrom, To, atrTo) {
    VarSetCapacity (t, 260 * 2, 0)

    DllCall ("SHLWAPI.DLL \ PathRelativePathTo", Str, t
            , str, From, Uint, atrFrom
            , str, To, Uint, atrTo)
    return t
}

; ------------------------------------------------------------------- -----------
; Join file path character string (expansion of .. \ etc is also OK)
; Even if there is no \ at the end, it is automatically added.
;
; path Target path
; more Connection path
; ------------------------------------------------------------------- -----------
Path_Combine (path, more) {
    VarSetCapacity (t, 260 * 2, 0)
    DllCall ("SHLWAPI.DLL \ PathCombine", Str, t, str, path, str, more)
    return t
}

; Expand ---- .. \ (to absolute path) ----
Path_Canonicalize (path) {
    VarSetCapacity (t, 260 * 2, 0)
    DllCall ("SHLWAPI.DLL \ PathCanonicalize", Str, t, str, path)
    return t
}

; ================================================= ============================
; AHK command compatibility function
; ================================================= ============================

; --- compatible SplitPath compatible characters ---
Path_SplitPath (path, byref OutFileName = "", byref OutDir = "", byref OutExtension = "", byref OutNameNoExt = "", byref OutDrive = "") {

    ; Leave the URL handling to the original family
    If (Instr (path, ": //")) {
        SplitPath, path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        return
    }

    ; File name excluding folder path
    ; If it is only a folder path, it will be empty
    OutFileName: = DllCall ("SHLWAPI.DLL \ PathFindFileName", Str, path, Str)
    If (RegExMatch (OutFileName, "(?: ^ | [^ \ X80 - \ x9F \ xE0 - \ xFC]) \\"))
        OutFileName: = ""

    ; Folder path (not including the last "\")
    ; If it is only a file name, it is empty.
    VarSetCapacity (OutDir, 260, 0)
    DllCall ("msvcrt.dll \ _mbscpy", UInt, & OutDir, Str, path)
    DllCall ("SHLWAPI.DLL \ PathRemoveFileSpec", Str, OutDir)
    OutDir: = RegExReplace (OutDir, "(? <= [^ \ X80 - \ x9F \ xE0 - \ xFC]) \ \ $")

    ; Extension of file (not including ".")
    OutExtension: = RegExReplace (DllCall ("SHLWAPI.DLL \ PathFindExtension"
                                         , Str, path, Str), "^ \.")

    ; Store the name part without the extension
    OutNameNoExt: = RegExReplace (OutFileName, "\ .. * $")


    ; Store the drive letter (with ":") and the machine name of the path on the network
    OutDrive: = SubStr (path, 2, 1) = ":"? SubStr (path, 1, 2)
            : SubStr (path, 1,2) = "\\"? RegExReplace (path
                                 , "(? <= [^ \ x80 - \ x9F \ xE0 - \ xFC]) \ \. * $", "", "", - 1, 3)
            : ""
}

; ;;;;;;;;;;;; ; ;;;;;;;;;;;;
;
; Internal routine for checking operation
; Since it is only called from AutoExecute at standalone startup, there is no problem even if you delete it

_PathCommandLineCheck () {
    global
    local filename
    filename =% 1%
    if (filename) {
        msgbox, command line argument `n% 1%` n`n * When passing a file with D & D, AHK seems to be the 8.3 `formula file path
        return 1
    }
}

_PathTest () {
    a: = A _ScriptFullPath

    r1: = Path_FileExists (a)
    r2: = Path_FileExists (A_ScriptDir)
    msgbox, 1, file existence check, Path_FileExists (path) `n`n% a% =% r1%` n% A_ScriptDir% =% r2%
    If MsgBox, Cancel, return

    r1: = Path_IsDirectory (a)
    r2: = Path_IsDirectory (A_ScriptDir)
    r3: = Path_IsDirectory ("c: \ hoge")
    msgbox, 1, directory existence check, Path_IsDirectory (path) `n`n% a% =% r1%` n% A_ScriptDir% =% r2% `nc: \ hoge =% r3%
    If MsgBox, Cancel, return

    r1: = Path_IsUNCServerShare ("\\ foo \ bar \ hoge.txt"); Invalid path
    p: = "\\" A_ComputerName "\ share folder"; ← ※ put a valid path
    r2: = Path_IsUNCServerShare (p)
    r3: = Path_IsUNCServerShare (A_ScriptFullPath)
    msgbox, 1, network path existence check, Path_IsUNCServerShare (path) `n`n \\ foo \ bar \ hoge.txt =% r1%` n% p% =% r2% `n% A_ScriptFullPath% =% r3%
    If MsgBox, Cancel, return

    r1: = Path_IsFileSpec (a)
    r2: = Path_IsFileSpec (A_ScriptName)
    msgbox, 1, file specification check (valid only for file name), Path_IsFileSpec (path) `n`n% a% =% r1%` n% A_ScriptName% =% r2%
    If MsgBox, Cancel, return

    r1: = Path_IsPrefix (".. \", a)
    r2: = Path_IsPrefix (".. \", ".. \ System32 \ readme.txt")
    msgbox, 1, determine the first character of the path, Path_IsPrefix (prefix, path) `n` nprefix: .. \ `ntarget:% a%` n ->% r1% `n` nprefix: .. \ ntarget: .. \ System32 \ readme.txt` n ->% r 2%
    If MsgBox, Cancel, return

    r1: = Path_IsRelative (a)
    r2: = Path_IsRelative (".. \ System32 \ readme.txt")
    msgbox, 1, path relative, Path_IsRelative (path) `n` n% a% =% r1% `n .. \ System32 \ readme.txt =% r 2%
    If MsgBox, Cancel, return

    
    r1: = Path_IsRoot (A_ScriptDir)
    r2: = Path_IsRoot ("Q: \")
    r3: = Path_IsRoot ("\\ hoge \")
    msgbox, 1, root directory, Path_IsRoot (path) `n` n% A_ScriptDir% =% r1% `n \ \ hoge \ =% r3%
    If MsgBox, Cancel, return

    r1: = Path_IsSameRoot (a, A_AhkPath)
    r2: = Path_IsSameRoot (A_WinDir, A_ScriptDir)
    msgbox, Path_IsSameRoot (path1, path2) `n` n1:% a%` n2:% A_AhkPath% `n ->% r1%` n` n1:% A_WinDir% ` n2:% A_ScriptDir% `n ->% r 2%
    If MsgBox, Cancel, return

    r1: = Path_IsURL ("http: // hoge /")
    r2: = Path_IsURL ("\\ foo \ bar \ hoge.txt")
    msgbox, 1, string is URL or Path_IsURL (url) `n` nhttp: // hoge / =% r1% `n \\ foo \ bar \ hoge.txt =% r 2%
    If MsgBox, Cancel, return

    r1: = Path_IsUNC (a)
    r2: = Path_IsUNC ("\\ foo \ bar \ hoge.txt")
    msgbox, 1, path is network path or Path_IsUNC (path) `n` n% a% =% r1% `n \\ foo \ bar \ hoge.txt =% r 2%
    If MsgBox, Cancel, return

    r1: = Path_IsUNCServer ("\\ foo")
    r2: = Path_IsUNCServer ("\\ foo \")
    r3: = Path_IsUNCServer ("\\")
    msgbox, 1, path is network root or Path_IsUNCServer (path) `n` n \\ foo =% r1% `n \\ foo \ =% r2%` n \\ =% r3%
    If MsgBox, Cancel, return

    r1: = Path_MatchSpec (a, "*. exe")
    r2: = Path_MatchSpec (a, "*. ahk")
    msgbox, 1, file Match check, Path_MatchSpec (filename, spec) `n` n% a% `n * .exe =% r1% * .ahk =% r2%
    If MsgBox, Cancel, return

    r1: = Path_GetCharType ("/")
    r2: = Path_GetCharType (",")
    r3: = Path_GetCharType ("a")
    r4: = Path_GetCharType ("\")
    r5: = Path_GetCharType ("*")
    msgbox, 1, pass character type determination, Path_GetCharType (c) `n` n / =% r 1% `n, =% r 2%` na =% r 3% `n \ =% r 4%` n * =% r 5%
    If MsgBox, Cancel, return

    r1: = Path_GetLongPathName (a); Long pass
    r2: = Path_GetShortPathName (r1); 8.3 format
    msgbox, 1, long / short file, Path_GetLongPathName (filePath) `nPath_GetShortPathName (filePath)` n` norg =% a% `nLongFile =% r1%` nShortFile =% r2%
    If MsgBox, Cancel, return

    r1: = Path_SearchAndQualify ("hoge.txt")
    r2: = Path_SearchAndQualify (".. \ hage.txt")
    msgbox, 1, complement the path and add it to the absolute path, Path_SearchAndQualify (file) `n`nhoge.txt` n->% r1%` n` nhage.txt` n->% r 2%
    If MsgBox, Cancel, return
    
; r1: = Path_MakePretty ("C: \ HOGE \ HOGE.txt")
; Make msgbox path lowercase `n C: \ HOGE \ HOGE.txt` n ->% r1%

    r1: = Path_AddBackslash (A_WinDir)
    r2: = Path_AddBackslash (A_WinDir. "\")
    msgbox, 1, backslash addition, Path_AddBackslash (path) `n`n% A_WinDir% =% r1%` n% A_WinDir% \ =% r 2%
    If MsgBox, Cancel, return

    r1: = Path_RemoveBackslash (A_WinDir)
    r2: = Path_RemoveBackslash (A_WinDir. "\")
    msgbox, 1, backslash delete, Path_RemoveBackslash (path) `n` n% A_WinDir% =% r1% `n% A_WinDir% \ =% r 2%
    If MsgBox, Cancel, return

    r1: = "". A_WinDir. ""
    r2: = Path_RemoveBlanks (r1)
    msgbox, 1, space deleted, Path_RemoveBlanks (path) `n` n [% r 1%] `n [% r 2%]
    If MsgBox, Cancel, return

    r1: = Path_QuoteSpaces (A_WinDir)
    r2: = Path_QuoteSpaces (A_ProgramFiles)
    msgbox, 1, appended to path containing spaces, Path_QuoteSpaces (path) `n` n% r 1% `n% r 2%
    If MsgBox, Cancel, return

    r3: = Path_UnquoteSpaces (r1. "\ hoge.exe")
    r4: = Path_UnquoteSpaces (r 2)
    r5: = Path_UnquoteSpaces (r2. "\ hoge.exe")
    msgbox, 1, "Removed, Path_UnquoteSpaces (path)` n `n% r1% \ hoge.exe =% r3%` n% r2% =% r4% `n% r2% \ hoge.exe =% r5%
    If MsgBox, Cancel, return

    b: = Path_RenameExtension (a, ". old"); Change the extension
    msgbox, 1, extension change, Path_RenameExtension (path, ext) `n`n% a%` n% b%
    If MsgBox, Cancel, return

    r1: = Path_GetDriveNumber (a)
    r2: = Path_FindFileName (a)
    r3: = Path_FindExtension (a)
    r4: = Path_RemoveExtension (a)
    r5: = Path_RemoveFileSpec (a)
    `nPath_FindExtension (path)` nPath_RemoveExtension (path) `nPath_RemoveFileSpec (path)` n`n% a% `n`n drive number =% r1%` `nPath_FindFileName (path) n Dir elimination =% r 2% `n extension =% r 3%` n extension removal =% r 4% `n file name removal =% r 5%
    If MsgBox, Cancel, return


    r1: = Path_StripToRoot (A_ScriptDir)
    msgbox, 1, get route information, Path_StripToRoot (path) `n`n% A_ScriptDir%` n ->% r1%
    If MsgBox, Cancel, return

    r1: = Path_RemoveFileSpec (A_ScriptDir)
    msgbox, 1, remove file name, Path_RemoveFileSpec (path) `n`n% A_ScriptDir%` n ->% r1%
    If MsgBox, Cancel, return

    r1: = Path_StripPath (a)
    msgbox, 1, remove path part from file name, Path_StripPath (path) `n`n% a%` n ->% r1%
    If MsgBox, Cancel, return

    r1 = \\ foo \ bar \ hoge.txt
    r2: = Path_SkipRoot (a)
    r3: = Path_SkipRoot (r1)
    msgbox, 1, remove the share name part from the path, Path_SkipRoot (path) `n` n% a% `n->% r 2%` n` n% r 1% `n->% r 3%
    If MsgBox, Cancel, return

    c =% A_AhkPath% / hoge "% A_ScriptDir%"
    r1: = Path_GetArgs (c)
    msgbox, 1, command line extraction, Path_GetArgs (path) `n`n% c%` n ->% r1%
    If MsgBox, Cancel, return

    r1: = Path_RemoveArgs (c)
    msgbox, 1, delete parameter, Path_RemoveArgs (path) `n`n% c%` n ->% r1%
    If MsgBox, Cancel, return

    r1: = Path_CommonPrefix (a, A_AhkPath)
    msgbox, 1, common Dir extraction, Path_CommonPrefix (p1, p2) `n` n1:% a%` n2:% A_AhkPath% `n ->% r1%
    If MsgBox, Cancel, return

    r2: = Path_Combine (r1, A_AhkPath)
    r3: = Path_Combine (A_ScriptDir, A_ScriptName)
    r4: = Path_Combine (A_ScriptDir, ". \ .. \ hoge.exe")
    msgbox, 1, path concatenation, Path_Combine (path, more) `n`n`n1:% r1%` n2:% A_AhkPath% `n ->% r2%` n` n1:% A_ScriptDir% `n2:% A_ScriptName % `n ->% r3%` n` n1:% A_ScriptDir% `n2:. \ .. \ hoge.exe`n ->% r4%
    If MsgBox, Cancel, return

    r1: = Path_RelativePathTo (A_ScriptFullPath, 0x20, A_AhkPath, 0x20)
    msgbox, 1, relative path creation, Path_RelativePathTo (From, atrFrom, To, atrTo) `n` n1:% A_ScriptFullPath%` n2:% A_AhkPath% `n ->% r1%
    If MsgBox, Cancel, return

    r1 =% A_ScriptDir% \ .. \ .. \ hoge.txt
    r2: = Path_Canonicalize (r1)
    msgbox, 1, to absolute path, Path_Canonicalize (path) `n` n% r 1%` n ->% r 2%
    If MsgBox, Cancel, return
}


