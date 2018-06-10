global g_hiRes := {}
D3DVIEWPORT.dwSize := D3DVIEWPORT.size()
DDBLTFX.dwSize := DDBLTFX.size()
DDBLTFX.ddckSrcColorkey.dwColorSpaceLowValue := 0
DDBLTFX.ddckSrcColorkey.dwColorSpaceHighValue := 0
DDBLTFX.dwFillColor := 0

/* cach the sektop resolution because for some games we just force a new resolution at IDirectDraw::CreateSurface
 * and thus the game will arllready have chenged the desktop resolution
 */
g_globals.desktop := GetDesktopResolution() 
ComputeResolutionCorrections(p2, p3)
{
	g_globals.res := (g_hiRes.width and g_hiRes.height) & True 
	? {"w" : g_hiRes.width, "h" : g_hiRes.height} : g_globals.desktop
	g_globals.requested_res := {"w" : p2, "h" : p3}
	;(g_globals.keep_aspect_ratio) ?: p2 := p3 * g_globals.res.w/g_globals.res.h
	g_globals.resolution_correction := g_globals.res.h/g_globals.requested_res.h
	g_globals.viewport_correction := (g_globals.res.w - p2*g_globals.resolution_correction)/2 
		
	/*	
	logerr("`nResolution\Viewport:"
	. "`nRequested                 : " g_globals.requested_res.w " x " g_globals.requested_res.h
	. "`nReal                      : " g_globals.res.w " x " g_globals.res.h
	. "`nCorrection                : " g_globals.resolution_correction
	. "`nViewport width correction : " g_globals.viewport_correction"`n")
	*/			
	_rect_setscale()	
}

_rect_setscale(scale="")
{
	if scale {
		_rect.left := (g_globals.res.w - g_globals.requested_res.w*scale)/2 
		_rect.top := (g_globals.res.h - g_globals.requested_res.h*scale)/2
		_rect.right := _rect.left + g_globals.requested_res.w*scale
		_rect.bottom := _rect.top + g_globals.requested_res.h*scale
	} else {
		_RECT.left := g_globals.viewport_correction
		_RECT.right := g_globals.res.w - g_globals.viewport_correction
		_RECT.bottom := g_globals.res.h 
		_RECT.top := 0
	}	
}

/* ========================================================================
 * =============================DirectX 2 and 3============================
 */

InitHighResHooks()
{
	g_hiRes := parseConfig(g_globals.config.hiRes)
	/* On win 10, Resident Evil and Hellbender (or maybe the system?) call
     * IDirectDraw::SetDisplayMode instead of IDirectDraw2::SetDisplayMode	 
	 */
	logErr(IDirectDraw.hook("SetDisplayMode"))
	logErr(IDirectDraw2.hook("SetDisplayMode"))
	logErr(IDirect3DDevice.hook("Execute"))
	logErr(IDirect3DDevice.hook("CreateMatrix")) 
	logerr(IDirect3DViewPort.Hook("SetViewPort"))
	logerr(IDirect3DViewport.Hook("Clear"))
}

IDirectDraw_SetDisplayMode(p1, p2, p3, p4)
{
	critical	
	ComputeResolutionCorrections(p2, p3)
   	r := dllcall(IDirectDraw.SetDisplayMode, uint, p1, int, g_globals.res.w, int, g_globals.res.h, int, p4)
    printl("IDirectDraw_SetDisplayMode " r draw.result[r . ""])
	g_hires.displaymode_set := True
	
	if (g_globals.config.d3D = "2")
		UpdateDevice2DrawPrimitieParamenters()
	return r
} 

IDirect3DDevice_CreateMatrix(p1, p2)
{
	critical
	logErr(IDirect3DDevice.unHook("Execute"))		
	r := dllcall(IDirect3DDevice.CreateMatrix, uint, p1, uint, p2)
	logErr(IDirect3DDevice.unHook("CreateMatrix")) 
	return r
}	

