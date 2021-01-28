#include <DirectX\ddraw>
;#include <GUI>
;#include <GDI>

/*
Surface3: Directshow
DirectX3 - DirectDraw2, Surface2, Direct3D, 3DDevice, ExecuteBuffer, Viewport, Texture, Material, Direct3DLight
DirectX5 - DirectDraw2, Surface2, Direct3D2, 3DDevice2, Excutebuffer??, Viewport2, Texture2, Material2, Lights?
DirectX6 - DirectDraw4, Surface4, Direct3D3, 3DDevice3, VertexBuffer, Viewport3, Texture2??, Material3, Lights?
*/

global IDirect3D, IDirect3DDevice, IDirect3DExecuteBuffer, IDirect3DViewPort, IDirect3DTexture                            
global IDirect3D2, IDirect3DDevice2, IDirect3DViewPort2, IDirect3DTexture2       													    	
global IDirect3D3, IDirect3DDevice3, IDirect3DViewPort3, IDirect3DVertexBuffer	

global IDirectDraw7, IDirectDrawSurface7
global IDirect3D7, IDirect3dDevice7, IDirect3DVertexBuffer7

releaseDirect3D()
{
	IDirect3DExecuteBuffer.__release()
	IDirect3DTexture.__release()
	IDirect3DViewPort.__release()
	IDirect3D.__release()	
	;IDirectDrawSurface3.__release()
	IDirectDrawSurface2.__release()
	IDirectDrawSurface.__release()
	IDirectDraw2.__release()
	IDirectDraw.__release()
}	

getDirect3D(h_win = "", device = "RGB Emulation", software = False)
{
	if not h_win
		h_win := A_scripthwnd ;ui_GetHidenWindowHandle()
	
	err := getDirectDraw2(h_win, software)
	if err
		return err
	
	VarSetCapacity(pd3d, 4)
	GUID_FromString(idd_d3d, d3d.IID_IDirect3D)
	r := dllcall(IDirectDraw2.QueryInterface, uint, IDirectDraw2.p, uint, &idd_d3d, uint, &pd3d, uint)
	print("Direct3d: " r ":" ddraw.result[r . ""] "`n")
	if r
		return "Failed to create the IDirect3D Interface " r " - " ddraw.result[r . ""]	
	else IDirect3D := new ComInterfaceWrapper(d3d.IDirect3d, &pd3d)
			
	VarSetCapacity(pViewPort, 4)
	GUID_FromString(idd_ViewPort, d3d.IID_IDirect3DViewport)
	r := dllcall(IDirect3D.CreateViewport, uint, IDirect3D.p, uint, &pViewPort, uint, 0, uint)
	Print("ViewPort: " r  ":" ddraw.result[r . ""] "`n")
	if r
		return "Failed to create the IDirect3DViewPort Interface " r " - " d3D.result[r . ""]	
	else IDirect3DViewPort := new ComInterfaceWrapper(d3d.IDirect3DViewPort, &pViewPort)			
				
	VarSetCapacity(pTexture, 4)
	GUID_FromString(idd_texture, d3d.IID_IDirect3DTexture)
	r := dllcall(IDirectDrawSurface2.QueryInterface, uint, IDirectDrawSurface2.p
				, ptr, &idd_texture, uint, &pTexture, uint)
	Print("Texture: " 	r  ":" ddraw.result[r . ""] "`n")						
	if r
		return "Failed to create the IDirect3DTexture Interface " r " - " d3D.result[r . ""]	
	else IDirect3DTexture := new ComInterfaceWrapper(d3d.IDirect3DTexture, &pTexture)
		
	enum3DDevices(device)
	if not isobject(IDirect3DDevice)
		return IDirect3DDevice				
		
	VarSetCapacity(pExecBuffer, 4)
	D3DEXECUTEBUFFERDESC.dwSize := D3DEXECUTEBUFFERDESC.size()
	D3DEXECUTEBUFFERDESC.dwFlags := 0x00000001 ;D3DDEB_BUFSIZE 
    D3DEXECUTEBUFFERDESC.dwBufferSize := 16

	r := dllcall(IDirect3DDevice.CreateExecuteBuffer, uint, IDirect3DDevice.p, uint, D3DEXECUTEBUFFERDESC[], uint, &pExecBuffer, uint, 0, uint)
	Print("Exec Buffer: " r  ":" d3d.result[r . ""] "`n")
	if r
		return "Failed to create the IDirect3DExecuteBuffer Interface " r " - " d3D.result[r . ""]	
	else IDirect3DExecuteBuffer :=	 new ComInterfaceWrapper(d3d.IDirect3DExecuteBuffer, &pExecBuffer)	
		
	if (_2ndTry = True)
	{
		r := dllcall(IDirectDraw.SetCooperativeLevel, uint, IDirectDraw.p, uint, h_win, uint, DDSCL_NORMAL)
		Print("CoopLevel: " r  ":" ddraw.result[r . ""] "`n")	
		if r
			return "Failed to set the Cooperatve Level back" r " - " ddraw.result[r . ""]
	}	

	return "Succeeded to create the DirectDraw2 and Direct3d Interfaces" 
}	

