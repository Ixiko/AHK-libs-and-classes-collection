;watch https://youtu.be/Hu_CQB0s050
;for instructions on how to setup the variables

#noenv
#singleinstance,force
setbatchlines,-1
settitlematchmode,1

#include ../ShinsImageScanClass.ahk ;if your class file is located in the same folder you can remove the '../'

scan := new ShinsImageScanClass()  ;desktop mode, window must be active

scan.autoUpdate := 0 ;turn off auto updating since we want to work on single frames


skipNormalNodes :=	0
reticleX := 		1278     ;these values apply to a 2k monitor in windowed fullscreen
reticleY :=	 		729		 ;you will need to change these most likely
lengthOuter := 		199
lengthMid :=		175
miningTime := 		4000
lTimer :=			0
variance :=			0 ;if playing on a small resolution may need a higher variance
return

~xbutton2::      ;xbutton2 to trigger hotkey but also requires rbutton, since you have to aim for the laser
	gosub miner
return



miner:
if (a_tickcount > lTimer and GetKeyState("rbutton","p")) {
	click,lbutton,down
	lTimer := a_tickcount + miningTime
	sleep 350 ;allow for the ui to fully show
	
	scan.update() ;update the pixel buffer to screen pixels
	extraMarkerTimer := 0
	preScanPrecision := 800 ;arbitrary value, scans 800 times in a circle checking for pixels
	preScanInc := (miningTime / preScanPrecision)
	delta := 0
	loop % preScanPrecision {
		delta += preScanInc
		TimeToXY(round(delta),reticleX,reticleY,x,y,lengthOuter,miningTime) ;look for the extra markers
		if (scan.pixelregion(0xFFFFFF,x-5,y-5,10,10,variance,x,y)) {
			extraMarkerTimer := lTimer - miningTime + round(delta) + 50 ;50 ms because it will trigger a little early, remove if yours isnt
			break
		}
	}
	if (skipNormalNodes and extraMarkerTimer = 0) {
		click,lbutton,up
		lTimer := 0
		return
	}
	if (extraMarkerTimer = 0) {
		delta := next := d1 := 0
		loop % preScanPrecision {
			delta += preScanInc
			TimeToXY(round(delta),reticleX,reticleY,x,y,lengthMid,miningTime) ;look for the normal markers
			if (scan.pixelregion(0xFFFFFF,x-5,y-5,10,10,variance,x,y)) {
				if (next) ;if we already found 1 correct spot wait until it moves away
					continue
				if (d1 = 0) {
					d1 := delta
					next := 1
				} else {
					deltaHalf := (delta - d1) / 2
					break
				}
			} else if (next) { ;if we moved away from the correct spot we can start looking again
				next := 0
			}
		}
	}
	loop { ;doing a loop here without a sleep using batchlines -1 will cause high cpu usage, but improves accuracy
		if (!GetKeyState("rbutton") or (extraMarkerTimer != 0 and a_tickcount >= extraMarkerTimer) or (a_tickcount >= lTimer)) {
			click,lbutton,up
			lTimer := 0
			return
		}
		if (extraMarkerTimer = 0) { ;if no extra marker then check for normal ones
			scan.update() ;update the pixel buffer
			delta := a_tickcount - lTimer
			TimeToXY(delta-deltaHalf,reticleX,reticleY,minx,miny,lengthMid,miningTime)
			TimeToXY(delta+deltaHalf,reticleX,reticleY,maxx,maxy,lengthMid,miningTime)

			if (scan.PixelCountRadius(0xFFFFFF,minx,miny,16,variance) > 0) {
				if (scan.PixelCountRadius(0xFFFFFF,maxx,maxy,16,variance) > 0) {
					click,lbutton,up
					lTimer := 0
					return
				}
			}
		}
	}
}
return


TimeToXY(delta,sx,sy,byref x, byref y,length,miningTime) { ;gets an x,y value in a circle based on a time delta
	d := ((delta / miningTime) * 6.28319) + 1.5708
	x := round(sx + (cos(d) * length))
	y := round(sy + (sin(d) * length))
}
