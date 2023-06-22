#Requires AutoHotkey v2-b+

FileEncoding "UTF-8-RAW"


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