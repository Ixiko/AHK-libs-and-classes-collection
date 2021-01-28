#include <DirectX\Headers\d3DX9>

global ID3DXBuffer

class d3DX9 {

__new(dll = "d3dx9_24.dll")
{
	this.h_dll := ""
	this.pD3DXLoadSurfaceFromFile := ""
	this.pD3DXCreateFont := ""
	
	h_dll := dllcall("GetModuleHandle", str, dll)
	h_dll ?: h_dll := dllcall("LoadLibraryW", str, dll)
	if not h_dll
		return ""		
	
	this.h_dll := h_dll
	this.pD3DXLoadSurfaceFromFile := dllcall("GetProcAddress", uint, this.h_dll, astr, "D3DXLoadSurfaceFromFileW")
	this.pD3DXCreateFont := dllcall("GetProcAddress", uint, this.h_dll, astr, "D3DXCreateFontW")
	this.D3DXCompileShader := dllcall("GetProcAddress", uint, this.h_dll, astr, "D3DXCompileShader")
	this.D3DXCompileShaderFromFile :=  dllcall("GetProcAddress", uint, this.h_dll, astr, "D3DXCompileShaderFromFileA") 
	this.D3DXGetPixelShaderProfile := dllcall("GetProcAddress", uint, this.h_dll, astr, "D3DXGetPixelShaderProfile")
	this.D3DXCreateBuffer :=  dllcall("GetProcAddress", uint, this.h_dll, astr, "D3DXCreateBuffer")
	this.D3DXCreateTextureFromFile := dllcall("GetProcAddress", uint, this.h_dll, astr, "D3DXCreateTextureFromFileW")
	this.rect := Struct("LONG left; LONG top; LONG right; LONG bottom;")
	this.POINT := Struct("LONG x; LONG y;")
}	

CreateTextureFromFile(pDevice, file, byref pTexture){
	return dllcall(this.D3DXCreateTextureFromFile
	,uint, pdevice, str, file, "uint*", pTexture)
}

LoadSurfaceFromFile(pSurface, file, filter = 1)
{	
	RETURN dllcall(this.pD3DXLoadSurfaceFromFile
		, uint, pSurface
		, uint, pDestPalette
		, uint, 0
		, str, file 
		, uint, 0
		, uint, filter
		, uint, ColorKey
		, uint, pSrcInfo, uint)
}

CreateFontW(pDevice, font = "Verdana", italic = False)
{
	r := dllcall(this.pD3DXCreateFont
		, uint, pDevice
		, int, 0
		, int, 0
		, int, 600
		, uint, 0
		, uint, italic
		, uint, 0
		, uint, 0
		, uint, 0
		, uint, 0
		, str, font
		, "uint*", pID3DXFont, uint)
		
	if r 
		return	r
		
	fnt := new ComInterfaceWrapper(d3DX9core.ID3DXFont, pID3DXFont, True)	
	return fnt
}

DrawText(byref fnt, txt, clr = 0xFFFFFFFF, rct = "")
{
	if not rct
		rct := "0|0|640|480"
	rct_ := strsplit(rct, "|")
	this.rect.left := rct_[1]
	this.rect.top := rct_[2]
	this.rect.right := rct_[3]	
	this.rect.bottom := rct_[4]	
	
	r := dllcall(fnt.DrawTextW, uint, fnt.p
		, uint, 0
		, str,  txt
		, int, -1
		, uint, this.RECT[]
		, uint, 256
		, uint, clr
		, uint)
		
	return r 
}

CompileShaderFromFile(pDevice, file, entrypoint, byref pShader)
{	
	
	r := dllcall(this.D3DXCompileShaderFromFile
	, astr, file
	, uint, 0
	, uint, 0
	, astr, entrypoint
	, astr, "ps_3_0"
	, uint, 0
	, "uint*", pShader
	, "uint*", pError
	, uint, 0, uint)	

	if r
		use := pError
	else use := pShader
	
	if not ID3DXBuffer
		ID3DXBuffer := new ComInterfaceWrapper(D3DX9Mesh.ID3DXBuffer, use, True)
	else ID3DXBuffer.p := use		
		
	_ptr := dllcall(ID3DXBuffer.GetBufferPointer, uint, ID3DXBuffer.p)	
	size := dllcall(ID3DXBuffer.GetBufferSize, uint, ID3DXBuffer.p)		
	
	if r 
	{
		rr := strget(_ptr+0, size, "CP0")
		ID3DXBuffer.__release()
		return rr
	}	
		
	else
	{
		r := dllcall(IDirect3DDevice9.CreatePixelShader, uint, pDevice, uint, _ptr, "uint*", pShader)
		ID3DXBuffer.__release()
		return r 
	}	
}	

CompileShader(pDevice, byref Shader, entrypoint, byref pShader)
{	
	r := dllcall(this.D3DXCompileShader
	, astr, Shader
	, UINT, strlen(Shader) 
	, uint, 0
	, uint, 0
	, astr, entrypoint
	, astr, "ps_3_0"
	, uint, 0
	, "uint*", pShader
	, "uint*", pError
	, uint, 0, uint)

	if r
		use := pError
	else use := pShader
	
	if not ID3DXBuffer
		ID3DXBuffer := new ComInterfaceWrapper(D3DX9Mesh.ID3DXBuffer, use, True)
	else ID3DXBuffer.p := use		
		
	_ptr := dllcall(ID3DXBuffer.GetBufferPointer, uint, ID3DXBuffer.p)	
	size := dllcall(ID3DXBuffer.GetBufferSize, uint, ID3DXBuffer.p)		
	
	if r 
	{
		rr := strget(_ptr+0, size, "CP0")
		ID3DXBuffer.__release()
		return rr
	}	
		
	else
	{
		r := dllcall(IDirect3DDevice9.CreatePixelShader, uint, pDevice, uint, _ptr, "uint*", pShader)
		ID3DXBuffer.__release()
		return r 
	}	
}	

}




