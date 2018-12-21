_GuiCreate(p*){
	local
	return ctrl_gui(guiCreate(p*), p[3])
	; Nested function
	ctrl_gui(o, es := "") {
		; creates a Control or Gui object wrapper object
		; o - a Control or Gui object to wrap
		; es - gui event sink object, optional.
		w :=	{	; wrapper object
					base 		: { __call : func("__call"), base : o, __class : type(o) },	; setting the object being wrapped (o) as base enables
																							; all properties to work with out any extra code.
					__es__ 		: es,	; event sink
					__cbfns__	: [],	; callback functions (for onevent)
					__ctrls__ 	: []	; the controls of the gui, for _NewEnum
				}
		w._newenum := type(o) == "Gui"	?  (this) =>	{	; enumerator object
															enum : this.__ctrls__._newenum(), 
															next : (this, byref k, byref v := "") 
																	=>	this.enum.next(,v) 
																		? (k:=v.hwnd,true) 
																		: false
														} 
										:	func("noenum")	; Only gui objects have _newenum
		_GuiFromHwnd(w.hwnd, w)	; Adds the wrapper object to _GuiFromHwnd list (controls are added to the same list).
		return w
		; nested functions
		__call(this, fn, p*){
			; Handles all calls to the wrapper object (this), returning the wrapper object itself, or the new control in
			; case the the wrapper wraps a Gui object and the methods is addXXX(...) or add("XXX",...)
			;
			; this - the wrapper object.
			; fn - the method to call.
			; p - method parameters.
			local
			if type(this) == "Gui" {
				if instr(fn, "add") == 1 {
					this.__ctrls__.push( w := ctrl_gui((this.base)[fn](p*), this.__es__) )	; save control for _newenum
					return w				 		; return the new control wrapper
				} else if fn = "destroy" {			; handle removal from _GuiFromHwnd and _GuiCtrlFromHwnd.
					for hwnd in this
						_GuiCtrlFromHwnd(hwnd, -1)	; remove all control wrappers from the _GuiCtrlFromHwnd list
					_GuiFromHwnd(this.hwnd, -1)		; remove the gui wrapper from the _GuiFromHwnd list
					this.base.destroy()				; destroy the gui.
					return this
				}
			} 
			if fn = "onevent" {		; Events require special handling, see createEventRouter()
				createEventRouter(this, this.__es__, p)
			} else {
				(this.base)[fn](p*)			; call the method
			}
			return this						; return the wrapper object to enable chaining
		}
		createEventRouter(this, es, p){	
			; this function does one of two things:
			; 1) creates a callback function which directs events to the udf callback function,
			; passing the wrapper object instead of the actual control / gui object.
			; 2) removes the callback.
			local
			; this - the wrapper object
			; es - the gui's event sink (if exist)
			; p - onevent parameters
			;
			; cbfn, callback function.
			p1 := p[1], p2 := p[2]								; convenience, allows p2 to be free variable and edit p[2] at the same time
			if this.__cbfns__[p1, p2] {							; Callback function already exists.
				cbfn := p[3] == 0	
						? this.__cbfns__[p1].delete(p2) 		; Do not call this callback.
						: this.__cbfns__[p1, p2]				; Changes AddRemove between 1 or -1 (or error).
			} else {	; add callback function, creates a router function.
				cbfn := es && type(p2) == "String" && isobject(m:=es[p2])			; m, event sink method.
						?	(ctrlOrGui, par*) => m.call(es, this, par*)				; gui uses event sink
						:	(ctrlOrGui, par*) => %p2%(this, par*)	 				; else, function name or some func/... obj.
				this.__cbfns__[p1, p2] := cbfn										; store the callback router to enable it to be deleted later.
			}
			p[2] := cbfn				; the second parameter is replace with the callback router
			this.base.onevent(p*)		; this.base is the gui or control object, 
			return
		}
		noenum(p*){ ; For correct error message when using _newenum on a control.
			throw exception("Unknown method.", -1, "_NewEnum")
		}
	}
}
_GuiFromHwnd(hwnd, addremove := false){
	; Hwnd, the hwnd of the Gui or GuiControl object to handle
	; addremove, internal use only, pass an object to add to the list of guis and guicontrols, pass -1 to remove the object at 'hwnd'.
	static guis := []	; contains all gui and guicontrol wrappers. Use hwnd as key and wrapper object as value.
	if isobject(addremove)
		return guis[hwnd] := addremove
	else if addremove
		return guis.delete(hwnd)
	return guis.haskey(hwnd) ? guis[hwnd] : false
}
_GuiCtrlFromHwnd(hwnd, addremove := false){
	return _GuiFromHwnd(hwnd, addremove)	; gui control wrappers are stored in the same array as gui wrappers.
}