IDirect3DDevice_Execute(p1, p2, p3, p4)
{
	Critical
	static vertex := Struct("float x; float y;")
	;static D3DINSTRUCTION := ("BYTE bOpcode; BYTE bSize; WORD wCount;")
	;static D3DOP_EXIT := 11
	
	dllcall(IDirect3DExecuteBuffer.GetExecuteData, uint, p2, uint, D3DEXECUTEDATA[])
	dllcall(IDirect3DExecuteBuffer.lock, uint, p2, uint, D3DEXECUTEBUFFERDESC[], uint)
	n_vertices := D3DEXECUTEDATA.dwVertexCount
	vertex[] := D3DEXECUTEBUFFERDESC.lpData + D3DEXECUTEDATA.dwVertexOffset 
	loop, % n_vertices
	{
		vertex.x *= g_globals.resolution_correction
		vertex.x += g_globals.viewport_correction
		vertex.y *= g_globals.resolution_correction
		vertex[] += 32
	}	
		
	dllcall(IDirect3DExecuteBuffer.unlock, uint, p2)	
	r := dllcall(IDirect3DDevice.Execute, uint, p1, uint, p2, uint, p3, uint, p4)
	return r
}	

IDirect3DViewPort_SetViewPort(p1, p2)
{
	critical
	D3DVIEWPORT[] := p2
	D3DVIEWPORT.dwX += g_globals.viewport_correction	
	D3DVIEWPORT.dwWidth *= g_globals.resolution_correction
	D3DVIEWPORT.dwHeight *= g_globals.resolution_correction
	D3DVIEWPORT.dvScaleX *= g_globals.resolution_correction
	D3DVIEWPORT.dvScaleY *= g_globals.resolution_correction	
	r := dllcall(IDirect3DViewPort.SetViewPort, uint, p1, uint, D3DVIEWPORT[])	
	return r	
}	

IDirect3DViewPort_Clear(p1, p2, p3, p4)
{
	critical	
	if not g_hiRes.checkflags or p4 & 0x00000001 { ; D3DCLEAR_TARGET	
	dllcall(IDirectdrawSurface2.blt, uint, g_globals.RenderTarget, uint, 0, uint, 0, uint, 0
							       , uint, DDBLT_COLORFILL, uint, DDBLTFX[], uint) 
    if g_globals.surrogate_RenderTarget
	dllcall(IDirectdrawSurface.blt, uint, g_globals.surrogate_RenderTarget, uint, 0
								  , uint, 0, uint, 0, uint, DDBLT_COLORFILL, uint, DDBLTFX[], uint) 
	}								  
	rect[] := p3
	loop, % p2
	{
		rect.bottom *= g_globals.resolution_correction 
		rect.right *= g_globals.resolution_correction 
		rect.right += g_globals.viewport_correction	
		rect[] += rect.size()
	}
	r := dllcall(IDirect3DViewPort.Clear, uint, p1, uint, p2, uint, p3, uint, p4)	     
	return r	
}

/* ========================================================================
 * =============================DirectX 2, 3 and 5=========================
 */
  
IDirectDraw2_SetDisplayMode(p1, p2, p3, p4, p5, p6)
{
	critical	
	ComputeResolutionCorrections(p2, p3)
   	r := dllcall(IDirectDraw2.SetDisplayMode, uint, p1, int, g_globals.res.w, int, g_globals.res.h, int, p4, int, p5, int, p6, uint)
    printl("IDirectDraw2_SetDisplayMode " r draw.result[r . ""])
	g_hires.displaymode_set := True
	
	if (g_globals.config.d3D = "2")
		UpdateDevice2DrawPrimitieParamenters()
	return r
} 

/* ========================================================================
 * =============================DirectX 5 =================================
 */
   
InitHighResHooks2(keep_aspect_ratio=True)
{
	/* On win 10, Resident Evil 2 and Tomb Raider II and III (or maybe the system?)
     * call IDirectDraw2::SetDisplayMode instead of IDirectDraw4::SetDisplayMode
	 */
	 
	logErr( g_globals.config.os_version  > 6.1 
	? IDirectDraw2.Hook("SetDisplayMode") : IDirectDraw4.Hook("SetDisplayMode") ) 
	logErr(IDirectDraw4.hook("SetDisplayMode"))
	logerr(IDirect3DViewPort2.Hook("SetViewPort2"))
	logerr(IDirect3DViewport2.Hook("Clear"))
	g_globals.keep_aspect_ratio := keep_aspect_ratio
	
	g_globals.SetDrawPrimitive2HookParameters := dllcall("GetProcAddress", uint, dllcall("GetModuleHandle", str, "peixoto.dll"), astr, "SetDrawPrimitive2HookParameters")
	logErr(IDirect3DDevice2.dllHook("DrawPrimitive", "DrawPrimitive2Hook"))	
	g_hiRes := parseConfig(g_globals.config.hiRes)			
}

