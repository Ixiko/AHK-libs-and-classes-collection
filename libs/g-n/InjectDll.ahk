InjectDll(pid,dllpath)   ;目标进程pid，需要注入的dll路径
{
    FileGetSize, size, %dllpath%   ;获取dll文件大小
    file := FileOpen(dllpath, "r")   ;只读方式打开“r”
    file.RawRead(dllFile, size)        ;文件写入到变量dllFile

    pHandle := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", false, "UInt", pid) ;根据pid获得句柄，权限为“0x1F0FFF“所有权限
    
    ;在目标进程申请size大小内存区域用于写入
    pLibRemote := DllCall("VirtualAllocEx", "Uint", pHandle, "Uint", 0, "Uint", size, "Uint", 0x1000, "Uint", 4)
          
    ;写入Dll
    VarSetCapacity(result,4)
    DllCall("WriteProcessMemory","Uint",pHandle,"Uint",pLibRemote,"Uint",&dllFile,"Uint",size,"Uint",&result)
     
    ;找到LoadLibraryA的入口地址
    LoadLibraryAdd := DllCall("GetProcAddress", "Uint", DllCall("GetModuleHandle", "str", "kernel32.dll"),"AStr", "LoadLibraryA")
    
    ;创建远程进程，以完成注入
    hThrd := DllCall("CreateRemoteThread", "Uint", pHandle, "Uint", 0, "Uint", 0, "Uint", LoadLibraryAdd, "Uint", pLibRemote, "Uint", 0, "Uint", 0)
    
    ;回收内存区域    
    DllCall("VirtualFreeEx","Uint",hProcess,"Uint",pLibRemote,"Uint",0,"Uint",32768)
    
    DllCall("CloseHandle", "Uint", hThrd)
    DllCall("CloseHandle", "Uint", pHandle)
    Return True
}