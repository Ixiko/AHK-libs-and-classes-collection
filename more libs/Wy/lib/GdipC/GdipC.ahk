class GdipC
{
	_version := "1.0.1"
	__New()  {
		
		if !DllCall("GetModuleHandle", "str", "gdiplus")
			DllCall("LoadLibrary", "str", "gdiplus")
		VarSetCapacity(si, (A_PtrSize = 8) ? 24 : 16, 0), si := Chr(1)
		DllCall("gdiplus\GdiplusStartup", "uptr*", pToken, "uptr", &si, "uint", 0)
		this.pToken := pToken
		
		this._New := Gdip.__New
		Gdip.__New := Gdip._DummyNew
	}
	
	_DummyNew() {
		return false
	}
	
	__Delete() {
		this.Dispose()
	}
	
	Dispose() {
		DllCall("gdiplus\GdiplusShutdown", "uptr", this.pToken)
		if (hModule := DllCall("GetModuleHandle", "str", "gdiplus"))
			DllCall("FreeLibrary", "uptr", hModule)
		
		Gdip.__New := this._New
	}
	
	class Size
	{
		; See: https://msdn.microsoft.com/en-us/library/windows/desktop/ms534504(v=vs.85).aspx
		_version := "1.0.0"
		Width := 0
		Height := 0
		
		__New(params*)	{
			c := params.MaxIndex()
			if (c == "") {
				this.Width := 0
				this.Height := 0
			}
			else  if (c == 1) {
				if (params[1].__Class == "GdipC.Size") {
					this.Width := params[1].Width
					this.Height := params[1].Height
				}
				else { 
					throw "Incorrect parameter type for " A_ThisFunc
				}
			}
			else  if (c == 2) {
				this.Width := params[1]
				this.Height := params[2]
			}
			else {
				throw "Incorrect number of parameters for "  A_ThisFunc
			}
		}
		empty() {
			return ((this.Width ==0) && (this.Height == 0))
		}
		equals(params*) {
			c := params.MaxIndex()
			if (c == 1) {
				if (params[1].__Class == "GdipC.Size") {
					return ((this.Width == params[1].Width) && (this.Height == params[1].Height))
				}
				else { 
					throw "Incorrect parameter type for " A_ThisFunc
				}
			}
			else {
				throw "Incorrect number of parameters for "  A_ThisFunc
			}
		}
		; The original implementation overloads several operators
		; As this is not possible with AHK, a separate function is offered
		subtract(params*) {
			; Alternative to overloaded minus-operator ("-")
			c := params.MaxIndex()
			if (c == 2) {
				return new GdipC.Size((this.Width - params[1]),(this.Height - params[2]))
			}
			if (c == 1) {
				if (params[1].__Class == "GdipC.Size") {
					return new GdipC.Point((this.Width - params[1].Width),(this.Height - params[1].Height))
				}
				else { 
					throw "Incorrect parameter class for " A_ThisFunc
				}
			}
			else {
				throw "Incorrect number of parameters for "  A_ThisFunc
			}
		}
		add(params*) {
			; Alternative to overloaded plus-operator ("+")
			c := params.MaxIndex()
			if (c == 2) {
				return new GdipC.Size((this.Width + params[1]),(this.Height + params[2]))
			}
			if (c == 1) {
				if (params[1].__Class == "GdipC.Size") {
					return new GdipC.Point((this.Width + params[1].Width),(this.Height + params[1].Height))
				}
				else { 
					throw "Incorrect parameter class for " A_ThisFunc
				}
			}
			else {
				throw "Incorrect number of parameters for "  A_ThisFunc
			}
		}
	}
	class Point
	{
		; See: https://msdn.microsoft.com/en-us/library/windows/desktop/ms534487(v=vs.85).aspx
		_version := "1.0.0"
		X := 0
		Y := 0
		
		__New(params*) {
			c := params.MaxIndex()
			if (c == 0) {
				this.X := 0
				this.Y := 0
			}
			else  if (c == 1) {
				if (params[1].__Class == "GdipC.Point") {
					this.X := params[1].X
					this.Y := params[1].Y
				}
				else if (params[1].__Class == "GdipC.Size") {
					this.X := params[1].Width
					this.Y := params[1].Height
				}
				else { 
					throw "Incorrect parameter class for " A_ThisFunc
				}
			}
			else  if (c == 2) {
				this.X := params[1]
				this.Y := params[2]
			}
			else {
				throw "Incorrect number of parameters for "  A_ThisFunc
			}
		}
		
		equals(sz) {
			if (sz.__Class == "GdipC.Point") {
				return ((this.X == sz.X) && (this.X == sz.X))
			}
			else { 
				throw "Incorrect parameter class for " A_ThisFunc
			}
		}
		
		; The original implementation overloads several operators
		; As this is not possible with AHK, a separate function is offered
		
		subtract(params*) {
			; Alternative to overloaded minus-operator ("-")
			c := params.MaxIndex()
			if (c == 2) {
				return new GdipC.Point((this.X - params[1]),(this.Y - params[2]))
			}
			if (c == 1) {
				if (params[1].__Class == "GdipC.Point") {
					return new GdipC.Point((this.X - params[1].X),(this.Y - params[1].X))
				}
				else if (params[1].__Class == "GdipC.Size") {
					return new GdipC.Point((this.X - params[1].Width),(this.Y - params[1].Height))
				}
				else { 
					throw "Incorrect parameter class for " A_ThisFunc
				}
			}
			else {
				throw "Incorrect number of parameters for "  A_ThisFunc
			}
		}
		add(params*) {
			; Alternative to overloaded minus-operator ("-")
			c := params.MaxIndex()
			if (c == 2) {
				return new GdipC.Point((this.X + params[1]),(this.Y + params[2]))
			}
			if (c == 1) {
				if (params[1].__Class == "GdipC.Point") {
					return new GdipC.Point((this.X + params[1].X),(this.Y + params[1].X))
				}
				else if (params[1].__Class == "GdipC.Size") {
					return new GdipC.Point((this.X + params[1].Width),(this.Y + params[1].Height))
				}
				else { 
					throw "Incorrect parameter class for " A_ThisFunc
				}
			}
			else {
				throw "Incorrect number of parameters for "  A_ThisFunc
			}
		}
	}
	class Rect
	{
		; See https://msdn.microsoft.com/en-us/library/windows/desktop/ms534495(v=vs.85).aspx
		_version := "1.0.0"
		
		__New(params*) {
			c := params.MaxIndex()
			if (c == "") {
				this.x := 0
				this.y := 0
				this.Width := 0
				this.Height := 0
			}
			else if (c == 4)
			{
				this.x := params[1]
				this.y := params[2]
				this.width := params[3]
				this.height := params[4]
			}
			else if (c == 2)
			{
				if ((params[1].__Class == "GdipC.Point") && (params[2].__Class == "GdipC.Size")) {
					this.x := params[1].x
					this.y := params[1].y
					this.width := params[2].width
					this.height := params[2].height
				}
				Else
					throw "Wrong parameter types for "  A_ThisFunc
			}
			else
				throw "Incorrect number of parameters for "  A_ThisFunc
			
		}
		clone() {
			r := new GdipC.Rect(this.x, this.y, this.width, this.height)
			return r
		}
		contains(params*) {
			c := params.MaxIndex()
			if (c == 1) {
				if (params[1].__Class == "GdipC.Point") {
					return this.contains(params[1].x, params[1].y)
				}
				if (params[1].__Class == "GdipC.Rect") {
					x := params[1].x
					y := params[1].y
					width := params[1].width
					height := params[1].height
					if ((x >= this.x) && ((x + width) <= (this.x + this.width)) && (y >= this.y) && ((y + height) <= (this.y + this.height))) {
						return true
					}
				}
				else
					throw "Incorrect parameter type for " A_ThisFunc
			} else if (c == 2) {
				x := params[1]
				y := params[2]
				if ((x >= this.x) && (x <= (this.x + this.width)) && (y >= this.y) && (y <= (this.y + this.width))) {
					return true
				}
			}
			else
				throw "Incorrect number of parameters for "  A_ThisFunc
			return false
		}
		equals(params*) {
			c := params.MaxIndex()
			if (c = 1) {
				if (params[1].__Class == "GdipC.Rect") {
					if ((params[1].x == this.x) && (params[1].y == this.y) && (params[1].width == this.width) && (params[1].height == this.height)) {
						return true
					}
				}
				else
					throw "Incorrect parameter type for " A_ThisFunc
			}
			else
				throw "Incorrect number of parameters for "  A_ThisFunc
			return false
		}
		getBottom() {
			return (this.y + this.height)
		}
		getBounds() {
			return this.clone()
		}
		getLeft() {
			return (this.x)
		}
		getLocation() {
			pt := new GdipC.Point(this.x, this.y)
			return pt
		}
		getRight() {
			return (this.x + this.width)
		}
		getSize() {
			sz := new GdipC.Size(this.width, this.height)
			return sz
		}
		getTop() {
			return (this.y)
		}
		inflate(params*) {
			c := params.MaxIndex()
			if (c = 1) {
				if (params[1].__Class == "GdipC.Point") {
					this.inflate(params[1].x, params[1].y)
				}
				else
					throw "Wrong parameter types for "  A_ThisFunc
			}
			else if (c = 2) {
				this.x := this.x - params[1]
				this.y := this.y - params[2]
				this.width := this.width + 2*params[1]
				this.height := this.height + 2*params[2]
			}
			else
				throw "Incorrect number of parameters for "  A_ThisFunc
			return false
		}
		intersect(params *) {
			c := params.MaxIndex()
			if (c = 1) {
				if (params[1].__Class == "GdipC.Rect") {
					right := (this.getRight() < params[1].getRight())?this.getRight():params[1].getRight()
					left := (this.getLeft() > params[1].getLeft())?this.getLeft():params[1].getLeft()
					bottom := (this.getBottom() < params[1].getBottom())?this.getBottom():params[1].getBottom()
					top := (this.getTop() > params[1].getTop())?this.getTop():params[1].getTop()
					ret := new GdipC.Rect(left, top, right-left, bottom-top)
					bIntersects := !ret.isEmptyArea()
					if (!bIntersects) {
						; if they don't intersect the result is an null-sized rectangle
						ret := new GdipC.Rect()
					}
					this.x := ret.x
					this.y := ret.y
					this.width := ret.width
					this.height := ret.height
					Outputdebug "this-after:" this.x "-" this.y "-" this.width "-" this.height
					return (bIntersects)
				}
				else
					throw "Wrong parameter types for "  A_ThisFunc
			}
			else
				throw "Incorrect number of parameters for "  A_ThisFunc
			return false
		}
		intersectsWith(params *) {
			c := params.MaxIndex()
			if (c = 1) {
				if (params[1].__Class == "GdipC.Rect") {
					return  ((this.GetLeft() < params[1].GetRight()) && (this.GetTop() < params[1].GetBottom()) && (this.GetRight() > params[1].GetLeft()) && (this.GetBottom() > params[1].GetTop()))
				}
				else
					throw "Wrong parameter types for "  A_ThisFunc
			}
			return false
		}
		isEmptyArea() {
			return (this.width <= 0) || (this.height <= 0)
		}
		offset(params*) {
			c := params.MaxIndex()
			if (c = 1) {
				if (params[1].__Class == "GdipC.Point") {
					this.offset(params[1].x, params[1].y)
				}
				else
					throw "Wrong parameter types for "  A_ThisFunc
			}
			else if (c = 2) {
				this.x := this.x + params[1]
				this.y := this.y + params[2]
			}
			else
				throw "Incorrect number of parameters for "  A_ThisFunc
			return
		}
		union(params *) {
			c := params.MaxIndex()
			if (c = 1) {
				if (params[1].__Class == "GdipC.Rect") {
					right := (this.getRight() > params[1].getRight())?this.getRight():params[1].getRight()
					left := (this.getLeft() < params[1].getLeft())?this.getLeft():params[1].getLeft()
					bottom := (this.getBottom() > params[1].getBottom())?this.getBottom():params[1].getBottom()
					top := (this.getTop() < params[1].getTop())?this.getTop():params[1].getTop()
					this.x := left
					this.y := top
					this.width := right-left
					this.height := bottom-top
					return (!this.isEmptyArea())
				}
				else
					throw "Wrong parameter types for "  A_ThisFunc
			}
			else
				throw "Incorrect number of parameters for "  A_ThisFunc
		}
	}
}