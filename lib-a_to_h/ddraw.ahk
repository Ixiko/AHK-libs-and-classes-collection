#include <DirectX\headers\_ddraw.h>
#include <DirectX\headers\_d3D.h>
;#include <GUI>

/*
Surface3: Directshow
DirectX3 - DirectDraw2, Surface2, Direct3D, 3DDevice, ExecuteBuffer, Viewport, Texture, Material, Direct3DLight
DirectX5 - DirectDraw, Surface, Direct3D2, 3DDevice2, no Excutebuffer, Viewport2, Texture2, Material2, Lights?
DirectX6 - DirectDraw4, Surface4, Direct3D3, 3DDevice3, VertexBuffer, Viewport3, Texture2, Material3, Lights?
*/

global IDirectDrawSurface3, IDirectDrawCliper
global IDirectDraw, IDirectDrawSurface
global IDirectDraw2, IDirectDrawSurface2								    	
global IDirectDraw4, IDirectDrawSurface4						 

fourCC(code)
{
	if code is not number 
		{
			VarSetCapacity(rcode, 4)
			loop, parse, code
			{
				var := A_loopfield
				numput(numget(var, "char"), rcode, A_index - 1, "char")	
				
			} return numget(rcode, "int")
		}
	/*
	Loop, Parse, Str
		nStr=%A_LoopField%%nStr%
	Return nStr
	*/
}	

setPixelFormat(format = "RGB")
{
	if (format = "RGB") 	{
			DDPIXELFORMAT.dwFlags := DDPF_RGB 
			DDPIXELFORMAT.dwSize := DDPIXELFORMAT.size()	
			DDPIXELFORMAT.dwRGBBitCount := 16
			DDPIXELFORMAT.dwRBitMask := 0xF800
			DDPIXELFORMAT.dwGBitMask := 0x07e0
			DDPIXELFORMAT.dwBBitMask := 0x001F				
		}
		
	else if (format = "XRGB") 	{
			DDPIXELFORMAT.dwFlags := DDPF_RGB 
			DDPIXELFORMAT.dwSize := DDPIXELFORMAT.size()	
			DDPIXELFORMAT.dwRGBBitCount := 16
			DDPIXELFORMAT.dwRBitMask := 0x00007C00  
			DDPIXELFORMAT.dwGBitMask := 0x000003E0  
			DDPIXELFORMAT.dwBBitMask := 0x0000001F 
		}	
		
	else if (format = "ARGB16") 	{
			DDPIXELFORMAT.dwFlags := DDPF_RGB | DDPF_ALPHAPIXELS
			DDPIXELFORMAT.dwSize := DDPIXELFORMAT.size()	
			DDPIXELFORMAT.dwRGBBitCount := 16
			DDPIXELFORMAT.dwRBitMask := 0x00007C00  
			DDPIXELFORMAT.dwGBitMask := 0x000003E0  
			DDPIXELFORMAT.dwBBitMask := 0x0000001F 
			DDPIXELFORMAT.dwRGBAlphaBitMask := 0x00008000		
		}		
		
	else if (format = "ARGB")	{	
			DDPIXELFORMAT.dwFlags := DDPF_RGB | DDPF_ALPHAPIXELS
			DDPIXELFORMAT.dwSize := DDSURFACEDESC.size("ddpfPixelFormat")	
			DDPIXELFORMAT.dwRGBBitCount := 32
			DDPIXELFORMAT.dwRBitMask := 0x00FF0000
			DDPIXELFORMAT.dwGBitMask := 0x0000FF00
			DDPIXELFORMAT.dwBBitMask := 0x000000FF
			DDPIXELFORMAT.dwRGBAlphaBitMask := 0xFF000000
		}	
	
	else if (format = "YUY2")	{	
			DDPIXELFORMAT.dwFlags := DDPF_FOURCC
			DDPIXELFORMAT.dwSize := DDSURFACEDESC.size("ddpfPixelFormat")
			DDPIXELFORMAT.dwFourCC := fourcc("YUY2")
		}		
}	

getPixelFormat(byref desk)
{
	if (desk.ddpfPixelFormat.dwRGBBitCount = 32)
		return "ARGB"
	else
	{
		if (desk.ddpfPixelFormat.dwRBitMask = 0xF800)
			return "RGB"
		else if (desk.ddpfPixelFormat.dwRBitMask = 0x00007C00)
		{
			if (desk.ddpfPixelFormat.dwRGBAlphaBitMask = 0x00008000)
				return "ARGB16"
			else return "XRGB"	
		}
	}
}	