UpdateDevice2DrawPrimitieParamenters()
{
	VERTEX_TRANSFORM_PARAMETERS.scale := True
	VERTEX_TRANSFORM_PARAMETERS.scale_delta := g_globals.resolution_correction 
	VERTEX_TRANSFORM_PARAMETERS.displace := True
	VERTEX_TRANSFORM_PARAMETERS.displacement := g_globals.viewport_correction
	VERTEX_TRANSFORM_PARAMETERS.p_DrawPrimitive := IDirect3DDevice2.DrawPrimitive
	dllcall(g_globals.SetDrawPrimitive2HookParameters, uint, VERTEX_TRANSFORM_PARAMETERS[])	
}

IDirect3DViewPort2_SetViewPort2(p1, p2)
{
	critical
	D3DVIEWPORT2[] := p2
	D3DVIEWPORT2.dwX += g_globals.viewport_correction	
	D3DVIEWPORT2.dwWidth *= g_globals.resolution_correction
	D3DVIEWPORT2.dwHeight *= g_globals.resolution_correction	
	if (D3DVIEWPORT2.dvClipX = 0)    ; Transformed vertices
	{	
		D3DVIEWPORT2.dvClipX += g_globals.viewport_correction			
		D3DVIEWPORT2.dvClipWidth *= g_globals.resolution_correction 
		D3DVIEWPORT2.dvClipHeight *= g_globals.resolution_correction 			
	} 
	
	r := dllcall(IDirect3DViewPort2.SetViewPort2, uint, p1, uint, D3DVIEWPORT2[])
	return r	
}	

IDirect3DViewPort2_Clear(p1, p2, p3, p4)
{
	critical	
	if not g_hiRes.checkflags or p4 & 0x00000001 { ; D3DCLEAR_TARGET
	dllcall(IDirectdrawSurface.blt, uint, g_globals.RenderTarget, uint, 0, uint, 0, uint, 0
								  , uint, DDBLT_COLORFILL, uint, DDBLTFX[], uint) 
	if g_globals.surrogate_RenderTarget
	dllcall(IDirectdrawSurface.blt, uint, g_globals.surrogate_RenderTarget.rSurface, uint, 0
								  , uint, 0, uint, 0, uint, DDBLT_COLORFILL, uint, DDBLTFX[], uint) 
	}								  
	
	rect[] := p3
	loop, % p2
	{
		rect.bottom *= g_globals.resolution_correction 
		rect.right *= g_globals.resolution_correction 
		rect.right += g_globals.viewport_correction	
		rect[] += rect.size()
	}
	r := dllcall(IDirect3DViewPort2.Clear, uint, p1, uint, p2, uint, p3, uint, p4)	
	return r	
}

/* ========================================================================
 * =============================DirectX 5 and 6 ===========================
 */
 
IDirectDraw4_SetDisplayMode(p1, p2, p3, p4, p5, p6)
{
	critical
	printl("IDirectDraw4_SetDisplayMode")	
	if g_globals.config.hiRes or g_globals.config.upScale
	{
		ComputeResolutionCorrections(p2, p3)
		VERTEX_TRANSFORM_PARAMETERS.scale := True
		VERTEX_TRANSFORM_PARAMETERS.scale_delta := g_globals.resolution_correction 
		VERTEX_TRANSFORM_PARAMETERS.displace := True
		VERTEX_TRANSFORM_PARAMETERS.displacement := g_globals.viewport_correction
		if (g_globals.config.d3D = "2")
			UpdateDevice2DrawPrimitieParamenters()
		else if (g_globals.config.d3D = "3")	
			UpdateDevice3DrawPrimitieParamenters()			
	} else g_globals.res := {"w" : p2, "h" : p3}
	if g_globals.config.8bitColorfix 
	{
		DDRAWI_DIRECTDRAW_INT[] := p1
		DDRAWI_DIRECTDRAW_LCL[] := DDRAWI_DIRECTDRAW_INT.lpLcl
		if p4 = 8 
			DDRAWI_DIRECTDRAW_LCL.dwAppHackFlags |= 0x800 
		else DDRAWI_DIRECTDRAW_LCL.dwAppHackFlags &= ~ 0x800
	} 
	g_hires.displaymode_set := True
	r := dllcall(IDirectDraw4.SetDisplayMode, uint, p1, int, g_globals.res.w, int, g_globals.res.h, int, p4, int, p5, int, p6)
	return r
}

