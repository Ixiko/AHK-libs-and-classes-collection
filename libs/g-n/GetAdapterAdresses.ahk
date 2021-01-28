/*
#NoEnv
VarSetCapacity(adapterGuid, 16), VarSetCapacity(adapterGuidStr, 140), adapters := GetAdaptersAddresses()

for INetwork in ComObjCreate("{DCB00C01-570F-4A9B-8D69-199FDBA5723B}").GetNetworks(1) { ; NLM_ENUM_NETWORK_CONNECTED
	profileName := INetwork.GetName()
	for k, v in INetwork.GetNetworkConnections() {
		try if ((INetworkConnection := ComObjQuery(k, "{DCB00005-570F-4A9B-8D69-199FDBA5723B}"))) {
			if (DllCall(NumGet(NumGet(INetworkConnection+0)+12*A_PtrSize), "Ptr", INetworkConnection, "Ptr", &adapterGuid) == 0) { ; ::GetAdapterId
				if (DllCall("ole32\StringFromGUID2", "Ptr", &adapterGuid, "WStr", adapterGuidStr, "Int", 68)) {
					adapterName := adapters[adapterGuidStr].Description
					interfaceAlias := adapters[adapterGuidStr].FriendlyName
				}
			}
			ObjRelease(INetworkConnection)
		}
	}
	MsgBox % profileName . "`n" . adapterName . "`n" . interfaceAlias
}
*/

; just me: https://autohotkey.com/boards/viewtopic.php?t=18768
GetAdaptersAddresses() {
	; initial call to GetAdaptersAddresses to get the size needed
	If (DllCall("iphlpapi.dll\GetAdaptersAddresses", "UInt", 2, "UInt", 0, "Ptr", 0, "Ptr", 0, "UIntP", Size) = 111) ; ERROR_BUFFER_OVERFLOW
		If !(VarSetCapacity(Buf, Size, 0))
			Return "Memory allocation failed for IP_ADAPTER_ADDRESSES struct"

	; second call to GetAdapters Addresses to get the actual data we want
	If (DllCall("iphlpapi.dll\GetAdaptersAddresses", "UInt", 2, "UInt", 0, "Ptr", 0, "Ptr", &Buf, "UIntP", Size) != 0) ; NO_ERROR
		Return "Call to GetAdaptersAddresses failed with error: " . A_LastError

	Addr := &Buf
	Adapters := {}
	While (Addr) {
		AdapterName := StrGet(NumGet(Addr + 8, A_PtrSize, "Uptr"), "CP0")
		Description := StrGet(NumGet(Addr + 8, A_PtrSize * 7, "UPtr"), "UTF-16")
		FriendlyName := StrGet(NumGet(Addr + 8, A_PtrSize * 8, "UPtr"), "UTF-16")
		Adapters[AdapterName] := {Description: Description, FriendlyName: FriendlyName}
		Addr := NumGet(Addr + 8, "UPtr") ; *Next
	}
	Return Adapters
}