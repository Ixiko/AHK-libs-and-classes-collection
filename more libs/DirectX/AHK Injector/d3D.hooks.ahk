#include <DirectX\d3D>
#include <DirectX\lib\TexSwap\TexSwapLib>
#include <DirectX\lib\hRes>
#include <DirectX\lib\SurfaceHooks>

if (g_globals.config.d3D = "1")
{	
	logErr(getDirect3D("", "Direct3D HAL"))	
	/* On win 10, Resident Evil and Hellbender (or maybe the system?) call
     * IDirectDraw::CreateSurface instead of IDirectDraw2::CreateSurface
	 */
	logErr( g_globals.config.os_version > 6.1 
	? IDirectDraw.Hook("CreateSurface") : IDirectDraw2.Hook("CreateSurface") )
	logErr(IDirectDrawSurface2.Hook("GetAttachedSurface"))
	logErr(IDirect3DDevice.Hook("EndScene"))	
	if g_globals.config.TextSwap 
		initTextSwapHooks(g_globals.config.TextSwap)	
	if g_globals.config.hiRes
		initHighResHooks()	
}
else if (g_globals.config.d3D = "2")
{
	logErr(getDirect3D2("", "Direct3D HAL"))	
	/* On win 10, Tomb Raider II and Resident Evil 2 (or maybe the system?) call
     * IDirectDraw2::CreateSurface instead of IDirectDraw::CreateSurface
	 */
	logerr(IDirectDraw.Hook("CreateSurface"))
	(g_globals.config.os_version) > 6.1 ? logerr(IDirectDraw2.Hook("CreateSurface"))
	logErr(IDirect3DDevice2.Hook("EndScene"))
	
	if g_globals.config.TextSwap 
		initTextSwapHooks2(g_globals.config.TextSwap)
	if g_globals.config.hiRes
		initHighResHooks2()		
}
else if (g_globals.config.d3D = "3")
{
	logErr(getDirect3D3("", "Direct3D HAL"))	
	logErr(IDirectDraw4.Hook("CreateSurface"))
	logErr(IDirect3DDevice3.Hook("EndScene"))	
	if g_globals.config.TextSwap 
		initTextSwapHooks2Device3(g_globals.config.TextSwap)
	if g_globals.config.hiRes
		initHighResHooks3()
}
else if (g_globals.config.d3D = "7")
{
	logErr(getDirect3D7("", "Direct3D HAL"))	
	logErr(IDirectDraw7.Hook("CreateSurface"))
	logErr(IDirect3DDevice7.Hook("EndScene"))
	if g_globals.config.TextSwap 
		initTextSwapHooks7(g_globals.config.TextSwap)
	if g_globals.config.hiRes
		initHighResHooks7()
	if g_globals.config.TextSwap or g_globals.config.hiRes
	{
		logErr(IDirectDrawSurface7.hook("Unlock"))	
		logErr(IDirectDrawSurface7.hook("blt"))		
	}	
}
else if g_globals.config.upScale
{
	err := getDirectDraw4()
	err ? logerr(err)
	/* On win 10, Dark Earth and LoK:Blood Omen (or maybe the system?) call
     * IDirectDraw::SetDisplayMode instead of IDirectDraw4::SetDisplayMode	 
	 */
	logErr(IDirectDraw4.hook("SetDisplayMode"))
	logErr(IDirectDraw.hook("SetDisplayMode"))
	logErr(IDirectDraw.hook("CreateSurface"))
	logerr(IDirectDrawSurface.Hook("lock"))
	logerr(IDirectDrawSurface.Hook("Unlock"))	
}
if g_globals.config.8bitColorfix and not g_globals.config.hiRes and not g_globals.config.upScale {
	err := getDirectDraw4()
	err ? logerr(err)
	logErr(IDirectDraw4.hook("SetDisplayMode"))
}
if g_globals.config.ddraw and not g_globals.config.hiRes and not g_globals.config.upScale
    and not g_globals.config.8bitColorfix {
	err := getDirectDraw4()
	err ? logerr(err)	
}

logerr("DirectDrawCreate Hook: " InstallHook("DirectDrawCreate_hook", pDirectDrawCreate, "ddraw.dll", "DirectDrawCreate")  " <- 0 means no error")	
g_globals.pDirectDrawCreate := pDirectDrawCreate
logerr(IDirectDraw.Hook("QueryInterface"))