LoadTexture(pInterface, pDevice, file_, byref ret, colorkey = "")
{
	critical
	colorkey ?: colorkey := {"RGB" : 0x07e0, "XRGB" : 0}	
	static pcopyData2Surface, desc 
	if not pcopyData2Surface
	{
		pcopyData2Surface := dllcall("GetProcAddress", uint, dllcall("GetModuleHandleW", str, "peixoto.dll")
													 , astr, "copyData2Surface")	
		desc := ddSurfaceDesc.clone()
		desc.dwSize := desc.size()
	}
			
	file := FileOpen(file_, "r")
	VarSetCapacity(data, file.Length)
	file.RawRead(data, file.Length)
	file.close()	
	
	dllcall("RtlMoveMemory", ptr, DDS_HEADER[], ptr, &data + 4, int, DDS_HEADER.size())	
	pixelformat := getFilePixelFormat(DDS_HEADER)	
	bytesperpixel := 2
	if (pixelformat = "ARGB")
		bytesperpixel += 2
			
	zeromem(desc)
	desc.dwSize := DDSURFACEDESC.size()
	desc.dwFlags := DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT| DDSD_PIXELFORMAT 
	desc.dwWidth := DDS_HEADER.dwWidth 
	desc.dwHeight := DDS_HEADER.dwHeight		
	desc.ddsCaps.dwCaps := DDSCAPS_VIDEOMEMORY | DDSCAPS_3DDEVICE | DDSCAPS_TEXTURE		
	if ! instr(pixelformat, "A")	{
		desc.dwFlags |= DDSD_CKSRCBLT 
		desc.ddckCKSrcBlt.dwColorSpaceLowValue := colorkey[pixelformat]
		desc.ddckCKSrcBlt.dwColorSpaceHighValue := colorkey[pixelformat]
	}
	DDPIXELFORMAT[] := desc.GetAddress("ddpfPixelFormat")
	setPixelFormat(pixelformat)		
	
	r := dllcall(IDirectDraw2.CreateSurface, uint, pInterface, uint, desc[]
										  , "ptr*", pSurface, uint, 0, uint)
	printl("Texture Load Surface: "	r " " ddraw.result[r . ""])							  
	zeromem(desc)
	r := dllcall(IDirectDrawSurface2.Lock, uint, pSurface, uint, 0, uint, desc[], uint, DDLOCK_WRITEONLY, uint, 0, uint)
	printl("Texture Load Lock: " r " " ddraw.result[r . ""])
		
	pitch := desc.lpitch
	pSurfdata := desc.lpSurface
	hLines := DDS_HEADER.dwHeight	
		
	dllcall(pcopyData2Surface, uint, pSurfdata, uint, &data + 4 + DDS_HEADER.size(), uint, pitch
	                         , uint, hLines, uint, desc.dwWidth, uint, bytesperpixel) 
									
	r := dllcall(IDirectDrawSurface2.UnLock, uint, pSurface, uint)
	printl("Texture Load UnLock: " r " " ddraw.result[r . ""])
		
	GUID_FromString(idd_texture, d3d.IID_IDirect3DTexture)
	r := dllcall(IDirectDrawSurface2.QueryInterface, uint, pSurface
				, ptr, &idd_texture, "ptr*", pTexture, uint)
	printl("Texture Load Texture: " r " " ddraw.result[r . ""])
	
	s := dllcall(IDirect3DTexture.GetHandle, uint, pTexture, uint, pDevice, "uint*", hText, uint)
	printl("Texture hwnd: "	s " " ddraw.result[s . ""] errorlevel " " vv.rTexture " " g_textSwap.device " " hText)				
				
	ret.rSurface := pSurface	
	ret.rTexture :=	pTexture	
	ret.hwnd := hText	
}	

