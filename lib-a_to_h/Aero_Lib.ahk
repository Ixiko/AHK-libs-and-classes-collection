/*

Aero_Libary

DWM - - Desktop Window Manager
Name: Aero_Lib
Autors:= Bentschi ; RaptorOne ;
Beta From 11.10.10

Funktions:
Aero_StartUp() ; Load important dll Files for more perfomance. ; Line: 52
Aero_Enable() ; Enable or disable the DWM. ; Line: 82
Aero_IsEnabled() ; Return True if DWM is enabled, False if it disabled. ; Line: 104
Aero_BlurWindow() ; Set a Blur behind a window. ; Line: 135
Aero_GuiBlurWindow() ; Set a Blur behind a window. ; Line: 174
Aero_ChangeFrameArea() ; Extend the Frame Area into the Client Area. ; Line: 220
Aero_GuiChangeFrameArea() ; Extend the Frame Area into the Client Area. ; Line: 261
Aero_ChangeFrameAreaAll() ; Extend the Frame Area into the whole Client Area. ; Line: 291
Aero_GuiChangeFrameAreaAll() ; Extend the Frame Area into the whole Client Area. ; Line: 316
Aero_GetDWMColor() ; Gets the Color of the current DWM options. ; Line: 337
Aero_GetDWMTrans() ; Gets the Transparent of the Current DWM options. ; Line: 362
Aero_SetDWMColor() ; Set큦 the DWM Window Color. ; Line: 389
Aero_SetTrans() ; Set큦 the DWM Transparent value. ; Line: 416
Aero_DrawPicture() ; Draws a Picture onto a DWM Gui. ; Line: 454
Aero_CreateBuffer() ; Creates a buffer from a Handle. ; Line: 481
Aero_CreateGuiBuffer() ; Creates a buffer from a GuiCount. ; Line: 502
Aero_DeleteBuffer() ; Deletes a buffer. ; Line: 523
Aero_UpdateWindow() ; Updates a window where is a DWM draw. ; Line: 550
Aero_UpdateGui() ; Updates a window where is a DWM draw. ; Line: 574
Aero_AutoRepaint() ; Set a Buffer to Autoredraw, everytime it is need it. ; Line: 598
Aero_AutoRepaintGui() ; Set a Buffer to Autoredraw, everytime it is need it. ;Line: 622
Aero_DisableAutoRepaint() ; Disables the AutoRedraw. ; Line: 643
Aero_DisableAutoRepaintGui() ; Disables the AutoRedraw. ; Line: 664
Aero_ClearBuffer() ; Clears a Buffer. ; Line: 685
Aero_LoadImage() ; Load image in a variable. ; Line: 714
Aero_DeleteImage() ; Deletes a loaded image. ; Line: 745
Aero_DrawImage() ; Draw the Picture on the Window. ; Line: 779
Aero_End() ; Unload the dll Files. ; Line: 805
*/

