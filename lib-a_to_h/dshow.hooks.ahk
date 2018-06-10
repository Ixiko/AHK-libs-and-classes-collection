#include <DirectX\dshow>
#include <DirectX\bink>

if g_globals.config.upScale or g_globals.config.hiRes 
{
	logerr(getDirectShow())
	logerr(IVideoWindow.hook("SetWindowPosition"))
}

IVideoWindow_SetWindowPosition(p1, p2, p3, p4, p5)
{
	Critical
	p4 *= g_globals.config.dshow
	p5 *= g_globals.config.dshow
	x := (g_globals.res.w - p4)/2 
	y := (g_globals.res.h - p5)/2
	r := dllcall(IVideoWindow.SetWindowPosition, uint, p1
									 , uint, x
									 , uint, y 
									 , uint, p4   
									 , uint, p5) 
	return r
}