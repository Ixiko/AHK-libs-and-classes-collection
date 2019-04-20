Class WindowPosition extends GuiBase.PositionType {
	Set(Coord, Val) {
		this.Parent.Show(Coord . Val " " (this.Parent.Visible ? "" : "Hide"))
	}
	
	Get(Coord) {
		WinGetPos, x, y, w, h, % "ahk_id" this.Parent.hwnd
		return _:=%Coord%
	}
}

Class ControlPosition extends GuiBase.PositionType {
	Set(Coord, Val) {
		this.Parent.MoveDraw(Coord . Val)
	}
	
	Get(Coord) {
		ControlGetPos, x, y, w, h,, % "ahk_id" this.Parent.hwnd
		return _:=%Coord%
	}
}

Class PositionType {
	
	__New(Parent) {
		this.Parent := Parent
	}
	
	_NewEnum() {
		this.i := 0
		return this
	}
	
	Next(ByRef k, ByRef v) {
		static EnumOrder := ["X", "Y", "W", "H"]
		if (this.i = 4)
			return false
		this.i++
		k := EnumOrder[this.i]
		v := this[k]
		return true
	}
	
	X {
		set {
			this.Set("X", value)
		}
		
		get {
			return this.Get("X")
		}
	}
	
	Y {
		set {
			this.Set("Y", value)
		}
		
		get {
			return this.Get("Y")
		}
	}
	
	W {
		set {
			this.Set("W", value)
		}
		
		get {
			return this.Get("W")
		}
	}
	
	H {
		set {
			this.Set("H", value)
		}
		
		get {
			return this.Get("H")
		}
	}
}