getDirect3D2(h_win = "", device = "RGB Emulation", software = False)
{
	bitdepth := {"RGB" : 16, "XRGB" : 16, "ARGB" : 32}
	
	if not h_win
		h_win := A_scripthwnd ;ui_GetHidenWindowHandle()
	
	err := getDirectDraw(h_win, software)
	if err
		return err
	
	GUID_FromString(idd_ddraw4, ddraw.IID_IDirectDraw4)
	r := dllcall(IDirectDraw.QueryInterface, uint, IDirectDraw.p, uint, &idd_ddraw4, "uint*", pddraw4, uint)
	if r
		return "Failed to create the IDirectdraw4 Interface " r " - " ddraw.result[r . ""]		
	else IDirectdraw4 := new ComInterfaceWrapper(ddraw.IDirectDraw4, pddraw4, True)	
		
	GUID_FromString(idd_d3d, d3d.IID_IDirect3D2)
	r := dllcall(IDirectDraw.QueryInterface, uint, IDirectDraw.p, uint, &idd_d3d, "uint*", pd3d, uint)
	print("Direct3d2: " r ":" ddraw.result[r . ""] "`n")
	if r
		return "Failed to create the IDirect3D2 Interface " r " - " ddraw.result[r . ""]		
	else IDirect3D2 := new ComInterfaceWrapper(d3d.IDirect3d2, pd3d, True)
			
	GUID_FromString(idd_ViewPort, d3d.IID_IDirect3DViewport2)
	r := dllcall(IDirect3D2.CreateViewport, uint, IDirect3D2.p, "uint*", pViewPort, uint, 0, uint)
	Print("ViewPort2: " r  ":" d3d.result[r . ""] "`n")
	if r
		return "Failed to create the IDirect3DViewPor2 Interface " r " - " d3D.result[r . ""]		
	else IDirect3DViewPort2 := new ComInterfaceWrapper(d3d.IDirect3DViewPort2, pViewPort, True)	
		
	GUID_FromString(idd_texture, d3d.IID_IDirect3DTexture2)
	r := dllcall(IDirectDrawSurface.QueryInterface, uint, IDirectDrawSurface.p
				, ptr, &idd_texture, "uint*", pTexture, uint)
	Print("Texture2: " 	r  ":" ddraw.result[r . ""] "`n")						
	if r
		return "Failed to create the IDirect3DTexture2 Interface " r " - " d3D.result[r . ""]		
	else IDirect3DTexture2 := new ComInterfaceWrapper(d3d.IDirect3DTexture2, pTexture, True)	
			
	enum3DDevices2(device)
	if not isobject(IDirect3DDevice2)	
		return IDirect3DDevice2			
		
	return "Succeeded to create the DirectDraw and Direct3D2 Interfaces" 
}

