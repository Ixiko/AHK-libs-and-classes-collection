#include <DirectX\lib\texSwap\TextureHooks>
global g_textSwap := {}

initTextSwapHooks(byref config)
{
	g_textSwap.textures := {}
	g_textSwap.ppHnds := {}
	g_textSwap.indexedSurfaces := []
	logErr(IDirect3DTexture.hook("GetHandle"))
	logErr(IDirect3DTexture.hook("Release"))
	logErr(IDirectDrawSurface2.hook("QueryInterface")) 
	initTextSwapConfig(config)		
}	

initTextSwapHooks2(byref config)
{
	g_textSwap.textures2 := {}
	g_textSwap.ppHnds2 := {}
	g_textSwap.indexedSurfaces2 := []	
	logErr(IDirectDrawSurface.hook("QueryInterface"))
	logErr(IDirect3DTexture2.hook("GetHandle"))
	logErr(IDirect3DTexture2.hook("Release"))	
	initTextSwapConfig(config)	
}

initTextSwapHooks2Device3(byref config)
{
	initTextSwapHooks2(config)
	logErr(IDirect3DDevice3.hook("SetTexture"))
	;g_textSwap.pEnumsurfaces_callback := RegisterCallback("enumsurfacesCallback", "F")	
}

initTextSwapHooks7(byref config)
{
	g_textSwap.surfaces7 := {}
	g_textSwap.uncheked := {}
	g_textSwap.indexedSurfaces7 := []	
	initTextSwapConfig(config)
	logErr(IDirect3DDevice7.hook("SetTexture"))
	logErr(IDirect3DDevice7.hook("Load"))		
	logErr(IDirectDrawSurface7.hook("Release"))		
}

initTextSwapConfig(byref config)
{
	g_textSwap := parseConfig(config)
	g_textSwap.bltsz := g_textSwap.thumbnail 
	g_textSwap.search := False
	if not g_textSwap.path
		return
	for k, v in ["Dumps", "Replacements"] {
		if not fileexist(g_textSwap.path "\" v) {
			path := g_textSwap.path
			FileCreateDir, %path%\%v%
			}
		}
}	

