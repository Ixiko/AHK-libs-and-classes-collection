; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=70639
; Author:	teadrinker
; Date:   	2019-12-11
; for:     	AHK_L

/*

   procName := "vlc.exe"
   Process, Exist, % procName
   if !(PID := ErrorLevel) {
      MsgBox, Process not found
      ExitApp
   }

   MsgBox, % Clipboard := GetOpenedFiles(PID)

*/

GetOpenedFiles(PID) {

; SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX
; https://www.geoffchappell.com/studies/windows/km/ntoskrnl/api/ex/sysinfo/handle_ex.htm
; https://www.geoffchappell.com/studies/windows/km/ntoskrnl/api/ex/sysinfo/handle_table_entry_ex.htm
   static PROCESS_DUP_HANDLE := 0x0040, SystemExtendedHandleInformation := 0x40, DUPLICATE_SAME_ACCESS := 0x2
        , FILE_TYPE_DISK := 1, structSize := A_PtrSize*3 + 16 ; size of SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX
   hProcess := DllCall("OpenProcess", "UInt", PROCESS_DUP_HANDLE, "UInt", 0, "UInt", PID)
   arr := {}
   res := size := 1
   while res != 0 {
      VarSetCapacity(buff, size, 0)
      res := DllCall("ntdll\NtQuerySystemInformation", "Int", SystemExtendedHandleInformation, "Ptr", &buff, "UInt", size, "UIntP", size, "UInt")
   }
   NumberOfHandles := NumGet(buff)
   VarSetCapacity(filePath, 1026)
   Loop % NumberOfHandles {
      ProcessId := NumGet(buff, A_PtrSize*2 + structSize*(A_Index - 1) + A_PtrSize, "UInt")
      if (PID = ProcessId) {
         HandleValue := NumGet(buff, A_PtrSize*2 + structSize*(A_Index - 1) + A_PtrSize*2)
         DllCall("DuplicateHandle", "Ptr", hProcess, "Ptr", HandleValue, "Ptr", DllCall("GetCurrentProcess")
                                  , "PtrP", lpTargetHandle, "UInt", 0, "UInt", 0, "UInt", DUPLICATE_SAME_ACCESS)
         if DllCall("GetFileType", "Ptr", lpTargetHandle) = FILE_TYPE_DISK
            && DllCall("GetFinalPathNameByHandle", "Ptr", lpTargetHandle, "Str", filePath, "UInt", 512, "UInt", 0)
               arr[ RegExReplace(filePath, "^\\\\\?\\") ] := ""
         DllCall("CloseHandle", "Ptr", lpTargetHandle)
      }
   }
   DllCall("CloseHandle", "Ptr", hProcess)
   for k in arr
      str .= (str = "" ? "" : "`n") . k
   Return str
}