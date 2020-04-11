; ==========================================================
;                  .NET Framework Interop
;      http://www.autohotkey.com/forum/topic26191.html
; ==========================================================
;
;   Author:     Lexikos
;   Version:    1.0
;   Requires:
;       - AutoHotkey Basic
;       - COM Standard Library
;         http://www.autohotkey.com/forum/topic22923.html
;

CLR_Start() {
    global CLR_CorRuntimeHost
    if CLR_CorRuntimeHost
        return
    COM_Init()
    if CLR_CorRuntimeHost := COM_CreateObject("CLRMetaData.CorRuntimeHost", "{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}")
        DllCall(NumGet(NumGet(CLR_CorRuntimeHost+0)+40),"uint",CLR_CorRuntimeHost)
    return CLR_CorRuntimeHost
}

CLR_StartDomain(ByRef pAppDomain, BaseDirectory="") {
    global CLR_CorRuntimeHost
    pAppDomain=0

    if (BaseDirectory!="") {    ; AppDomainSetup.ApplicationBase = BaseDirectory;
        DllCall(NumGet(NumGet(CLR_CorRuntimeHost+0)+72),"uint",CLR_CorRuntimeHost,"uint*",puSetup)
        pSetup := COM_QueryInterface(puSetup, "{27FFF232-A7A8-40DD-8D4A-734AD59FCD41}")
        psWorkingDir := COM_SysAllocString(BaseDirectory)
        DllCall(NumGet(NumGet(pSetup+0)+16),"uint",pSetup,"uint",psWorkingDir)
        COM_Release(pSetup), COM_SysFreeString(psWorkingDir)
    } else
        puSetup := 0
    hr:=DllCall(NumGet(NumGet(CLR_CorRuntimeHost+0)+68),"uint",CLR_CorRuntimeHost
            ,"uint*",0,"uint",puSetup,"uint",0,"uint*",pAppDomain)
    if puSetup
        COM_Release(puSetup)
    return hr
}

CLR_StopDomain(pAppDomain) {
    global CLR_CorRuntimeHost
    return DllCall(NumGet(NumGet(CLR_CorRuntimeHost+0)+80),"uint",CLR_CorRuntimeHost,"uint",pAppDomain)
}

;"After a call to Stop, the CLR cannot be reinitialized into the same process."
CLR_Stop() {
    global CLR_CorRuntimeHost
    if !CLR_CorRuntimeHost
        return
    DllCall(NumGet(NumGet(CLR_CorRuntimeHost+0)+44),"uint",CLR_CorRuntimeHost)
    COM_Release(CLR_CorRuntimeHost), CLR_CorRuntimeHost:=0
    COM_Term()
}

;Invoke equivalent:
;   COM_Invoke(pAssembly,"CreateInstance",sType)

CLR_CreateObject(pAssembly, sType, Type1="", Arg1="", Type2="", Arg2="", Type3="", Arg3="", Type4="", Arg4="", Type5="", Arg5="", Type6="", Arg6="", Type7="", Arg7="", Type8="", Arg8="", Type9="", Arg9="") {
    global _hResult_
    psType:=COM_SysAllocString(sType), VarSetCapacity(vtRet,16,0)

    if (Type1 != "")    ; The following is essentially based on COM_Invoke_()
    {
        nParams = 0
        Loop, 9
            if Type%A_Index% !=
                 nParams += 1
            else break
        VarSetCapacity(vtArgs,nParams*16,0)
        VarSetCapacity(aArgs,24,0), NumPut(&vtArgs,NumPut(16,NumPut(1,aArgs,0,"Ushort")+2)+4), NumPut(nParams,aArgs,16)
        Loop, %	nParams
            NumPut(type%A_Index%,vtArgs,(A_Index-1)*16,"Ushort"), type%A_Index%&0x4000=0 ? NumPut(type%A_Index%=8 ? COM_SysAllocString(arg%A_Index%) : arg%A_Index%,vtArgs,(A_Index-1)*16+8,type%A_Index%=5||type%A_Index%=7 ? "double" : type%A_Index%=4 ? "float" : "int64") : type%A_Index%=0x400C||type%A_Index%=0x400E ? NumPut(arg%A_Index%,vtArgs,(A_Index-1)*16+8) : VarSetCapacity(ref%A_Index%,8,0) . NumPut(&ref%A_Index%,vtArgs,(nParams-A_Index)*16+8) . NumPut(type%A_Index%=0x4008 ? COM_SysAllocString(arg%A_Index%) : arg%A_Index%,ref%A_Index%,0,type%A_Index%=0x4005||type%A_Index%=0x4007 ? "double" : type%A_Index%=0x4004 ? "float" : "int64")
        VarSetCapacity(vtRet,16,0)
        _hResult_:=DllCall(NumGet(NumGet(pAssembly+0)+172),"uint",pAssembly,"uint",psType,"short",0
            ,"int",0x200,"uint",0,"uint",&aArgs,"uint",0,"uint",0,"uint",&vtRet)
        Loop, %	nParams
            type%A_Index%&0x4000=0 ? (type%A_Index%=8 ? COM_SysFreeString(NumGet(vtArgs,(nParams-A_Index)*16+8)) : "") : type%A_Index%=0x400C||type%A_Index%=0x400E ? "" : type%A_Index%=0x4008 ? (_TEMP_VT_BYREF_%A_Index%:=COM_Ansi4Unicode(NumGet(ref%A_Index%))) . COM_SysFreeString(NumGet(ref%A_Index%)) : (_TEMP_VT_BYREF_%A_Index%:=NumGet(ref%A_Index%,0,type%A_Index%=0x4005||type%A_Index%=0x4007 ? "double" : type%A_Index%=0x4004 ? "float" : "int64"))
    }
    else
        _hResult_:=DllCall(NumGet(NumGet(pAssembly+0)+164),"uint",pAssembly,"uint",psType,"uint",&vtRet)

    COM_SysFreeString(psType)
    return NumGet(vtRet,8)
}

