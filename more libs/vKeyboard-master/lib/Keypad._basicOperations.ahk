Class _BasicOperations extends Keypad._BasicOperations._DefaultProcedures {
	keyWithVariantsProc(_keypadInst, _keyDescriptor, _count:=1, _index:="") {
		local
		if (_count = -1) {
			_keypadInst.suggestVariants(_keyDescriptor.params*)
		return 0
		}
		(_keypadInst._altMode && _keypadInst.suggestVariants())
		_text := (_index) ? _keyDescriptor.params[_index]
							: (_keypadInst._altIndex) ? _keyDescriptor.params[ _keypadInst._altIndex ]
														: _keyDescriptor.caption
		_keypadInst._autocomplete.sendText(_text)
	return 0
	}
	altEntryModeProc(_keypadInst, _keyDescriptor, _count:=1) {
	return 0, _keypadInst.autocomplete.sendText(_keyDescriptor.params[_count])
	}
	setAltIndexProc(_keypadInst, _keyDescriptor, _count:=1) {
	return _keyDescriptor.params.1
	}
	setCaretPosProc(_keypadInst, _keyDescriptor, _count:=1) {
		local
		static EM_SETSEL := 0xB1
		_ea := _keypadInst.autocomplete
		_s := _ea._getSelection() + _keyDescriptor.params.1 * _count
		GuiControl, Focus, % _ea._hwnd
		SendMessage % EM_SETSEL, % _s, % _s,, % _ea._AHKID
	}
	shiftCaretPosUProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst.autocomplete.send("{NumpadUp " . _count . "}")
	}
	shiftCaretPosRProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst.autocomplete.send("{NumpadRight " . _count . "}")
	}
	shiftCaretPosDProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst.autocomplete.send("{NumpadDown " . _count . "}")
	}
	shiftCaretPosLProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst.autocomplete.send("{NumpadLeft " . _count . "}")
	}
	keyWithAccessProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst._autocomplete.send("{" . _keyDescriptor.accessKey . "}")
	}
	sendBackSpaceProc(_keypadInst, _keyDescriptor, _count:=1) {
		local
		GuiControlGet, _content,, % _keypadInst._autocomplete._hwnd
		if (_content = "")
			return "", _keypadInst._submit(true, false, false)
		_keypadInst.autocomplete.send("{BackSpace " . _count . "}")
	}
	sendSpaceProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst.autocomplete.send("{Space " . _count . "}")
	}
	startNewLineProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst.autocomplete.send("{Enter " . _count . "}")
	}
	toLayerProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst.setLayer(_keyDescriptor.params.1)
	}
	submitProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst._submit(_keypadInst._hideOnSubmit, _keypadInst._resetOnSubmit, true) ; ++++
	}
	clearContentProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst._autocomplete._clearContent()
	}
	increaseFontSizeProc(_keypadInst, _keyDescriptor, _count:=1, _additiveTerm:=2) {
		_keypadInst.fontSize += _additiveTerm * _count
	}
	decreaseFontSizeProc(_keypadInst, _keyDescriptor, _count:=1, _subtrahend:=2) {
		_keypadInst.fontSize -= _subtrahend * _count 
	}
	showHideProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst.show()
	}
	switchLayerProc(_keypadInst, _keyDescriptor, _count:=1) {
		local
		_layer := _keypadInst._layer, _keypadInst.setLayer((++_layer > _keypadInst.layers) ? 1 : _layer)
	}
	altResetProc(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst.altReset()
	}

	call(_keypadInst, _keyDescriptor, _count:=1) {
		_keypadInst._autocomplete.sendText(_keyDescriptor.caption)
	return 0
	}

		Class _DefaultProcedures {
			listboxDismiss(_eAInst) {
				_eAInst.listbox._dismiss()
			}
			listboxSelectUp(_eAInst) {
				_eAInst.listbox._selectUp()
			}
			listboxSelectDown(_eAInst) {
				_eAInst.listbox._selectDown()
			}
			dataLookUp1(_eAInst) {
				_eAInst._completionDataLookUp(1)
			}
			dataLookUp2(_eAInst) {
				_eAInst._completionDataLookUp(2)
			}
			complete1(_eAInst) {
				_eAInst._complete(false, 1)
			}
			complete2(_eAInst) {
				_eAInst._complete(false, 2)
			}
		}

}