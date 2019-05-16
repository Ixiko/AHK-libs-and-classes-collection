/*
; ------------ Examples of usage ------------

PID = 1120          ; Process Id.
Address = 0xD0077C  ; Address to write to.
n = 123
d = 1.999
s = Hello, world!

WriteMemory(PID, Address, n, "Int")    ; Write an integer.
WriteMemory(PID, Address, d, "Double") ; Write a double.
WriteMemory(PID, Address, s)   ; Write a whole string
                                ; whith the null terminator.
WriteMemory(PID, Address, s, 5)    ; Write the first 5 characters only
                                    ; (without a null terminator).
VarSetCapacity(Buf, 8)
NumPut(123, Buf, 0, "Int")
NumPut(456, Buf, 4, "Int")

WriteMemory(PID, Address, &Buf, 8) ; Write 8 bytes from a buffer.
***note the msg box in functions - remove one day
*/
; ------------ Function -----------------------

;***user length name eg int instead of 4!!!

; function will return True if successful 0 if not.
; But when call WriteMemory() to close handle 
; will return either "Handle Closed:" closed  OR "Fail" 
; call WriteMemory() on exit to close handle
WriteMemory(WriteAddress = "", PROGRAM="", Data="", TypeOrLength = "")
{
  
   Static OLDPROC, hProcess, pid

   If (PROGRAM != OLDPROC)
   {
        if hProcess
          closed := DllCall("CloseHandle", "UInt", hProcess), hProcess := 0, OLDPROC := ""
        if PROGRAM
        {
            WinGet, pid, pid, % OLDPROC := PROGRAM
            if !pid 
               return "Process Doesn't Exist", OLDPROC := "" ;blank OLDPROC so subsequent calls will work if process does exist
            hProcess := DllCall("OpenProcess", "Int", 0x8 | 0x20, "Int", 0, "UInt", pid)   
        }
   }

    If Data is Number   ; Either a numeric value or a memory address.
    {
        If TypeOrLength is Integer  ; Address of a buffer was passed.
        {
            DataAddress := Data
            DataSize := TypeOrLength    ; Length in bytes of the data in the buffer.
        }
        Else    ; A numeric value was passed.
        {
            If (TypeOrLength = "Double" or TypeOrLength = "Int64")
                DataSize = 8
            Else If (TypeOrLength = "Int" or TypeOrLength = "UInt"
                                          or TypeOrLength = "Float")
                DataSize = 4
            Else If (TypeOrLength = "Short" or TypeOrLength = "UShort")
                DataSize = 2
            Else If (TypeOrLength = "Char" or TypeOrLength = "UChar")
				        DataSize = 1
            Else {
              ;  MsgBox, Invalid type of number.
                Return False 
            }
            VarSetCapacity(Buf, DataSize, 0)
            NumPut(Data, Buf, 0, TypeOrLength)
            DataAddress := &Buf
        }
    }
    Else    ; Data is a string.
    {
        DataAddress := &Data
        If TypeOrLength is Integer  ; Length (in characters) was specified.
        {
            If A_IsUnicode
                DataSize := TypeOrLength * 2    ; 1 character = 2 bytes.
            Else
                DataSize := TypeOrLength
        }
        Else
        {
            If A_IsUnicode
                DataSize := (StrLen(Data) + 1) * 2  ; Take the whole string
            Else                                    ; with the null terminator.
                DataSize := StrLen(Data) + 1
        }
    }                                               
    ; will return null if write works
    if (hProcess && DllCall("WriteProcessMemory", "UInt", hProcess 
                                         , "UInt", WriteAddress
                                         , "UInt", DataAddress
                                         , "UInt", DataSize
                                         , "UInt", 0))
        return                               
    else  return !hProcess ? "Handle Closed:" closed : "Fail"
}