browseTextures(pBackbuffer, clr = 0x00000000)
{
	static lRECT, lDDBLTFX, currentindex
	if not isobject(lRECT) 
	{
		currentindex := 1
		lDDBLTFX := DDBLTFX.clone()
		lDDBLTFX.dwsize := lDDBLTFX.size()
		lRECT := RECT.clone()
		lRECT.top := 0,	lRECT.left := 0
		lRECT.right := g_textSwap.bltsz, lRECT.bottom := g_textSwap.bltsz
	}	
	
	_func := getkeystate(g_textSwap.quick) ? "getkeystate" : "keyevent"
		
	if %_func%(g_textSwap.next) 
		currentindex += 1
	else if %_func%(g_textSwap.prev) 
		currentindex -= 1
	else if keyevent(g_textSwap.dump)
	{
		n := 0
		file := "dump" n ".dds"
		while fileexist(g_textSwap.path "\dumps\" file) {
			n += 1
			file := "dump" n ".dds"
		} 
		dumpSurface(g_textSwap.indexedSurfaces[currentindex], g_textSwap.path "\dumps\" file)
		soundplay, *64
	}	
			
	if (currentindex >  g_textSwap.indexedSurfaces._MaxIndex())
		currentindex := 1
	
	if (currentindex < 1 )
		currentindex := g_textSwap.indexedSurfaces._MaxIndex() 
	
	blt := dllcall(IDirectDrawSurface2.Blt, uint, pBackbuffer
	, uint, lRECT[]
	, uint, g_textSwap.indexedSurfaces[currentindex]
	, uint, 0
	, uint, DDBLTFAST_NOCOLORKEY
	, uint, lDDBLTFX[]
	, uint)		
	
	return g_textSwap.bltsz + writeOnSurface(pBackbuffer
	, g_textSwap.indexedSurfaces._MaxIndex() " textures`ncurrent texture: " currentindex " " blt " " ddraw.result[blt . ""]
	, clr, 0, g_textSwap.bltsz)
}

browseTextures2(pBackbuffer, clr = 0x00000000)
{
	static lRECT, lDDBLTFX, currentindex
	if not isobject(lRECT) 
	{
		currentindex := 1
		lDDBLTFX := DDBLTFX.clone()
		lDDBLTFX.dwsize := lDDBLTFX.size()
		lRECT := RECT.clone()
		lRECT.top := 0,	lRECT.left := 0
		lRECT.right := g_textSwap.bltsz, lRECT.bottom := g_textSwap.bltsz
	}
	
	_func := getkeystate(g_textSwap.quick) ? "getkeystate" : "keyevent"
		
	if %_func%(g_textSwap.next) 
		currentindex += 1
	else if %_func%(g_textSwap.prev) 
		currentindex -= 1
	else if keyevent(g_textSwap.dump)
	{
		n := 0
		file := "dump" n ".dds"
		while fileexist(g_textSwap.path "\dumps\" file) {
			n += 1
			file := "dump" n ".dds"
		} dumpSurface(g_textSwap.indexedSurfaces2[currentindex], g_textSwap.path "\dumps\" file)
		soundplay, *64
	}	
			
	if (currentindex >  g_textSwap.indexedSurfaces2._MaxIndex())
		currentindex := 1
	
	if (currentindex < 1 )
		currentindex := g_textSwap.indexedSurfaces2._MaxIndex() 
	
	blt := dllcall(IDirectDrawSurface.Blt, uint, pBackbuffer
	, uint, lRECT[]
	, uint, g_textSwap.indexedSurfaces2[currentindex]
	, uint, 0
	, uint, DDBLTFAST_NOCOLORKEY | DDBLT_WAIT 
	, uint, lDDBLTFX[]
	, uint)	
	
	return g_textSwap.bltsz + writeOnSurface(pBackbuffer
	, g_textSwap.indexedSurfaces2._MaxIndex() " textures`ncurrent texture: " currentindex " " blt " " ddraw.result[blt . ""]
	, clr, 0, g_textSwap.bltsz)	 
}

browseDevice3Textures2(pBackbuffer, pddraw, clr = 0x00FFFFFF)
{
	static SurfaceDesc
	SurfaceDesc ?: SurfaceDesc := ddSurfaceDesc.clone()	
	SurfaceDesc.dwSize := SurfaceDesc.size()
	
	static lRECT, lDDBLTFX, currentindex
	if not isobject(lRECT) 
	{
		currentindex := 1
		lDDBLTFX := DDBLTFX.clone()
		lDDBLTFX.dwsize := lDDBLTFX.size()
		lRECT := RECT.clone()
		lRECT.top := 0,	lRECT.left := 0
		lRECT.right := g_textSwap.bltsz, lRECT.bottom := g_textSwap.bltsz
	}
	
	GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface)
	dllcall(IDirectDrawSurface4.QueryInterface, uint, pBackbuffer, uint, &idd_surface, "uint*", pSurface, uint)
	
	dllcall(IDirectDrawSurface.GetSurfaceDesc, uint, g_textSwap.indexedSurfaces2[currentindex], uint, SurfaceDesc[], uint)
	SurfaceDesc.dwFlags := DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH 
	SurfaceDesc.ddsCaps.dwCaps := 0	
	dllcall(IDirectDraw.CreateSurface, uint, pddraw, uint, SurfaceDesc[], "uint*", pTempSurface, uint, 0)
			
	_func := getkeystate(g_textSwap.quick) ? "getkeystate" : "keyevent"
		
	if %_func%(g_textSwap.next) 
		currentindex += 1
	else if %_func%(g_textSwap.prev) 
		currentindex -= 1
	else if keyevent(g_textSwap.dump)
	{
		n := 0
		file := "dump" n ".dds"
		while fileexist(g_textSwap.path "\dumps\" file) {
			n += 1
			file := "dump" n ".dds"
		} dumpSurface(g_textSwap.indexedSurfaces2[currentindex], g_textSwap.path "\dumps\" file)
		soundplay, *64
	}	
			
	if (currentindex >  g_textSwap.indexedSurfaces2._MaxIndex())
		currentindex := 1
	
	if (currentindex < 1 )
		currentindex := g_textSwap.indexedSurfaces2._MaxIndex() 
	
	dllcall(IDirectDrawSurface.GetDC, uint, pTempSurface, "uint*", dDC)
	dllcall(IDirectDrawSurface.GetDC, uint, g_textSwap.indexedSurfaces2[currentindex], "uint*", sDC)
	
	DllCall("Gdi32.dll\BitBlt", int, dDC, int, 0, int, 0, int, SurfaceDesc.dwWidth, int, SurfaceDesc.dwHeight
					          , int, sDC, int, 0, int, 0, uint,  0x00CC0020)								  
	
	dllcall(IDirectDrawSurface.releaseDC, uint, pTempSurface, uint, dDC, uint)
	dllcall(IDirectDrawSurface.releaseDC, uint, g_textSwap.indexedSurfaces2[currentindex], uint, sDC, uint)	
	
	blt := dllcall(IDirectDrawSurface.Blt, uint, pSurface
	, uint, lRECT[]
	, uint, pTempSurface
	, uint, 0
	, uint, DDBLTFAST_NOCOLORKEY | DDBLT_WAIT 
	, uint, lDDBLTFX[]
	, uint)	

	blt ? printl("blt " blt ddraw.result[blt . ""]  g_textSwap.bltsz)
		
	r := writeOnSurface(pSurface, g_textSwap.indexedSurfaces2._MaxIndex() " textures`ncurrent texture: " . currentindex 
	. " size"  SurfaceDesc.dwWidth " " SurfaceDesc.dwHeight " " blt " " ddraw.result[blt . ""] 
	, clr, 0, g_textSwap.bltsz)	+ g_textSwap.bltsz
	
	dllcall(IDirectDrawSurface.release, uint, pSurface)
	dllcall(IDirectDrawSurface.release, uint, pTempSurface)
	return r  
	
}

browseTextures2DC(pBackbuffer, clr = 0x00FFFFFF)
{
	static currentindex, SurfaceDesc
	SurfaceDesc ?: SurfaceDesc := ddSurfaceDesc.clone()	
	SurfaceDesc.dwSize := SurfaceDesc.size()
	
	GUID_FromString(idd_surface, ddraw.IID_IDirectDrawSurface)
	dllcall(IDirectDrawSurface4.QueryInterface, uint, pBackbuffer, uint, &idd_surface, "uint*", pSurface, uint)
				
	_func := getkeystate(g_textSwap.quick) ? "getkeystate" : "keyevent"
		
	if %_func%(g_textSwap.next) 
		currentindex += 1
	else if %_func%(g_textSwap.prev) 
		currentindex -= 1
	else if keyevent(g_textSwap.dump)
	{
		n := 0
		file := "dump" n ".dds"
		while fileexist(g_textSwap.path "\dumps\" file) {
			n += 1
			file := "dump" n ".dds"
		} dumpSurface(g_textSwap.indexedSurfaces2[currentindex], g_textSwap.path "\dumps\" file)
		soundplay, *64
		return
	}	
			
	if (currentindex >  g_textSwap.indexedSurfaces2._MaxIndex())
		currentindex := 1
	
	if (currentindex < 1 )
		currentindex := g_textSwap.indexedSurfaces2._MaxIndex() 
	
	; Surfaces blt, but textures don't, so we use a device context	 
	dllcall(IDirectDrawSurface.GetSurfaceDesc, uint, g_textSwap.indexedSurfaces2[currentindex], uint, SurfaceDesc[], uint)	
	dllcall(IDirectDrawSurface4.GetDC, uint, pBackbuffer, "uint*", dDC)
	dllcall(IDirectDrawSurface.GetDC, uint, g_textSwap.indexedSurfaces2[currentindex], "uint*", sDC)
	
	;printl("DC blt "DllCall("Gdi32.dll\BitBlt", int, dDC, int, 0, int, 0, int, g_textSwap.bltsz, int, g_textSwap.bltsz
					                          ;, int, sDC, int, 0, int, 0, uint,  0x00CC0020))											  
	
	DllCall("Gdi32.dll\StretchBlt" , int, dDC, int, 0, int, 0, int, g_textSwap.bltsz, int, g_textSwap.bltsz
					               , int, sDC, int, 0, int, 0, int, SurfaceDesc.dwWidth, int, SurfaceDesc.dwHeight
								   , uint,  0x00CC0020)											  
	
	dllcall(IDirectDrawSurface4.releaseDC, uint, pBackbuffer, uint, dDC, uint)
	dllcall(IDirectDrawSurface.releaseDC, uint, g_textSwap.indexedSurfaces2[currentindex], uint, sDC, uint)
	
	writeOnSurface(pSurface
	, g_textSwap.indexedSurfaces2._MaxIndex() " textures`ncurrent texture: " currentindex " size " SurfaceDesc.dwWidth " " SurfaceDesc.dwHeight
	, clr, 0, g_textSwap.bltsz)	 
	
	dllcall(IDirectDrawSurface.release, uint, pSurface)
	return r
}	

browseTextures7(pBackbuffer, clr = 0x00000000)
{
	static lRECT, lDDBLTFX, currentindex
	if not isobject(lRECT) 
	{
		currentindex := 1
		lDDBLTFX := DDBLTFX.clone()
		lDDBLTFX.dwsize := lDDBLTFX.size()
		lRECT := RECT.clone()
		lRECT.top := 0,	lRECT.left := 0
		lRECT.right := g_textSwap.bltsz, lRECT.bottom := g_textSwap.bltsz
	}
	
	_func := getkeystate(g_textSwap.quick) ? "getkeystate" : "keyevent"
		
	if %_func%(g_textSwap.next) 
		currentindex += 1
	else if %_func%(g_textSwap.prev) 
		currentindex -= 1
	else if keyevent(g_textSwap.dump)
	{
		n := 0
		file := "dump" n ".dds"
		while fileexist(g_textSwap.path "\dumps\" file) {
			n += 1
			file := "dump" n ".dds"
		}
		GUID_FromString(idd_surf, ddraw.IID_IDirectDrawSurface)
		dllcall(IDirectDrawSurface7.QueryInterface, uint, g_textSwap.indexedSurfaces7[currentindex], uint, &idd_surf, "uint*", pSurface)
		dumpSurface(pSurface, g_textSwap.path "\dumps\" file)
		dllcall(IDirectDrawSurface.Release, uint, pSurface)
		soundplay, *64
	}	
			
	if (currentindex >  g_textSwap.indexedSurfaces7._MaxIndex())
		currentindex := 1
	
	if (currentindex < 1 )
		currentindex := g_textSwap.indexedSurfaces7._MaxIndex() 
	
	blt := dllcall(IDirectDrawSurface7.Blt, uint, pBackbuffer
	, uint, lRECT[]
	, uint, g_textSwap.indexedSurfaces7[currentindex]
	, uint, 0
	, uint, DDBLTFAST_NOCOLORKEY | DDBLT_WAIT 
	, uint, lDDBLTFX[]
	, uint)	

	return g_textSwap.bltsz + writeOnSurface(pBackbuffer
	, g_textSwap.indexedSurfaces7._MaxIndex() " textures`ncurrent texture: " currentindex " " blt " " ddraw.result[blt . ""]
	, clr, 0, g_textSwap.bltsz)	 
}

TextSwapUpdate2Device3(pIDirectDraw)
{
	critical
	static desc, Tag
		
	if not desc {
		desc := ddSurfaceDesc.clone()
		desc.dwSize := desc.size()
	}
	
	if Tag
	{
		LoadTexture2(pIDirectDraw, g_textSwap.device, g_textSwap.dumps[Tag[2]].replacement, g_textSwap.textures2[Tag[1]])				
		g_textSwap.textures2[Tag[1]].pReplace := g_textSwap.textures2[Tag[1]].rTexture
		g_textSwap.ppHnds2.remove(Tag[1])
		Tag := ""
		return
	}	
		
	;printl("`nSearching textures")
	for k, v in g_textSwap.ppHnds2 
	{
		if not g_textSwap.textures2[k].pSurface
			continue
		
		r := dllcall(IDirectDrawSurface.Lock, uint, g_textSwap.textures2[k].pSurface, uint, 0, uint, desc[], uint, DDLOCK_READONLY, uint, 0, uint)
		for kk, vv in g_textSwap.dumps 
		{
			samples := vv.optimized && True ? vv.samples : g_textSwap.samples					
			
			if not compareSurfaceData(vv, desc, samples, vv.optimized) 
				continue
			
			printl("updating texture")			
			fileexist(vv.replacement) ? Tag := [k, kk] : g_textSwap.textures2[k].pReplace := 0					
		}
		
		dllcall(IDirectDrawSurface.UnLock, uint, g_textSwap.textures2[k].pSurface, uint)
		Tag ?: g_textSwap.ppHnds2.remove(k)			
		break		
	} ;printl("Finished searching  textures `n")	
	return 	
}	

TextSwapUpdate2(pIDirectDraw)
{
	critical
	static desc, Tag
		
	if not desc {
		desc := ddSurfaceDesc.clone()
		desc.dwSize := desc.size()
	}
	
	if Tag
	{
		LoadTexture2(pIDirectDraw, g_textSwap.device, g_textSwap.dumps[Tag[2]].replacement, g_textSwap.textures2[Tag[1]])				
		dllcall(IDirect3DDevice2.SwapTextureHandles, uint, g_textSwap.device, uint, g_textSwap.textures2[Tag[1]].rTexture
		, uint, g_textSwap.textures2[Tag[1]].pTexture)
		g_textSwap.ppHnds2.remove(Tag[1])
		Tag := ""
		return
	}	
		
	;printl("`nSearching textures")
	for k, v in g_textSwap.ppHnds2 
	{
		if not g_textSwap.textures2[k].pSurface
			continue
		
		dllcall(IDirectDrawSurface.Lock, uint, g_textSwap.textures2[k].pSurface, uint, 0, uint, desc[], uint, DDLOCK_READONLY, uint, 0, uint)	
		for kk, vv in g_textSwap.dumps 
		{
			samples := vv.optimized && True ? vv.samples : g_textSwap.samples					
			
			if not compareSurfaceData(vv, desc, samples, vv.optimized) 
				continue
			
			printl("updating texture")			
			fileexist(vv.replacement) ? Tag := [k, kk] : numput(0, v+0, "Uint")					
		}
		
		dllcall(IDirectDrawSurface.UnLock, uint, g_textSwap.textures2[k].pSurface, uint)
		Tag ?: g_textSwap.ppHnds2.remove(k)			
		break		
	} ;printl("Finished searching  textures `n")	
	return 	
}	

TextSwapUpdate(pIDirectDraw)
{
	critical
	static desc, Tag
	
	if not desc {
		desc := ddSurfaceDesc.clone()
		desc.dwSize := desc.size()
	}
	
	if Tag
	{
		LoadTexture(pIDirectDraw, g_textSwap.device, g_textSwap.dumps[Tag[2]].replacement, g_textSwap.textures[Tag[1]])				
		dllcall(IDirect3DDevice.SwapTextureHandles, uint, g_textSwap.device, uint, g_textSwap.textures[Tag[1]].rTexture
		, uint, g_textSwap.textures[Tag[1]].pTexture)
		g_textSwap.ppHnds.remove(Tag[1])
		Tag := ""
		return
	}	
		
	;printl("`nSearching textures")
	for k, v in g_textSwap.ppHnds
	{
		if not g_textSwap.textures[k].pSurface
			continue
		
		r := dllcall(IDirectDrawSurface2.Lock, uint, g_textSwap.textures[k].pSurface, uint, 0, uint, desc[], uint, DDLOCK_READONLY, uint, 0, uint)
				
		for kk, vv in g_textSwap.dumps 
		{
			samples := vv.optimized && True ? vv.samples : g_textSwap.samples
			if not compareSurfaceData(vv, desc, samples, vv.optimized) 
				continue			
			printl("updating texture")			
			fileexist(vv.replacement) ? Tag := [k, kk] : numput(0, v+0, "Uint")					
		}
		
		dllcall(IDirectDrawSurface2.UnLock, uint, g_textSwap.textures[k].pSurface, uint)
		Tag ?: g_textSwap.ppHnds.remove(k)			
		break		
	} ;printl("Finished searching  textures `n")	
}