DirectDrawCreate_hook(p1, p2, p3)
{
	Critical	
	static pddraw2
	static flags := {DDCREATE_EMULATIONONLY : "DDCREATE_EMULATIONONLY", DDCREATE_HARDWAREONLY : "DDCREATE_HARDWAREONLY", 0 : "Default"}
	;logerr("Creating directdraw " flags[p1])
	r := dllcall(g_globals.pDirectDrawCreate, uint, p1, uint, p2, uint, p3)
	g_Globals.pIDirectDraw := numget(p2+0, "ptr")	
	
	pddraw2 ? dllcall(IDirectDraw2.Release, uint, pddraw2)	
	GUID_FromString(idd_ddraw2, ddraw.IID_IDirectDraw2)
	r := dllcall(IDirectDraw.QueryInterface, uint, g_Globals.pIDirectDraw
				                           , ptr, &idd_ddraw2, "ptr*", pddraw2, uint)
	g_Globals.pIDirectDraw2 := 	pddraw2								   
	return r
}

IDirectDraw_QueryInterface(p1, p2, p3)
{
	critical
	r := dllcall(IDirectDraw.QueryInterface, uint, p1, uint, p2, uint, p3)
	r ?: StringFromIID(p2) = ddraw.IID_IDirectDraw2 ? g_Globals.pIDirectDraw2 := numget(p3+0, "ptr")	
	return r	
}		

/* ========================================================================
 * =============================DirectX 2 and 3============================
 */
 
IDirect3DDevice_EndScene(p1)
{
	critical	
	r := dllcall(IDirect3DDevice.EndScene, uint, p1)
	if not g_globals.config.TextSwap 
		return r		
	
	static clr := 0x00ffffff		
	keyevent(g_textSwap.color_switch) ?	clr := cicleColor(clr)
	if keyevent(g_textSwap.switch)
		g_textSwap.search := (g_textSwap.search) & True ? False : True
	
	(g_textSwap.search) & True ? browseTextures(g_globals.RenderTarget, clr)	
	TextSwapUpdate(g_Globals.pIDirectDraw2)	
	return r
}

IDirectDrawSurface2_GetAttachedSurface(p1, p2, p3)
{
	r := dllcall(IDirectDrawSurface2.GetAttachedSurface, uint, p1, uint, p2, uint, p3)
	if numget(p2+0, "uint") & DDSCAPS_BACKBUFFER
		g_globals.RenderTarget := numget(p3+0, "uint")	
	return r
}

/* ========================================================================
 * =============================DirectX 2, 3 and 5=========================
 */
 
IDirectDraw2_CreateSurface(pIDirectDraw, pSurfaceDesc, ppSurface, pIUnknown)
{
	critical
	static SurfaceDesc 
	SurfaceDesc ?: SurfaceDesc := ddSurfaceDesc.clone()		
	SurfaceDesc[] := pSurfaceDesc 	
		
	if g_globals.config.hiRes and SurfaceDesc.dwWidth = g_globals.requested_res.w and SurfaceDesc.dwHeight = g_globals.requested_res.h 
	{		
		SurfaceDesc.dwWidth := g_globals.res.w
		SurfaceDesc.dwHeight := g_globals.res.h
	}		
		
	r := dllcall(IDirectDraw2.CreateSurface
	,uint, pIDirectDraw, uint, SurfaceDesc[]
	,uint, ppSurface, uint, pIUnknown, uint)
		
	if (SurfaceDesc.ddsCaps.dwCaps & DDSCAPS_PRIMARYSURFACE) and not r
	{
		g_Globals.pIDirectDraw2 := pIDirectDraw
		isobject(g_textSwap.dump) ?: LoadTextureDumps()
		printl("IDirectDraw2_CreateSurface " r  ":" ddraw.result[r . ""])				
	}	
	else if SurfaceDesc.ddsCaps.dwCaps & DDSCAPS_BACKBUFFER 
		g_globals.RenderTarget := numget(ppSurface+0, "uint")	
	return r
}
 