getDirect3D3(h_win = "", device = "RGB Emulation", software = False)
{
	if not h_win
		h_win := A_scripthwnd ;ui_GetHidenWindowHandle()
	
	err := getDirectDraw4(h_win, software)
	if err
		return err
	
	GUID_FromString(idd_d3d, d3d.IID_IDirect3D3)
	r := dllcall(IDirectDraw.QueryInterface, uint, IDirectDraw.p, uint, &idd_d3d, "uint*", pd3d, uint)
	print("Direct3D3: " r ":" ddraw.result[r . ""] "`n")
	if r
		return "Failed to create the IDirect3D3 Interface " r " - " ddraw.result[r . ""]		
	else IDirect3D3 := new ComInterfaceWrapper(d3d.IDirect3d3, pd3d, True)
			
	r := dllcall(IDirect3D3.CreateViewport, uint, IDirect3D3.p, "uint*", pViewPort, uint, 0, uint)
	Print("ViewPort3: " r  ":" d3d.result[r . ""] "`n")
	if r
		return "Failed to create the IDirect3DViewPor2 Interface " r " - " d3D.result[r . ""]		
	else IDirect3DViewPort3 := new ComInterfaceWrapper(d3d.IDirect3DViewPort3, pViewPort, True)	
		
	D3DVERTEXBUFFERDESC.dwSize := D3DVERTEXBUFFERDESC.size()
	D3DVERTEXBUFFERDESC.dwFVF := D3DFVF_XYZRHW | D3DFVF_DIFFUSE 
	D3DVERTEXBUFFERDESC.dwNumVertices := 4
	r := dllcall(IDirect3D3.CreateVertexBuffer, uint, IDirect3D3.p, uint, D3DVERTEXBUFFERDESC[], "uint*", pVerTexBuffer
                                              , uint, 0, uint, 0, uint)
	Print("VertexBuffer: " r  ":" d3d.result[r . ""] "`n")										  
	if r
		return "Failed to create the IDirect3DVertexBuffer Interface " r " - " d3D.result[r . ""]		
	else IDirect3DVertexBuffer := new ComInterfaceWrapper(d3d.IDirect3DVertexBuffer, pVerTexBuffer, True)	
		
	GUID_FromString(idd_texture, d3d.IID_IDirect3DTexture2)
	r := dllcall(IDirectDrawSurface.QueryInterface, uint, IDirectDrawSurface.p
				, ptr, &idd_texture, "uint*", pTexture, uint)
	Print("Texture2: " 	r  ":" ddraw.result[r . ""] "`n")						
	if r
		return "Failed to create the IDirect3DTexture2 Interface " r " - " d3D.result[r . ""]		
	else IDirect3DTexture2 := new ComInterfaceWrapper(d3d.IDirect3DTexture2, pTexture, True)	
		
	enum3DDevices3(device)
	if not isobject(IDirect3DDevice3)	
		return IDirect3DDevice3		
		
	return "Succeeded to create the DirectDraw4 and Direct3D3 Interfaces" 
}

