/*
    Recupera información sobre la versión del sistema operativo.
    Return:
        Devuelve un objeto con las siguientes claves:
            MajorVersion     = 
            MinorVersion     = 
            BuildNumber      = 
            PlatformId       = 
            CSDVersion       = 
            ServicePackMajor = 
            ServicePackMinor = 
            SuiteMask        = 
            ProductType      = 
    Ejemplo:
        MsgBox('OS Version: ' . GetSystemVersion().MajorVersion . '.' . GetSystemVersion().MinorVersion . '.' . GetSystemVersion().BuildNumber)
        MsgBox('OS Version: ' . A_OSVersion)
*/
GetSystemVersion()
{
    Local RTL_OSVERSIONINFOEX, SysInfo

    NumPut(VarSetCapacity(RTL_OSVERSIONINFOEX, 284, 0), &RTL_OSVERSIONINFOEX, 'UInt')
    DllCall('Ntdll.dll\RtlGetVersion', 'UPtr', &RTL_OSVERSIONINFOEX)

    SysInfo                  := {}
    SysInfo.MajorVersion     := NumGet(&RTL_OSVERSIONINFOEX +   4, 'UInt')
    SysInfo.MinorVersion     := NumGet(&RTL_OSVERSIONINFOEX +   8, 'UInt')
    SysInfo.BuildNumber      := NumGet(&RTL_OSVERSIONINFOEX +  12, 'UInt')
    SysInfo.PlatformId       := NumGet(&RTL_OSVERSIONINFOEX +  16, 'UInt')
    SysInfo.CSDVersion       := StrGet(&RTL_OSVERSIONINFOEX +  20, 128, 'UTF-16')
    SysInfo.ServicePackMajor := NumGet(&RTL_OSVERSIONINFOEX + 276, 'UShort')      ;16 + 128*2 + 4
    SysInfo.ServicePackMinor := NumGet(&RTL_OSVERSIONINFOEX + 278, 'UShort')
    SysInfo.SuiteMask        := NumGet(&RTL_OSVERSIONINFOEX + 280, 'UShort')
    SysInfo.ProductType      := NumGet(&RTL_OSVERSIONINFOEX + 282, 'UChar')
    
    Return (SysInfo)
} ;https://msdn.microsoft.com/en-us/library/windows/hardware/ff561910%28v=vs.85%29.aspx | https://msdn.microsoft.com/en-us/library/windows/hardware/ff563620(v=vs.85).aspx
