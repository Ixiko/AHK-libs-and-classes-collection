
; *************************************************************************
; IUIAutomationEventHandler
; GUID: {146C3C17-F12E-4E22-8C27-F894B9B79C69}
; https://autohotkey.com/boards/viewtopic.php?f=5&t=37142&hilit=ImportTypeLib+event+handler
; *************************************************************************


class IUIAutomationEventHandler
{ 
	; Generic definitions

	static __IID := "{146C3C17-F12E-4E22-8C27-F894B9B79C69}"

	__New(p="", flag=1)
	{
		this.__Type:="IUIAutomationEventHandler"
		this.__Value:=p
		this.__Flag:=flag
	}

	__Delete()
	{
		this.__Flag? ObjRelease(this.__Value):0
	}

	__Vt(n)
	{
		return NumGet(NumGet(this.__Value+0, "Ptr")+n*A_PtrSize,"Ptr")
	}

	; Interface functions

	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleAutomationEvent([FIN] IUIAutomationElement*: sender, [FIN] Int: eventId)
	HandleAutomationEvent(sender, eventId)
	{
		If (IsObject(sender) and (ComObjType(sender)=""))
			refsender:=sender.__Value
		else
			refsender:=sender
		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refsender, "Int", eventId, "Int")
		return res
	}
}