IDirectDraw_CreateSurface(pIDirectDraw, pSurfaceDesc, ppSurface, pIUnknown)
{
	critical
	static SurfaceDesc
	SurfaceDesc ?: SurfaceDesc := ddSurfaceDesc.clone()	
	SurfaceDesc[] := pSurfaceDesc 
	
	if g_globals.config.hiRes and SurfaceDesc.dwWidth = g_globals.requested_res.w and SurfaceDesc.dwHeight = g_globals.requested_res.h 
	{		
		SurfaceDesc.dwWidth := g_globals.res.w
		SurfaceDesc.dwHeight := g_globals.res.h
	}		
		
	r := dllcall(IDirectDraw.CreateSurface
	,uint, pIDirectDraw, uint, SurfaceDesc[]
	,uint, ppSurface, uint, pIUnknown, uint)
	
	if SurfaceDesc.ddsCaps.dwCaps & DDSCAPS_PRIMARYSURFACE and not r
	{
		printl("IDirectDraw_CreateSurface " r ":" ddraw.result[r . ""])
		g_Globals.pIDirectDraw := pIDirectDraw	
		isobject(g_textSwap.dump) ?: LoadTextureDumps()	
		
		/* On win 10 that can give us real access to the primary
		g_Globals.primary := numget(ppSurface+0, "uint")
		IDirectDrawSurface.PatchVtable("blt", numget(g_Globals.primary+0, "uint"))
		*/
		return r						
	}
	return r
}


/* ========================================================================
 * =============================DirectX 5 =================================
 */
 
IDirect3DDevice2_EndScene(p1)
{
	critical
	(g_globals.RenderTarget) ? dllcall(IDirectDrawSurface.release, uint, g_globals.RenderTarget)
	dllcall(IDirect3DDevice2.GetRenderTarget, uint, p1, "uint*", pBackbuffer)
	g_globals.RenderTarget := pBackbuffer	
	
	r := dllcall(IDirect3DDevice2.EndScene, uint, p1)	
	if not g_globals.config.TextSwap 
		return r
	
	static clr := 0x00ffffff			
	keyevent(g_textSwap.color_switch) ?	clr := cicleColor(clr)
	if keyevent(g_textSwap.switch)
		g_textSwap.search := (g_textSwap.search) & True ? False : True
	
	(g_textSwap.search) & True ? browseTextures2(g_globals.RenderTarget, clr)	
	TextSwapUpdate2(g_Globals.pIDirectDraw)	
	return r
}

/* ========================================================================
 * =============================DirectX 6 =================================
 */

IDirectDraw4_CreateSurface(pIDirectDraw4, pSurfaceDesc, ppSurface, pIUnknown)
{
	critical
	static pddraw, SurfaceDesc 
	SurfaceDesc ?: SurfaceDesc := ddSurfaceDesc2.clone()		
	SurfaceDesc[] := pSurfaceDesc 	
	
	if g_globals.config.hiRes and SurfaceDesc.dwWidth = g_globals.requested_res.w and SurfaceDesc.dwHeight := g_globals.requested_res.h 
	{		
		SurfaceDesc.dwWidth := g_globals.res.w
		SurfaceDesc.dwHeight := g_globals.res.h
	}		
		
	r := dllcall(IDirectDraw4.CreateSurface
	,uint, pIDirectDraw4, uint, SurfaceDesc[]
	,uint, ppSurface, uint, pIUnknown, uint)
	
	if SurfaceDesc.ddsCaps.dwCaps & DDSCAPS_PRIMARYSURFACE
	{
		isobject(g_textSwap.dump) ?: LoadTextureDumps()	
		printl("IDirectDraw4_CreateSurface" r  ":" ddraw.result[r . ""])
		
		if pddraw
			dllcall(IDirectDraw.release, uint, pddraw)
						
		GUID_FromString(idd_ddraw, ddraw.IID_IDirectDraw)
		; crashes soul reaver on win 7
		q := dllcall(IDirectDraw4.QueryInterface, uint, pIDirectDraw4, uint, &idd_ddraw, "uint*", pddraw, uint)
		printl("Query DirectDraw " q  ":" ddraw.result[q . ""])
		g_Globals.pIDirectDraw := pddraw		
	}
	return r
}

