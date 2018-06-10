CheckSurface(p1)
{	
	static surrogate, SurfaceDesc
	SurfaceDesc ?: (SurfaceDesc := ddSurfaceDesc.clone()).dwSize := ddSurfaceDesc.size()
	d := dllcall(IDirectDrawSurface.GetSurfaceDesc, uint, p1, uint, SurfaceDesc[])
	d ? printl("IDirectDrawSurface::GetSurfaceDesc Failed " d ddraw.result[d . ""])
		
	if ( (SurfaceDesc.dwWidth = g_globals.res.w) and (SurfaceDesc.dwheight = g_globals.res.h) )
	{
		; printl("surface " SurfaceDesc.ddsCaps.dwCaps " " DDSCAPS_PRIMARYSURFACE)
		; we check if the surface is lost, but even so we can't handle alt-tab on win 10 
		accquire :=  surrogate ? (release := dllcall(IDirectDrawSurface.IsLost, uint, surrogate)) : True
		if accquire	{
			release ? printl("releasing the old surrogate " dllcall(IDirectDrawSurface.release, uint, surrogate))
			printl("Creating the surrogate surface with " g_globals.requested_res.w "x" g_globals.requested_res.h)			
			SurfaceDesc.ddsCaps.dwCaps := DDSCAPS_OFFSCREENPLAIN 		
			SurfaceDesc.dwFlags := DDSD_HEIGHT | DDSD_WIDTH | DDSD_PIXELFORMAT | DDSD_CAPS	
			if isobject(g_globals.requested_res){
				SurfaceDesc.dwWidth := g_globals.requested_res.w 
				SurfaceDesc.dwHeight := g_globals.requested_res.h 
				} else {
					SurfaceDesc.dwWidth := 640
					SurfaceDesc.dwHeight := 480
				} z := dllcall(IDirectDraw.CreateSurface, uint, g_Globals.pIDirectDraw, uint, SurfaceDesc[], "uint*", pSurface, uint, 0, uint)
				printl("Surrogate surface: " z ddraw.result[z . ""])
				surrogate := pSurface		
		} RETURN surrogate 		
	} return p1
}		

IDirectDrawSurface_lock(p1, p2, p3, p4, p5)
{
	critical
	p1 := CheckSurface(p1)
	r := dllcall(IDirectDrawSurface.lock, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint)	
	return r
}	

IDirectDrawSurface_Unlock(p1, p2)
{
	critical
	surrogate := CheckSurface(p1) 	
	r := dllcall(IDirectDrawSurface.Unlock, uint, surrogate, uint, p2)	
	surrogate != p1
	? blt := dllcall(IDirectDrawSurface.blt, uint, p1, uint, _RECT[], uint, surrogate, uint, 0
										   , uint,  DDBLTFAST_NOCOLORKEY | DDBLT_WAIT, uint, 0, uint)										   
	return r
}	

/*
IDirectDrawSurface_Blt(p1, p2, p3, p4, p5, p6)
{
	Critical
	surrogate := CheckSurface(p1) 	
	r := dllcall(IDirectDrawSurface.blt, uint, surrogate, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6)
	if (surrogate != p1) {
	blt := dllcall(IDirectDrawSurface.blt, uint, p1, uint, _RECT[], uint, surrogate, uint, 0
										 , uint,  DDBLTFAST_NOCOLORKEY | DDBLT_WAIT, uint, 0)									 
	}									 
	return 0
}
 
IDirectDrawSurface2_Blt(p1, p2, p3, p4, p5, p6)
{
	critical
	GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface)
	z := dllcall(IDirectDrawSurface2.QueryInterface, uint, p1, uint, &idd_surface, "uint*", pp1, uint)
	t := dllcall(IDirectDrawSurface2.QueryInterface, uint, p3, uint, &idd_surface, "uint*", pp3, uint)
	;printl("query " z ddraw.result[z . ""] "-" t ddraw.result[t . ""] )
	r := IDirectDrawSurface_Blt(pp1, p2, pp3, p4, p5, p6)
	dllcall(IDirectdrawsurface.release, uint, pp1)
	dllcall(IDirectdrawsurface.release, uint, pp2)
	return r
}

IDirectDrawSurface3_blt(p1, p2, p3, p4, p5, p6)
{
	critical
	GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface)
	z := dllcall(IDirectDrawSurface3.QueryInterface, uint, p1, uint, &idd_surface, "uint*", pp1, uint)
	t := dllcall(IDirectDrawSurface3.QueryInterface, uint, p3, uint, &idd_surface, "uint*", pp3, uint)
	;printl("query " z ddraw.result[z . ""] "-" t ddraw.result[t . ""] )
	r := IDirectDrawSurface_Blt(pp1, p2, pp3, p4, p5, p6)
	dllcall(IDirectdrawsurface3.release, uint, pp1)
	dllcall(IDirectdrawsurface3.release, uint, pp2)
	return r		
}

IDirectDrawSurface4_blt(p1, p2, p3, p4, p5, p6)
{
	critical
	GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface)
	z := dllcall(IDirectDrawSurface4.QueryInterface, uint, p1, uint, &idd_surface, "uint*", pp1, uint)
	t := dllcall(IDirectDrawSurface4.QueryInterface, uint, p3, uint, &idd_surface, "uint*", pp3, uint)
	;printl("query " z ddraw.result[z . ""] "-" t ddraw.result[t . ""] )
	r := IDirectDrawSurface_Blt(pp1, p2, pp3, p4, p5, p6)
	dllcall(IDirectdrawsurface4.release, uint, pp1)
	dllcall(IDirectdrawsurface4.release, uint, pp2)
	return r		
}
*/