IDirect3DTexture_GetHandle(p1, p2, p3)
{
	critical	
	g_textSwap.device := p2
	r := dllcall(IDirect3DTexture.GetHandle, uint, p1, uint, p2, uint, p3, uint)
	g_textSwap.textures[p1 . "*"].pHwnd := p3	
	g_textSwap.ppHnds[p1 . "*"] := p3	
	return r
}	

IDirectDrawSurface2_QueryInterface(p1, p2, p3)
{
	critical	
	r := dllcall(IDirectDrawSurface2.QueryInterface, uint, p1, uint, p2, uint, p3, uint)
	GUID := StringFromIID(p2)	
	if (GUID = d3d.IID_IDirect3DTexture)
	{
		pTexture := numget(p3 + 0, "uint") . "*"
		if isobject(g_textSwap.textures[pTexture]) 
			return r
		g_textSwap.ppHnds[p1 . "*"] := ""
		g_textSwap.textures[pTexture] := {}
		g_textSwap.textures[pTexture].pTexture := numget(p3 + 0, "uint")
		g_textSwap.textures[pTexture].pSurface := p1
		g_textSwap.indexedSurfaces := []	
		for k, v in g_textSwap.textures
			g_textSwap.indexedSurfaces.insert(v.pSurface)
	}
	else if (GUID = d3d.IID_IDirect3DHALDevice) ;or (GUID = d3d.IID_IDirect3DRGBDevice)
			g_textSwap.RenderTarget := p1		;or (GUID = d3d.IID_IDirect3DRampDevice)						
	return r
}	

IDirect3DTexture_Release(p1)
{
	critical	
	if  g_textSwap.textures[p1 . "*"].rTexture {
	dllcall(IDirect3DTexture.release, uint, g_textSwap.textures[p1 . "*"].rTexture)
	dllcall(IDirectDrawSurface2.release, uint, g_textSwap.textures[p1 . "*"].rSurface)
	}	
	g_textSwap.textures.remove(p1 . "*")
	g_textSwap.ppHnds.remove(p1 . "*")
	g_textSwap.indexedSurfaces := []	
	for k, v in g_textSwap.textures
		g_textSwap.indexedSurfaces.insert(v.pSurface)	
	r := dllcall(IDirect3DTexture.Release, uint, p1, uint)		
	return r	
}	

IDirect3DTexture2_GetHandle(p1, p2, p3)
{
	critical
	g_textSwap.device := p2
	r := dllcall(IDirect3DTexture2.GetHandle, uint, p1, uint, p2, uint, p3, uint)
	g_textSwap.textures2[p1 . "*"].pHwnd := p3	
	g_textSwap.ppHnds2[p1 . "*"] := p3	
	return r
}	

IDirectDrawSurface_QueryInterface(p1, p2, p3)
{
	critical	
	r := dllcall(IDirectDrawSurface.QueryInterface, uint, p1, uint, p2, uint, p3, uint)		
	if (StringFromIID(p2) = d3d.IID_IDirect3DTexture2)
	{
		pTexture := numget(p3 + 0, "uint") . "*"
		if isobject(g_textSwap.textures2[pTexture]) 
			return r
		g_textSwap.ppHnds2[pTexture] := p1
		g_textSwap.textures2[pTexture] := {}
		g_textSwap.textures2[pTexture].pTexture := numget(p3 + 0, "uint")
		g_textSwap.textures2[pTexture].pSurface := p1
		g_textSwap.textures2[pTexture].pReplace := numget(p3 + 0, "uint")
		g_textSwap.indexedSurfaces2 := []	
		for k, v in g_textSwap.textures2
			g_textSwap.indexedSurfaces2.insert(v.pSurface)
	}	
	return r
}	