LoadTexture2(pInterface, pDevice, file_, byref ret, colorkey = "")
{
	critical	
	colorkey ?: colorkey := {"RGB" : 0x07e0, "XRGB" : 0}
	static pcopyData2Surface, desc 
	if not pcopyData2Surface
	{
		pcopyData2Surface := dllcall("GetProcAddress", uint, dllcall("GetModuleHandleW", str, "peixoto.dll", uint)
													 , astr, "copyData2Surface", uint)	
		desc := ddSurfaceDesc.clone()
		desc.dwSize := desc.size()
	}
			
	file := FileOpen(file_, "r")
	VarSetCapacity(data, file.Length)
	file.RawRead(data, file.Length)
	file.close()

	if not isobject(file)
		return
	
	dllcall("RtlMoveMemory", ptr, DDS_HEADER[], ptr, &data + 4, int, DDS_HEADER.size())
	pixelformat := getFilePixelFormat(DDS_HEADER)
	printl("file: " file_ " pixelformat " pixelformat)
	bytesperpixel := pixelformat = "ARGB" ? 4 : 2
					
	zeromem(desc)
	desc.dwSize := DDSURFACEDESC.size()
	desc.dwFlags := DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT | DDSD_PIXELFORMAT 
	desc.dwWidth := DDS_HEADER.dwWidth 
	desc.dwHeight := DDS_HEADER.dwHeight		
	desc.ddsCaps.dwCaps := DDSCAPS_VIDEOMEMORY | DDSCAPS_3DDEVICE | DDSCAPS_TEXTURE	
	if ! instr(pixelformat, "A")	{
		desc.dwFlags |= DDSD_CKSRCBLT 
		desc.ddckCKSrcBlt.dwColorSpaceLowValue := colorkey[pixelformat]
		desc.ddckCKSrcBlt.dwColorSpaceHighValue := colorkey[pixelformat]
	}
	DDPIXELFORMAT[] := desc.GetAddress("ddpfPixelFormat")
	setPixelFormat(pixelformat)		
	
	r := dllcall(IDirectDraw.CreateSurface, uint, pInterface, uint, desc[]
										  , "ptr*", pSurface, uint, 0, uint)
	printl("Texture Load Surface: "	r " " ddraw.result[r . ""])							  
	zeromem(desc)
	r := dllcall(IDirectDrawSurface.Lock, uint, pSurface, uint, 0, uint, desc[], uint, DDLOCK_WRITEONLY, uint, 0, uint)
	printl("Texture Load Lock: " r " " ddraw.result[r . ""])
		
	pitch := desc.lpitch
	pSurfdata := desc.lpSurface
	hLines := DDS_HEADER.dwHeight		
							 
	DllCall("QueryPerformanceFrequency", "Int64*", freq)			
	DllCall("QueryPerformanceCounter", "Int64*", timebefore)
					
	dllcall(pcopyData2Surface, uint, pSurfdata, uint, &data + 4 + DDS_HEADER.size(), uint, pitch
	                         , uint, hLines, uint, desc.dwWidth, uint, bytesperpixel)
		
	;pData := &data + 4 + DDS_HEADER.size()
	;Loop, % desc.dwHeight
		;dllcall("RtlMoveMemory", ptr, pSurfdata + pitch * (A_index - 1), ptr, pData + desc.dwWidth * bytesperpixel * (A_index - 1)
		;, int, desc.dwWidth * bytesperpixel)
		
	DllCall("QueryPerformanceCounter", "Int64*", timenow)	
	printl("Texture data copy took " (timenow - timebefore)/freq*1000)	
									
	r := dllcall(IDirectDrawSurface.UnLock, uint, pSurface, uint)
	printl("Texture Load UnLock: " r " " ddraw.result[r . ""])	
		
	VarSetCapacity(pTexture, 4)	
	GUID_FromString(idd_texture, d3d.IID_IDirect3DTexture2)
	r := dllcall(IDirectDrawSurface.QueryInterface, uint, pSurface
				, ptr, &idd_texture, "ptr*", pTexture, uint)
	printl("Texture Load Texture: " r " " ddraw.result[r . ""])
	
	if not isobject(IDirect3DDevice3) {
	s := dllcall(IDirect3DTexture2.GetHandle, uint, pTexture, uint, pDevice, "uint*", hText, uint)
	printl("Texture hwnd: "	s " " ddraw.result[s . ""] errorlevel " " vv.rTexture " " g_textSwap.device " " hText)	
	}	
				
	ret.rSurface := pSurface	
	ret.rTexture :=	pTexture
	ret.rHwnd := hText
	ret.hwnd := hText
}

