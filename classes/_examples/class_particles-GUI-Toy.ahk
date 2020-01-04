/*
Name: Particle System
Version 2.1 (Tuesday, January 17, 2017)
Created: Thursday, December 22, 2016
Author: tidbit
Credit:
	maestrith - dlg_color()
	tic - GDIP

Hotkeys:

Description:

*/


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; #singleInstance, off
#singleInstance, force
setBatchLines, -1
setWinDelay, -1
setControlDelay, -1
; includes are at the bottom

_name_:="Particle System"
_version_:="2.0 (Saturday, December 31, 2016)"
OnExit, whyMustYouLeaveMe


ptypes:="Generic|Generic Fill|Sparks||AllLines|Text|Image|Cursor"
; ptypes:="Generic|Generic Fill|Sparks||AllLines|Cursor"

quality:=2 ; 1 2 3 or 4
emitArrGUI:={}
frame:=0
FPS:=30

BGCol:="0x002233"
guiFontSize:=10
; https://www.strangeplanet.fr/work/gradient-generator/index.php
gradientPresets:={"---":""
, "Fire":["FFFFFF","FFFEBF","FFFD7F","FFFC3F","FFFB00","FFE600","FFD100","FFBC00","FFA800","FF9300","FF7E00","FF6900","FF5500"]
, "Rainbow":["FF0000","F71507","F02B0F","E94116","E2571E","E96116","F06B0F","F77507","FF7F00","FFA900","FFD400","FFFF00","AAFF00","55FF00","00FF00","00AA55","0055AA","0000FF","2E00FF","5C00FF","8B00FF"]
, "Rainbow2":["8FBC8F","FF1493","191970"]
,"Pur1":["114599","2244A1","3343AA","4442B3","5641BB","6740C4","783FCD","8A3ED6","7B3ECE","6C3FC6","5D40BF","4E41B7","3F42B0","3043A8","2244A1"]
, "Pur1-R": ["783FCD","693FC5","5A40BE","4B41B6","3D42AF","2E43A7","1F44A0","114599","1E449F","2C43A6","3942AD","4741B4","5440BB","623FC2","703FC9"]
, "Hue":["FF0000","FF003F","FF007F","FF00BF","FF00FF","BF00FF","7F00FF","3F00FF","0000FF","0055FF","00AAFF","00FFFF","00FFAA","00FF55","00FF00","55FF00","AAFF00","FFFF00","FFAA00","FF5500","FF0000"]}

dirsPresets:=["r",0,45,90,180,270,"18 36 54 72 90 108 126 144 162 180 198 216 234 252 270 288 306 324 342 360"
,"0 5 10 13 16 17 16 13 10 5 0 -5 -10 -13 -16 -17 -16 -13 -10 -5"
, "0 2 3 5 5 6 5 5 3 2 0 -2 -3 -5 -5 -6 -5 -5 -3 -2"]


gui, main: margin, 3, 6
gui, main: font, s%guiFontSize%
; gui, main: add, picture, xm ym w500 h300 0x1000
gui, main: add, text, xm y+m, Emitter(s)
gui, main: add, listbox, xp y+m w100 r12 altsubmit veLB geChanged
gui, main: add, button, xp y+m w75 gaddEmit, +
gui, main: add, button, x+2 yp w23 gdeleteEmit, -

gui, main: add, text, xm y+m, FPS (1-60):
gui, main: add, edit, x+m yp-3 w40 number right vFPS gqueue, 30
gui, main: add, text, xm y+m, PPS (1-60):
gui, main: add, edit, x+m yp-3 w40 number right vPPS gqueue, 30
gui, main: add, button, xm y+m w100 vcolBtn gchooseCol, BG Color
gui, main: add, checkbox, xm y+0 hp vuseMouse gqueue, Follow Mouse

guiControlGet, pos, main: pos, eLB
guiControlGet, pos2, main: pos, FPS
guiControl, main: move, FPS, % "w" posw+posx-pos2x
guiControl, main: move, PPS, % "w" posw+posx-pos2x
guiControl, main: move, colBtn, % "w" posw
guiControl, main: move, useMouse, % "w" posw

