; see also: https://github.com/Drugoy/Autohotkey-scripts-.ahk/blob/master/Libraries/Acc.ahk
Acc_Init() {
static _h := ""
IfNotEqual, _h,, return
	_h := DllCall("LoadLibrary", "Str", "Oleacc.dll", "UPtr")
}
Acc_ObjectFromEvent(ByRef _idChild_, _hWnd, _idObject, _idChild) {
	static VT_DISPATCH := 9
	Acc_Init(), _pAcc := ""
	if (DllCall("Oleacc.dll\AccessibleObjectFromEvent", "Ptr", _hWnd, "UInt", _idObject, "UInt", _idChild, "PtrP", _pAcc, "Ptr", VarSetCapacity(_varChild, 8 + 2 * A_PtrSize, 0) * 0 + &_varChild) = 0)
		return ComObj(VT_DISPATCH, _pAcc, 1), _idChild_ := NumGet(_varChild, 8, "UInt")
}