/* ========================================================================
 * =============================DirectX 6 =================================
 */

InitHighResHooks3()
{
	logErr(IDirectDraw4.hook("SetDisplayMode"))
	logerr(IDirect3DViewPort3.Hook("SetViewPort2"))
	logerr(IDirect3DViewport3.Hook("Clear"))
	logerr(IDirect3DViewport3.Hook("Clear2"))	
	logerr(IDirect3DViewport3.Hook("TransformVertices"))
		
	g_globals.SetDrawPrimitive3HookParameters := dllcall("GetProcAddress", uint, dllcall("GetModuleHandle", str, "peixoto.dll"), astr, "SetDrawPrimitive3HookParameters")	
	if g_globals.config.dev
	{
		logErr(IDirect3DDevice3.Hook("DrawIndexedPrimitiveStrided"))
		logErr(IDirect3DDevice3.Hook("DrawIndexedPrimitiveVB"))  ;<- Half-Life
		logErr(IDirect3DDevice3.Hook("DrawPrimitiveVB"))
	} else {
		logErr(IDirect3DDevice3.dllHook("DrawPrimitive", "DrawPrimitive3Hook"))	
		logErr(IDirect3DDevice3.dllHook("DrawIndexedPrimitive", "DrawIndexedPrimitive3Hook"))
	}		
	g_hiRes := parseConfig(g_globals.config.hiRes)				
}

UpdateDevice3DrawPrimitieParamenters()
{
	VERTEX_TRANSFORM_PARAMETERS.scale := True
	VERTEX_TRANSFORM_PARAMETERS.scale_delta := g_globals.resolution_correction 
	VERTEX_TRANSFORM_PARAMETERS.displace := True
	VERTEX_TRANSFORM_PARAMETERS.displacement := g_globals.viewport_correction
	VERTEX_TRANSFORM_PARAMETERS.p_DrawPrimitive := IDirect3DDevice3.DrawPrimitive
	VERTEX_TRANSFORM_PARAMETERS.p_DrawIndexedPrimitive := IDirect3DDevice3.DrawIndexedPrimitive
	dllcall(g_globals.SetDrawPrimitive3HookParameters, uint, VERTEX_TRANSFORM_PARAMETERS[])		
}

IDirect3DDevice3_DrawPrimitive(pIDirect3DDevice3, dptPrimitiveType, dwVertexTypeDesc, lpvVertices, dwVertexCount, dwFlags)
{
	critical
	static pdata
	static vertice := struct("float x; float y; float z; float w")
	static temp_vertice := struct("float x; float y; float z; float w")
    size := 4*4
    if (dwVertexTypeDesc && D3DFVF_DIFFUSE) 
		size += 4
    if (dwVertexTypeDesc && D3DFVF_SPECULAR) 
		size += 4
    size += ((dwVertexTypeDesc & D3DFVF_TEXCOUNT_MASK)>>D3DFVF_TEXCOUNT_SHIFT) * 8

    if (dwVertexTypeDesc && D3DFVF_XYZRHW) {		
	pdata := dllcall("VirtualAlloc", uint, 0, uint, size * dwVertexCount, "Int", 0x00001000 
								   , uint, (PAGE_READWRITE := 0x04) )	
	vertice[] := pdata	
	dllcall("RtlMoveMemory", ptr, pdata, ptr, lpvVertices, int, size * dwVertexCount)	
    loop % dwVertexCount
    {
		vertice.x *= g_globals.resolution_correction
		vertice.y *= g_globals.resolution_correction
		vertice.x += g_globals.viewport_correction		
		vertice[] += size	
    }
	hr := dllcall(IDirect3DDevice3.DrawPrimitive, uint, pIDirect3DDevice3, uint, dptPrimitiveType
                                                , uint, dwVertexTypeDesc, uint, pdata, uint, dwVertexCount
                                                , uint, dwFlags)
	dllcall("VirtualFree", uint, pdata, uint, 0, uint, (MEM_RELEASE := 0x8000) )
	return hr	
	} 
	return 0
    hr := dllcall(IDirect3DDevice3.DrawPrimitive, uint, pIDirect3DDevice3, uint, dptPrimitiveType
                                                , uint, dwVertexTypeDesc, uint, lpvVertices, uint, dwVertexCount
                                                , uint, dwFlags)	
    return hr
}

