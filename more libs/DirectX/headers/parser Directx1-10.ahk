class ddraw_h_parser extends CppWrapper {
_7thpass()
{
	fileappend,	% this.filename ".h: Pass7 - Retriving error constants definitions`n", *
	preproc := this.preproc
	loop, parse, preproc, "`n"
		{
			token := regexreplace(A_loopfield, "\s+", " ")
			stringsplit, token_, token, %A_space%			
			if instr(token_3, "MAKE_DDHRESULT") 
				{
					code := regexreplace(A_loopfield, ".*MAKE_DDHRESULT\(", "")
					stringreplace, code, code, ), ,
					stringreplace, code, code, %A_space%, ,1
					stringreplace, code, code, `r, ,1	
					VarSetCapacity(error_code, 4)					
					error_code := 1<<31 | 0x876<<16 | code	
					;err := numget(&erro_code, "uint")
					;fileappend, % token_2 " > " code " > " error_code "`n", *					
					this.error_constants[token_2] := error_code
				}	
		}	
}
}


class d3d_h_parser extends ddraw_h_parser {
patch()
{	
	for k, v in this.interfaces {
		;fileappend, % v[1] "`n", *
		if v[1] = "extern""C"" {IDirect3D"
			{
				v[1] := "IDirect3D"
				def := v[2]
				stringreplace, def, def, extern "C" {"`n, "`n,
				;fileappend, % errorlevel "`n", *
				v[2] := def
			}	
	}
}
}

class d3dtypes_h_parser extends ddraw_h_parser {
}

class d3sound_h_parser extends ddraw_h_parser {
_7thpass()
{
	fileappend,	% this.filename ".h: Pass7 - Retriving error constants definitions`n", *
	preproc := this.preproc
	loop, parse, preproc, "`n"
		{
			token := regexreplace(A_loopfield, "\s+", " ")
			stringsplit, token_, token, %A_space%			
			if instr(token_3, "MAKE_DSHRESULT") 
				{
					code := regexreplace(A_loopfield, ".*MAKE_DSHRESULT\(", "")
					stringreplace, code, code, ), ,
					stringreplace, code, code, %A_space%, ,1
					stringreplace, code, code, `r, ,1	
					VarSetCapacity(error_code, 4)					
					error_code := 1<<31 | 0x878<<16 | code	
					;err := numget(&erro_code, "uint")
					;fileappend, % token_2 " > " code " > " error_code "`n", *					
					this.error_constants[token_2] := error_code
				}					
		}	
	
}
}

class d3D9_h_parsers extends CppWrapper {
_7thpass()
{
	fileappend,	% this.filename ".h: Pass7 - Retriving error constants definitions`n", *
	preproc := this.preproc
	loop, parse, preproc, "`n"
		{
			token := regexreplace(A_loopfield, "\s+", " ")
			stringsplit, token_, token, %A_space%			
			if instr(token_3, "MAKE_D3DHRESULT") 
				{
					code := regexreplace(A_loopfield, ".*MAKE_D3DHRESULT\(", "")
					stringreplace, code, code, ), ,
					stringreplace, code, code, %A_space%, ,1
					stringreplace, code, code, `r, ,1	
					VarSetCapacity(error_code, 4)					
					error_code := 1<<31 | 0x876<<16 | code	
					;err := numget(&erro_code, "uint")
					;fileappend, % token_2 " > " code " > " error_code "`n", *					
					this.error_constants[token_2] := error_code
				}
			if instr(token_3, "MAKE_D3DSTATUS") 
				{
					code := regexreplace(A_loopfield, ".*MAKE_D3DSTATUS\(", "")
					stringreplace, code, code, ), ,
					stringreplace, code, code, %A_space%, ,1
					stringreplace, code, code, `r, ,1	
					VarSetCapacity(error_code, 4)					
					error_code := 0<<31 | 0x876<<16 | code	
					;err := numget(&erro_code, "uint")
					;fileappend, % token_2 " > " code " > " error_code "`n", *					
					this.error_constants[token_2] := error_code
				}	
			
		}	
	
}
}

class dinput_h_parser extends CppWrapper {
_6thpass() ;process constants
{
	fileappend,	% this.filename ".h: Pass6 - Retriving Constants definitions`n", *
	preproc := this.preproc
	loop, parse, preproc, "`n"
		{
			stringreplace, token, A_loopfield, (HRESULT), ,
			stringreplace, token, token, ), ,
			stringreplace, token, token, (, ,
			token := regexreplace(token, "\s+", " ")
			stringsplit, token_, token, %A_space%
			if not token_3 
				continue
			stringreplace, token_3, token_3, L, 
			if token_3 is not xdigit 
				continue
			if instr(token_1, "#define") {
					;fileappend, % A_loopfield, *
					this.constants[token_2] := token_3	
				}	
		}	
			
}	
}

#singleinstance force
#include <_Struct>
#include HeaderParser.ahk


;ddraw := new ddraw_h_parser("C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Include\ddraw.h")
;ddraw.save("ddraw.h.ahk")

;d3d := new d3d_h_parser("C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Include\d3d.h")
;d3d.save("d3d.h.ahk")

;d3dtypes := new d3dtypes_h_parser("C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Include\d3dtypes.h")
;d3dtypes.save("d3dtypes.h.ahk")

;d3sound := new d3sound_h_parser("C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Include\dsound.h")
;d3sound.save("dsound.h.ahk")

;d3d9 := new d3D9_h_parsers("C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Include\d3D9.h")
;d3d9.save("d3D9.h.ahk")

;d3d9types := new d3D9_h_parsers("C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Include\d3D9types.h")
;d3d9types.save("d3D9types.h.ahk")

;dinput := new dinput_h_parser("C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Include\dinput.h")
;dinput.save("dinput.h.ahk")

;d3DX9core := new CppWrapper("C:\Program Files (x86)\Microsoft DirectX SDK (June 2007)\Include\d3DX9core.h")
;d3DX9core.save("d3DX9core.h.ahk")

;gl := new CppWrapper("C:\Program Files\Microsoft SDKs\Windows\v7.0\Include\gl\GL.h")
;gl.save("gl.h.ahk")




					