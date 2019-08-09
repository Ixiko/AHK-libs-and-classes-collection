/*
Title: __SetupapiLib (v0.0 August 18, 2014)

Introduction
------------

	'__SetupapiLib' contains 2 main functions, the 'ListDeviceInterfaces' and the
	'GetDeviceInterfaces'.
	
	The 'Device Name' can be chosen from the Windows Device Manager. This is either the	'Friendly Name' or
	the 'Device Description'. The 'Friendly Name' takes precedence over the 'Device Description'.
	
	The 'Device Instance ID' can be chosen from the Windows Device Manager.
	- Right-click on the 'Device Name' and select "Properties".
	- Click on the 'Detail' tab.
	  You should see the 'Device Instance ID'.
	
	The 'Hardware ID' can be chosen from the Windows Device Manager.
	- Right-click on the 'Device Name' and select "Properties".
	- Click on the 'Detail' tab and press the Down key, once.
	  You should see the 'Hardware IDs'. This is a multi-string value.
	  The script uses the first string (line) as the Hardware ID.
	
	'Device Name', 'Device Interface ID' and 'Hardware ID' can't be Copy/Paste. Then, you can use the
	'List Device Interfaces.ahk' script to produce a .txt file.
	
	The 'Identifier' is the 'Device Interface Class' which refers to the 'Device Interface Class GUID'.
	You can find a list of the 'Device Interface Classes' with their 'Device Interface Class GUID' in the
	'EnumDeviceInterfaceClasses' module, located in the 'Lib' folder.
	
Compatibility
-------------

	This library is designed to run on AutoHotkey v1.1.12.00+ (32 and 64-bit), on Windows XP+.

Links
-----

	Device and Driver Installation
	http://msdn.microsoft.com/en-us/library/windows/hardware/ff549731%28v=vs.85%29.aspx
	
	Menu and Others Resources - Strings
	http://msdn.microsoft.com/en-us/library/windows/desktop/ms646979%28v=vs.85%29.aspx

Credit
------

How to used it
--------------
	
Changes
-------

Author
------

	JPV alias Oldman
*/

#Include <EnumDeviceInterfaceClasses>

global DIGCF_DEFAULT = 0x1
global DIGCF_PRESENT = 0x2
global DIGCF_PROFILE = 0x8
	
