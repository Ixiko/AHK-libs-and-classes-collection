;ANSI version of injecting a dll, this file was translated from chinese to english with google translate - Ixiko 18.12.2018

InjectDllA(pid,dllpath)   ;Target process pid, the dll path to be injected
{
    FileGetSize, size, %dllpath%   ;Get dll file size
    file := FileOpen(dllpath, "r")   ;Open "r" in read-only mode
    file.RawRead(dllFile, size)        ;File is written to variable dllFile

    pHandle := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", false, "UInt", pid) ;Get the handle according to pid, the permission is "0x1F0FFF" all permissions
    
    ;Request size in the target process memory area for writing
    pLibRemote := DllCall("VirtualAllocEx", "Uint", pHandle, "Uint", 0, "Uint", size, "Uint", 0x1000, "Uint", 4)
          
    ;Write to Dll
    VarSetCapacity(result,4)
    DllCall("WriteProcessMemory","Uint",pHandle,"Uint",pLibRemote,"Uint",&dllFile,"Uint",size,"Uint",&result)
     
    ;Find the entry address of LoadLibraryA
    LoadLibraryAdd := DllCall("GetProcAddress", "Uint", DllCall("GetModuleHandle", "str", "kernel32.dll"),"AStr", "LoadLibraryA")
    
    ;Create a remote process to complete the injection
    hThrd := DllCall("CreateRemoteThread", "Uint", pHandle, "Uint", 0, "Uint", 0, "Uint", LoadLibraryAdd, "Uint", pLibRemote, "Uint", 0, "Uint", 0)
    
    ;Reclaim memory area    
    DllCall("VirtualFreeEx","Uint",hProcess,"Uint",pLibRemote,"Uint",0,"Uint",32768)
    
    DllCall("CloseHandle", "Uint", hThrd)
    DllCall("CloseHandle", "Uint", pHandle)
    Return True
}