CLR_LoadLibrary(sLibrary, pAppDomain=0) {
    pApp := pAppDomain ? pAppDomain : CLR_GetDefaultDomain()
    if !pApp
        return 0
    if p_App := COM_QueryInterface(pApp,"{05F696DC-2B29-3663-AD8B-C4389CF2A713}")
    {
        psLibrary:=COM_SysAllocString(sLibrary)

        ; Attempt to load by full name (incl. Version, Culture & PublicKeyToken) first.
        hr:=DllCall(NumGet(NumGet(p_App+0)+176),"uint",p_App,"uint",psLibrary,"uint*",pAsm)

        if (hr!=0 or !pAsm)
        {
            ; Get typeof(Assembly) for calling static methods. (p_App->GetType()->Assembly->GetType())
            DllCall(NumGet(NumGet(p_App+0)+40),"uint",p_App,"uint*",p_Type)
            DllCall(NumGet(NumGet(p_Type+0)+80),"uint",p_Type,"uint*",p_Asm)
            COM_Release(p_Type)
            DllCall(NumGet(NumGet(p_Asm+0)+40),"uint",p_Asm,"uint*",p_Type)
            COM_Release(p_Asm), p_Asm:=0

            ; Initialize VARIANTs & SAFEARRAY(VARIANT) for method args.
            VarSetCapacity(vtArg,16,0), NumPut(8,vtArg), NumPut(psLibrary,vtArg,8)
            VarSetCapacity(vtRet,16,0)
            VarSetCapacity(rArgs,24,0), NumPut(&vtArg,NumPut(16,NumPut(1,rArgs,0,"Ushort")+2)+4), NumPut(1,rArgs,16)

            ; Attempt to load from file.
            ; Does not use IfExist since LoadFrom probably doesn't use A_WorkingDir.
            psMethodName:=COM_SysAllocString("LoadFrom")
            hr:=DllCall(NumGet(NumGet(p_Type+0)+228),"uint",p_Type
                ,"uint",psMethodName,"int",0x118,"uint",0
                ,"int64",1,"int64",0 ; VARIANT Target={ vt=VT_NULL }
                ,"uint",&rArgs,"uint",&vtRet)
            COM_SysFreeString(psMethodName)

            if (hr!=0 or !NumGet(vtRet,8))
            {   ; Attempt to load using partial name.
                psMethodName:=COM_SysAllocString("LoadWithPartialName")
                hr:=DllCall(NumGet(NumGet(p_Type+0)+228),"uint",p_Type
                    ,"uint",psMethodName,"int",0x118,"uint",0
                    ,"int64",1,"int64",0,"uint",&rArgs,"uint",&vtRet)
                COM_SysFreeString(psMethodName)
            }
            ; vtRet should now be of type VT_DISPATCH, so no QueryInterface necessary.
            if (hr=0)
                pAsm := NumGet(vtRet,8)
            else
                pAsm := 0

            COM_Release(p_Type)
        }
        COM_SysFreeString(psLibrary)
        COM_Release(p_App)
    }
    if (pAppDomain != pApp)
        COM_Release(pApp)
    return pAsm
}

