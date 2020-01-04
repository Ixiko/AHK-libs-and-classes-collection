#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; #singleInstance, off
#singleInstance, force
setBatchLines, -1
; includes are at the bottom

gui, margin, 3, 3
gui, +hwndMYHWND
gui, -theme
gui, add, button, xm ym  w200      vBTN1 gdoTheMagic, click for emitter 1
gui, add, button, xm y+m w350 h100 vBTN2 gdoTheMagic, click for emitter 2
gui, add, button, xm y+m w200 h200 vBTN3 gdoTheMagic, click for emitter 1+2
; gui, add, picture, x300 y300 w300 h300 0xE hwndPHWND vPDisp
gui show

; Start gdi+
pToken:=Gdip_Startup()

; create a system that runs at 30 fps
fps:=30
psys:=new particles(fps)

; create a display/canvas using the dimensions of the picture control "PHWND"
; set the quality to 4, which is the best but slowest (1-4)

; add an emitter, this is what stores all the info of how a particle should behave
; if unset, it uses the default values
e1:=psys.addEmitter()  ; create the emitter, save its pointer as "e1" for easy access
e1.type:="sparks"      ; how it displays
e1.life:=[0.3,0.7]     ; how long it will live, 1/3 to 1/3 second, random.
e1.lineWidth:=[35,2]   ; transition from these values over its life.
e1.circleSize:=[30,5]  ; transition from these values over its life.
e1.alpha:=[120]        ; how see-through is it? 255=solid, 0= invisible
e1.jitter:=[80,80,200] ; how much will it wiggle from its position each tick?
e1.speed:=[100]        ; how fast it'll move, in pixels per inch
e1.pattern:=[180,0]    ; when created, move either left (180) or right (0). chosen randomly

; add multiple emitters!
; you can also assign all the properties in this format
e2:=psys.addEmitter({"type":"genric", "life":[1], "offx":0, "offy":0
, "color":[232323], "colorMode":1, "colorVari":20, "alpha":[100,0]
, "lineWidth":[8], "circleSize":[15], "pattern":["c", 45, 135, 225, 315], "speed":[200]
, "gravity":[0], "jitter":[0], "spiral":[0]})
return

~esc::
	exitapp
return



doTheMagic:
	; get the position of the click control, relative to the screen, not window.
	guiControlGet, hwnd, Hwnd, %A_GuiControl%
	winGetPos, posx, posy, posw, posh, ahk_id %hwnd%
	winGetPos, pos2x, pos2y, pos2w, pos2h, ahk_id %MYHWND%


	; ---------
	; emitter 1
	; ---------
	if (A_GuiControl="btn1")
	{
		; move the canvas to the position+size of the button, set the quality to the best (4)
		psys.setCanvas(posx, posy, posw, posh, 4)
		loop, 50 ; create 50 particles all at once
			psys.addParticle(rand(posw), posh//2, 1)
		while (psys.particles[1].length()>=1) ; if any particles exist, keep looping.
		{
			psys.clear()  ; this clears all previously drawn stuff, so we only see the new stuff. try removing it for a cool effect
			psys.step()   ; advance the simulation by 1 step/frame/tick
			psys.draw()   ; finally, draw it!
			sleep, % psys.delay ; how long to wait to get roughly the desired FPS
		}
		psys.clear() ; particles are dead, do one final cleanup just incase
	}


	; ---------
	; emitter 2
	; ---------
	if (A_GuiControl="btn2")
	{
		; move the canvas to the position+size of the button, set the quality to the best (4)
		psys.setCanvas(pos2x, pos2y, pos2w, pos2h, 4)
		; e2.speed:=[posw*3]
		qty:=fps*e2.life[1]
		; msgBox % psys.particles[2].length()
		psys.addParticle(pos2w//2, pos2h//2, 2)
		while (psys.particles[2].length()>=1)
		{
			if (A_Index<=qty/2)
				psys.addParticle(pos2w//2, pos2h//2, 2)
			psys.clear()
			psys.step()
			psys.draw()
			sleep, % psys.delay
		}
		psys.clear(psys.ID)
	}


	; emitter 1+2
	if (A_GuiControl="btn3")
	{
		; move the canvas to the position+size of the button, set the quality to the best (4)
		psys.setCanvas(pos2x, pos2y, pos2w, pos2h, 4)
		guiControlGet, pos, pos, %A_GuiControl%

		loop, 50
			psys.addParticle(rand(pos2w), rand(pos2h), 1)

		while (psys.particles[1].length()>=1 || psys.particles[2].length()>=1)
		{
			if (A_Index<=fps//2)
				psys.addParticle(pos2w//2, pos2h//2, 2)
			psys.clear()
			psys.step()
			psys.draw()
			sleep, % psys.delay
		}
		psys.clear(psys.ID)
	}
return




#include %A_ScriptDir%\..\..\lib-a_to_h\Gdip.ahk
#include %A_ScriptDir%\..\class_particles.ahk
