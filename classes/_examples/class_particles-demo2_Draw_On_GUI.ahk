#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; #singleInstance, off
#singleInstance, force
setBatchLines, -1
; includes are at the bottom

; create the GUI we'll draw on.
gui, color, black
gui, add, slider, xm w200 range0-500 tickinterval100 tooltip vpSpeed gsize, 300
gui, add, slider, xm w200 range-300-300 tickinterval100 tooltip vpSpeed2 gsize, 0

; this control is what we draw onto. give it an HWND (i named it "PHWND") so we can draw onto it.
gui, add, picture, xm y+10 wp h200 0xE hwndPHWND
gui show

; Start gdi+, this is required.
pToken:=Gdip_Startup()

; create a system that runs at 30 fps
fps:=30
psys:=new particles(fps)

; create a display/canvas using the dimensions of the picture control "PHWND"
; set the quality to 4, which is the best but slowest (1-4)
psys.setCanvas(0, 0, 0, 0, 4, PHWND)

; add an emitter, this is what stores all the info of how a particle should behave
; if unset, it uses the default values
e1:=psys.addEmitter()  ; create the emitter, save its pointer as "e1" for easy access
e1.type:="text"        ; how it displays
e1.life:=[0.5,1]       ; how long it will live, 1/2 to 1 second, random.
e1.circleSize:=[22,18] ; at the start of its life, it'll be size 22 text, at the end, 18
e1.color:=["00ff00"]   ; what color(s) it'll be
e1.alpha:=[135, 20]    ; how see-through is it? transitions over its life
e1.pattern:=[270]      ; what direction to move
e1.speed:=[300,300,5]  ; how fast it'll move, in pixels per inch. transitions over its life
; these are but a few of the many properties.

gosub, size
setTimer, doTheMagic, % psys.delay ; how fast is each frame? in ms.
return


~esc::
	exitapp
return


size:
	gui, submit, noHide
	; have the sliders adjust the speed
	e1.speed:=[pSpeed, pSpeed, pSpeed2]
return


doTheMagic:
	; for every frame/tick of the particle system, create 3 particles
	; the x-position is randomly 1 to max width
	; height is 0
	; we choose the first (1) emitter of the particle system
	; we display 1 random character (chr) within 33-90 of the ASCII range/
	loop, 3
		psys.addParticle(rand(psys.cw), 0, 1, chr(rand(33,90)))
	psys.clear()     ; this clears all previously drawn stuff, so we only see the new stuff. try removing it for a cool effect
	psys.step()      ; advance the simulation by 1 step/frame/tick
	psys.draw(PHWND) ; finally, draw it onto the gui.
	; tooltip % "Drawing: " psys.drawcount , 0, 20
return





#include %A_ScriptDir%\..\..\lib-a_to_h\Gdip.ahk
#include %A_ScriptDir%\..\class_particles.ahk
