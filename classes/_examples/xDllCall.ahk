#include %A_ScriptDir%\..\class_xlib.ahk
#include %A_ScriptDir%\..\class_xcall.ahk

xDllCall(callback := '', fn := '', typesAndArgs*){
	local
	global xlib, xcall
	; callback, user defined script function to call when the function fn (see next param) returns. (optional)
	; fn, the function to call, DllFile\Function													(required)
	; typesAndArgs, optional [Type1, Arg1, Type2, Arg2, ..., TypeN, ArgN, "Cdecl ReturnType]		(optional)
	if callback == ''
		callback := (p*) => 
	xlib.splitTypesAndArgs typesAndArgs, decl, params 	; decl and params are byref
	(new xcall(fn, decl*)).call(callback, params*)
}
