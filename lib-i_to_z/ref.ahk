/* ========================================================================
 * =============================DirectX 2 and 3============================
 */
 
IDirectDrawSurface2_lock(p1, p2, p3, p4, p5)
{
	critical
	(p1 = g_globals.RenderTarget) ? p1 := g_globals.surrogate_RenderTarget
	(p1 = g_globals.primary) ? printl("locking primary")
	r := dllcall(IDirectDrawSurface2.lock, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint)
	return r
}

IDirectDrawSurface2_Unlock(p1, p2)
{
	critical	
	(p1 = g_globals.RenderTarget) ? p1 := g_globals.surrogate_RenderTarget
	r := dllcall(IDirectDrawSurface2.Unlock, uint, p1, uint, p2)
	(p1 = g_globals.surrogate_RenderTarget)
	? blt := dllcall(IDirectDrawSurface.blt, uint, g_Globals.RenderTarget, uint, _RECT[], uint, g_globals.surrogate_RenderTarget
									       , uint, 0, uint, DDBLT_KEYSRCOVERRIDE | DDBLT_WAIT, uint, DDBLTFX[], uint)										
	return r
}	

/* ========================================================================
 * =============================DirectX 5 =================================
 */

IDirectDrawSurface_lock(p1, p2, p3, p4, p5)
{
	critical
	(p1 = g_globals.primary) ? p1 := g_globals.surrogate_primary
	(p1 = g_globals.RenderTarget) ? p1 := g_globals.surrogate_RenderTarget.rSurface
	r := dllcall(IDirectDrawSurface.lock, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint)
	;printl("lock" ddraw.result[r . ""])
	return r
}	

IDirectDrawSurface_Unlock(p1, p2)
{
	critical	
	static D3DPT_TRIANGLESTRIP := 5
	static D3DVT_TLVERTEX := 3

	(p1 = g_globals.primary) ? p1 := g_globals.surrogate_primary	
	(p1 = g_globals.RenderTarget) ? p1 := g_globals.surrogate_RenderTarget.rSurface
	r := dllcall(IDirectDrawSurface.Unlock, uint, p1, uint, p2)
	;printl("unlock" ddraw.result[r . ""])
	(p1 = g_globals.surrogate_primary)
	? dllcall(IDirectDrawSurface.blt, uint, g_Globals.primary, uint, _RECT[], uint, g_globals.surrogate_primary
									, uint, 0, uint, DDBLT_WAITVSYNC | DDBLTFAST_NOCOLORKEY, uint, 0)
	if (p1 = g_globals.surrogate_RenderTarget.rSurface)
	{
		if dllcall(IDirect3DDevice2.BeginScene, uint, g_globals.Device2 , uint)	
			return
		if dllcall(IDirect3DDevice2.GetRenderState, uint, g_globals.Device2, uint, 41, "uint*", colorkeystate)
			return dllcall(IDirect3DDevice2.EndScene, uint, g_globals.Device2, uint)
		if dllcall(IDirect3DDevice2.SetRenderState, uint, g_globals.Device2, uint, 1, uint, g_globals.surrogate_RenderTarget.rHwnd)	
			return dllcall(IDirect3DDevice2.EndScene, uint, g_globals.Device2, uint)
		if dllcall(IDirect3DDevice2.SetRenderState, uint, g_globals.Device2, uint, 41, uint, 1)	
			return dllcall(IDirect3DDevice2.EndScene, uint, g_globals.Device2, uint)
				
		z := dllcall(IDirect3DDevice2.DrawPrimitive
		, uint, g_globals.Device2
		, uint, D3DPT_TRIANGLESTRIP
		, uint, D3DVT_TLVERTEX
		, uint, g_globals.vertices[]
		, uint, 4
		, uint, 0
		, uint) 
		
		dllcall(IDirect3DDevice2.SetRenderState, uint, g_globals.Device2, uint, 41, uint, colorkeystate)				
		dllcall(IDirect3DDevice2.EndScene, uint, g_globals.Device2, uint)		
	}	
	return r
}	

IDirectDrawSurface_Blt(p1, p2, p3, p4, p5, p6)
{
	Critical
	(p1 = g_Globals.primary) ? p1 := g_globals.surrogate_primary
	r := dllcall(IDirectDrawSurface.blt, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6)
	(p1 = g_globals.surrogate_primary)
	dllcall(IDirectDrawSurface.blt, uint, g_Globals.primary, uint, _RECT[], uint, g_globals.surrogate_primary, uint, 0
										, uint, DDBLT_WAITVSYNC | DDBLTFAST_NOCOLORKEY | DDBLT_WAIT, uint, 0)
									  
	return r
}

IDirectDrawSurface_Restore(p1)
{
	Critical	
	r := dllcall(IDirectDrawSurface.Restore, uint, p1)
	(p1 = g_Globals.primary) ? dllcall(IDirectDrawSurface.Restore, uint, g_globals.surrogate_primary)	
	return r
}	

/* ========================================================================
 * =============================DirectX 6 =================================
 */

