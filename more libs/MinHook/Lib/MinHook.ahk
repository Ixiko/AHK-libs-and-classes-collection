; v1.2.1 (2019-08-18)
; AHK version: U32/U64

class MinHook
{
	__New(ModuleName, ModuleFunction, CallbackFunction)
	{
		static init
		if !init
			init := this.__MinHook_Load_Unload()

		if !IsFunc(CallbackFunction)
			throw "Function <" CallbackFunction "> does not exist."

		this.cbAddr := RegisterCallback(CallbackFunction, "F",, &this)

		if (ModuleName = "")
		{
			if err := MH_CreateHook(ModuleFunction, this.cbAddr, pOriginal)
				throw MH_StatusToString(err)
		}
		else
		{
			if !(ModuleName ~= "i)^(User32|Kernel32|ComCtl32|Gdi32)(\.dll)?$")
			{
				if !this.hModule := DllCall("LoadLibrary", "str", ModuleName, "ptr")
					throw "Failed loading module: " ModuleName
			}
			
			if err := MH_CreateHookApiEx(ModuleName, ModuleFunction, this.cbAddr, pOriginal, pTarget)
				throw MH_StatusToString(err)
		}
		
		this.original := pOriginal
		this.target := pTarget
	}

	__Delete()
	{
		MH_RemoveHook(this.target)
		DllCall("GlobalFree", "ptr", this.cbAddr, "ptr")
		if this.hModule
			DllCall("FreeLibrary", "ptr", this.hModule)
	}

	Enable() {
		if err := MH_EnableHook(this.target)
			throw MH_StatusToString(err)
	}

	Disable() {
		if err := MH_DisableHook(this.target)
			throw MH_StatusToString(err)
	}

	QueueEnable() {
		if err := MH_QueueEnableHook(this.target)
			throw MH_StatusToString(err)
	}

	QueueDisable() {
		if err := MH_QueueDisableHook(this.target)
			throw MH_StatusToString(err)
	}

	__MinHook_Load_Unload()
	{
		static _ := { base: {__Delete: MinHook.__MinHook_Load_Unload} }
		static hModule

		if _
		{
			if !dllFile := this._findDll()
				throw "Unable to find MinHook.dll"
			if !hModule := DllCall("LoadLibrary", "str", dllFile, "ptr")
				throw "Failed loading " dllFile
			if err := MH_Initialize()
				throw MH_StatusToString(err)
			return true
		}

		if hModule
		{
			DllCall("MinHook\MH_Uninitialize")
			DllCall("FreeLibrary", "ptr", hModule)
		}
	}

	_findDll()
	{
		dirs := { 4: [".", "MinHook\x32", A_LineFile "\..", A_LineFile "\..\MinHook\x32"]
		        , 8: [".", "MinHook\x64", A_LineFile "\..", A_LineFile "\..\MinHook\x64"] }
		for i, dir in dirs[A_PtrSize]
			if FileExist(dir "\MinHook.dll")
				return dir "\MinHook.dll"
	}
}


; Initialize the MinHook library. You must call this function EXACTLY ONCE
; at the beginning of your program.
MH_Initialize() {
	return DllCall("MinHook\MH_Initialize")
}

; Uninitialize the MinHook library. You must call this function EXACTLY
; ONCE at the end of your program.
MH_Uninitialize() {
	return DllCall("MinHook\MH_Uninitialize")
}

; Creates a Hook for the specified target function, in disabled state.
; Parameters:
;   pTarget    [in]  A pointer to the target function, which will be
;                    overridden by the detour function.
;   pDetour    [in]  A pointer to the detour function, which will override
;                    the target function.
;   ppOriginal [out] A pointer to the trampoline function, which will be
;                    used to call the original target function.
;                    This parameter can be NULL.
MH_CreateHook(pTarget, pDetour, ByRef ppOriginal := 0) {
	return DllCall("MinHook\MH_CreateHook"
	               , "ptr", pTarget
	               , "ptr", pDetour
	               , "uptr*", ppOriginal )
}

; Creates a Hook for the specified API function, in disabled state.
; Parameters:
;   pszModule  [in]  A pointer to the loaded module name which contains the
;                    target function.
;   pszTarget  [in]  A pointer to the target function name, which will be
;                    overridden by the detour function.
;   pDetour    [in]  A pointer to the detour function, which will override
;                    the target function.
;   ppOriginal [out] A pointer to the trampoline function, which will be
;                    used to call the original target function.
;                    This parameter can be NULL.
MH_CreateHookApi(pszModule, pszProcName, pDetour, ByRef ppOriginal := 0) {
	return DllCall("MinHook\MH_CreateHookApi"
	               , "str", pszModule
	               , "astr", pszProcName
	               , "ptr", pDetour
	               , "uptr*", ppOriginal )
}

; Creates a Hook for the specified API function, in disabled state.
; Parameters:
;   pszModule  [in]  A pointer to the loaded module name which contains the
;                    target function.
;   pszTarget  [in]  A pointer to the target function name, which will be
;                    overridden by the detour function.
;   pDetour    [in]  A pointer to the detour function, which will override
;                    the target function.
;   ppOriginal [out] A pointer to the trampoline function, which will be
;                    used to call the original target function.
;                    This parameter can be NULL.
;   ppTarget   [out] A pointer to the target function, which will be used
;                    with other functions.
;                    This parameter can be NULL.
MH_CreateHookApiEx(pszModule, pszProcName, pDetour, ByRef ppOriginal := 0, ByRef ppTarget := 0) {
	return DllCall("MinHook\MH_CreateHookApiEx"
	               , "str", pszModule
	               , "astr", pszProcName
	               , "ptr", pDetour
	               , "uptr*", ppOriginal
	               , "uptr*", ppTarget )
}

; Removes an already created hook.
; Parameters:
;   pTarget [in] A pointer to the target function.
MH_RemoveHook(pTarget) {
	return DllCall("MinHook\MH_RemoveHook", "ptr", pTarget)
}

/*
	#define MH_ALL_HOOKS NULL
*/

; Enables an already created hook.
; Parameters:
;   pTarget [in] A pointer to the target function.
;                If this parameter is MH_ALL_HOOKS, all created hooks are
;                enabled in one go.
MH_EnableHook(pTarget := 0) {
	return DllCall("MinHook\MH_EnableHook", "ptr", pTarget)
}

; Disables an already created hook.
; Parameters:
;   pTarget [in] A pointer to the target function.
;                If this parameter is MH_ALL_HOOKS, all created hooks are
;                disabled in one go.
MH_DisableHook(pTarget := 0) {
	return DllCall("MinHook\MH_DisableHook", "ptr", pTarget)
}

; Queues to enable an already created hook.
; Parameters:
;   pTarget [in] A pointer to the target function.
;                If this parameter is MH_ALL_HOOKS, all created hooks are
;                queued to be enabled.
MH_QueueEnableHook(pTarget := 0) {
	return DllCall("MinHook\MH_QueueEnableHook", "ptr", pTarget)
}

; Queues to disable an already created hook.
; Parameters:
;   pTarget [in] A pointer to the target function.
;                If this parameter is MH_ALL_HOOKS, all created hooks are
;                queued to be disabled.
MH_QueueDisableHook(pTarget := 0) {
	return DllCall("MinHook\MH_QueueDisableHook", "ptr", pTarget)
}

; Applies all queued changes in one go.
MH_ApplyQueued() {
	return DllCall("MinHook\MH_ApplyQueued")
}

; Translates the MH_STATUS to its name as a string.
MH_StatusToString(status) {
	return DllCall("MinHook\MH_StatusToString", "int", status, "astr")
}
