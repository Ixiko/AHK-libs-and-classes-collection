
/*
#SingleInstance ignore	; One instance at a time

;-- Find first active monitor ID
i=0
While AdapterInfo := EnumDisplayDevices(i++) {
	While MonInfo := EnumDisplayDevices(A_Index-1, AdapterInfo.Name) {
		If (MonInfo.Flags & 0x00000001) { ; DISPLAY_DEVICE_ACTIVE
			ActiveID := MonInfo.ID
			Break
		}
	}
}

;-- Try switch to "computer only"
runwait % "displayswitch /internal"

;-- Find active monitor ID again
i=0
While AdapterInfo := EnumDisplayDevices(i++) {
	While MonInfo := EnumDisplayDevices(A_Index-1, AdapterInfo.Name) {
		If (MonInfo.Flags & 0x00000001) { ; DISPLAY_DEVICE_ACTIVE
			ActiveIDNew := MonInfo.ID
			Break
		}
	}
}

;-- Check for changes
If Not ActiveID == ActiveIDNew
	Exit

;-- Try switch to "projector"
runwait % "displayswitch /external"


Exit


/*
	Function: EnumDisplayDevices

	Parameters:
		Index 				- Adapter index OR if adapter parameter is specified, monitor index. Starts at 0.
		Adapter 			- Adapter name (string)
		GetInterfaceName	- ???

	Remarks:
		Function fails if given index is greater than the largest device index.

	Returns:
		On success returns object containing returned DISPLAY_DEVICE members. FALSE on failure.

	Returned Object Members:

		Name 		- DeviceName ???
		String		- DeviceString ???
		Flags		- StateFlags (see below)
		ID			- DeviceID ???
		Key			- DeviceKey ???

	Adapter Flags:

		0x00000001		- DISPLAY_DEVICE_ATTACHED_TO_DESKTOP
		0x00000002		- DISPLAY_DEVICE_MULTI_DRIVER
		0x00000004		- DISPLAY_DEVICE_PRIMARY_DEVICE
		0x00000008		- DISPLAY_DEVICE_MIRRORING_DRIVER
		0x00000010		- DISPLAY_DEVICE_VGA_COMPATIBLE
		0x00000020		- DISPLAY_DEVICE_REMOVABLE
		0x02000000		- DISPLAY_DEVICE_DISCONNECT
		0x04000000 		- DISPLAY_DEVICE_REMOTE
		0x08000000		- DISPLAY_DEVICE_MODESPRUNED

	Monitor Flags:

		0x00000001		- DISPLAY_DEVICE_ACTIVE
		0x00000002		- DISPLAY_DEVICE_ATTACHED

	Links:
		- <EnumDisplayDevices function at http://msdn.microsoft.com/en-us/library/dd162609%28v=vs.85%29.aspx>.
		- <DISPLAY_DEVICE structure at http://msdn.microsoft.com/en-us/library/aa932948.aspx>.

	Examples:
(start code)

; Shows all display adapters and monitors in a treeview
Gui, Add, TreeView, r20 w400
i=0
While AdapterInfo := EnumDisplayDevices(i++) {
	TV_Adapter := TV_Add(AdapterInfo.Name)
	While MonInfo := EnumDisplayDevices(A_Index-1, AdapterInfo.Name) {
		TV_AdapterMonitor := TV_Add(MonInfo.Name, TV_Adapter)
		TV_Add(MonInfo.String, 	TV_AdapterMonitor)
		TV_Add(MonInfo.Flags, 	TV_AdapterMonitor)
		TV_Add(MonInfo.ID, 		TV_AdapterMonitor)
		TV_Add(MonInfo.Key, 	TV_AdapterMonitor)
	}
}
Gui, Show

(end)
*/

EnumDisplayDevices(Index, Adapter = 0, GetInterfaceName=False) {

	NumPut(VarSetCapacity(DISPLAY_DEVICE, A_IsUnicode ? 840 : 424, 0), &DISPLAY_DEVICE )

	If ! DllCall("EnumDisplayDevices" . (A_IsUnicode ? "W" : "A")
			, "UInt", Adapter ? &Adapter : 0
			, "UInt", Index
			, "UInt", &DISPLAY_DEVICE
			, "UInt", GetInterfaceName ? 1 : 0)	; EDD_GET_DEVICE_INTERFACE_NAME
		Return False

	CharSize := A_IsUnicode ? 2 : 1
	Return { "Name" 	: StrGet(&DISPLAY_DEVICE + (Offset := 4))
			, "String"	: StrGet(&DISPLAY_DEVICE + (Offset += 32*CharSize))
			, "Flags"	: NumGet(&DISPLAY_DEVICE + (Offset += 128*CharSize), 0, "Uint")
			, "ID"		: StrGet(&DISPLAY_DEVICE + (Offset += 4))
			, "Key"		: StrGet(&DISPLAY_DEVICE + (Offset += 128*CharSize))}
}