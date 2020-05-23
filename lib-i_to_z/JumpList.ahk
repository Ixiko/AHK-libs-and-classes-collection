; ---------------------------------- constants -----------------------------------
; Property identifiers
Global PKEY_AppUserModel_ID
Global PKEY_AppUserModel_IsDestListSeparator
Global PKEY_Title
DEFINE_PROPERTYKEY(PKEY_AppUserModel_ID,"{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}",5)
DEFINE_PROPERTYKEY(PKEY_AppUserModel_IsDestListSeparator,"{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}",6)
DEFINE_PROPERTYKEY(PKEY_Title,"{F29F85E0-4FF9-1068-AB91-08002B27B3D9}",2)

; GUID identifiers
Global CLSID_DestinationList
Global CLSID_EnumerableObjectCollection
Global CLSID_ShellLink
Global IID_ICustomDestinationList
Global IID_IShellLinkW
Global IID_IPersist
Global IID_IPersistFile
Global IID_IObjectCollection
Global IID_IObjectArray
Global IID_IPropertyStore
DEFINE_GUID(CLSID_DestinationList,"{77f10cf0-3db5-4966-b520-b7c54fd35ed6}")
DEFINE_GUID(CLSID_EnumerableObjectCollection,"{2d3468c1-36a7-43b6-ac24-d3f02fd9607a}")
DEFINE_GUID(CLSID_ShellLink,"{00021401-0000-0000-C000-000000000046}")
DEFINE_GUID(IID_ICustomDestinationList,"{6332debf-87b5-4670-90c0-5e57b408a49e}")
DEFINE_GUID(IID_IShellLinkW,"{000214F9-0000-0000-C000-000000000046}")
DEFINE_GUID(IID_IPersist,"{0000010c-0000-0000-C000-000000000046}")
DEFINE_GUID(IID_IPersistFile,"{0000010b-0000-0000-C000-000000000046}")
DEFINE_GUID(IID_IObjectCollection,"{5632b1a4-e38a-400a-928a-d4cd63230295}")
DEFINE_GUID(IID_IObjectArray,"{92CA9DCD-5622-4bba-A805-5E9F541BD8C9}")
DEFINE_GUID(IID_IPropertyStore,"{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}")

; --------------------------------------------------   library functions ----------------------------------------------------------------------------------
DEFINE_PROPERTYKEY(byref PropertyKeyStruct, byref fmtid, byref propertyid)
{
	VarSetCapacity(PropertyKeyStruct, 20)
	 DllCall("ole32.dll\CLSIDFromString", "str", fmtid, "ptr", &PropertyKeyStruct)
	NumPut(propertyid, PropertyKeyStruct, 16, "int") 	 
}

DEFINE_GUID(byref GUIDStruct,byref idstring)
{
	VarSetCapacity(GUIDStruct, 16)
	 DllCall("ole32.dll\CLSIDFromString", "str", idstring, "ptr", &GUIDStruct)	
}

InitVariantFromString(string, byref variant)
{
	VarSetCapacity(variant, 8+2*A_PtrSize)
	NumPut(31,variant,0,"short") 		; VT_LPWSTR
	hr := DllCall("Shlwapi\SHStrDupW", ptr, &string, ptrp, tempptr)
	NumPut(tempptr, variant, 8, "ptr")
}

InitVariantFromBoolean(bool, byref variant)
{
	VarSetCapacity(variant, 8+2*A_PtrSize)
	NumPut(11,variant,0,"short") 		; VT_BOOL
	NumPut(bool, variant, 8, "int")
}

