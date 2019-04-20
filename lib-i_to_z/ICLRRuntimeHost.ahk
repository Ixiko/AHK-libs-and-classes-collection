Class ICLRRuntimeHost
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

        ; ICLRRuntimeHost Interface (https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-interface)
        ; EXTERN_GUID(CLSID_CLRRuntimeHost, 0x90F1A06E, 0x7712, 0x4762, 0x86, 0xB5, 0x7A, 0x5E, 0xBA, 0x6B, 0xDB, 0x02)
        ; EXTERN_GUID(IID_ICLRRuntimeHost, 0x90F1A06C, 0x7712, 0x4762, 0x86, 0xB5, 0x7A, 0x5E, 0xBA, 0x6B, 0xDB, 0x02)
        Local GUID, IID, pICLRRuntimeHost, R
        VarSetCapacity(GUID, 16, 0), DllCall("Ole32.dll\CLSIDFromString", "Str", "{90F1A06E-7712-4762-86B5-7A5EBA6BDB02}", "UPtr", &GUID)
        VarSetCapacity(IID, 16, 0),  DllCall("Ole32.dll\CLSIDFromString", "Str", "{90F1A06C-7712-4762-86B5-7A5EBA6BDB02}", "UPtr",  &IID)
        If (R := DllCall("MSCorEE.dll\CorBindToRuntimeEx", "Str", "v" . Version, "UPtr", 0, "UInt", 0, "UPtr", &GUID, "UPtr", &IID, "UPtrP", pICLRRuntimeHost, "UInt"))
            MsgBox("An error has occurred.`nSpecifically: CorBindToRuntimeEx (ICLRRuntimeHost)`nError code: " . Format("0x{:08X}", R),, 0x2010), ExitApp()

        ; ICLRRuntimeHost : public IUnknown
        this.ICLRRuntimeHost := pICLRRuntimeHost
        For Each, Method in ["Start","Stop","SetHostControl","GetCLRControl","UnloadAppDomain","ExecuteInAppDomain","GetCurrentAppDomainId","ExecuteApplication","ExecuteInDefaultAppDomain"]
            ObjRawSet(this, "p" . Method, NumGet(NumGet(this.ICLRRuntimeHost) + (2 + A_Index) * A_PtrSize))
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        If (this.StartCode == 0)
            this.Stop()
        ObjRelease(this.ICLRRuntimeHost)
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    Start()
    {
        Return this.StartCode ? this.StartCode := DllCall(this.pStart, "UPtr", this.ICLRRuntimeHost, "UInt") : 0
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-start-method

    Stop()
    {
        Local R := DllCall(this.pStop, "UPtr", this.ICLRRuntimeHost, "UInt")
        this.StartCode := R == 0
        Return R
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-stop-method

    SetHostControl(IHostControl)
    {
        Return DllCall(this.pSetHostControl, "UPtr", this.ICLRRuntimeHost, "UPtr", IHostControl, "UInt")
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-sethostcontrol-method

    GetCLRControl(ByRef ICLRControl)
    {
        Return DllCall(this.pGetCLRControl, "UPtr", this.ICLRRuntimeHost, "UPtrP", ICLRControl, "UInt")
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-getclrcontrol-method

    UnloadAppDomain(AppDomainId, WaitUntilDone)
    {
        Return DllCall(this.pUnloadAppDomain, "UPtr", this.ICLRRuntimeHost, "UInt", AppDomainId, "Int", WaitUntilDone, "UInt")
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-unloadappdomain-method

    ExecuteInAppDomain(AppDomainId, Callback, Cookie)
    {
        Return DllCall(this.pExecuteInAppDomain, "UPtr", this.ICLRRuntimeHost, "UInt", AppDomainId, "UPtr", Callback, "UPtr", Cookie, "UInt")
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-executeinappdomain-method

    GetCurrentAppDomainId(ByRef AppDomainId)
    {
        Return DllCall(this.pGetCurrentAppDomainId, "UPtr", this.ICLRRuntimeHost, "UIntP", AppDomainId, "UInt")
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-getcurrentappdomainid-method

    ExecuteApplication(AppFullName, nManifestPaths := 0, ManifestPaths := 0, nActivationData := 0, ActivationData := 0, ByRef ReturnValue := "")
    {
        Return DllCall(this.pExecuteApplication, "UPtr", this.ICLRRuntimeHost, "UPtr", &AppFullName, "UInt", nManifestPaths, "UPtr", ManifestPaths, "UInt", nActivationData, "UPtr", ActivationData, "IntP", ReturnValue, "UInt")
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-executeapplication-method

    ExecuteInDefaultAppDomain(AssemblyPath, TypeName, MethodName, Argument, ByRef ReturnValue)
    {
        Return DllCall(this.pExecuteInDefaultAppDomain, "UPtr", this.ICLRRuntimeHost, "UPtr", &AssemblyPath, "UPtr", &TypeName, "UPtr", &MethodName, "UPtr", &Argument, "UIntP", ReturnValue, "UInt")
    } ; https://docs.microsoft.com/en-us/dotnet/framework/unmanaged-api/hosting/iclrruntimehost-executeindefaultappdomain-method
}