/*
==============================================================================================
	ListDeviceInterfaces(Device, Identifier, InterfaceGUID, Flags)
	
	Device        : Device Name, Device Instance ID or Hardware ID (in optional)
	Identifier    : Device Interface Class (in optional)
	InterfaceGUID : Device Interface Class GUID (in optional)
	Flags         : flags to select only specific Devices in the system (in optional)
						 DIGCF_DEFAULT return only the device that is associated with the system default device
											interface, if one is set, for the specified device interface classes
						 DIGCF_PRESENT return only devices that are currently present in the system (default)
						 DIGCF_PROFILE return only devices that are part of the current hardware profile
	
	List all the Device Interface Classes with their corresponding Device Setup Classes
==============================================================================================
*/
ListDeviceInterfaces(ByRef _device="", ByRef _identifier="", ByRef _interfaceGUID="", _flags=0x2)
{
	static DIGCF_ALLCLASSES      = 0x4
	static DIGCF_DEVICEINTERFACE = 0x10
	
	static INVALID_HANDLE_VALUE  = -1
	
	;-----------------------
	; Verify the parameters
	;-----------------------
	if _identifier
	{
		if !EnumDeviceInterfaceClasses.HasKey(_identifier)
		{
			MsgBox, 16, % A_ScriptName, % "The Identifier (" _identifier ") is not found"
			return false
		}
		
		lIdentifier := _identifier
		
		if _interfaceGUID
		{
			if (_interfaceGUID <> EnumDeviceInterfaceClasses[_identifier])
			{
				MsgBox, 16, % A_ScriptName, % "Identifier (" _identifier ") and Interface Class GUID ("
								. _interfaceGUID ") do not match"
				return false
			}
			
			lInterfaceGUID := _interfaceGUID
		}
		else
			lInterfaceGUID := EnumDeviceInterfaceClasses[_identifier]
	}
	else
	{
		if _interfaceGUID
		{
			for lIdentifier, lInterfaceGUID in EnumDeviceInterfaceClasses
				if (lInterfaceGUID = _interfaceGUID)
					break
			
			if (lInterfaceGUID <> _interfaceGUID)
			{
				MsgBox, 16, % A_ScriptName, % "The Interface Class GUID (" _interfaceGUID ") is not found"
				return false
			}
		}
		else
		{
			lIdentifier=
			lInterfaceGUID=
		}
	}
	
	if _flags
	{
		; The DIGCF_DEFAULT value is not authorized, because it causes an A_LastError -536870374
		if (_flags & ~0xA)
		{
			MsgBox, 16, % A_ScriptName, % "The Device flags (" _flags ") is invalid"
			return false
		}
	}
	
	;---------------------------
	; Load the Setupapi Library
	;---------------------------
	if !hSetupapi := DllCall("LoadLibrary", "Str", "setupapi.dll", "Ptr")
	{
		MsgBox, 16, % A_ScriptName, % "LoadLibrary(setupapi.dll) failed " A_LastError
		return false
	}
	
	;---------------------------------------------------
	; Retrieve the Handle of the Device Information Set
	;---------------------------------------------------
	lFlags := DIGCF_DEVICEINTERFACE | _flags
	
	if lInterfaceGUID
	{
		VarSetCapacity(lInterfaceClassGUID, 16, 0)
		ClassGuidFromString(lInterfaceClassGUID, lInterfaceGUID)
	}
	else
		lFlags |= DIGCF_ALLCLASSES
	
	hDevInfo := DllCall("setupapi.dll\SetupDiGetClassDevs"			; ClassGuid  (opt)
												, "Ptr" , (lInterfaceGUID ? &lInterfaceClassGUID : 0)
												, "Ptr" , 0							; Enumerator (opt)
												, "Ptr" , 0							; hwndParent (opt)
												, "UInt", lFlags					; Flags
												, "Ptr")
	
	if (hDevInfo = INVALID_HANDLE_VALUE)
	{
		MsgBox, 16, % A_ScriptName, % "SetupDiGetClassDevs() failed " A_LastError
		FreeLibrary(hSetupapi)
		return false
	}
	
	;---------------------------------
	; Enumerate the Device Interfaces
	;---------------------------------
	lArrResults := {}
	
	if (_identifier or _interfaceGUID)
	{
		if !lArr := EnumerateDeviceInterfaces(hDevInfo, lIdentifier, lInterfaceGUID, _device)
		{
			SetupDiDestroyDeviceInfoList(hDevInfo)
			FreeLibrary(hSetupapi)
			return false
		}
		
		lArrResults[lIdentifier] := lArr
	}
	else
	{
		for lIdentifier, lInterfaceGUID in EnumDeviceInterfaceClasses
		{
			if !lArr := EnumerateDeviceInterfaces(hDevInfo, lIdentifier, lInterfaceGUID, _device)
			{
				SetupDiDestroyDeviceInfoList(hDevInfo)
				FreeLibrary(hSetupapi)
				return false
			}
			
			if lArr[1].MaxIndex()
				lArrResults[lIdentifier] := lArr
		}
	}
	
	;-------------------------------------
	; Destroy the Device Information List
	;-------------------------------------
	SetupDiDestroyDeviceInfoList(hDevInfo)
   FreeLibrary(hSetupapi)
	
	;----------------------------
	; List the Device Interfaces
	;----------------------------
	lScriptName := SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".") - 1)
	lFileNew    := lScriptName ".txt"
	lFileOld    := lScriptName ".old.txt"
	
	IfExist, %lFileNew%
		FileMove, %lFileNew%, %lFileOld%, 1
	
	; Declare the format of the data (d=digit, s=string) and the headers
	lArrFormat := ["d", "s", "s", "s", "d", "s", "s", "s", "s", "s", "s"]
	lArrHeader := [" Nr", "Interface Class Identifier", "Interface Class GUID"
					,  "Setup Class GUID", "DevIn", "Class Description", "Friendly Name"
					, "Device Description", "Device Interface ID", "Hardware ID", "DevicePath"]
	
	; Calculate the lengths of the headers
	;-------------------------------------
	lArrLen := []
	for lIndex, Header in lArrHeader
		lArrLen.Insert(StrLen(Header))
	
	lArrLen[3] := 38	; default length for Interface Class GUID
	lArrLen[4] := 38	; default length for Setup Class GUID
	
	; Calculate the maximum length of the data
	;-----------------------------------------
	for lIdentifier, lArray in lArrResults
	{
		if ((lLen := StrLen(lIdentifier)) > lArrLen[2])
			lArrLen[2] := lLen
		
		for lIndex, lArr in lArray
		{
			if (lIndex = 1)	; Setup Class GUID
				continue
			
			for lInd, lData in lArr
				if ((lLen := StrLen(lData)) > lArrLen[lIndex+3])
					lArrLen[lIndex+3] := lLen
		}
	}
	
	; Calculate the Buffer length and build the Format strings (headers and data)
	;----------------------------------------------------------------------------
	lBufferLen=2
	lFormatH=
	lFormatD=
	
	for lIndex, lLen in lArrLen
	{
		lBufferLen += lLen + 1
		lFormatH .= "%-" lLen "s "
		
		if (lArrFormat[lIndex] = "d")
			lFormatD .= "%" lLen "d "
		else
			lFormatD .= "%-" lLen "s "
	}
	
	lFormatH .= "`r`n"
	lFormatD .= "`r`n"
	
	; Write the Headers
	;------------------
	lBufferSize := VarSetCapacity(lBuffer, lBufferLen * (A_IsUnicode ? 2 : 1))
	
	lNbrChars := DllCall("user32.dll\wsprintf"
												, "Str" , lBuffer
												, "Str" , lFormatH
												, "Str" , lArrHeader[1]
												, "Str" , lArrHeader[2]
												, "Str" , lArrHeader[3]
												, "Str" , lArrHeader[4]
												, "Str" , lArrHeader[5]
												, "Str" , lArrHeader[6]
												, "Str" , lArrHeader[7]
												, "Str" , lArrHeader[8]
												, "Str" , lArrHeader[9]
												, "Str" , lArrHeader[10]
												, "Str" , lArrHeader[11]
												, "Cdecl int")
	
	if (lNbrChars > lBufferLen)
	{
		MsgBox, 16, % A_ScriptName, % "wsprintf has " lBufferLen " chars, but requires " lNbrChars
		return false
	}
	
	FileAppend, % lBuffer, %lFileNew%
	
	; Write the data
	;---------------
	i=0
	for lIdentifier, lArr in lArrResults
	{
		lInterfaceGUID := EnumDeviceInterfaceClasses[lIdentifier]
		lClassDescription=
		
		for lIndex, lGUID in lArr[1]
		{
			lNbrChars := DllCall("user32.dll\wsprintf"
														, "Str" , lBuffer
														, "Str" , lFormatD
														, "Int" , ++i
														, "Str" , lIdentifier
														, "Str" , lInterfaceGUID
														, "Str" , lGUID
														, "UInt", lArr[2, A_Index]
														, "Str" , lArr[3, A_Index]
														, "Str" , lArr[4, A_Index]
														, "Str" , lArr[5, A_Index]
														, "Str" , lArr[6, A_Index]
														, "Str" , lArr[7, A_Index]
														, "Str" , lArr[8, A_Index]
														, "Cdecl int")

			if (lNbrChars > lBufferLen)
			{
				MsgBox, 16, % A_ScriptName, % "wsprintf has " lBufferLen " chars, but requires " lNbrChars
				return false
			}
			
			FileAppend, % lBuffer, %lFileNew%
			lIdentifier    := ""
			lInterfaceGUID := ""
		}
	}
	
	return true
}