IDirect3DDevice3_DrawIndexedPrimitive(pIDirect3DDevice3, d3dptPrimitiveType, dwVertexTypeDesc, lpvVertices, dwVertexCount, lpwIndices, dwIndexCount, dwFlags)
{
    static vertice := struct("float x; float y; float z; float w")
	static temp_vertice := struct("float x; float y; float z; float w")
    size := 4*4
    if (dwVertexTypeDesc & D3DFVF_DIFFUSE) 
		size += 4
    if (dwVertexTypeDesc & D3DFVF_SPECULAR) 
		size += 4
    size += ((dwVertexTypeDesc & D3DFVF_TEXCOUNT_MASK)>>D3DFVF_TEXCOUNT_SHIFT) * 8

    if (dwVertexTypeDesc && D3DFVF_XYZRHW) {		
	pdata := dllcall("VirtualAlloc", uint, 0, uint, size * dwVertexCount, "Int", 0x00001000 
								   , uint, (PAGE_READWRITE := 0x04) )	
	vertice[] := pdata	
	dllcall("RtlMoveMemory", ptr, pdata, ptr, lpvVertices, int, size * dwVertexCount)	
    loop % dwVertexCount
    {
		vertice.x *= g_globals.resolution_correction
		vertice.y *= g_globals.resolution_correction
		vertice.x += g_globals.viewport_correction		
		vertice[] += size	
    }
	hr := dllcall(IDirect3DDevice3.DrawIndexedPrimitive, uint, pIDirect3DDevice3, uint, d3dptPrimitiveType
                                                       , uint, dwVertexTypeDesc, uint, pdata, uint, dwVertexCount
                                                       , uint, lpwIndices, uint, dwIndexCount, uint, dwFlags)
	dllcall("VirtualFree", uint, pdata, uint, 0, uint, (MEM_RELEASE := 0x8000) )
	return hr	
	}    
	r := dllcall(IDirect3DDevice3.DrawIndexedPrimitive, uint, pIDirect3DDevice3, uint, d3dptPrimitiveType
                                                      , uint, dwVertexTypeDesc, uint, lpvVertices, uint, dwVertexCount
													  , uint, lpwIndices, uint, dwIndexCount, uint, dwFlags)
	return r
}

IDirect3DDevice3_DrawIndexedPrimitiveStrided(p1, p2, p3, p4, p5, p6, p7, p8)
{
	Critical
	return
}

IDirect3DDevice3_DrawIndexedPrimitiveVB(p1, p2, p3, p4, p5, p6)
{
	Critical
	return 0
	;dllcall(IDirect3DVertexBuffer.GetVertexBufferDesc, uint, p2, uint, D3DVERTEXBUFFERDESC[]) 
	r := dllcall(IDirect3DDevice3.DrawIndexedPrimitiveVB, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6)
	return r
}

IDirect3DDevice3_DrawPrimitiveVB(p1, p2, p3, p4, p5, p6)
{
	Critical
	return 0
	r := dllcall(IDirect3DDevice3.DrawPrimitiveVB, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6)	
	return r
}	

IDirect3DViewPort3_SetViewPort(p1, p2)
{
	Critical
	printl("Setviewport 1")
	return 0
}	

IDirect3DViewPort3_SetViewPort2(p1, p2)
{
	critical
	D3DVIEWPORT2[] := p2
	;ComputeResolutionCorrections(D3DVIEWPORT2.dwWidth, D3DVIEWPORT2.dwHeight)
			
	D3DVIEWPORT2.dwX += g_globals.viewport_correction	
	D3DVIEWPORT2.dwWidth *= g_globals.resolution_correction 
	D3DVIEWPORT2.dwHeight *= g_globals.resolution_correction 
		
	if (D3DVIEWPORT2.dvClipX = 0)    ; Transformed vertices
	{	
		D3DVIEWPORT2.dvClipX += g_globals.viewport_correction			
		D3DVIEWPORT2.dvClipWidth *= g_globals.resolution_correction 
		D3DVIEWPORT2.dvClipHeight *= g_globals.resolution_correction 			
	} 
		
	r := dllcall(IDirect3DViewPort3.SetViewPort2, uint, p1, uint, D3DVIEWPORT2[])
	return r	
}	

IDirect3DViewport3_TransformVertices(p1, p2, p3, p4, p5)
{
	Critical
	return 0
}

