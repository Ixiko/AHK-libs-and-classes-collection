/*
title: Thumbnail library
wrapped by maul.esel

Credits:
	- skrommel for example how to show a thumbnail (http://www.autohotkey.com/forum/topic34318.html)
	- RaptorOne & IsNull for correcting some mistakes in the code

Requirements:
	OS - Windows Vista or Windows7 (tested on Windows 7)
	AutoHotkey - AHK classic or AHK_L

To make this work on 64bit you should use AHK_L.

Quick-Tutorial:
To add a thumbnail to a gui, you must know the following:
	- the HWND / id of your gui
	- the HWND / id of the window to show
	- the coordinates where to show the thumbnail
	- the coordinates of the area to be shown

1. Create a thumbnail with <Thumbnail_Create()>
2. Set its regions with <Thumbnail_SetRegion()>, optionally query for the source windows width and height before with <Thumbnail_GetSourceSize()>.
3. optionally set the opacity with <Thumbnail_SetOpacity()>
4. show the thumbnail with <Thumbnail_Show()>
*/


/*
Function: Thumbnail_Create()
creates a thumbnail relationship between two windows

Parameters::
	HWND hDestination - the window that will show the thumbnail
	HWND hSource - the window whose thumbnail will be shown

Returns:
	HANDLE hThumb - thumbnail id on success, false on failure

Remarks:
	To get the HWNDs, you could use WinExist().
*/
Thumbnail_Create(hDestination, hSource)
{
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(thumbnail,	4,	0)
	if DllCall("dwmapi.dll\DwmRegisterThumbnail", _ptr, hDestination, _ptr, hSource, _ptr, &thumbnail)
		return false
	return NumGet(thumbnail, _ptr)
}

/*
Function: Thumbnail_SetRegion()
defines dimensions of a previously created thumbnail

Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
	INT xDest - the x-coordinate of the rendered thumbnail inside the destination window
	INT yDest - the y-coordinate of the rendered thumbnail inside the destination window
	INT wDest - the width of the rendered thumbnail inside the destination window
	INT hDest - the height of the rendered thumbnail inside the destination window
	INT xSource - the x-coordinate of the area that will be shown inside the thumbnail
	INT ySource - the y-coordinate of the area that will be shown inside the thumbnail
	INT wSource - the width of the area that will be shown inside the thumbnail
	INT hSource - the height of the area that will be shown inside the thumbnail

Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_SetRegion(hThumb, xDest, yDest, wDest, hDest, xSource, ySource, wSource, hSource)
{
	dwFlags := 0x00000001 | 0x00000002
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)

	NumPut(dwFlags,			dskThumbProps,	00,	"UInt")
	NumPut(xDest,			dskThumbProps,	04,	"Int")
	NumPut(yDest,			dskThumbProps,	08,	"Int")
	NumPut(wDest+xDest,		dskThumbProps,	12,	"Int")
	NumPut(hDest+yDest,		dskThumbProps,	16,	"Int")

	NumPut(xSource,			dskThumbProps,	20,	"Int")
	NumPut(ySource,			dskThumbProps,	24,	"Int")
	NumPut(wSource-xSource,	dskThumbProps,	28,	"Int")
	NumPut(hSource-ySource,	dskThumbProps,	32,	"Int")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}


/*
Function: Thumbnail_Show()
shows a previously created and sized thumbnail

Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>

Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_Show(hThumb)
{
	static dwFlags := 0x00000008, fVisible := 1
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)
	NumPut(dwFlags,		dskThumbProps,	00,	"UInt")
	NumPut(fVisible,	dskThumbProps,	37,	"Int")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}


/*
Function: Thumbnail_Hide()
hides a thumbnail. It can be shown again without recreating

Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>

Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_Hide(hThumb)
{
	static dwFlags := 0x00000008, fVisible := 0
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)

	NumPut(dwFlags,		dskThumbProps,	00,	"Uint")
	NumPut(fVisible,	dskThumbProps,	37,	"Int")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}


/*
Function: Thumbnail_Destroy()
destroys a thumbnail relationship

Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>

Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_Destroy(hThumb)
{
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	return DllCall("dwmapi.dll\DwmUnregisterThumbnail", _ptr, hThumb) >= 0x00
}


/*
Function: Thumbnail_GetSourceSize()
gets the width and height of the source window - can be used with <Thumbnail_SetRegion()>

Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
	ByRef INT width - receives the width of the window
	ByRef INT height - receives the height of the window

Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_GetSourceSize(hThumb, ByRef width, ByRef height)
{
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(Size, 8, 0)
	if DllCall("dwmapi.dll\DwmQueryThumbnailSourceSize", _ptr, hThumb, _ptr, &Size)
		return false
	width := NumGet(&Size + 0, 0, "int")
	height := NumGet(&Size + 0, 4, "int")
	return true
}


/*
Function: Thumbnail_SetOpacity()
sets the current opacity level

Parameters::
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
	INT opacity - the opacity level from 0 to 255 (will wrap to the other end if invalid)

Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_SetOpacity(hThumb, opacity)
{
	static dwFlags := 0x00000004
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)

	NumPut(dwFlags,		dskThumbProps,	00,	"UInt")
	NumPut(opacity,		dskThumbProps,	36,	"UChar")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}

/*
Function: Thumbnail_SetIncludeNC()
sets whether the source's non-client area should be included. The default value is true.

Parameters:
	HANDLE hThumb - the thumbnail id returned by <Thumbnail_Create()>
	BOOL include - true to include the non-client area, false to exclude it

Returns:
	BOOL success - true on success, false on failure
*/
Thumbnail_SetIncludeNC(hThumb, include)
{
	static dwFlags := 0x00000010
	_ptr := A_PtrSize ? "UPtr" : "UInt"

	VarSetCapacity(dskThumbProps, 45, 0)

	NumPut(dwFlags,		dskThumbProps,	00,	"UInt")
	NumPut(!include,	dskThumbProps,	42, "UInt")

	return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", _ptr, hThumb, _ptr, &dskThumbProps) >= 0x00
}