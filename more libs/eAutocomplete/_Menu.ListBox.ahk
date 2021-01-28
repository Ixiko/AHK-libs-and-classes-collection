Class ListBox extends eAutocomplete._Menu.BasicControlList {
	__New(_GUIID, _x, _y) {
		local
		base.__New(_GUIID)
		GUI % this._hHost . ":Add", ListBox, % "-Sort -Multi -HScroll +VScroll hwnd_hListBox x" _x . " y" . _y,
		this.HWND := _hListBox
		this.selection := new this.SelectionWrapper(this.HWND)
		_font := this._font := new this.FontWrapper(this.HWND)
		_font.name := "Segoe UI", _font.size := 12, _font.color := "000000"
	}
	font {
		set {
		return this.font
		}
		get {
		return this._font
		}
	}
	_onItemClick := ""
	onItemClick {
		set {
			if (IsFunc(value)) {
				this._onItemClick := StrLen(value) ? Func(value) : value
			} else if (IsObject(value)) {
				this._onItemClick := value
			} else this._onItemClick := ""
		return this._onItemClick
		}
		get {
		return this._onItemClick
		}
	}
	_dispose() {
		sleep, 1
		base._dispose()
		this._font := ""
		this.onItemClick := ""
		this.selection._dispose()
	}
	__Delete() {
		; MsgBox % A_ThisFunc
	}
	resize(_w, _h) {
		GuiControl, Move, % this.HWND, % Format("w{} h{}", _w, _h)
	}
	getPos(ByRef _x:="", ByRef _y:="") {
		WinGetPos, _x, _y,,, % "ahk_id " . this.HWND
	}
	setlist(_list) {
		local
		_delimiter := this.delimiter
		_list := Trim(_list, _delimiter), _count := 0
		if (_list <> "") {
			_threshold := this._MAXITEMS
			StrReplace(_list, _delimiter,, _count)
			if (++_count > _threshold) {
				_count := _threshold, _list := SubStr(_list, 1, InStr(_list, _delimiter,,, ++_threshold) - 1)
			}
		}
		this.itemCount := _count
		GuiControl, -Redraw, % this.HWND
		GuiControl,, % this.HWND, % _delimiter . this._list:=_list
		GuiControl, +Redraw, % this.HWND
		; ((this.itemCount := _count) && this.selection.index:=1) ; <<<<
	}
	getItemFromPointer() {
		local
		static LB_ITEMFROMPOINT := 0x01A9
		; if not (DllCall("IsWindowVisible", "Ptr", this.HWND))
			; return -1
		VarSetCapacity(_POINT_, 8, 0)
		DllCall("GetCursorPos", "Ptr", &_POINT_)
		DllCall("ScreenToClient", "Ptr", this.HWND, "Ptr", &_POINT_)
		_x := NumGet(_POINT_, 0, "UShort"), _y := NumGet(_POINT_, 4, "UShort") << 16
		SendMessage % LB_ITEMFROMPOINT, 0, % (_x + _y),, % "ahk_id " . this.HWND
	return (ErrorLevel & 0xFFFF0000) ? -1 : (ErrorLevel & 0xFFFF)
	}
	_itemClickHandler() {
		local
		KeyWait, LButton, T0.65
		_e := ErrorLevel
		if (DllCall("IsWindowVisible", "Ptr", this.HWND))
			((_onItemClick:=this.onItemClick) && _onItemClick.call(this.selection.text, _e))
	}
	__itemClick(_itemIndex:="") {
		local
		(this.selection.index:=_itemIndex)
		_fn := this._itemClickHandler.bind(this)
		SetTimer % _fn, -1
	}
	itemHeight {
		get {
			static LB_GETITEMHEIGHT := 0x1A1
			SendMessage % LB_GETITEMHEIGHT, 0, 0,, % "ahk_id " . this.HWND
		return ErrorLevel
		}
		set {
		return this.itemHeight
		}
	}
	selectPrevious() {
	this.selection.previousItem()
	}
	selectNext() {
	this.selection.nextItem()
	}
	Class SelectionWrapper {
		__New(_parent) {
			local
			this._parent := _parent
			; _fn := this.__index.bind(this)
			; GuiControl, +g, % _parent, % _fn
		}
		_dispose() {
			; GuiControl, -g, % this._parent,
		}
		__index(_hControl, _GUIEvent, _eventInfo, _errorLevel:="") {
		; ...
		}
		itemCount {
			get {
				static LB_GETCOUNT := 0x18B
				SendMessage % LB_GETCOUNT, 0, 0,, % "ahk_id " . this._parent
			return ErrorLevel
			}
			set {
			return this.itemCount
			}
		}
		previousItem() {
			local
			_index := this.index - 1
			this.index := (_index < 1) ? this.itemCount : _index
		}
		nextItem() {
			local
			_index := this.index + 1
			this.index := (_index > this.itemCount) ? 1 : _index
		}
		isVisible() {
		return DllCall("IsWindowVisible", "Ptr", this._parent)
		}
		index {
			set {
				static LB_SETCURSEL := 0x0186
				if ((value+0 <> "") && value <> this.index)
					SendMessage % LB_SETCURSEL, % --value, 0,, % "ahk_id " . this._parent
			return this.index
			}
			get {
				local
				static LB_GETCURSEL := 0x188
				SendMessage, 0x188, 0, 0,, % "ahk_id " . this._parent
				_pos := ErrorLevel << 32 >> 32
			return ++_pos
			}
		}
		text {
			get {
				local
				ControlGet, _item, Choice,,, % "ahk_id " . this._parent
			return _item
			}
			set {
			return this.text
			}
		}
		offsetTop {
			get {
				static LB_GETTOPINDEX := 0x018E
				SendMessage % LB_GETTOPINDEX, 0, 0,, % "ahk_id " . this._parent
				_e := ErrorLevel
				return this.index - _e
			}
			set {
			return this.offsetTop
			}
		}
	}
}
