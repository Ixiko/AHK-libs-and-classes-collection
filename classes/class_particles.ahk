/*
Name: Particle System
Version 2.1 (Tuesday, January 17, 2017)
Created: Thursday, December 22, 2016
Author: tidbit
Credit: 
	tic - GDIP
	CaptureCursor - ???
	
Hotkeys:

Description:
	Add a particle system to your script! Lines, circles, connected lines, and much more types!
	Control the speed, angle, jitter and many more properties. Values are transitioned smoothly if more than 1
	value is specified.

	setup:
	; create something we can draw on
	gui, add, picture, xm ym w300 w500 h500 0xE hwndPHWND vPDisp
	gui, show

	; Start gdi+
	pToken:=Gdip_Startup()
	
	; create a system that runs at 30 fps
	psys:=new particles(30)
	
	; create a display/canvas at 100,100 an a size of 500x300, the the best quality (1-4)
	; we set it to draw on the control we made above
	psys.setCanvas( 100, 100, 500, 300, 4, PHWND)

	; add the thing that gives all the particles their properties. blank = defaults
	e1:=psys.addEmitter()
	
	; add multiple emitters!
	e2:=psys.addEmitter()
	e2.speed:=100 ; change the particles of this emitter to move 100px per second
	e2.gravity:=50 ; make the particles fall down

	; now we need particles. the actual things we see.
	psys.addParticle(50, 80) ; create a particle for the default (first) emitter
	psys.addParticle(50, 80, 2) ; create a particle for the second

	; creating particles isn't enough, though. we need to advance the simulation
	; ... but before we do that, we should clear what was drawn previously, so we only see
	; the current frame, not old dead copies.
	psys.clear() ; clear the canvas for preperation to draw the new stuff
	psys.step() ; step forward in time 1 frame!

	; finally, we can show it!
	psys.draw()

	; ... now just add particles, clear, step and draw in a loop/timer and it's animated!
*/

class particles
{
	__New(FPS=30)
	{
		this.defaults:={"type":"Generic", "life":[1], "offx":0, "offy":0
		, "color":"", "colorMode":1, "colorVari":0, "alpha":[255]
		, "lineWidth":[0], "circleSize":[10]
		, "pattern":["r"], "speed":[100], "gravity":[0], "jitter":[0], "spiral":[0]}
		
		this.emitters:=[] ; apparently adding commas makes stuff faster
		this.particles:=[[]]
		this.FPS:=FPS
		this.delay:=1000//FPS
		this.drawCount:=0
	}

	; I know this isn't the proper way to do it, but it works
	getDeltaTime()
	{
		deltaT:=(1000/this.FPS)/1000
		return deltaT
	}
	
	clear(refresh="")
	{
		Gdip_GraphicsClear(this.ggg)
		if (refresh!="")
			UpdateLayeredWindow(refresh, this.hdc, this.cx, this.cy, this.cw, this.ch)
		; brush:=Gdip_BrushCreateSolid("0x7700ff00")
		; Gdip_FillRectangle(this.ggg, brush, 0, 0, this.cw, this.ch)
		; gdip_deleteBrush(brush)
	}
	
	addEmitter(pe="")
	{
		if (!isObject(pe))
			ttt:=this.emitters.push({"type":"Generic"})
		else
			ttt:=this.emitters.push(pe)
			
		
		for dkey, dval in this.defaults
		for ekey, eval in this.emitters
			if ((isObject(dval) && eval[dkey].length()<0) || eval[dkey]="")
				eval[dkey]:=dval
		return this.emitters[ttt]
	}
	
