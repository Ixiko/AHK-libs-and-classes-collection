/*
http://www.autohotkey.com/board/topic/71791-solved-readprocessmemory-offsets-from-cheat-engine/


SetFormat IntegerFast, H
Base:=  GetImageBase(Path) ; Replace A_AhkPath with path of executable.
SetFormat IntegerFast, D

BaseOffset := 0x00E966B8
offset0 := 0x56C
offset1 := 0x5C0
offset2 := 0x12


loop, %win_count%
{
		pid := pid%A_Index%
		Pointer := ReadMemory(Base, BaseOffset, pid)
		PointerResult1 := ReadMemory(Pointer, offset0, pid)
		PointerResult2 := ReadMemory(PointerResult1, offset1, pid)
		Name := ReadMemory_Str(PointerResult2, offset2, pid)
		msgtext .= "Character Name" A_Index ": " Name "`n"
}

msgbox, %msgtext%

*/
GetDllBase(DllName, PID = 0)
{
    if PID = 0
	{
		error:= "The specified process could not be found."
		return error
	}
    
    TH32CS_SNAPMODULE := 0x00000008
    INVALID_HANDLE_VALUE = -1
    VarSetCapacity(me32, 548, 0)
    NumPut(548, me32)
    snapMod := DllCall("CreateToolhelp32Snapshot", "Uint", TH32CS_SNAPMODULE
                                                 , "Uint", PID)
    If (snapMod = INVALID_HANDLE_VALUE) {
        Return 0
    }
    If (DllCall("Module32First", "Uint", snapMod, "Uint", &me32)){
        while(DllCall("Module32Next", "Uint", snapMod, "UInt", &me32)) {
            If !DllCall("lstrcmpi", "Str", DllName, "UInt", &me32 + 32) {
                DllCall("CloseHandle", "UInt", snapMod)
                Return NumGet(&me32 + 20)
            }
        }
    }
    DllCall("CloseHandle", "Uint", snapMod)
    Return 0
}
GetImageBase(filename)
{
    static IMAGE_DOS_SIGNATURE := 0x5A4D
    static IMAGE_NT_SIGNATURE := 0x4550
    static IMAGE_SIZEOF_FILE_HEADER := 20
    static MAGIC_PE32 := 0x10B
    static MAGIC_PE32PLUS := 0x20B

    file := FileOpen(filename, "r")
    if !file
        return
    
    if (file.ReadUShort() != IMAGE_DOS_SIGNATURE)
    || !file.Seek(60) ; Seek to e_lfanew.
    || !file.Seek(file.ReadInt()) ; Seek to NT header.
    || (file.ReadUInt() != IMAGE_NT_SIGNATURE)
        return
    
    file.Seek(IMAGE_SIZEOF_FILE_HEADER, 1) ; Seek to optional header.
    
    magic := file.ReadUShort()
    if (magic = MAGIC_PE32)
    {
        file.Seek(26, 1)
        return file.ReadUInt()
    }
    else if (magic = MAGIC_PE32PLUS) ; x64
    {
        file.Seek(22, 1)
        return file.ReadInt64()
    }
}
;//function ReadMemory
ReadMemory(MADDRESS, pOffset = 0, PID = "") 
{ 
			if (PID == ""){
				Process, wait, ffxivgame.exe 0.5
				PID = %ErrorLevel%
				if PID = 0
				{
					MsgBox The specified process could not be found.
					return
				}
			}
			
			VarSetCapacity(MVALUE,4) 
			ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
			
			
			;int pAddress = 0x002D1120; 
			; ReadProcessMemory(pHandle,(LPVOID)pAddress,&pAddress,4,NULL); 
			;  pAddress += 0x14;
			  
			DllCall("ReadProcessMemory", "UInt", ProcessHandle, "Ptr", MADDRESS+pOffset, "Ptr", &MVALUE, "Uint",4, "Uint",0)
			DllCall("CloseHandle", "int", ProcessHandle)
			Loop 4 
				result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)
				
			return result
}


;//function ReadMemory_Str 
ReadMemory_Str(MADDRESS, pOffset = 0, PID = "") 
{ 
			if (PID == ""){
				Process, wait, ffxivgame.exe 0.5
				PID = %ErrorLevel%
				if PID = 0
				{
					MsgBox The specified process could not be found.
					return
				}
			}
			
			ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "Uint")
			teststr =
			Loop
			{
			   Output := "x"  ; Put exactly one character in as a placeholder. used to break loop on null
			   tempVar := DllCall("ReadProcessMemory", "UInt", ProcessHandle, "UInt", MADDRESS+pOffset, "str", Output, "Uint", 1, "Uint *", 0)
			   if (ErrorLevel or !tempVar)
			   {
				  DllCall("CloseHandle", "int", ProcessHandle)
				  return teststr
			   }
			   if Output =
				  break
			
			   teststr = %teststr%%Output%
			   MADDRESS++
			}
			DllCall("CloseHandle", "int", ProcessHandle)
			return, teststr  
}