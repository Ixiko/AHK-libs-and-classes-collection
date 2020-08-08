#include <CWindow>

Class CChildWindow extends CWindow
{
	__New(parent, title, options)
	{
		this.parent := parent
		base.__New(title, options . " +Parent" parent.__Handle)
	}

	GetPos(){
		hwnd := this.__Handle
		Gui, %hwnd%: +LastFound
		WinGetPos x, y, w, h
		return {Top: y, Left: x, Right: x + w, Bottom: y + h}
	}

	GetSize(){
		hwnd := this.__Handle
		Gui, %hwnd%: +LastFound
		WinGetPos x, y, w, h
		;msgbox % h
		return {w: w, h: h}
	}

}