getDirect3D7(h_win = "", device = "RGB Emulation")
{
	h_ddrawdll := dllcall("LoadLibrary", str, "ddraw.dll")
	pdirectdrawcreateEx := dllcall("GetProcAddress", int, h_ddrawdll, astr, "DirectDrawCreateEx")
	if not h_ddrawdll or not pdirectdrawcreateEx
		return "failed to load ddraw.dll"	
	
	GUID_FromString(idd_ddraw7, ddraw.IID_IDirectDraw7)
	if (device = "RGB Emulation")
		r := dllcall(pdirectdrawcreateEx, uint, DDCREATE_EMULATIONONLY, "uint*", pddraw7, uint, &idd_ddraw7, int, 0, uint)
	else r := dllcall(pdirectdrawcreateEx, uint, 0, "uint*", pddraw7, uint, &idd_ddraw7, int, 0, uint) 
	printl("Directdraw7 " r ddraw.result[r . ""])
	if not r
		IDirectDraw7 := new ComInterfaceWrapper(ddraw.IDirectDraw7, pddraw7, True)
	else return "Failed to create th IDirectDraw7 interface " r " - " ddraw.result[r . ""]
	
	r := dllcall(IDirectDraw7.SetCooperativeLevel, ptr, IDirectDraw7.p, uint, h_win, int, DDSCL_NORMAL, uint)
	Print("CoopLevel: " r  ":" ddraw.result[r . ""] "`n")
	if r
		return "Failed to set the Cooperatve Level " r " - " ddraw.result[r . ""]		
				
	res := GetDesktopResolution() 
	r := dllcall(IDirectDraw7.SetDisplayMode, uint, IDirectDraw7.p, uint, res.w, uint, res.h
										    , uint, 32, uint, 0, uint, 0, uint)
	if r
		return "Failed to set the Display mode " r " - " ddraw.result[r . ""]
	
	zeromem(ddSurfaceDesc2)
	ddSurfaceDesc2.dwSize := DDSURFACEDESC2.size()
	ddSurfaceDesc2.dwFlags := DDSD_CAPS 
	ddSurfaceDesc2.ddsCaps.dwCaps := DDSCAPS_3DDEVICE | DDSCAPS_PRIMARYSURFACE    
	ddSurfaceDesc2.dwWidth := 640
	ddSurfaceDesc2.dwHeight := 480
	r := dllcall(IDirectDraw7.CreateSurface, uint, IDirectDraw7.p, uint, ddSurfaceDesc2[]
										   , "ptr*", pPrimary, uint, 0, uint)
									  
	if (ddraw.result[r . ""] = "DDERR_NOEXCLUSIVEMODE")
	{
		ddSurfaceDesc2.dwFlags := DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH 
		ddSurfaceDesc2.ddsCaps.dwCaps := DDSCAPS_3DDEVICE 
		r := dllcall(IDirectDraw7.CreateSurface, uint, IDirectDraw7.p, uint, ddSurfaceDesc2[]
										       , "ptr*", pPrimary, uint, 0, uint)
	}		
	print("Primary7: " r  ":" ddraw.result[r . ""] "`n")		
	if r
		return "Failed to create the IDirectDrawSurface7 Interface " r " - " ddraw.result[r . ""]	
	else IDirectDrawSurface7 := new ComInterfaceWrapper(ddraw.IDirectDrawSurface7, pPrimary, True)
		
	GUID_FromString(idd_surf, ddraw.IID_IDirectDrawSurface)
	r := dllcall(IDirectDrawSurface7.QueryInterface, uint, IDirectDrawSurface7.p, uint, &idd_surf, "uint*", pSurface)
	print("Surface: " r  ":" ddraw.result[r . ""] "`n")	
	if r
		return "Failed to create the IDirectDrawSurface Interface " r " - " ddraw.result[r . ""]	
	else IDirectDrawSurface := new ComInterfaceWrapper(ddraw.IDirectDrawSurface, pSurface, True)
	
	GUID_FromString(idd_d3D7, d3d.IID_IDirect3D7)
	r := dllcall(IDirectDraw7.QueryInterface, uint, IDirectDraw7.p, uint, &idd_d3D7, "uint*", pd3D7, uint)
	print("d3D7: " r  ":" ddraw.result[r . ""] "`n")
	if r
		return "Failed to create the IDirect3D7 Interface " r " - " ddraw.result[r . ""]	
	else IDirect3D7 := new ComInterfaceWrapper(d3D.IDirect3D7, pd3D7, True)	
		
	D3DVERTEXBUFFERDESC.dwSize := D3DVERTEXBUFFERDESC.size()
	D3DVERTEXBUFFERDESC.dwFVF := D3DFVF_XYZRHW | D3DFVF_DIFFUSE 
	D3DVERTEXBUFFERDESC.dwNumVertices := 4
	r := dllcall(IDirect3D7.CreateVertexBuffer, uint, IDirect3D7.p, uint, D3DVERTEXBUFFERDESC[], "uint*", pVerTexBuffer, uint, 0, uint)
	Print("VertexBuffer7: " r  ":" d3d.result[r . ""] "`n")										  
	if r
		return "Failed to create the IDirect3DVertexBuffer7 Interface " r " - " d3D.result[r . ""]		
	else IDirect3DVertexBuffer7 := new ComInterfaceWrapper(d3d.IDirect3DVertexBuffer7, pVerTexBuffer, True)	
		
	devices := 	{"RGB Emulation" : d3d.IID_IDirect3DRGBDevice, "Direct3D HAL" :  d3d.IID_IDirect3DHALDevice
	            , "Direct3D T&L HAL" : d3d.IID_IDirect3DTnLHalDevice }
	GUID_FromString(idd_device7, devices[device])	
    r := dllcall(IDirect3D7.CreateDevice, uint, IDirect3D7.p,  uint, &idd_device7, uint, pPrimary, "uint*", pd3Ddevice7, uint)
	print("d3DDevice7: " r  ":" ddraw.result[r . ""] "`n")	
	if r
		return "Failed to create the IDirect3DDevice7 Interface " r " - " ddraw.result[r . ""]	
	else IDirect3DDevice7 := new ComInterfaceWrapper(d3d.IDirect3DDevice7, pd3Ddevice7, True)
		
	return "Succeeded to create the DirectDraw7 and Direct3D7 Interfaces" 
}	