IDirectDrawSurface4_blt(p1, p2, p3, p4, p5, p6)
{
	critical
	if (p1 = g_globals.Rendertarget) and p2 != 0
	{
		rect[] := p2
		rect.bottom *= g_globals.resolution_correction 
		rect.top *= g_globals.resolution_correction 
		rect.left := rect.left * g_globals.resolution_correction + g_globals.viewport_correction 
		rect.right := rect.right * g_globals.resolution_correction + g_globals.viewport_correction 
	}		
	r := dllcall(IDirectDrawSurface4.blt, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6)
	return r		
}

IDirectDrawSurface4_lock(p1, p2, p3, p4, p5)
{
	critical
	(p1 = g_globals.RenderTarget) ? p1 := g_globals.surrogate_RenderTarget
	(p1 = g_globals.primary) ? p1 := g_globals.surrogate_primary
	r := dllcall(IDirectDrawSurface4.lock, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint)
	return r
}

IDirectDrawSurface4_Unlock(p1, p2)
{
	critical	
	(p1 = g_globals.RenderTarget) ? p1 := g_globals.surrogate_RenderTarget
	(p1 = g_globals.primary) ? p1 := g_globals.surrogate_primary
	r := dllcall(IDirectDrawSurface4.Unlock, uint, p1, uint, p2)
	(p1 = g_globals.surrogate_RenderTarget)
	? blt := dllcall(IDirectDrawSurface4.blt, uint, g_Globals.RenderTarget, uint, _RECT[], uint, g_globals.surrogate_RenderTarget
									        , uint, 0, uint, DDBLT_KEYSRCOVERRIDE, uint, DDBLTFX[], uint)	
	if (p1 = g_globals.surrogate_primary)
	{
		blt := dllcall(IDirectDrawSurface4.blt, uint, g_Globals.primary, uint, _RECT[], uint, g_globals.surrogate_primary
											  , uint, 0, uint, DDBLT_WAITVSYNC | DDBLTFAST_NOCOLORKEY | DDBLT_WAIT, uint, DDBLTFX[], uint)
		
		printl("blt" blt ddraw.result[blt . ""])
		if blt
		{			
			dllcall(IDirectDrawSurface4.GetDC, uint, g_globals.surrogate_primary, "uint*", sDC)
			dllcall(IDirectDrawSurface4.GetDC, uint, g_Globals.primary, "uint*", dDC)
			
			printl("DC blt "DllCall("Gdi32.dll\BitBlt", int, dDC, int, (g_globals.res.w-g_globals.requested_res.w)/2, int, (g_globals.res.h-g_globals.requested_res.h)/2
			                                          , int, g_globals.requested_res.w, int, g_globals.requested_res.h
													  , int, sDC, int, 0, int, 0, uint,  0x00CC0020))											  
			
			;DllCall("Gdi32.dll\StretchBlt" , int, dDC, int, _RECT.left, int, _RECT.top, int, _RECT.right-_RECT.left, int, _RECT.bottom-_RECT.top
										   ;, int, sDC, int, 0, int, 0, int, g_globals.requested_res.w, int, g_globals.requested_res.h
										   ;, uint,  0x00CC0020)											  
			
			dllcall(IDirectDrawSurface4.releaseDC, uint, g_globals.surrogate_primary, uint, sDC, uint)
			dllcall(IDirectDrawSurface4.releaseDC, uint, g_Globals.primary, uint, dDC, uint)	
		}	
	}
	;? dllcall(IDirectDrawSurface4.blt, uint, g_Globals.primary, uint, 0, uint, g_globals.surrogate_primary
								     ;, uint, 0, uint, DDBLT_WAITVSYNC | DDBLTFAST_NOCOLORKEY, uint, DDBLTFX[], uint)
	;printl("unlocking")								 
	return r
}	

/*
	w := g_globals.res.w - g_globals.viewport_correction
	x := g_globals.viewport_correction
	h := g_globals.res.h 
	y := 0 
	
	vertice := struct("float x; float y; float z; float w; int color; int specular; float u; float v")
	g_globals.vertices := struct("vertice[4]")	
	g_globals.vertices.1.x := x  , g_globals.vertices.1.y := y   , g_globals.vertices.1.color := 0x00FFFFFF
	g_globals.vertices.2.x := w  , g_globals.vertices.2.y := y   , g_globals.vertices.2.color := 0x00FFFFFF
	g_globals.vertices.3.x := x  , g_globals.vertices.3.y := h   , g_globals.vertices.3.color := 0x00FFFFFF
	g_globals.vertices.4.x := w  , g_globals.vertices.4.y := h   , g_globals.vertices.4.color := 0x00FFFFFF
		
	g_globals.vertices.1.u := 0., g_globals.vertices.1.v := 0.
	g_globals.vertices.2.u := 1., g_globals.vertices.2.v := 0.
	g_globals.vertices.3.u := 0., g_globals.vertices.3.v := 1.
	g_globals.vertices.4.u := 1., g_globals.vertices.4.v := 1.	
*?