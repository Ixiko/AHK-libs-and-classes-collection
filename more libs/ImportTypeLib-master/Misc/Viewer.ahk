#NoEnv
#KeyHistory 0
#SingleInstance force
ListLines Off
SetBatchLines -1

#include ..\
#include ImportTypeLib.ahk

libFile := ""

Menu ViewMenu, Add, Open registry, openRegLibs
Menu ViewMenu, Add, Open Folder, openFolderLibs
Menu ViewMenu, Add, Open file, openFileLibs
Menu ViewMenu, Add, Copy selected row, CopySelected

Menu GuiMenu, Add, View, :ViewMenu

Gui view: Menu, GuiMenu
Gui view: +Resize
Gui view: Add, Listview, vLVr x0 y0 w800 h600, Name|Description|GUID/Path|Version

gosub UpdateLibs

Gui Show, w800 h600, Type Library Viewer
return

viewGuiClose:
	ExitApp
return

viewGuiSize:
GuiControl view:Move, LVr, w%A_GuiWidth% h%A_GuiHeight%
return

openFolderLibs:
	FileSelectFolder libFile, C:\, 2, Select the folder holding the type libraries
	if !ErrorLevel
		gosub UpdateLibs
return

openFileLibs:
	FileSelectFile libFile, 3, C:\, Select the file holding the type library, Type Libraries (*.dll; *.olb; *.exe; *.tlb)
	if !ErrorLevel
		gosub UpdateLibs
return

openRegLibs:
	libFile := ""
	gosub UpdateLibs
return

UpdateLibs:
	SplashTextOn, 400, 50, Type Library Viewer, Loading type libraries...
	Gui view: Default
	LV_Delete()

	if (!libFile)
	{
		libs := LoadLibsFromReg()
	}
	else
	{
		if (InStr(FileExist(libFile), "D"))
			libs := LoadLibsFromFolder(libFile)
		else
			libs := LoadLibsFromFile(libFile)
	}

	for each, lib in libs
		LV_Add("", lib.Name, lib.Doc, lib.GUID ? lib.GUID : lib.Path, lib.Version)

	Loop 4
		LV_ModifyCol(A_Index, "AutoHdr")
	LV_ModifyCol(1, "Sort")

	SplashTextOff
return

CopySelected:
	row := LV_GetNext(1, "F")
	Loop % LV_GetCount("Col")
	{
		LV_GetText(header, 0, A_Index)
		LV_GetText(field, row, A_Index)
		text .= header " = " field "|"
	}
	text := RTrim(text, "|")
	Clipboard := text
return

LoadLibsFromReg()
{
	libs := {}
	Loop, HKCR, TypeLib, 2
	{
		Loop HKCR, TypeLib\%A_LoopRegName%, 2
		{
			version := A_LoopRegName
		}
		StringSplit version, version, .
		hr := ITL_GUID_FromString(A_LoopRegName, guid)
		if (ITL_FAILED(hr))
		{
			MsgBox % ITL_FormatError(hr)
			continue
		}
		hr := DllCall("OleAut32\LoadRegTypeLib", "Ptr", &guid, "UShort", version1, "UShort", version2, "UInt", 0, "Ptr*", lib)
		if (ITL_FAILED(hr))
		{
			;MsgBox % ITL_FormatError(hr)
			continue
		}
		StringUpper, guid, A_LoopRegName
		obj := CreateInfoObject(lib), obj["GUID"] := guid, obj["Version"] := version
		libs.Insert(obj)
		ObjRelease(lib)
	}
	return libs
}

LoadLibsFromFolder(folder)
{
	local libs := [], ext := "", each := 0, obj := ""

	Loop %folder%\*.*,0,1
	{
		SplitPath, A_LoopFileLongPath, , , ext
		if ext not in exe,dll,old,tlb
			continue

		for each, obj in LoadLibsFromFile(A_LoopFileLongPath)
			libs.Insert(obj)
	}
	return libs
}

LoadLibsFromFile(file)
{
	static proc := RegisterCallback("ResourceEnumCallback")
	local libs := [], ext := "", hr := 0x00, obj := "", lib := 0, module := 0, currentLibs := "", each := 0, resource := ""

	SplitPath, file, , , ext
	if ext not in exe,dll,old,tlb
		return

	if (ext = "tlb")
	{
		hr := LoadTypeLib(file, lib)
		if (ITL_FAILED(hr))
		{
			return
		}

		obj := CreateInfoObject(lib), obj["Path"] := file
		libs.Insert(obj)
		ObjRelease(lib)
	}
	else
	{
		currentLibs := []

		module := DllCall("LoadLibrary", "Str", file, "Ptr")
		DllCall("EnumResourceNames", "Ptr", module, "Str", "TYPELIB", "Ptr", proc, "Ptr", Object(currentLibs))

		for each, resource in currentLibs
		{
			hr := LoadTypeLib(file "\" resource, lib)
			if (ITL_FAILED(hr))
			{
				continue
			}
			obj := CreateInfoObject(lib), obj["Path"] := file "\" resource
			libs.Insert(obj)
			ObjRelease(lib), currentLibs[lib] := 0
		}

		DllCall("FreeLibrary", "Ptr", module)
	}
	return libs
}

LoadTypeLib(file, byRef lib)
{
	return DllCall("OleAut32\LoadTypeLib", "Str", file, "Ptr*", lib, "Int")
}

ResourceEnumCallback(module, type, name, custom)
{
	currentLibs := Object(custom)
	currentLibs.Insert(name)
	return true
}

CreateInfoObject(lib)
{
	hr := DllCall(NumGet(NumGet(lib+0), 09*A_PtrSize, "Ptr"), "Ptr", lib, "Int", -1, "Ptr*", pName, "Ptr*", pDoc, "UInt*", 0, "Ptr", 0, "Int")
	if (ITL_FAILED(hr))
	{
		MsgBox % ITL_FormatError(hr)
		return
	}
	return { "Name": StrGet(pName), "Doc" : StrGet(pDoc) }
}