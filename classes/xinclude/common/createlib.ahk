; Included in ui.ahk
createlib(lib, cleanupfn := '', structName := ''){
	; Creates a function lib from array lib
	; lib, array, on the form [ ['dll\func', 'memberName'], ... ]
	; cleanupfn, udf clean-up function for the struct
	; structName, the name of the struct / lib, only for debug purposes.
	local
	global xlib
	tofn := xlib.ui.getFnPtrFromLib											; string to function pointer 
	out_struct := new xlib.struct( a_ptrsize * lib.length(),, structName)	; a struct containing all function pointers
	sdef := []																; struct definition, parameters for struct.build.
	for i, fn_mem in lib
		sdef.push ['ptr', tofn.call(fn_mem.1), fn_mem.2]					; convert all function names to function pointers and setup memeber names
	out_struct.build sdef*													; build the struct
	; Set clean up function only when struct was built without errors.
	if cleanupfn
		out_struct.setCleanUpFunction cleanupfn
	return out_struct
}