enum3DDevices(device)
{
	print("Enumerating devices:`n")
	dllcall(IDirect3D.EnumDevices, uint, IDirect3D.p, uint
								 , registercallback("enum3DDevicesCallback", "F"), str, device)									 
}	

enum3DDevicesCallback(lpGuid, pDeviceDescription, lpDeviceName, lpD3DHWDeviceDesc, lpD3DHELDeviceDesc, lpUserArg)	
{	
	print( StringFromIID(lpGuid) ":" strget(lpDeviceName, "UTF-8") "`n" )
	if (strget(lpDeviceName, "UTF-8") = strget(lpUserArg, "UTF-16"))
	{
		
		IDirectDrawSurface.__release()	
		IDirectDrawSurface2.__release()			
		
		GUID_FromString(idd_d3DDevice, StringFromIID(lpGuid))		
		;res := GetDesktopResolution() 			
		ddSurfaceDesc.dwFlags := DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH 
		ddSurfaceDesc.ddsCaps.dwCaps := DDSCAPS_3DDEVICE | DDSCAPS_VIDEOMEMORY  ; DDSCAPS_3DDEVICE | DDSCAPS_BACKBUFFER  
		ddSurfaceDesc.dwWidth := 640
		ddSurfaceDesc.dwHeight := 480			
		r := dllcall(IDirectDraw2.CreateSurface, uint, IDirectDraw2.p, uint, ddSurfaceDesc[]
										             , "ptr*", pBackBuffer, uint, 0, uint)												  
		if r
		{
			IDirect3DDevice :=  "Failed to create the IDirectDrawSurface Backbufffer Surface " r " - " ddraw.result[r . ""]
			return		
		}	
		else IDirectDrawSurface2.p := pBackBuffer
			
		GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface)
		r := dllcall(IDirectDrawSurface2.QueryInterface, uint, pBackBuffer, uint, &idd_surface, "uint*", pSurface, uint)
		if r
		{
			IDirect3DDevice :=  "Failed to create the IDirectDrawSurface Backbufffer Surface " r " - " ddraw.result[r . ""]
			return		
		}	
		IDirectDrawSurface.p := pSurface
		
		r := dllcall(IDirectDrawSurface2.QueryInterface, uint, pBackBuffer, uint, &idd_d3DDevice, "uint*", pd3DDevice, uint)			
		Print("Device: " r  ":" ddraw.result[r . ""] "`n")
		if r
			IDirect3DDevice := "Failed to create the IDirect3DDevice Interface " r " - " d3D.result[r . ""]		
		else IDirect3DDevice := new ComInterfaceWrapper(d3d.IDirect3DDevice, pd3DDevice, True)
			
		return false
	}
	return True	
}