IDirect3DDevice3_EndScene(p1)
{
	critical
	(g_globals.RenderTarget) ? dllcall(IDirectDrawSurface4.release, uint, g_globals.RenderTarget)
	dllcall(IDirect3DDevice3.GetRenderTarget, uint, p1, "uint*", pBackbuffer)
	g_globals.RenderTarget := pBackbuffer			
	
	r := dllcall(IDirect3DDevice3.EndScene, uint, p1)	
	if not g_globals.config.TextSwap 
		return r
	
	static clr := 0x00ffffff			
	keyevent(g_textSwap.color_switch) ?	clr := cicleColor(clr)
	if keyevent(g_textSwap.switch)
		g_textSwap.search := (g_textSwap.search) & True ? False : True
	
	(g_textSwap.search) & True ? (g_textSwap.useDC) & True 
	? browseTextures2DC(g_globals.RenderTarget, clr) : browseDevice3Textures2(g_globals.RenderTarget, g_Globals.pIDirectDraw, clr)	
	(g_textSwap.altSwap) & True ?: TextSwapUpdate2Device3(g_Globals.pIDirectDraw)		
	return r
}

/* ========================================================================
 * =============================DirectX 7 =================================
 */

IDirectDraw7_CreateSurface(pIDirectDraw7, pSurfaceDesc, ppSurface, pIUnknown)
{
	critical
	static pddraw, SurfaceDesc 
	SurfaceDesc ?: SurfaceDesc := ddSurfaceDesc.clone()		
	SurfaceDesc[] := pSurfaceDesc 	
	
	SurfaceDesc.ddsCaps.dwCaps & DDSCAPS_TEXTURE ? Texture := True
	if g_globals.config.hiRes and SurfaceDesc.dwWidth = g_globals.requested_res.w and SurfaceDesc.dwHeight := g_globals.requested_res.h 
	{		
		SurfaceDesc.dwWidth := g_globals.res.w
		SurfaceDesc.dwHeight := g_globals.res.h
		Texture := false
	}		
	
	r := dllcall(IDirectDraw7.CreateSurface
	,uint, pIDirectDraw7, uint, SurfaceDesc[]
	,uint, ppSurface, uint, pIUnknown, uint)
	
	if Texture and g_globals.config.TextSwap
	{
		pSurface := numget(ppSurface + 0, "uint") . "*"
		if isobject(g_textSwap.surfaces7[pSurface]) 
			return r
		g_textSwap.surfaces7[pSurface] := {"p" : pSurface, "r" : pSurface, "Tested" : False}
		g_textSwap.indexedSurfaces7 := []	
		for k, v in g_textSwap.surfaces7
			g_textSwap.indexedSurfaces7.insert(v.p)
	}
	
	if SurfaceDesc.ddsCaps.dwCaps & DDSCAPS_PRIMARYSURFACE
	{
		isobject(g_textSwap.dump) ?: LoadTextureDumps()	
		g_Globals.pIDirectDraw7 := pIDirectDraw7
		
		if pddraw
			dllcall(IDirectDraw.release, uint, pddraw)
										
		GUID_FromString(idd_ddraw, ddraw.IID_IDirectDraw)
		dllcall(IDirectDraw7.QueryInterface, uint, pIDirectDraw4, uint, &idd_ddraw, "uint*", pddraw, uint)
		g_Globals.pIDirectDraw := pddraw		
	}
	return r
}

IDirect3DDevice7_EndScene(p1)
{
	critical
	(g_globals.RenderTarget) ? dllcall(IDirectDrawSurface7.release, uint, g_globals.RenderTarget)
	dllcall(IDirect3DDevice7.GetRenderTarget, uint, p1, "uint*", pBackbuffer)
	g_globals.RenderTarget := pBackbuffer	
	
	r := dllcall(IDirect3DDevice7.EndScene, uint, p1)
    if not g_globals.config.TextSwap 
		return r	
	
	static clr := 0x00ffffff			
	keyevent(g_textSwap.color_switch) ?	clr := cicleColor(clr)
	if keyevent(g_textSwap.switch)
		g_textSwap.search := (g_textSwap.search) & True ? False : True
	
	(g_textSwap.search) & True ? browseTextures7(g_globals.RenderTarget, clr)	
	return r
}

IDirectDrawSurface7_Unlock(p1, p2)
{
	Critical
	isobject(g_textSwap.surfaces7[p1 . "*"]) ? g_textSwap.surfaces7[p1 . "*"].tested := False
	r := dllcall(IDirectDrawSurface7.Unlock, uint, p1, uint, p2)
	return r
}

IDirectDrawSurface7_Blt(p1, p2, p3, p4, p5, p6)
{
	Critical
	isobject(g_textSwap.surfaces7[p1 . "*"]) ? g_textSwap.surfaces7[p1 . "*"].tested := False
	r := dllcall(IDirectDrawSurface7.Blt, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6)
	return r
}