; --------------------------------------------------   class definitions ----------------------------------------------------------------------------------
 class ShellLink 
{	
	__new()
	{
		hr := DllCall("ole32\CoCreateInstance", ptr, &CLSID_ShellLink, ptr, 0, uint, 1, ptr, &IID_IShellLinkW, ptrp, tempptr)
		this.pShellLinkW := tempptr
		this.QueryInterface(IID_IPersistFile, tempptr)
		this.pPersistFile := tempptr
		this.QueryInterface(IID_IPropertyStore, tempptr)
		this.pPropertyStore := tempptr
	}
	; IPersist
	GetClassID(byRef pClassID)
	{
			VarSetCapacity(guid, 16)
			return DllCall(NumGet( NumGet(this.pPersistFile+0, "ptr"), 3*A_PtrSize, "ptr"), ptr, this.pPersistFile, ptr, &guid)			
	}
	; IPersistFile
	IsDirty()
	{
			return DllCall(NumGet( NumGet(this.pPersistFile+0, "ptr"), 4*A_PtrSize, "ptr"), ptr, this.pPersistFile)
	}
	Load(byref Filename, byref Mode)
	{
			return DllCall(NumGet( NumGet(this.pPersistFile+0, "ptr"), 5*A_PtrSize, "ptr"), ptr, this.pPersistFile, str, FileName, int, Mode, int)
	}
	Save(byref Filename, byref fRemember)
	{
			return DllCall(NumGet( NumGet(this.pPersistFile+0, "ptr"), 6*A_PtrSize, "ptr"), ptr, this.pPersistFile, str, FileName, int, fRemember, int)
	}
	SaveCompleted(byref Filename)
	{
			return DllCall(NumGet( NumGet(this.pPersistFile+0, "ptr"), 7*A_PtrSize, "ptr"), ptr, this.pPersistFile, str, FileName, int)
	}
	GetCurFile(byref Filename)
	{
			return DllCall(NumGet( NumGet(this.pPersistFile+0, "ptr"), 8*A_PtrSize, "ptr"), ptr, this.pPersistFile, ptrp, pFileName, int)
			Filename := StrGet(pFileName)
	}
	; IShellLink
	QueryInterface(byref riid, byref pinterface)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 0*A_PtrSize, "ptr"), ptr, this.pShellLinkW, ptr, &riid, ptrp, pinterface)
	}	
	AddRef()
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 1*A_PtrSize, "ptr"), ptr, this.pShellLinkW)
	}	
	Release()
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 2*A_PtrSize, "ptr"), ptr, this.pShellLinkW)
	}	
	GetPath(byref File, byref pFD, byref fFlags )
	{
			VarSetCapacity(File, 1024)
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 3*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, File, int, 1024, ptr, pfd, int, fFlags)
	}	
	GetIDList(byref pPIDL)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 4*A_PtrSize, "ptr"), ptr, this.pShellLinkW, ptrp, pPIDL)
	}
	SetIDList(byref pPIDL)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 5*A_PtrSize, "ptr"), ptr, this.pShellLinkW, ptrp, pPIDL)
	}
	GetDescription(byref Name)
	{
			VarSetCapacity(Name, 1024)
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 6*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, Name, int, 1024)
	}
	SetDescription(byref Name)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 7*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, Name)
	}
	GetWorkingDirectory(byref Dir)
	{
			VarSetCapacity(Dir, 1024)
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 8*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, Dir, int, 1024)
	}
	SetWorkingDirectory(byref Dir)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 9*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, Dir)
	}
	GetArguments(byref Arg)
	{
			VarSetCapacity(Args, 1024)
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 10*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, Args, int, 1024)
	}
	SetArguments(byref Args)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 11*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, Args)
	}
	GetHotkey(byref Hotkey)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 12*A_PtrSize, "ptr"), ptr, this.pShellLinkW, shortp, Hotkey)
	}
	SetHotkey(byref Hotkey)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 13*A_PtrSize, "ptr"), ptr, this.pShellLinkW, short, Hotkey)
	}
	GetShowCmd(byref iShowCmd)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 14*A_PtrSize, "ptr"), ptr, this.pShellLinkW, intp, iShowCmd)
	}
	SetShowCmd(byref iShowCmd)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 15*A_PtrSize, "ptr"), ptr, this.pShellLinkW, int, iShowCmd)
	}
	GetIconLocation(byref IconPath, byref iIcon)
	{
			VarSetCapacity(IconPath, 1024)
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 16*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, IconPath, int, 1024, intp, iIcon)
	}
	SetIconLocation(byref IconPath, byref iIcon)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 17*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, IconPath, int, iIcon)
	}
	SetRelativePath(byref PathRel)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 18*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, PathRel, int, 0)
	}
	Resolve(byref hwnd, byref fflags)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 19*A_PtrSize, "ptr"), ptr, hwnd, int, fflags)
	}
	SetPath(byref File)
	{
			return DllCall(NumGet( NumGet(this.pShellLinkW+0, "ptr"), 20*A_PtrSize, "ptr"), ptr, this.pShellLinkW, str, File)
	}	
	; IPropertyStore
	GetCount(byref cProps)
	{
			return DllCall(NumGet( NumGet(this.pPropertyStore+0, "ptr"), 3*A_PtrSize, "ptr"), ptr, this.pPropertyStore, intp, cProps)
	}	
	GetAt(byref iProp, byref PROPERTYKEY)
	{
			VarSetCapacity(PROPERTYKEY, 20)	
			return DllCall(NumGet( NumGet(this.pPropertyStore+0, "ptr"), 4*A_PtrSize, "ptr"), ptr, this.pPropertyStore, int, iProp, ptr, &PROPERTYKEY)
	}	
	GetValue(byref PROPERTYKEY, byref PROPVARIANT)
	{
			VarSetCapacity(PROPVARIANT, 8+2*A_PtrSize)  
			return DllCall(NumGet( NumGet(this.pPropertyStore+0, "ptr"), 5*A_PtrSize, "ptr"), ptr, this.pPropertyStore, ptr, &PROPERTYKEY, ptr, &PROPVARIANT)
	}	
	SetValue(byref pkey, byref pvariant)
	{
			return DllCall(NumGet( NumGet(this.pPropertyStore+0, "ptr"), 6*A_PtrSize, "ptr"), ptr, this.pPropertyStore, ptr, &pkey, ptr, &pvariant)
	}	
	Commit()
	{
			return DllCall(NumGet( NumGet(this.pPropertyStore+0, "ptr"), 7*A_PtrSize, "ptr"), ptr, this.pPropertyStore)
	}	
}   