enum3DDevices2(device)
{
	print("Enumerating devices:`n")
	dllcall(IDirect3D2.EnumDevices, uint, IDirect3D2.p, uint
							      , registercallback("enum3DDevicesCallback2", "F"), str, device)								 
}	

enum3DDevicesCallback2(lpGuid, pDeviceDescription, lpDeviceName, lpD3DHWDeviceDesc, lpD3DHELDeviceDesc, lpUserArg)	
{	
	print( StringFromIID(lpGuid) ":" strget(lpDeviceName, "UTF-8") "`n" )
	if (strget(lpDeviceName, "UTF-8") = strget(lpUserArg, "UTF-16"))
	{
		GUID_FromString(idd_d3DDevice, StringFromIID(lpGuid))
		
		r := dllcall(IDirect3D2.Createdevice,uint, IDirect3D2.p, uint, &idd_d3DDevice,  uint, IDirectDrawSurface.p,  "uint*", pd3DDevice, uint)
		Print("IDirect3DDevice2: " r  ":" ddraw.result[r . ""] "`n")
		if r
			IDirect3DDevice2 := "Failed to create the IDirect3DDevice2 Interface " r " - " d3D.result[r . ""]	
		else IDirect3DDevice2 := new ComInterfaceWrapper(d3d.IDirect3DDevice2, pd3DDevice, True)
		
		/*		
		r := dllcall(IDirectDrawSurface.QueryInterface, uint, IDirectDrawSurface.p, uint, &idd_d3DDevice, "ptr*", pd3DDevice, uint)			
		printl("IDirect3DDevice: " r  ":" d3d.result[r . ""])
		if r
			IDirect3DDevice2 := "Failed to create the IDirect3DDevice Interface " r " - " d3D.result[r . ""]	
		else IDirect3DDevice := new ComInterfaceWrapper(d3d.IDirect3DDevice, pd3DDevice, True)	
		*/		
			
		return false
	}
	return True
}	

enum3DDevices3(device)
{
	print("Enumerating devices:`n")
	dllcall(IDirect3D3.EnumDevices, uint, IDirect3D3.p, uint
							      , registercallback("enum3DDevicesCallback3", "F"), str, device)								 
}	

enum3DDevicesCallback3(lpGuid, pDeviceDescription, lpDeviceName, lpD3DHWDeviceDesc, lpD3DHELDeviceDesc, lpUserArg)	
{	
	print( StringFromIID(lpGuid) ":" strget(lpDeviceName, "UTF-8") "`n" )
	if (strget(lpDeviceName, "UTF-8") = strget(lpUserArg, "UTF-16"))
	{
		GUID_FromString(idd_d3DDevice, StringFromIID(lpGuid))		
		r := dllcall(IDirect3D3.CreateDevice, uint, IDirect3D3.p
					, ptr, &idd_d3DDevice, uint, IDirectDrawSurface4.p, "uint*", pDevice3, uint, pUnknown, uint)
		Print("Device3: " r  ":" ddraw.result[r . ""] "`n")						
		if r
			IDirect3DDevice3 := "Failed to create the IDirect3DDevice3 Interface " r " - " d3D.result[r . ""] IDirectDrawSurface4.p		
		else IDirect3DDevice3 := new ComInterfaceWrapper(d3d.IDirect3DDevice3, pDevice3, True)	
	}
	return True
}

