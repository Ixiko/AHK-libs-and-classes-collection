global g_textSwap := {}

InitTextSwapHooksGl(byref config)
{
	g_textSwap := parseConfig(config)
	path := g_textSwap.path
	for k, v in ["Dumps", "Replacements"] {
		if not path
			break
		if not fileexist(path "\" v)
			FileCreateDir, %path%\%v%			
		}
	
	g_textSwap.curent_color := [1., 1., 1.]	
	g_textSwap.GLTextures := {}
	g_textSwap.GLIndexedTextures := []
	g_textSwap.current_texture := ""
	InstallGlHook("glGenTextures")
	InstallGlHook("glDeleteTextures")
	InstallGlHook("glBindTexture")
	InstallGlHook("glTexImage2D")	
}

LoadTextureDumpsGl(path = "")
{
	g_textSwap.dumps := []
	if not path
		path := g_textSwap.path
	
	if fileexist(path "\Dumps\dump._dds")		
		g_textSwap.pDumpArray := loadCompiledDumpCollection(g_textSwap.path "\Dumps\dump._dds", g_textSwap.dumps)
	else 
		g_textSwap.pDumpArray := loadDumpCollection(g_textSwap.path "\Dumps", g_textSwap.dumps)	
				
	for kk, vv in g_textSwap.dumps {
		printl(vv.fname " " vv.bitdepth)
		if not vv.replacement
			vv.replacement := path "\Replacements\" vv.fname
		if (vv.bitdepth = 24)
			(vv.optimized) ? ChangeIndianess24(vv.w * vv.samples, vv.data) : ChangeIndianess24(vv.w * vv.h, vv.data)
		}			
}

BrowseTexturesGl()
{
	static currentindex
	
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
		for k, v in g_textSwap.GLTextures {
			if (k = g_textSwap.GLIndexedTextures[currentindex] . "*")
				dumpGlTexture(v, g_textSwap.path "\dumps\" file)
			}
	}			
				
	if (currentindex >  g_textSwap.GLIndexedTextures._MaxIndex())
		currentindex := 1
	
	if (currentindex < 1 )
		currentindex := g_textSwap.GLIndexedTextures._MaxIndex() 
	
	dllcall(gl.p.glGetIntegerv, uint, GL_TEXTURE_BINDING_2D, "uint*", current_texture)
	dllcall(gl.p.glBindTexture, uint, GL_TEXTURE_2D, uint, g_textSwap.GLIndexedTextures[currentindex])
	glDrawRect()
	glWrite("Texture" currentindex "\" g_textSwap.GLIndexedTextures._MaxIndex())
	dllcall(gl.p.glBindTexture, uint, GL_TEXTURE_2D, uint, current_texture)
}

ChangeIndianess24(n_pixels, pdata)
{
	static pixel24 := struct("BYTE r, BYTE g, BYTE b")
	pixel24[] := pdata
	loop % n_pixels
	{
		r := numget(pixel24[]+0, "char")
		b := numget(pixel24[]+2, "char")
		pixel24.r := b
		pixel24.b := r
		pixel24[] += 3
	}		
}	

dumpGlTexture(byref texture, file)
{
	printl("type: " gl.constant[texture.type ""] "  format: " gl.constant[texture.format ""] "-> " getPixelFormatGl(texture))
	printl(file " " texture.dwWidth "x" texture.dwHeight)
		
	pixelformat	:= getPixelFormatGl(texture)	
	if (pixelformat = "ABGR") or (pixelformat = "ARGB")
		memsize := 4 * texture.dwWidth * texture.dwHeight
	else if (pixelformat = "RGB24")
		memsize := 3 * texture.dwWidth * texture.dwHeight ;dumpAsBitmapGl(texture, file) ;
	else memsize := 2 * texture.dwWidth * texture.dwHeight 
		
	pdata := dllcall("VirtualAlloc", uint, 0, uint, memsize, "Int", 0x00001000 ;| 0x00002000
								   , uint, (PAGE_READWRITE := 0x04) )	
	
	
	dllcall(gl.p.glGetIntegerv, uint, GL_TEXTURE_BINDING_2D, "uint*", current_texture)
	dllcall(gl.p.glBindTexture, uint,GL_TEXTURE_2D, uint, texture.pTexture)							   
	dllcall(gl.p.glGetTexImage, uint, GL_TEXTURE_2D, uint, 0, uint, texture.format, uint, texture.type, uint, pdata)
	dllcall(gl.p.glBindTexture, uint, GL_TEXTURE_2D, uint, current_texture)
	
	if (pixelformat = "RGB24")
		ChangeIndianess24(texture.dwWidth * texture.dwHeight, pdata)
	
	Zeromem(DDS_HEADER)	
	DDS_HEADER.dwSize := DDS_HEADER.size()
	DDS_HEADER.dwFlags := 0x00000002 | 0x00000004 | 0x00001000 | 0x00000001 ;DDSD_HEIGHT | DDSD_WIDTH |  DDSD_PIXELFORMAT | DDSD_CAPS
		
	DDS_HEADER.dwWidth := texture.dwWidth
	DDS_HEADER.dwHeight := texture.dwHeight 
	DDS_HEADER.dwPitchOrLinearSize := memsize / texture.dwHeight
		
	DDS_HEADER.dwCaps := 0x00001000 ;DDSCAPS_TEXTURE
	DDS_PIXELFORMAT[] := DDS_HEADER.GetAddress("ddspf")
	setFilePixelFormat(pixelformat)			
		
	_file := FileOpen(file, "w")	
	VarSetCapacity(ddssig, 4)
	for k, v in [0x44, 0x44, 0x53, 0x20]		
		numput(v, &ddssig+A_index-1, "char")
	
	_file.RawWrite(&ddssig, 4)
	_file.RawWrite(DDS_HEADER[]+0, DDS_HEADER.size())	
	_file.RawWrite(pdata+0, memsize)
	
	dllcall("VirtualFree", uint, pdata, uint, 0, uint, (MEM_RELEASE := 0x8000) )
	_file.close()
}	

LoadTextureGl(file_)
{			
	file := FileOpen(file_, "r")
	VarSetCapacity(data, file.Length)
	file.RawRead(data, file.Length)
	file.close()	
	dllcall("RtlMoveMemory", ptr, DDS_HEADER[], ptr, &data + 4, int, DDS_HEADER.size())	
	
	pixelformat := getFilePixelFormat(DDS_HEADER)
	if (pixelformat = "RGB24")
		ChangeIndianess24(DDS_HEADER.dwWidth * DDS_HEADER.dwHeight, &data + 4 + DDS_HEADER.size())
	
	if (pixelformat = "ABGR")
	{
		type := GL_UNSIGNED_BYTE
		format := GL_RGBA
	}
	else if (pixelformat = "ARGB")
	{	
		type := GL_UNSIGNED_INT_8_8_8_8_REV
		format := GL_BGRA
	}
	else if (pixelformat = "RGB24")
	{	
		type := GL_UNSIGNED_BYTE
		format := GL_RGB
	}
		
	dllcall(gl.p.glGetIntegerv, uint, GL_PIXEL_UNPACK_BUFFER_BINDING, "uint*", current_buffer)	
	(gl.p.glBindBuffer) ? dllcall(gl.p.glBindBuffer, uint, GL_PIXEL_UNPACK_BUFFER, uint, 0)
	dllcall(gl.p.glGetIntegerv, uint, GL_TEXTURE_BINDING_2D, "uint*", current_texture)
	dllcall(gl.p.glGenTextures, uint, 1, "uint*", tex_name)
	dllcall(gl.p.glBindTexture, uint, GL_TEXTURE_2D, uint, tex_name)	
	dllcall(gl.p.glTexImage2D, uint, GL_TEXTURE_2D, uint, 0, uint, GL_RGBA8, uint, DDS_HEADER.dwWidth, uint, DDS_HEADER.dwHeight 
	                         , uint, 0, uint, format, uint, type, uint, &data + 4 + DDS_HEADER.size())
	dllcall(gl.p.glTexParameteri, uint, GL_TEXTURE_2D, uint, GL_TEXTURE_MIN_FILTER, uint, GL_LINEAR)
    dllcall(gl.p.glTexParameteri, uint, GL_TEXTURE_2D, uint, GL_TEXTURE_MAG_FILTER, uint, GL_LINEAR)					 
	dllcall(gl.p.glBindTexture, uint, GL_TEXTURE_2D, uint, current_texture)
	(gl.p.glBindbuffer) ? dllcall(gl.p.glBindBuffer, uint, GL_PIXEL_UNPACK_BUFFER, uint, current_buffer)
	return tex_name							 
}	

getPixelFormatGl(byref texture)
{
	if (gl.constant[texture.type ""] = "GL_UNSIGNED_BYTE") and (gl.constant[texture.format ""] = "GL_RGBA")
		return "ABGR"
	else if texture.type = GL_UNSIGNED_INT_8_8_8_8_REV and texture.format = GL_BGRA
		return "ARGB"
	else if (gl.constant[texture.type ""] = "GL_UNSIGNED_BYTE") and texture.format = GL_RGB
		return "RGB24"
	else return "Unsupported format"
}	

glTexImage2D(target, level, i_format, ww, hh, border, format, type, pdata)
{
	if (level = 0)
	{	
		g_textSwap.GLTextures[g_textSwap.current_texture].format := format
		g_textSwap.GLTextures[g_textSwap.current_texture].type := type
		g_textSwap.GLTextures[g_textSwap.current_texture].dwWidth := ww
		g_textSwap.GLTextures[g_textSwap.current_texture].dwHeight := hh
		pix := getPixelFormatGl(g_textSwap.GLTextures[g_textSwap.current_texture])
		if (pix = "ABGR") or (pix = "ARGB")
			g_textSwap.GLTextures[g_textSwap.current_texture].lPitch := ww * 4
		else if (pix = "RGB24")
			g_textSwap.GLTextures[g_textSwap.current_texture].lPitch := ww * 3
		else g_textSwap.GLTextures[g_textSwap.current_texture].lPitch := ww * 2
		g_textSwap.GLTextures[g_textSwap.current_texture].lpSurface := pdata
		
		for k, v in g_textSwap.dumps
		{
			samples := v.optimized && True ? v.samples : g_textSwap.samples
			if compareSurfaceData(v, g_textSwap.GLTextures[g_textSwap.current_texture], samples, v.optimized)
			{
				if fileexist(v.replacement)
				{
					tex := LoadTextureGl(v.replacement)
					g_textSwap.GLTextures[g_textSwap.current_texture].pReplace := tex					
				} else g_textSwap.GLTextures[g_textSwap.current_texture].pReplace := 0 
			}
		}	
		g_textSwap.GLTextures[g_textSwap.current_texture].lpSurface := ""	
	}		
	dllcall(gl.p.glTexImage2D, uint, target, uint, level, uint, i_format, uint, ww, uint, hh
	                         , uint, border, uint, format, uint, type, uint, pdata)						 
}	

glBindBuffer(p1, p2)
{
	Critical
	dllcall(gl.p.glBindBuffer, uint, p1, uint, p2)
}	

glBindTexture(p1, p2)
{
	g_textSwap.current_texture := p2 . "*"
	if not g_textSwap.GLTextures[p2 . "*"] 
	{
		g_textSwap.GLTextures[p2 . "*"] := {}
		g_textSwap.GLTextures[p2 . "*"].pTexture := p2	
		g_textSwap.GLTextures[p2 . "*"].pReplace := p2	
		g_textSwap.GLIndexedTextures := []
		for k, v in g_textSwap.GLTextures	
			g_textSwap.GLIndexedTextures.insert(v.pTexture)	
	}
	dllcall(gl.p.glBindTexture, uint, p1, uint, g_textSwap.GLTextures[p2 . "*"].pReplace)
}	

glGenTextures(p1, p2)
{
	critical
	dllcall(gl.p.glGenTextures, uint, p1, uint, p2)
	loop, % p1
	{
		pTexture := numget(p2+(A_Index-1)*4, "uint")
		g_textSwap.GLTextures[pTexture . "*"] := {}
		g_textSwap.GLTextures[pTexture . "*"].pTexture := pTexture
		g_textSwap.GLTextures[pTexture . "*"].pReplace := pTexture
	}
	g_textSwap.GLIndexedTextures := []
	for k, v in g_textSwap.GLTextures	
		g_textSwap.GLIndexedTextures.insert(v.pTexture)
}

glDeleteTextures(p1, p2)
{
	critical
	dllcall(gl.p.glDeleteTextures, uint, p1, uint, p2)
	if g_textSwap.GLTextures[p2 . "*"].pReplace
		dllcall(gl.p.glDeleteTextures, uint, 1, uint, g_textSwap.GLTextures[p2 . "*"].pReplace)
	loop, % p1
	{
		pTexture := numget(p2+(A_Index-1)*4, "uint")
		g_textSwap.GLTextures.remove(pTexture . "*")
	}
	g_textSwap.GLIndexedTextures := []
	for k, v in g_textSwap.GLTextures	
		g_textSwap.GLIndexedTextures.insert(v.pTexture)	
}

glDrawRect()
{	
	static state_names 
	state_names ?: state_names := [GL_DEPTH_TEST, GL_CULL_FACE, GL_LIGHTING]
	static state_states := [False, False, False]
	
	glSetStates(state_names, state_states, True)	
	;dllcall(gl.p.glRectf, float, 200, float, 200, float, 0, float, 0)
	dllcall(gl.p.glBegin, uint, GL_POLYGON)
	dllcall(gl.p.glTexCoord2f, float, 1, float, 1) dllcall(gl.p.glVertex2f, float, 200, float, 200)
	dllcall(gl.p.glTexCoord2f, float, 0, float, 1), dllcall(gl.p.glVertex2f, float, 0, float, 200)
	dllcall(gl.p.glTexCoord2f, float, 0, float, 0), dllcall(gl.p.glVertex2f, float, 0, float, 0)
	dllcall(gl.p.glTexCoord2f, float, 1, float, 0), dllcall(gl.p.glVertex2f, float, 200, float, 0)
	dllcall(gl.p.glEnd)
	glRestoreRenderState(state_names, state_states)
	
	;printl("error " dllcall(gl.p.glGetError))
}

glWrite(str)
{
	critical
	static SYSTEM_FONT := 13	
	static state_names 
	state_names ?: state_names := [GL_DEPTH_TEST, GL_CULL_FACE, GL_TEXTURE_2D, GL_LIGHTING]
	static state_states := [False, False, False, False]	
		
	base := dllcall(gl.p.glGenLists, uint, strlen(str))
	dllcall(gl.p.SelectObject, uint, g_globals.gl_hDC, uint, dllcall(gl.p.GetStockObject, int, SYSTEM_FONT))
	dllcall(gl.p.wglUseFontBitmapsW, uint, g_globals.gl_hDC, uint, 0, uint, 255, uint, base) 
	dllcall(gl.p.glListBase, uint, base)
	
	glSetStates(state_names, state_states, False, True)		
	dllcall(gl.p.glRasterPos2f, float, -1., float, -1.0)	
	dllcall(gl.p.glCallLists, uint, strlen(str), uint, GL_UNSIGNED_BYTE, astr, str)		
	glRestoreRenderState(state_names, state_states)		
	
	;printl("error " dllcall(gl.p.glGetError))
}	

glSetStates(byref state_names, byref state_states, _2D = False, color=False)
{
	for k, v in state_names	{
		dllcall(gl.p.glGetBooleanv, uint, v, "uint*", state)
		state_states[k] := state
		dllcall(gl.p.glDisable, uint, v)
	} 	
	
	dllcall(gl.p.glGetFloatv, uint, GL_MODELVIEW_MATRIX, uint, gl._Model[])
	dllcall(gl.p.glGetFloatv, uint, GL_PROJECTION_MATRIX, uint, gl._Projection[])
	dllcall(gl.p.glGetIntegerv, uint, GL_VIEWPORT, gl._viewport[])
	
	color ? dllcall(gl.p.glColor3f, float, g_textSwap.curent_color[1], float, g_textSwap.curent_color[2]
	, float, g_textSwap.curent_color[3]) : dllcall(gl.p.glColor3f, float, 1., float, 1., float, 1.) 
	dllcall(gl.p.glMatrixMode, uint, GL_MODELVIEW)
	dllcall(gl.p.glLoadIdentity)
	dllcall(gl.p.glMatrixMode, uint, GL_PROJECTION)
	dllcall(gl.p.glLoadIdentity)
	_2D ? dllcall(gl.p.glOrtho, double, 0, double, g_globals.res.w, double, g_globals.res.h, double, 0, double, -1, double, 1)
	dllcall(gl.p.glViewport, uint, 0, uint, 0, uint, g_globals.res.w, uint, g_globals.res.h)
	;dllcall(gl.p.glPushMatrix)	
}

glRestoreRenderState(byref state_names, byref state_states)
{
	for k, v in state_names
		if state_states[k] = True
			dllcall(gl.p.glEnable, uint, v)	
		
	dllcall(gl.p.glViewport, uint, gl._viewport.x, uint, gl._viewport.y, uint,gl._viewport.w, uint, gl._viewport.h)	
		
	dllcall(gl.p.glMatrixMode, uint, GL_MODELVIEW)
	dllcall(gl.p.glLoadMatrixf, uint, gl._Model[])
	dllcall(gl.p.glMatrixMode, uint, GL_PROJECTION)
	dllcall(gl.p.glLoadMatrixf, uint, gl._Projection[])	
	;dllcall(gl.p.glPopMatrix)		
}

gl_cicleColor()
{
	static clrs := [[1., 1., 1.], [1., 0., 1.], [1., 0., 0.], [1., 1., 0.], [0., 1., 1.], [0., 0., 1.], [0., 1., 0.]
				   ,[0., 0., 0.], [1., 1., 1.]]
	for k, v in clrs
	{
		if (g_textSwap.curent_color[1] = v[1] and g_textSwap.curent_color[2] = v[2] and g_textSwap.curent_color[3] = v[3])
		{
			g_textSwap.curent_color := clrs[k+1]
			break
		}
	}
}

; Reference for dumping bitmaps
/*
dumpAsBitmapGl(byref texture, file)
{
	stringreplace, file, file, .dds, .bmp
	
	memsize := 3 * texture.dwWidth * texture.dwHeight 
	pdata := dllcall("VirtualAlloc", uint, 0, uint, memsize, "Int", 0x00001000 ;| 0x00002000
								   , uint, (PAGE_READWRITE := 0x04) )	
	
	dllcall(gl.p.glGetIntegerv, uint, GL_TEXTURE_BINDING_2D, "uint*", current_texture)
	dllcall(gl.p.glBindTexture, uint,GL_TEXTURE_2D, uint, texture.pTexture)							   
	dllcall(gl.p.glGetTexImage, uint, GL_TEXTURE_2D, uint, 0, uint, texture.format, uint, texture.type, uint, pdata)
	dllcall(gl.p.glBindTexture, uint, GL_TEXTURE_2D, uint, current_texture)
	
	VarSetCapacity(header, 54)

	_file := FileOpen(file, "w")	
	numput(0x4D42, &header+0, "ushort")
	numput(memsize, &header+2)
	numput(0, &header+6, "uint")
	numput(54, &header+10, "uint")
	numput(40, &header+14, "uint")
	numput(texture.dwWidth, &header+18, "int")
	numput(texture.dwHeight * -1, &header+22, "int")
	numput(1, &header+26, "ushort")
	numput(24, &header+28, "ushort")
	numput(0, &header+30, "uint")
	numput(memsize, &header+34, "uint")
	numput(texture.dwWidth, &header+38, "uint")
	numput(texture.dwHeight, &header+42, "uint")
	numput(0, &header+46, "uint")
	numput(0, &header+50, "uint")
	_file.rawwrite(&header+0, 54)
	_file.rawwrite(pdata+0, memsize)
	
	dllcall("VirtualFree", uint, pdata, uint, 0, uint, (MEM_RELEASE := 0x8000) )
	_file.close()	
}
*/