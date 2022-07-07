class Python {
	static __instance__ := 0
	static Call(dllpath := 'python39.dll') {
		if this.__instance__
			return this.__instance__
		if !(mod := DllCall('GetModuleHandle', 'str', dllpath, 'ptr') || DllCall('LoadLibrary', 'str', dllpath, 'ptr'))
			throw OSError()
		DllCall(addr('Py_Initialize'))
		if !DllCall(addr('Py_IsInitialized'))
			throw 'py is not initialized'
		this.DefineProp('__Delete', {call: ((add, self) => (Python.__instance__ := 0, DllCall(add))).Bind(addr('Py_Finalize'))})
		pyscript :=
		(
			'from builtins import *`n__import__ = __import__`n'
			'class ScriptInterpreter:`n'
			'    def __getattr__(self, __name, __globals = globals()):`n'
			'        try: return __globals.__getitem__(__name)`n'
			'        except: raise AttributeError`n'
			'    def __setattr__(self, __name, __value, __globals = globals()):`n'
			'        __globals.__setitem__(__name, __value)`n'
			'    def eval(self, __code, __globals = globals(), __locals = None):`n'
			'        return eval(__code, __globals, __locals)`n'
			'    def exec(self, __code, __globals = globals(), __locals = None):`n'
			'        exec(__code, __globals, __locals)`n'
			'    @classmethod`n'
			'    def _init(cls):`n'
			'        from pyahk.comproxy import ComProxy`n'
			'        from ctypes import POINTER, c_void_p, cast`n'
			'        idisp = ComProxy(cls()).as_IDispatch()`n'
			'        idisp.AddRef()`n'
			'        cast({}, POINTER(c_void_p))[0] = idisp.value`n'
			'        {}`n'
			'ScriptInterpreter._init(); del ScriptInterpreter._init; del ScriptInterpreter'
		)
		if DllCall('GetProcAddress', 'ptr', 0, 'astr', 'ahkGetApi', 'ptr') {
			ahk_mod := DllCall('GetModuleHandleW', 'ptr', 0, 'ptr')
			v2hext := 'from pyahk import AhkApi; AhkApi.initialize(cast(' ahk_mod ', c_void_p).value); AhkApi.pumpMessages()'
		} else v2hext := ''
		pyscript := Format(pyscript, (buf := Buffer(A_PtrSize, 0)).Ptr, v2hext)
		r := DllCall(addr('PyRun_SimpleString'), 'astr', pyscript)
		return this.__instance__ := ComObjFromPtr(NumGet(buf, 'ptr'))
		addr(f) => DllCall('GetProcAddress', 'ptr', mod, 'astr', f, 'ptr')
	}
	; __Call(name, params)			; call `__main__`'s global var
	; __Get(name, params)			; get `__main__`'s global var
	; __Set(name, params, value)	; set `__main__`'s global var
	; exec(code, globals, locals)
	; eval(code, globals, locals)
}