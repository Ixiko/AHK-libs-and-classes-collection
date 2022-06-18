; ============================================================
; UrlUnescape() -> https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-urlunescapea
; URL_DONT_UNESCAPE_EXTRA_INFO = 0x02000000
; URL_UNESCAPE_AS_UTF8 = 0x00040000 (Win 8+)
; URL_UNESCAPE_INPLACE = 0x00100000
; ============================================================
UrlUnescape(Url, Flags := 0x00100000) {
	Return !DllCall("Shlwapi.dll\UrlUnescape", "Ptr", &Url, "Ptr", 0, "UInt", 0, "UInt", Flags, "UInt") ? Url : ""
}