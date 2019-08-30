
class jitFn {
	; Compiles a function as:
	/*
		typedef TYPE_RET [__cdecl/__stdcall] (*fn)([arg1type, arg2type, ...]);	
	
		typedef struct v {
			fn pfn;				// The function to call
			void* args;			// An array of arguments
			TYPE_RET* r;		// Stores the return, 8 byte int, double or float
		} *pv;
		void f(pv p){
			*(p->r) = p->pfn([(arg1type) p->args[0], ...]);
		}
	*/
	static cache := {}	; Storage for compiled functions.
	; Consider returning declstr for faster caching. (added parameter but not implemented)
	__new(decl, byref rt, byref declStrOut := "" ) { ; for convenice
		; decl - 'function declaration', includes return type and (opt) calling convention at the last element.
		; rt - return type, pass blank, getFunc -> declToStr sets this variable.
		return xlib.jitFn.getFunc(decl, rt, declStrOut) 
	}
	getFunc(decl, byref rt_str, byref declStrOut := ""){
		local
		global xlib
		declStr := this.declToStr(decl, rt, isCdecl) ; Convert the declaration to string representation
		rt_str := rt
		c := isCdecl ? "c" : ""
		cacheKey := declStr . rt_str . c
		if this.cache.haskey(cacheKey)			; If the cache contains such a function, return it
			return this.cache[cacheKey]
		if instr(declStr, "void") {	; NOTE! Not sure if this was really tested.
			declStr := "11"
			cacheKey := declStr . rt_str . c
		}
		this.declStrToPtRt(declStr, pt, rt)		; Convert the declaration string to an array of numeric representation of the parameter types, pt, and return type, rt.
		bin := this.compile(rt, pt, isCdecl)
		(bin) ? this.cache[cacheKey] := bin : xlib.exception(A_ThisFunc " failed.")	; Error should not occur, throw should occur in in this.compile(...).		
			
		return bin
	}
	; db
	showCache(){
		local
		str := ""
		for k, v in this.cache
			str .= k "`t" v "`n" 
		msgbox str
	}
	; Compile
	compile(rt, pt, cdecl){		
		return a_ptrsize == 4 ? this.compile32(rt, pt, cdecl) : this.compile64(rt, pt, cdecl)
	}
	
