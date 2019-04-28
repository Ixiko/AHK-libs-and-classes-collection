SplashTextOn(aWidth:="",aHeight:="",aTitle:="",aText:=""){
	static SM_CXFIXEDFRAME,SM_CYCAPTION,WS_EX_TOPMOST,WS_DISABLED,WS_POPUP,WS_CAPTION,WS_CHILD,WS_VISIBLE,SS_CENTER,FW_NORMAL,DEFAULT_GUI_FONT,LOGPIXELSY,DEFAULT_CHARSET
				,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,PROOF_QUALITY,FF_DONTCARE,WM_SETFONT,SW_SHOWNOACTIVATE,g_hWndSplash,g_hFontSplash,pt,rect
	if !SM_CXFIXEDFRAME
    SM_CXFIXEDFRAME:=7,SM_CYCAPTION:=4,WS_EX_TOPMOST:=8,WS_DISABLED:=134217728,WS_POPUP:=2147483648,WS_CAPTION:=12582912
    ,WS_CHILD:=1073741824,WS_VISIBLE:=268435456,SS_CENTER:=1,FW_NORMAL:=400,DEFAULT_GUI_FONT:=17,LOGPIXELSY:=90,DEFAULT_CHARSET:=1
    ,OUT_TT_PRECIS:=4,CLIP_DEFAULT_PRECIS:=0,PROOF_QUALITY:=2,FF_DONTCARE:=0,WM_SETFONT:=48,SW_SHOWNOACTIVATE:=4
    ,g_hWndSplash,g_hFontSplash,pt:=Struct("x,y"),rect:=Struct("left,top,right,bottom")
    ,Gui("Splash_GUI_Init:Show","HIDE") ; required to init ahk_class AutoHotkeyGUI
	if (aWidth aHeight aTitle aText = ""){
		if (g_hWndSplash && IsWindow(g_hWndSplash))
			DestroyWindow(g_hWndSplash)
		g_hWndSplash := 0
		return
	}
	; Add some caption and frame size to window:
	aWidth := (aWidth?aWidth:200) + GetSystemMetrics(SM_CXFIXEDFRAME) * 2
	min_height := GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CXFIXEDFRAME) * 2
	aHeight := (aHeight?aHeight:0) + min_height

	pt[] := CenterWindow(aWidth, aHeight) ; Determine how to center the window in the region that excludes the task bar.

	; My: Probably not too much overhead to do this, though it probably would perform better to resize and
	; "re-text" the existing window rather than recreating it like this:
	if (g_hWndSplash && IsWindow(g_hWndSplash))
		DestroyWindow(g_hWndSplash)

	; Doesn't seem necessary to have it owned by the main window, but neither
	; does doing so seem to cause any harm.  Feels safer to have it be
	; an independent window.  Update: Must make it owned by the parent window
	; otherwise it will get its own task-bar icon, which is usually undesirable.
	; In addition, making it an owned window should automatically cause it to be
	; destroyed when it's parent window is destroyed:
	g_hWndSplash := CreateWindowEx(WS_EX_TOPMOST,"AutoHotkeyGUI",aTitle,WS_DISABLED|WS_POPUP|WS_CAPTION,pt.x,pt.y,aWidth,aHeight,A_ScriptHwnd,0,A_ModuleHandle,0)
	GetClientRect(g_hWndSplash,rect[])	; get the client size

	; CREATE static label full size of client area.
	static_win := CreateWindowEx(0, "static",aText,WS_CHILD|WS_VISIBLE|SS_CENTER,0,0,rect.right-rect.left,rect.bottom-rect.top,g_hWndSplash,0,A_ModuleHandle,0)

	if (!g_hFontSplash)
	{
		VarSetCapacity(default_font_name,65*2)
		nSize := 12, nWeight := FW_NORMAL
		hdc := CreateDC("DISPLAY",0,0,0)
		if (FontExist(hdc, "Segoe UI")) ; Use a more appealing font under Windows Vista or later (Segoe UI).
		{
			nSize := 11
			default_font_name:="Segoe UI"
		}
		else
		{
			SelectObject(hdc,GetStockObject(DEFAULT_GUI_FONT))		; Get Default Font Name
			GetTextFace(hdc,65 - 1,&default_font_name) ; -1 just in case, like AutoIt3.
		}
		CyPixels := GetDeviceCaps(hdc,LOGPIXELSY)			; For Some Font Size Math
		DeleteDC(hdc)
		;strcpy(default_font_name,vParams[7].szValue())	; Font Name
		;nSize = vParams[8].nValue()		; Font Size
		;if ( vParams[9].nValue() >= 0 && vParams[9].nValue() <= 1000 )
		;	nWeight = vParams[9].nValue()			; Font Weight
		g_hFontSplash := CreateFont(0-(nSize*CyPixels)/72,0,0,0,nWeight,0,0,0,DEFAULT_CHARSET,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,PROOF_QUALITY,FF_DONTCARE,default_font_name)	; Create Font
		; The font is deleted when by g_script's destructor.
	}

	SendMessage_(static_win,WM_SETFONT,g_hFontSplash,MAKELPARAM(TRUE, 0))	; Do Font
	ShowWindow(g_hWndSplash,SW_SHOWNOACTIVATE)				; Show the Splash
	; Doesn't help with the brief delay in updating the window that happens when
	; something like URLDownloadToFile is used immediately after SplashTextOn:
	;InvalidateRect(g_hWndSplash, NULL, TRUE)
	; But this does, but for now it seems unnecessary since the user can always do
	; a manual sleep in the extremely rare cases this ever happens (even when it does
	; happen, the window updates eventually, after the download starts, at least on
	; my system.  Update: Might as well do it since it's a little nicer this way
	; (the text appears more quickly when the command after the splash is something
	; that might keep our thread tied up and unable to check messages).
	Sleep,-1
	; UpdateWindow() would probably achieve the same effect as the above, but it feels safer to do
	; the above because it ensures that our message queue is empty prior to returning to our caller.
	; return 0
}