createTexture2(pDdraw, pDevice, ww, hh, pixelformat = "ARGB")
{
	critical	
	colorkey ?: colorkey := {"RGB" : 0x07e0, "XRGB" : 0}
	static desc 
	desc ?: desc := ddSurfaceDesc.clone()	
						
	zeromem(desc)
	desc.dwSize := desc.size()
	desc.dwSize := DDSURFACEDESC.size()
	desc.dwFlags := DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT | DDSD_PIXELFORMAT 
	desc.dwWidth := ww
	desc.dwHeight := hh		
	desc.ddsCaps.dwCaps := DDSCAPS_VIDEOMEMORY | DDSCAPS_3DDEVICE | DDSCAPS_TEXTURE	
	DDPIXELFORMAT[] := desc.GetAddress("ddpfPixelFormat")
	setPixelFormat(pixelformat)	
	if ! instr(pixelformat, "A")	{
		desc.dwFlags |= DDSD_CKSRCBLT 
		desc.ddckCKSrcBlt.dwColorSpaceLowValue := colorkey[pixelformat]
		desc.ddckCKSrcBlt.dwColorSpaceHighValue := colorkey[pixelformat]
	}	
	
	r := dllcall(IDirectDraw.CreateSurface, uint, pDdraw, uint, desc[]
										  , "ptr*", pSurface, uint, 0, uint)
	printl("Create Texture - Surface "	r " " ddraw.result[r . ""])	
	if r
		return
							  
				
	GUID_FromString(idd_texture, d3d.IID_IDirect3DTexture2)
	r := dllcall(IDirectDrawSurface.QueryInterface, uint, pSurface
				, ptr, &idd_texture, "ptr*", pTexture, uint)
	printl("Create Texture - Texture " r " " ddraw.result[r . ""])			
	if r
		return			
	
	if not isobject(IDirect3DDevice3) {
	s := dllcall(IDirect3DTexture2.GetHandle, uint, pTexture, uint, pDevice, "uint*", hText, uint)
	printl("Create Texture hwnd "	s " " ddraw.result[s . ""] errorlevel " " vv.rTexture " " g_textSwap.device " " hText)	
	}
	
	ret := {}	
	ret.rSurface := pSurface	
	ret.rTexture :=	pTexture
	ret.rHwnd := hText
	return ret
}

releaseTexture2(tex)
{
	if isobject(tex)
	{
		printl("Releasing IDirect3DTexture2 object")
		dllcall(IDirect3DTexture2.release, uint, tex.rTexture)
		dllcall(IDirectdrawSurface.release, uint, tex.rSurface)			
	}	
	return
}	

matrix2String(pMatrix)
{
	static matrix 
	matrix ?: matrix := D3DMATRIX.clone()
	matrix[] := pMatrix
	str := 	MATRIX.m11 " " MATRIX.m12 " " MATRIX.m13 " " MATRIX.m14 "`n"
	str .= 	MATRIX.m21 " " MATRIX.m22 " " MATRIX.m23 " " MATRIX.m24 "`n"
	str .= 	MATRIX.m31 " " MATRIX.m32 " " MATRIX.m33 " " MATRIX.m34 "`n"
	str .= 	MATRIX.m41 " " MATRIX.m42 " " MATRIX.m43 " " MATRIX.m44 "`n"
	return str	
}	

makeViewPortMatrix(x, y, w, h, MaxZ=1, MinZ=0)
{
	matrix := D3DMATRIX.clone()
	matrix.m11 := w/2
	matrix.m41 := x + w/2
	matrix.m22 := -h/2
	matrix.m42 := y + h/2
    matrix.m33 := MaxZ-MinZ
	matrix.m44 := 1
	matrix.m43 := MinZ
	return matrix	
}	

changeViewPortMatrix(byref matrix, x, y, w, h, MaxZ=1, MinZ=0)
{
	matrix.m11 := w/2
	matrix.m41 := x + w/2
	matrix.m22 := -h/2
	matrix.m42 := y + h/2
    matrix.m33 := MaxZ-MinZ
	matrix.m44 := 1
	matrix.m43 := MinZ	
}	