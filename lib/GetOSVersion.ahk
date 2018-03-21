/*! TheGood
    GetOSVersion()
    Last Updated: June 9th, 2010
    
    All parameters are optional.
    
    ________________________________________________________________________________________________________________________
    Output Var:     Description:
    
    sOSName         Set to the fully qualified name of the operating system. Its format is
                    Microsoft Windows <Release name> <Edition> <Service Pack> <build number>
                    
    bIs64           Set to True if the system is running a 64-bit version of Windows.
    
    iServicePack    Set to the version number of the latest service pack installed on the system. Its format is
                    %MajorVersionNumber%.%MinorVersionNumber%
    
    bIsNT           Set to True if the operating system is based on the Windows NT architecture.
    
    iBuildNumber    Set to the build number of the operating system.
    
    Return value    The version number of the operating system. Its format is %MajorVersionNumber%.%MinorVersionNumber%
                    
                    Possible values for Windows NT-based operating systems are:
                    Return value:   Possible OS:
                        6.1             Windows 7, Windows Server 2008 R2
                        6.0             Windows Vista, Windows Server 2008
                        5.2             Windows XP Professional x64 Edition, Windows Server 2003 and its derivatives
                        5.1             Windows XP
                        5.0             Windows 2000
                        4.0             Windows NT 4.0
                    
                    Possible values for non-Windows NT-based operating systems are:
                    Return value:   Possible OS:
                        4.90            Windows ME
                        4.10            Windows 98
                        4.0             Windows 95
*/
GetOSVersion(ByRef sOSName, ByRef bIs64 = 0, ByRef iServicePack = 0, ByRef bIsNT = 0, ByRef iBuildNumber = 0) {
    
    VarSetCapacity(cOSVersionInfoEx, 156)
    NumPut(156, cOSVersionInfoEx, "int")
    
    DllCall("GetVersionEx", "uint", &cOSVersionInfoEx)
    
    iMajorVersion     := NumGet(cOSVersionInfoEx,  4, "uint")
    iMinorVersion     := NumGet(cOSVersionInfoEx,  8, "uint")
    iVersion = %iMajorVersion%.%iMinorVersion%
    
    iBuildNumber      := NumGet(cOSVersionInfoEx, 12, "uint")
    iPlatformID       := NumGet(cOSVersionInfoEx, 16, "uint")
    
    sCSDVersion       := DllCall("MulDiv", "int", &cOSVersionInfoEx + 20, "int", 1, "int", 1, "str")
    
    iServicePackMajor := NumGet(cOSVersionInfoEx, 148, "ushort")
    iServicePackMinor := NumGet(cOSVersionInfoEx, 150, "ushort")
    iServicePack = %iServicePackMajor%.%iServicePackMinor%
    
    iSuiteMask        := NumGet(cOSVersionInfoEx, 152, "ushort")
    iProductType      := NumGet(cOSVersionInfoEx, 154, "uchar")
    
    VarSetCapacity(cSystemInfo, 48, 0)
    
    ;Check which function to use
    If (iGNSIAddr := DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "kernel32"), "str", "GetNativeSystemInfo"))
        DllCall(iGNSIAddr, "uint", &cSystemInfo)
    Else DllCall("GetSystemInfo", "uint", &cSystemInfo)
    
    ;Get processor architecture
    iProcessorArc := NumGet(cSystemInfo, 0, "ushort")
    bIs64 := (iProcessorArc = 9) Or (iProcessorArc = 6) ;PROCESSOR_ARCHITECTURE_AMD64
    
    ;Start building the string
    sOSName := "Microsoft "
    
    If (iPlatformID = 2) { ;VER_PLATFORM_WIN32_NT
        
        bIsNT := True
        
        If (iMajorVersion = 6) {
            
            If (iMinorVersion = 0) {
                If (iProductType = 1) ;VER_NT_WORKSTATION
                    sOSName .= "Windows Vista "
                Else sOSName .= "Windows Server 2008 "
            } Else If (iMinorVersion = 1) {
                If (iProductType = 1) ;VER_NT_WORKSTATION
                    sOSName .= "Windows 7 "
                Else sOSName .= "Windows Server 2008 R2 "
            }
            
            DllCall("GetProductInfo", "uint", iMajorVersion, "uint", iMinorVersion, "uint", 0, "uint", 0, "uint*", iProductType)
            
            If (iProductType = 0x00000001) ;PRODUCT_ULTIMATE
                sOSName .= "Ultimate Edition"
            Else If (iProductType = 0x00000030) ;PRODUCT_PROFESSIONAL
                sOSName .= "Professional"
            Else If (iProductType = 0x00000003) ;PRODUCT_HOME_PREMIUM
                sOSName .= "Home Premium Edition"
            Else If (iProductType = 0x00000002) ;PRODUCT_HOME_BASIC
                sOSName .= "Home Basic Edition"
            Else If (iProductType = 0x00000004) ;PRODUCT_ENTERPRISE
                sOSName .= "Enterprise Edition"
            Else If (iProductType = 0x00000006) ;PRODUCT_BUSINESS
                sOSName .= "Business Edition"
            Else If (iProductType = 0x0000000B) ;PRODUCT_STARTER
                sOSName .= "Starter Edition"
            Else If (iProductType = 0x00000012) ;PRODUCT_CLUSTER_SERVER
                sOSName .= "Cluster Server Edition"
            Else If (iProductType = 0x00000008) ;PRODUCT_DATACENTER_SERVER
                sOSName .= "Datacenter Edition"
            Else If (iProductType = 0x0000000C) ;PRODUCT_DATACENTER_SERVER_CORE
                sOSName .= "Datacenter Edition (core installation)"
            Else If (iProductType = 0x0000000A) ;PRODUCT_ENTERPRISE_SERVER
                sOSName .= "Enterprise Edition"
            Else If (iProductType = 0x0000000E) ;PRODUCT_ENTERPRISE_SERVER_CORE
                sOSName .= "Enterprise Edition (core installation)"
            Else If (iProductType = 0x0000000F) ;PRODUCT_ENTERPRISE_SERVER_IA64
                sOSName .= "Enterprise Edition for Itanium-based Systems"
            Else If (iProductType = 0x00000009) ;PRODUCT_SMALLBUSINESS_SERVER
                sOSName .= "Small Business Server"
            Else If (iProductType = 0x00000019) ;PRODUCT_SMALLBUSINESS_SERVER_PREMIUM
                sOSName .= "Small Business Server Premium Edition"
            Else If (iProductType = 0x00000007) ;PRODUCT_STANDARD_SERVER
                sOSName .= "Standard Edition"
            Else If (iProductType = 0x0000000D) ;PRODUCT_STANDARD_SERVER_CORE
                sOSName .= "Standard Edition (core installation)"
            Else If (iProductType = 0x00000011) ;PRODUCT_WEB_SERVER
                sOSName .= "Web Server Edition"
            
        } Else If (iMajorVersion = 5) And (iMinorVersion = 2) {
            
            SysGet, SM_SERVERR2, 89
            
            If (SM_SERVERR2)
                sOSName .= "Windows Server 2003 R2, "
            Else If (iSuiteMask & 0x00002000) ;VER_SUITE_STORAGE_SERVER
                sOSName .= "Windows Storage Server 2003"
            Else If (iSuiteMask & 0x00008000) ;VER_SUITE_WH_SERVER
                sOSName .= "Windows Home Server"
            Else If (iProductType = 1) And (iProcessorArc = 9) ;VER_NT_WORKSTATION and PROCESSOR_ARCHITECTURE_AMD64
                sOSName .= "Windows XP Professional x64 Edition"
            Else sOSName .= "Windows Server 2003, "
            
            If (iProductType != 1) { ;VER_NT_WORKSTATION
                
                If (iProcessorArc = 6) { ;PROCESSOR_ARCHITECTURE_IA64
                    
                    If (iSuiteMask & 0x00000080) ;VER_SUITE_DATACENTER
                        sOSName .= "Datacenter Edition for Itanium-based Systems"
                    Else If (iSuiteMask & 0x00000002) ;VER_SUITE_ENTERPRISE
                        sOSName .= "Enterprise Edition for Itanium-based Systems"
                    
                } Else If (iProcessorArc = 9) { ;PROCESSOR_ARCHITECTURE_AMD64
                    
                    If (iSuiteMask & 0x00000080) ;VER_SUITE_DATACENTER
                        sOSName .= "Datacenter x64 Edition"
                    Else If (iSuiteMask & 0x00000002) ;VER_SUITE_ENTERPRISE
                        sOSName .= "Enterprise x64 Edition"
                    Else sOSName .= "Standard x64 Edition"
                    
                } Else {
                    
                    If (iSuiteMask & 0x00004000) ;VER_SUITE_COMPUTE_SERVER
                        sOSName .= "Compute Cluster Edition"
                    Else If (iSuiteMask & 0x00000080) ;VER_SUITE_DATACENTER
                        sOSName .= "Datacenter Edition"
                    Else If (iSuiteMask & 0x00000002) ;VER_SUITE_ENTERPRISE
                        sOSName .= "Enterprise Edition"
                    Else If (iSuiteMask & 0x00000400) ;VER_SUITE_BLADE
                        sOSName .= "Web Edition"
                    Else sOSName .= "Standard Edition"
                }
            }
            
        } Else If (iMajorVersion = 5) And (iMinorVersion = 1) {
            
            SysGet, SM_TABLETPC, 86
            SysGet, SM_MEDIACENTER, 87
            SysGet, SM_STARTER, 88
            
            If SM_TABLETPC
                sOSName .= "Windows XP Tablet PC Edition"
            Else If SM_MEDIACENTER
                sOSName .= "Windows XP Media Center Edition"
            Else If SM_STARTED
                sOSName .= "Windows XP Started Edition"
            Else {
                
                sOSName .= "Windows XP "
                If (iSuiteMask & 0x00000200) ;VER_SUITE_PERSONAL
                    sOSName .= "Home Edition"
                Else sOSName .= "Professional"
            }
            
        } Else If (iMajorVersion = 5) And (iMinorVersion = 0) {
            
            sOSName .= "Windows 2000 "
            If (iProductType = 1)
                sOSName .= "Professional"
            Else {
                
                If (iSuiteMask & 0x00000080) ;VER_SUITE_DATACENTER
                    sOSName .= "Datacenter Server"
                Else If (iSuiteMask & 0x00000002) ;VER_SUITE_ENTERPRISE
                    sOSName .= "Advanced Server"
                Else sOSName .= "Server"
            }
            
        } Else If (iMajorVersion = 4) And (iMinorVersion = 0)
            sOSName .= "Windows NT 4.0"
        
        ;Include any service pack
        If sCSDVersion
            sOSName .= " " sCSDVersion
        
        ;Add build number
        sOSName .= " (build " iBuildNumber ")"
        
        If (iMajorVersion >= 6) {
            If (iProcessorArc = 9) ;PROCESSOR_ARCHITECTURE_AMD64
                sOSName .= ", 64-bit"
            Else If (iProcessorArc = 9) ;PROCESSOR_ARCHITECTURE_INTEL
                sOSName .= ", 32-bit"
        }
        
    } Else If (iPlatformID = 1) { ;VER_PLATFORM_WIN32_WINDOWS
        
        bIsNT := False
        
        If (iMinorVersion < 10) {
            
            sOSName .= "Windows 95"
            
            If (sCSDVersion = "A")
                sOSName .= " OEM Service Release 1" ;Equivalent to Service Pack 1 (for retail versions)
            Else If (sCSDVersion = "B")
                sOSName .= " OEM Service Release 2"
            Else If (sCSDVersion = "C")
                sOSName .= " OEM Service Release 2.5"
            
        } Else If (iMinorVersion = 10) {
            
            sOSName .= "Windows 98"
            
            If (iBuildNumber = 2222)
                sOSName .= " Second Edition"
            
        } Else If (iMinorVersion = 90)
            sOSName .= "Windows ME"
        
        ;Add build number
        sOSName .= " (build " iBuildNumber ")"
    }
    
    Return iVersion
}