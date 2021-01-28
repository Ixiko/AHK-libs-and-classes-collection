/*
#NoEnv
#Persistent
SetBatchLines, -1

Run, firefox,,, PID
timer := Func("SetChildProcessesPriority").Bind([PID], "H")
SetTimer, % timer, 5000
Return

SetChildProcessesPriority(PidArray, priority) {
   static changed := []
   for k, PID in PidArray {
      if !changed.HasKey(PID) {
         Process, Priority, % PID, % priority
         changed[PID] := ""
      }
      if (arr := EnumerateChilds(PID))
         SetChildProcessesPriority(arr, priority)
   }
}
*/

EnumerateChilds(PID) {
   static MAX_PATH := 260
   childs := []
   hSnap := DllCall("CreateToolhelp32Snapshot", UInt, TH32CS_SNAPPROCESS := 2, UInt, 0, Ptr)
   VarSetCapacity(PROCESSENTRY32, sz := 4*7 + A_PtrSize*2 + MAX_PATH << !!A_IsUnicode, 0)
   NumPut(sz, PROCESSENTRY32, "UInt")
   DllCall("Process32First", Ptr, hSnap, Ptr, &PROCESSENTRY32)
   Loop {
      parentPID := NumGet(PROCESSENTRY32, 4*4 + A_PtrSize*2, "UInt")
      if (parentPID = PID)
         childs.Push( NumGet(PROCESSENTRY32, 4*2, "UInt") )
   } until !DllCall("Process32Next", Ptr, hSnap, Ptr, &PROCESSENTRY32)
   DllCall("CloseHandle", Ptr, hSnap)
   Return childs[1] ? childs : ""
}