/*
==============================================================================================
	GetDeviceInterfaces(Device, Identifier, InterfaceGUID, Flags)
	
	Device        : Device Name, Device Instance ID or Hardware ID (in)
	Identifier    : Device Interface Class (in optional)
	InterfaceGUID : Device Interface Class GUID (in optional)
	Flags         : flags to select only specific Devices in the system (in optional)
						 DIGCF_DEFAULT return only the device that is associated with the system default device
											interface, if one is set, for the specified device interface classes
						 DIGCF_PRESENT return only devices that are currently present in the system (default)
						 DIGCF_PROFILE return only devices that are part of the current hardware profile
	
	Check if a Device Name, Device Instance ID or a Hardware ID belongs to a Device Interface Class
==============================================================================================
*/
GetDeviceInterfaces(ByRef _device, ByRef _identifier="", ByRef _interfaceGUID="", _flags=0x2)
{
	static DIGCF_ALLCLASSES      = 0x4
	static DIGCF_DEVICEINTERFACE = 0x10
	
	static INVALID_HANDLE_VALUE  = -1
	
	;-----------------------
	; Verify the parameters
	;-----------------------
	if _identifier
	{
		if !EnumDeviceInterfaceClasses.HasKey(_identifier)
		{
			MsgBox, 16, % A_ScriptName, % "The Identifier (" _identifier ") is not found"
			return false
		}
		
		lIdentifier := _identifier
		
		if _interfaceGUID
		{
			if (_interfaceGUID <> EnumDeviceInterfaceClasses[_identifier])
			{
				MsgBox, 16, % A_ScriptName, % "Identifier (" _identifier ") and Interface Class GUID ("
								. _interfaceGUID ") do not match"
				return false
			}
			
			lInterfaceGUID := _interfaceGUID
		}
		else
			lInterfaceGUID := EnumDeviceInterfaceClasses[_identifier]
	}
	else
	{
		if !_interfaceGUID
		{
			MsgBox, 16, % A_ScriptName, % "The Indentifier or the Interface Class GUID is missing"
			return false
		}
		
		for lIdentifier, lInterfaceGUID in EnumDeviceInterfaceClasses
			if (lInterfaceGUID = _interfaceGUID)
				break
		
		if (lInterfaceGUID <> _interfaceGUID)
		{
			MsgBox, 16, % A_ScriptName, % "The Interface Class GUID (" _interfaceGUID ") is not found"
			return false
		}
	}
	
	if _flags
	{
		; The DIGCF_DEFAULT value is not authorized, because it causes an A_LastError -536870374
		if (_flags & ~0xA)
		{
			MsgBox, 16, % A_ScriptName, % "The Device flags (" _flags ") is invalid"
			return false
		}
	}
	
	;---------------------------
	; Load the Setupapi Library
	;---------------------------
	if !hSetupapi := DllCall("LoadLibrary", "Str", "setupapi.dll", "Ptr")
	{
		MsgBox, 16, % A_ScriptName, % "LoadLibrary(setupapi.dll) failed " A_LastError
		return false
	}
	
	;---------------------------------------------------
	; Retrieve the Handle of the Device Information Set
	;---------------------------------------------------
	lFlags := DIGCF_DEVICEINTERFACE | _flags
	
	VarSetCapacity(lInterfaceClassGUID, 16, 0)
	ClassGuidFromString(lInterfaceClassGUID, lInterfaceGUID)
	
	hDevInfo := DllCall("setupapi.dll\SetupDiGetClassDevs"			; ClassGuid  (opt)
												, "Ptr" , &lInterfaceClassGUID
												, "Ptr" , 0							; Enumerator (opt)
												, "Ptr" , 0							; hwndParent (opt)
												, "UInt", lFlags					; Flags
												, "Ptr")
	
	if (hDevInfo = INVALID_HANDLE_VALUE)
	{
		MsgBox, 16, % A_ScriptName, % "SetupDiGetClassDevs() failed " A_LastError
		FreeLibrary(hSetupapi)
		return false
	}
	
	;---------------------------------
	; Enumerate the Device Interfaces
	;---------------------------------
	if !lArr := EnumerateDeviceInterfaces(hDevInfo, lIdentifier, lInterfaceGUID, _device)
	{
		SetupDiDestroyDeviceInfoList(hDevInfo)
		FreeLibrary(hSetupapi)
		return false
	}
	
	;-------------------------------------
	; Destroy the Device Information List
	;-------------------------------------
	SetupDiDestroyDeviceInfoList(hDevInfo)
   FreeLibrary(hSetupapi)
	return lArr
}

