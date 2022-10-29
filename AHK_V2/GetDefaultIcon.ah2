#Requires Autohotkey v2.0-beta.7
/**
* Function: GetDefaultIcon(fExt [, getHandle])
* https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-assocquerystringw
*
* Based on a specific use case of the AssocQueryString function.
*
* Searches for and retrieves the default icon for a provided extension and returns
* a handle to the icon to be used in a picture control or the string to the associated icon path.
*
* Params:
* fExt      - File extension to work on with optional `.` in front e.g.: ahk or .ahk
* getHandle - instruct the function to either return the handle to a resource or
*             the string to the default executable file
*
* Returns:
* - A Handle to an icon resource (Default)
* - A string to the default executable and icon number for the extension
*
* Examples:
* ---ahk
	MsgBox GetDefaultIcon("ahk")
	MsgBox GetDefaultIcon(".ahk")
* ---
*
* ---ahk
	for ext in ["ahk", ".html", ".bat", "vbs", ".dll"]
		strings .= GetDefaultIcon(ext, false) '`n'

	MsgBox strings
* ---
*/ ; by RaptorX

GetDefaultIcon(fExt, getHandle:=true) {
	static ASSOCSTR_DEFAULTICON := 15

	fExt := RegExReplace(fExt, "^\.?(.*)$", ".$1")

	DllCall "shlwapi.dll\AssocQueryString",
		"int", false,                      ; [in]            ASSOCF   flags,
		"int", ASSOCSTR_DEFAULTICON,       ; [in]            ASSOCSTR str,
		"str", fExt,                       ; [in]            LPCSTR   pszAssoc,
		"int", false,                      ; [in, optional]  LPCSTR   pszExtra,
		"ptr", StrOut:=Buffer(65000),      ; [out, optional] LPSTR    pszOut,
		"ptr*", &length:=StrOut.size // 2, ; [in, out]       DWORD    *pcchOut
		"HRESULT"

	try
	{
		app := StrSplit(assocStr:=StrGet(StrOut), ",")
		regKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\." fExt "\UserChoice"

		if (!hIcon := LoadPicture(app[1], "Icon" app.Has(2) ? app[2] : "", &imgType))
		&& (progID := RegRead(regKey,"progID", false))
		&& (icon   := RegRead("HKCR\" progID "\DefaultIcon"))
		{
			RegExMatch(icon, "(?<app>.*?),?(?<index>\d+)?$", &matched)
			hIcon := LoadPicture(matched.app, "Icon" matched.index, &imgType)
		}
	}

	return getHandle ? (hIcon?? LoadPicture("C:\Windows\system32\shell32.dll", "Icon291", &imgType)) : assocStr
}
