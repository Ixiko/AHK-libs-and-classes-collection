#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input

CoordMode, ToolTip, Screen
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

global vk := ""
global userDefinedFuncKeyName := "_userDefinedFunc"
global layoutName := "test", defaultFFunction := "vk_defaultFFunction"
global vk_map_updateFn := Func("vk_map_update").bind(layoutName, defaultFFunction)
columns := 10
rows := 3
layer := ""
fileFullPath := ""
map := ""
exception := ""
global vCaption := vFunc := vParams := ""
infoTip =
(LTrim Join`r`n
	Hey, thanks for trying the vKeyboard library!
	(you can use the little UI handle at the right bottom corner of the edit control to resize it)

	By means of this GUI, you can the WYSIWYG-way create keyboard layouts, export and
	save them as Layout JSON representations, compatible with the 'setHotkeys' interface
	method (https://github.com/A-AhkUser/vKeyboard#setlayout).
	Usage:
	▸ Use the arrow keys to navigate through keyboard's keys.
	▸ Long-click on a key to display an UI dialog; it allows you to customize the behaviour of the key.
	▸ Click on a key to display in an info tip its current descriptor features.
	▸ ALT+m > push a column of keys
	▸ CTRL+ALT+m > pop a column of keys
	▸ ALT+n > push a row of keys
	▸ CTRL+ALT+n >  pop a row of keys
	▸ NumpadAdd > append a layer
	▸ Delete > delete the current layer
	▸ CTRL+L > load your keyboard layout mapping
	▸ CTRL+S > export and save the mapping of your keyboard layout
	▸ CTRL+Tab > cycle through layers

	The coordinates (z-layer, y-row, x-key) of the key currently focused appear on the window
	title bar.

	Cheers
)

#Include %A_ScriptDir%\..\..\lib\vKeyboard.ahk
Class _vKeyboard extends vKeyboard {
	_updateFocus() {
		base._updateFocus()
		if (this.hostWindow.isVisible())
			this.hostWindow.show("NA", "Key currently focused: [" this.layer "," this.X "," this.Y "]")
	}
	setLayer(_layer) {
		local
		if (_r:=base.setLayer(_layer))
			if (this.hostWindow.isVisible())
				this.hostWindow.show("NA", "Key currently focused: [" this.layer "," this.X "," this.Y "]")
	return _r
	}
} ; update the window title, specifying the coordinates of the key currently focused, each time the focus changes on the visual keyboard's keypad
global vk := new _vKeyboard() ; create a new instance of the visual keyboard object and stores it in 'vk'
vKeyboard_define(layoutName, "[[[null]]]", defaultFFunction)
; define the simplest keyboard layout mapping using the 'vk_defaultFFunction' function as default callback
vk.setLayout(layoutName)
vk.alwaysOnTop := false
vKeyboard.defineStyle("default", A_ScriptDir . "\styles\default.css")
vk.setStyle("default")
vk.autocomplete.bkColor := vk.backgroundColor
vk.autocomplete.fontColor := "FFFFFF"
vk.autocomplete.fontName := "Segoe UI"
vk.autocomplete.fontSize := 9
vk.autocomplete.disabled := true
; GuiControl, Disable, % vk.autocomplete.HWND
GuiControl, Text, % vk.autocomplete.HWND, % infoTip
vk.setHotkeys({}, 0) ; 0: don't use joystick
vk._unsetHotkeys() ; internal method
vk._setDirectionHotkeys() ; internal method
vk._setClickHotkey() ; internal method
vk.showHide()
vk.fitContent()
Loop % columns-1
	vk_map_addColumn()
Loop % rows-1
	vk_map_addRow()
vk_map_updateFn.call()
OnExit, handleExit
return

handleExit:
	vk.dispose()
ExitApp

!x::ExitApp

#If WinActive("ahk_id " . vk.hostWindow.HWND) ;{
	!m::vk_map_addColumn(), vk_map_updateFn.call()
	^!m::(vk_map_removeColumn() && vk_map_updateFn.call())
	!n::(vk_map_addRow(), vk_map_updateFn.call())
	^!n::(vk_map_removeRow() && vk_map_updateFn.call())
	^Tab::layer := vk._layer, vk.setLayer((++layer > vk.layers) ? 1 : layer)
	NumpadAdd::vk_map_addLayer(), vk_map_updateFn.call(), vk.setLayer(vk.layers)
	Delete::
		GUI % vk.hostWindow.HWND . ":+OwnDialogs"
		MsgBox, 4,, Are you sure you want to remove the current keyboard layer?
			IfMsgBox, No
				return
		if (vk_map_removeLayer(vk.layer)) {
			vk.setLayer(1), vk_map_updateFn.call()
		}
	return
	^s::
		GUI % vk.hostWindow.HWND . ":+OwnDialogs"
		FileSelectFile, fileFullPath, S16, % A_ScriptDir . "\keymaps", Save the mapping of the keyboard layout to a location of your choice
				, vKeyboard compatible keyboard layout mapping (*.json)
		if ((fileFullPath <> "") && !ErrorLevel)
			if not (vk_map_exportAndSave(fileFullPath))
				MsgBox, The attempt to overwrite the file failed.
	return
	^l::
		GUI % vk.hostWindow.HWND . ":+OwnDialogs"
		FileSelectFile, fileFullPath, 3, % A_ScriptDir . "\keymaps", Load the keyboard layout mapping of your choice
				, vKeyboard compatible keyboard layout mapping (*.json)
		if ((fileFullPath <> "") && !ErrorLevel) {
			try map:=vk_map_load(A_ScriptHwnd, fileFullPath, defaultFFunction)
			catch exception {
				MsgBox % exception.message "`r`n" exception.extra
			return
			}
			vKeyboard_define(layoutName, JSON.Dump(map), defaultFFunction)
			vk.setLayout(layoutName, 1)
		}
	return
#If ;}

vk_defaultFFunction(this, _descriptor, _count:=-1) { ; the default 'f-function'
	if (_count = -1) {
		vk_onLongClick(this, _descriptor)
	} else if (_count = 1) {
		vk_keyDisplayInfo(this, _descriptor)
	}
}
	vk_onLongClick(this, _descriptor) {
		global
		GUI, 2:New, % "+owner" . this.hostWindow.HWND
		GUI % this.hostWindow.HWND . ":+Disabled"
			GUI, Add, Text, Section, key's caption:
			GUI, Add, Edit, ys r1 w50 Limit3 vvCaption, % _descriptor.caption
			GUI, Add, Text, Section xs, key's associated 'f-function' (omit to use the default procedure):
			GUI, Add, Edit, ys r1 w230 vvFunc, % _descriptor[userDefinedFuncKeyName]
			GUI, Add, Text, Section xs, an array of 'params' values (if applicable):
			GUI, Add, Edit, ys r4 w230 vvParams, % IsObject(_descriptor.params) ? JSON.Dump(_descriptor.params) : ""
			GUI, Add, Button, Section xs w100 ggKeyDescriptorGuiSubmit Default, OK
			GUI, Add, Button, ys w100 g2GUIEscape, cancel
		GUI, Show, AutoSize, % "Key descriptor - [" this.layer "," this.X "," this.Y "]"
	}
	vk_keyDisplayInfo(this, _descriptor:="") {
		local _k, _v, _str, _fn
		if not (_descriptor) {
			ToolTip
		return
		}
		for _k, _v in _descriptor.params, _str := ""
			_str .= A_Tab . "." . (IsObject(_v) ? "[Object]" : _v) . "`r`n"
		ToolTip % "function: " _descriptor[userDefinedFuncKeyName] "`r`nparams:`r`n" . _str
		_fn := Func(A_ThisFunc).bind(this)
		SetTimer % _fn, -2500
	}
gKeyDescriptorGuiSubmit() {
	local _obj, _exception
	GUI, %A_GUI%:Submit, NoHide
	_obj := {}
	try {
		if (vParams <> "") {
			vParams := JSON.Load(vParams)
			if not (vParams.count())
				throw Exception("Invalid 'params' array.")
		_obj.params := vParams
		}
	} catch _exception {
		GUI %A_GUI%:+OwnDialogs
		MsgBox % "Invalid 'params' array.`r`n" . _exception.message
	return
	}
	if (RegExMatch(vFunc, "\s")) {
		GUI %A_GUI%:+OwnDialogs
		MsgBox, Invalid function name.
	return
	}
	_obj.caption := vCaption, _obj.f := defaultFFunction, _obj[userDefinedFuncKeyName] := vFunc
	vk._map[ vk.layer, vk.Y, vk.X ] := _obj
	vk_map_updateFn.call()
	2GUIClose:
	2GUIEscape:
		GUI % vk.hostWindow.HWND . ":-Disabled"
		GUI %A_GUI%:Destroy
	return
}

vk_map_load(_name, _pathOrContent, _defaultFFunction) {
	local
	global vKeyboard, vk, JSON, userDefinedFuncKeyName, defaultFFunction
	try vKeyboard.defineLayout(_name, _pathOrContent,, defaultFFunction, true)
	catch _exception {
		throw Exception("Invalid keyboard mapping.", -1, _exception.message)
	; return
	}
	vKeyboard.defineLayout(_name, _pathOrContent,, _defaultFFunction, false)
	_map := vKeyboard._keymaps[_name] ; internal property
	for _index, _layer in _map {
		for _indexPrime, _row in _layer {
			for _k, _v in _row {
				if (_v.hasKey(userDefinedFuncKeyName)) {
					throw Exception("'" . userDefinedFuncKeyName
					. "' is reserved by the script as key's descriptor key. Could not load the keyboard mapping.", -1)
				; return
				}
				if (_v.hasKey("f")) {
					if (_v.f = userDefinedFuncKeyName) {
						throw Exception("'" . userDefinedFuncKeyName
						. "' is reserved by the script as f-function name. Could not load the keyboard mapping.", -1)
					; return
					}
					_row[_k][userDefinedFuncKeyName] := _v.f, _row[_k].delete("f")
				}
			}
		}
	}
	return _map
}
vk_map_exportAndSave(_fileFullPath) {
	local
	global vKeyboard, vk, JSON, userDefinedFuncKeyName, defaultFFunction
	_name := A_ScriptHwnd
	try vKeyboard.defineLayout(_name, JSON.Dump(vk._map),, defaultFFunction, false)
	_map := vKeyboard._keymaps[_name] ; internal property
	for _index, _layer in _map
		for _indexPrime, _row in _layer
			for _k, _v in _row {
				if (_v.hasKey(userDefinedFuncKeyName))
					_row[_k].f := _v[userDefinedFuncKeyName], _row[_k].delete(userDefinedFuncKeyName)
				else _row[_k] := _v.caption
			}
	_objectDescription := JSON.Dump(_map,, 4)
	SplitPath, % _fileFullPath,,, _outExtension
	((_outExtension = "") && (_fileFullPath .= ".json"))
	if FileExist(_fileFullPath) {
		FileDelete % _fileFullPath
		if (ErrorLevel)
	return false
	}
	FileAppend % _objectDescription, % _fileFullPath, UTF-8
return true
}

vKeyboard_define(_name, _map, _defaultFFunction) {
vKeyboard.defineLayout(_name, _map,, _defaultFFunction, true)
}
vk_map_update(_name, _defaultFFunction) {
vKeyboard.defineLayout(_name, JSON.Dump(vk._map),, _defaultFFunction, true), vk.setLayout(_name, vk.layer)
}
vk_map_addLayer() {
    local
	global vk
    _rows := vk._map[ 1 ], _count := _rows[ 1 ].count()
    _arr := [ StrSplit(StrReplace(Format("{:" _count-!!_count "}", ""), A_Space, A_Space), A_Space)* ]
	; cf. also str_rept by jeeswg https://www.autohotkey.com/boards/viewtopic.php?t=44614 (thanks jeeswg!)
    _obj := {}
    Loop % _rows.count()
        _obj.push(_arr.clone())
    vk._map.push(_obj)
}
vk_map_addColumn() {
    local
	global vk
    for _index, _layer in vk._map
        for _indexPrime, _row in _layer {
			_layer[_indexPrime].push("")
		}
}
vk_map_addRow() {
    local
	global vk
    _arr := [ StrSplit(StrReplace(Format("{:" vk._map[ 1 ][ 1 ].count() - 1 "}", ""), A_Space, A_Space), A_Space)* ]
    for _index, _layer in vk._map {
		_layer.push(_arr.clone())
	}
}
vk_map_removeRow() {
    local
	global vk
	if (vk._map[ 1 ].count() > 1) {
		for _index, _layer in vk._map
			_layer.pop()
	return true
	}
	return false
}
vk_map_removeColumn() {
    local
	global vk
	if (vk._map[ 1 ][ 1 ].count() > 1) {
		for _index, _layer in vk._map
			for _indexPrime, _row in _layer
				_layer[_indexPrime].pop()
	return true
	}
	return false
}
vk_map_removeLayer(_index) {
    local
	global vk
	if (vk._map.count() > 1)
		return true, vk._map.removeAt(_index)
	return false
}
