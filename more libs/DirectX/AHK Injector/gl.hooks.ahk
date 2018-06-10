#include  <DirectX\headers\GL.h>
#include  <DirectX\lib\TexSwap\TexSwapLibGL>

global GL_BGRA := 32993
global GL_UNSIGNED_INT_8_8_8_8_REV := 33639
global GL_PIXEL_UNPACK_BUFFER_BINDING := 35055 
global GL_PIXEL_UNPACK_BUFFER := 35052

gl.p := {}
InstallGlHook(function, GDI=False) 
{
	static err := ["Failed to load the helper library" 
	, "Failed to register the callback for the hook function"
	, "Failed to load the specified libray with lasterror = 126"
	, "Failed to load the specified libray"
	, "Failed to get the adress of the function to be hooked"]
	r := InstallHook(isfunc("Alt_" function) ? "Alt_" function : function, pfunction, GDI ? "Gdi32.dll" : "opengl32.dll" , function)
	gl.p[function] := pfunction + 0
	r ? logerr("Failed to hook " function " " . err[r] ? err[r] : "detours error " r) :  logerr("Succeeded to hook " function)
	return r
}	

printl("Acquiring OpenGl and GDI Pointers")
h_gl32 := dllcall("LoadLibraryW", str, "opengl32.dll")
for k, v in strsplit("glMatrixMode glLoadIdentity glLoadMatrixf glOrtho glGetFloatv glGetIntegerv glPopMatrix glPushMatrix glViewport "
. "glDisable glEnable glGetBooleanv glColor3f glRectf glRasterPos2f glGenLists glDeleteLists glListBase glCallLists wglUseFontBitmapsW "
. "glVertex2f glBegin glEnd glGetError glTexCoord2f glBindTexture glGetIntegerv glGetTexImage glTexParameteri glGetString wglMakeCurrent "
. "wglGetProcAddress glScissor glFrustum", " ") {
	gl.p[v] := dllcall("GetProcAddress", uint, h_gl32, astr, v)	
	printl(v " address: " gl.p[v] " error " A_lasterror " <- 0 Means no error")
}

h_gdil32 := dllcall("LoadLibraryW", str, "Gdi32.dll")
for k, v in strsplit("SelectObject GetStockObject", " ") {
	gl.p[v] := dllcall("GetProcAddress", uint, h_gdil32, astr, v)
	printl(v " address: " gl.p[v] " error " A_lasterror " <- 0 Means no error")
}

InstallGlHook("wglCreateContext")
if g_globals.config.TextSwap 
{
	InstallGlHook("wglGetProcAddress")
	InstallGlHook("wglSwapBuffers") 
	InstallGlHook("SwapBuffers", True)
}
gl._Model := struct("float m11, float m12, float m13, float m14, float m21, float m22, float m23, float m24,"
                   . "float m31, float m32, float m33, float m34, float m41, float m42, float m43, float m44")
gl._Projection := gl._Model.clone()
gl._viewport := struct("int x, int y, int w, int h")

if g_globals.config.TextSwap 
	InitTextSwapHooksGl(g_globals.config.TextSwap)

if g_globals.config.hiRes
{
	global g_hiRes := parseConfig(g_globals.config.hiRes)
	logerr("ChangeDisplaySettingsW Hook: " InstallHook("ChangeDisplaySettingsW", pChangeDisplaySettingsW, "User32.dll", "ChangeDisplaySettingsW") " <- 0 means no error")
	logerr("ChangeDisplaySettingsA Hook: " InstallHook("ChangeDisplaySettingsA", pChangeDisplaySettingsA, "User32.dll", "ChangeDisplaySettingsA") " <- 0 means no error")
	logerr("GetDC Hook                 : " InstallHook("GetDC", pGetDC, "User32.dll", "GetDC") " <- 0 means no error")	
		
	InstallGlHook("glViewport")
	InstallGlHook("glScissor")	
	if g_hiRes.wide
	{
		InstallGlHook("glMatrixMode")
		InstallGlHook("glLoadMatrixf")
		InstallGlHook("glFrustum")
		(g_hiRes.nostretch) ? InstallGlHook("glOrtho")
	}	
	gl.p.user_ChangeDisplaySettingsW := pChangeDisplaySettingsW
	gl.p.user_ChangeDisplaySettingsA := pChangeDisplaySettingsA
	gl.p.user_GetDC:= pGetDC		
}