LoadSurface7(pInterface, file_)
{
	critical	
	colorkey ?: colorkey := {"RGB" : 0x07e0, "XRGB" : 0}
	static pcopyData2Surface, desc 
	if not pcopyData2Surface
	{
		pcopyData2Surface := dllcall("GetProcAddress", uint, dllcall("GetModuleHandleW", str, "peixoto.dll", uint)
													 , astr, "copyData2Surface", uint)	
		desc := ddSurfaceDesc2.clone()
		desc.dwSize := desc.size()
	}
			
	file := FileOpen(file_, "r")
	VarSetCapacity(data, file.Length)
	file.RawRead(data, file.Length)
	file.close()

	if not isobject(file)
		return
	
	dllcall("RtlMoveMemory", ptr, DDS_HEADER[], ptr, &data + 4, int, DDS_HEADER.size())
	pixelformat := getFilePixelFormat(DDS_HEADER)
	printl("file: " file_ " pixelformat " pixelformat)
	bytesperpixel := pixelformat = "ARGB" ? 4 : 2
					
	zeromem(desc)
	desc.dwSize := DDSURFACEDESC2.size()
	desc.dwFlags := DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT | DDSD_PIXELFORMAT 
	desc.dwWidth := DDS_HEADER.dwWidth 
	desc.dwHeight := DDS_HEADER.dwHeight		
	desc.ddsCaps.dwCaps := DDSCAPS_VIDEOMEMORY | DDSCAPS_3DDEVICE | DDSCAPS_TEXTURE	
	if ! instr(pixelformat, "A")	{
		desc.dwFlags |= DDSD_CKSRCBLT 
		desc.ddckCKSrcBlt.dwColorSpaceLowValue := colorkey[pixelformat]
		desc.ddckCKSrcBlt.dwColorSpaceHighValue := colorkey[pixelformat]
	}
	DDPIXELFORMAT[] := desc.GetAddress("ddpfPixelFormat")
	setPixelFormat(pixelformat)		
	
	r := dllcall(IDirectDraw7.CreateSurface, uint, pInterface, uint, desc[]
										   , "ptr*", pSurface, uint, 0, uint)
	printl("Texture Load Surface: "	r " " ddraw.result[r . ""])
    printl("vtable " numget(pSurface+0, "ptr"))	
	zeromem(desc)
	r := dllcall(IDirectDrawSurface7.Lock, uint, pSurface, uint, 0, uint, desc[], uint, DDLOCK_WRITEONLY, uint, 0, uint)
	printl("Texture Load Lock: " r " " ddraw.result[r . ""])		
		
	pitch := desc.lpitch
	pSurfdata := desc.lpSurface
	hLines := DDS_HEADER.dwHeight		
							 
	DllCall("QueryPerformanceFrequency", "Int64*", freq)			
	DllCall("QueryPerformanceCounter", "Int64*", timebefore)
					
	dllcall(pcopyData2Surface, uint, pSurfdata, uint, &data + 4 + DDS_HEADER.size(), uint, pitch
	                         , uint, hLines, uint, desc.dwWidth, uint, bytesperpixel)
	
	r := dllcall(IDirectDrawSurface7.UnLock, uint, pSurface, uint)
	printl("Texture Load UnLock: " r " " ddraw.result[r . ""])	
	return pSurface
}

dumpSurface(pSurface, dest)
{
	Zeromem(ddSurfaceDesc)	
	ddSurfaceDesc.dwSize := DDSURFACEDESC.size()
	r := dllcall(IDirectDrawSurface.Lock, uint, pSurface, uint, 0, uint, ddSurfaceDesc[], uint, DDLOCK_READONLY, uint, 0, uint)
	print("Dump Lock" r  ddraw.result[r . ""] "`n")
	
	pixelformat := getPixelFormat(ddSurfaceDesc)
	if g_textSwap.no16bitAlpha and pixelformat = "ARGB16"
		pixelformat := "XRGB"
		
	if (pixelformat = "ARGB")
		bytesperpixel := 4
	else if (pixelformat = "RGB")
		bytesperpixel := 2	
	else if (pixelformat = "XRGB")
		bytesperpixel := 2	
	else if (pixelformat = "ARGB16")
		bytesperpixel := 2		
	
	Zeromem(DDS_HEADER)	
	DDS_HEADER.dwSize := DDS_HEADER.size()
	DDS_HEADER.dwFlags := DDSD_HEIGHT | DDSD_WIDTH |  DDSD_PIXELFORMAT | DDSD_CAPS
	;DDS_HEADER.dwFlags := 0x0000100F ;fix for paint.net
	
	DDS_HEADER.dwWidth := DDSURFACEDESC.dwWidth
	DDS_HEADER.dwHeight := DDSURFACEDESC.dwHeight
	DDS_HEADER.dwPitchOrLinearSize := DDSURFACEDESC.dwWidth * bytesperpixel
	
	DDS_HEADER.dwCaps := DDSCAPS_TEXTURE
	DDS_PIXELFORMAT[] := DDS_HEADER.GetAddress("ddspf")
	setFilePixelFormat(pixelformat)	
		
	printl(ddSurfaceDesc.ddpfPixelFormat.dwRGBBitCount " bits")
	format := A_FormatInteger
	setformat, integer, hex
	printl("alpha :" ddSurfaceDesc.ddpfPixelFormat.dwRGBAlphaBitMask)
	printl("red   :" ddSurfaceDesc.ddpfPixelFormat.dwRBitMask)
	printl("green :" ddSurfaceDesc.ddpfPixelFormat.dwGBitMask)
	printl("blue  :" ddSurfaceDesc.ddpfPixelFormat.dwBBitMask)
	setformat, integer, %format%
	
	file := FileOpen(dest, "w")
	
	VarSetCapacity(ddssig, 4)
	for k, v in [0x44, 0x44, 0x53, 0x20]		
		numput(v, &ddssig+A_index-1, "char")
	
	file.RawWrite(&ddssig, 4)
	file.RawWrite(DDS_HEADER[]+0, DDS_HEADER.size())
		
	hlines := DDSURFACEDESC.dwHeight		
	print(hlines " " DDSURFACEDESC.size() "`n")
	loop, %hLines%
		file.RawWrite(DDSURFACEDESC.lpSurface + (DDSURFACEDESC.lPitch * (A_index - 1))
					 , DDSURFACEDESC.dwWidth * bytesperpixel)	
	file.close()	
	
	r := dllcall(IDirectDrawSurface.UnLock, uint, pSurface, uint)
	print("Dump UnLock" r  ddraw.result[r . ""] "`n")
}

