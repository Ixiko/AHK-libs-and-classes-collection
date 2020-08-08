#Include %A_ScriptDir%\UIAutomationClient-v1_0-x86_64.ahk

; *************************************************************************
; IUIAutomationEventHandler
; GUID: {146C3C17-F12E-4E22-8C27-F894B9B79C69}
; *************************************************************************

; class IUIAutomationEventHandler {
; 	; Generic definitions

; 	static __IID := "{146C3C17-F12E-4E22-8C27-F894B9B79C69}"

; 	__New(p="", flag=1) {
; 		this.__Type:="IUIAutomationEventHandler"
; 		this.__Value:=p
; 		this.__Flag:=flag
; 	}

; 	__Delete() {
; 		this.__Flag? ObjRelease(this.__Value):0
; 	}

; 	__Vt(n) {
; 		return NumGet(NumGet(this.__Value, "Ptr")+n*A_PtrSize,"Ptr")
; 	}

; 	; Interface functions

; 	; VTable Positon 3: INVOKE_FUNC Vt_Hresult HandleAutomationEvent([FIN] IUIAutomationElement*: sender, [FIN] Int: eventId)
; 	HandleAutomationEvent(sender, eventId) {
; 		If (IsObject(sender) and (ComObjType(sender)=""))
; 			refsender:=sender.__Value
; 		else
; 			refsender:=sender
; 		res:=DllCall(this.__Vt(3), "Ptr", this.__Value, "Ptr", refsender, "Int", eventId, "Int")
; 		return res
; 	}
; }


class Heap {
	ProcessHeap {
		get {
			static heap := DllCall("GetProcessHeap", "Ptr")
			return heap
		}
	}
	Allocate(bytes) {
		static HEAP_GENERATE_EXCEPTIONS := 0x00000004, HEAP_ZERO_MEMORY := 0x00000008
		return DllCall("HeapAlloc", "Ptr", Heap.ProcessHeap, "UInt", HEAP_GENERATE_EXCEPTIONS|HEAP_ZERO_MEMORY, "UInt", bytes, "UPtr")
	}
	GetSize(buffer) {
		return DllCall("HeapSize", "Ptr", Heap.ProcessHeap, "UInt", 0, "Ptr", buffer, "Ptr" )
	}
	Release(buffer) {

		return DllCall("HeapFree", "Ptr", Heap.ProcessHeap, "UInt", 0, "Ptr", buffer, "Int")
	}
}

StringFromCLSID(riid) {
	res := DllCall("ole32\StringFromCLSID", "Ptr", riid, "PtrP", pStrCLSID := 0)
	sCLSID := StrGet(pStrCLSID, "UTF-16")
	DllCall("ole32\CoTaskMemFree", "Ptr", pStrCLSID)
	return sCLSID
}

global 	VT 		:= 0
	   ,REFS 	:= 1

/**
 *	Base implementation for all Com Objects
 *		- Handles creation of static vTable
 *		- Registers new class instance with vtoMap for efficient memory management of vTable use
 *		- Creates global pObject pointer for use with COM
 *
 *	 NOTE - Tested that:
 *		- this.vTable and this.vtoMap accesses the static declaration in the top level class declaration
 */
class ComObjImpl {

	; Pointers to vTables by this.IID
	static vTables := { }
	; Map of Interface Pointers to Object by this.IID
	static ObjMap := { }

	; Array of string GUID Com Interfaces that this object implements
	ImplementsInterfaces := []

	; Array of Com Functions that are implemented in the class hierarchy
	ComFunctions := []

	__New() {
		; Using the last Interface in the implementation array, this *should* be the highest IID in the chain
		this.IID := this.ImplementsInterfaces[this.ImplementsInterfaces.Length()]

		this.PopulateVirtualMethodTable()

		this.pInterface := Heap.Allocate(A_PtrSize + 4)
		ComObjImpl.ObjMap[this.pInterface] := this
		ObjRelease(&this)	; Release the reference just created, this reference will be free'd when __Delete is actually called

		NumPut(ComObjImpl.vTables[this.IID][VT], this.pInterface, 0, "Ptr")
		ComObjImpl.vTables[this.IID][REFS] += 1

		Refs := this._AddRef(this.pInterface)	; Adding our own reference, on delete should be 0
	}

