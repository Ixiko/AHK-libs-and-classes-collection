; ==================================================================================================================================
; Namespace:      RMO (Remote Memory Object)
; Function:       Functions to allocate and access memory within the address space of other processes.
; Tested with:    AHK 1.1.15.00 (A32/U32/U64)
; Tested on:      Win 8.1 (x64)
; Changelog:      1.0.00.00/2014-06-11/just me - initial release
; Remarks:        Adapted from Lexikos' ControlGetTabs() at www.autohotkey.com/board/topic/70727-ahk-l-controlgettabs/
;                 As lexikos pointed out, both processes should be running in the same 32/64-bit environment.
; ==================================================================================================================================
; Usage:       To allocate a block of remote memory call
;                    MyRemote := RMO_Create(Proc, Size)
;              whereas
;                    Proc  must contain the PID of the remote process (e.g. got from "WinGet, OutputVar, PID" or
;                          "Process, Exist, Name") or a HWND of a window or control created by the process,
;              and
;                    Size  must contain the requested buffer size in bytes.
;
;              On success, MyRemote will be an object containing the keys (!!!you must not change them!!!):
;                    HPROC -  Process handle.
;                    Addr  -  Address of the remote buffer.
;                    Size  -  Size of the remote buffer in bytes.
;              Otherwise, it will be set to False.
;
;              The following functions provide access to the remote buffer:
;                    RMO_Put  -  Stores the content of a local variable into the remote buffer.
;                    RMO_Get  -  Stores the content of the remote buffer into a local variable.
;                    RMO_Init -  Initializes the remote buffer's memory.
;              These functions are also accessible via the RMO object, e.g. MyRemote.Put/Get/Init(...).
;              In this case, you must omit the first parameter entirely (i.e. including the related comma),
;              because the object will be added internally.
;
;              All functions except RMO_Create() and RMO_IsProcess32Bit() expect a RMO object returned by
;              RMO_Create() as first parameter.
; ==================================================================================================================================
; Allocates the requested remote memory and creates a RMO object on success.
; Parameters:   Proc          -  PID of the remote process or HWND of a window/control created by the process.
;               Size          -  Requested size in bytes
;               CheckBitness  -  Check if both processes have the same bitness and abort if not (True/False).
;                                Default: True
;                                You should know what you are doing if you set this parameter to False. Otherwise one
;                                or both of the processes might crash.
; Return value: Object containing the address, the process handle, and the size of the remote buffer, if successful;
;               otherwise False.
; ==================================================================================================================================
RMO_Create(Proc, Size, CheckBitness := True) {
   ; PROCESS_QUERY_INFORMATION = 0x0400, PROCESS_VM_WRITE = 0x20, PROCESS_VM_READ = 0x10, PROCESS_VM_OPERATION = 0x8
   ; READ_WRITE_ACCESS = 0x0438, MEM_COMMIT = 0x1000, PAGE_READWRITE = 4
   Static Dummy := Func("RMO_Dummy")
   Static RMOBase := {__New: Dummy, __Delete: Func("RMO_Free"), __Get: Dummy, __Set: Dummy}
   ; If a window/control handle is passed, get the PID
   If DllCall("IsWindow", "Ptr", Proc, "UInt")
      DllCall("GetWindowThreadProcessId", "Ptr", Proc, "UIntP", Proc)
   ; Open the process for allocating/reading/writing memory.
   If !(HPROC := DllCall("OpenProcess", "UInt", 0x0438, "Int", False, "UInt", Proc, "Ptr"))
      Return False
   ; Check if both processes are running in the same 32/64-bit environment (THX, Lexikos)
   If (CheckBitness) && (A_Is64bitOS) {
      If !DllCall("IsWow64Process", "Ptr", HPROC, "UIntP", WOW64) || (WOW64 && (A_PtrSize = 8)) || (!WOW64 && (A_PtrSize = 4))
         Return (DllCall("CloseHandle", "Ptr", HPROC) & 0) ; False
   }
   ; Allocate a buffer in the (presumably) remote process.
   If !(Addr := DllCall("VirtualAllocEx", "Ptr", HPROC, "Ptr", 0, "UPtr", Size, "UInt", 0x1000, "UInt", 4, "UPtr"))
      Return False
   ; All right, return the RMO object
   Return {HPROC: HPROC, Addr: Addr, Size: Size, Get: Func("RMO_Get"), Init: Func("RMO_Init"), Put: Func("RMO_Put"), Base: RMOBase}
}
; ==================================================================================================================================
; Releases the remote memory and closes the remote process handle.
; This function will be called automatically when the remote memory object is to be destroyed.
; ==================================================================================================================================
RMO_Free(RMO) {
   ; MEM_RELEASE = 0x8000
   If (RMO.HPROC & RMO.Addr)
      DllCall("VirtualFreeEx", "Ptr", RMO.HPROC, "Ptr", RMO.Addr, "UPtr", 0, "UInt", 0x8000)
   If (RMO.HPROC)
      DllCall("CloseHandle", "Ptr", RMO.HPROC)
   RMO.HPROC := RMO.Addr := RMO.Size := 0
}
; ==================================================================================================================================
; Stores the content of a local variable into the remote memory block.
; Parameters:   LocalVar   -  Local variable
;               Offset     -  Offset within the remote memory block
;                             Default: 0
;               Size       -  Size of the local variable in bytes
;                             Default: 0 -> size of the local variable returned by VarSetCapacity()
; Return value: True, if successful; otherwise False.
; ==================================================================================================================================
RMO_Put(RMO, ByRef LocalVar, Offset := 0, Size := 0) {
   If RMO_CheckParams(RMO, Offset, Size = 0 ? (Size := VarSetCapacity(LocalVar)) : Size)
      Return DllCall("WriteProcessMemory", "Ptr", RMO.HPROC, "Ptr", RMO.Addr + Offset, "Ptr", &LocalVar, "UPtr", Size, "Ptr", 0)
   Return False
}
; ==================================================================================================================================
; Stores the content of the remote memory block into this local variable.
; Parameters:   LocalVar   -  Local variable
;               Offset     -  Offset within the remote memory block
;                             Default: 0
;               Size       -  Size of the local variable in bytes
;                             Default: 0 -> (RMO.Size - Offset)
; Return value: True, if successful; otherwise False.
; ==================================================================================================================================
RMO_Get(RMO, ByRef LocalVar, Offset := 0, Size := 0) {
   If RMO_CheckParams(RMO, Offset, Size = 0 ? (Size := RMO.Size - Offset) : Size) {
      VarSetCapacity(LocalVar, Size, 0)
      Return DllCall("ReadProcessMemory", "Ptr", RMO.HPROC, "Ptr", RMO.Addr + OffSet, "Ptr", &LocalVar, "UPtr", Size, "Ptr", 0)
   }
   Return False
}
; ==================================================================================================================================
; Initializes (parts of) the remote memory block.
; Parameters:   Offset     -  Offset within the remote memory block
;                             Default: 0
;               Size       -  Number of bytes to initialize.
;                             Default: 0 -> (RMO.Size - Offset)
;               FillByte   -  Byte to initialize with (0 = 0x0, 1 = 0x1, etc.)
;                             Default: 0
; Return value: True, if successful; otherwise False.
; ==================================================================================================================================
RMO_Init(RMO, Offset := 0, Size := 0, FillByte := 0) {
   If !RMO_CheckParams(RMO, Offset, Size = 0 ? (Size := RMO.Size - Offset) : Size)
      Return False
   VarSetCapacity(Init, Size, FillByte)
   Return RMO_Put(RMO, Init, Offset, Size)
}
; ==================================================================================================================================
; Determines whether the specified process is 32-bit.
; Parameters:   Proc -  PID of the remote process or HWND of a window/control created by the process.
; Return value: True, if the process is 32-bit; otherwise False.
;               On failure Errorlevel is set to True.
; ==================================================================================================================================
RMO_IsProcess32Bit(Proc) {
   If (A_Is64bitOS) {
      If DllCall("IsWindow", "Ptr", Proc, "UInt")
         DllCall("GetWindowThreadProcessId", "Ptr", Proc, "UIntP", Proc)
      If (HPROC := DllCall("OpenProcess", "UInt", 0x0400, "Int", 0, "UInt", Proc, "UPtr"))
      && DllCall("IsWow64Process", "Ptr", HPROC, "UIntP", WOW64, "UInt")
         Return WOW64
      Else
         Return !(ErrorLevel := True) ; False
   }
   Return True
}
; ==================================================================================================================================
; For internal use!!!
; ==================================================================================================================================
; Validates parameters.
RMO_CheckParams(RMO, Offset, Size) {
   If !(RMO.HPROC && RMO.Addr && RMO.Size)
      Return False
   If (Offset < 0) || (Offset >= RMO.Size)
      Return False
   If (Size + Offset) > RMO.Size
      Return False
   Return True
}
; ----------------------------------------------------------------------------------------------------------------------------------
; Do not call!!!
RMO_Dummy(P*) {
   Return ""
}