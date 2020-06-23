; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=61497&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; ===============================================================================================================================
; GetDesktopIconUnderMouse()
; Function:       Gets the desktop icon under the mouse. See the "Return values" section below for more information about the
;                 icon and associated file data retrieved.
; Parameters:     None
; Return values:  If there is an icon under the mouse, an associative array with the following keys:
;                 - left: the left position of the icon in screen coordinates
;                 - top: the top position of the icon in screen coordinates
;                 - right: the right position of the icon in screen coordinates
;                 - bottom: the bottom position of the icon in screen coordinates
;                 - name: the name of the file represented by the icon, e.g. New Text Document.txt
;                 - size: the size of the file represented by the icon, e.g. 1.72 KB. Note: this value is blank for folders
;                 - type: the type of the file represented by the icon, e.g. TXT File, JPEG image, File folder
;                 - date: the modified date of the file represented by the icon, e.g. 9/9/2016 10:39 AM
;                 Otherwise, a blank value
; Global vars:    None
; Dependencies:   None
; Tested with:    AHK 1.1.30.01 (A32/U32/U64)
; Tested on:      Win 7 (x64)
; Written by:     iPhilip
; ===============================================================================================================================

GetDesktopIconUnderMouse() {
   static MEM_COMMIT := 0x1000, MEM_RELEASE := 0x8000, PAGE_READWRITE := 0x04
        , PROCESS_VM_OPERATION := 0x0008, PROCESS_VM_READ := 0x0010
        , LVM_GETITEMCOUNT := 0x1004, LVM_GETITEMRECT := 0x100E
   
   Icon := ""
   MouseGetPos, x, y, hwnd
   if not (hwnd = WinExist("ahk_class Progman") || hwnd = WinExist("ahk_class WorkerW"))
      Return
   ControlGet, hwnd, HWND, , SysListView321
   if not WinExist("ahk_id" hwnd)
      Return
   WinGet, pid, PID
   if (hProcess := DllCall("OpenProcess" , "UInt", PROCESS_VM_OPERATION|PROCESS_VM_READ, "Int",  false, "UInt", pid)) {
      VarSetCapacity(iCoord, 16)
      SendMessage, %LVM_GETITEMCOUNT%, 0, 0
      Loop, %ErrorLevel% {
         pItemCoord := DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "UInt", 16, "UInt", MEM_COMMIT, "UInt", PAGE_READWRITE)
         SendMessage, %LVM_GETITEMRECT%, % A_Index-1, %pItemCoord%
         DllCall("ReadProcessMemory", "Ptr", hProcess, "Ptr", pItemCoord, "Ptr", &iCoord, "UInt", 16, "UInt", 0)
         DllCall("VirtualFreeEx", "Ptr", hProcess, "Ptr", pItemCoord, "UInt", 0, "UInt", MEM_RELEASE)
         left   := NumGet(iCoord,  0, "Int")
         top    := NumGet(iCoord,  4, "Int")
         right  := NumGet(iCoord,  8, "Int")
         bottom := NumGet(iCoord, 12, "Int")
         if (left < x and x < right and top < y and y < bottom) {
            ControlGet, list, List
            RegExMatch(StrSplit(list, "`n")[A_Index], "O)(.*)\t(.*)\t(.*)\t(.*)", Match)
            Icon := {left:left, top:top, right:right, bottom:bottom
                   , name:Match[1], size:Match[2], type:Match[3]
                     ; Delete extraneous date characters (https://goo.gl/pMw6AM):
                     ; - Unicode LTR (Left-to-Right) mark (0x200E = 8206)
                     ; - Unicode RTL (Right-to-Left) mark (0x200F = 8207)
                   , date:RegExReplace(Match[4], A_IsUnicode ? "[\x{200E}-\x{200F}]" : "\?")}
            Break
         }
      }
      DllCall("CloseHandle", "Ptr", hProcess)
   }
   Return Icon
}