;============================================================================
; Funktion
; Api Name: LoadLibary (Kernel32.dll)
;
; Aero_StartUp()
;
; Load important dll Files for more perfomance.
;
;
; Return: Module Id큦 (splittet with "|") (or false if OS is not compatible)
;
Aero_StartUp(){
	global
	If(A_OSVersion=="WIN_VISTA" || A_OSVersion=="WIN_7")
	{
		MODULEID3:=DllCall("LoadLibrary", "str", "dwmapi")
		MODULEID2:=DllCall("LoadLibrary", "str", "uxtheme") ;zwar noch nicht gebraucht aber egal
		MODULEID:=MODULEID3 . "|" . MODULEID2
		Return,MODULEID
	}Else{
		MsgBox, 4112, DWM Stop, Dwm cannot applied with these OS version.
		Return,False
	}
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DwmEnableComposition (dwmapi.dll)
;
; Aero_Enable()
;
; Enable or disable the DWM.
;
; Params:
;
; 1. enableBool (True == 1)
;    TRUE change to Aero Theme, False change to Windows Basic Theme.
;
; Return: A_LastError
;
Aero_Enable(enableBool=1){
	global
	If(!MODULEID)
		Aero_StartUp()
	If(A_OSVersion=="WIN_VISTA" || A_OSVersion=="WIN_7")
		DllCall("dwmapi\DwmEnableComposition","UInt",enableBool)
	Else
		MsgBox, 4112, DWM Stop, Dwm cannot applied with these OS version.
	Return,A_LastError
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DwmIsCompositionEnabled (dwmapi.dll)
;
; Aero_IsEnabled()
;
; Return True if DWM is enabled, False if it disabled.
;
; Return: EnabledBool
;
Aero_IsEnabled(){
	global
	If(!MODULEID)
		Aero_StartUp()
	VarSetCapacity(_ISENABLED,4)
	DllCall("dwmapi\DwmIsCompositionEnabled","UInt",&_ISENABLED)
	Return,NumGet(&_ISENABLED,0)
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DwmEnableBlurBehindWindow (dwmapi.dll)
;
; Aero_BlurWindow()
;
; Set a Blur behind a window.
;
; Params:
;
; 1. hwndWin
;    The handle to the window on which the blur behind data is applied.
;
; 2. enableBool (True == 1)
;    TRUE to register the window handle to DWM blur behind; FALSE to unregister the window handle from DWM blur behind.
;
; 3. region (False == 0)
;    The region within the client area to apply the blur behind. A NULL value will apply the blur behind the entire client area.
;
; Return: A_LastError
;
Aero_BlurWindow(hwndWin ,enableBool=1 ,region=0){
	global
	If(!MODULEID)
		Aero_StartUp()
	If(region)
		dwmConstant:=0x00000001 | 0x00000002 ;DWM_BB_ENABLE | DWM_BB_BLURREGION
	Else
		dwmConstant:=0x00000001 ;DWM_BB_ENABLE
	VarSetCapacity(DWM_BLURBEHIND,16)
		NumPut(dwmConstant,&DWM_BLURBEHIND,0,"UInt")
		NumPut(enableBool,&DWM_BLURBEHIND,4,"UInt")
		NumPut(region,&DWM_BLURBEHIND,8,"UInt")
		NumPut(False,&DWM_BLURBEHIND,12,"UInt")
	DllCall("dwmapi\DwmEnableBlurBehindWindow","UInt",hwndWin,"UInt",&DWM_BLURBEHIND)
	Return,A_LastError
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DwmEnableBlurBehindWindow (dwmapi.dll)
;
; Aero_GuiBlurWindow()
;
; Set a Blur behind a window.
;
; Params:
;
; 1. GuiNum (deafult == current Gui)
;    Gui Number.
;
; 2. enableBool (True == 1)
;    TRUE to register the window handle to DWM blur behind; FALSE to unregister the window handle from DWM blur behind.
;
; 3. region (False == 0)
;    The region within the client area to apply the blur behind. A NULL value will apply the blur behind the entire client area.
;
; Return: A_LastError
;
Aero_GuiBlurWindow(GuiNum="default" ,enableBool=1 ,region=0){
	global
	If(!MODULEID)
		Aero_StartUp()
	If(region)
		dwmConstant:=0x00000001 | 0x00000002 ;DWM_BB_ENABLE | DWM_BB_BLURREGION
	Else
		dwmConstant:=0x00000001 ;DWM_BB_ENABLE
	VarSetCapacity(DWM_BLURBEHIND,16)
		NumPut(dwmConstant,&DWM_BLURBEHIND,0,"UInt")
		NumPut(enableBool,&DWM_BLURBEHIND,4,"UInt")
		NumPut(region,&DWM_BLURBEHIND,8,"UInt")
		NumPut(False,&DWM_BLURBEHIND,12,"UInt")
	Gui, % ((GuiNum="default") ? "" : GuiNum ":") "+LastFound"
	DllCall("dwmapi\DwmEnableBlurBehindWindow","UInt",WinExist(),"UInt",&DWM_BLURBEHIND)
	Return,A_LastError
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DwmExtendFrameIntoClientArea (dwmapi.dll)
;
; Aero_ChangeFrameArea()
;
; Extend the Frame Area into the Client Area.
;
; Params:
;
; 1. hwndWin
;    The handle to the window for which the frame is extended into the client area.
;
; 2. leftPos (0)
;    Width of the left border that retains its size.
;
; 3. rightPos (0)
;    Width of the right border that retains its size.
;
; 2. topPos (0)
;    Height of the top border that retains its size.
;
; 3. bottomPos (0)
;    Height of the bottom border that retains its size.
;
; Return: A_LastError
;
Aero_ChangeFrameArea(hwndWin, leftPos=0, rightPos=0, topPos=0, bottomPos=0){
	global
	If(!MODULEID)
		Aero_StartUp()
	VarSetCapacity(_MARGINS,16)
		NumPut(leftPos,&_MARGINS,0,"UInt")
		NumPut(rightPos,&_MARGINS,4,"UInt")
		NumPut(topPos,&_MARGINS,8,"UInt")
		NumPut(bottomPos,&_MARGINS,12,"UInt")
	DllCall("dwmapi\DwmExtendFrameIntoClientArea", "UInt", hwndWin, "UInt", &_MARGINS)
	Return,A_LastError
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DwmExtendFrameIntoClientArea (dwmapi.dll)
;
; Aero_GuiChangeFrameArea()
;
; Extend the Frame Area into the Client Area.
;
; Params:
;
; 1. GuiNum (default == current Gui)
;    Gui Number.
;
; 2. leftPos (0)
;    Width of the left border that retains its size.
;
; 3. rightPos (0)
;    Width of the right border that retains its size.
;
; 2. topPos (0)
;    Height of the top border that retains its size.
;
; 3. bottomPos (0)
;    Height of the bottom border that retains its size.
;
; Return: A_LastError
;
Aero_GuiChangeFrameArea(GuiNum="default", leftPos=0, rightPos=0, topPos=0, bottomPos=0){
	global
	If(!MODULEID)
		Aero_StartUp()
	VarSetCapacity(_MARGINS,16)
		NumPut(leftPos,&_MARGINS,0,"UInt")
		NumPut(rightPos,&_MARGINS,4,"UInt")
		NumPut(topPos,&_MARGINS,8,"UInt")
		NumPut(bottomPos,&_MARGINS,12,"UInt")
	Gui, % ((GuiNum="default") ? "" : GuiNum ":") "+LastFound"
	DllCall("dwmapi\DwmExtendFrameIntoClientArea", "UInt", WinExist(), "UInt", &_MARGINS)
	Return,A_LastError
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DwmExtendFrameIntoClientArea (dwmapi.dll)
;
; Aero_ChangeFrameAreaAll()
;
; Extend the Frame Area into the whole Client Area.
;
; Params:
;
; 1. hwndWin
;    The handle to the window for which the frame is extended into the client area.
;
; Return: A_LastError
;
Aero_ChangeFrameAreaAll(hwndWin){
	global
	If(!MODULEID)
		Aero_StartUp()
	VarSetCapacity(_AllMARGINS,16,-1)
	DllCall("dwmapi\DwmExtendFrameIntoClientArea", "UInt", hwndWin, "UInt", &_AllMARGINS)
	Return,A_LastError
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DwmExtendFrameIntoClientArea (dwmapi.dll)
;
; Aero_GuiChangeFrameAreaAll()
;
; Extend the Frame Area into the whole Client Area.
;
; Params:
;
; 1. GuiNum (default == current Gui)
;    Number of a Gui
;
; Return: A_LastError
;
Aero_GuiChangeFrameAreaAll(GuiNum="deafult"){
	global
	If(!MODULEID)
		Aero_StartUp()
	VarSetCapacity(_AllMARGINS,16,-1)
	Gui, % ((GuiNum="default") ? "" : GuiNum ":") "+LastFound"
	DllCall("dwmapi\DwmExtendFrameIntoClientArea", "UInt", WinExist(), "UInt", &_AllMARGINS)
	Return,A_LastError
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DwmGetColorizationColor (dwmapi.dll)
;
; Aero_GetDWMColor()
;
; Gets the Color of the current DWM options.
;
; Return: dwmColor (0xAARRGGBB)
;
Aero_GetDWMColor(){
	global
	If(!MODULEID)
		Aero_StartUp()
	VarSetCapacity(dwmColor,16)
	VarSetCapacity(subend,4)
	DllCall("dwmapi\DwmGetColorizationColor", "UInt", &dwmColor, "UInt", &subend)
	SetFormat,integer,hex
	dwmColor2:=NumGet(&dwmColor,0)+0
	SetFormat,IntegerFast,d
	Return,dwmColor2
}
;============================================================================


;============================================================================
; Funktion
; Api Name: DwmGetColorizationColor (dwmapi.dll)
;
; Aero_GetDWMTrans()
;
; Gets the Transparent of the Current DWM options.
;
; Return: dwmTransparent (False==Transparent ; True==Not Transparent)
;
Aero_GetDWMTrans(){
	global
	If(!MODULEID)
		Aero_StartUp()
	VarSetCapacity(subend,16)
	VarSetCapacity(dwmTrans,4)
	DllCall("dwmapi\DwmGetColorizationColor", "UInt", &subend, "UInt", &dwmTrans)
	Return,NumGet(&dwmTrans,0,"UInt")
}
;============================================================================


;============================================================================
; Funktion
; Api Name: none ()
;
; Aero_SetDWMColor()
;
; Set큦 the DWM Window Color.
;
; Params:
;
; 1. dwmColor
;    A 32 bit Color (0xAARRGGBB)
;
; Return: A_LastError
;
Aero_SetDWMColor(dwmColor=0x910047ab){
	global
	If(!MODULEID)
		Aero_StartUp()
	RegWrite,REG_DWORD,HKCU,Software\Microsoft\Windows\DWM,ColorizationColor,%dwmColor%
	RegWrite,REG_DWORD,HKCU,Software\Microsoft\Windows\DWM,ColorizationAfterglow,%dwmColor%
	DllCall("dwmapi\DwmEnableComposition","UInt",False)
	DllCall("dwmapi\DwmEnableComposition","UInt",True)
	Return,A_LastError
}
;============================================================================

;============================================================================
; Funktion
; Api Name: none ()
;
; Aero_SetTrans()
;
; Set큦 the DWM Transparent value.
;
; Params:
;
; 1. dwmTrans
;    A Bool. False is transparent, True is not Transparent.
;
; Return: A_LastError
;
Aero_SetTrans(dwmTrans){
	global
	If(!MODULEID)
		Aero_StartUp()
	RegWrite,REG_DWORD,HKCU,Software\Microsoft\Windows\DWM,ColorizationOpaqueBlend,%dwmTrans%
	DllCall("dwmapi\DwmEnableComposition","UInt",False)
	DllCall("dwmapi\DwmEnableComposition","UInt",True)
	Return,A_LastError
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many xD (view in source)
;
; Aero_DrawPicture()
;
; Draws a Picture onto a DWM Gui.
;
; Params:
;
; 1. hwnd
;    Handle of the Window which the Picture is to draw.
;
; 2. picturePath
;    Path to a Picture (All supportet Gdi32 Pictures (also Transparent Pictures))
;
; 3. xPos (0)
;    X Position where the Picture is to draw.
;
; 4. yPos (0)
;    Y Position where the Picture is to draw.
;
; 5. autoUpdate (True==1)
;    Redraw the Picture everytime need it.
;
; Return: The Buffer of the Picture.
;
Aero_DrawPicture(hwnd,picturePath,xPos=0,yPos=0,autoUpdate=1){
	hBuffer := Aero_CreateBuffer(hwnd)
	hImage := Aero_LoadImage(picturePath)
	Aero_DrawImage(hBuffer, hImage, xPos, yPos)
	If(autoUpdate)
		Aero_AutoRepaintGui(hBuffer)
	Aero_DeleteImage(hImage)
	Return,hBuffer
}
;============================================================================


;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_CreateBuffer()
;
; Creates a buffer from a Handle.
;
; Params:
;
; 1. hWnd
;    Handle of the Window which the buffer is applied.
;
; Return: Created buffer.
;
Aero_CreateBuffer(hWnd){
	hDC := DllCall("GetDC", "uint", hWnd)
	Return Aero_CreateBufferFromBuffer(hDC)
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_CreateGuiBuffer()
;
; Creates a buffer from a GuiCount.
;
; Params:
;
; 1. GuiNum (default==current Gui)
;    Gui number
;
; Return: Created buffer.
;
Aero_CreateGuiBuffer(GuiNum="default"){
	Gui, % ((GuiNum="default") ? "" : GuiNum ":") "+LastFound"
	Return Aero_CreateBuffer(WinExist())
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_DeleteBuffer()
;
; Deletes a buffer.
;
; Params:
;
; 1. hBuffer
;    Handle of a Buffer.
;
; Return: True
;
Aero_DeleteBuffer(byref hBuffer){
	hBitmap := DllCall("GetCurrentObject", "uint", hBuffer, "uint", 7)
	DllCall("DeleteDC", "uint", hBuffer)
	DllCall("DeleteObject", "uint", hBitmap)
	hBuffer := 0
	Return 1
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_UpdateWindow()
;
; Updates a window where is a DWM draw.
;
; Params:
;
; 1. hWnd
;    Handle of the window who is to update.
;
; 2. hBuffer
;    A handle of a Buffer
;
; Return: NonZero if succes otherwise NULL
;
Aero_UpdateWindow(hWnd, hBuffer){
	hDC := DllCall("GetDC", "uint", hWnd)
	Return Aero_Blit(hDC, hBuffer)
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_UpdateGui()
;
; Updates a window where is a DWM draw.
;
; Params:
;
; 1. hBuffer
;    Handle of a Buffer.
;
; 2. GuiNum (default == current Gui)
;    Gui number.
;
; Return: NonZero if succes otherwise NULL
;
Aero_UpdateGui(hBuffer, GuiNum="default"){
	Gui, % ((GuiNum="default") ? "" : GuiNum ":") "+LastFound"
	Return Aero_UpdateWindow(WinExist(), hBuffer)
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_AutoRepaint()
;
; Set a Buffer to Autoredraw, everytime it is need it.
;
; Params:
;
; 1. hWnd
;    Handle of a Window.
;
; 2. hBuffer
;    handle of a Buffer.
;
; Return: Errorlevel
;
Aero_AutoRepaint(hWnd, hBuffer){
	OnMessage(0x0F, "Aero_AutoRepaintCallback")
	Return Aero_AutoRepaintCallback(hBuffer, 0, "register", hWnd)
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_AutoRepaintGui()
;
; Set a Buffer to Autoredraw, everytime it is need it.
;
; Params:
;
; 1. hBuffer
;    Handle of a buffer.
;
; 2. GuiNum (default == current Gui)
;    Gui Number.
;
; Return: ErrorLevel
;
Aero_AutoRepaintGui(hBuffer, GuiNum="default"){
	Gui, % ((GuiNum="default") ? "" : GuiNum ":") "+LastFound"
	Return Aero_AutoRepaint(WinExist(), hBuffer)
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_DisableAutoRepaint()
;
; Disables the AutoRedraw.
;
; Params:
;
; 1. hWnd
;    Handle of the Window.
;
; Return: True
;
Aero_DisableAutoRepaint(hWnd){
	Aero_AutoRepaint(hWnd, "")
	Return 1
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_DisableAutoRepaintGui()
;
; Disables the AutoRedraw.
;
; Params:
;
; 1. GuiNum (default == current Gui)
;    Gui Number.
;
; Return: True
;
Aero_DisableAutoRepaintGui(GuiNum="default"){
	Gui, % ((GuiNum="default") ? "" : GuiNum ":") "+LastFound"
	Return Aero_DisableAutoRepaint(WinExist())
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_ClearBuffer()
;
; Clears a Buffer.
;
; Params:
;
; 1. hBuffer
;    Handle of a Buffer.
;
; Return: True for succes otherwise False
;
Aero_ClearBuffer(hBuffer){
	VarSetCapacity(Img, 24, 0)
	hBitmap := DllCall("GetCurrentObject", "uint", hBuffer, "uint", 7)
	DllCall("GetObject", "uInt", hBitmap "uInt", 24, "uInt", &Img)
	VarSetCapacity(rect, 16, 0)
		NumPut(((NumGet(Img, 4)=0) ? A_ScreenWidth : NumGet(Img, 4)), rect, 8, "int")
		NumPut(((NumGet(Img, 8)=0) ? A_ScreenHeight : NumGet(Img, 8)), rect, 12, "int")
	hBrush := DllCall("CreateSolidBrush", "uint", 0)
	retval := DllCall("FillRect", "uint", hBuffer, "uint", &rect, "uint", hBrush)
	DllCall("DeleteObject", "uint", hBrush)
	Return ((retval!=0) ? 1 : 0)
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_LoadImage()
;
; Load image in a variable.
;
; Params:
;
; 1. FileName
;    Path to a Picture (All suportet Gdi32 Pictures)
;
; Return: The Image.
;
Aero_LoadImage(Filename){
	DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(pGdiplusToken, 4, 0)
	VarSetCapacity(pGdiplusInput, 16, 0)
		NumPut(1, pGdiplusInput)
	DllCall("gdiplus\GdiplusStartup", "uint", &pGdiplusToken, "uint", &pGdiplusInput, "uint", 0)
	Aero_MultibyteToWide(Filename, WideFilename)
	DllCall("gdiplus\GdipCreateBitmapFromFile", "uint", &WideFilename, "uint*", GdiplusBitmap)
	DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "uint", GdiplusBitmap, "uint*", hImage, "uint", 0xFF000000)
	DllCall("gdiplus\GdipDisposeImage", "uint", GdiplusBitmap)
	DllCall("gdiplus\GdiplusShutdown", "uint", NumGet(pGdiplusToken))
	DllCall("FreeLibrary", "uint", DllCall("GetModuleHandle", "str", "gdiplus"))
	Return hImage
}
;============================================================================

;============================================================================
; Funktion
; Api Name: DeleteObject (Gdi32.dll)
;
; Aero_DeleteImage()
;
; Deletes a loaded image.
;
; Params:
;
; 1. hImage
;    A Image in a variable.
;
; Return: True
;
Aero_DeleteImage(byref hImage){
	DllCall("DeleteObject", "uint", hImage)
	hImage := 0
	Return 1
}
;============================================================================

;============================================================================
; Funktion
; Api Name: many (view in source)
;
; Aero_DrawImage()
;
; Draw the Picture on the Window.
;
; Params:
;
; 1. hBuffer
;    Handle to a Buffer
;
; 2. hImage
;    An Image.
;
; 3. x (0)
;    X Position of the Picture
;
; 3. y (0)
;    Y Position of the Picture
;
; 3. alpha (256 (0xFF))
;    Alpha Value.
;
; Return: Selected Buffer.
;
Aero_DrawImage(hBuffer, hImage, x=0, y=0, alpha=0xFF){
	If (hImage = 0)	
		Return 0
	hBufferSrc := DllCall("CreateCompatibleDC", "uint", hBuffer)
	DllCall("SelectObject", "uint", hBufferSrc, "uint", hImage)
	retval := Aero_AlphaBlend(hBuffer, hBufferSrc, x, y, alpha)
	DllCall("DeleteDC", "uint", hBufferSrc)
	Return retval
}
;============================================================================

;============================================================================
; Funktion
; Api Name: FreeLibary (Kernel32.dll)
;
; Aero_End()
;
; Unload the dll Files.
;
; Params:
;
; 1. MODUELIDPARAM_ (""nonzero"")
;    The Return MODULID from Aero_StartUp() .
;
; Return: True for succes otherwise False for fail
;
Aero_End(MODUELIDPARAM_=""){
	global
	If(MODUELIDPARAM_)
	{
		StringSplit,MODULEIDARRAY,MODULEID,% "|"
		Loop,%MODULEIDARRAY0%
			DllCall("FreeLibary", "Uint", MODULEIDARRAY%A_Index%)
		Return,True	
	}Else{
		If(MODULEID)
		{
			StringSplit,MODULEIDARRAY,MODULEID,% "|"
			Loop,%MODULEIDARRAY0%
				DllCall("FreeLibary", "Uint", MODULEIDARRAY%A_Index%)
			Return,True	
		}Else{
			MsgBox, 4144, DWM Stop, No Loaded Libarys found.`n`nAero_End() fail !
			Return,False
		}
	}
}
;============================================================================


;============================================================================
;============================================================================
;============================================================================
;=============================PRIVATE FUNKTIONS==============================
;============================================================================
;============================================================================
Aero_CreateBufferFromBuffer(hBuffer)
{
  hNewBuffer := DllCall("CreateCompatibleDC", "uint", hBuffer)
  if (hBufferOut=0)
    Return 0
  w := DllCall("GetDeviceCaps", "uint", hBuffer, "int", 8)
  h := DllCall("GetDeviceCaps", "uint", hBuffer, "int", 10)
  VarSetCapacity(bmi, 40, 0)
  NumPut(40, bmi, 0, "uint")
  NumPut(((w=0) ? A_ScreenWidth : w), bmi, 4, "int")
  NumPut(((h=0) ? A_ScreenHeight : h), bmi, 8, "int")
  NumPut(1, bmi, 12, "ushort")
  NumPut(32, bmi, 14, "ushort")
  hBitmap := DllCall("CreateDIBSection", "uint", hBuffer, "uint", &bmi, "uint", 0, "uint*", diBits, "uint", 0, "uint", 0)
  if (hBitmap=0)
    Return 0
  DllCall("SelectObject", "uint", hNewBuffer, "uint", hBitmap)
  Return hNewBuffer
}
;============================================================================
Aero_AutoRepaintCallback(wParam, lParam, msg, hWnd)
{
  static
  SetFormat, Integer, h
  hWnd += 0
  SetFormat, Integer, d
  if (msg="register")
  {
    Buffer%hWnd% := wParam
    Return Aero_UpdateWindow(hWnd, wParam)
  }
  if ((Buffer%hWnd%!=""))
  {
    Aero_UpdateWindow(hWnd, Buffer%hWnd%)
    SendMessage, % msg, % wParam, % lParam,, ahk_id %hWnd%
    Return errorlevel
  }
  SendMessage, % msg, % wParam, % lParam,, ahk_id %hWnd%
  Return errorlevel
}
;============================================================================
Aero_AlphaBlend(hBufferDst, hBufferSrc, x=0, y=0, alpha=0xFF)
{
  VarSetCapacity(ImgSrc, 24, 0)
  VarSetCapacity(ImgDst, 24, 0)
  hBitmapSrc := DllCall("GetCurrentObject", "uint", hBufferSrc, "uint", 7)
  hBitmapDst := DllCall("GetCurrentObject", "uint", hBufferDst, "uint", 7)
  DllCall("GetObject", "uInt", hBitmapSrc, "uInt", 24, "uInt", &ImgSrc)
  DllCall("GetObject", "uInt", hBitmapDst, "uInt", 24, "uInt", &ImgDst)
  w := ((NumGet(ImgSrc, 4)<=NumGet(ImgDst, 4)) ? NumGet(ImgSrc, 4) : NumGet(ImgDst, 4))
  h := ((NumGet(ImgSrc, 8)<=NumGet(ImgDst, 8)) ? NumGet(ImgSrc, 8) : NumGet(ImgDst, 8))
  alpha := ((alpha>0xFF) ? 0xFF : (alpha<0) ? 0 : alpha)
  Return DllCall("GdiAlphaBlend", "uint", hBufferDst, "int", x, "int", y, "int", w, "int", h, "uint", hBufferSrc
      , "int", 0, "int", 0, "int", w, "int", h, "uint", 0x01000000 | (alpha*0x10000))
}
;============================================================================
Aero_Blit(hBufferDst, hBufferSrc, x=0, y=0)
{
  VarSetCapacity(ImgSrc, 24, 0)
  VarSetCapacity(ImgDst, 24, 0)
  hBitmapSrc := DllCall("GetCurrentObject", "uint", hBufferSrc, "uint", 7)
  hBitmapDst := DllCall("GetCurrentObject", "uint", hBufferDst, "uint", 7)
  DllCall("GetObject", "uInt", hBitmapSrc, "uInt", 24, "uInt", &ImgSrc)
  DllCall("GetObject", "uInt", hBitmapDst, "uInt", 24, "uInt", &ImgDst)
  w := ((NumGet(ImgSrc, 4)<=NumGet(ImgDst, 4)) ? NumGet(ImgSrc, 4) : NumGet(ImgDst, 4))
  h := ((NumGet(ImgSrc, 8)<=NumGet(ImgDst, 8)) ? NumGet(ImgSrc, 8) : NumGet(ImgDst, 8))
  Return DllCall("BitBlt", "uint", hBufferDst, "int", x, "int", y, "int", w, "int", h, "uint", hBufferSrc
      , "int", 0, "int", 0, "uint", 0xCC0020)
}
;============================================================================
Aero_MultibyteToWide(Multibyte, byref Wide)
{
  SizeOfString := DllCall("MultiByteToWideChar", "uInt", 0, "uInt", 0, "uInt", &Multibyte, "Int", -1, "uInt", 0, "Int", 0) * 2
  VarSetCapacity(Wide, SizeOfString, 0)
  Return DllCall("MultiByteToWideChar", "uInt", 0, "uInt", 0, "uInt", &Multibyte, "Int", -1, "uInt", &Wide, "uInt", SizeOfString)
}
;============================================================================

Aero_DrawText(hBuffer, Text, x=10, y=10, color="", glowsize=14) ;BUGGY , DONT WORK , DONT USE IT
{
  Gui, +LastFound ;Zum verwenden des Theme
  Aero_MultibyteToWide("CompositedWindow::Window", WideClass)
  hTheme := DllCall("uxtheme\OpenThemeData", "uint", WinExist(), "uint", &WideClass)
  hTmpBuffer := Aero_CreateBufferFromBuffer(hBuffer)
  hFont := DllCall("GetCurrentObject", "uint", hBuffer, "uint", 6)
  DllCall("SelectObject", "uint", hTmpBuffer, "uint", hFont)

  VarSetCapacity(Img, 24, 0)
  hBitmap := DllCall("GetCurrentObject", "uint", hBuffer, "uint", 7)
  DllCall("GetObject", "uInt", hBitmap, "uint", 24, "uint", &Img)

  VarSetCapacity(rect, 16, 0)
  NumPut(x, rect, 0, "int")
  NumPut(y, rect, 4, "int")
  NumPut(NumGet(Img, 4)-x, rect, 8, "int")
  NumPut(NumGet(Img, 8)-y, rect, 12, "int")

  VarSetCapacity(dttopts, 64, 0)
  NumPut(64, dttopts, 0, "uint") ;dwSize
  NumPut(0x2800 + ((color!="") ? 1 : 0), dttopts, 4, "uint") ;dwFlags (DTT_COMPOSITED | DTT_GLOWSIZE)
  if (color!="")
    NumPut(((color&0xFF0000)>>16) | (color&0xFF00) | ((color&0xFF)<<16), dttopts, 8, "uint") ;RGB to BGR
  NumPut(glowsize, dttopts, 52, "int")


  Aero_MultibyteToWide(Text, WideText)
  DllCall("uxtheme\DrawThemeTextEx", "uint", hTheme, "uint", hTmpBuffer, "int", 0, "int", 0, "uint", &WideText, "int", -1, "uint", 0x40000, "uint", &rect, "uint", &dttopts)
  Aero_AlphaBlend(hBuffer, hTmpBuffer)
  Aero_DeleteBuffer(hTmpBuffer)
}

Aero_UseFont(hWnd, hBuffer)
{
  hDC := DllCall("GetDC", "uint", hWnd)
  hFont := DllCall("GetCurrentObject", "uint", hDC, "uint", 6)
  DllCall("SelectObject", "uint", hBuffer, "uint", hFont)
  return 1
}

Aero_UseGuiFont(hBuffer, GuiNum="default")
{
  Gui, % ((GuiNum="default") ? "" : GuiNum ":") "+LastFound"
  return Aero_UseFont(WinExist(), hBuffer)
}

IDE_DrawTransImage(hwnd,Path="")
{
	If(!Path)
		Return,False
	hDC := DllCall("GetDC", "uint", hwnd)
	hBuffer:=Aero_CreateBuffer(hwnd)
	hImage:=Aero_LoadImage(Path)
	hBuffer:=Aero_DrawImage(hBuffer, hImage)
	Aero_Blit(hDC, hBuffer)
	Aero_DeleteImage(hImage)
}