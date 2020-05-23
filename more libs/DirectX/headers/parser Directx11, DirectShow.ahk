class CppWrapperB extends CppWrapper {
_5thpass()
{
	this.interfaces := {}		
	fileappend,	% this.filename ".h: Alt Pass5 - Retriving COM inerfaces definitions`n", *	
	contents := this.preproc
	loop, parse, contents, "`n"
	{
		for k, v in this.GUIDs
		{
			interface := v[1]
			stringreplace, interface, interface, IID_, ,
			if not errorlevel
			this.interfaces[interface] ?: this.interfaces[interface] := [interface, "`n""`n"]
			if instr(A_loopfield, " " interface) 
			{
				method := RegExReplace(A_loopfield, "#define " interface "_")
				stringreplace, method, method, (, )(
				method := "STDMETHOD(" trim(strsplit(method, " ")[1])
				
				;fileappend, method found for interface %interface%`n, *
				(method = "STDMETHOD(#define") ?: this.interfaces[interface][2] .= method "`n"
			}
		}
	}		
	for k, v in this.interfaces
		fileappend, % "`n" k "`n" v[2] "...`n", *	
}

_6thpass()
{
	fileappend,	% this.filename ".h: Pass6 - Retriving Constants definitions`n", *
	preproc := this.preproc
	loop, parse, preproc, "`n"
		{
			if instr(A_Loopfield, "#define") and instr(A_Loopfield, "(")
			{
				field := strsplit(A_Loopfield, "(")
				val := field[2]
				stringreplace, val, val, ), ,
				stringreplace, val, val, `n, ,
				stringreplace, val, val, `r, ,
				if not instr(val, "0x")
					stringreplace, val, val, f, ,
				val := trim(val)
				val := val + 0
				if val is number 
				{
					const := field[1]
					if instr(const, " ")
						continue
					stringreplace, const, const, #define, ,
					const := trim(const)
					fileappend, % A_Loopfield "`n", *
					fileappend, % field[1] "`n", *
					this.constants[const] := val
				}
			}			
		}	
}

_7thpass()
{
	fileappend,	% this.filename ".h: Pass7 - Retriving error constants definitions`n", *
	preproc := this.preproc
	loop, parse, preproc, "`n"
		{
			token := regexreplace(A_loopfield, "\s+", " ")
			stringsplit, token_, token, %A_space%			
			if instr(token_3, "MAKE_D3D11_HRESULT") 
				{
					code := regexreplace(A_loopfield, ".*MAKE_D3D11_HRESULT\(", "")
					stringreplace, code, code, ), ,
					stringreplace, code, code, %A_space%, ,1
					stringreplace, code, code, `r, ,1	
					VarSetCapacity(error_code, 4)					
					error_code := 1<<31 | 0x87c<<16 | code	
					this.error_constants[token_2] := error_code
				}					
		}	
	
}

process_interfaces() {	
return
}
}

class dshow_h_parser extends CppWrapperB {
patch() {
	this.filename := "dshow"		
}
}

#include HeaderParser.ahk

;dshow := new dshow_h_parser("C:\Program Files\Microsoft SDKs\Windows\v7.0\Include\control.h")
;dshow.save("dshow.h.ahk")

dx11 := new CppWrapperB("C:\Program Files (x86)\Microsoft DirectX SDK (June 2010)\Include\D3D11.h")
dx11.save("d3d11.h.ahk")