IDirect3DViewPort3_Clear(p1, p2, p3, p4)
{
	critical
	if not g_hiRes.checkflags or p4 & 0x00000001  ; D3DCLEAR_TARGET
	dllcall(IDirectdrawSurface4.blt, uint, g_globals.RenderTarget, uint, 0, uint, 0, uint, 0
							       , uint, DDBLT_COLORFILL, uint, DDBLTFX[], uint)         
	rect[] := p3
	loop, % p2
	{
		rect.bottom *= g_globals.resolution_correction 
		rect.right *= g_globals.resolution_correction 
		rect.right += g_globals.viewport_correction	
		rect[] += rect.size()
	}
	r := dllcall(IDirect3DViewPort3.Clear, uint, p1, uint, p2, uint, p3, uint, p4)	
	return r	
}

IDirect3DViewPort3_Clear2(p1, p2, p3, p4, p5, p6, p7)
{
	critical
	if not g_hiRes.checkflags or p4 & 0x00000001  ; D3DCLEAR_TARGET
	dllcall(IDirectdrawSurface4.blt, uint, g_globals.RenderTarget, uint, 0, uint, 0, uint, 0
							       , uint, DDBLT_COLORFILL, uint, DDBLTFX[], uint)         
	rect[] := p3
	loop, % p2
	{
		rect.bottom *= g_globals.resolution_correction 
		rect.right *= g_globals.resolution_correction 
		rect.right += g_globals.viewport_correction					
		rect[] += rect.size()
	}
	r := dllcall(IDirect3DViewPort3.Clear2, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6, uint, p7)	
	return r	
}

/* ========================================================================
 * =============================DirectX 7 =================================
 */

initHighResHooks7()
{
	logErr(IDirectDraw7.hook("SetDisplayMode"))
	logerr(IDirect3DDevice7.Hook("SetViewPort"))
	logerr(IDirect3DDevice7.Hook("Clear"))
	;logErr(IDirect3DDevice7.Hook("DrawPrimitive"))	
	;logErr(IDirect3DDevice7.Hook("DrawPrimitiveVB"))
			
	g_hiRes := parseConfig(g_globals.config.hiRes)	
	
	g_globals.SetDrawPrimitive7HookParameters := dllcall("GetProcAddress", uint, dllcall("GetModuleHandle", str, "peixoto.dll"), astr, "SetDrawPrimitive7HookParameters")	
	logErr(IDirect3DDevice7.dllHook("DrawPrimitiveVB", "DrawPrimitive7VBHook"))	
    logErr(IDirect3DDevice7.dllHook("DrawPrimitive", "DrawPrimitive7Hook"))		
	return	
}

IDirectDraw7_SetDisplayMode(p1, p2, p3, p4, p5, p6)
{
	critical		
	if g_globals.config.hiRes or g_globals.config.upScale
		ComputeResolutionCorrections(p2, p3)
	
	VERTEX_TRANSFORM_PARAMETERS.scale := True
	VERTEX_TRANSFORM_PARAMETERS.scale_delta := g_globals.resolution_correction 
	VERTEX_TRANSFORM_PARAMETERS.displace := True
	VERTEX_TRANSFORM_PARAMETERS.displacement := g_globals.viewport_correction
	VERTEX_TRANSFORM_PARAMETERS.p_DrawPrimitiveVB := IDirect3DDevice7.DrawPrimitiveVB
	VERTEX_TRANSFORM_PARAMETERS.p_DrawPrimitive := IDirect3DDevice7.DrawPrimitive
	VERTEX_TRANSFORM_PARAMETERS.p_GetVertexBufferDesc := IDirect3DVertexBuffer7.GetVertexBufferDesc
	VERTEX_TRANSFORM_PARAMETERS.p_LockVertexBuffer := IDirect3DVertexBuffer7.Lock
	VERTEX_TRANSFORM_PARAMETERS.p_UnLockVertexBuffer := IDirect3DVertexBuffer7.Unlock
	dllcall(g_globals.SetDrawPrimitive7HookParameters, uint, VERTEX_TRANSFORM_PARAMETERS[])	

	r := dllcall(IDirectDraw7.SetDisplayMode, uint, p1, int, g_globals.res.w, int, g_globals.res.h, int, p4, int, p5, int, p6)
	return r
}

