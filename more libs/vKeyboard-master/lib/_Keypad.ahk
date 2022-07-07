Class _KeypadAXObjectWrapper {
	_Init() {
		local
		global _KeypadAXObjectWrapper
		static _ := _KeypadAXObjectWrapper._Init()
		_html =
		(LTrim Join`r`n
		<!DOCTYPE html>
		<html lang="en">
		<head>
			<meta http-equiv="X-UA-Compatible" content="IE=edge" charset="utf-8">
			<title>title</title>
				<style type="text/css" id="userDefined">
				</style>
		</head>
			<body>
			<canvas id="_canvas"></canvas>
				<ul id="Keypad">
					<div id="variants"><button class="variant"></button></div>
					<div id="row"><button class="key"></button></div>
				</ul>
			</body>
			<script>
				document.body.addEventListener("contextmenu", function (_event) {
				  _event.preventDefault();
				});
			</script>
		</html>
		)
		_KeypadAXObjectWrapper._html := _html
		_CSS =
		(LTrim Join`r`n
			#Keypad {
				-ms-user-select: none;
				list-style: none;
				display: flex;
				flex-flow: column nowrap;
				position: fixed;
				top: 0;
				bottom: 0;
				left: 0;
				right: 0;
				margin: 0;
				padding: 20px 20px 20px 20px;
			}
			div.row {
				pointer-events: initial;
				display: flex;
				flex-flow: row nowrap;
				justify-content: space-around;
				margin: 1px 0px;
				height: 100`%;
				opacity: 1;
			}
			button.key {
				pointer-events: inherit;
				margin: 0px 1px;
				width: 100`%;
				height: 100`%;
				opacity: inherit;
				font-size: inherit;
			}

			#variants {
				z-index: 1;
				display: flex;
				flex-flow: row nowrap;
				justify-content: space-around;
				padding: 0px 0px 4px 0px;
			}
			button.variant {
				margin: 0px 1px;
				width: 100`%;
				animation-name: anim;
				animation-iteration-count: 1;
				animation-delay: 0s;
				animation-duration: 0.7s;
				animation-timing-function: ease-in-out;
				animation-fill-mode: forwards;
				display: none;
				font-size: inherit;
			}
			@keyframes anim {
				0`% {
					height: 1`%;
				}
				100`% {
					height: 100`%;
				}
			}
		)
		_KeypadAXObjectWrapper._CSS := _CSS
	}
	__New(_hWndActiveX) {
		local
		static _classes := ["Shell DocObject View", "Shell Embedding", "AtlAxWin"]
		WinGetClass, _className, % "ahk_id " . this._hWnd0:=_hWndActiveX
		if (_className <> "Internet Explorer_Server") {
			throw Exception("The host control is not a valid ActiveX control.", -1, _hWndActiveX)
		; return
		}
		for _each, _class in _classes {
			_hWndActiveX := DllCall("user32\GetAncestor", "Ptr", _hWndActiveX, "UInt", 1, "Ptr") ; GA_PARENT := 1 (cf. https://www.autohotkey.com/boards/viewtopic.php?t=49374#profile219333)
			WinGetClass, _className, % "ahk_id " . _hWndActiveX
			if (_className <> _class) {
				throw Exception("The host control is not a valid ActiveX control.", -1, _hWndActiveX)
			; return
			}
		}
		GuiControlGet, _AXWrapperObject,, % this.HWND:=_hWndActiveX
		this._AXObject := _AXWrapperObject
		_doc := this._docRef := _AXWrapperObject.document
		_doc.open(), _doc.write(this._html), _doc.close()
		_styles := _doc.createElement("style")
		_styles.type := "text/css", _styles.innerText := this._CSS
		_doc.head.appendChild(_styles)
		this._parentWindowRef := _doc.parentWindow
		this._pad := _doc.getElementById(this._padId:="Keypad")
		this._rowDivs := _doc.getElementsByClassName(this._rowDivsClassName:="row")
		this._keys := _doc.getElementsByClassName(this._keysClassName:="key")
		this._variantsDiv := _doc.getElementById(this._variantsDivId:="variants")
		this._variants := _doc.getElementsByClassName(this._variantsClassName:="variant")
		this._canvas := _doc.getElementById("_canvas")
	}
	AXObject {
		set {
		return this._AXObject
		}
		get {
		return this._AXObject
		}
	} ; ++++
}
Class _KeypadGraphicsMapping extends _KeypadAXObjectWrapper {
	static _keymaps := {}
	static _cascadingStyleSheets := []
	_style := ""
	_layer_ := 1
	, _layout_ := ""
	_map := {}
	, __columns := 0
	, __rows := -1
	, _columns := 0
	, _rows := 0
	_altMode := false
	__New(_hWndActiveX) {
		local
		base.__New(_hWndActiveX)
		_computedStyle := this._parentWindowRef.getComputedStyle(this._pad)
		_offsetLeft := RTrim(_computedStyle.getPropertyValue("padding-left"), "px")
		, _offsetRight := RTrim(_computedStyle.getPropertyValue("padding-right"), "px")
		this._padPaddingX := _offsetLeft + _offsetRight
		_offsetTop := RTrim(_computedStyle.getPropertyValue("padding-top"), "px")
		, _offsetBottom := RTrim(_computedStyle.getPropertyValue("padding-bottom"), "px")
		this._padPaddingY := _offsetTop + _offsetBottom
	}
	altMode {
		set {
		return this._altMode
		}
		get {
		return this._altMode
		}
	}
	columns {
		set {
		return this._columns
		}
		get {
		return this._columns
		}
	}
	rows {
		set {
		return this._rows
		}
		get {
		return this._rows
		}
	}
	layer {
		set {
		return this._layer_
		}
		get {
		return this._layer_
		}
	}
	_layer {
		set {
		return value, this._layer_ := value, this.suggestVariants(), this._updateLayer(this._map, value)
		}
		get {
		return this._layer_
		}
	}
	layers {
		get {
		return this._map.count()
		}
		set {
		return this._map.count()
		}
	}
	layout {
		set {
		return this._layout_
		}
		get {
		return this._layout_
		}
	}
	_layout[_name, _map] {
		set {
			local
			this.altReset()
			this._layout_ := _name, this._updateLayout(this._map:=_map, this._layer_:=value, _x, _y)
			this._rows := _y, this._columns := _x
			this.fitContent() ; ~
		return value
		}
		get {
		return this._layout_
		}
	}
	_updateLayout(_map, _layer, ByRef _x:=0, ByRef _y:=0) {
		local
		(IsByRef(_x) && _x:=0), (IsByRef(_y) && _y:=0)
		_divPrefix := "<div class='" . this._rowDivsClassName . "'>`r`n"
		for _y, _row in _map[_layer], _str := "" {
			_str .= _divPrefix
			for _x, _item in _row {
				_str .= this._getKeyOuterHtml(_x, _y, _item) . "`r`n"
			}
			_str .= "</div>`r`n"
		}
		_variants := "<div id='" . this._variantsDivId . "'>`r`n"
		Loop % _x { ; ~
			_variants .= this._getVariantOuterHtml(a_index) . "`r`n"
		}
		_variants .= "</div>`r`n"
		_str := _variants . _str
		this._pad.innerHTML := _str
	}
	_updateLayer(_map, _layer) {
		local
		for _y, _row in _map[_layer], _i := -1 {
			for _x, _item in _row {
				this._keys[++_i].innerText := this._getItemText(_item)
			}
		}
	}
		_getVariantOuterHtml(_x) { ; ~
		return "<button class='" . this._variantsClassName . "'></button>"
		}
		_getKeyOuterHtml(_x, _y, _item) {
		return "<button class='" . this._keysClassName . "'>" . this._getItemText(_item) . "</button>"
		}

	suggestVariants(_params*) {
			local
			_boolean := this._altMode:=!!this.__columns:=_params.count() ; ~
		return this._altMode, (_boolean) ? this._displayVariants(_params) : this._hideVariants()
	}
	_displayVariants(_params) {
		local
		for _k, _v in _params, _variants := this._variants {
			try _e := _variants[ a_index - 1 ]
			catch
				break ; ~
			_e.style.display := "block", _e.innerText := _v
		}
		this._disablePad(true)
	}
	_hideVariants() {
		local
		_variants := this._variants
		Loop % _variants.length {
			_e := _variants[ a_index - 1 ]
			_e.style.display := "none", _e.innerText := ""
		}
		this._disablePad(false)
	}
	_disablePad(_boolean) {
		local
		_rowDivs := this._rowDivs
		if (_boolean) {
			Loop % _rowDivs.length {
				_e :=  _rowDivs[ a_index - 1 ]
				_e.style.opacity := "0.4", _e.style.pointerEvents := "none"
			}
		} else {
			Loop % _rowDivs.length {
				_e :=  _rowDivs[ a_index - 1 ]
				_e.style.opacity := "1", _e.style.pointerEvents := "initial"
			}
		}
	}

	defineStyle(_name, _pathOrContent) { ; http://jigsaw.w3.org/css-validator/api.html
		local
		if not (StrLen(_name)) {
			throw Exception("The style name is not valid.", -1, "")
		; return
		}
		SplitPath, % _pathOrContent,,,,, _outDrive
		if (_outDrive <> "") {
			try _fileObject:=FileOpen(_pathOrContent, 4+8+0, "UTF-8")
			catch {
				throw Exception("Failed attempt to open the file.", -1)
			; return
			}
			_cascadingStyleSheet := _fileObject.read(), _fileObject.close()
		} else _cascadingStyleSheet := _pathOrContent
		this._cascadingStyleSheets[_name] := _cascadingStyleSheet
	} ; ++++++++++
	style {
		set {
		return this._style
		} ; ++++
		get {
		return this._style
		}
	}
	backgroundColor {
		set {
			return this.backgroundColor
		}
		get { ; https://developer.mozilla.org/fr/docs/Web/CSS/Type_color
			local
			_bkColor := LTrim(this._docRef.body.currentStyle.getAttribute("background-color"), "#") ; ~
		return (_bkColor = "transparent") ? "FFFFFF" : _bkColor
		}
	}

	fontSize {
		set {
			if value not between 8 and 112
				return this._fontSize
			this._pad.style.fontSize := value . "px"
		return this._fontSize:=RTrim(this._pad.currentStyle.getAttribute("font-size"), "px")
		}
		get {
		return this._fontSize
		}
	}
	_decreaseFontSize() {
		this.fontSize := this.fontSize - 2
	}
	_increaseFontSize() {
		this.fontSize := this.fontSize + 2
	}

	_onResize_ := Func("Object")
	_onResize {
		set {
		return this._onResize_ := value
		}
		get {
		return this._onResize_
		}
	}
	redraw() {
		this.fontSize++, this.fontSize--
	} ; ++++
	expand() {
		this.fitContent(this._fontSize + 2)
	}
	shrink() {
		this.fitContent(this._fontSize - 2)
	}
	fitContent(_size:="", _multiplier:=6) {
		local
		this._measureGridBasis(_size, _basis, _multiplier)
		this.fontSize := _size
		_w := _basis * this._columns + this._padPaddingX
		_h := _basis * this._rows + this._padPaddingY
		GuiControl, Move, % this.HWND, % "w" . _w . " h" . _h
		((_fn:=this._onResize_) && _fn.call(_w, _h))

	}
		_measureGridBasis(ByRef _fontSize:="", ByRef _basis:="", _multiplier:=6) {
			local
			_c := this._canvas, _ctx := _c.getContext("2d")
			_e := this._keys[ 0 ] ; ~
			_cs := this._parentWindowRef.getComputedStyle(_e)
			_font := _cs.getPropertyValue("font-style")
				. A_Space . _cs.getPropertyValue("font-weight")
				. A_Space . _cs.getPropertyValue("font-stretch")
				. A_Space . (_fontSize:=(_fontSize <> "") ? _fontSize . "px" : _cs.getPropertyValue("font-size")) ; ~
				. A_Space . _cs.getPropertyValue("font-line-height")
				. A_Space . _cs.getPropertyValue("font-family") ; https://developer.mozilla.org/en-US/docs/Web/CSS/font
			_ctx.font := _font
			_fontSize := RTrim(_fontSize, "px")
			_textMetrics := _ctx.measureText(SubStr((_e.innerText = "") ? Chr(9608) : _e.innerText, 1, 1)) ; ~ https://unicode-table.com/en/2588/
			_basis := _textMetrics.width * _multiplier
		}

	_dispose() {
		this._onResize_ := ""
	}
	; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	Class Keymap {
		__New(_name, _objectDescription, _defaultObjectWrapper, _defaultCallback:="", _validate:=true) { ; ++++
			local
			global JSON
			; if not (StrLen(_name)) {
				; throw Exception("Invalid keymap name.")
			; return
			; }
			if not (IsObject(this._defaultObjectWrapper:=_defaultObjectWrapper)) {
				throw Exception("The object wrapper does not exist.",, _defaultObjectWrapper)
			; return
			}
			if (_defaultCallback = "") {
				this._defaultCallback := "call"
			} else {
				if not (!IsObject(_defaultCallback) && IsFunc(_defaultCallback)) { ; +++++
					_methodName := _defaultObjectWrapper.__Class . "." . _defaultCallback
					if not (IsFunc(_methodName)) {
						throw Exception("The function or method does not exist.",, _defaultCallback " / " _methodName)
					; return
					}
					_defaultCallback := Func(_defaultObjectWrapper.__Class . "." . _defaultCallback)
				}
				this._defaultCallback := _defaultCallback
			}
			try this._map:= _map := JSON.Load(_objectDescription)
			catch _exception {
				throw _exception
			; return
			}
			if (_validate) {
				if not (this._validateMap(_map)) {
					throw Exception("Invalid map.")
				; return
				}
			}
			; (IsByRef(_objectDescription) && _objectDescription := JSON.Dump(_map,, 4))
			; FileAppend % _objectDescription, % A_Desktop . "\JSON_test.json", UTF-8
		}

		_validateMap(_map) {
			local
			if not (_l:=_map.count())
				return false
			_defaultObjectWrapper := this._defaultObjectWrapper
			_lastFoundColumns := 0
			Loop % _l {
				_layer := _map[ a_index ]
				if not (_rows:=_layer.count())
					return false
				if not (_count:=_layer[ 1 ].count())
					return false
				if ((_lastFoundColumns <> 0) && (_lastFoundColumns <> _count))
					return false
				_lastFoundColumns := _count
				Loop % _rows {
					_row := _layer[ a_index ]
					for _k, _v in _row, _columns := 0 {
						if not (this._validateAndNormalizeEntity(_defaultObjectWrapper, _v))
							return false
						_row[_k] := _v, ++_columns
					}
					if ((a_index <> _rows) && (_columns <> _layer[ a_index + 1 ].count()))
						return false
				}
			}
			return true
		}
			_validateAndNormalizeEntity(_defaultObjectWrapper, ByRef _v:="") {
				local
				if (IsObject(_v)) {
					if not (_v.hasKey("caption") && ((_v.hasKey("f") && IsFunc(_v.f))
					|| (_v.f:=_defaultObjectWrapper[_v.f])
					|| _v.f:=this._defaultCallback))
						return false
				} else _v := {"caption": _v, "f": this._defaultCallback}
			return true
			}
	}
	; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	defineLayout(_name, ByRef _objectDescription, _defaultObjectWrapper, _defaultCallback:="") {
		local _inst, _exception, _classPath, _className, _obj
		_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1)
		_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className%
		try _inst := new _obj.Keymap(_name, _objectDescription, _defaultObjectWrapper,  _defaultCallback) ; +++++++
		catch _exception {
			throw Exception(_exception.message, -1, _exception.extra)
		; return
		}
		_obj._keymaps[_name] := _inst._map
	}
		_getItemText(_item) {
		return _item.caption
		}
}
Class _KeypadEvents extends _KeypadGraphicsMapping {
	static _axesToSections := {"_X": "_columns", "_Y": "_rows", "_Xv": "__columns", "_Yv": "__rows"}
	_X_ := 1
	, _Y_ := 1
	_Xv_ := 1
	, _Yv_ := -1
	_movementsParams := {0: {Down: [], Left: [], Right: [], Up: []}, 1: {Down: [], Left: [], Right: [], Up: []}}
	_arrowsSensitivity := 0.07
	_hkEnterObject := [] ; ~
	_lastFoundX := 1
	_lastFoundY := 1
	_altIndex := 0
	Class _HostWindowWrapper {
		__New(_hWndActiveX) {
			this.HWND := Format("0x{:x}", DllCall("user32\GetAncestor", "Ptr", _hWndActiveX, "UInt", 2, "Ptr")) ; GA_ROOT := 2
		}
	}
	__New(_hWndActiveX) {
		this._hostWindow := new this._HostWindowWrapper(_hWndActiveX)
		base.__New(_hWndActiveX)
		sleep, 15
		this._timestamp := A_TickCount
		this._fnIf1 := _KeypadEvents._mouseIsOver.bind("", this._hWnd0)
		; this._fnIf2 := _KeypadEvents._areVariantsDisplayed.bind("", this._hostWindow.HWND, this._variants)
		this._fnIf2 := _KeypadEvents._areVariantsDisplayed.bind("", this._hostWindow.HWND)
		this._setMovementsParams("_Y", 1, "_X", -1, "_X", 1, "_Y", -1, "_Xv", -1, "_Xv", -1, "_Xv", 1, "_Xv", 1)
		this._setDirectionHotkeys()
		this._setClickHotkey(), this._setEnterHotkey()
		this._setEscapeHotkey()
		this._updateFocus()
	}
	altIndex {
		set {
		return this._altIndex
		}
		get {
		return this._altIndex
		}
	}
	hostWindow {
		set {
		return this._hostWindow
		}
		get {
		return this._hostWindow
		}
	}
	_setMovementsParams(_params*) {
		for _index, _root in this._movementsParams, _i := 0
			for _direction, _obj in _root
				_root[_direction] := [], _root[_direction].push(_params[++_i], _params[++_i])
	}
	_getVariantOuterHtml(_x) { ; ~
	return "<button class='variant' data-X='" . _x . "' data-Y='-1'></button>" ; ~
	}
	_getKeyOuterHtml(_x, _y, _item) {
	return "<button class='" . this._keysClassName . "' data-X='" . _x . "' data-Y='" . _y . "'>" . this._getItemText(_item) . "</button>"
	}
	_setFocusedKey(_x, _y) {
		this._docRef.querySelector("[data-X='" . _x . "'][data-Y='" . _y . "']").focus()
	}
	X {
		set {
		return this._X_
		}
		get {
		return this._X_
		}
	}
	Y {
		set {
		return this._Y_
		}
		get {
		return this._Y_
		}
	}
	_X {
		set {
		return value, this._X_ := value, this._updateFocus()
		}
		get {
		return this._X_
		}
	}
	_Y {
		set {
		return value, this._Y_ := value, this._updateFocus()
		}
		get {
		return this._Y_
		}
	}

	Xv {
		set {
		return this._Xv_
		}
		get {
		return this._Xv_
		}
	}
	Yv {
		set {
		return this._Yv_
		}
		get {
		return this._Yv_
		}
	}
	_Xv {
		set {
		return value, this._Xv_ := value, this._updateFocusV()
		}
		get {
		return this._Xv_
		}
	}
	_Yv {
		set {
		return value, this._Yv_ := value, this._updateFocusV()
		}
		get {
		return this._Yv_
		}
	}

	_updateLayout(_map, _layer, ByRef _x:=0, ByRef _y:=0) {
		local
		base._updateLayout(_map, _layer, _x, _y)
		this._resetFocus() ; +++++++
	}
	_displayVariants(_params) {
		base._displayVariants(_params)
		this._resetFocusV() ; +++++++
	}
	_resetFocus() {
		this._X := this._Y_ := 1
	}
	_resetFocusV() {
		this._Xv := 1, this._Yv_ := -1
	}
	_hideVariants() {
	base._hideVariants(), this._updateFocus()
	}
	_updateFocus() {
	this._setFocusedKey(this._X_, this._Y_)
	}
	_updateFocusV() {
	this._setFocusedKey(this._Xv_, this._Yv_)
	}
	altReset() {
		this.suggestVariants(), this._altIndex := 0
	}

	_setClickHotkey(_lButton:="LButton") {
		local
		global Hotkey
		_lastFoundGroup := Hotkey.setGroup()
		Hotkey.setGroup(this._timestamp)
			Hotkey.InTheEvent(this._fnIf1)
				new this._KeypressHandler(_lButton, ObjBindMethod(this, "__click"), ObjBindMethod(this, "_keyFuncExec"))
			Hotkey.InTheEvent()
		Hotkey.setGroup(_lastFoundGroup)
	}
	_setDirectionHotkeys(_right:="Right", _left:="Left", _down:="Down", _up:="Up") {
		local
		global Hotkey
		_lastFoundGroup := Hotkey.setGroup()
		Hotkey.setGroup(this._timestamp)
			_fn := this._setFocusedKeyRelative_.bind(this)
			Hotkey.IfWinActive("ahk_id " . this._hostWindow.HWND)
				new Hotkey(_right).onEvent(_fn, this._setFocusedKeyRelative.bind(this, _right))
				new Hotkey(_left).onEvent(_fn, this._setFocusedKeyRelative.bind(this, _left))
				new Hotkey(_down).onEvent(_fn, this._setFocusedKeyRelative.bind(this, _down))
				new Hotkey(_up).onEvent(_fn, this._setFocusedKeyRelative.bind(this, _up))
			Hotkey.IfWinActive()
		Hotkey.setGroup(_lastFoundGroup)
	}
	_setEnterHotkey(_enter:="Enter") {
		local
		global Hotkey
		_lastFoundGroup := Hotkey.setGroup()
		Hotkey.setGroup(this._timestamp+1)
			Hotkey.IfWinActive("ahk_id " . this._hostWindow.HWND)
				this._hkEnterObject.push(_hkObj:=new this._KeypressHandler(_enter, ObjBindMethod(this, "__press"), ObjBindMethod(this, "_keyFuncExec")))
			Hotkey.IfWinActive()
		Hotkey.setGroup(_lastFoundGroup)
	return _hkObj
	}
	_setEscapeHotkey(_escape:="Esc") {
		local
		global Hotkey
		_lastFoundGroup := Hotkey.setGroup()
		Hotkey.setGroup(this._timestamp+2)
			Hotkey.InTheEvent(this._fnIf2)
				_hkObj := new Hotkey(_escape).onEvent(this.altReset.bind(this))
			Hotkey.InTheEvent()
		Hotkey.setGroup(_lastFoundGroup)
	return _hkObj
	}
		_mouseIsOver(_hWndActiveX) {
			local
			MouseGetPos,,,, _hWnd, 2
		return (_hWnd = _hWndActiveX)
		}
		; _areVariantsDisplayed(_hostWindow, _variants) {
		_areVariantsDisplayed(_hostWindow) {
		; return WinActive("ahk_id " . _hostWindow) && (_variants[ 0 ].style.getAttribute("display") = "block") ; ~
		return WinActive("ahk_id " . _hostWindow)
		}

	_unsetHotkeys() {
		this._hkEnterObject := []
		try Hotkey.deleteAll(this._timestamp), Hotkey.deleteAll(this._timestamp+1), Hotkey.deleteAll(this._timestamp+2)
	}
	_dispose() {
		this._unsetHotkeys()
		base._dispose()
	}
		; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
		Class _KeypressHandler extends _Hotkey {
			_counter := 0
			_longPressThreshold := 0.30
			_latency := - Round(1000 * (this._longPressThreshold + 0.04)) ; +++++++
			_ongoing := false
			_keyWaitParam := "" ; +++++++
			__New(_keyName, _fn_, _fn) {
				local
				if ((GetKeyName(this._keyWaitParam:=_keyName) = "")
				&& !(this._keyWaitParam:=RegExReplace(_keyName:=Trim(_keyName), "i)^\d{1,2}(?=Joy\d{1,2}$)", ""))) {
					throw Exception("""" . _keyName . """ is not a valid key name.")
				; return
				}
				base.__New(_keyName, true, -2)
				this.onEvent(_fn_, _fn)
				this.onEvent()
				this.onEvent(this._pressMonitor.bind(this))
				this._fn_ := _fn_
				this._fn := _fn
				this._cb := this._call.bind(this)
			} ; +++++++
			_pressMonitor(_hk, _state:="") { ; adapted from Rohwedder's code snippet: 'https://www.autohotkey.com/boards/viewtopic.php?f=76&t=78564#profile341691
				local
				if (this._counter > 0) {
					++this._counter
				} else {
					if not (this._ongoing:=!this._fn_.call()) ; +++
						Exit ; +++
					++this._counter ; ++++++
					_cb := this._cb ; ++++++
					SetTimer % _cb, % this._latency ; ++++++
					_keyName := this.getKeyName()
					KeyWait % _keyName, % "T" . this._longPressThreshold
					if (ErrorLevel) {
						SetTimer % _cb, Off ; ++++++
						this._counter := -1
						this._cb.call()
						KeyWait % _keyName
						this._counter := 0, this._ongoing := false
					return
					}
				}
			}
			_call() {
				local
				_fn := this._fn
			return %_fn%(this._counter), this._counter := 0, this._ongoing := false
			}
			_precipitate() {
				local
				if not (this._ongoing && (this._counter <> 0)) ; +++
					return
				_cb := this._cb
				SetTimer % _cb, -1
			}
			_dispose() {
				local
				base._dispose()
				if (_fn:=this._fn) {
					SetTimer % _fn, Off
					SetTimer % _fn, Delete
					this._fn_ := this._fn := this._cb := ""
				}
			}
			__Delete() {
				; WinActivate, ahk_class Notepad
				; WinWaitActive, ahk_class Notepad
				; ControlSend,, % "{Text}" . A_ThisFunc "," this.getKeyName() "`r`n", A
			}
		}
		; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
		_getActiveKey(ByRef _x:="", ByRef _y:="") {
			local
			_activeElement := this._docRef.activeElement
			if (_x:=_activeElement.getAttribute("data-X") + 0)
				return true, _y := _activeElement.getAttribute("data-Y") + 0
		}
		__press() {
			local
			if (this._getActiveKey(_x, _y)) {
				if (this._altMode)
					this._Xv := _x, this._Yv := _y
				else this._lastFoundX := _x, this._lastFoundY := _y
			return 0 ; +++
			} else return 1 ; +++ INTERRUPT_HANDLING := 1
		}
		_getHoveredKey(ByRef _x:="", ByRef _y:="") {
			local
			_target := this._docRef.querySelector("." . this._variantsClassName ":hover" ", " "." this._keysClassName . ":hover")
			if (_x:=_target.getAttribute("data-X") + 0)
				return true, _y:=_target.getAttribute("data-Y") + 0
		}
		__click() {
			local
			if (this._getHoveredKey(_x, _y)) {
				if (this._altMode) {
					this._Xv := _x, this._Yv := _y
				} else this._lastFoundX := this._X := _x, this._lastFoundY := this._Y := _y
			return 0 ; +++
			} else return 1 ; +++ INTERRUPT_HANDLING := 1
		}
		_keyFuncExec(_count:="") {
			local
			_o := this._map[ this._layer_ ][ this._lastFoundY ][ this._lastFoundX ]
			if (this._altMode)
				_result := _o.f(this, _o, _count, this._Xv) ; ~
			else _result := _o.f(this, _o, _count) ; ~
			if (_result+0 <> "") {
				this._altIndex := _result
			}
		}
		; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
		_setFocusedKeyRelative_(_hk:="", _state:="") {
			local
			for _k, _v in this._hkEnterObject
				_v._precipitate()
			KeyWait % _hk.getKeyName(), % "T" this._arrowsSensitivity
		}
		_setFocusedKeyRelative(_direction, _hk:="", _state:="") {
			local
			_mp := this._movementsParams[ this._altMode, _direction], _axis := _mp.1, _v := _mp.2
			_i := this[_axis], _m := _i + _v, _section := this._axesToSections[_axis], _n := this[_section]
			, this[_axis] := (_m < 1) ? _n : (_m > _n) ? 1 : _i + _v
		}
		; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
}
Class _Keypad extends _KeypadEvents {

	dispose() {
		base._dispose()
	}

	setLayout(_layout, _layer:=1) {
		local _classPath, _className, _obj
		_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1)
		_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className%
		if not (_obj._keymaps.hasKey(_layout))
	return 0
		; if (_layout = this._layout_)
	; return -1
	return this._layout[_layout, _obj._keymaps[_layout]] := _layer
	}
	setStyle(_style) {
		if (this._style = _style)
			return this._style
		if (_style = "") ; ++++
			return this._docRef.getElementById("userDefined").innerText :=  this._style:=_style:="" ; ++++
		if not (this._cascadingStyleSheets.hasKey(_style)) {
			throw Exception("The style does not exist.", -1, _style)
		; return
		}
		this._docRef.getElementById("userDefined").innerText := this._cascadingStyleSheets[ this._style:=_style ]
	} ; ++++
	setLayer(_layer) {
		local
		_l := this.layers
		if _layer not between 1 and %_l%
	return 0 ; ++++
	return this._layer := _layer
	}
	; layouts {
		; set {
		; }
		; get {
		; }
	; }

	pressKey(_x:="", _y:="", _count:=1) {
		if (this._altMode) {
			((_x+0 = "") && _x := this._Xv_), _y := -1
		} else {
			((_x+0 = "") && _x := this._X_), ((_y+0 = "") && _y := this._Y_)
		}
		this._lastFoundX := this._X := _x, this._lastFoundY := this._Y := _y, this._keyFuncExec(_count)
	}
}