dumpSurface2(pSurface, dest)
{
	Zeromem(ddSurfaceDesc)	
	ddSurfaceDesc.dwSize := DDSURFACEDESC.size()
	r := dllcall(IDirectDrawSurface2.Lock, uint, pSurface, uint, 0, uint, ddSurfaceDesc[], uint, DDLOCK_READONLY, uint, 0, uint)
	print("Dump Lock" r  ddraw.result[r . ""] "`n")
	
	pixelformat := getPixelFormat(ddSurfaceDesc)	
	
	if (pixelformat = "ARGB")
		bytesperpixel := 4
	else if (pixelformat = "RGB")
		bytesperpixel := 2	
	else if (pixelformat = "XRGB")
		bytesperpixel := 2	
	else if (pixelformat = "ARGB16")
		bytesperpixel := 2		
	
	Zeromem(DDS_HEADER)	
	DDS_HEADER.dwSize := DDS_HEADER.size()
	DDS_HEADER.dwFlags := DDSD_HEIGHT | DDSD_WIDTH |  DDSD_PIXELFORMAT | DDSD_CAPS
	;DDS_HEADER.dwFlags := 0x0000100F ;fix for paint.net
	
	DDS_HEADER.dwWidth := DDSURFACEDESC.dwWidth
	DDS_HEADER.dwHeight := DDSURFACEDESC.dwHeight
	DDS_HEADER.dwPitchOrLinearSize := DDSURFACEDESC.dwWidth * bytesperpixel
	
	DDS_HEADER.dwCaps := DDSCAPS_TEXTURE
	DDS_PIXELFORMAT[] := DDS_HEADER.GetAddress("ddspf")
	setFilePixelFormat(pixelformat)
	
	file := FileOpen(dest, "w")
	
	VarSetCapacity(ddssig, 4)
	for k, v in [0x44, 0x44, 0x53, 0x20]		
		numput(v, &ddssig+A_index-1, "char")
	
	file.RawWrite(&ddssig, 4)
	file.RawWrite(DDS_HEADER[]+0, DDS_HEADER.size())
		
	hlines := DDSURFACEDESC.dwHeight		
	print(hlines " " DDSURFACEDESC.size() "`n")
	loop, %hLines%
		file.RawWrite(DDSURFACEDESC.lpSurface + (DDSURFACEDESC.lPitch * (A_index - 1))
					 , DDSURFACEDESC.dwWidth * bytesperpixel)	
	file.close()	
	
	r := dllcall(IDirectDrawSurface2.UnLock, uint, pSurface, uint)
	print("Dump UnLock" r  ddraw.result[r . ""] "`n")
}

writeOnSurface(pSuf, txt, clr = 0x00000000, x = 0, y = 0)
{	
	static coords
	if not coords
		coords := rect.clone()
		
	interface := isobject(IDirectDrawSurface7) ? IDirectDrawSurface7 : isobject(IDirectDrawSurface2) ? IDirectDrawSurface2 : IDirectDrawSurface
	dllcall(interface.GetDC, uint, pSuf, "uint*", h_DC, uint)	
	
	HORZRES := 8, VERTRES := 10	
	w := dllcall("GetDeviceCaps", uint, h_DC, uint, HORZRES, int)
	h := dllcall("GetDeviceCaps", uint, h_DC, uint, VERTRES, int)
	
	coords.left := x
	coords.top := y
	coords.right := w 
	coords.bottom := h 	
	
	dllcall("Gdi32.dll\SetBkMode", uint, h_DC, uint, 1)
	dllcall("Gdi32.dll\SetTextColor", uint, h_DC, uint, clr)

	r :=  dllcall("DrawTextW"
	, uint, h_DC
	, str, txt
	, int, -1
	, uint, coords[]
	, uint, 0) 	
	
	dllcall(interface.ReleaseDC, uint, pSuf, uint, h_DC, uint)
	return r	
}