gui, main: add, text, x+m ym section vtxte1, Type:
gui, main: add, DDL, x+m yp-3 altsubmit veType gqueue, %ptypes%
gui, main: add, text, xs y+m vtxte5, Text:
gui, main: add, edit, x+m yp-3 veMisc gqueue


gui, main: add, text, xs y+m vtxte3, Life (min, max):
gui, main: add, edit, x+m yp-3 w40 vlifemin gqueue, 1
gui, main: add, edit, x+m yp wp vlifemax gqueue, 1
gui, main: add, checkbox, x+m yp hp vuseFrames gqueue, Frames

gui, main: add, text, xs y+m vtxte4, Position (x, y):
gui, main: add, edit, x+m yp-3 w40 voffx gqueue, 0
gui, main: add, edit, x+m yp wp voffy gqueue, 0
; gui, main: add, checkbox, x+m yp hp vuseMouse gqueue, Mouse


guiControlGet, pos, main: pos, lifemax
guiControlGet, pos2, main: pos, lifemin
guiControl, main: move, offx, x%pos2x% w%pos2w%
guiControl, main: move, offy, x%posx% w%posw%
guiControlGet, pos, main: pos, useFrames
guiControlGet, pos2, main: pos, eType
guiControl, main: move, eType, % " w" posx+posw-pos2x
guiControlGet, pos2, main: pos, eMisc
guiControl, main: move, eMisc, % " w" posx+posw-pos2x

GroupBox2("Emitter", "txte1,txte3,txte4,txte5,etype,emisc,qty,lifemin,lifemax,offx,offy,useFrames", "main")


gui, main: add, text, xs y+m vtxtc2, Mode:
gui, main: add, DDL, x+m yp-3 altsubmit vcolormode gqueue, Cycle||Random|Life|Life Reverse

ttt:=""
for k in gradientPresets
	ttt.= k "|"
gui, main: add, text, xs y+m vtxtc5, Presets:
gui, main: add, DDL, x+m yp-3 altsubmit vcolorPre gqueue, % strReplace(trim(ttt, "|"), "|", "||",, 1)

gui, main: add, link, xs y+m vtxtc1 w120, <a href="https://www.strangeplanet.fr/work/gradient-generator/index.php">Colors (rrggbb)</a>
gui, main: add, text, x+m yp vtxtc4 wp, Alphas (0-255)