	declToStr(decl, byref ccrt, byref isCdecl){
		static typeMap := 	a_ptrsize == 8 
							?	{	; 64 bit
									ptr		: "1",	uptr	: "1", 
									int		: "1",	uint	: "1", 
									int64	: "1",	uint64	: "1",		
									short	: "1",	ushort	: "1", 
									char	: "1",	uchar	: "1", 
									float	: "3",	double 	: "2",
									str		: "1",	wstr	: "1",	astr : "1"
								}
							:	{	; 32 bit
									ptr		: "1",	uptr	: "1", 
									int		: "1",	uint	: "1", 
									int64	: "11",	uint64	: "11",
									short	: "1",	ushort	: "1", 
									char	: "1",	uchar	: "1", 
									float	: "1",	double 	: "11",
									str		: "1",	wstr	: "1",	astr : "1"
								}
		local
		global xlib
		
		ccrt := decl.pop()	; Get the return type and calling convention. If not specified, default is __stdcall
		
		if instr(ccrt, "cdecl")
			isCdecl := true, ccrt := strreplace(ccrt,"cdecl") ; Mark as cdecl and remove cdecl from the string
		ccrt := trim(ccrt) ; trim white space in case cdecl was removed
	
		declStr := ""
		if decl.length() < 2					; either void f(void) or 'type' f(void)
			return "void" . typeMap[decl[1]]
		for k, type in decl						; type f(type1, ...)
			declStr .= typeMap.haskey(type) ? typeMap[type] : xlib.exception("Invalid paramter type: " type ".")
		
		return declStr
		
	}
	declStrToPtRt(declStr, byref pt, byref rt){
		pt := strsplit(declStr)
		rt := rt = "double" ? "2" : rt = "float" ? "3" : "1"	; 
	}
	compile32(rt, pt, cdecl := false){
		; pt is array of parameter types, int = 1, double = 2, float = 3
		; rt is the return type, int, double.
		; cdecl, true if using __cdecl calling convention. Default is false, which implies __stdcall
		static int := "1", double := "2", float := "3"
		
		local nParams := pt.length()
		
		local ss := 0x14 												; stack size, allocate 0x10 per 4 params if more than 4. Four params or less needs 0x14.
					+ (nParams > 4 	
					? 0x10*ceil((nParams-4)/4) 							
					: 0)		
						
		
								; __asm__( . )							; Instructions:
		static pushl_ebp:=		[ 1, 0x00000055 ]						; pushl	%ebp;
								
		static movl_esp_ebp :=	[ 2, 0x0000E589 ]						; movl	%esp, %ebp;
		static pushl_ebx :=		[ 1, 0x00000053 ]						; pushl	%ebx;
			
		local subl_ss_esp :=	[ 3, 0x0000EC83							; subl	$ss, %esp;
								   | ss << 16	]				
									
		static movl_ebp :=	[	[ 3, 0x0008558B ]						; movl	8(%ebp), %edx;	(*fn)
							,	[ 3, 0x0004428B ]						; movl	4(%edx), %eax;	(*args)
							,	[ 3, 0x00085A8B ]	]					; movl	8(%edx), %ebx;	(*ret)
			
		static eax_esp_0 := [	[ 2, 0x0000008B ]						; movl	(%eax), %eax;
							,	[ 3, 0x00240489 ]	]					; movl	%eax, (%esp);
		
		local raw :=		[ 	pushl_ebp 	
							,	movl_esp_ebp	
							,	pushl_ebx	
							,	subl_ss_esp	
							,	movl_ebp*			]		
			
		local ps := 4													; Param size, all params takes 4 bytes on the stack, double, long long int and such takes 8 and are pushed as two 4 byte params.
		local so														; Stack offset
			
		local eax_esp_x													; movl eax esp;
	
		loop nParams - 1 {	
				
			so := ( nParams - A_Index) * ps								; Stack offset, parameter offset (bytes) on stack, after first param.
			eax_esp_x :=	[	[ 3, 0x0000488B 	
									 | so << 16	]						; movl	xx (%eax), %ecx;
							,	[ 4, 0x00244C89 	
									 | so << 24	]	]					; movl	%ecx, xx (%esp);
			
			raw.push( eax_esp_x* )	
			if so == 0x70
				xlib.exception("Excessive amount of parameters. Not supported.")
		}	
			
		if nParams	
			raw.push( eax_esp_0* )										; Push first param onto the stack
			
		static call_edx :=	[ 2, 0x000012FF ]							; call	*(%edx);
			
		; Return is long long, 8 bytes, for integers.	
		static movl_eax_ebx :=	[	[ 2, 0x00000389 ]					; movl	%eax, (%ebx);
								,	[ 3, 0x00045389 ]	]				; movl	%edx, 4(%ebx);
		; Return for double
		static fstpl_ebx	:=	[	[ 2, 0x00001BDD ]	]				; fstpl	(%ebx);
		; Return for float
		static fstps_ebc	:=	[	[ 2, 0x00001BD9 ]	]				; fstps	(%ebx);
		raw.push( call_edx )											; Call
		
		raw.push(	( rt == int		? movl_eax_ebx 						; int
					: rt == double	? fstpl_ebx							; double
					: rt == float	? fstps_ebc		 					; float
					: xlib.exception("Invalid return type: " rt ". Acceptable range is 1-3.") )* )
			
		
		static leave :=	[	[ 3, 0x00FC5D8B ]							; movl	-4(%ebp), %ebx;
						,	[ 1, 0x000000C9 ]	]						; leave;
		
		; If cdecl, clean up stack after the call
		
		static cdecl_popl_ebx_ebp :=	[	[ 1, 0x0000005B ]			; popl	%ebx;
										,	[ 1, 0x0000005D ]	]		; popl	%ebp;

		if cdecl {														; __cdecl - caller clean up
			local cdecl_addl_ss_esp := [ 3, 0x0000C483 | ss << 16 ]		; addl	$ss, %esp;
			raw.push(	cdecl_addl_ss_esp
					,	cdecl_popl_ebx_ebp* )
		} else {														; __stdcall - callee clean up
			if nParams > 0
				raw.push(	[ 3, 0x0000EC83								
							   | nParams*4 << 16 ] )					; subl	$(nParams*4), %esp;
			
			raw.push(leave*)
		}
		static ret :=		[ 1, 0x000000C3 ]							; ret
		raw.push(ret)

		local db := false, k, v, str:=""
		if db {
			
			for k, v in raw {
				if !v.haskey(1)
					msgbox k "`t" v.2
				try str .= "[ " v.1 ", " format("0x{:08X}", v.2) " ]`n"
			}
			msgbox "db: "  "`n"  "`n" str
		}
		return this.rawPutO( raw, "" ) ; Write to memory and return pointer.
		
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	compile64(rt, pt, cdecl := false, _va := false){
		; pt is array of parameter types, int = 1, double = 2, float = 3
		; rt is the return type, int, double.
		static int := "1", double := "2", float := "3"
		local va := true	; Default for now, consider making option because not needed in general.
		
		local nParams := pt.length()
		static sds := 0x20											; shadow space
		local ss :=	sds												; ss - stack size = shadow space + 0x10 for every complete or half pair of parameters after the first four.
					+ (nParams > 4 
					? 0x10*round((nParams-4)/2) 					; More than four parameters.
					: 0)											; Less or equal to four parameters.
		
								; __asm__( . )						; Instructions:
		static pushq_rbx :=		[ 1, 0x00000053 ]					; %rbx;
		                                                            
		local subq_ss_rsp :=	[ 4, 0x00EC8348 					; subq	$ss, %rsp;
								   |   ss << 24 ]					
		
		static mov_rcx :=	[	[ 3, 0x00CA8949 ]					; movq	%rcx, %r10;			(*fn)
							,	[ 4, 0x08418B48 ]					; movq	08 (%rcx), %rax;	(*args)
							,	[ 4, 0x10598B48 ]	]				; movq	16 (%rcx), %rbx;	(*ret)
		
		; Four first parameters - double - float in xmm0-xmm3, int - rcx,rdx,r8,r9
		static i4 := 		[	[ 3, 0x00088B48 ]					; movq 00  (%rax), %rcx;
							,	[ 4, 0x08508B48 ]					; movq 08  (%rax), %rdx;
							,	[ 4, 0x10408B4C ]					; movq 16  (%rax), %r8;
							,	[ 4, 0x18488B4C ]	]				; movq 24  (%rax), %r9;
																		
		static d4 :=		[	[[ 4, 0x00100FF2 ]]					; movsd	00 (%rax), %xmm0;
							 ,	[[ 4, 0x48100FF2 ]					; movsd	08 (%rax), %xmm1;
								,[ 1, 0x00000008 ]]	                
							 ,	[[ 4, 0x50100FF2 ]					; movsd	16 (%rax), %xmm2;
								,[ 1, 0x00000010 ]]                  
							 ,	[[ 4, 0x58100FF2 ]					; movsd	24 (%rax), %xmm3;
								,[ 1, 0x00000018 ]]	]
		
		static f4 := 		[	[[ 4, 0x00100FF3 ]]					; movss	00 (%rax), %xmm0;
							 ,	[[ 4, 0x48100FF3 ]					; movss	08 (%rax), %xmm1;
								,[ 1, 0x00000008 ]]					 
							 ,	[[ 4, 0x50100FF3 ]					; movss	16 (%rax), %xmm2;
								,[ 1, 0x00000010 ]]					 
							 ,	[[ 4, 0x58100FF3 ]					; movss	24 (%rax), %xmm3;
								,[ 1, 0x00000018 ]]	]			

		local raw := []		; Array of raw instructions.
		
		raw.push(pushq_rbx)
		raw.push(subq_ss_rsp)
		raw.push(mov_rcx*)
		
		; Note: when va := true first four params must be put in both int and float registers.
		local pt4 := []	; First four parameters
		loop nParams > 4 ? 4 : nParams
			pt4.push( pt.removeAt(1) )
		local k, t
		for k, t in pt4	; t is type
			(t == int)			? raw.push( i4[ k ]  )						; 'Int' params
		: 	(t == double)		? raw.push( d4[ k ]* )						; Double params
		: 	(t == float)		? raw.push( f4[ k ]* )						; Float params
		: 	xlib.exception("Invalid parameter type for paramter: " k ", type: " t ". Acceptable range is 1-3.") 
		
		; Add param first four to registers if 'va'
		if va && pt4.length()
			for k, t in pt4
				(t == int) 		? raw.push( d4[ k ]* )						; if int, put in double xmmX
			:	(t == double)	? raw.push( i4[ k ] )						; if double, put in int registers
			:	""															; nvm if float, not supported by standard. Should be error if va not set by default.
		; Handle parameters five, ...
		local ps := 8						; Parameter size, all params take 8 bytes on the stack
		local so							; Stack offset. Parameter offset (bytes) on stack.
		for k in pt {						; up to 0x78
			so := sds + (k-1) * ps
			raw.push( [ 4, 0x00588B4C 		; movq so (%rax), %r11;
						 | so << 24	  ]     
					 ,[ 4, 0x245C894C ]		; movq %r11, so (%rsp);
					 ,[ 1, so 		  ] )	; 
			if so == 0x70
				xlib.exception("Excessive amount of parameters. Not supported.")
		}

		
		
		static call_r10 := 		[ 3, 0x0012FF41 ]					; call	*(%r10);
		
		; Returns, int, double, float:
		static movq_rax_rbx := 	[ 3, 0x00038948	]					; movq	%rax, (%rbx);
		static movsd_xmm0_rbx:= [ 4, 0x03110FF2 ]					; movsd	%xmm0, (%rbx);
		static movss_xmm0_rbx:= [ 4, 0x03110FF3 ]					; movss	%xmm0, (%rbx);
		
		; Stack
		local addq_ss_rsp	:=	[ 4, 0x00C48348						; addq	$ss, %rsp;
								  |  ss << 24	]					
		; Return
		static popq_rbx	:=		[ 1, 0x0000005B ]					; popq	%rbx;
		static ret	:=  		[ 1, 0x000000C3 ]					; ret;
		
		; final assemble
		raw.push(call_r10)											; Call
																	; Return type:
		
		raw.push(  rt == int 	? movq_rax_rbx 						; int
				 : rt == double ? movsd_xmm0_rbx					; double
				 : rt == float 	? movss_xmm0_rbx 					; float
				 : xlib.exception("Invalid return type: " rt ". Acceptable range is 1-3.") )	; Invalid
		
		
		raw.push(addq_ss_rsp)
		raw.push(popq_rbx)
		raw.push(ret)
		
		; db
		local db := false, v, str :=""
		if db {
			for k, v in raw
				str .= "[ " v.1 ", " format("{:#08X}", v.2) " ]`n"
			msgbox str
		}
		return this.rawPutO( "", raw ) ; Write to memory and return pointer.
	}
	rawPutO(raw32,raw64){
		local bin, raw, o, e
		bin:=xlib.mem.virtualAlloc((raw:=(A_PtrSize==4?raw32:raw64)).length()*4)
		o := 0
		try {
			for k, pair in raw
				NumPut(pair[2], bin, o, "Int"), o += pair[1]
		} catch e {
			xlib.virtualFree( bin )
			xlib.exception(e.message "`t" o)
		}
		return bin
	
	}
}