IDirect3DDevice7_SetViewPort(p1, p2)
{
	critical
	D3DVIEWPORT7[] := p2
	;ComputeResolutionCorrections(D3DVIEWPORT7.dwWidth, D3DVIEWPORT7.dwHeight)
	if (D3DVIEWPORT7.dwWidth < g_globals.res.w)
	{
		D3DVIEWPORT7.dwX += g_globals.viewport_correction	
		D3DVIEWPORT7.dwWidth *= g_globals.resolution_correction 
		D3DVIEWPORT7.dwHeight *= g_globals.resolution_correction 
	}
	r := dllcall(IDirect3DDevice7.SetViewPort, uint, p1, uint, D3DVIEWPORT7[])
	return r
}	

IDirect3DDevice7_DrawPrimitive(pIDirect3DDevice7, dptPrimitiveType, dwVertexTypeDesc, lpvVertices, dwVertexCount, dwFlags)
{
	critical
	static vertice := struct("float x; float y; float z; float w")
	size := 4*4
    if (dwVertexTypeDesc & D3DFVF_DIFFUSE) 
		size += 4
    if (dwVertexTypeDesc & D3DFVF_SPECULAR) 
		size += 4
    size += ((dwVertexTypeDesc & D3DFVF_TEXCOUNT_MASK)>>D3DFVF_TEXCOUNT_SHIFT) * 8
	
    if (dwVertexTypeDesc & D3DFVF_XYZRHW) {
	vertice[] := lpvVertices
    loop % dwVertexCount
    {
		vertice.x *= g_globals.resolution_correction 
		vertice.x += g_globals.viewport_correction		
        vertice.y *= g_globals.resolution_correction 			
		vertice[] += size	
    }
	} 												
    hr := dllcall(IDirect3DDevice7.DrawPrimitive, uint, pIDirect3DDevice7, uint, dptPrimitiveType
                                                , uint, dwVertexTypeDesc, uint, lpvVertices, uint, dwVertexCount
                                                , uint, dwFlags)	
    return hr		
}

IDirect3DDevice7_DrawPrimitiveVB(p1, p2, p3, p4, p5, p6)
{
	Critical
	g_globals.call += 1
	static vertice := struct("float x; float y; float z; float w")
	dllcall(IDirect3DVertexBuffer7.GetVertexBufferDesc, uint, p3, uint, D3DVERTEXBUFFERDESC[])
	dllcall(IDirect3DVertexBuffer7.lock, uint, p3, uint, DDLOCK_READONLY, "uint*", src, uint, 0)		
			
	dwVertexTypeDesc := D3DVERTEXBUFFERDESC.dwFVF 
	dwVertexCount := D3DVERTEXBUFFERDESC.dwNumVertices
	size := 4*4
	(dwVertexTypeDesc & D3DFVF_DIFFUSE) ? size += 4
	(dwVertexTypeDesc & D3DFVF_SPECULAR) ? size += 4 
	size += ((dwVertexTypeDesc & D3DFVF_TEXCOUNT_MASK)>>D3DFVF_TEXCOUNT_SHIFT) * 8
	dllcall("peixoto.dll\ScaleVertices", ptr, src+p4*size, int, dwVertexTypeDesc, int, p5, float, g_globals.resolution_correction, float, g_globals.viewport_correction)
			
	r := dllcall(IDirect3DDevice7.DrawPrimitive, uint, p1, uint, p2, uint, D3DVERTEXBUFFERDESC.dwFVF, uint, src+p4*size, uint, p5, uint, 0)
	dllcall(IDirect3DVertexBuffer7.unlock, uint, p3)	
	return 0
}	

IDirect3DDevice7_Clear(p1, p2, p3, p4, p5, p6, p7)
{
	critical
	if not g_hiRes.checkflags or p4 & 0x00000001  ; D3DCLEAR_TARGET
	dllcall(IDirectdrawSurface7.blt, uint, g_globals.RenderTarget, uint, 0, uint, 0, uint, 0
							       , uint, DDBLT_COLORFILL, uint, DDBLTFX[], uint)         
	rect[] := p3
	loop, % p2
	{
		rect.bottom *= g_globals.resolution_correction 
		rect.right *= g_globals.resolution_correction 
		rect.right += g_globals.viewport_correction	
		rect[] += rect.size()
	}
	r := dllcall(IDirect3DDevice7.Clear, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6, uint, p7)	
	return r	
}