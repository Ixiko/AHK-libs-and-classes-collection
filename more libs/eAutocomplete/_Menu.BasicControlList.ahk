Class BasicControlList extends eAutocomplete._Window.GUIControl {
	_MAXITEMS := 52
	_list := ""
	itemCount := 0
	_delimiter := "|"
	_maxVisibleItems := 5
	__New(_GUIID) {
		base.__New(_GUIID)
		this.delimiter := this.delimiter
		this.maxVisibleItems := this.maxVisibleItems
	}
	delimiter { ; to do: protected
		set {
			GUI % this._hHost . ":+Delimiter" . this._delimiter:=value:=RegExReplace(value, "^(Space|Tab|.)\K.*", "")
		return this._delimiter
		}
		get {
		return this._delimiter
		}
	}
	maxVisibleItems {
		set {
			if ((1 <= value) && (value <= this._MAXITEMS))
				return this._maxVisibleItems:=Floor(value)
			else return this._maxVisibleItems
		}
		get {
		return this._maxVisibleItems
		}
	}
	hasVScrollBar {
		get {
		return (this.itemCount > this.maxVisibleItems)
		}
		set {
		return this.hasVScrollBar
		}
	}
	getIdealWidth(_list) {
		local
		_widthBuffer := _w := 0
		_listLines := A_ListLines
		ListLines, 0
		_font := this.font
		for _index, _loopField in StrSplit(_list, this.delimiter,, -1)
		{
			_font.getTextExtentPoint(_loopField, _w)
			_w &= 0xFFFFFFFF, ((_w > _widthBuffer) && _widthBuffer:=_w)

		}
		ListLines % _listLines
	return _widthBuffer, (_widthBuffer && _widthBuffer += 8)
	}
	autoWH() {
		local
		this._Resizing.getDim(_w, _h, this._list)
		(this.hasVScrollBar) ? _h -= (this.itemCount - this.maxVisibleItems) * this.itemHeight
		this.resize(_w, _h)
	}
	__click() {
		local
		static EAT := 1
		_item := this.getItemFromPointer()
		if (_item > -1)
			return EAT, this.__itemClick(++_item)
		return not EAT
	}
	getItemFromPointer() {
	return -1
	}
	__itemClick(_item) {
	}
	_dispose() {
		this._Resizing := ""
	}
	itemHeight {
		set {
		return 0
		}
		get {
		return 0
		}
	}
	_resizingStrategy := "Menu"
	resizingStrategy {
		set {
			local
			for _strategy in this.DimStrategies {
				if ((_strategy = value) && (_strategy <> "__Class")) {
					_dimStrategy := this.DimStrategies[value], this._Resizing := new _dimStrategy(this._hHost, this)
				return this._resizingStrategy:=value
				}
			}
			throw Exception("The resizing strategy is not available.", -1, value)
		; return this._resizingStrategy
		}
		get {
		return this._resizingStrategy
		}
	}
	Class DimStrategies {
		Class DropDownList {
			__New(_hHost, _control) {
				this._parent := DllCall("User32.dll\GetParent", "Ptr", _hHost, "Ptr")
				this._itemsBox := _control
			}
			getDim(ByRef _w:="", ByRef _h:="", _list:="") {
				local
				static SM_CYHSCROLL := DllCall("GetSystemMetrics", "UInt", 3)
				_itemsBox := this._itemsBox
				_wIdeal := _itemsBox.getIdealWidth(_list)
				ControlGetPos,,, _w,,, % "ahk_id " . this._parent
				_h := (_itemsBox.itemCount + 1) * _itemsBox.itemHeight + (_wIdeal > _w) * SM_CYHSCROLL
			}
			__Delete() {
				; ; MsgBox % A_ThisFunc
			}
		}
		Class Menu {
			__New(_hHost, _control) {
				this._itemsBox := _control
			}
			getDim(ByRef _w:="", ByRef _h:="", _list:="") {
				static SM_CXVSCROLL := DllCall("GetSystemMetrics", "UInt", 2)
				local
				_itemsBox := this._itemsBox
				_w := _itemsBox.getIdealWidth(_list) + _itemsBox.hasVScrollBar * SM_CXVSCROLL
				_h := (_itemsBox.itemCount + 1) * _itemsBox.itemHeight
			}
			__Delete() {
				; ; MsgBox % A_ThisFunc
			}
		}
	}
}