DirectDrawCreate(software = False)
{
	h_ddrawdll := dllcall("LoadLibrary", str, "ddraw.dll")
	pdirectdrawcreate := dllcall("GetProcAddress", int, h_ddrawdll, astr, "DirectDrawCreate")
	if not h_ddrawdll or not pdirectdrawcreate
		return -1	
	
	VarSetCapacity(pdraw, 4)
	if not software
		r := dllcall(pdirectdrawcreate, uint, 0, ptr, &pdraw, int, 0, uint) 	
	else r:= dllcall(pdirectdrawcreate, uint, DDCREATE_EMULATIONONLY, ptr, &pdraw, int, 0, uint)  
	if not r
		IDirectDraw := new ComInterfaceWrapper(ddraw.IDirectDraw, &pdraw)
	
	return r
}	

getDirectDraw(h_win = "", software=False)
{
	if not h_win
		h_win := A_scripthwnd ;ui_GetHidenWindowHandle()	

	r := DirectDrawCreate(software)
	if (r != 0)
		return "Failed to create the IDirectDraw interface " r " - " ddraw.result[r . ""]	
	
	GUID_FromString(idd_ddraw2, ddraw.IID_IDirectDraw2)
	r := dllcall(IDirectDraw.QueryInterface, uint, IDirectDraw.p, uint, &idd_ddraw2, "uint*", pddraw2, uint)
	if r
		return "Failed to create the IDirectDraw2 Interface " r " - " ddraw.result[r . ""]	
	else IDirectDraw2 := new ComInterfaceWrapper(ddraw.IDirectDraw2, pddraw2, True)
	
	r := dllcall(IDirectDraw.SetCooperativeLevel, ptr, IDirectDraw.p, uint, h_win, int, DDSCL_NORMAL, uint)
	Print("CoopLevel: " r  ":" ddraw.result[r . ""] "`n")
	if r
		return "Failed to set the Cooperatve Level " r " - " ddraw.result[r . ""]		
				
	res := GetDesktopResolution() 
	r := dllcall(IDirectDraw.SetDisplayMode, uint, IDirectDraw.p, uint, res.w, uint, res.h
										   , uint, 32, uint, 0, uint, 0, uint)
	if r
		return "Failed to set the Display mode " r " - " ddraw.result[r . ""]
		
	zeromem(ddSurfaceDesc)
	ddSurfaceDesc.dwSize := DDSURFACEDESC.size()
	ddSurfaceDesc.dwFlags := DDSD_CAPS 
	ddSurfaceDesc.ddsCaps.dwCaps := DDSCAPS_3DDEVICE | DDSCAPS_PRIMARYSURFACE | DDSCAPS_VIDEOMEMORY   
	ddSurfaceDesc.dwWidth := 640
	ddSurfaceDesc.dwHeight := 480
	r := dllcall(IDirectDraw.CreateSurface, uint, IDirectDraw.p, uint, ddSurfaceDesc[]
										  , "ptr*", pPrimary, uint, 0, uint)
										  
	if (ddraw.result[r . ""] = "DDERR_NOEXCLUSIVEMODE")
	{
		ddSurfaceDesc.dwFlags := DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH 
		ddSurfaceDesc.ddsCaps.dwCaps := DDSCAPS_3DDEVICE | DDSCAPS_VIDEOMEMORY 
		r := dllcall(IDirectDraw.CreateSurface, uint, IDirectDraw.p, uint, ddSurfaceDesc[]
										      , "ptr*", pPrimary, uint, 0, uint)
	}		
		
	if r
		return "Failed to create the IDirectDrawSurface Interface " r " - " ddraw.result[r . ""]	
	else IDirectDrawSurface := new ComInterfaceWrapper(ddraw.IDirectDrawSurface, pPrimary, True)		
	
	GUID_FromString(idd_ds2, ddraw.IID_IDirectDrawSurface2)
	r := dllcall(IDirectDrawSurface.QueryInterface, uint, IDirectDrawSurface.p, ptr, &idd_ds2, "uint*", pSurface2, uint)
	Print("Surface2: " 	r  ":" ddraw.result[r . ""] "`n")						
	if r
		return "Failed to create the IDirectDrawSurface2 Interface " r " - " ddraw.result[r . ""]	
	else IDirectDrawSurface2 := new ComInterfaceWrapper(ddraw.IDirectDrawSurface2, pSurface2, True)
			
	return ""
}	