/*
==============================================================================================
	The function is only used by the Library. It should never be called by the main program.
==============================================================================================
*/
SetupDiDestroyDeviceInfoList(_hDevInfo)
{
	if _hDevInfo
		if !DllCall("setupapi.dll\SetupDiDestroyDeviceInfoList", "Ptr", _hDevInfo)
			MsgBox, 16, % A_ScriptName, % "SetupDiDestroyDeviceInfoList() failed " A_LastError
}

/*
==============================================================================================
	The function is only used by the Library. It should never be called by the main program.
==============================================================================================
*/
FreeLibrary(_handle)
{
   if _handle
		DllCall("FreeLibrary", "Ptr", _handle)
}

/*
==============================================================================================
	The function is only used by the Library. It should never be called by the main program.
==============================================================================================
	EnumerateDeviceInterfaces(hDevInfo, Identifier, InterfaceGUID, Device)
	
	hDevInfo      : Devise Information Set Handle (in)
	Identifier    : Device Interface Class (in)
	InterfaceGUID : Device Interface Class GUID (in)
	Device        : Device Name, Device Instance ID or Hardware ID (in optional)
	
	Return all the Device Interface Classes with their corresponding Device Setup Classes
==============================================================================================
*/
EnumerateDeviceInterfaces(_hDevInfo, ByRef _identifier, ByRef _interfaceGUID, ByRef _device="")
{
	static ERROR_INVALID_DATA        = 13
	static ERROR_INSUFFICIENT_BUFFER = 122
	static ERROR_NO_MORE_ITEMS       = 259
	
	static SPDRP_DEVICEDESCR  = 0x0
	static SPDRP_HARDWAREID   = 0x1
	static SPDRP_FRIENDLYNAME = 0xC
	
	static LINE_LEN   = 256
	static LINE_SIZE  = A_IsUnicode ? 512 : 256
	static TCHAR_SIZE = A_IsUnicode ? 2 : 1
	
	lArrGUID             := []
	lArrDevInst          := []
	lArrClassDescription := []
	lArrFriendlyName     := []
	lArrDeviceDescr      := []
	lArrDeviceInstanceId := []
	lArrHardwareID       := []
	lArrDevicePath       := []
	lArrResult := [lArrGUID, lArrDevInst, lArrClassDescription, lArrFriendlyName, lArrDeviceDescr
					 , lArrDeviceInstanceId, lArrHardwareID, lArrDevicePath]
	
	if _interfaceGUID
		lInterfaceGUID := _interfaceGUID
	else
		lInterfaceGUID := EnumDeviceInterfaceClasses[_identifier]
	
	;-------------------------------------------------------------------------
	; Enumerate the Device Interfaces contained in the Device Information Set
	;-------------------------------------------------------------------------
	VarSetCapacity(lInterfaceClassGUID, 16, 0)
	ClassGuidFromString(lInterfaceClassGUID, lInterfaceGUID)
	
	; DWORD + GUID + DWORD + ULONG_PTR
	lLen := 4 + 16 + 4 + A_PtrSize
	VarSetCapacity(lDeviceInterfaceData, lLen, 0)
	NumPut(lLen, lDeviceInterfaceData, 0, "UInt")
	
	lGUIDold=
	while DllCall("setupapi.dll\SetupDiEnumDeviceInterfaces"
									, "Ptr" , _hDevInfo							; DeviseInfoSet
									, "Ptr" , 0										; DeviseInfoData (opt)
									, "Ptr" , &lInterfaceClassGUID			; InterfaceClassGuid
									, "UInt", A_Index-1							; MemberIndex
									, "Ptr" , &lDeviceInterfaceData)			; DeviceInterfaceData (out)
	{
		;------------------------------------------------
		; Retrieve the Device Interface Detail Structure
		;------------------------------------------------
		; DWORD + TCHAR[ANYSIZE_ARRAY]
		lLen        := 4 + TCHAR_SIZE
		lBufferSize := lLen + LINE_SIZE + TCHAR_SIZE
		VarSetCapacity(lDeviceInterfaceDetailData, lBufferSize, 0)
		NumPut(lLen, lDeviceInterfaceDetailData, 0, "UInt")
		
		; DWORD + GUID + DWORD + ULONG_PTR
		lLen := 4 + 16 + 4 + A_PtrSize
		VarSetCapacity(lDeviceInfoData, lLen, 0)
		NumPut(lLen, lDeviceInfoData, 0, "UInt")
		
		if !DllCall("setupapi.dll\SetupDiGetDeviceInterfaceDetail"
									, "Ptr"  , _hDevInfo							; DeviseInfoSet
									, "Ptr"  , &lDeviceInterfaceData			; DeviceInterfaceData
									, "Ptr"  , &lDeviceInterfaceDetailData	; DevInterfaceDetailData (out opt)
									, "UInt" , lBufferSize 						; DevInterfaceDetailDataSize(byte)
									, "UIntP", lRequiredSize := 0				; RequiredSize (out opt)(byte)
									, "Ptr"  , &lDeviceInfoData)				; DeviceInfoData (out opt)
		{
			MsgBox, 16, % A_ScriptName, % "SetupDiGetDeviceInterfaceDetail() failed " A_LastError
			return false
		}
		
		; DevicePath = SymbolicLink (registry value name)
		lDevicePath := StrGet(&lDeviceInterfaceDetailData+4)
		VarSetCapacity(lClassGUID, 16, 0)
		StructGet(lClassGUID, lDeviceInfoData, 16, 4)
		ClassGuidToString(lGUID, lClassGUID)
		lDevInst := NumGet(lDeviceInfoData, 20, "UInt")
		
		;--------------------------------------------
		; Retrieve the description of the Class GUID
		;--------------------------------------------
		VarSetCapacity(lClassDescription, LINE_SIZE, 0)
		
		if (lGUID = "{00000000-0000-0000-0000-000000000000}")
			lClassDescription := "Unknown"
		
		else (lGUID <> lGUIDold)
		{
			if !DllCall("setupapi.dll\SetupDiGetClassDescription"
										, "Ptr"  , &lClassGUID					; ClassGuid
										, "Str"  , lClassDescription			; ClassDescription (out)
										, "UInt" , LINE_LEN						; ClassDescriptionSize (char)
										, "UIntP", lRequiredSize := 0)		; RequiredSize (out opt)(char)
			{
				MsgBox, 16, % A_ScriptName, % "SetupDiGetClassDescription() failed " A_LastError
				return false
			}
		}
		
		;-------------------------------
		; Retrieve the DeviceInstanceId
		;-------------------------------
		VarSetCapacity(lDeviceInstanceId, LINE_SIZE, 0)
		
		if !DllCall("setupapi.dll\SetupDiGetDeviceInstanceId"
									, "Ptr"  , _hDevInfo							; DeviceInfoSet
									, "Ptr"  , &lDeviceInfoData				; DeviceInfoData
									, "Str"  , lDeviceInstanceId				; DeviceInstanceId (out opt)
									, "UInt" , LINE_SIZE							; PropertyBufferSize (byte)
									, "UIntP", lRequiredSize := 0)			; RequiredSize (out opt)(byte)
		{
			if (A_LastError = ERROR_INVALID_DATA)
				lDeviceInstanceId := "Unknown"
			else
			{
				MsgBox, 16, % A_ScriptName, % "SetupDiGetDeviceInstanceId() failed " A_LastError
				return false
			}
		}
		
		;---------------------------------------------
		; Retrieve the FriendlyName Registry Property
		;---------------------------------------------
		VarSetCapacity(lFriendlyName, LINE_SIZE, 0)
		
		if !DllCall("setupapi.dll\SetupDiGetDeviceRegistryProperty"
									, "Ptr"  , _hDevInfo							; DeviceInfoSet
									, "Ptr"  , &lDeviceInfoData				; DeviceInfoData
									, "UInt" , SPDRP_FRIENDLYNAME				; Property
									, "UInt" , 0									; PropertyRegDataType (out opt.)
									, "Str"  , lFriendlyName					; PropertyBuffer (out opt)
									, "UInt" , LINE_SIZE							; PropertyBufferSize (byte)
									, "UIntP", lRequiredSize := 0)			; RequiredSize (out opt)(byte)
		{
			if (A_LastError = ERROR_INVALID_DATA)
				lFriendlyName := "Unknown"
			else
			{
				MsgBox, 16, % A_ScriptName, % "SetupDiGetDeviceRegistryProperty(FriendlyName) failed " A_LastError
				return false
			}
		}
		
		;--------------------------------------------
		; Retrieve the DeviceDescr Registry Property
		;--------------------------------------------
		VarSetCapacity(lDeviceDescr, LINE_SIZE, 0)
		
		if !DllCall("setupapi.dll\SetupDiGetDeviceRegistryProperty"
									, "Ptr"  , _hDevInfo							; DeviceInfoSet
									, "Ptr"  , &lDeviceInfoData				; DeviceInfoData
									, "UInt" , SPDRP_DEVICEDESCR				; Property
									, "UInt" , 0									; PropertyRegDataType (out opt.)
									, "Str"  , lDeviceDescr						; PropertyBuffer (out opt)
									, "UInt" , LINE_SIZE							; PropertyBufferSize (byte)
									, "UIntP", lRequiredSize := 0)			; RequiredSize (out opt)(byte)
		{
			if (A_LastError = ERROR_INVALID_DATA)
				lDeviceDescr := "Unknown"
			else
			{
				MsgBox, 16, % A_ScriptName, % "SetupDiGetDeviceRegistryProperty(DeviceDescr) failed " A_LastError
				return false
			}
		}
		
		;-------------------------------------------
		; Retrieve the HardwareID Registry Property
		;-------------------------------------------
		VarSetCapacity(lHardwareID, LINE_SIZE, 0)
		
		if !DllCall("setupapi.dll\SetupDiGetDeviceRegistryProperty"
									, "Ptr"  , _hDevInfo							; DeviceInfoSet
									, "Ptr"  , &lDeviceInfoData				; DeviceInfoData
									, "UInt" , SPDRP_HARDWAREID				; Property
									, "UInt" , 0									; PropertyRegDataType (out opt.)
									, "Str"  , lHardwareID						; PropertyBuffer (out opt)
									, "UInt" , LINE_SIZE							; PropertyBufferSize (byte)
									, "UIntP", lRequiredSize := 0)			; RequiredSize (out opt)(byte)
		{
			if (A_LastError = ERROR_INVALID_DATA)
				lHardwareID := "Unknown"
			else
			{
				MsgBox, 16, % A_ScriptName, % "SetupDiGetDeviceRegistryProperty(HardwareID) failed " A_LastError
				return false
			}
		}
		
		if _device
			if (lDeviceInstanceId <> _device)
				if (lFriendlyName <> _device and lDeviceDescr <> _device)
					if (lHardwareID <> _device)
						continue
		
		lArrGUID.Insert(lGUID)
		lArrDevInst.Insert(lDevInst)
		lArrClassDescription.Insert(lClassDescription)
		lArrDeviceInstanceId.Insert(lDeviceInstanceId)
		lArrFriendlyName.Insert(lFriendlyName)
		lArrHardwareID.Insert(lHardwareID)
		lArrDeviceDescr.Insert(lDeviceDescr)
		lArrDevicePath.Insert(lDevicePath)
		lGUIDold := lGUID
	}
	
	if (ErrorLevel or A_LastError)
	{
		if (A_LastError <> ERROR_NO_MORE_ITEMS)
		{
			MsgBox, 16, % A_ScriptName, % "SetupDiEnumDeviceInterfaces() failed " A_LastError " " ErrorLevel
			return false
		}
	}
	
	return lArrResult
}