	; Quaity: Default = 0, HighSpeed = 1, HighQuality = 2, None = 3, AntiAlias = 4
	setCanvas(cx, cy, cw, ch, cquality, drawOnThis="") ; c = canvas
	{
		this.clear(this.ID)
		DeleteObject(this.hbm)
		DeleteDC(this.hdc)
		Gdip_DeleteGraphics(this.ggg)
		Gdip_DisposeImage(this.cBitmap)
	
		if (drawOnThis="") ; fullscreen mouse mode
		{
			if (ttt!="")
				gui, %ttt%: destroy
			ttt:=this.ID
			this.cx:=cx
			this.cy:=cy
			this.cw:=cw
			this.ch:=ch
			; ttt:=substr(this.ID, 3)
			; nnn:=rand(1,20000) ; pretty horrible, I know
			gui, new, +hwndMYID -Caption +E0x80000 +AlwaysOnTop +ToolWindow +OwnDialogs +Owner
			; gui, show, x0 y0 NA, mouse particles 
			gui, show, x%cx% y%cy% w%cw% h%ch% NA, mouse particles 
			; msgBox x%cx% y%cy% w%cw% h%ch%
			this.hbm:=CreateDIBSection(cw, ch)
			, this.hdc:=CreateCompatibleDC()
			, this.obm:=SelectObject(this.hdc, this.hbm)
			, this.ggg:=Gdip_GraphicsFromHDC(this.hdc)
			, Gdip_SetSmoothingMode(this.ggg, cquality)
			, this.ID:=MYID
			; , this.ID:=WinExist("mouse particles " nnn)
			WinSet, ExStyle, +0x20, % "ahk_id " this.ID
			; msgBox % this.id

		}
		else ; draw on a bitmap/gui
		{
			winGetPos,,, cw, ch, ahk_id %drawOnThis%
			this.cx:=0
			, this.cy:=0
			, this.cw:=cw
			, this.ch:=ch
			, this.ID:=drawOnThis
			, this.cBitmap:=Gdip_CreateBitmap(cw, ch)
			, this.ggg:=Gdip_GraphicsFromImage(this.cBitmap)
			, Gdip_SetSmoothingMode(this.ggg, cquality)
		}
		return this.ggg
	}
	