	/**
	 *	Populates the static this.vTable with the callback points
	 *		NOTE: vTable is being passed in ByRef because it would seem using this.vTable with
	 *		VarSetCapacity/NumPut does not function correctly, using them on a ByRef of it works
	 *		just fine.
	 */
	PopulateVirtualMethodTable() {
		if (!ComObjImpl.vTables[this.IID]) {
			; Allocate a Ptr record for each method in ComFunctions
			ComObjImpl.vTables[this.IID, VT] := Heap.Allocate(this.ComFunctions.Length() * A_PtrSize)
			ComObjImpl.vTables[this.IID, REFS] := 0

			for i, func in this.ComFunctions {
				callback := RegisterCallback(this["_" func].Name)

				NumPut(callback, ComObjImpl.vTables[this.IID][VT], (i-1) * A_PtrSize)
			}
		}
	}

	__Delete() {
		ComObjImpl.ObjMap[this.pInterface] :=
		ComObjImpl.vTables[this.IID][REFS] -= 1

		Heap.Release(this.pInterface)

		if (ComObjImpl.vTables[this.IID][REFS] == 0) {
			Heap.Release(ComObjImpl.vTables[this.IID][VT])
			ComObjImpl.vTables[this.IID] :=
		}
	}
}

class UnknownImpl extends ComObjImpl {
	; Declare the functions our class is implementing (expected to be over-ridden by sub-classes)
	; This array should be complete for the interface and in the correct vTable order per the Type Library
	ComFunctions := ["QueryInterface", "AddRef", "Release"]

	__New() {
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{00000000-0000-0000-C000-000000000046}")		; IUnknown
		base.__New()
	}
	/**
	 *	Implementation of IUnknown::QueryInterface
	 *		Each class level that implements some part of the final vTable should have its interface GUID
	 *		declared in this.ImplementsInterface array
	 */
	_QueryInterface(pInterface, riid, ppvObject) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._QueryInterface(this, pInterface, riid)

		sCLSID := StringFromCLSID(riid)

		for i, sIID in this.ImplementsInterfaces {
			if (sCLSID == sIID) {
				NumPut(pInterface, ppvObject+0, "Ptr")

				this._AddRef(pInterface)
				return 0 ; S_OK
			}
		}

		NumPut(0, ppvObject+0, "Ptr")
		return 0x80004002 ; E_NOINTERFACE
	}

	; Implementation of IUnknown::AddRef
	_AddRef(pInterface) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._AddRef(this)

		NumPut((RefCount := NumGet(pInterface+0, A_PtrSize, "UInt") + 1), pInterface+0, A_PtrSize, "UInt")

		return RefCount
	}

	; Implementation of IUnknown::Release
	_Release(pInterface) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._Release(this)

		if ((RefCount := this.GetRefs()) > 0) {
			RefCount -= 1
			NumPut(RefCount, pInterface+0, A_PtrSize, "UInt")
		}

		return RefCount
	}

	GetRefs() {
		return NumGet(this.pInterface+0, A_PtrSize, "UInt")
	}

	__Delete() {
		if ( (RefCount := this.GetRefs()) != 1)
			OutputDebug % Format("WARNING: RefCount={} in {}, should be 1 (our own reference)", RefCount, A_ThisFunc "()")
		base.__Delete()
	}
}

/**
 *	UIAutomationEventHandlerImpl
 *		- Top Level Interface Implementation
 *		- Should have vTable and vtoMap declare as static
 *		- Sub-classes are user-level implementations and should just override
 *			HandleAutomationEvent verbatim.
 */
class UIAutomationEventHandlerImpl extends UnknownImpl {

	; Declare the functions our class is implementing, this should not be over-ridden by userland classes
	; 	This array should be complete for the interface and in the correct vTable order per the Type Library
	ComFunctions := ["QueryInterface", "AddRef", "Release", "HandleAutomationEvent"]

	__New() {
		; Add the GUID of the interface this class is implementing
		this.ImplementsInterfaces.InsertAt(1, "{146C3C17-F12E-4E22-8C27-F894B9B79C69}")		; IUIAutomationEventHandler
		base.__New()
	}