/*
==============================================================================================
	ClassGuidFromString(ClassGUID, GUID)
	
	ClassGUID : Class GUID structure (out)
	GUID      : Class GUID string (in)
	
	Convert the GUID string into a GUID structure
==============================================================================================
*/
ClassGuidFromString(ByRef _classGUID, ByRef _GUID)
{
	NumPut("0x" SubStr(_GUID,  2, 8), _classGUID,  0, "UInt")		; DWORD Data1
	NumPut("0x" SubStr(_GUID, 11, 4), _classGUID,  4, "UShort")		; WORD  Data2
	NumPut("0x" SubStr(_GUID, 16, 4), _classGUID,  6, "UShort")		; WORD  Data3
	NumPut("0x" SubStr(_GUID, 21, 2), _classGUID,  8, "UChar")		; BYTE  Data4[1]
	NumPut("0x" SubStr(_GUID, 23, 2), _classGUID,  9, "UChar")		; BYTE  Data4[2]
	NumPut("0x" SubStr(_GUID, 26, 2), _classGUID, 10, "UChar")		; BYTE  Data4[3]
	NumPut("0x" SubStr(_GUID, 28, 2), _classGUID, 11, "UChar")		; BYTE  Data4[4]
	NumPut("0x" SubStr(_GUID, 30, 2), _classGUID, 12, "UChar")		; BYTE  Data4[5]
	NumPut("0x" SubStr(_GUID, 32, 2), _classGUID, 13, "UChar")		; BYTE  Data4[6]
	NumPut("0x" SubStr(_GUID, 34, 2), _classGUID, 14, "UChar")		; BYTE  Data4[7]
	NumPut("0x" SubStr(_GUID, 36, 2), _classGUID, 15, "UChar")		; BYTE  Data4[8]
	return
}

