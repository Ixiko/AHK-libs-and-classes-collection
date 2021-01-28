#include <DirectX\Headers\_d3D9.h>
#include <DirectX\d3DX9>

global IDirect3D9, IDirect3DDevice9, IDirect3DPixelShader9, IDirect3DVertexBuffer9, IDirect3DTexture9, IDirect3DSurface9 

dumpPixelShader(pShader, file)
{
	dllcall(IDirect3DPixelShader9.GetFunction, uint, pShader, uint, 0, "uint*", size)
	VarSetCapacity(data, size)
	dllcall(IDirect3DPixelShader9.GetFunction, uint, pShader, uint, &data, "uint*", size)
	f := fileopen(file, "w")
	f.rawwrite(&data, size)
	f.close()
}	

class ShaderDataCollection
{
	__new(dir, pDevice = "", file = "")
	{
		this.collection := []
		if not file
			ini := new ini(dir "\shader.ini")
		else ini := new ini(file)
		loop, %dir%\*.bin, 0, 0
		{
			f := FileOpen(A_loopfilefullpath, "r")	
			PMEM := dllcall("VirtualAlloc", uint, 0, uint, f.Length, Int, 0x00001000 | 0x00002000
										  , uint, (PAGE_READWRITE := 0x04) )
			
			f.RawRead(PMEM+0, f.Length)	
			entry := {}
			entry.pData := PMEM
			entry.size := f.Length
			entry.shader := 0
			entry.bool := []
			entry.float := []
			entry.int := []			
						
			if pDevice
			{
				splitpath, A_loopfilefullpath, , , , fname
				
				if fileexist(dir "\" fname ".h") {
					d3DX9.CompileShaderFromFile(pDevice, dir "\" fname ".h", "PixelShaderFunction", pShader)
					entry.shader := pShader
				}
			}
			
			entry.preserve := ini.isTrue("preserve", fname)	
			bool := strsplit(ini.read("bool", fname), " ")
			pBool := dllcall("VirtualAlloc", uint, 0, uint, bool._MaxIndex() * 4, Int, 0x00001000 | 0x00002000
										   , uint, (PAGE_READWRITE := 0x04) )
			for k, v in bool
			{
				if (v = "True")
					numput(1, pBool + (k-1)*4, "int")
				else numput(0, pBool + (k-1)*4, "int")
			}	
			entry.pBool := pBool
			entry.szBool := bool._MaxIndex() * 4
			this.collection.insert(entry)				
			f.close()			
		}		
	}

	find(pShader)
	{
		dllcall(IDirect3DPixelShader9.GetFunction, uint, pShader, uint, 0, "uint*", size)
		VarSetCapacity(data, size)
		dllcall(IDirect3DPixelShader9.GetFunction, uint, pShader, uint, &data, "uint*", size)
		
		for k, v in this.collection
		{
			if (v.size = size)
			{
				;print("data check")
				if ( dllcall("ntdll.dll\RtlCompareMemory", "uint", &data, "uint", v.pData, "uint", size, uint) =  size )
					return v						
			}	
			;else
				;Print("dump: " v[1] " shader: " size "`n")			
		}
		print("`n")
		return False	
	}	
	__delete()
	{
		for k, v in this.collection
			dllcall("VirtualFree", uint, v.pBool, uint, 0, uint, (MEM_RELEASE := 0x8000) )
	}
}


class FlatRect9 {

__new(pDevice, dim, tex) {
	
	texture := tex		
	vertex := "float x; float y; float z; float rhw; float u; float v;"	
		
	this.device := pDevice
	this.rect := struct("vertex[4]")
	this.flags := D3DFVF_XYZRHW | D3DFVF_TEX1
	this.texture := texture
	
	r := dllcall(IDirect3DDevice9.CreateVertexBuffer, uint, pDevice, uint, this.rect.size(), uint, 0
											        , uint, this.flags
										            , uint, (D3DPOOL_DEFAULT := 0)
											        , "uint*", pVbuffer, uint, 0)
	this.pVbuff := 	pVbuffer	
	this.update(dim, tex)	
}

update(dim, tex) 
{
	dims := strsplit(dim, "|")
	this.rect.1.x := dims[1]+ 0, this.rect.1.y := dims[2]+ 0, this.rect.1.z := 1, this.rect.1.rhw := 1
	this.rect.2.x := dims[3]+ 0, this.rect.2.y := dims[2]+ 0, this.rect.2.z := 1, this.rect.2.rhw := 1 
	this.rect.3.x := dims[1]+ 0, this.rect.3.y := dims[4]+ 0, this.rect.3.z := 1, this.rect.3.rhw := 1 
	this.rect.4.x := dims[3]+ 0, this.rect.4.y := dims[4]+ 0, this.rect.4.z := 1, this.rect.4.rhw := 1 
	
	this.rect.1.u := 0., this.rect.1.v := 0.
	this.rect.2.u := 1., this.rect.2.v := 0.
	this.rect.3.u := 0., this.rect.3.v := 1.
	this.rect.4.u := 1., this.rect.4.v := 1.		
		
	r := dllcall(IDirect3DVertexBuffer9.lock, uint, this.pVbuff, uint, 0, uint, 0, "ptr*", pData, uint, 0)
	dllcall("RtlMoveMemory", ptr, pData, ptr, this.rect[], uint, this.rect.size())	
	r := dllcall(IDirect3DVertexBuffer9.unlock, uint, this.pVbuff)		
}	

draw()
{
	dllcall(IDirect3DDevice9.SetTextureStageState, uint, this.device, uint, 0, uint, (D3DTSS_COLOROP := 1), uint, (D3DTOP_SELECTARG1 := 2) )
	dllcall(IDirect3DDevice9.SetTextureStageState, uint, this.device, uint, 0, uint, (D3DTSS_COLORARG1 := 2), uint, (D3DTA_TEXTURE := 0x00000002) )
	;dllcall(IDirect3DDevice9.SetTextureStageState, uint, this.device, uint, 0, uint, (D3DTSS_COLORARG2 := 3), uint, (D3DTA_DIFFUSE := 0x00000000) )
	dllcall(IDirect3DDevice9.SetTexture, uint, this.device, uint, 0, uint, this.texture.pTexture)
		
	dllcall(IDirect3DDevice9.SetFVF, uint, this.device, uint, this.flags, uint) 
	dllcall(IDirect3DDevice9.SetStreamSource, uint, this.device, uint, 0, uint, this.pVbuff, uint, 0, uint, this.rect.size()/4)
	dllcall(IDirect3DDevice9.DrawPrimitive, uint, this.device, uint, (D3DPT_TRIANGLESTRIP := 5), uint, 0, uint, 2)								 
}

__delete() {
	 dllcall(IDirect3DVertexBuffer9.release, uint, this.pVbuff)	 
}	
}

class Texture9
{
	__delete()
	{
		dllcall(IDirect3DTexture9.release, uint, this.pTexture)
		dllcall(Surface9 .release, uint, this.pSurface)		 
	}
}	

getRenderTargetTexture9(pDevice, pixelformat = "ARGB", width = 640, height = 480
					   , usage = 0x00000001)
{
	static pixelsformats := {"ARGB" : 21, "RGB" : 23}
			
	VarSetCapacity(p_text9, 4)	
	r := dllcall(IDirect3DDevice9.CreateTexture, uint, pDevice
					, uint, width
					, uint, height
					, uint, 1
					, uint, usage 
					, uint, pixelsformats[pixelformat]
					, uint, (D3DPOOL_DEFAULT := 0) 
					, "uint*", p_text9
					, uint, 0, uint)						
    if (r != 0)
		return " IDirect3DTexture9 interface " r " - " d3D9.result[r . ""]			
		
	r := dllcall(IDirect3DTexture9.GetSurfaceLevel, uint, p_text9, uint, 0, "uint*", p_surf9)
	if (r != 0)
		return " IDirect3DSurface9 interface " r " - " d3D9.result[r . ""]		
	
	T := new Texture9()
	T.pTexture := p_text9
	T.pSurface := p_surf9
	return t
}	

getDirect3D9(h_win = "", windowed = True, refresh = 60, ww = 640, hh = 480
			,pixelformat = "ARGB", dll = "d3dx9_24.dll")
{
	static pixelformats := {"ARGB" : 21, "RGB" : 23}
			
	hModule := dllcall("LoadLibraryW", str, "d3D9.dll")
	Direct3DCreate9 := dllcall("GetProcAddress", uint, hModule, astr, "Direct3DCreate9")
	
	if ( (not hModule) or (not Direct3DCreate9) )
		return "Failed to get the entry point of the Direct3DCreate9 procedure or get the handle to d3D9.dll " A_lasterror

	p_d3D9 := dllcall(Direct3DCreate9, uint, D3D_SDK_VERSION)
	if not p_d3D9
		return "Failed to create the IDirect3D9 interface " r " - " d3D9.result[r . ""]
		
	IDirect3D9 := new ComInterfaceWrapper(d3D9.IDirect3D9, p_d3D9, True)
					
	if not h_win
		h_win := A_scripthwnd ;ui_GetHidenWindowHandle()
	
	VarSetCapacity(p_d3D9Dev, 4)
	ZeroMem(D3DPRESENT_PARAMETERS)
    D3DPRESENT_PARAMETERS.Windowed := windowed  
	D3DPRESENT_PARAMETERS.RefreshRateInHz := refresh
	D3DPRESENT_PARAMETERS.BackBufferWidth := ww
	D3DPRESENT_PARAMETERS.BackBufferHeight := hh
	D3DPRESENT_PARAMETERS.SwapEffect := (D3DSWAPEFFECT_DISCARD := 1)
    D3DPRESENT_PARAMETERS.hDeviceWindow := h_win
	D3DPRESENT_PARAMETERS.Flags := (D3DPRESENT_LOCKABLE_BACKBUFFER := 0x00000001)
	D3DPRESENT_PARAMETERS.BackBufferFormat := pixelformats[pixelformat]
	
	r := dllcall(IDirect3D9.CreateDevice, uint, IDirect3D9.p
									, uint, (D3DADAPTER_DEFAULT := 0)
									, uint, (D3DDEVTYPE_HAL := 1)
									, uint, h_win
									, uint, D3DCREATE_HARDWARE_VERTEXPROCESSING
									, uint, D3DPRESENT_PARAMETERS[]
									, uint, &p_d3D9Dev, uint)  
	if (r > 0)
		return "Failed to create the IDirect3DDevice9 interface " r " - " d3D9.result[r . ""]
			
	IDirect3DDevice9 := new ComInterfaceWrapper(d3D9.IDirect3DDevice9, &p_d3D9Dev)
	
	d3DX9.__new(dll)
	shader := "float4 PixelShaderFunction(float4 color: COLOR0) : COLOR0`n"  
	       . "{`nreturn float4(0,0,0,0);`n};"
	
	r := d3DX9.CompileShader(IDirect3DDevice9.p, shader, "PixelShaderFunction", pShader)
	if (r != 0)
		return "Failed to create the IDirect3DPixelShader9 interface " r " - " d3D9.result[r . ""]
	
	IDirect3DPixelShader9 := new ComInterfaceWrapper(d3D9.IDirect3DPixelShader9, pShader, True)
	;IDirect3DPixelShader9.__release()
	
	r := dllcall(IDirect3DDevice9.CreateVertexBuffer, uint, IDirect3DDevice9.p, uint, 20, uint, 0
												    , uint, D3DFVF_XYZRHW | D3DFVF_DIFFUSE
										            , uint, 0, "uint*", pVbuffer, uint, 0)
	if (r != 0)
		return "Failed to create the IDirect3DVertexBuffer9 interface " r " - " d3D9.result[r . ""]
	
	IDirect3DVertexBuffer9 :=  new ComInterfaceWrapper(d3D9.IDirect3DVertexBuffer9, pVbuffer, True)
	;IDirect3DVertexBuffer9.__release()
	
	r := dllcall(IDirect3Ddevice9.GetRenderTarget, uint, IDirect3Ddevice9.p, uint, 0, "uint*", p_backbuffer) 
	if (r != 0)
		return "Failed to create the IDirect3DSurface9 interface " r " - " d3D9.result[r . ""]
	IDirect3DSurface9 := new ComInterfaceWrapper(d3D9.IDirect3DSurface9, p_backbuffer, True)
	
	r := dllcall(IDirect3DDevice9.CreateTexture, uint, IDirect3Ddevice9.p
					, uint, 256
					, uint, 256
					, uint, 1
					, uint, D3DUSAGE_DYNAMIC := 0x00000200
					, uint, pixelformats[pixelformat]
					, uint, (D3DPOOL_DEFAULT := 0) 
					, "uint*", p_text9
					, uint, 0, uint)				
	if (r != 0)
		return "Failed to create the IDirect3DTexture9 interface " r " - " d3D9.result[r . ""]
	IDirect3DTexture9 := new ComInterfaceWrapper(d3D9.IDirect3DTexture9, p_text9, True)	
	;IDirect3DTexture9.__release()	
			
	return "Succeeded to create the DirectX9 interfaces"	
}

releaseDirect3D9()
{
	IDirect3DPixelShader9.__release()
	IDirect3DVertexBuffer9.__release()
	IDirect3DSurface9.__release()
	IDirect3DTexture9.__release()
	IDirect3DDevice9.__release()
	IDirect3D9.__release()
}
	