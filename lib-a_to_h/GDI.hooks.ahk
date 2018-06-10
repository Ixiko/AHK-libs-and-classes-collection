; <COMPILER: v1.1.11.01>
global g_GDIHooks := {}
if g_globals.config.upScale or g_globals.config.hiRes
{
	logerr("ExtTextOutA Hook error " . InstallHook("ExtTextOutA", pExtTextOutA, "Gdi32.dll", "ExtTextOutA"))
	logerr("TextOutA Hook error " . InstallHook("TextOutA", pTextOutA, "Gdi32.dll", "TextOutA"))
	g_GDIhooks.pTextOutA := pTextOutA
	g_GDIhooks.pExtTextOutA := pExtTextOutA
}
ExtTextOutA(p1, p2, p3, p4, p5, p6, p7, p8)
{
	Critical
	p2 *= g_globals.resolution_correction
	p2 += g_globals.viewport_correction
	p3 *= g_globals.resolution_correction
	r := dllcall(g_GDIHooks.pExtTextOutA, uint, p1, uint, p2, uint, p3, uint, p4, uint, _RECT[], uint, p6, uint, p7, uint, p8)
	return r
}
TextOutA(p1, p2, p3, p4, p5)
{
	Critical
	p2 *= g_globals.resolution_correction
	p2 += g_globals.viewport_correction
	p3 *= g_globals.resolution_correction
	r := dllcall(g_GDIHooks.pTextOutA, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5)
	return r
}