;   Title:   Remote Buffer
;         *Read and write process memory*
;

/*-------------------------------------------------------------------------------
   Function: Open
           Open remote buffer

   Parameters:
         H      - Reference to variable to receive remote buffer handle
         hwnd    - HWND of the window that belongs to the process
         size    - Size of the buffer

   Returns:
         Error message on failure
 */
RemoteBuf_Open(ByRef H, hwnd, size) {
   static MEM_COMMIT:=0x1000, PAGE_READWRITE:=4

   WinGet, pid, PID, ahk_id %hwnd%
   hProc   := DllCall( "OpenProcess", "uint", 0x38, "int", 0, "uint", pid) ;0x38 = PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE
   IfEqual, hProc,0, return A_ThisFunc ">   Unable to open process (" A_LastError ")"
      
   bufAdr  := DllCall( "VirtualAllocEx", "PTR", hProc, "PTR", 0, "PTR", size, "uint", MEM_COMMIT, "uint", PAGE_READWRITE)
   IfEqual, bufAdr,0, return A_ThisFunc ">   Unable to allocate memory (" A_LastError ")"

   ; Buffer handle structure:
    ;   @0: hProc
    ;   @4: size
    ;   @8: bufAdr
   VarSetCapacity(H, A_PtrSize*3, 0 )
   NumPut( hProc,   H, 0,"PTR") 
   NumPut( size,   H, A_PtrSize,"PTR")
   NumPut( bufAdr, H, A_PtrSize*2,"PTR")
}

/*----------------------------------------------------
   Function: Close
           Close the remote buffer

   Parameters:
           H - Remote buffer handle
 */
RemoteBuf_Close(ByRef H) {
   static MEM_RELEASE := 0x8000
   
   handle := NumGet(H, 0,"PTR")
   IfEqual, handle, 0, return A_ThisFunc ">   Invalid remote buffer handle"
   adr    := NumGet(H, A_PtrSize*2,"PTR")

   r := DllCall( "VirtualFreeEx", "PTR", handle, "PTR", adr, "PTR", 0, "uint", MEM_RELEASE)
   ifEqual, r, 0, return A_ThisFunc ">   Unable to free memory (" A_LastError ")"
   DllCall( "CloseHandle", "PTR", handle )
   VarSetCapacity(H, 0 )
}

/*----------------------------------------------------
   Function:   Read 
            Read from the remote buffer into local buffer

   Parameters: 
         H         - Remote buffer handle
         pLocal      - Reference to the local buffer
         pSize      - Size of the local buffer
         pOffset   - Optional reading offset, by default 0

Returns:
         TRUE on success or FALSE on failure. ErrorMessage on bad remote buffer handle
 */
RemoteBuf_Read(ByRef H, ByRef pLocal, pSize, pOffset := 0){
   handle := NumGet( H, 0,"PTR"),   size:= NumGet( H, A_PtrSize,"PTR"),   adr := NumGet( H, A_PtrSize*2,"PTR")
   IfEqual, handle, 0, return A_ThisFunc ">   Invalid remote buffer handle"   
   IfGreaterOrEqual, offset, %size%, return A_ThisFunc ">   Offset is bigger then size"

   VarSetCapacity( pLocal, pSize )
   return DllCall( "ReadProcessMemory", "PTR", handle, "PTR", adr + pOffset, "PTR", &pLocal, "PTR", size, "PTR", 0 ), VarSetCapacity(pLocal, -1)
}

/*----------------------------------------------------
   Function:   Write 
            Write local buffer into remote buffer

   Parameters: 
         H         - Remote buffer handle
         pLocal      - Reference to the local buffer
         pSize      - Size of the local buffer
         pOffset   - Optional writting offset, by default 0

   Returns:
         TRUE on success or FALSE on failure. ErrorMessage on bad remote buffer handle
 */

RemoteBuf_Write(Byref H, byref pLocal, pSize, pOffset:=0) {
   handle:= NumGet( H, 0,"PTR"),   size := NumGet( H, A_PtrSize,"PTR"),   adr := NumGet( H, A_PtrSize*2,"PTR")
   IfEqual, handle, 0, return A_ThisFunc ">   Invalid remote buffer handle"   
   IfGreaterOrEqual, offset, %size%, return A_ThisFunc ">   Offset is bigger then size"

   return DllCall( "WriteProcessMemory", "PTR", handle,"PTR", adr + pOffset,"PTR", &pLocal,"PTR", pSize, "PTR", 0 )
}

/*----------------------------------------------------
   Function:   Get
            Get address or size of the remote buffer

   Parameters: 
         H      - Remote buffer handle
         pQ     - Query parameter: set to "adr" to get address (default), to "size" to get the size or to "handle" to get Windows API handle of the remote buffer.

   Returns:
         Address or size of the remote buffer
 */
RemoteBuf_Get(ByRef H, pQ:="adr") {
   return pQ = "adr" ? NumGet(H, A_PtrSize*2,"PTR") : pQ = "size" ? NumGet(H, A_PtrSize,"PTR") : NumGet(H,"PTR")
}

/*---------------------------------------------------------------------------------------
Group: Example
(start code)
   ;get the handle of the Explorer window
      WinGet, hw, ID, ahk_class ExploreWClass

   ;open two buffers
      RemoteBuf_Open( hBuf1, hw, 128 )       
      RemoteBuf_Open( hBuf2, hw, 16  ) 

   ;write something
      str := "1234" 
      RemoteBuf_Write( hBuf1, str, strlen(str) ) 

      str := "_5678" 
      RemoteBuf_Write( hBuf1, str, strlen(str), 4) 

      str := "_testing" 
      RemoteBuf_Write( hBuf2, str, strlen(str)) 


   ;read 
      RemoteBuf_Read( hBuf1, str, 10 ) 
      out = %str% 
      RemoteBuf_Read( hBuf2, str, 10 ) 
      out = %out%%str% 

      MsgBox %out% 

   ;close 
      RemoteBuf_Close( hBuf1 ) 
      RemoteBuf_Close( hBuf2 ) 
(end code)
 */

/*-------------------------------------------------------------------------------------------------------------------
   Group: About
   o Ver 2.0 by majkinetor. See http://www.autohotkey.com/forum/topic12251.html
   o Code updates by infogulch
   o Licenced under Creative Commons Attribution-Noncommercial <http://creativecommons.org/licenses/by-nc/3.0/>.  
 */