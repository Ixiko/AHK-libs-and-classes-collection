/*
Tested On		Autohotkey_L version  1.1.13.00 U32
Author 			Nick McCoy (Ronins)
Initial Release Date	May 6, 2014
Version Release Date	May 6, 2014
Version			1.0
*/

Class Subclass 
{
	
	__New()
	{
		return false
	}
	
	AddListener(hWnd, Message, Function) 
	{
		this.hWnd[Message] := Function
		this.DispatchPointer := RegisterCallback("Subclass_Dispatch")
		return, DllCall("Comctl32.dll\SetWindowSubclass", "int", hWnd, "int", this.DispatchPointer, "int", hWnd, "int", 0)
	}
	
	RemoveListener(hWnd, Message)
	{
		if(this.hWnd[Message]=-1 || !IsObject(this.hWnd))
			return, false
		this.hWnd[Message] := -1
		Dummy := 0
		For key, value in this.hWnd
			if(this.hWnd[key]!=-1)
				Dummy++
		if(Dummy)
			return true
		this.hWnd := ""
		return DllCall("Comctl32.dll\RemoveWindowSubclass", "int", hWnd, "int", this.DispatchPointer, "int", hWnd)
	}
	
	GetFunction(Hwnd, Message) 
	{
		if(this.hWnd[Message])
			return this.hWnd[Message]
		Return 0
	}
}
Subclass_Dispatch(Hwnd, Message, wParam, lParam, IdSubclass, RefData) 
{
	Function := Subclass.GetFunction(Hwnd, Message)
	if(Function = -1)
		Exit
	If(Function)
		Function.(Hwnd, Message, wParam, lParam)
	Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", Hwnd, "UInt", Message, "Ptr", wParam, "Ptr", lParam)
}