getDirectDraw2(h_win = "", software = False)
{	
	if not h_win
		h_win := A_scripthwnd ;ui_GetHidenWindowHandle()

	r := DirectDrawCreate(software)
	if (r != 0)
		return "Failed to create the IDirectDraw interface " r " - " ddraw.result[r . ""]	
	
	VarSetCapacity(pddraw2, 4)
	GUID_FromString(idd_ddraw2, ddraw.IID_IDirectDraw2)
	r := dllcall(IDirectDraw.QueryInterface, uint, IDirectDraw.p, uint, &idd_ddraw2, uint, &pddraw2, uint)
	if r
		return "Failed to create the IDirectDraw2 Interface " r " - " ddraw.result[r . ""]	
	else IDirectDraw2 := new ComInterfaceWrapper(ddraw.IDirectDraw2, &pddraw2)
		
	r := dllcall(IDirectDraw2.SetCooperativeLevel, uint, IDirectDraw2.p, uint, h_win, uint, DDSCL_NORMAL)
	Print("CoopLevel: " r  ":" ddraw.result[r . ""] " " coop_level " `n")	
	if r
		return "Failed to set the Cooperatve Level " r " - " ddraw.result[r . ""]

	res := GetDesktopResolution() 
	r := dllcall(IDirectDraw2.SetDisplayMode, uint, IDirectDraw2.p, uint, res.w, uint, res.h
												, uint, 32, uint, 0, uint, 0, uint)
	if r
		return "Failed to set the Display mode " r " - " ddraw.result[r . ""]
		
	zeromem(ddSurfaceDesc)
	res := GetDesktopResolution() 	
	ddSurfaceDesc.dwSize := DDSURFACEDESC.size()
	ddSurfaceDesc.dwFlags :=  DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH
	ddSurfaceDesc.ddsCaps.dwCaps := DDSCAPS_3DDEVICE ;| DDSCAPS_PRIMARYSURFACE    
	ddSurfaceDesc.dwWidth := 640
	ddSurfaceDesc.dwHeight := 480	
			
	r := dllcall(IDirectDraw2.CreateSurface, uint, IDirectDraw2.p, uint, ddSurfaceDesc[]
										   , "ptr*", pPrimary, uint, 0, uint)										   
											   
	Print("Surface2: " r  ":" ddraw.result[r . ""] "`n")		
	if r
		return "Failed to create the IDirectDrawSurface2 Interface " r " - " ddraw.result[r . ""]	
	else IDirectDrawSurface2 := new ComInterfaceWrapper(ddraw.IDirectDrawSurface2, pPrimary, True)		
	
	GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface)
	r := dllcall(IDirectDrawSurface2.QueryInterface, uint, IDirectDrawSurface2.p, uint, &idd_surface, "uint*", pSurface, uint)
	if r
		return "Failed to create the IDirectDrawSurface Interface " r " - " ddraw.result[r . ""]
	IDirectDrawSurface := new ComInterfaceWrapper(ddraw.IDirectDrawSurface, pSurface, True)
	
	/*	
	VarSetCapacity(pOffsccreenSurface3, 4)
	GUID_FromString(idd_ds3, ddraw.IID_IDirectDrawSurface3)
	r := dllcall(IDirectDrawSurface2.QueryInterface, uint, IDirectDrawSurface2.p
				, ptr, &idd_ds3, uint, &pOffsccreenSurface3, uint)
	Print("Surface3: " 	r  ":" ddraw.result[r . ""] "`n")						
	if r
		return "Failed to create the IDirectDrawSurface3 Interface " r " - " ddraw.result[r . ""]	
	else IDirectDrawSurface3 := new ComInterfaceWrapper(ddraw.IDirectDrawSurface3, &pOffsccreenSurface3)
	*/	
	
	return ""
}	

