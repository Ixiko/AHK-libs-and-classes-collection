#NoEnv

; Note: See https://stackoverflow.com/a/42986966/12364306 to understand the difference between WorkingSetPrivateSize
; and the value shown in Task Manager under the "Memory (active private working set)" column in the Details tab.

PID := DllCall("GetCurrentProcessId")
Loop {
   SizeInKB := GetWorkingSetPrivateSize(PID) // 1024
   ToolTip, % PID ": " SizeInKB " KB"
   Sleep, 250
}
Esc::ExitApp

GetWorkingSetPrivateSize(PID) {
   static SYSTEM_INFORMATION_CLASS := 0x5
   if (DllCall("Ntdll\NtQuerySystemInformation", "UInt", SYSTEM_INFORMATION_CLASS, "Ptr", 0, "UInt", 0, "UInt*", Size, "Int") != 0) {
      VarSetCapacity(SYSTEM_PROCESS_INFORMATION, Size), Offset := 0
      if (DllCall("Ntdll\NtQuerySystemInformation", "UInt", SYSTEM_INFORMATION_CLASS, "Ptr", &SYSTEM_PROCESS_INFORMATION, "UInt", Size, "UInt*", 0, "Int") = 0) {
         Loop {
            WorkingSetPrivateSize := NumGet(SYSTEM_PROCESS_INFORMATION, Offset + 8, "Int64")
            UniqueProcessId := NumGet(SYSTEM_PROCESS_INFORMATION, Offset + 56 + 3 * A_PtrSize, "Ptr")
            if (UniqueProcessId = PID)
               return WorkingSetPrivateSize
            NextEntryOffset := NumGet(SYSTEM_PROCESS_INFORMATION, Offset, "UInt")
            Offset += NextEntryOffset
         } Until !NextEntryOffset
      }
   }
}