; Title:   	How can I set the default printer?
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=12735
; Author:	jNIzM
; Date:   	06. April 2017
; for:     	AHK_L

/*


    ; GLOBAL SETTINGS ===============================================================================================================

    #NoEnv
    #SingleInstance Force
    #NoTrayIcon              ; <- remove trayicon so user dont notice this script in background

    SetBatchLines, -1

    ; SCRIPT ========================================================================================================================

    sleep 20000              ; <- since the script is in startup wait 20 seconds and give pc time to start


    if (A_UserName ~= "i)usera|userb|userc")           ; Check username (User A / User B / User C)
        DefaultPrinter.Set("\\10.1.1.20\PRINTER_1")    ; -> Set Printer 1

    if (A_UserName ~= "i)userd|usere")                 ; Check username (User D / User E)
        DefaultPrinter.Set("\\10.1.1.20\PRINTER_2")    ; -> Set Printer 2

    ; EXIT ==========================================================================================================================

    ExitApp

*/


; CLASSES =======================================================================================================================

Class DefaultPrinter{

    static init := DefaultPrinter.ClassInit()
    static quit := OnExit(ObjBindMethod(DefaultPrinter, "_Delete"))

    ClassInit()    {
        if !(this.hWINSPOOL := DllCall("LoadLibrary", "str", "winspool.drv", "ptr"))
            return false
        return true
    }

    Set(printer)    {
        if !(DllCall("winspool.drv\SetDefaultPrinter", "ptr", &printer))
            return false
        return true
    }

    Get()    {
        if !(DllCall("winspool.drv\GetDefaultPrinter", "ptr", 0, "uint*", size)) {
            size := VarSetCapacity(buf, size << 1, 0)
            if !(DllCall("winspool.drv\GetDefaultPrinter", "str", buf, "uint*", size))
                return false
        }
        return buf
    }

    _Delete()    {
        if !(DllCall("FreeLibrary", "ptr", this.hWINSPOOL))
            return false
        return true
    }
}