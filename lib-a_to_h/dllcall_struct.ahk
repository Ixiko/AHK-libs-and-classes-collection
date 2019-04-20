dllcall_struct( p* ) {
	; use as dllcall, new arg type: 'struct'. 
	
	; See documetation at github: https://github.com/HelgeffegleH/AHK-misc./blob/master/functions/dllcall_struct/readme.md
	static size_map := { 1:1, 2:1, 4:1, 8:1 } ; only structs of these byte (keys) sizes will be passed by value on 64 bit. Only these sizes are returned in the register(s).
	static size_type_map := { 1 : 'char', 2 : 'short', 4 : 'int', 8 : 'int64' }
	local
	type_is_struct := false ; false if type is a normal 'type', 1 if type is 'struct' and 2 if type is 'struct*'.
	
	fn := p.removeat( 1 ) ; fn - function, the function to call.
	
	n := []	; new parameter list
	; build the new parameter list:
	for k, par in p {
		if type_is_struct {	; handle 'struct' and 'struct*'
			if !isobject(par)
				throw exception('Invalid struct at param: ' . string(k+1), -1)
			; par is a struct object.
			adr := addressof( par )		; adr - address of the struct
			verifyAdr
			if type_is_struct == 2 {	; this is case: 'struct*'
				n.push adr
				type_is_struct := false	; for next iteration
				continue
			}
			; From here, handle 'struct' (no suffix: *)	
			sz := sizeof( par ) ; sz - size of the struct
			verifySize
			
			type_is_struct := false	; for next iteration
			if a_ptrsize == 8 && !size_map.haskey(sz) {
				; struct must be passed by address in this case for x64.
				n.push 'uptr', adr
				continue
			}
			while sz > 0 
				; for x86 pass the struct on the stack. 
				; for x64 copy to register / stack only if the size of the struct is one the sizes in size_map,
				; in which case it has already been handled above
				n.push( 'uptr', numget(adr, (a_index-1)*a_ptrsize) ), sz -= a_ptrsize
			continue
		}
		
		if isEven( k ) || k == p.length()	{	; it is a value of a normal 'type' (from the previous iteration) or the return type.
			n.push par
			continue
		}
		
		if instr(par, 'struct') {	; either stuct by value or address
			if rtrim(par, '*pP') !== par {	; also allows 'structP', 'structp'
				n.push 'ptr'
				type_is_struct := 2	; pass struct by address
			} else
				type_is_struct := 1	; pass struct by value (can be by address on x64, decided on next iteration)
			continue
		}
		n.push par	; it is a normal 'type'
	} ; end for
	;
	; handle functions returning structs.
	;
	last_param_or_return := n[ n.length() ]
	return_is_struct := isobject( last_param_or_return ) || instr(last_param_or_return, 'struct') ; return is struct
	sz := '' ; to help catch bugs below since 'sz' might be used to hold size of some other struct below.
	adr := '' ; as for sz.
	struct_returned_in_register := false ; indicates wether to copy the return value from dllcall to the struct or not.
	if return_is_struct {
		return_struct := ''
		return_param := n.pop() 
		cc := '' ; calling convention
		if type(return_param) == 'String' {	; the return parameter is on the form '[cdecl ] struct: struct_definition', eg, 'cdecl struct: 4' or 'struct:120' where the definition is the size of the structure.
			if instr(return_param, 'cdecl')
				cc := 'cdecl'
			struct_definition :=  substr(return_param, instr(return_param, ':') + 1)
			
			return_param := [ cc, createStruct( struct_definition ) ]
		}
		; return_param is on the form: [callingconvention, struct_object], where callingconvention is either omitted, a blank string or 'cdecl'.
		if return_param.haskey(1)
			cc := return_param[ 1 ]	; calling convention
		else
			cc := ''
		if cc && trim(cc) != 'cdecl' ; trim ok here, but dllcall will complain if leading space: ' cdecl' 
			throw exception('Invalid calling convention: ' string(cc), -1)
		
		return_struct := return_param[ 2 ]		; struct object
		sz := sizeof( return_struct )
		verifySize
		
		if size_map.haskey( sz ) {
			; return stuct in register
			; for x86, return structs of size <= 32 bit in %eax,  for: 32 < size <= 64 return in %eax/%edx pair.
			; for x64, return struct of size <= 64 bit in %rax.
			struct_returned_in_register := true	; must copy the return value from dllcall into return_struct
			n.push trim( cc . (a_ptrsize == 4 && sz <= 4 ? ' uint' : ' int64') )
		} else { 
			; return struct by pointer
			; caller allocates memory for struct
			adr := addressof( return_struct )
			verifyAdr
			; for x86, push struct pointer last on to the stack
			; for x64, pass struct pointer in %rcx
			n.insertat 1, adr
			n.insertat 1, 'ptr'
			if cc !== ''
				n.push cc
		}
	} ; end handling return struct
	; db
	static db := false
	if db {
		s := ''
		for k, v in n
			s .= v '`n' 
		msgbox s
	}
	;
	;	call the function
	;
	return_value := dllcall(fn, n*)
	if struct_returned_in_register {
		; struct was returned in register, return a struct object
		verifySize ; should never fail, to protect against bugs since 'sz' is set conditonally above
		if !return_struct || !return_is_struct	; at this point return_struct must exist and return_is_struct must be true.
			throw exception('Implementation error: ' . string(!!return_struct) . ' ' . string(!!return_is_struct))
		adr := addressof( return_struct )
		verifyAdr
		if !size_type_map.haskey(sz)	; at this point 'sz' must be a key in this map.
			throw exception('Implementation error')
		numput return_value, adr, size_type_map[ sz ]	
	}
	return return_struct ? return_struct : return_value
	;
	;	nested function
	;
	; for maintainability and flexibility,
	addressof(struct){
		return struct.1
	}
	sizeof(struct){
		return struct.2
	}
	createStruct(definition) {
		local
		size := integer( definition )
		struct := [ 0, size ]
		struct.setcapacity 'data', size
		struct_pointer := struct.getaddress( 'data' )
		struct[ 1 ] := struct_pointer
		return struct
	}
	; misc help function
	isEven(x) => !(x & 1)
	; closures:
	verifySize(){
		; sz is the size of some struct
		if type(sz) !== 'Integer'  || sz <= 0
			throw exception('Invalid struct size at param: ' . string(k+1) . '. Must be an integer, got: ' . string(sz) . ' (' . type(sz) . ')', -1)
	}
	verifyAdr(){
		; adr is the address of some struct
		if type(adr) !== 'Integer'
			throw exception('Invalid address at param: ' . string(k+1) . '. Must be an integer, got: ' . string(adr) . ' (' . type(adr) . ')', -1)
	}
}