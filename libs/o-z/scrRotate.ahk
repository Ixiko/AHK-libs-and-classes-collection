; Title:   	Is there really no way to set screen orientation in modern Windows 10?
; Link:   		https://www.autohotkey.com/boards/viewtopic.php?f=76&t=87453
; Author:	malcev && BoBo
; Date:   	2021-08-21
; for:     	AHK_L

/*

	;  'scr(een)Rotate'-function based on code kindly provided by malcev:
	;	https://www.autohotkey.com/boards/viewtopic.php?p=384743#p384743
	;	Params ...
	;		clock mode:	3/6/9/12
	;		angle degree:	0/90/180/270/360
	;		direction:		t/r/b/l

	F1::scrRotate(3)			; rotating to 3 o'clock
	F2::scrRotate(180)			; rotating 180°
	F3::scrRotate(9)			; rotating to 9 o'clock
	F4::scrRotate(360)			; rotating 360° (default)
	F5::scrRotate("b")			; rotating towards the bottom of the screen
	F6::scrRotate("default")	; rotating to default position (12 o'clock AKA 360°/0° AKA 'top')
	F7::scrRotate("d")			; rotating to d(efault) position (12 o'clock AKA 360°/0° AKA 'top')
	F8::scrRotate()				; throwing 'parameter advise'-message.

*/


scrRotate(param:="") {
	if param not in 0,3,6,9,12,90,180,270,360,default,d,t,r,b,l
		MsgBox % "Valid parameters are: 0,3/6/9/12/90/180/270/360/default/d/t/r/b/l"
	else {
		mode:=	(param=0) || (param=12)  || (param=360) || (param=t)?	DMDO_DEFAULT:=0
			:	(param=9) || (param=90)	 || (param=r)				?	DMDO_90		:=1
			:	(param=6) || (param=180) || (param=b)				?	DMDO_180	:=2
			:	(param=3) || (param=270) || (param=l)				?	DMDO_270	:=3
			:	(param=default)										?	DMDO_DEFAULT:=0
			:	(param=d)											?	DMDO_DEFAULT:=0
		VarSetCapacity(DEVMODE, 220, 0)
		NumPut(220, DEVMODE, 68, "short")										; dmSize
		DllCall("EnumDisplaySettingsW", "ptr", 0, "int", -1, "ptr", &DEVMODE)

		width	:= NumGet(DEVMODE, 172, "uint")
		height	:= NumGet(DEVMODE, 176, "uint")

		NumPut(width, DEVMODE, 176, "int")
		NumPut(height, DEVMODE, 172, "int")
		NumPut(mode, DEVMODE, 84, "int")										; dmDisplayOrientation
		DllCall("ChangeDisplaySettingsW", "ptr", &DEVMODE, "uint", 0)
		}
	}