wglSwapBuffers(p1)
{
	critical
	static clr := 0x00ffffff		
	keyevent(g_textSwap.color_switch) ?	clr := gl_cicleColor()
	
	if keyevent(g_textSwap.switch)
		g_textSwap.search := (g_textSwap.search) & True ? False : True
	
	(g_textSwap.search) & True ? BrowseTexturesGl()	
	return dllcall(gl.p.wglSwapBuffers, uint, p1)
}

wglCreateContext(hDC) 
{
	critical
	static local_rect := struct("int x, int y, int w, int h")	
	g_globals.gl_hDC := hDC	
	
	hWin := dllcall("User32.dll\WindowFromDC", uint, hDC)
	dllcall("User32.dll\GetClientRect", uint, hWin, uint, local_rect[])
	g_globals.res := {"w" : local_rect.w, "h" : local_rect.h}	
	
	isobject(g_textSwap.dump) ?: LoadTextureDumpsGl()
	hglrc := dllcall(gl.p.wglCreateContext, uint, hDC)	
	
	/*
		dllcall(gl.p.wglMakeCurrent, uint, hDC, uint, hglrc)
		_EXTENSIONS := dllcall(gl.p.glGetString, int, GL_EXTENSIONS, "astr")
		stringreplace, _EXTENSIONS, _EXTENSIONS, %A_space%, `n, 1
		logerr("GL_EXTENSIONS:`n" _EXTENSIONS)
	*/
	
	return hglrc
}

SwapBuffers(hDC)
{
	critical
	static clr := 0x00ffffff			
	keyevent(g_textSwap.color_switch) ?	clr := gl_cicleColor()
	
	if keyevent(g_textSwap.switch)
		g_textSwap.search := (g_textSwap.search) & True ? False : True	
	(g_textSwap.search) & True ? BrowseTexturesGl()
	dllcall(gl.p.glDisable, uint, GL_SCISSOR_TEST)	
	return dllcall(gl.p.SwapBuffers, uint, hDC)
}

wglGetProcAddress(ext)
{
	critical
	static callbacks := {"glBindTextureEXT" : registercallback("glBindTexture", "F")
						,"glBindTexture" : registercallback("glBindTexture", "F")
	                    ,"glGenTexturesEXT" : registercallback("glGenTextures", "F")
						,"glGenTextures" : registercallback("glGenTextures", "F")
	                    ,"glDeleteTexturesEXT" : registercallback("glDeleteTextures", "F")
						,"glDeleteTextures" : registercallback("glDeleteTextures", "F")
						,"glTexImage2DEXT" : registercallback("glGenTextures", "F")
						,"glTexImage2D" : registercallback("glGenTextures", "F")
						,"glBindTextureEXT" : registercallback("glGenTextures", "F")
						,"glBindTexture" : registercallback("glGenTextures", "F")
						,"glBindBuffer" : registercallback("glBindBuffer", "F")
						,"glBindBufferARB" : registercallback("glBindBuffer", "F")}					
	
	r := dllcall(gl.p.wglGetProcAddress, uint, ext)
	;logerr("Requesting extension " strget(ext+0, "CP0"))		
	
	ex := strget(ext+0, "CP0")
	if callbacks[ex]
	{
		logerr("Requesting extension " strget(ext+0, "CP0"))	
		ex := substr(ex, 1, strlen(ex)-3)		
		gl.p[ex] := r
		return callbacks[ex . "EXT"]
	}
	return r 
}

ComputeResolutionCorrectionsGl(p2, p3)
{
	g_globals.res := (g_hiRes.width and g_hiRes.height) & True 
	? {"w" : g_hiRes.width, "h" : g_hiRes.height} : GetDesktopResolution()
	g_globals.requested_res := {"w" : p2, "h" : p3}
	g_globals.resolution_correction := g_globals.res.h/g_globals.requested_res.h
	g_globals.viewport_correction := (g_globals.res.w - p2*g_globals.resolution_correction)/2	
	g_globals.aspect_correction := (g_globals.res.w/g_globals.res.h)/(g_globals.requested_res.w/g_globals.requested_res.h) 
}

