#noenv
setbatchlines,-1
settitlematchmode,1

;include the library assumed to be in the parent directory
;remove ../ if in same directory, or specify path
#include ../ShinsImageScanClass.ahk

scan := new ShinsImageScanClass() ;no title supplied so using desktop instead

;look for a pure red pixel anywhere on the desktop
if (scan.Pixel(0xFF0000,20,x,y)) {
	msgbox % "Found a red pixel at " x "," y
} else {
	msgbox % "Could not find a red pixel on the desktop!"
}

;count all the white pixels on the desktop screen
msgbox % "There are " scan.PixelCount(0xFFFFFF) " white pixels on screen!"


exitapp
