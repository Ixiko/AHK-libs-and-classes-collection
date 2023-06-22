Skip to content
Product
Solutions
Open Source
Pricing
Search
Sign in
Sign up
fincs
/
SciTE4AutoHotkey
Public
Code
Issues
11
Pull requests
2
Security
Insights
SciTE4AutoHotkey/installer/BuildInstaller.ahk
@fincs
fincs Installer: Minor/major overhaul, see details:
…
Latest commit aff58d6 on May 11, 2022
 History
 1 contributor
356 lines (284 sloc)  10.3 KB


#Requires AutoHotkey v2-b+

FileEncoding "UTF-8-RAW"

; Path to source data
g_BaselinePath := A_ScriptDir "\..\..\S4AHK_Test\source"

for f in ["7z.exe", "7zSD.sfx"]
	if not FileExist(f)
		throw Error("Missing file in installer folder",, f)

for f in ["SciTE.exe", "Scintilla.dll", "lexilla.dll", "InternalAHK.exe", "SciTE.chm"]
	if not FileExist(g_BaselinePath "\" f)
		throw Error("Missing file in SciTE folder",, f)

g_S4AHKVersion := ParseVersion(FileGetVersion(g_BaselinePath "\SciTE.exe"))
g_InstallerExe := 'SciTE4AHK_v' g_S4AHKVersion.AsStr '_Install.exe'
g_PortableZip  := 'SciTE4AHK_v' g_S4AHKVersion.AsStr '_Portable.zip'

SplitPath A_AhkPath,, &ahk2Dir
ahk2exe := ahk2Dir "\..\Compiler\Ahk2Exe.exe"

if not FileExist(ahk2exe)
	throw Error("Missing Ahk2Exe")

try FileDelete "~compile.exe"
RunWait Format('"{}" /in setup.ahk /out ~compile.exe', ahk2exe)

if not hModule := DllCall("LoadLibraryEx", "str", "~compile.exe", "ptr", 0, "ptr", 2, "ptr")
	throw Error("LoadLibraryEx")

hRsrc := DllCall("FindResource", "ptr", hModule, "str", ">AUTOHOTKEY SCRIPT<", "ptr", 10, "ptr")
hMem := DllCall("LoadResource", "ptr", hModule, "ptr", hRsrc, "ptr")
setupScript := StrGet(DllCall("LockResource", "ptr", hMem, "ptr"), DllCall("SizeofResource", "ptr", hModule, "ptr", hRsrc, "uint"), "UTF-8")
DllCall("FreeLibrary", "ptr", hModule)
FileDelete "~compile.exe"

if not hModule := DllCall("LoadLibraryEx", "str", "7zSD.sfx", "ptr", 0, "ptr", 2, "ptr")
	throw Error("LoadLibraryEx")

hRsrc := DllCall("FindResource", "ptr", hModule, "ptr", 1, "ptr", 16, "ptr") ; Version Info\1
hMem := DllCall("LoadResource", "ptr", hModule, "ptr", hRsrc, "ptr")
memSize := DllCall("SizeofResource", "ptr", hModule, "ptr", hRsrc, "uint")
pVerRes := DllCall("LockResource", "ptr", hMem, "ptr")
verInfo := VersionNode(pVerRes)
DllCall("FreeLibrary", "ptr", hModule)

desiredVerText := {
	CompanyName:      'fincs',
	FileDescription:  'SciTE4AutoHotkey Installer',
	FileVersion:      g_S4AHKVersion.AsStr,
	InternalName:     g_InstallerExe,
	LegalCopyright:   'Copyright (c) 2007-' A_Year ' fincs',
	OriginalFilename: g_InstallerExe,
	ProductName:      'SciTE4AutoHotkey Installer',
	ProductVersion:   g_S4AHKVersion.AsStr,
}

stringFileInfo := verInfo['StringFileInfo']['040904b0']
for key, value in desiredVerText.OwnProps()
	stringFileInfo[key].Value := value

NumPut(
	"UInt", g_S4AHKVersion.Hi, "UInt", g_S4AHKVersion.Lo,
	"UInt", g_S4AHKVersion.Hi, "UInt", g_S4AHKVersion.Lo,
	verInfo.Value, 8
)

/*
bah := ""
for key, node in verStrings {
	bah .= Format("{} = {}`n", key, node.Value)
}
MsgBox bah
*/

FileCopy "7zSD.sfx", "~temp.bin", 1

if not hModule := DllCall("BeginUpdateResource", "str", "~temp.bin", "uint", 0, "ptr")
	throw Error("BeginUpdateResource")

AddOrReplaceIconGroup hModule, "install.ico", "~temp.bin", 1

verInfo := verInfo.Serialize()
if not DllCall("UpdateResource", "ptr", hModule, "ptr", 16, "ptr", 1, "ushort", 0x409, "ptr", verInfo, "uint", verInfo.Size, "uint")
	throw Error("UpdateResource")

manifest := FileRead("install.manifest", "RAW")
if not DllCall("UpdateResource", "ptr", hModule, "ptr", 24, "ptr", 1, "ushort", 0x409, "ptr", manifest, "uint", manifest.Size, "uint")
	throw Error("UpdateResource")

if not DllCall("EndUpdateResource", "ptr", hModule, "uint", 0)
	throw Error("EndUpdateResource")

;-----------

; Create S4AHK install "medium"
try DirDelete "$TEMP", 1
DirCreate "$TEMP"
DirCopy g_BaselinePath, "$TEMP\$DATA"
Loop Files "$TEMP\$DATA\*.*", "FDR" {
	if SubStr(A_LoopFileName, 1, 1) == '.' or A_LoopFileAttrib ~= "[HS]" {
		if InStr(A_LoopFileAttrib, "D")
			DirDelete A_LoopFileFullPath, 1
		else
			FileDelete A_LoopFileFullPath
	}
}
FileAppend setupScript,  "$TEMP\$DATA\$SETUP"
FileCopy "dialog.html", "$TEMP\dialog.html"
FileCopy "banner.png",  "$TEMP\banner.png"
RunWait "7z.exe a package.7z $DATA banner.png dialog.html -m0=BCJ2 -m1=LZMA:d25:fb255 -m2=LZMA:d19 -m3=LZMA:d19 -mb0:1 -mb0s1:2 -mb0s2:3 -mx", "$TEMP"

;--------------

; Create S4AHK Portable
DirMove "$TEMP\$DATA", "$TEMP\SciTE"
DirMove "$TEMP\SciTE\newuser", "$TEMP\SciTE\user"
FileDelete "$TEMP\SciTE\$SETUP"

heading := "SciTE4AutoHotkey v" g_S4AHKVersion.AsStr " Portable Edition"
lines := ""
Loop StrLen(heading)
	lines .= "="

FileAppend heading "`n" lines "`n`n
(
Thank you for downloading SciTE4AutoHotkey.
Supported platforms: Windows Vista, 7, 8, 8.1, 10, 11

AutoHotkey v1.1+ (and optionally AutoHotkey v2) is required.

Installation: unpack this archive to your AutoHotkey folder so that you have:

AutoHotkey
|_______ AutoHotkey.exe
|_______ AutoHotkeyA32.exe
|_______ AutoHotkeyU32.exe
|_______ AutoHotkeyU64.exe
|_______ AutoHotkey.chm
|_______ v2
|        |_______ AutoHotkey32.exe
|        |_______ AutoHotkey64.exe
|        |_______ AutoHotkey.chm
|_______ SciTE
         |______ etc...
)", "$TEMP\ReadMe.txt", "`n"
RunWait "7z.exe a -tzip package.zip SciTE ReadMe.txt", "$TEMP"
FileMove "$TEMP\package.zip", g_PortableZip, 1

;---------------

installConfig := "
(
;!@Install@!UTF-8!
RunProgram="$DATA\InternalAHK.exe /CP65001 $DATA\$SETUP"
;!@InstallEnd@!
)"
fo := FileOpen("~temp.bin", "a", "UTF-8-RAW")
fo.Write(installConfig)
fo.RawWrite(FileRead("$TEMP\package.7z", "RAW"))
fo := ""

FileMove "~temp.bin", g_InstallerExe, 1

try DirDelete "$TEMP", 1

MsgBox "The following files were created successfully:`n`n" g_InstallerExe "`n" g_PortableZip,, "Iconi"

ParseVersion(rawStr) {
	parts := StrSplit(rawStr, '.')
	major := Integer(parts[1])
	minor := Integer(parts[2])
	patch := Integer(parts[3])
	return {
		AsStr: Format("{}.{}.{}", major, minor, patch),
		Hi: (major << 16) | minor,
		Lo: (patch << 16),
	}
}

class VersionNode {
	Children := []
	ChildrenMap := Map()

	__New(ptr := unset) {
		if !IsSet(ptr) {
			this.Key := ""
			this.Value := ""
		}

		wLength := NumGet(ptr, 0, "UShort")
		wValueLength := NumGet(ptr, 2, "UShort")
		wType := NumGet(ptr, 4, "UShort")
		this.Key := szKey := StrGet(ptr+6)
		valuePos := ptr+6+2*(StrLen(szKey)+1)
		valuePos := (valuePos + 3) &~ 3
		childPos := valuePos + (wType+1) * wValueLength
		childPos := (childPos + 3) &~ 3

		if wType == 0 {
			this.Value := Buffer(wValueLength)
			DllCall "msvcrt\memcpy", "ptr", this.Value, "ptr", valuePos, "ptr", wValueLength, "cdecl"
		} else {
			this.Value := StrGet(valuePos, wValueLength)
		}

		while childPos < ptr + wLength {
			childSize := NumGet(childPos, 0, "UShort")
			childSize := (childSize + 3) &~ 3
			this.Children.Push child := VersionNode(childPos)
			this.ChildrenMap[child.Key] := child
			childPos += childSize
		}
	}

	__Item[key] => this.ChildrenMap[key]
	__Enum(p*) => this.ChildrenMap.__Enum(p*)

	ValueSize {
		get {
			if this.Value is Buffer
				return this.Value.Size
			else {
				strSize := StrLen(this.Value)
				return strSize ? (strSize+1) : 0
			}
		}
	}

	SerializedSize {
		get {
			size := 6 + 2*(StrLen(this.Key)+1)
			size := (size + 3) &~ 3
			size += this.ValueSize * (1 + !(this.Value is Buffer))
			size := (size + 3) &~ 3

			for child in this.Children
				size += child.SerializedSize

			return size
		}
	}

	Serialize(ptr := unset) {
		wLength := this.SerializedSize
		if !IsSet(ptr)
			ptr := Buffer(wLength, 0)

		writePtr := NumPut("UShort", wLength, "UShort", wValueLength := this.ValueSize, "UShort", !(this.Value is Buffer), ptr)
		StrPut(this.Key, writePtr), writePtr += 2*(StrLen(this.Key)+1)
		writePtr := (writePtr + 3) &~ 3
		if this.Value is Buffer {
			DllCall "msvcrt\memcpy", "ptr", writePtr, "ptr", this.Value, "ptr", wValueLength, "cdecl"
			writePtr += wValueLength
		} else if wValueLength
			StrPut(this.Value, writePtr, wValueLength), writePtr += 2*wValueLength
		writePtr := (writePtr + 3) &~ 3

		for child in this.Children {
			child.Serialize writePtr
			writePtr += NumGet(writePtr, "UShort")
		}

		return ptr
	}
}

AddOrReplaceIconGroup(re, icoFile, exeFile, iconGroupID := unset) {
	if !IsSet(iconGroupID)
		throw Error("Not implemented")

	highestIconID := GetHighestIconID(exeFile)
	existingIconIDs := GetIconGroupIconIDs(exeFile, iconGroupID)

	f := FileOpen(icoFile, "r", "UTF-8-RAW")
	idReserved := f.ReadUShort()
	idType := f.ReadUShort()
	idCount := f.ReadUShort()
	if idReserved != 0 or idType != 1 or idCount == 0
		throw Error("Bad icon file",, icoFile)

	newIconGroup := Buffer(6 + idCount*14, 0)
	grpEntryPtr := NumPut("UShort", idReserved, "UShort", idType, "UShort", idCount, newIconGroup)

	; Read in every icon
	newIcons := Map()
	Loop idCount {
		if A_Index <= existingIconIDs.Length
			curIconID := existingIconIDs[A_Index]
		else
			curIconID := ++highestIconID

		f.RawRead(grpEntryPtr, 12)
		iconSize := NumGet(grpEntryPtr, 8, "UInt")
		grpEntryPtr := NumPut("UShort", curIconID, grpEntryPtr, 12)

		offset := f.ReadUInt()
		backup := f.Pos
		f.Pos := offset
		f.RawRead(newIcons[curIconID] := Buffer(iconSize))
		f.Pos := backup
	}

	f := ""

	; Delete all the existing icons for this group
	for id in existingIconIDs
		DllCall "UpdateResource", "ptr", re, "ptr", 3, "ptr", id, "ushort", 0x409, "ptr", 0, "uint", 0, "uint"

	; Add in all new images
	for iconID, iconData in newIcons
		DllCall "UpdateResource", "ptr", re, "ptr", 3, "ptr", iconID, "ushort", 0x409, "ptr", iconData, "uint", iconData.Size, "uint"

	; Replace icon group
	DllCall "UpdateResource", "ptr", re, "ptr", 14, "ptr", iconGroupID, "ushort", 0x409, "ptr", newIconGroup, "uint", newIconGroup.Size, "uint"
}

GetHighestIconID(exeFile) {
	enumResourceCallback(&var, hModule_, type_, name_, lParam_) {
		if name_ < 0x10000
			var := Max(var, name_)
		return 1
	}

	if not hModule := DllCall("LoadLibraryEx", "str", ExeFile, "ptr", 0, "ptr", 2, "ptr")
		throw Error("LoadLibraryEx")

	enumFunc := CallbackCreate(enumResourceCallback.Bind(&accum := 0), 'F', 4)
	DllCall "EnumResourceNames", "ptr", hModule, "ptr", 3, "ptr", enumFunc, "uint", 0
	CallbackFree enumFunc
	DllCall "FreeLibrary", "ptr", hModule

	return accum
}

GetIconGroupIconIDs(exeFile, iconGroupID) {
	if not hModule := DllCall("LoadLibraryEx", "str", ExeFile, "ptr", 0, "ptr", 2, "ptr")
		throw Error("LoadLibraryEx")

	hRsrc := DllCall("FindResource", "ptr", hModule, "ptr", iconGroupID, "ptr", 14, "ptr")
	hMem := DllCall("LoadResource", "ptr", hModule, "ptr", hRsrc, "ptr")
	pDirHeader := DllCall("LockResource", "ptr", hMem, "ptr")
	pResDir := pDirHeader + 6

	ret := []
	Loop NumGet(pDirHeader+4, "UShort") {
		pResDirEntry := pResDir + (A_Index-1)*14
		ret.Push NumGet(pResDirEntry+12, "UShort")
	}

	DllCall "FreeLibrary", "ptr", hModule
	return ret
}
Footer
© 2023 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
SciTE4AutoHotkey/installer/BuildInstaller.ahk at master · fincs/SciTE4AutoHotkey · GitHub