ChangeDisplaySettingsA(p1, p2)
{
	critical
	ComputeResolutionCorrectionsGl(numget(p1+108, "int"), numget(p1+112, "int"))
	numput(g_globals.res.w, p1+108, "int")
	numput(g_globals.res.h, p1+112, "int")
	return dllcall(gl.p.user_ChangeDisplaySettingsA, uint, p1, uint, p2)
}

ChangeDisplaySettingsW(p1, p2)
{
	critical
	ComputeResolutionCorrectionsGl(numget(p1+172, "int"), numget(p1+176, "int"))
	numput(g_globals.res.w, p1+172, "int")
	numput(g_globals.res.h, p1+176, "int")
	return dllcall(gl.p.user_ChangeDisplaySettingsW, uint, p1, uint, p2)
}

GetDC(h_win)
{
	critical
	static winpos := dllcall("GetProcAddress", uint, dllcall("GetModuleHandleW", str, "User32.dll", uint), astr, "SetWindowPos")
		
	if h_win 
		dllcall(winpos, uint, h_win, int, -1, int, g_globals.res.viewport_correction, int, 0, int, g_globals.res.w, int, g_globals.res.h, uint, 0x0400)
		;printl("setpos " dllcall(winpos, uint, h_win, int, -1, int, g_globals.res.viewport_correction
		                               ;, int, 0, int, g_globals.res.w, int, g_globals.res.h, uint, 0x0400) A_lasterror) 
									   
	dllcall("SetForegroundWindow", uint, h_win)								   
	winset, style, -0xC00000, ahk_id %h_win%	
	return dllcall(gl.p.user_GetDC, uint, h_win)	
}

glFrustum(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12)
{
	Critical
	ww := getdoubleGl(p1, p2),	w := getdoubleGl(p3, p4) 
	hh := getdoubleGl(p5, p6),	h := getdoubleGl(p7, p8) 
	if g_hiRes.nofov 
	{
		hh /= g_globals.aspect_correction
		h /= g_globals.aspect_correction 
	} else {
		ww *= g_globals.aspect_correction 
		w *= g_globals.aspect_correction 
	}		
	dllcall(gl.p.glFrustum, "Double", ww, "Double", w, "Double", hh, "Double", h, uint, p9, uint, p10, uint, p11, uint, p12)
	return 
}

glOrtho(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12)
{
	Critical	
	left := getdoubleGl(p1, p2) - g_globals.viewport_correction/g_globals.resolution_correction
	right := getdoubleGl(p3, p4) + g_globals.viewport_correction/g_globals.resolution_correction
	bottom := getdoubleGl(p5, p6) 
	top := getdoubleGl(p7, p8) 
	dllcall(gl.p.glOrtho, "Double", left, "Double", right, "Double", bottom, "Double", top, uint, p9, uint, p10, uint, p11, uint, p12)
	return 
}

glLoadMatrixf(pMatrix)
{
	critical
	if (g_globals.gl_matrixmode = GL_PROJECTION)
	{
		;printl("Projection")
		if g_hiRes.nofov 
		{
			m22 := numget(pMatrix+20, "float")	
			numput(m22*g_globals.aspect_correction, pMatrix+20, "float")				
		} else {
			m11 := numget(pMatrix+0, "float")
			numput(m11/g_globals.aspect_correction, pMatrix+0, "float")							
		}
	}
	dllcall(gl.p.glLoadMatrixf, "ptr", pMatrix)	
}

glMatrixMode(mode)
{
	Critical
	g_globals.gl_matrixmode := mode
	dllcall(gl.p.glMatrixMode, uint, mode)
	return
}

glViewport(p1, p2, p3, p4)
{
	Critical	
	p3 *= g_globals.resolution_correction
	g_hiRes.wide ? p3 += g_globals.viewport_correction*2 : p1 += g_globals.viewport_correction
	dllcall(gl.p.glViewport, uint, p1, uint, p2, uint, p3, uint, p4*g_globals.resolution_correction)
	dllcall(gl.p.glDisable, uint, GL_CULL_FACE)	
	return
}

glScissor(p1, p2, p3, p4)
{
	critical
	;printl("Scissor")
	return 	
}

getdoubleGl(p1, p2)
{
	VarSetCapacity(var, 8)
	numput(p1, &var+0,  "uint")
	numput(p2, &var+4, "uint")
	return numget(&var+0, "double")
}
