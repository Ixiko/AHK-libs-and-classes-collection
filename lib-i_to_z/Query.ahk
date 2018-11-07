
;------------------------------------------------------------------------------
; Query.ahk Standard Library
; by Sean
;
; REQUIREMENT: 32/64-bit UNICODE AutoHotkey_L
;------------------------------------------------------------------------------

Query_Service(pobj, SID, IID = "!", bRaw = "")
{
	If	DllCall(NumGet(NumGet(0,IsObject(pobj)?pobj:=ComObjUnwrap(pobj):pobj)), "Ptr", pobj, "Ptr", -VarSetCapacity(PID,16)+NumPut(0xFA096000AA003480,NumPut(0x11CE74366D5140C1,PID,"UInt64"),"UInt64"), "Ptr*", psp)=0
	&&	DllCall(NumGet(NumGet(0,psp),A_PtrSize*3), "Ptr", psp, "Ptr", Query_Guid4String(SID,SID), "Ptr", IID=="!"?&SID:Query_Guid4String(IID,IID), "Ptr*", pobj:=0)+DllCall(NumGet(NumGet(0,psp),A_PtrSize*2), "Ptr", psp)*0=0
	Return	bRaw?pobj:ComObjEnwrap(9,pobj)
}

Query_Interface(pobj, IID = "", bRaw = "")
{
	If	DllCall(NumGet(NumGet(0,IsObject(pobj)?pobj:=ComObjUnwrap(pobj):pobj)), "Ptr", pobj+0, "Ptr", Query_Guid4String(IID,IID), "Ptr*", pobj:=0)=0
	Return	bRaw?pobj:ComObjEnwrap(9,pobj)
}

Query_Guid4String(ByRef GUID, sz = "")
{
	Return	DllCall("ole32\CLSIDFromString", "WStr", sz?sz:sz==""?"{00020400-0000-0000-C000-000000000046}":"{00000000-0000-0000-C000-000000000046}", "Ptr", VarSetCapacity(GUID,16,0)*0+&GUID)*0+&GUID
}

Query_String4Guid(pGUID)
{
	Return	DllCall("ole32\StringFromGUID2", "Ptr", pGUID, "WStr", sz:="{00000000-0000-0000-0000-000000000000}", "Int", 39)?sz:""
}
