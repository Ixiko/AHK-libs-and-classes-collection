; ===========================================================================================================================================================================
; Gets general information about an application (from the Add/Remove Programs Application).
; Tested with AutoHotkey v2.0-a133
; ===========================================================================================================================================================================

EnumInstalledApps()
{
	static CLSID_EnumInstalledApps := "{0B124F8F-91F0-11D1-B8B5-006008059382}"
	static IID_IEnumInstalledApps  := "{1BC752E1-9046-11D1-B8B3-006008059382}"
	static InfoData := [ "DisplayName", "Version", "Publisher", "ProductID", "RegisteredOwner", "RegisteredCompany", "Language"
						, "SupportUrl", "SupportTelephone", "HelpLink", "InstallLocation", "InstallSource", "InstallDate"
						, "Contact", "Comments", "Image", "ReadmeUrl", "UpdateInfoUrl" ]

	InstalledApps := Map()
	EnumInstalledApps := ComObject(CLSID_EnumInstalledApps, IID_IEnumInstalledApps)
	while !(ComCall(3, EnumInstalledApps, "ptr*", &IShellApp := 0, "uint"))
	{
		AppInfoData := Buffer(8 + (A_PtrSize * 18), 0)
		NumPut("uint", AppInfoData.size, AppInfoData, 0)
		NumPut("uint", 0x0EDFFF, AppInfoData, 4)
		if !(ComCall(3, IShellApp, "ptr", AppInfoData))
		{
			InstalledApp := Map()
			Offset := 8 - A_PtrSize
			for each, Info in InfoData
				InstalledApp[Info] := (addr := NumGet(AppInfoData, Offset += A_PtrSize, "uptr")) ? StrGet(addr, "utf-16") : ""
			InstalledApps[A_Index] := InstalledApp
		}
		ObjRelease(IShellApp)
	}
	return InstalledApps
}

; ===========================================================================================================================================================================

Apps := EnumInstalledApps()
for i, v in Apps {
	output := ""
	for k, v in Apps[i]
		output .= k ": " v "`n"
	MsgBox(output)
}