/*
==============================================================================================
	ClassGuidToString(GUID, ClassGUID)
	
	GUID      : Class GUID string (out)
	ClassGUID : Class GUID Structure (in)
	
	Convert the GUID structure into a GUID string
==============================================================================================
*/
ClassGuidToString(ByRef _GUID, ByRef _classGUID)
{
	_GUID := "{" IntToHexa(NumGet(_classGUID,  0, "UInt")  , 8, false)	; DWORD Data1
			.  "-" IntToHexa(NumGet(_classGUID,  4, "UShort"), 4, false)	; WORD  Data2
			.  "-" IntToHexa(NumGet(_classGUID,  6, "UShort"), 4, false)	; WORD  Data3
			.  "-" IntToHexa(NumGet(_classGUID,  8, "UChar") , 2, false)	; BYTE  Data4[1]
			.      IntToHexa(NumGet(_classGUID,  9, "UChar") , 2, false)	; BYTE  Data4[2]
			.  "-" IntToHexa(NumGet(_classGUID, 10, "UChar") , 2, false)	; BYTE  Data4[3]
			.      IntToHexa(NumGet(_classGUID, 11, "UChar") , 2, false)	; BYTE  Data4[4]
			.      IntToHexa(NumGet(_classGUID, 12, "UChar") , 2, false)	; BYTE  Data4[5]
			.      IntToHexa(NumGet(_classGUID, 13, "UChar") , 2, false)	; BYTE  Data4[6]
			.      IntToHexa(NumGet(_classGUID, 14, "UChar") , 2, false)	; BYTE  Data4[7]
			.      IntToHexa(NumGet(_classGUID, 15, "UChar") , 2, false)	; BYTE  Data4[8]
			.  "}"
	return
}

/*
==============================================================================================
	StructGet(Data, Struct, Length, Offset)
	
	Data   : an elementary field name (out)
	Struct : a structure name (in)
	Length : the length to be copied (in)
	Offset : the starting position of the structure to be copied from (in optional)
	
	Copy a structure content into an elementary field
==============================================================================================
*/
StructGet(ByRef _data, ByRef _struct, _len, _offset=0)
{
	if IsByRef(_struct)
		Loop, %_len%
			NumPut(NumGet(_struct, _offset++, "UChar"), _data, A_Index-1, "UChar")
	else
		Loop, %_len%
			NumPut(NumGet(_struct+0, _offset++, "UChar"), _data, A_Index-1, "UChar")
	
	return
}

/*
==============================================================================================
	StructPut(Data, Struct, Length, Offset)
	
	Data   : an elementary field name (in)
	Struct : a structure name (out)
	Length : the length to be copied (in)
	Offset : the starting position of the structure to be copied to (in optional)
	
	Copy an elementary field as a structure content
==============================================================================================
*/
StructPut(ByRef _data, ByRef _struct, _len, _offset=0)
{
	Loop, %_len%
		NumPut(NumGet(_data, A_Index-1, "UChar"), _struct, _offset++, "UChar")
	
	return
}