getDirectDraw4(h_win = "", software=False)
{
	if not h_win
		h_win := A_scripthwnd ;ui_GetHidenWindowHandle()

	r := DirectDrawCreate(software)
	if (r != 0)
		return "Failed to create the IDirectDraw interface " r " - " ddraw.result[r . ""]
	
	GUID_FromString(idd_ddraw2, ddraw.IID_IDirectDraw2)
	r := dllcall(IDirectDraw.QueryInterface, uint, IDirectDraw.p, uint, &idd_ddraw2, "uint*", pddraw2, uint)
	if r
		return "Failed to create the IDirectDraw2 Interface " r " - " ddraw.result[r . ""]	
	else IDirectDraw2 := new ComInterfaceWrapper(ddraw.IDirectDraw2, pddraw2, True)
	
	VarSetCapacity(pddraw4, 4)
	GUID_FromString(idd_ddraw4, ddraw.IID_IDirectDraw4)
	r := dllcall(IDirectDraw.QueryInterface, uint, IDirectDraw.p, uint, &idd_ddraw4, uint, &pddraw4, uint)
	if r
		return "Failed to create the IDirectDraw4 Interface " r " - " ddraw.result[r . ""]	
	else IDirectDraw4 := new ComInterfaceWrapper(ddraw.IDirectDraw4, &pddraw4)
	
	r := dllcall(IDirectDraw4.SetCooperativeLevel, ptr, IDirectDraw4.p, uint, h_win, int, DDSCL_NORMAL, uint)
	Print("CoopLevel: " r  ":" ddraw.result[r . ""] "`n")
	if r
		return "Failed to set the Cooperatve Level " r " - " ddraw.result[r . ""]		
				
	res := GetDesktopResolution() 
	r := dllcall(IDirectDraw4.SetDisplayMode, uint, IDirectDraw4.p, uint, res.w, uint, res.h
										   , uint, 32, uint, 0, uint, 0, uint)
	if r
		return "Failed to set the Display mode " r " - " ddraw.result[r . ""]
		
	zeromem(ddSurfaceDesc2)
	ddSurfaceDesc2.dwSize := DDSURFACEDESC2.size()
	ddSurfaceDesc2.dwFlags := DDSD_CAPS 
	ddSurfaceDesc2.ddsCaps.dwCaps := DDSCAPS_3DDEVICE | DDSCAPS_PRIMARYSURFACE    
	ddSurfaceDesc2.dwWidth := 640
	ddSurfaceDesc2.dwHeight := 480
	r := dllcall(IDirectDraw4.CreateSurface, uint, IDirectDraw4.p, uint, ddSurfaceDesc2[]
										   , "ptr*", pPrimary, uint, 0, uint)
										  
	if (ddraw.result[r . ""] = "DDERR_NOEXCLUSIVEMODE")
	{
		ddSurfaceDesc2.dwFlags := DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH 
		ddSurfaceDesc2.ddsCaps.dwCaps := DDSCAPS_3DDEVICE 
		r := dllcall(IDirectDraw4.CreateSurface, uint, IDirectDraw4.p, uint, ddSurfaceDesc2[]
										      , "ptr*", pPrimary, uint, 0, uint)
	}		
	Print("Surface4: " r  ":" ddraw.result[r . ""] "`n")	
	if r
		return "Failed to create the IDirectDrawSurface4 Interface " r " - " ddraw.result[r . ""]	
	else IDirectDrawSurface4 := new ComInterfaceWrapper(ddraw.IDirectDrawSurface4, pPrimary, True)
		
	GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface)
	r := dllcall(IDirectDrawSurface4.QueryInterface, uint, IDirectDrawSurface4.p, uint, &idd_surface, "uint*", pSurface, uint)
	if r
		return "Failed to create the IDirectDrawSurface Interface " r " - " ddraw.result[r . ""]	
	IDirectDrawSurface := new ComInterfaceWrapper(ddraw.IDirectDrawSurface, pSurface, True)
	
	GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface2)
	r := dllcall(IDirectDrawSurface4.QueryInterface, uint, IDirectDrawSurface4.p, uint, &idd_surface, "uint*", pSurface, uint)
	if r
		return "Failed to create the IDirectDrawSurface2 Interface " r " - " ddraw.result[r . ""]	
	IDirectDrawSurface2 := new ComInterfaceWrapper(ddraw.IDirectDrawSurface2, pSurface, True)
	
	GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface3)
	r := dllcall(IDirectDrawSurface4.QueryInterface, uint, IDirectDrawSurface4.p, uint, &idd_surface, "uint*", pSurface, uint)
	if r
		return "Failed to create the IDirectDrawSurface3 Interface " r " - " ddraw.result[r . ""]	
	IDirectDrawSurface3 := new ComInterfaceWrapper(ddraw.IDirectDrawSurface3, pSurface, True)
	
	r := dllcall(IDirectDraw.CreateClipper, uint, IDirectDraw.p, uint, 0, "uint*", pClipper, uint, 0, uint)
	if r
		return "Failed to create the IDirectDrawCliper Interface " r " - " ddraw.result[r . ""]	
	IDirectDrawCliper := new ComInterfaceWrapper(ddraw.IDirectDrawClipper, pClipper, True)
		
	return ""
}	