	;
	; 	Handles a Microsoft UI Automation event.
	;		@see: https://msdn.microsoft.com/en-us/library/windows/desktop/ee696045(v=vs.85).aspx
	;
	;	IUIAutomationEventHandler 	pInterface	Pointer to our interface address
	;	IUIAutomationElement		pSender		Pointer to Element for which Event happened
	;	EVENTID 					EventID 	The event identifier.
	;		@see: https://msdn.microsoft.com/en-us/library/windows/desktop/ee671223(v=vs.85).aspx
	;
	_HandleAutomationEvent(pInterface, pSender, EventID) {
		if (!IsObject(this))
			return ComObjImpl.ObjMap[this]._HandleAutomationEvent(this, pInterface, pSender)

		this.HandleAutomationEvent(pInterface, pSender, EventID)
	}
}

class UIA_SnoopWindowsDestroyed extends UIAutomationEventHandlerImpl {
	;
	; 	Handles a Microsoft UI Automation event, called by the parent class which received the
	;		event call.
	;	@see: https://msdn.microsoft.com/en-us/library/windows/desktop/ee696045(v=vs.85).aspx
	;
	;	IUIAutomationEventHandler 	pInterface	Pointer to our interface address
	;	IUIAutomationElement		pSender		Pointer to Element for which Event happened
	;	EVENTID 					EventID 	The event identifier.
	;		@see: https://msdn.microsoft.com/en-us/library/windows/desktop/ee671223(v=vs.85).aspx
	;
	HandleAutomationEvent(pInterface, pSender, EventID) {

		Sender := new IUIAutomationElement(pSender)
		hWnd := Sender.CurrentNativeWindowHandle
		WinGet, sProcess, ProcessName, ahk_id %hWnd%
		OutputDebug % Format("Window Destroyed - hwnd={:X}, CurrentName={:20.20s}, Class={:20.20s}, Process={:s}", hWnd, Sender.CurrentName, Sender.CurrentClassName, sProcess)
	}
}

class UIA_SnoopWindowsCreated extends UIAutomationEventHandlerImpl {
	;
	; 	Handles a Microsoft UI Automation event, called by the parent class which received the
	;		event call.
	;	@see: https://msdn.microsoft.com/en-us/library/windows/desktop/ee696045(v=vs.85).aspx
	;
	;	IUIAutomationEventHandler 	pInterface	Pointer to our interface address
	;	IUIAutomationElement		pSender		Pointer to Element for which Event happened
	;	EVENTID 					EventID 	The event identifier.
	;		@see: https://msdn.microsoft.com/en-us/library/windows/desktop/ee671223(v=vs.85).aspx
	;
	HandleAutomationEvent(pInterface, pSender, EventID) {
		Sender := new IUIAutomationElement(pSender)
		hWnd := Sender.CurrentNativeWindowHandle
		WinGet, sProcess, ProcessName, ahk_id %hWnd%
		OutputDebug % Format("Window Created - hwnd={:X}, CurrentName={:20.20s}, Class={:20.20s}, Process={:s}", hWnd, Sender.CurrentName, Sender.CurrentClassName, sProcess)
	}
}

global OnCreated := new UIA_SnoopWindowsCreated()
global OnDestroyed := new UIA_SnoopWindowsDestroyed()
global UIA := CUIAutomation()

global DesktopElem := UIA.GetRootElement()

OutputDebug % Format("AddAutomationEventHandler, DesktopElem={}, OnCreated.pInterface={:X}", DesktopElem.CurrentName(), OnCreated.pInterface )

hr := UIA.AddAutomationEventHandler( UIAutomationClientTLConst.UIA_Window_WindowOpenedEventId
	, DesktopElem
	, UIAutomationClientTLConst.TreeScope_Children
	, 0
 	, OnCreated.pInterface )

UIA_Exit() {
	OutputDebug % Format(A_ThisFunc "()")
	; Remove our exit function from the list
	OnExit(A_ThisFunc, 0)

	if (IsObject(UIA)) {
		UIA.RemoveAllEventHandlers()
		UIA := ""
	}

	if (DesktopElem) {
		ObjRelease(DesktopElem)
		DesktopElem := 0
	}

	if(OnCreated)
		OnCreated :=
	if(OnDestroyed)
		OnDestroyed :=

	return 0
}

OnExit("UIA_Exit")


F1::Exit, 0