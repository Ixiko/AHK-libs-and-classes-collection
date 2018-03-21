;~ Process, Exist, notepad.exe
;~ If !PID := ErrorLevel
  ;~ Run notepad.exe,,,PID
;~ MsgBox % GetProcessWorkingDir(PID)
GetProcessWorkingDir(PID){
  static PROCESS_ALL_ACCESS:=0x1F0FFF,MEM_COMMIT := 0x1000,MEM_RELEASE:=0x8000,PAGE_EXECUTE_READWRITE:=64
        ,GetCurrentDirectoryW,init:=MCode(GetCurrentDirectoryW,"8BFF558BECFF75088B450803C050FF15A810807CD1E85DC20800")
  nDirLength := VarSetCapacity(nDir, 512, 0)
  hProcess := DllCall("OpenProcess", "UInt", PROCESS_ALL_ACCESS, "Int",0, "UInt", PID)
  if !hProcess 
    return
  pBufferRemote := DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "PTR", nDirLength + 1, "UInt", MEM_COMMIT, "UInt", PAGE_EXECUTE_READWRITE, "Ptr")

  pThreadRemote := DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "PTR", 26, "UInt", MEM_COMMIT, "UInt", PAGE_EXECUTE_READWRITE, "Ptr")
  DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", pThreadRemote, "Ptr", &GetCurrentDirectoryW, "PTR", 26, "Ptr", 0)

  If hThread := DllCall("CreateRemoteThread", "PTR", hProcess, "UInt", 0, "UInt", 0, "PTR", pThreadRemote, "PTR", pBufferRemote, "UInt", 0, "UInt", 0)
  {
    DllCall("WaitForSingleObject", "PTR", hThread, "UInt", 0xFFFFFFFF)
    DllCall("GetExitCodeThread", "PTR", hThread, "UIntP", lpExitCode)
    If lpExitCode {
      DllCall("ReadProcessMemory", "PTR", hProcess, "PTR", pBufferRemote, "Str", nDir, "UInt", lpExitCode*2, "UInt", 0)
      VarSetCapacity(nDir,-1)
    }
    DllCall("CloseHandle", "PTR", hThread)
  }
  DllCall("VirtualFreeEx","PTR",hProcess,"PTR",pBufferRemote,"PTR",nDirLength + 1,"UInt",MEM_RELEASE)
  DllCall("VirtualFreeEx","PTR",hProcess,"PTR",pThreadRemote,"PTR",31,"UInt",MEM_RELEASE)
  DllCall("CloseHandle", "PTR", hProcess)

  return nDir
}