	draw(drawOnThis="") ; p = particle, e = emitter
	{
		; eee:=this.emitter
		this.drawCount:=0
		for eeeN in this.emitters
		{
			ppp:=this.particles[eeeN]
			
			; item = current particle #
			; vvv = current particle sub-array properties
			; ppp = particle array
			for item, vvv in ppp 
			{
				color:=vvv.color
				, alpha2:=vvv.alpha
				, alpha:=format("{:02x}", vvv.alpha)
				, type:=vvv.type
				, radius:=vvv.radius
				, lw:=vvv.lineW
				
				if (radius="" || alpha2<1) ; brushes
					radius:=0, alpha:="00"
				else
					brush:=Gdip_BrushCreateSolid("0x" alpha . color)
							
				if (lw="" || alpha2<1) ; lines
					lw:=0, alpha:="00"
				else
					pen:=Gdip_CreatePen("0x" alpha . color, lw)
					, Gdip_SetEndCap(pen, (type!="sparks") ? 2 : 0)
							
				; if (type="Circles" || type="AllLines")
				if (radius>0 && type!="sparks" && type!="text" && type!="image")
					Gdip_FillEllipse(this.ggg, brush, vvv.x1-(radius//2), vvv.y1-(radius//2), radius, radius)
					, this.drawCount+=1
					
				if (lw>0)
				{
					if (type="sparks")
					{
						Gdip_DrawLine(this.ggg, pen
						, vvv.x1, vvv.y1
						, vvv.x1+radius*cos((vvv.dir+vvv.dir2)*3.1415926535/180)
						, vvv.y1+radius*sin((vvv.dir+vvv.dir2)*3.1415926535/180))
						, this.drawCount+=1
					}
					else if (type="AllLines" && ppp.length()>1)
					{
						Loop, % ppp.length()-item
							Gdip_DrawLine(this.ggg, pen
							, ppp[item+a_index].x1, ppp[item+a_index].y1
							, vvv.x2, vvv.y2)
							, this.drawCount+=1
					}
					else if (ppp.length()>1)
						Gdip_DrawLine(this.ggg, pen, vvv.x1, vvv.y1, vvv.x2, vvv.y2) 
						, this.drawCount+=1
				}
				if (type="cursor")
				{
					hcur:=CaptureCursor(this.hdc, vvv.x1+1, vvv.y1)
					; Gdip_DrawImage(this.ggg, hcur)
				}
					
				if (type="text")
				{
					font:="Comic Sans MS"
					, font2:=Gdip_FontFamilyCreate(font)
					, ttt:="x" vvv.x1 " y" vvv.y1 " c" alpha color " s" radius  " r0 " vvv.misc2
					, ttt:=strSplit(Gdip_TextToGraphics(this.ggg, vvv.misc1, ttt, font,,,1), "|")
					, ttt2:="x" vvv.x1-(ttt[3]//2) " y" vvv.y1-(ttt[4]//2) " c" alpha color " s" radius  " r0 " vvv.misc2
					, Gdip_TextToGraphics(this.ggg, vvv.misc1, ttt2, font)
					, Gdip_DeleteFontFamily(font2)
					, this.drawCount+=1
				}
				if (type="image")
				{
					; img:=Gdip_CreateBitmapFromFile("C:\Users\Joe\Pictures\img.jpg")
					; color:=vvv.color
					; toolTip, % "::" vvv.color
					img:=Gdip_CreateBitmapFromFile(color)
					; img:=Gdip_CreateBitmapFromFile(vvv.misc1)
					, Gdip_GetDimensions(img, iw, ih)
					, iw*=radius/100
					, ih*=radius/100
					, Gdip_DrawImage(this.ggg, img, vvv.x1-(iw//2), vvv.y1-(ih//2), iw, ih) 
					, this.drawCount+=1
					, Gdip_DisposeImage(img)
				}
				
				gdip_deletebrush(brush)
				Gdip_DeletePen(pen)
			}
			
			if (instr(this.emitters[eeeN].type, "fill"))
			{
				ttt:=""
				for item, vvv in ppp
					ttt.=vvv.x1 "," vvv.y1 "|"
				ttt:=substr(ttt, 1, -1)
				, color:=vvv.color
				, alpha2:=vvv.alpha
				, alpha:=format("{:02x}", vvv.alpha)
				, brush:=Gdip_BrushCreateSolid("0x" alpha . color)
				, Gdip_FillPolygon(this.ggg, brush, ttt, 1)
				, this.drawCount+=1
				gdip_deletebrush(brush)
				Gdip_DeletePen(pen)
			}
		}
		

		; clipboard:=st_printArr(this.particles)
		if (drawOnThis="")
			UpdateLayeredWindow(this.ID, this.hdc, this.cx, this.cy, this.cw, this.ch)
		else
		{
			hBitmap := Gdip_CreateHBITMAPFromBitmap(this.cBitmap)
			SetImage(drawOnThis, hBitmap)
			DeleteObject(hBitmap)
			Gdip_DisposeImage(hBitmap)
		}
		return this.ggg
	}

	
	step() ; this does all phy physics/color/etc math.
	{
		; if (this.particles.length()<=0)
		; 	return
		deltaT:=this.getDeltaTime()
		eee:=this.emitters
		
		; eeeN = emitter number, really wish I thought of a better way to do this
		for eeeN in eee
		{
			ppp:=this.particles[eeeN]
			ecolor:=eee[eeeN].color
			, ecolorMode:=eee[eeeN].colorMode
			, ealpha:=eee[eeeN].alpha
			, elw:=eee[eeeN].lineWidth
			, ecs:=eee[eeeN].circleSize
			, espeed:=eee[eeeN].speed
			, ejitter:=eee[eeeN].jitter
			, egravity:=eee[eeeN].gravity
			, espiral:=eee[eeeN].spiral
			for bbb, vvv in ppp
			{
				lp:=vvv.life/vvv.mlife ; life percent, its age.
				stage:=vvv.mlife-vvv.life
				if (ecolor.length()>0)
				{
					if (ecolorMode=4) ; gradient over life, reverse
						color:=(ecolor.length()=1) ? ecolor[1] 
						: ecolor[round(1+(ecolor.length()-1)*(lp))]
					else if (ecolorMode=3) ; gradient over life
						color:=(ecolor.length()=1) ? ecolor[1] 
						: ecolor[1+ecolor.length()-1-round((ecolor.length()-1)*(lp))]
					else
						color:=vvv.color
				}
				else
					color:=vvv.color
				color:=strReplace(color, """")
					
				vvv.color:=color
				
				vvv.alpha:=(ealpha.length()=1) ? ealpha[1] : round(numRange(vvv.mlife, stage, ealpha*))
				vvv.radius:=(ecs.length()=1) ? ecs[1] : round(numRange(vvv.mlife, stage, ecs*))
				vvv.lineW:=(elw.length()=1) ? elw[1] : round(numRange(vvv.mlife, stage, elw*))
				gravity:=(egravity.length()=1) ? egravity[1] : round(numRange(vvv.mlife, stage, egravity*))
				speed:=(espeed.length()=1) ? espeed[1] : round(numRange(vvv.mlife, stage, espeed*))
				jitter:=(ejitter.length()=1) ? ejitter[1] : round(numRange(vvv.mlife, stage, ejitter*))
				spiral:=(espiral.length()=1) ? espiral[1] : round(numRange(vvv.mlife, stage, espiral*))
				speed*=deltaT
				jitter*=deltaT
				vvv.dir+=spiral*deltaT*-1
				dir:=vvv.dir
					
				if (eee[eeeN].type="sparks")
					dir+=rand(-jitter,jitter)
					, vvv.dir2+=rand(-360,360)*deltaT
					
				; if (dir>360)
				; 	dir:=mod(dir, 360)
				if gravity is number
					if (gravity!=0)
					{
						vvv.y1+=vvv.vel*5*deltaT
						vvv.vel+=gravity*deltaT
					}
					
				vvv.x1:=vvv.x1+speed*cos((dir)*3.1415926535/180)
				vvv.y1:=vvv.y1+speed*sin((dir)*3.1415926535/180)
				vvv.x1+=rand(-jitter, jitter)
				vvv.y1+=rand(-jitter, jitter)

				ppp[bbb+1].x2:=vvv.x1
				ppp[bbb+1].y2:=vvv.y1
				; 
				; my own gravity system :D sure it's not realistic, but the results are nice, IMO
				; if gravity is number
				; 	if (gravity!=0)
				; 		vvv.y1+=((vvv.mlife-vvv.life)*(gravity))/25
				; 		, vvv.x1-=(vvv.mlife-vvv.life)*0.5
				vvv.life-=1
			}
			
			ttt:=0
			loop, % ppp.length() ; start from the end, not to screw stuff up.
			{
				if (ppp[A_Index-ttt].life<=0)
					ppp.removeAt(A_Index-ttt)
					, ttt+=1
			}
		}
	}
	
	addParticle(px, py, pe=1, misc*)
	{
		static cycleDir:=[], cycleColor:=[], mouseAngle:=0, mouseAngleP:=0, xxxp, yyyp
		eee:=this.emitters[pe]
		; --- LIFE ---
		ttt:=0
		if (eee.life[1]="f")
			ttt:=1
			
		if (eee.life.length()>1+ttt)
			life:=rand(eee.life[1+ttt], eee.life[2+ttt])
		else
			life:=eee.life[1+ttt]
		
		if (eee.life[1]="f")
			life:=life
		else
			life:=floor(life*this.FPS)
		
		; --- COLOR ---
		if (eee.color="" || !isObject(eee.color) || eee.color.length()<1)
			color:=format("{:02x}{:02x}{:02x}",rand(0,255),rand(0,255),rand(0,255))
		else if (eee.color.length()>1)
		{
			(cycleColor[pe]="") ? cycleColor[pe]:=1 : cycleColor[pe]+=1
			if (cycleColor[pe]>eee.color.length())
				cycleColor[pe]:=1
			if (eee.colorMode=2) ; random
				color:=eee.color[rand(eee.color.length())]
			else if (eee.colorMode=1) ; cycle
				color:=eee.color[cycleColor[pe]]
			else
				color:=eee.color[1]
		}
		else
			color:=eee.color[1]
		color:=strReplace(color, ["""", "#"])
			
		if (eee.colorVari!="" && eee.type!="image")
			color:=cshift("0x" color, rand(-eee.colorVari, eee.colorVari))
			
		alpha:=eee.alpha[1]
		
		; --- DIR ---
		epat:=eee.pattern
		if (instr(epat[1], "c"))
		{
			(cycleDir[pe]="") ? cycleDir[pe]:=2 : cycleDir[pe]+=1
			if (cycleDir[pe]>epat.length())
				cycleDir[pe]:=2
			dir:=epat[cycleDir[pe]]
		}
		else if (!isobject(epat) || epat[1]="r")
			dir:=rand(360)
		else
			dir:=epat[rand(epat.length())]

		if (instr(epat[1], "m") || instr(epat[1], "w"))
		{
			mouseGetPos, xxx, yyy
			if (xxx=xxxp && yyy=yyyp)
				mouseAngle:=mouseAngleP
			else
				mouseAngle:=getAngle(xxx,yyy,xxxp,yyyp,2)
			dir+=(xxx=xxxp && yyy=yyyp) ? mouseAngleP : mouseAngle
			
			if (instr(epat[1], "w"))
				dir:=dir+180
				
			mouseAngleP:=floor(mouseAngle)
			xxxp:=xxx
			yyyp:=yyy
		}
		
		if (dir="r")
			dir:=rand(360)

		dir*=-1

		if (!isObject(this.particles[pe]))
			this.particles[pe]:=[]
		; msgBox % this.cx "+" eee.offx "+" px
		this.particles[pe].insertAt(1
		, {"x1":eee.offx+px, "y1":eee.offy+py
		, "x2":eee.offx+px, "y2":eee.offy+py
		; , {"x1":this.cx+eee.offx+px, "y1":this.cy+eee.offy+py
		; , "x2":this.cx+eee.offx+px, "y2":this.cy+eee.offy+py
		, "dir":dir, "vel":0
		, "radius":eee.circleSize[1]
		, "lineW":eee.lineWidth[1]
		, "life":life, "mlife":life
		, "color":color, "alpha":alpha
		, "type":eee.type})
		
		if (eee.type="text")
			this.particles[pe,1].misc1:=misc[1]
			, this.particles[pe,1].misc2:=misc[2]

		if (eee.type="sparks")
			this.particles[pe,1].dir2:=rand(360)
		; toolTip % st_printArr(this.particles) "::" pe
	}


	; these make me cry and will probably be removed
	type(ptype, eNum=1) {
		this.emitters[eNum].type:=ptype
	}	
	qty(pqty, eNum=1) {
		this.emitters[eNum].qty:=pqty
	}
	life(plife, eNum=1) {
		this.emitters[eNum].life:=plife
	}
	offx(poffx, eNum=1) {
		this.emitters[eNum].offx:=poffx
	}
	offy(poffy, eNum=1) {
		this.emitters[eNum].offy:=poffy
	}
	color(pcolor, eNum=1) {
		this.emitters[eNum].color:=pcolor
	}
	colorMode(pcolorMode, eNum=1) {
		this.emitters[eNum].colorM:=pcolorMode
	}
	colorVari(pcolorVari, eNum=1) {
		this.emitters[eNum].colorVari:=pcolorVari
	}
	alpha(palpha, eNum=1) {
		this.emitters[eNum].alpha:=palpha
	}
	lineWidth(plw, eNum=1) {
		this.emitters[eNum].lineWidth:=plw
	}
	circleSize(pcs, eNum=1) {
		this.emitters[eNum].circleSize:=pcs
	}
	pattern(ppattern, eNum=1) {
		this.emitters[eNum].pattern:=ppattern
	}
	speed(pspeed, eNum=1) {
		this.emitters[eNum].speed:=pspeed
	}
	gravity(pgravity, eNum=1) {
		this.emitters[eNum].gravity:=pgravity
	}
	jitter(pjitter, eNum=1) {
		this.emitters[eNum].jitter:=pjitter
	}
}

rand(max=100, min=1)
{
	if (min>max)
		t:=max, max:=min, min:=t
	random, r, %min%, %max%
	return r
}

; mode: 1=0-180, 2=0-359.999
getAngle(x1,y1,x2,y2, mode=1)
{
	angle:=atan2(y1-y2, x1-x2)*(180/3.14159)*-1
	if (mode=2)
		angle+=(angle<0) ? 360 : 0 ; or should it be 359? whatever.
	return angle
}

; 4-quadrant atan, thanks ymg! http://www.autohotkey.com/board/topic/88476-vincenty-formula-for-latitude-and-longitude-calculations/
atan2(y,x) { 
   Return dllcall("msvcrt\atan2","Double",y, "Double",x, "CDECL Double")
}

numRange(steps, IWantThis="", numbers*)
{
	age:=0
	sets:=numbers.length()-1
	sectionSize:=floor(steps/sets)
	which:=0
	total:=numbers[1]
	out:=[]
	if (numbers.length()=1)
		return numbers[1]
	loop, %steps%
	{
		age+=1
		total+=stepSize
		if (age>=sectionSize || a_index=1)
		{
			which+=1
			age:=0
			numFrom:=numbers[which]
			numTo:=numbers[which+1]
			if (numTo="")
				numTo:=numFrom
			total-=stepSize
			stepSize:=(numTo-numFrom)/(round(steps/sets)-1)
		}
		if (IWantThis="")
			out.push(total)
		else if (A_Index=IWantThis)
			return total
	}
	return out
}

cshift(hex, lum=0.5, mode=2) 
{
	for k, val in [substr(hex, 3, 2), substr(hex, 5, 2), substr(hex, 7, 2)] ; split the hex into an array of [##,##,##]
		val:=format("{1:d}", "0x" val) ; convert from hex, to decimal values
		, val:=round((mode=1) ? val*lum : val+lum) ; do the math
		, val:=(val<0) ? 0 : (val>255) ? 255 : val ; clamp the values between 0 and 255
		, out.=format("{1:02}", format("{1:x}", val)) ; build it again, make sure each hex thing is 2 chars long
	return out ; we're done!
}


Gdip_SetEndCap(pPen, cap=2)
{
	return DllCall("gdiplus\GdipSetPenLineCap197819", "UPtr", pPen, "Uint", cap, "Uint", cap, "Uint", 3)
}


CaptureCursor(hDC, nL=10, nT=10)
{
	VarSetCapacity(mi, 20, 0)
	mi := Chr(20)
	DllCall("GetCursorInfo", "Uint", &mi)
	bShow   := NumGet(mi, 4)
	hCursor := NumGet(mi, 8)

	VarSetCapacity(ni, 20, 0)
	DllCall("GetIconInfo", "Uint", hCursor, "Uint", &ni)
	xHotspot := NumGet(ni, 4)
	yHotspot := NumGet(ni, 8)

	If bShow
		DllCall("DrawIcon", "Uint", hDC, "int", nL-xHotspot , "int", nT-yHotspot, "Uint", hCursor)
	return Gdip_CreateBitmapFromHBITMAP(hCursor) ; fails
}


st_printArr(array, depth=5, indentLevel="")
{
	for k,v in Array
	{
	list.= indentLevel "[" k "]"
	if (IsObject(v) && depth>1)
		list.="`n" st_printArr(v, depth-1, indentLevel . "    ")
	Else
		list.=" => " v
		list.="`n"
	}
	return rtrim(list)
}