CLR_CompileC#(Code, References, pAppDomain=0, FileName="", CompilerOptions="") {
    return CLR_CompileAssembly(Code, References
        , "System", "Microsoft.CSharp.CSharpCodeProvider", pAppDomain
        , FileName, CompilerOptions)
}

CLR_CompileVB(Code, References, pAppDomain=0, FileName="", CompilerOptions="") {
    return CLR_CompileAssembly(Code, References
        , "System", "Microsoft.VisualBasic.VBCodeProvider", pAppDomain
        , FileName, CompilerOptions)
}

;
; INTERNAL FUNCTIONS
;

CLR_GetDefaultDomain() {
    global CLR_CorRuntimeHost
    DllCall(NumGet(NumGet(CLR_CorRuntimeHost+0)+52),"uint",CLR_CorRuntimeHost,"uint*",pApp)
    return pApp
}

CLR_CompileAssembly(Code, References, ProviderAssembly, ProviderType, pAppDomain=0, FileName="", CompilerOptions="") {
    pApp := pAppDomain ? pAppDomain : CLR_GetDefaultDomain()
    if !pApp
        return 0

    asmProvider := CLR_LoadLibrary(ProviderAssembly, pApp)
    if ProviderAssembly = System
        asmSystem := asmProvider, COM_AddRef(asmSystem)
    else
        asmSystem := CLR_LoadLibrary("System", pApp)

    if (pAppDomain != pApp)
        COM_Release(pApp)
    if !asmProvider
        return 0

    codeProvider := CLR_CreateObject(asmProvider, ProviderType)
    COM_Release(asmProvider)
    if !codeProvider
        return 0

    codeCompiler := COM_Invoke(codeProvider, "CreateCompiler")
    COM_Release(codeProvider)

    StringSplit, References, References, |, %A_Space%%A_Tab%

    VarSetCapacity(aRefs,24+4*References0,0), NumPut(References0,aRefs,16)
    NumPut(&aRefs+24,NumPut(4,NumPut(1,aRefs,0,"Ushort")+2)+4)
    Loop, %References0%
        NumPut(COM_SysAllocString(References%A_Index%), aRefs, 20+4*A_Index)
    compilerParms := CLR_CreateObject(asmSystem
        , "System.CodeDom.Compiler.CompilerParameters", 0x2008, &aRefs)
    COM_Release(asmSystem)
    Loop, %References0%
        COM_SysFreeString(NumGet(aRefs, 20+4*A_Index))
    COM_Invoke(compilerParms, "GenerateInMemory=", FileName="")
    if SubStr(FileName,-3)=".exe"
        COM_Invoke(compilerParms, "GenerateExecutable=", true)
    if CompilerOptions
        COM_Invoke(compilerParms, "CompilerOptions=", CompilerOptions)
    if FileName
        COM_Invoke(compilerParms, "OutputAssembly=", FileName)
    COM_Invoke(compilerParms, "IncludeDebugInformation=", true)

    compilerRes := COM_Invoke(codeCompiler
        , "CompileAssemblyFromSource", "+" compilerParms, Code)
    COM_Release(compilerParms), COM_Release(codeCompiler)

    errors := COM_Invoke(compilerRes, "Errors")
    if error_count := COM_Invoke(errors, "Count")
    {
        Loop, % error_count
        {
            error := COM_Invoke(errors, "Item", A_Index-1)
            error_text .= (COM_Invoke(error, "IsWarning") ? "Warning " : "Error ")
                . COM_Invoke(error, "ErrorNumber") " on line " COM_Invoke(error, "Line")
                . ": " COM_Invoke(error, "ErrorText") "`n`n"
            COM_Release(error)
        }
        MsgBox, 16, Compilation Failed, %error_text%
        COM_Release(errors)
        return 0
    }
    COM_Release(errors)

    if FileName =
        asmResult := COM_Invoke(compilerRes, "CompiledAssembly")
    else    ; on success, return a string which can't be mistaken for a pointer.
        asmResult := error_count ? 0 : FileName

    COM_Release(compilerRes)

    return asmResult
}