IDirect3DDevice3_SetTexture(p1, p2, p3)
{
	Critical
	static desc, Tag		
	if not desc {
		desc := ddSurfaceDesc.clone()
		desc.dwSize := desc.size()
	}
	
	k := p3 . "*"	
	if g_textSwap.altSwap and g_textSwap.ppHnds2[k]
	{		
		dllcall(IDirectDrawSurface.Lock, uint, g_textSwap.textures2[k].pSurface, uint, 0, uint, desc[], uint, DDLOCK_READONLY, uint, 0, uint)
		for kk, vv in g_textSwap.dumps 
		{
			samples := vv.optimized && True ? vv.samples : g_textSwap.samples			
			if not compareSurfaceData(vv, desc, samples, vv.optimized) 
				continue
			
			printl("alt updating texture")			
			if fileexist(vv.replacement) 
			{
				LoadTexture2(g_Globals.pIDirectDraw, g_textSwap.device, g_textSwap.dumps[kk].replacement, g_textSwap.textures2[k])				
				g_textSwap.textures2[k].pReplace := g_textSwap.textures2[k].rTexture							
			}
			else g_textSwap.textures2[k].pReplace := 0	
			g_textSwap.ppHnds2.remove(k)		
		}		
		dllcall(IDirectDrawSurface.UnLock, uint, g_textSwap.textures2[k].pSurface, uint)
	}
	
	if dllcall(IDirectDrawSurface.IsLost, uint, g_textSwap.textures2[p3 . "*"].rSurface, uint) = DDERR_SURFACELOST 
	{
		g_textSwap.ppHnds2[p3 . "*"] := g_textSwap.textures2[p3 . "*"].rSurface
		g_textSwap.textures2[p3 . "*"].pReplace := g_textSwap.textures2[p3 . "*"].pTexture
	}
	r := dllcall(IDirect3DDevice3.SetTexture, uint, p1, uint, p2, uint, g_textSwap.textures2[p3 . "*"].pReplace)
	return r
}	

IDirect3DTexture2_Release(p1)
{
	critical	
	if  g_textSwap.textures2[p1 . "*"].rTexture {
	dllcall(IDirect3DTexture2.release, uint, g_textSwap.textures2[p1 . "*"].rTexture)
	dllcall(IDirectDrawSurface.release, uint, g_textSwap.textures2[p1 . "*"].rSurface)
	}
	g_textSwap.textures2.remove(p1 . "*")
	g_textSwap.ppHnds2.remove(p1 . "*")
	g_textSwap.indexedSurfaces2 := []	
	for k, v in g_textSwap.textures2
		g_textSwap.indexedSurfaces2.insert(v.pSurface)	
	r := dllcall(IDirect3DTexture2.Release, uint, p1, uint)		
	return r	
}

UpdateSurface7(k)
{
	static desc		
	if not desc {
		desc := ddSurfaceDesc2.clone()
		desc.dwSize := desc.size()
	}
	
	if g_textSwap.surfaces7[k].r and g_textSwap.surfaces7[k].r != g_textSwap.surfaces7[k].p
		printl("Texture reused " dllcall(IDirectDrawSurface7.Release, uint, g_textSwap.surfaces7[k].r))
	g_textSwap.surfaces7[k].r := g_textSwap.surfaces7[k].p
	
	dllcall(IDirectDrawSurface7.Lock, uint, g_textSwap.surfaces7[k].p, uint, 0, uint, desc[], uint, DDLOCK_READONLY, uint, 0, uint)
	for kk, vv in g_textSwap.dumps 
	{
		samples := vv.optimized && True ? vv.samples : g_textSwap.samples			
		if not compareSurfaceData(vv, desc, samples, vv.optimized) 
			continue
			
		printl("updating texture")			
		if fileexist(vv.replacement) 
			g_textSwap.surfaces7[k].r := LoadSurface7(g_Globals.pIDirectDraw7, g_textSwap.dumps[kk].replacement)						
		else g_textSwap.surfaces7[k].r := 0					
	}		
	dllcall(IDirectDrawSurface7.UnLock, uint, g_textSwap.surfaces7[k].p, uint)
}

IDirect3DDevice7_SetTexture(p1, p2, p3)
{
	Critical		
	k := p3 . "*"	
	if (g_textSwap.surfaces7[k].Tested = False)
	{
		UpdateSurface7(k)
		g_textSwap.surfaces7[k].Tested := True
	}
	r := dllcall(IDirect3DDevice7.SetTexture, uint, p1, uint, p2, uint, g_textSwap.surfaces7[k].r)	
	return r
}

IDirectDrawSurface7_Release(p1)
{
	Critical
	r := dllcall(IDirectDrawSurface7.Release, uint, p1)
	if g_textSwap.surfaces7[p1 . "*"].r and g_textSwap.surfaces7[p1 . "*"].r != g_textSwap.surfaces7[p1 . "*"].p 
		printl("releasing replacement " dllcall(IDirectDrawSurface7.Release, uint, g_textSwap.surfaces7[p1 . "*"].r))	
	g_textSwap.surfaces7.remove(p1 . "*")
	g_textSwap.indexedSurfaces7 := []	
	for k, v in g_textSwap.surfaces7
		g_textSwap.indexedSurfaces7.insert(v.p)	
	return r	
}	

IDirect3DDevice7_Load(p1, p2, p3, p4, p5, p6)
{
	Critical
	r := dllcall(IDirect3DDevice7.Load, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6)
	g_textSwap.surfaces7[p2 . "*"].Tested := False		
	return r
}
	