class DestinationList
{
	__new()
	{
		hr := DllCall("ole32\CoCreateInstance", ptr, &CLSID_DestinationList, ptr, 0, uint, 1, ptr, &IID_ICustomDestinationList, ptrp, tempptr)
		this.pCustomDestinationList := tempptr
	}
	SetAppID(byref szAppID)
	{	
			return DllCall(NumGet(NumGet(this.pCustomDestinationList+0, "ptr"), 3*A_PtrSize, "ptr"), ptr, this.pCustomDestinationList, str, szAppID)
	}
	BeginList(byref MinSlots, byref pObjectArray)
	{
			return DllCall(NumGet(NumGet(this.pCustomDestinationList+0, "ptr"), 4*A_PtrSize, "ptr"), ptr, this.pCustomDestinationList, uintp, MinSlots, ptr, &IID_IObjectArray, ptrp, pObjectArray)
	}
	AppendCategory(byref szCategory, byref pObjectArray)
	{ 
			return DllCall(NumGet(NumGet(this.pCustomDestinationList+0, "ptr"), 5*A_PtrSize, "ptr"), ptr, this.pCustomDestinationList, str, szCategory, ptr, pObjectArray)
	}	
	AppendKnownCategory(byref intKnownCategory)
	{
			return DllCall(NumGet(NumGet(this.pCustomDestinationList+0, "ptr"), 6*A_PtrSize, "ptr"), ptr, this.pCustomDestinationList, int, intKnownCategory)
	}		
	AddUserTasks(byref pObjectArray)
	{  
			return DllCall(NumGet(NumGet(this.pCustomDestinationList+0, "ptr"), 7*A_PtrSize, "ptr"), ptr, this.pCustomDestinationList, ptr, pObjectArray)
	}	
	CommitList()
	{
			return DllCall(NumGet(NumGet(this.pCustomDestinationList+0, "ptr"), 8*A_PtrSize, "ptr"), ptr, this.pCustomDestinationList)
	}	
	GetRemovedDestinations(byref pObjectArray)
	{  
			return DllCall(NumGet(NumGet(this.pCustomDestinationList+0, "ptr"), 9*A_PtrSize, "ptr"), ptr, this.pCustomDestinationList, ptr, &IID_IObjectArray, ptrp, pObjectArray)
	}
	DeleteList(byref szAppID)
	{
			return DllCall(NumGet(NumGet(this.pCustomDestinationList+0, "ptr"), 10*A_PtrSize, "ptr"), ptr, this.pCustomDestinationList, str, szAppID)
	}
	AbortList()
	{ 
			return DllCall(NumGet(NumGet(this.pCustomDestinationList+0, "ptr"), 11*A_PtrSize, "ptr"), ptr, this.pCustomDestinationList)
	}
}

class EnumerableObjectCollection
{
	__new()
	{
		DllCall("ole32\CoCreateInstance", ptr, &CLSID_EnumerableObjectCollection, ptr, 0, uint, 1, ptr, &IID_IObjectCollection, ptrp, tempptr)
		this.pObjectCollection := tempptr
	}
	; IObjectArray
	QueryInterface(byref IID, byref pobject)
	{	
		return DllCall(NumGet(NumGet(this.pObjectCollection+0, "ptr"),0*A_PtrSize, "ptr"), ptr, this.pObjectCollection, ptr, &IID, ptrp, pobject)
	}	
	GetCount(byref cObjects)
	{	
		DllCall(NumGet(NumGet(this.pObjectCollection+0, "ptr"),3*A_PtrSize, "ptr"), ptr, this.pObjectCollection, uintp, cObjects)
	}	
    GetAt(byref Index, byref pVoid)
	{	
		 DllCall(NumGet(NumGet(this.pObjectCollection+0, "ptr"),4*A_PtrSize, "ptr"), ptr, this.pObjectCollection, uint, Index, ptr, pVoid)
	}	 
	; IObjectCollection
    AddObject(byref pUnknown)
	{	
		 return DllCall(NumGet(NumGet(this.pObjectCollection+0, "ptr"),5*A_PtrSize, "ptr"), ptr, this.pObjectCollection, ptr, pUnknown)
	}
    AddFromArray(byref pObjectArray)
	{	
		 DllCall(NumGet(NumGet(this.pObjectCollection+0, "ptr"),6*A_PtrSize, "ptr"), ptr, this.pObjectCollection, ptr, pObjectArray)
	}
    RemoveObjectAt(byref uiIndex)
	{	
		 DllCall(NumGet(NumGet(this.pObjectCollection+0, "ptr"),7*A_PtrSize, "ptr"), ptr, this.pObjectCollection, ptr, &uiIndex)
	}
    Clear()
	{	
		 DllCall(NumGet(NumGet(this.pObjectCollection+0, "ptr"),8*A_PtrSize, "ptr"), ptr, this.pObjectCollection)
	}
 }
