; ----------------------------------------------------------------------------------------------------------------------
; Name .........: Zip library
; Description ..: Implements basic zip features using Windows built-in zip support.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Unicode
; Author .......: shajul (http://goo.gl/t3rtix) - Cyruz (http://ciroprincipe.info)
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Mar. 03, 2014 - v0.1 - First version.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Zip_Add
; Description ..: Creates a zip archive with the provided files.
; Parameters ...: sZip   - Path to the zip file to be created.
; ..............: sFiles - Path to the folder or file to be added to the zip (files can be passed as wildcard: *.*).
; Return .......: 1 on success, 0 on error.
; ----------------------------------------------------------------------------------------------------------------------
Zip_Add(sZip, sFiles) {
    If ( !FileExist(sZip) ) { ; Create an empty file zip.
        HEADER1 := "PK" . Chr(5) . Chr(6), VarSetCapacity(HEADER2, 18, 0)
        If ( !IsObject(oFile := FileOpen(sZip, "w")) )
            Return 0
        oFile.Write(HEADER1)
        oFile.RawWrite(HEADER2, 18)
        oFile.close()
    }
    objShell := ComObjCreate("Shell.Application")
    objZip   := objShell.Namespace(sZip)
    If ( InStr(FileExist(sFiles), "D") )
        sFiles .= (SubStr(sFiles, 0) == "\") ? "*.*" : "\*.*"
    Loop, %sFiles%, 1
    {
        nZipped := objZip.Items().Count + 1
        objZip.CopyHere(A_LoopFileLongPath, 16)
        Loop
        {   ; This loop is required to check if the file has been zipped.
            Sleep, 50
            If ( nZipped == objZip.Items().Count )
                Break
        }
    }
    Return 1
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: Zip_Extract
; Description ..: Extract the zip archive to the specified folder.
; Parameters ...: sZip - Path to the zip file to be extracted.
; ..............: sDir - Path to the directory where the archive will be extracted.
; Return .......: 1 on success, 0 on error.
; ----------------------------------------------------------------------------------------------------------------------
Zip_Extract(sZip, sDir) {
    If ( !InStr(FileExist(sDir), "D") ) {
        FileCreateDir, %sDir%
        If ( ErrorLevel )
            Return 0
    }
    objShell := ComObjCreate("Shell.Application")
    nZipped  := objShell.Namespace(sZip).Items().Count
    objShell.Namespace(sDir).CopyHere(objShell.Namespace(sZip).Items, 16)
    Loop
    {   ; This loop is required to check if the zip content has been extracted.
        Sleep, 50
        nUnzipped := objShell.Namespace(sDir).Items().Count
        If ( nUnzipped == nZipped )
            Break
    }
    Return 1
}
