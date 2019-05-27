/**************************************************************************************************************
title: Thumbnail functions
wrapped by maul.esel

Credits:
- skrommel for example how to show a thumbnail (http://www.autohotkey.com/forum/topic34318.html)
- RaptorOne & IsNull for correcting some mistakes in the code

NOTE:
*This requires Windows Vista or Windows7* (tested on Windows 7)
Quick-Tutorial:
To add a thumbnail to a gui, you must know the following:
- the hwnd / id of your gui
- the hwnd / id of the window to show
- the coordinates where to show the thumbnail
- the coordinates of the area to be shown
1. Create a thumbnail with Thumbnail_Create()
2. Set its regions with Thumbnail_SetRegion()
a. optionally query for the source windows width and height before with <Thumbnail_GetSourceSize()>
3. optionally set the opacity with <Thumbnail_SetOpacity()>
4. show the thumbnail with <Thumbnail_Show()>
***************************************************************************************************************
*/


/**************************************************************************************************************
Function: Thumbnail_Create()
creates a thumbnail relationship between two windows

params:
handle hDestination - the window that will show the thumbnail
handle hSource - the window whose thumbnail will be shown
returns:
handle hThumb - thumbnail id on success, false on failure

Remarks:
To get the Hwnds, you could use WinExist()
***************************************************************************************************************
*/
Thumbnail_Create(hDestination, hSource) {

VarSetCapacity(thumbnail, 4, 0)
if DllCall("dwmapi.dll\DwmRegisterThumbnail", "UInt", hDestination, "UInt", hSource, "UInt", &thumbnail)
return false
return NumGet(thumbnail)
}


/**************************************************************************************************************
Function: Thumbnail_SetRegion()
defines dimensions of a previously created thumbnail

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
int xDest - the x-coordinate of the rendered thumbnail inside the destination window
int yDest - the y-coordinate of the rendered thumbnail inside the destination window
int wDest - the width of the rendered thumbnail inside the destination window
int hDest - the height of the rendered thumbnail inside the destination window
int xSource - the x-coordinate of the area that will be shown inside the thumbnail
int ySource - the y-coordinate of the area that will be shown inside the thumbnail
int wSource - the width of the area that will be shown inside the thumbnail
int hSource - the height of the area that will be shown inside the thumbnail
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_SetRegion(hThumb, xDest, yDest, wDest, hDest, xSource, ySource, wSource, hSource) {
dwFlags := 0x00000001 | 0x00000002

VarSetCapacity(dskThumbProps, 45, 0)

NumPut(dwFlags, dskThumbProps, 0, "UInt")
NumPut(xDest, dskThumbProps, 4, "Int")
NumPut(yDest, dskThumbProps, 8, "Int")
NumPut(wDest+xDest, dskThumbProps, 12, "Int")
NumPut(hDest+yDest, dskThumbProps, 16, "Int")

NumPut(xSource, dskThumbProps, 20, "Int")
NumPut(ySource, dskThumbProps, 24, "Int")
NumPut(wSource+xSource, dskThumbProps, 28, "Int")
NumPut(hSource+ySource, dskThumbProps, 32, "Int")

return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", "UInt", hThumb, "UInt", &dskThumbProps) ? false : true
}


/**************************************************************************************************************
Function: Thumbnail_Show()
shows a previously created and sized thumbnail

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_Show(hThumb) {
static dwFlags := 0x00000008, fVisible := 1

VarSetCapacity(dskThumbProps, 45, 0)
NumPut(dwFlags, dskThumbProps, 0, "UInt")
NumPut(fVisible, dskThumbProps, 37, "Int")

return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", "UInt", hThumb, "UInt", &dskThumbProps) ? false : true
}


/**************************************************************************************************************
Function: Thumbnail_Hide()
hides a thumbnail. It can be shown again without recreating

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_Hide(hThumb) {
static dwFlags := 0x00000008, fVisible := 0

VarSetCapacity(dskThumbProps, 45, 0)
NumPut(dwFlags, dskThumbProps, 0, "Uint")
NumPut(fVisible, dskThumbProps, 37, "Int")
return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", "UInt", hThumb, "UInt", &dskThumbProps) ? false : true
}


/**************************************************************************************************************
Function: Thumbnail_Destroy()
destroys a thumbnail relationship

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_Destroy(hThumb) {
return DllCall("dwmapi.dll\DwmUnregisterThumbnail", "UInt", hThumb) ? false : true
}


/**************************************************************************************************************
Function: Thumbnail_GetSourceSize()
gets the width and height of the source window - can be used with <Thumbnail_SetRegion()>

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
ByRef int width - receives the width of the window
ByRef int height - receives the height of the window
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_GetSourceSize(hThumb, ByRef width, ByRef height) {
VarSetCapacity(Size, 8, 0)
if DllCall("dwmapi.dll\DwmQueryThumbnailSourceSize", "Uint", hThumb, "Uint", &Size)
return false
width := NumGet(&Size + 0, 0, "int")
height := NumGet(&Size + 0, 4, "int")
return true
}


/**************************************************************************************************************
Function: Thumbnail_SetOpacity()
sets the current opacity level

params:
handle hThumb - the thumbnail id returned by <Thumbnail_Create()>
int opacity - the opacity level from 0 to 255 (will wrap to the other end if invalid)
returns:
bool success - true on success, false on failure
***************************************************************************************************************
*/
Thumbnail_SetOpacity(hThumb, opacity) {
static dwFlags := 0x00000004

VarSetCapacity(dskThumbProps, 45, 0)
NumPut(dwFlags, dskThumbProps, 0, "UInt")
NumPut(opacity, dskThumbProps, 36, "UChar")
return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", "Uint", hThumb, "UInt", &dskThumbProps) ? false : true
}

/**************************************************************************************************************
section: example
This example sctript shows a thumbnail of your desktop in a GUI
(start code)
; initializing the script:
#SingleInstance force
#NoEnv
#KeyHistory 0
SetWorkingDir %A_ScriptDir%
#include Thumbnail.ahk

; get the handles:
Gui +LastFound
hDestination := WinExist() ; ... to our GUI...
hSource := WinExist("ahk_class Progman") ; ... and to the desktop

; creating the thumbnail:
hThumb := Thumbnail_Create(hDestination, hSource) ; you must get the return value here!

; getting the source window dimensions:
Thumbnail_GetSourceSize(hThumb, width, height)

; then setting its region:
Thumbnail_SetRegion(hThumb, 25, 25 ; x and y in the GUI
, 400, 350 ; display dimensions
, 0, 0 ; source area coordinates
, width, height) ; the values from Thumbnail_GetSourceSize()

; now some GUI stuff:
Gui +AlwaysOnTop +ToolWindow
Gui Add, Button, gHideShow x0 y0, Hide / Show

; Now we can show it:
Thumbnail_Show(hThumb) ; but it is not visible now...
Gui Show, w450 h400 ; ... until we show the GUI

; even now we can set the transparency:
Thumbnail_SetOpacity(hThumb, 200)

return

GuiClose: ; in case the GUI is closed:
Thumbnail_Destroy(hThumb) ; free the resources
ExitApp

HideShow: ; in case the button is clicked:
if hidden
Thumbnail_Show(hThumb)
else
Thumbnail_Hide(hThumb)

hidden := !hidden
return
(end)
***************************************************************************************************************
*/