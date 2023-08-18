
Gson_Window()
{
	static dom, window
	if window
		return window
	
	dom := ComObjCreate("htmlfile")
	dom.write("<meta http-equiv='X-UA-Compatible'content='IE=edge'><script>
	( Comment
	function fromAHK(obj) {
		if (typeof obj !== 'object') return obj
		if (obj == ahk_true) return true
		if (obj == ahk_false) return false
		var keys = ahk_obj_keys(obj)
		var out = {}
		var isArray = true
		for (var i = 1; i <= keys.length(); ++i) {
			out[keys[i]] = fromAHK(obj[keys[i]])
			if (keys[i] !== i) isArray = false
		}
		if (isArray) {
			out.length = i
			return Array.prototype.slice.apply(out, [1])
		}
		return out
	}
	)</script>")
	
	window := dom.parentWindow
	window.ahk_true := this ? this.Gson_True() : Gson_True()
	window.ahk_false := this ? this.Gson_False() : Gson_False()
	window.ahk_obj_keys := this ? this.Gson_Keys : Func("Gson_Keys")
	return window
}

Gson_Keys(param:="")
{
	out := []
	for k in (this ? this : param)
		out.Push(k)
	return out
}

Gson_Dump(obj)
{
	window := this ? this.Gson_Window() : Gson_Window()
	return window.JSON.stringify(window.fromAHK(obj))
}

Gson_FromJS(jsobj) {
	if !IsObject(jsobj)
		return jsobj
	window := this ? this.Gson_Window() : Gson_Window()
	obj := {}
	if window.Array.isArray(jsobj) {
		loop, % jsobj.length
			obj.Push(%A_ThisFunc%(jsobj[A_Index-1]))
	} else {
		keys := window.Object.keys(jsobj)
		loop, % keys.length
			obj[keys[A_Index-1]] := %A_ThisFunc%(jsobj[keys[A_Index-1]])
	}
	return obj
}

Gson_Load(json)
{
	window := this ? this.Gson_Window() : Gson_Window()
	parsed := window.JSON.parse(json)
	return this ? this.Gson_FromJS(parsed) : Gson_FromJS(parsed)
}

Gson_True()
{
	static obj := {}
	return obj
}

Gson_False()
{
	static obj := {}
	return obj
}
