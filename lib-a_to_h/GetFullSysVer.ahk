; © Drugwash, Dec 2016-July 2017 v1.1
;================================================================
GetFullSysVer(ByRef osfn, ByRef cos, ByRef kver)
;================================================================
{
Global Ptr, AW, A_CharSize, w9x
Static vernames = "95 RTM|95 OSR1/SP1|95 OSR2|95 OSR2 USB|95 OSR2.1|95 OSR2.5|98 Gold|98 Second Edition|Millennium"
Static versions = "4.00.950,4.00.951-4.00.1110,4.00.1111-4.00.9999,4.03.1212-4.03.1213
	,4.03.1214-4.03.1215,4.03.1216-4.03.9999,4.10.1998-4.10.2221,4.10.2222-4.10.9999
	,4.90.3000-4.90.9999"

VarSetCapacity(sp, 260*A_CharSize, 0)	; MAX_PATH size
DllCall((w9x ? "SHFolder" : "shell32") "\SHGetFolderPath" AW		; Win98SE+
	, Ptr, 0		; hwndOwner
	, "UInt", 0x25	; nFolder
	, Ptr, 0		; hToken
	, "UInt", 0	; dwFlags (SHGFP_TYPE_CURRENT=0, SHGFP_TYPE_DEFAULT=1)
	, Ptr, &sp)	; pszPath
VarSetCapacity(sp, -1)
if !sp
	{
	VarSetCapacity(sp, sz := DllCall("GetSystemDirectory" AW, Ptr, &sp, "UInt", 0)*A_CharSize, 0)
	DllCall("GetSystemDirectory" AW, Ptr, &sp, "UInt", sz)			; Win95+
	VarSetCapacity(sp, -1)
	}
kver := FileGetVersionInfo(sp "\kernel32.dll", "FileVersion")			; Get real kernel version

off := 128*A_CharSize
sz := 28+off
VarSetCapacity(OVIX, sz, 0)		; OSVERSIONINFOEX struct
NumPut(sz, OVIX, 0, "UInt")
if !DllCall("GetVersionEx" AW, Ptr, &OVIX, "UInt")
	{
	sz := 20+off
	VarSetCapacity(OVIX, sz, 0)	; OSVERSIONINFO struct (for Win95)
	NumPut(sz, OVIX, 0, "UInt")
	if !DllCall("GetVersionEx" AW, Ptr, &OVIX, "UInt")
		return
	}
d2 := NumGet(OVIX, 4, "UInt")
d3 := NumGet(OVIX, 8, "UInt")
d4 := NumGet(OVIX, 12, "UInt") & 0xFFFF
VarSetCapacity(d6, off, 0)
DllCall("lstrcpyn" AW, Ptr, &d6, Ptr, &OVIX + 20, "UInt", 128)
VarSetCapacity(d6, -1)
d6=%d6%
cos := d2 "." d3 "." d4 " " d6									; Get current system version

Loop, Parse, versions, CSV
	{
	osv2=
	StringSplit, osv, A_LoopField, -
	osv2 := osv2 ? osv2 : osv1
	if kver between %osv1% and %osv2%					; Check if kernel version fits certain limits
		cosv := A_Index, break
	}
if nt := A_OSType="WIN32_NT" OR kver > "4.99.0" ? " NT" : ""
	RegRead, osfn, HKLM, Software\Microsoft\Windows%nt%\CurrentVersion, ProductName
else Loop, Parse, vernames, |
	if (A_Index=cosv)
		osfn := "Microsoft Windows " A_LoopField, break
StringReplace, osfn, osfn, Microsoft, Microsoft®
StringReplace, osfn, osfn, Windows, Windows®
; Test if system is Millenium or lower and not in compatibility mode
return OSTest("ME", "EL") && (kver < "5.0.0")
}
;================================================================
#include *i func_GetFileVersionInfo.ahk
#include func_OSTest.ahk
