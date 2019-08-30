; This file contains misc core api function wrappers. 
;<< Event Api >>
class event {
	createEvent(lpEventAttributes, bManualReset, bInitialState, lpName){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682396(v=vs.85).aspx (CreateEvent function)
		; Note:
		;	- Use the CloseHandle function to close the handle. The system closes the handle automatically when the process terminates.
		;	  The event object is destroyed when its last handle has been closed.
		;
		/*
		LPSECURITY_ATTRIBUTES lpEventAttributes,
		BOOL                  bManualReset,
		BOOL                  bInitialState,
		LPCTSTR               lpName
		*/
		local handle
		if !(handle:=DllCall("Kernel32.dll\CreateEvent", "Ptr", lpEventAttributes, "Int", bManualReset, "Int", bInitialState, "Str", lpName, "Ptr"))		
			xlib.exception("CreateEvent failed for name: " . lpName . ".",,-2)
		return handle
	}
	setEvent(hEvent){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686211(v=vs.85).aspx (SetEvent function)
		if !DllCall("Kernel32.dll\SetEvent", "Ptr", hEvent)
			xlib.exception("SetEvent failed for handle: " hEvent,,-2)
		return
	}
}	; End event

	;<< misc >>

class misc {
	closeHandle(hObject){
		; Url:
		;	- http://msdn.microsoft.com/en-us/library/windows/desktop/ms724211%28v=vs.85%29.aspx (CloseHandle function)
		if !DllCall("Kernel32.dll\CloseHandle", "Ptr", hObject)
			xlib.exception("Close handle failed to close handle: " hObject,,-2)
	}
}	; End misc
