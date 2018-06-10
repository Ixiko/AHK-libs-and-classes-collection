#include <DirectX\headers\_dinput.h>

global IDirectInputA, IDirectInputW, IDirectInputDeviceA, IDirectInputDeviceW, IDirectInputDevice2W
global g_XinputDevicesDinputGUIDS := []

DirectInputCreate(Unicode_ = False)
{
	h_dinput := dllcall("GetModuleHandle", str, "dinput.dll")
	if not h_dinput
		h_dinput := dllcall("LoadLibrary", str, "dinput.dll")
	if Unicode_
		pDirectInputCreate := dllcall("GetProcAddress", int, h_dinput, astr, "DirectInputCreateW")
	else pDirectInputCreate := dllcall("GetProcAddress", int, h_dinput, astr, "DirectInputCreateA")

	if not h_dinput or not pDirectInputCreate
		return -1	
		
	VarSetCapacity(pDinput, 4)
	r := dllcall(pDirectInputCreate
				,uint, A_ModuleHandle
				,uint, 0x0500
				,uint, &pDinput
				,uint, 0, uint)
	
	if Unicode_ 
		IDirectInputW := new ComInterfaceWrapper(dinput.IDirectInputW, &pDinput)	
	else IDirectInputA := new ComInterfaceWrapper(dinput.IDirectInputA, &pDinput)		
	return r
}	

getDirectInput(Unicode_ = false)
{		
	r := DirectInputCreate(Unicode_)
	if (r != 0)
		return "Failed to create the IDirectInput interface "  r " - " dinput.result[r . ""]
	
	if not Unicode_
	{
		g_XinputDevicesDinputGUIDS := []
		print("Enumerating Controlers:`n")		
		r := dllcall(IDirectInputA.EnumDevices, uint, IDirectInputA.p
				, uint, DIDEVTYPE_JOYSTICK
				, uint, RegisterCallback("DIEnumDevicesCallback")
				, uint, 0
				, uint, DIDEVTYPE_ATTACHEDONLY, uint)
		
		;print("`nFound Xinput Devices:`n")
		;for k, v in g_XinputDevicesDinputGUIDS
			;print(v[1] ":`n" v[2] "`n")
		
		VarSetCapacity(pDinputDevice, 4)
		VarSetCapacity(GUID, 16)
		GUID_FromString(GUID, dinput.GUID_SysKeyboard)
		r := dllcall(IDirectInputA.CreateDevice, uint, IDirectInputA.p, uint, &GUID
												, uint, &pDinputDevice, uint, 0, uint)
		if (r != 0)
			return "Failed to create the IDirectInputDevice interface " r " - " dinput.result[r . ""]
		
		IDirectInputDeviceA := new ComInterfaceWrapper(dinput.IDirectInputDeviceA, &pDinputDevice)			
	}

	else
	{
		g_XinputDevicesDinputGUIDS := []
		print("Enumerating Controlers:`n")		
		r := dllcall(IDirectInputW.EnumDevices, uint, IDirectInputW.p
				, uint, DIDEVTYPE_JOYSTICK
				, uint, RegisterCallback("DIEnumDevicesCallback")
				, uint, 1
				, uint, DIDEVTYPE_ATTACHEDONLY, uint)
		
		;print("`nFound Xinput Devices:`n")
		;for k, v in g_XinputDevicesDinputGUIDS
			;print(v[1] ":`n" v[2] "`n")
		
		VarSetCapacity(pDinputDevice, 4)
		VarSetCapacity(GUID, 16)
		GUID_FromString(GUID, dinput.GUID_SysKeyboard)
		r := dllcall(IDirectInputW.CreateDevice, uint, IDirectInputW.p, uint, &GUID
											   , uint, &pDinputDevice, uint, 0, uint)
												
		if (r != 0)
			return "Failed to create the IDirectInputDevice interface " r " - " dinput.result[r . ""]		
		IDirectInputDeviceW := new ComInterfaceWrapper(dinput.IDirectInputDeviceW, &pDinputDevice)	
		
		GUID_FromString(GUID, dinput.IID_IDirectInputDevice2W)
		r := dllcall(IDirectInputDeviceW.QueryInterface, uint, IDirectInputDeviceW.p, uint, &GUID, "uint*", pDinputDevice2W)
		if (r != 0)
			return "Failed to create the IDirectInputDevice2 interface " r " - " dinput.result[r . ""]	
		IDirectInputDevice2W := new ComInterfaceWrapper(dinput.IDirectInputDevice2W, pDinputDevice2W, True)	
			
	}
	return "Succeeded to create the DirectInput Interfaces"	
}	

DIEnumDevicesCallback(lpddi, pvRef)
{
	hpx := dllcall("GetModuleHandle", str, "peixoto.dll", uint)
	IsXinput := dllcall("GetProcAddress", uint, hpx, astr, "IsXInputDevice", uint)
		
	DIDEVICEINSTANCE_DX3A[] := lpddi
	add_ := DIDEVICEINSTANCE_DX3A[] + DIDEVICEINSTANCE_DX3A.offset("tszInstanceName")
	
	if pvRef = 0
		name := strget(add_+0, "CP0")
	else name := strget(add_+0, "UTF-16")

	guidProduct := DIDEVICEINSTANCE_DX3A[] + DIDEVICEINSTANCE_DX3A.offset("guidProduct")	
	guidInstace := DIDEVICEINSTANCE_DX3A[] + DIDEVICEINSTANCE_DX3A.offset("guidInstance")	
		
	xinput := dllcall(IsXinput, uint, guidProduct, int)
	guid_string := StringFromIID(guidInstace)
	if xinput
		g_XinputDevicesDinputGUIDS.insert([name, guid_string])
	
	print(name "`n")
	print(guid_string "`n")
	return True
}




