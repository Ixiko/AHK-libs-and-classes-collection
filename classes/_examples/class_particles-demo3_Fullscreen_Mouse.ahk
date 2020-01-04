#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; #singleInstance, off
#singleInstance, force
setBatchLines, -1
coordMode, mouse, screen
; includes are at the bottom

; Start gdi+, this is required.
pToken:=Gdip_Startup()

; create a system that runs at 30 fps
fps:=30
psys:=new particles(fps)

; create a display/canvas using the dimensions of the picture control "PHWND"
; set the quality to 2, which is pretty good quality, but not the best (1-4)
psys.setCanvas(0, 0, A_ScreenWidth, A_ScreenHeight, 2)

; add an emitter, this is what stores all the info of how a particle should behave
; if unset, it uses the default values
e1:=psys.addEmitter() ; create the emitter, save its pointer as "e1" for easy access
e1.type:="Generic" ; how it displays
e1.life:=[0.5] ; how long it will live? 1/2 second.
e1.LineWidth:=[5, 1] ; transition from 5 to 1 pixels over its life
e1.circleSize:=[0] ; no circles.
e1.color:=["114599","2244A1","3343AA","4442B3","5641BB","6740C4","783FCD","8A3ED6","7B3ECE","6C3FC6","5D40BF","4E41B7","3F42B0","3043A8","2244A1"] ; what color(s) it'll be
e1.colorMode:=1 ; how will the colors behave? 1 = cycle. available: 1, 2, 3, 4
e1.alpha:=[255, 80] ; how see-through is it? transitions over its life
e1.pattern:=["c", 90, 210, 330] ; what direction to move
e1.speed:=[100] ; how fast it'll move, in pixels per inch. transitions over its life
e1.spiral:=[180] ; over 1 second, rotate 180 degrees
e1.offx:=20 ; 20px right from its creation point
e1.offy:=20 ; 20px down from its creation point
; these are but a few of the many properties.

setTimer, doTheMagic, % psys.delay ; how fast is each frame? in ms.
return


~esc::
	exitapp
return


doTheMagic:
	; for every frame/tick of the particle system, create a particles. This will increase performance.
	; the x-position is randomly 1 to max width
	; height is 0
	; we choose the first (1) emitter of the particle system
	; we display 1 random character (chr) within 33-90 of the ASCII range
	mouseGetPos, mx, my
	psys.addParticle(mx, my, 1)
	psys.clear() ; this clears all previously drawn stuff, so we only see the new stuff. try removing it for a cool effect
	psys.step()  ; advance the simulation by 1 step/frame/tick
	psys.draw()  ; finally, draw it onto the gui.
return





#include %A_ScriptDir%\..\..\lib-a_to_h\Gdip.ahk
#include %A_ScriptDir%\..\class_particles.ahk
