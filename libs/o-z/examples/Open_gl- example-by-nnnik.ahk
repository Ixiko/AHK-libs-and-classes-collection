; Author: nnnik

#Persistent
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,all,off ; Recommended for catching common errors.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchlines,-1
#Include agl.ahk
#Include gl.ahk
#Include glu.ahk
#Include wgl.ahk
 
aglinit()
 
Gui,+LastFound
Gui, Add, Picture,vPicture x0 y0 w640 h640, tex1.jpg
Gui,Add,Text,gDraw y645 w400 x0 vText,Play
Gui,Add,Button,gDraw y645 x600,Play
Gui, show
hRC := aglUseGuiControl("Picture")
hDC := wglGetCurrentDC()
var:=0
glEnable(GL_TEXTURE_2D)
glEnable(GL_DEPTH_TEST)
glEnable(GL_LIGHTING)
glEnable(GL_LIGHT0)
glEnable(GL_COLOR_MATERIAL)
aglLoadMipmaps2D(GL_TEXTURE_2D, "tex1.jpg")
aglLoadMipmaps2D(GL_TEXTURE_2D, "tex2.png")
aglLoadMipmaps2D(GL_TEXTURE_2D, "tex3.png")
aglLoadMipmaps2D(GL_TEXTURE_2D, "tex4.png")


VarSetCapacity(buf, 16, 0)
NumPut(-100, buf, 8, "float")
glLightfv(GL_LIGHT0, GL_POSITION, &buf)


sphere:={pos:[0,0.89,0],movementspeed:[0,0,0],force:[0,-0.00007,0],size:0.1,timefactor:2,draw:func("drawsphere"),tex:3}
sphere2:={pos:[0,-0.9,0],movementspeed:[0.001,0,0],force:[0,0,0],size:0.1,timefactor:3,draw:func("drawsphere"),tex:3}
opengl:={objects:[sphere,sphere2],draw:func("drawgl")}
Settimer,Draw,% 1000//60
return
Draw:
opengl.draw()
MaxSpeedX:=((opengl.objects[1].movementspeed[2]**2)**0.5>MaxSpeedX)?opengl.objects[1].movementspeed[2]:MaxSpeedX
GuiControl,,Text,% "SpeedX: " opengl.objects[1].movementspeed[2] " MaxSpeedX: " MaxSpeedX
return
 
GuiClose:
ExitApp
 
Drawsphere(this)
{
	global GL_TRUE
	antipos:=[]
	For Each,val in this.pos
	antipos[each]:=-val
	GlTranslateF(this.pos*)
	sph:=glunewQuadric()
	if this.tex
	{
		AglSetActiveTex(this.tex)
		gluQuadricTexture(sph,GL_TRUE)
		;gluQuadricNormals(sph, GL_SMOOTH)
	}
	Glusphere(sph,this.size,100,100)
	GlTranslateF(antipos*)	
}
 
Drawgl(this)
{
	global
	glClear(GL_COLOR_BUFFER_BIT)
	glClear(GL_DEPTH_BUFFER_BIT)
	glLoadIdentity()
	localobj:=this.objects
	col:=0
	for each, obj in localobj
	{
		Loop,3
		{
			m:=A_Index
			obj.pos[m]+=1/2*obj.force[m]*obj.timefactor**2+obj.movementspeed[m]*obj.timefactor
			obj.movementspeed[m]+=obj.force[m]*obj.timefactor
			if ((obj.pos[m]+obj.size>=1)||(obj.pos[m]-obj.size<=-1))
			obj.movementspeed[m]:=0>(v:=(obj.movementspeed[m]))*-((obj.pos[m]>0)*2-1)?-v:v
		}
		obj.draw()
	}
	SwapBuffers(hDC)
}