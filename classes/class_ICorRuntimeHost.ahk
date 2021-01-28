Class ICorRuntimeHost
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    StartCode := 1


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Version := "")
    {
        ; Microsoft.NET Framework Version
        If ((Version:=StrReplace(Version, "v")) == "")
        {
            Loop Files, A_WinDir . "\Microsoft.NET\Framework" . (A_PtrSize==8?"64":"") . "\*", "D"
                If (FileExist(A_LoopFileFullPath . "\mscorlib.dll") && (Version == "" || StrSplit(SubStr(A_LoopFileName, 2), ".")[1] >= Version))
                    Version := SubStr(A_LoopFileName, 2)
            If (Version == "")
                MsgBox("A version of .NET Framework could not be found.`nDownload and install .NET Framework.",, 0x2010), ExitApp()
        }

        ; ICorRuntimeHost Interface (https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-interface)
        ; EXTERN_GUID(CLSID_CorRuntimeHost, 0xcb2f6723, 0xab3a, 0x11d2, 0x9c, 0x40, 0x00, 0xc0, 0x4f, 0xa3, 0x0a, 0x3e)
        ; EXTERN_GUID(IID_ICorRuntimeHost, 0xcb2f6722, 0xab3a, 0x11d2, 0x9c, 0x40, 0x00, 0xc0, 0x4f, 0xa3, 0x0a, 0x3e)
        Local GUID, IID, pICLRRuntimeHost, R
        VarSetCapacity(GUID, 16, 0), DllCall("Ole32.dll\CLSIDFromString", "Str", "{CB2F6723-AB3A-11d2-9C40-00C04FA30A3E}", "UPtr", &GUID)
        VarSetCapacity(IID, 16, 0),  DllCall("Ole32.dll\CLSIDFromString", "Str", "{CB2F6722-AB3A-11d2-9C40-00C04FA30A3E}", "UPtr",  &IID)
        If (R := DllCall("MSCorEE.dll\CorBindToRuntimeEx", "Str", "v" . Version, "UPtr", 0, "UInt", 0, "UPtr", &GUID, "UPtr", &IID, "UPtrP", pICLRRuntimeHost, "UInt"))
            MsgBox("An error has occurred.`nSpecifically: CorBindToRuntimeEx (ICorRuntimeHost)`nError code: " . Format("0x{:08X}", R),, 0x2010), ExitApp()

        ; ICorRuntimeHost : public IUnknown
        this.ICorRuntimeHost := pICLRRuntimeHost
        For Each, Method in ["CreateLogicalThreadState","DeleteLogicalThreadState","SwitchInLogicalThreadState","SwitchOutLogicalThreadState","LocksHeldByLogicalThread","MapFile","GetConfiguration","Start"
                            ,"Stop","CreateDomain","GetDefaultDomain","EnumDomains","NextDomain","CloseEnum","CreateDomainEx","CreateDomainSetup","CreateEvidence","UnloadDomain","CurrentDomain"]
            ObjRawSet(this, "p" . Method, NumGet(NumGet(this.ICorRuntimeHost) + (2 + A_Index) * A_PtrSize))
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.ICorRuntimeHost)
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Start()
    {
        Return DllCall(this.pStart, "UPtr", this.ICorRuntimeHost, "UInt")
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/icorruntimehost-start-method

    Stop()
    {
        Return DllCall(this.pStop, "UPtr", this.ICorRuntimeHost, "UInt")
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/icorruntimehost-stop-method
}
