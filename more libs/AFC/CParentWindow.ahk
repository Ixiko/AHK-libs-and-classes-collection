#include <CWindow>

class CParentWindow extends CWindow
{
	child_windows := []
	panel_bottom := 0

	__New(title := "", options := "")
	{
		base.__New(title, options)
		hwnd := this.__Handle
		Gui, %hwnd%: +LastFound
		return
	}

	AddChild(type){
		;base.__New("", "-Border +Parent" parent.__Handle)
		cw := new %type%(this, "", "-Border")
		hwnd := cw.__Handle
		this.child_windows[hwnd] := cw
		cw.Show()

		y := this.AllocateSpace(cw)
		cw.Show("w300 X0 Y" y)

		this.OnSize()
		return cw
	}

	GetClientRect(hwnd){
		Gui, %hwnd%: +LastFound
		VarSetCapacity(rect, 16, 0)
        DllCall("GetClientRect", "Ptr", hwnd, "Ptr", &rect)
        ;return {w: NumGet(rect, 8, "Int"), h: NumGet(rect, 12, "Int")}
        return {l: NumGet(rect, 0, "Int"), t: NumGet(rect, 4, "Int") , r: NumGet(rect, 8, "Int"), b: NumGet(rect, 12, "Int")}
	}

	ScreenToClient(hwnd, x, y){
		VarSetCapacity(pt, 16)
		NumPut(x,pt,0)
		NumPut(y,pt,4)
		DllCall("ScreenToClient", "uint", hwnd, "Ptr", &pt)
		x := NumGet(pt, 0, "long")
		y := NumGet(pt, 4, "long")
		
		return {x: x, y: y}
	}

	AdjustToClientCoords(hwnd, obj){
		tmp := this.ScreenToClient(hwnd, 0, 0)
    	obj.Left += tmp.x
    	obj.Right += tmp.x
    	obj.Top += tmp.y
    	obj.Bottom += tmp.y
    	return obj
	}

	RemoveChild(cw){
		hwnd := cw.__Handle
		this.child_windows.remove(hwnd,"")  ; The ,"" is VITAL, else remaining HWNDs in the array are decremented by one

		this.panel_bottom := 0
		For key, value in this.child_windows {
			this.child_windows[key].Show("X0 Y" . this.panel_bottom)
			;this.panel_bottom += this.GetClientRect(this.child_windows[key].__Handle).b
			this.panel_bottom += this.child_windows[key].GetSize().h
		}
		this.OnSize()
	}
	
	AllocateSpace(window){
		tmp := this.panel_bottom
		this.panel_bottom += this.GetClientRect(window.__Handle).b + 2
		return tmp
	}
}
