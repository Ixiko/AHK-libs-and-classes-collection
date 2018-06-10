;~ Process,Exist, notepad.exe
;~ If !PID:=ErrorLevel
;~ Run notepad.exe,,,PID
;~ rThread:=InjectAhkDll(PID,A_AhkDir "\AutoHotkeyMini.dll","#Persistent`nMsgBox % A_WorkingDir")
;~ Sleep 500
;~ rThread.Exec("MsgBox % A_AhkPath")

InjectAhkDll(PID,dll="AutoHotkey.dll",script=0){
  static PROCESS_ALL_ACCESS:=0x1F0FFF,MEM_COMMIT := 0x1000,MEM_RELEASE:=0x8000,PAGE_EXECUTE_READWRITE:=64
        ,hKernel32:=DllCall("LoadLibrary","Str","kernel32.dll","PTR"),LoadLibraryA:=DllCall("GetProcAddress","PTR",hKernel32,"AStr","LoadLibraryA","PTR")
        ,base:={__Call:"InjectAhkDll",__Delete:"InjectAhkDll"},FreeLibrary:=DllCall("GetProcAddress","PTR",hKernel32,"AStr","FreeLibrary","PTR")
  static TH32CS_SNAPMODULE:=0x00000008,INVALID_HANDLE_VALUE:=-1
        ,MAX_PATH:=260,MAX_MODULE_NAME32:=255,ModuleName:="",init:=VarSetCapacity(ModuleName,MAX_PATH*(A_IsUnicode?2:1))
        ,_MODULEENTRY32:="
        (
          DWORD   dwSize;
          DWORD   th32ModuleID;
          DWORD   th32ProcessID;
          DWORD   GlblcntUsage;
          DWORD   ProccntUsage;
          BYTE    *modBaseAddr;
          DWORD   modBaseSize;
          HMODULE hModule;
          TCHAR   szModule[" MAX_MODULE_NAME32 + 1 "];
          TCHAR   szExePath[" MAX_PATH "];
        )"
 
  If IsObject(PID){
    If (dll!="Exec" && script)
      return DllCall("MessageBox","PTR",0,"Str","Only Exec method can be used here!","STR","Error","UInt",0)
    
    hProc := DllCall("OpenProcess", "UInt", PROCESS_ALL_ACCESS, "Int",0, "UInt", PID.PID,"PTR")
    If !hProc
      return DllCall("MessageBox","PTR",0,"Str","Could not open process for PID: " PID.PID,"STR","Error","UInt",0)
    
    if (!script) ; Free Library in remote process (object is being deleted)
    {
      ; Terminate the thread in ahkdll
      hThread := DllCall("CreateRemoteThread", "PTR", hProc, "PTR", 0, "PTR", 0, "PTR", PID.ahkTerminate, "PTR", 0, "UInt", 0, "PTR", 0,"PTR")
      DllCall("WaitForSingleObject", "PTR", hThread, "UInt", 0xFFFFFFFF)
      ,DllCall("CloseHandle", "PTR", hThread)
      
      ; Free library in remote process
      hThread := DllCall("CreateRemoteThread", "PTR", hProc, "UInt", 0, "UInt", 0, "PTR", FreeLibrary, "PTR", PID.hModule, "UInt", 0, "UInt", 0,"PTR")
      DllCall("WaitForSingleObject", "PTR", hThread, "UInt", 0xFFFFFFFF)
      ,DllCall("CloseHandle", "PTR", hThread),DllCall("CloseHandle", "PTR", hProc)
      return
    }
    
    nScriptLength := VarSetCapacity(nScript, (StrLen(script)+1)*(A_IsUnicode?2:1), 0)
    ,StrPut(script,&nScript)
    
    ; Reserve memory in remote process where our script will be saved
    If !pBufferRemote := DllCall("VirtualAllocEx", "Ptr", hProc, "Ptr", 0, "PTR", nScriptLength, "UInt", MEM_COMMIT, "UInt", PAGE_EXECUTE_READWRITE, "Ptr")
      return DllCall("MessageBox","PTR",0,"Str","Could not reseve memory for process.","STR","Error","UInt",0)
            ,DllCall("CloseHandle", "PTR", hProc)
 
    ; Write script to remote process memory
    DllCall("WriteProcessMemory", "Ptr", hProc, "Ptr", pBufferRemote, "Ptr", &nScript, "PTR", nScriptLength, "Ptr", 0)
    
    ; Start execution of code
    hThread := DllCall("CreateRemoteThread", "PTR", hProc, "PTR", 0, "PTR", 0, "PTR", PID.ahkExec, "PTR", pBufferRemote, "UInt", 0, "PTR", 0,"PTR")
    If !hThread
    {
      DllCall("VirtualFreeEx","PTR",hProc,"PTR",pBufferRemote,"PTR",nScriptLength,MEM_RELEASE)
      ,DllCall("CloseHandle", "PTR", hProc)
      return DllCall("MessageBox","PTR",0,"Str","Could not execute script in remote process.","STR","Error","UInt",0)
    }
    
    ; Wait for thread to finish
    DllCall("WaitForSingleObject", "PTR", hThread, "UInt", 0xFFFFFFFF)
    
    ; Get Exit code returned by ahkExec (1 = script could be executed / 0 = script could not be executed)
    DllCall("GetExitCodeThread", "PTR", hThread, "UIntP", lpExitCode)
    If !lpExitCode
      return DllCall("MessageBox","PTR",0,"Str","Could not execute script in remote process.","STR","Error","UInt",0)
    
    DllCall("CloseHandle", "PTR", hThread)
    ,DllCall("VirtualFreeEx","PTR",hProc,"PTR",pBufferRemote,"PTR",nScriptLength,MEM_RELEASE)
    ,DllCall("CloseHandle", "PTR", hProc)
    return
  } else if !hDll:=DllCall("LoadLibrary","Str",dll,"PTR")
    return DllCall("MessageBox","PTR",0,"Str","Could not find " dll " library.","STR","Error","UInt",0),DllCall("CloseHandle", "PTR", hProc)
  else {
    hProc := DllCall("OpenProcess","UInt", PROCESS_ALL_ACCESS, "Int",0,"UInt", DllCall("GetCurrentProcessId"),"PTR")
    DllCall("GetModuleFileName","PTR",hDll,"PTR",&ModuleName,"UInt",MAX_PATH)
    DllCall("CloseHandle","PTR",hProc)
  }
  ; Open Process to PID
  hProc := DllCall("OpenProcess", "UInt", PROCESS_ALL_ACCESS, "Int",0, "UInt", PID,"PTR")
  If !hProc
    return DllCall("MessageBox","PTR",0,"Str","Could not open process for PID: " PID,"STR","Error","UInt",0)
 
  ; Reserve some memory and write dll path (ANSI)
  nDirLength := VarSetCapacity(nDir, StrLen(dll)+1, 0)
  ,StrPut(dll,&nDir,"CP0")
 
  ; Reserve memory in remote process
  If !pBufferRemote := DllCall("VirtualAllocEx", "Ptr", hProc, "Ptr", 0, "PTR", nDirLength, "UInt", MEM_COMMIT, "UInt", PAGE_EXECUTE_READWRITE, "Ptr")
    return DllCall("MessageBox","PTR",0,"Str","Could not reseve memory for process.","STR","Error","UInt",0),DllCall("CloseHandle", "PTR", hProc)
 
  ; Write dll path to remote process memory
  DllCall("WriteProcessMemory", "Ptr", hProc, "Ptr", pBufferRemote, "Ptr", &nDir, "PTR", nDirLength, "Ptr", 0)
 
  ; Start new thread loading our dll
 
  hThread:=DllCall("CreateRemoteThread","PTR",hProc,"PTR",0,"PTR",0,"PTR",LoadLibraryA,"PTR",pBufferRemote,"UInt",0,"PTR",0,"PTR")
  If !hThread {
    DllCall("VirtualFreeEx","PTR",hProc,"PTR",pBufferRemote,"PTR",nDirLength,"Uint",MEM_RELEASE)
    ,DllCall("CloseHandle", "PTR", hProc)
    return DllCall("MessageBox","PTR",0,"Str","Could not load " dll " in remote process.","STR","Error","UInt",0)
  }
  ; Wait for thread to finish
  DllCall("WaitForSingleObject", "PTR", hThread, "UInt", 0xFFFFFFFF)
 
  ; Get Exit code returned by thread (HMODULE for our dll)
  DllCall("GetExitCodeThread", "PTR", hThread, "UInt*", hModule)
 
  ; Close Thread
  DllCall("CloseHandle", "PTR", hThread)
 
  If (A_PtrSize=8){ ; use different method to retrieve base address because GetExitCodeThread returns DWORD only
    hModule:=0,me32 := Struct(_MODULEENTRY32)
    ;  Take a snapshot of all modules in the specified process.
    hModuleSnap := DllCall("CreateToolhelp32Snapshot","UInt", TH32CS_SNAPMODULE,"UInt", PID, "PTR" )
    if( hModuleSnap != INVALID_HANDLE_VALUE ){
      ; reset hModule and set the size of the structure before using it.
      me32.dwSize := sizeof(_MODULEENTRY32)
      ;  Retrieve information about the first module,
      ;  and exit if unsuccessful
      if( !DllCall("Module32First" (A_IsUnicode?"W":""),"PTR", hModuleSnap,"PTR", me32[] ) ) {
  ; Free memory used for passing dll path to remote thread
        DllCall("VirtualFreeEx","PTR",hProc,"PTR",pBufferRemote,"PTR",nDirLength,MEM_RELEASE)
        ,DllCall("CloseHandle","PTR", hModuleSnap ) ; Must clean up the snapshot object!
        return false
      }
      ;  Now walk the module list of the process,and display information about each module
      while(A_Index=1 || DllCall("Module32Next" (A_IsUnicode?"W":""),"PTR",hModuleSnap,"PTR", me32[] ) )
        If (StrGet(me32.szExePath[""])=dll){
          hModule := me32.modBaseAddr["",""]
          break
        }
      DllCall("CloseHandle","PTR",hModuleSnap) ; clean up
    }
  }
 
  hDll:=DllCall("LoadLibrary","Str",dll,"PTR")
 
  ; Calculate pointer to ahkdll and ahkExec functions
  ahktextdll:=hModule+DllCall("GetProcAddress","PTR",hDll,"AStr","ahktextdll","PTR")-hDll
  ahkExec:=hModule+DllCall("GetProcAddress","PTR",hDll,"AStr","ahkExec","PTR")-hDll
  ahkTerminate:=hModule+DllCall("GetProcAddress","PTR",hDll,"AStr","ahkTerminate","PTR")-hDll
 
 
  If script {
    nScriptLength := VarSetCapacity(nScript, (StrLen(script)+1)*(A_IsUnicode?2:1), 0)
    ,StrPut(script,&nScript)
    ; Reserve memory in remote process where our script will be saved
    If !pBufferScript := DllCall("VirtualAllocEx", "Ptr", hProc, "Ptr", 0, "PTR", nScriptLength, "UInt", MEM_COMMIT, "UInt", PAGE_EXECUTE_READWRITE, "Ptr")
      return DllCall("MessageBox","PTR",0,"Str","Could not reseve memory for process.","STR","Error","UInt",0)
            ,DllCall("CloseHandle", "PTR", hProc)
 
    ; Write script to remote process memory
    DllCall("WriteProcessMemory", "Ptr", hProc, "Ptr", pBufferScript, "Ptr", &nScript, "PTR", nScriptLength, "Ptr", 0)
    
  } else pBufferScript:=0
 
  ; Run ahkdll function in remote thread
  hThread := DllCall("CreateRemoteThread","PTR",hProc,"PTR",0,"PTR",0,"PTR",ahktextdll,"PTR",pBufferScript,"PTR",0,"UInt",0,"PTR")
  If !hThread { ; could not start ahkdll in remote process
    ; Free memory used for passing dll path to remote thread
    DllCall("VirtualFreeEx","PTR",hProc,"PTR",pBufferRemote,"PTR",nDirLength,MEM_RELEASE)
    DllCall("CloseHandle", "PTR", hProc)
    return DllCall("MessageBox","PTR",0,"Str","Could not start ahkdll in remote process","STR","Error","UInt",0)
  }
  DllCall("WaitForSingleObject", "PTR", hThread, "UInt", 0xFFFFFFFF)
  DllCall("GetExitCodeThread", "PTR", hThread, "UIntP", lpExitCode)
 
  ; Release memory and handles
  DllCall("VirtualFreeEx","PTR",hProc,"PTR",pBufferRemote,"PTR",nDirLength,MEM_RELEASE)
  DllCall("CloseHandle", "PTR", hThread)
  DllCall("CloseHandle", "PTR", hProc)
 
  If !lpExitCode ; thread could not be created.
    return DllCall("MessageBox","PTR",0,"Str","Could not create a thread in remote process","STR","Error","UInt",0)
 
  return {PID:PID,hModule:hModule,ahkExec:ahkExec,ahkTerminate:ahkTerminate,base:base}
}