gui, main: font,, consolas
gui, main: add, edit, xs y+m wp r6 -wrap vcolors gqueue, ff4400
gui, main: add, edit, x+m yp wp r6 valphas gqueue, 255`n80
gui, main: font
gui, main: font, s%guiFontSize%
; gui, main: add, edit, xs y+m wp r6 vcolors gqueue, 336699`nff4400`n112233`n3352ba`naa22aa`n512aff
; gui, main: add, edit, x+m yp wp r6 valphas gqueue, 0`n0`n255`n100

gui, main: add, text, xs y+m vtxtc3, Color +/- (-255 - 255):
gui, main: add, edit, x+m yp-3 w50 vvariations gqueue, 30

guiControlGet, pos, main: pos, alphas
guiControlGet, pos2, main: pos, colormode
guiControl, main: move, variations, x%posx% w%posw%
guiControl, main: move, colormode, % "w" posx+posw-pos2x
guiControlGet, pos2, main: pos, colorPre
guiControl, main: move, colorPre, % "w" posx+posw-pos2x

ttt2:=GroupBox2("Color settings", "txtc1,txtc2,txtc3,txtc4,txtc5,colors,colormode,variations,alphas,colorPre", "main")
guiControl, main: move, % ttt[1], % "w" ttt2[4]
guiControlGet, pos2, main: pos, type
guiControl, main: move, type, % "w" ttt2[2]+ttt2[4]-pos2x-6

gui, main: add, text, ym section vtxtp1, Thicknesses (#, ...):
gui, main: add, edit, x+m yp-3 w100 r1 vlw gqueue, 5

gui, main: add, text, xs y+m vtxtp2, Size (#, ...):
gui, main: add, edit, x+m yp-3 w100 r1 vcs gqueue, 0, 20

gui, main: add, text, xs y+m vtxtp3, Directions* (angle, ...):

ttt:=""
for k, v in dirsPresets
	ttt.=v "|"
gui, main: add, comboBox, x+m yp-3 w100 r10 vdirs gqueue, % strReplace(trim(ttt, "|"), "|", "||",, 1)
gui, main: add, text, xp y+0 vtxtp4 cblue backgroundtrans, * r = random
gui, main: add, checkbox, xs+30 yp checked vcycle gqueue, Cycle?
gui, main: add, checkbox, xp y+m vrelm gqueue, Relative to mouse?
gui, main: add, checkbox, xp y+m vrelw gqueue, Relative to mouse (Reverse)?

gui, main: add, text, xs y+m vtxtp5, Speed (#, ...):
gui, main: add, edit, x+m yp-3 w100 r1 vspeeds gqueue, 100

gui, main: add, text, xs y+m vtxtp6, Jitter (#, ...):
gui, main: add, edit, x+m yp-3 w100 r1 vjitters gqueue, 0

gui, main: add, text, xs y+m vtxtp7, Gravity* (#, ...):
gui, main: add, edit, x+m yp-3 w100 r1 vgravity gqueue, 100
gui, main: add, text, xs y+0 vtxtp8 cblue backgroundtrans, * 0 is off, -# is up, # is down
gui, main: add, text, xs y+m vtxtp9, Spiral:
gui, main: add, edit, x+m yp-3 w100 r1 vspiral gqueue, 0


GroupBox2("Properties", "txtp1,txtp2,txtp3,txtp4,txtp5,txtp6,txtp7,txtp8,txtp9,lw,cs,dirs,cycle,relm,relw,speeds,jitters,gravity, spiral", "main")

guiControlGet, pos, main: pos, dirs
guiControl, main: move, lw, x%posx%
guiControl, main: move, cs, x%posx%

guiControlGet, pos, main: pos, speeds
guiControl, main: move, jitters, x%posx%
guiControl, main: move, gravity, x%posx%
guiControl, main: move, spiral, x%posx%

gui, preview: margin, 0, 0
gui, preview: color, %BGCol%
gui, preview: +toolWindow +ownerMain +resize
gui, preview: add, picture, xm ym w300 w500 h500 0xE hwndPHWND vPDisp gclickToSetAnchor

; Start gdi+
pToken:=Gdip_Startup()

gui, main: +hwndMAINHWND
gui, main: show, x200 ycenter, %_name_% %_version_%

contArr:=["etype","emisc","lifemin","lifemax","offx","offy","useFrames"
,"colorPre","colors","colormode","variations","alphas","lw","cs","dirs","cycle"
,"relm","relw","speeds","jitters","gravity","spiral"]

winGetPos, x,y,w,h, ahk_id %MAINHWND%
gui, preview: show, % "x" x+w " y" y " autosize", Preview - %_name_%
; gui, preview: show, % "x" x " y" y " autosize", Preview

psys:=new particles(FPS)
; msgBox % st_printArr(psys)



gosub, setup
gosub, addEmit
; gosub, changeEProperty
; gosub, update
return


whyMustYouLeaveMe: ; why? :(
previewguiClose:
mainguiClose:
~esc::
	; gdi+ may now be shutdown
	Gdip_Shutdown(pToken)
	ExitApp
return


; j::msgBox % st_printArr(emitArrGUI)
; j::psys.particles[1]:=[]


chooseCol:
	BGCol:=RGB(dlg_color(BGCol,MAINHWND))
	gui, preview: color, 0x%BGCol%
return


setup:
	gui, main: submit, noHide

	guiControlGet, drawArea, preview: pos, PDisp
	anchorX:=(drawAreaW//2)+offx
	anchorY:=(drawAreaH//2)+offy

	; quality:=3
	psys:=new particles(FPS)
	Graphics:=psys.setCanvas(0, 0, drawAreaW, drawAreaH, quality, PHWND)
return


deleteEmit:
	guiControlGet, eLB, main:
	psys.Emitters.removeAt(eLB)
	emitArrGUI.removeAt(eLB)
	ttt:=""
	for k in psys.Emitters
	{
		if (k=eLB)
			ttt.=psys.Emitters[k].type "||"
		else
			ttt.=psys.Emitters[k].type "|"
	}
	guiControl, main:, eLB, |%ttt%
return


addEmit:
	gui, main: submit, noHide
	gui, main: default
	newE:=psys.addEmitter()

	for k, v in contArr
		guiControl, main: -g, %v%
	guiControl, main: -g, eLB

	guiControl, main: choose, eType, 1
	guiControl, main:, lifemin, % newE.Life[1]
	guiControl, main:, lifemax, % newE.Life[1]
	guiControl, main:, offx, 0
	guiControl, main:, offy, 0
	guiControl, main:, useFrames, 0
	guiControl, main:, colors, % st_glue(newE.color)
	guiControl, main: choose, colormode, 1
	guiControl, main:, variations, % newE.colorVari
	guiControl, main:, alphas, % st_glue(newE.alpha)
	guiControl, main:, lw, % st_glue(newE.lineWidth)
	guiControl, main:, cs, % st_glue(newE.circleSize)
	guiControl, main:text, dirs, % st_glue(newE.pattern)
	guiControl, main:, cycle, 0
	guiControl, main:, relm, 0
	guiControl, main:, relw, 0
	guiControl, main:, speeds, % st_glue(newE.speed)
	guiControl, main:, jitters, % st_glue(newE.jitter)
	guiControl, main:, gravity, % st_glue(newE.gravity)
	guiControl, main:, spiral, % st_glue(newE.spiral)
	guiControl, main:, eLB, Generic||

	gui, main: submit, noHide
	for k, v in contArr
	{
		emitArrGUI[eLB, v]:=%v%
		guiControl, main: +gqueue, %v%
	}
	guiControl, main: +geChanged, eLB

	gosub, changeEProperty
return


clickToSetAnchor:
	coordMode, mouse, client
	mouseGetPos, mx, my, mw, mc
	guiControlGet, drawArea, preview: pos, PDisp
	anchorX:=mx-drawAreaX
	anchorY:=my-drawAreaY
	gosub, CreateBG
return


previewGuiSize:
	guiControl, preview: move, PDisp, % "w" A_GuiWidth " h" A_GuiHeight
	guiControlGet, drawArea, preview: pos, PDisp
	gosub, CreateBG
return


CreateBG:
	Gdip_DeleteGraphics(BGGraphics) ; get rid of the old one
	Gdip_DisposeImage(BGBitmap)     ; get rid of the old one
	BGBitmap:=Gdip_CreateBitmap(drawAreaW, drawAreaH)
	BGGraphics:=Gdip_GraphicsFromImage(BGBitmap)

	; brsh := Gdip_BrushCreateSolid("0xffff4400")
	brsh := Gdip_BrushCreateSolid("0xff" BGCol)
	Gdip_FillRectangle(BGGraphics, brsh, 0, 0, drawAreaW, drawAreaH)
	pen:=Gdip_CreatePen("0x44000000", 2)
	gdip_drawLine(BGGraphics, pen, 0, anchorY, drawAreaW, anchorY)
	gdip_drawLine(BGGraphics, pen, anchorX, 0, anchorX, drawAreaH)
	Gdip_DrawRectangle(BGGraphics, pen, 1, 1, drawAreaW-2, drawAreaH-2)
	Gdip_DeleteBrush(brsh)
	Gdip_DeletePen(pen)
	BGCloned:=Gdip_CloneBitmapArea(BGBitmap, 0, 0, drawAreaW, drawAreaH)
	if (useMouse=0)
		Graphics:=psys.setCanvas(0, 0, drawAreaW, drawAreaH, quality, PHWND)
return


eChanged:
	critical
	gui, main: submit, noHide
	if (eLB=eLBP)
		return
	; msgBox % st_printArr(emitArrGUI)
	for k, v in emitArrGUI[eLB]
	{
		guiControl, main: -g, %k%
		if (k="eType" || k="colormode" || k="colorPre")
			guiControl, main: choose, %k%, %v%
		else if (k="dirs")
			guiControl, main: text, %k%, %v%
		else
			guiControl, main:, %k%, %v%
		guiControl, main: +gqueue, %k%
	}
	eLBP:=eLB
	; guiControl, main: +geChanged, eLB
return


queue:
	critical
	; gui, submit, noHide
	selCtrl:=A_GuiControl
	settimer, changeEProperty, -888
return
changeEProperty:
	critical
	gui, main: default
	gui, main: submit, noHide

	guiControlGet, typeN, main:, eType, text
	if (typeN="")
		typeN:="Generic"
	if (eLB="")
		eLB:=1

	ttt:=""
	if (selCtrl="etype")
	{
		for k in psys.Emitters
		{
			if (a_index=eLB)
				ttt.=typeN "||"
			else
				ttt.=psys.Emitters[k].type "|"
		}
		guiControl, main:, eLB, |%ttt%
	}
	if (selCtrl="colorPre")
	{
		guiControlGet, colorPreN, main:, colorPre, text
		guiControl, main:, colors, % st_glue(gradientPresets[colorPreN], "`n")
		gui, main: submit, noHide
	}

	offx:=(offx="") ? 0 : offx
	offy:=(offy="") ? 0 : offy
	; eLB:=1
	qqq:=psys.Emitters[eLB]
	, qqq.type:=typeN
	, qqq.life:=[lifemin, lifemax]
	, qqq.offx:=offx
	, qqq.offy:=offy

	; , qqq.color:=strSplit(colors, "`n", "`r")
	, qqq.color:=[]
	, qqq.colorMode:=colormode
	, qqq.colorVari:=variations
	, qqq.alpha:=[]
	; , qqq.alpha:=strSplit(trim(alphas, "`r`n `t"), "`n", "`r")

	, qqq.lineWidth:=strSplit(lw, [",", " "])
	, qqq.circleSize:=strSplit(cs, [",", " "])
	, qqq.pattern:=strSplit(dirs, [",", " "])
	, qqq.speed:=strSplit(speeds, [",", " "])
	, qqq.gravity:=strSplit(gravity, [",", " "])
	, qqq.jitter:=strSplit(jitters, [",", " "])
	, qqq.spiral:=strSplit(spiral, [",", " "])

	ttt:="`n, "
	loop, parse, colors, %ttt%, `r ; ignore blanks
		if (trim(A_LoopField)!="")
			qqq.color.push(A_LoopField)
	loop, parse, alphas, %ttt%, `r ; ignore blanks
		if (trim(A_LoopField)!="")
			qqq.alpha.push(A_LoopField)

	if (useFrames=1)
		qqq.life.insertAt(1, "f")
	ttt:=""
	if (cycle=1)
		ttt.="c"
	if (relm=1)
		ttt.="m"
	if (relw=1)
		ttt.="w"
	if (ttt!="")
		qqq.pattern.insertAt(1, ttt)

	if (typeN="Text" || typeN="Image")
	{
		if (typeN="Text")
			eMisc:=strReplace(eMisc, "``n", "`n")
		if (typeN="image")
			eMisc:=trim(eMisc, """")
		transform, eMisc, deref, %eMisc%
		qqq.misc1:=eMisc
		guiControl, main: enable, eMisc
	}
	else
		guiControl, main: disable, eMisc


	guiControlGet, drawArea, preview: pos, PDisp
	if (useMouse!=useMouseP) ;update the canvas size and whatnot
		if (useMouse=1)
			Graphics:=psys.setCanvas(0, 0, A_ScreenWidth, A_ScreenHeight, quality)
			, psys.particles:=[]
		else
			Graphics:=psys.setCanvas(0, 0, drawAreaW, drawAreaH, quality, PHWND)
			, psys.particles:=[]

	useMouseP:=useMouse

	; gui, submit, noHide
	for k, v in contArr
		emitArrGUI[eLB, v]:=%v%

	update:=1000//FPS
	psys.fps:=FPS
	psys.delay:=update
	if (PPS>FPS)
		PPS:=FPS
	if (PPS=0)
		PPS:=1
	PPS:=FPS//PPS
	setTimer, update, %update%
return


update:
	; gui, preview: submit, noHide
	; sleep, 300
	; return

	if (psys.emitters.length()>0)
	{
		frame++
		coordMode, mouse, % (useMouse=1) ? "screen" : "client" ; ahk handles coordmode dumb
		; toolTip, % psys.drawcount "/" psys.emitters.length(), 0

		mouseGetPos, xxx, yyy

		psys.step()
		psys.clear()

		; DRAW THE BACKGROUND CLONE HERE
		if (useMouse=0)
			Gdip_DrawImage(Graphics, BGCloned)

		; ahk has smart evaluation. if it sees PPS>=FPS is true ...
		; ... it'll never do mod(). Doing less division is better
		if (PPS>=FPS || mod(frame, PPS)=0)
		{
			for dummy in psys.Emitters
			{
				if (useMouse=1)
				{
					mouseGetPos, xxx, yyy
					psys.addParticle(xxx, yyy, a_index)
				}
				else
				{
					psys.addParticle(anchorX, anchorY, a_index, eMisc)
				}
			}
		}

		if (useMouse=1)
			psys.draw()
		else
			psys.draw(PHWND)
	}
	; psys.draw() ; ffffffffffff
return




st_glue(array, delim=", ")
{
	if (isObject(array))
		for k,v in array
			new.=v delim
	else
		new:=array
	return trim(new, delim)
}

GroupBox2(Text, Controls, GuiName=1, Offset="0,0", Padding="6,6,6,6", TitleHeight=15)
{
	static
	xx:=yy:=ww:=hh:=PosX:=PosY:=PosW:=PosH:=0
	StringSplit, Padding, Padding, `,
	StringSplit, Offset, Offset, `,
	loop, parse, Controls, `,
	{
		LoopField:=trim(A_LoopField)
		GuiControlGet, Pos, %GuiName%: Pos, %LoopField%
		if (a_index=1)
			xx:=PosX, yy:=PosY, ww:=PosX+PosW, hh:=PosY+PosH
		xx:=((xx<PosX) ? xx : PosX), yy:=((yy<PosY) ? yy : PosY)
		ww:=((ww>PosX+PosW) ? ww : PosX+PosW), hh:=((hh>PosY+PosH) ? hh : PosY+PosH)
		GuiControl, %GuiName%: Move, %LoopField%, % "x" PosX+Padding1+Offset1 " y" PosY+Padding3+Offset2+titleHeight
	}
	xx+=Offset1, yy+=Offset2
	ww+=Padding1+Padding2+Offset1-xx
	hh+=Padding3+Padding4+titleHeight+Offset2-yy
	counter+=1
	UID:="GB" GUIName counter xx yy ww hh
	status := GroupBox2_Add(guiname, xx, yy, ww, hh, uid, text)
	Return (status == true ? [uid,xx,yy,ww,hh] : false)
}
GroupBox2_Add(guiname, xx, yy, ww, hh, uid, text) {
	Global
	Gui, %GuiName%: add, GroupBox, x%xx% y%yy% w%ww% h%hh% 0x800000 v%UID%, %Text%
	return (errorlevel == 0 ? true : false)
}


Dlg_Color(Color,hwnd){
    static
    if !cc{
        VarSetCapacity(CUSTOM,16*A_PtrSize,0),cc:=1,size:=VarSetCapacity(CHOOSECOLOR,9*A_PtrSize,0)
        Loop,16{
            IniRead,col,color.ini,color,%A_Index%,0
            NumPut(col,CUSTOM,(A_Index-1)*4,"UInt")
        }
    }
    NumPut(size,CHOOSECOLOR,0,"UInt"),NumPut(hwnd,CHOOSECOLOR,A_PtrSize,"UPtr")
    ,NumPut(Color,CHOOSECOLOR,3*A_PtrSize,"UInt"),NumPut(3,CHOOSECOLOR,5*A_PtrSize,"UInt")
    ,NumPut(&CUSTOM,CHOOSECOLOR,4*A_PtrSize,"UPtr")
    ret:=DllCall("comdlg32\ChooseColor","UPtr",&CHOOSECOLOR,"UInt")
    if !ret
    exit
    Loop,16
    IniWrite,% NumGet(custom,(A_Index-1)*4,"UInt"),color.ini,color,%A_Index%
    IniWrite,% Color:=NumGet(CHOOSECOLOR,3*A_PtrSize,"UInt"),color.ini,default,color
    return Color
}
rgb(c){
    setformat,IntegerFast,H
    c:=(c&255)<<16|(c&65280)|(c>>16),c:=SubStr(c,1)
    SetFormat,IntegerFast,D
    return substr(c,3)
}


#include %A_ScriptDir%\..\..\lib-a_to_h\Gdip.ahk
#include %A_ScriptDir%\..\class_particles.ahk
