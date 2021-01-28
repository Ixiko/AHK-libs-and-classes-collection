
;	This will return the x,y cordinates for the top left and bottom right
;	corners of the desktop work area (if 2 monitors, the entire area)

DesktopScreenCoordinates(byref Xmin, byref Ymin, byref Xmax, byref Ymax)
{
	SysGet, Xmin, 76 	; XVirtualScreenleft  	; left side of virtual screen
	SysGet, Ymin, 77	; YVirtualScreenTop		; Top side of virtual screen

	SysGet, VirtualScreenWidth, 78
	SysGet, VirtualScreenHeight, 79

	Xmax := Xmin + VirtualScreenWidth
	Ymax := Ymin + VirtualScreenHeight
	return
} 