;how to use - Open up a new instance of paint select the brush or pen, then run the program
; it should draw a square with a cross in the center of the drawing region

#noenv
#singleinstance,force
setbatchlines,-1
settitlematchmode,1

#include ..\ShinsImageScanClass.ahk  ;remove ..\ if the class file is in the same directory
scan := new ShinsImageScanClass("Untitled - Paint")
scan.AutoUpdate := 0  ;only want to update the buffer once then perform many scans
scan.UseControlClick := 1
scan.Update() ;update buffer

regionX1 := 0  ;default the regions of the paint canvas
regionY1 := 0 
regionX2 := 0 
regionY2 := 0 

;attempt to find the paint canvas height; assumes white background
x := 20
y := scan.height
while(y > 30) {
	if (!regionY2 and scan.PixelPosition(0xFFFFFFFF,x,y)) {
		regionY2 := y
	} else if (regionY2 and !regionY1 and !scan.PixelPosition(0xFFFFFFFF,x,y)) {
		regionY1 := y+1
		break
	}
	y--
	;msgbox % x "," y "`n" tohex(scan.getpixel(x,y))
}


;attempt to find the paint canvas width; assumes white background
x := 0
y := regionY1
while(x < scan.width) {
	if (!regionX1 and scan.PixelPosition(0xFFFFFF,x,y)) {
		regionX1 := x
	} else if (regionX1 and !regionX2 and !scan.PixelPosition(0xFFFFFF,x,y)) {
		regionX2 := x-1
		break
	}
	x++
}


;attempt to draw a square with a cross using ControlClick (doesn't have to be active)
;ControlClick seems a little wonky on paint if too close to the edge, so I had an 80 px buffer
scan.ClickDrag(regionX1+80,regionY1+80,regionX2-80,regionY1+80) ;top
scan.ClickDrag(regionX1+80,regionY1+80,regionX1+80,regionY2-80) ;left
scan.ClickDrag(regionX2-80,regionY1+80,regionX2-80,regionY2-80) ;right
scan.ClickDrag(regionX1+80,regionY2-80,regionX2-80,regionY2-80) ;bot

scan.ClickDrag(regionX1+80,regionY1+80,regionX2-80,regionY2-80) ;cross1
scan.ClickDrag(regionX1+80,regionY2-80,regionX2-80,regionY1+80) ;cross2

exitapp
