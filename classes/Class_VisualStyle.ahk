; ==================================================================================================================================================;
; **************************************************************************************************************************************************;
;
;	UX_THEME / VISUAL STYLE / AEROWIZARD
;
;	Author:		MIAMIGUY | CHESHIRECAT
;	Developed:	04/27/2008 - 11/13/2019
;	Function:		Create AeroWizard with AHK | Perform other Visual Style modifications to GUI and/or Controls
;	Tested with:	AHK 1.1.20.00+ (A32/U32)
;	Tested On:	Win Vista | Win 7 | Win 10
;	Org. Forum:	https://autohotkey.com/board/topic/28522-help-with-extending-client-area-in-vista-gui/
;
;	Changes:
;		0.1.00.00/2019-11-13 - initial release
; **************************************************************************************************************************************************;
;
;	THIS CODE AND/OR INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
;	INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
;	IN NO EVENT WILL THE AUTHOR BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE OR MISUSE OF THIS SOFTWARE.
;
; ==================================================================================================================================================;

#Include %A_ScriptDir%\..\lib-a_to_h\Const_Theme.ahk


Class VisualStyle {

	static DerivedObjects := {}
	static DerivedObjectsCount := 0
	static UxThemeInit := 0

	__New() {

		if ! UxThemeInit
			if ! (UxThemeInit := UxTheme_Init())
				Return

		VisualStyle.DerivedObjectsCount += 1

		if (VisualStyle.DerivedObjectsCount = 1) {
			OnMessage(WM_LBUTTONDOWN, this.WM_LBUTTONDOWN 				:= ObjBindMethod(VisualStyle, "WM_LBUTTONDOWN"))
			OnMessage(WM_PAINT, this.WM_PAINT 							:= ObjBindMethod(VisualStyle, "WM_PAINT"))
			OnMessage(WM_CTLCOLORBTN, this.WM_CTLCOLORBTN 				:= ObjBindMethod(VisualStyle, "WM_CTLCOLORBTN"))
			OnMessage(WM_DWMCOMPOSITIONCHANGED, this.WM_DWMCOMPOSITIONCHANGED:= ObjBindMethod(VisualStyle, "WM_DWMCOMPOSITIONCHANGED"))
			OnMessage(WM_SETCURSOR, this.WM_SETCURSOR 					:= ObjBindMethod(VisualStyle, "WM_SETCURSOR"))
			OnMessage(WM_NCACTIVATE, this.WM_NCACTIVATE 				:= ObjBindMethod(VisualStyle, "WM_NCACTIVATE"))
			OnMessage(WM_CTLCOLORDLG, this.WM_CTLCOLORDLG 				:= ObjBindMethod(VisualStyle, "WM_CTLCOLORDLG"))
		}
	}

	__Delete() {

		VisualStyle.DerivedObjects.Delete(this.wProperty.hwnd)
		VisualStyle.DerivedObjectsCount -= 1

		Gui, % this.wProperty.hwnd ": Destroy"

		this.wProperty := ""

		if (VisualStyle.DerivedObjectsCount = 0)
		{
			OnMessage(WM_LBUTTONDOWN, 		this.WM_LBUTTONDOWN, 0)
			OnMessage(WM_PAINT,				this.WM_PAINT, 0)
			OnMessage(WM_CTLCOLORBTN,		this.WM_CTLCOLORBTN, 0)
			OnMessage(WM_DWMCOMPOSITIONCHANGED,this.WM_DWMCOMPOSITIONCHANGED, 0)
			OnMessage(WM_SETCURSOR, 		this.WM_SETCURSOR, 0)
			OnMessage(WM_NCACTIVATE, 		this.WM_NCACTIVATE, 0)
			OnMessage(WM_CTLCOLORDLG, 		this.WM_CTLCOLORDLG, 0)
		}
	}

	WinCreate(wCaption, BkBtnLabel, NxtBtnLabel, CancelBtnLabel, wIcon:="", X:="", Y:="", W:="", H:="", Style:= "Wiz") {

		W := (W!=""?W:570), H := (H!=""?H:408), X := (X!=""?X:"Center"), Y := (Y!=""?Y:"Center"), btnX := (W-(68*2)-17), btnY := (H-(25+8))

		Gui, New, +HwndhWnd +Owner -MinimizeBox +Caption +0x40000 +MaxSize +MinSize, % wCaption

		this.wProperty := {hwnd: hwnd}

		Font := this.GetFontProperties("AEROWIZARD", AW_CONTENTAREA)
		Gui, % hWnd ": Font", % "s" Font.Size, % Font.Name
		VisualStyle.DerivedObjects[hwnd] := &this

		if (Style = "Wiz")
		{
			Gui, % hwnd ": Add" , Button, % " x0 y0 w30 h30 +Disabled hwndhNavBtn g" BkBtnLabel,

			UxTheme_SetWindowTheme(hNavBtn, "EXPLORER", "NAVIGATION")

			this.wProperty.NavBtn := hNavBtn
		}

		Gui, % hwnd ": Add" , Button, % " x" btnX " y" btnY " w68 h23 hWndhCmdBtn1 g" NxtBtnLabel, Next
		Gui, % hwnd ": Add" , Button, % " x+7 yp wp hp hWndhCmdBtn2 g" CancelBtnLabel, Cancel

		this.wProperty.CmdBtnNext := hCmdBtn1, this.wProperty.CmdBtnCancel := hCmdBtn2

		Icon := StrSplit(wIcon,","," `t" , 2), wIcon:= Icon[1], nIcon := (Icon[2] ? Icon[2] : 1)

		(wIcon && wIcon != -1) ? (DllCall("user32\SendMessage", "Ptr", hWnd, "uInt", WM_SETICON, "uInt", 0, "Ptr", (hIcon := LoadPicture(wIcon, "Icon" nIcon " GDI+ h16", vType))))
		: (wIcon = -1) ? (hIcon := -1) : (hIcon := DllCall("user32\SendMessage", "Ptr", hWnd, "uInt", WM_GETICON, "uInt", 0))

		this.wProperty.Icon := hIcon

		if (Style = "Wiz" || Style = "Win" && hIcon = -1 && wCaption = -1)
			dwFlags := dwMask := (WTNCA_NOMIRRORHELP|WTNCA_NOSYSMENU|WTNCA_NODRAWICON|WTNCA_NODRAWCAPTION)
		else if (Style = "Win" && hIcon = -1 && wCaption != -1)
			dwFlags := dwMask := (WTNCA_NOMIRRORHELP|WTNCA_NOSYSMENU|WTNCA_NODRAWICON)
		else if (Style = "Win" && hIcon != -1 && wCaption = -1)
			dwFlags := dwMask := (WTNCA_NOMIRRORHELP|WTNCA_NOSYSMENU|WTNCA_NODRAWCAPTION)
		else
			dwFlags := dwMask := ""

		cbAttribute := VarSetCapacity(pvAttribute, 8, 0)
		NumPut(dwFlags, pvAttribute, 0)
		NumPut(dwMask,  pvAttribute, 4)
		UxTheme_SetWindowThemeAttribute(hWnd, WTA_NONCLIENT, &pvAttribute, cbAttribute)

		if (UxTheme_IsCompositionActive() && Style = "Wiz")
		{
			VarSetCapacity(pMarInset, 16, 0)
			NumPut(0, NumPut(DWM_WINEXTENT, NumPut(0, NumPut(0, pMarInset))))
			DllCall("dwMapi\DwmExtendFrameIntoClientArea", "Ptr", hWnd, "Ptr", &pMarInset)
		}

		Gui, % hwnd ": Show" , % " Hide x" X " y" Y " w" W " h" H,

		SysGet, CXSIZEFRAME, 32
		SysGet, CXFIXEDFRAME, 7
		SysGet, CXEDGE, 45

		this.wProperty.Style := wStyle := (Style = "Wiz" ? DWM_WINEXTENT : 0)

		VarSetCapacity(cRect, 16,0)
		DllCall("user32\GetClientRect","Ptr", hWnd, "Ptr", &cRect)
		pW := (NumGet(cRect, 8)-NumGet(cRect, 0)), pH := (NumGet(cRect, 12)-NumGet(cRect, 4))

		Gui, % hwnd ": Add" , Tab3, % " +Right hWndhPageCtrl x0 y" (wStyle) " w" W " h" H-(wStyle+45), 1

		this.wProperty.hPage := hPageCtrl

		VarSetCapacity(pRect, 16, 0)
		DllCall("SendMessage", "Ptr", hPageCtrl, "uInt", (0x1300+10), "Int", 1, "Ptr", &pRect)
		ppW := (NumGet(pRect, 8)-NumGet(pRect, 0)), ppH := (NumGet(pRect, 12)-NumGet(pRect, 4))

		GuiControl, Move, % hPageCtrl, % " w" (pW+(ppW+(CXFIXEDFRAME*2))-4)

		Return this.wProperty
	}

	WinShow(aParams:="", wCaption="") {

		Gui, % this.wProperty.hwnd ": Show", % aParams, % wCaption

		if this.wProperty.hPage
			Return DllCall("ShowWindow", "Ptr", this.wProperty.hPage, "Int", SW_HIDE)

		DllCall("SendMessage", "Ptr", this.wProperty.hwnd, "uInt", WM_SETREDRAW, "Int", False, "Int", 0)
		DllCall("ShowWindow", "Ptr", this.wProperty.hPage, "Int", SW_SHOW)

		GuiControl, Choose, % this.wProperty.hPage, 1

		DllCall("SendMessage", "Ptr", this.wProperty.hwnd, "uInt", WM_SETREDRAW, "Int", True, "Int", 0)
		DllCall("ShowWindow", "Ptr", this.wProperty.hPage, "Int", SW_HIDE)

		WinSet, Redraw,, % "ahk_id " this.wProperty.hwnd
	}

	PagingCreate(nPages, vPage:="PageCtrl") {

		Loop % nPages
			P .= A_Index "|"

		if (nPages > 1)
		{
			GuiControl,, % this.wProperty.hPage, % "|" SubStr(P, 1, -1)
			GuiControl, % "+v" vPage, % this.wProperty.hPage
		}
	}

	PageAdd(nPage) {

		Gui, % this.wProperty.hwnd ": Tab", % nPage
	}

	PageChoose(nPage) {

		Critical

		DllCall("SendMessage", "Ptr", this.wProperty.hwnd, "uInt", WM_SETREDRAW, "Int", False, "Int", 0)
		DllCall("ShowWindow", "Ptr", this.wProperty.hPage, "Int", SW_SHOW)

		GuiControl, Choose, % this.wProperty.hPage, % "|" nPage

		DllCall("SendMessage", "Ptr", this.wProperty.hwnd, "uInt", WM_SETREDRAW, "Int", True, "Int", 0)
		DllCall("ShowWindow", "Ptr", this.wProperty.hPage, "Int", SW_HIDE)
	}

	GetFontProperties(pszClassList, iPartId, iStateId:=0) {

		if UxTheme_IsThemeActive()
		{
			hTheme := UxTheme_OpenThemeData(this.wProperty.hwnd, pszClassList)
			DC := DllCall("user32\GetDC", "Ptr", this.wProperty.hwnd)

			UxTheme_GetThemeColor(hTheme, iPartId, iStateId, TMT_TEXTCOLOR, ColorRef)

			VarSetCapacity(LOGFONT, (szLOGFONT := 60 * (A_IsUnicode ? 2 : 1)))
			UxTheme_GetThemeFont(hTheme, DC, iPartId, iStateId, TMT_FONT, &LOGFONT)

			UxTheme_CloseThemeData(hTheme)
			DllCall("user32.dll\ReleaseDC", Ptr, this.wProperty.hwnd, Ptr, DC)

			Return {Color: Format("{1:#x}", ((ColorRef >> 16) & 0xFF) | (ColorRef & 0x00FF00) | ((ColorRef & 0xFF) << 16))
				  , Size: Round((-NumGet(LOGFONT, 0, "Int") * 72) / A_ScreenDPI)
				  , Name: DllCall("kernel32.dll\MulDiv", "Int", &LOGFONT+28, "Int", 1, "Int", 1, "wStr")}
		}
	}

	GetWinColor(iColorID) {

		if UxTheme_IsThemeActive()
		{
			hTheme   := UxTheme_OpenThemeData(this.wProperty.hwnd, "WINDOW")
			ColorRef := UxTheme_GetThemeSysColor(hTheme, iColorID)
			UxTheme_CloseThemeData(hTheme)
			Return Format("{1:#x}", ((ColorRef >> 16) & 0xFF) | (ColorRef & 0x00FF00) | ((ColorRef & 0xFF) << 16))
		}
	}

	GetTextExtent(Text, pszClassList, iPartId, iStateId, dwTextFlags) {

		pszClassList ? pszClassList : pszClassList := "TEXTSTYLE"
		iPartId ? iPartId : iPartId := TEXT_BODYTEXT
		iStateId ? iStateId : iStateId := 0
		dwTextFlags ? dwTextFlags : dwTextFlags := DT_LEFT

		if UxTheme_IsThemeActive()
		{
			hTheme := UxTheme_OpenThemeData(this.wProperty.hwnd, pszClassList)

			hDC := DllCall("user32\GetDC", "Ptr", this.wProperty.hwnd)

			VarSetCapacity(cRect, 16, 0)
			DllCall("user32\GetClientRect", "Ptr", this.wProperty.hwnd, "Ptr", &cRect)

			VarSetCapacity(pExtentRect, 16, 0)
		  	HRESULTS := UxTheme_GetThemeTextExtent(hTheme, hDC, iPartId, iStateId, Text, (StrLen(Text) + 1), dwTextFlags, &cRect, &pExtentRect)

		  	DllCall("user32.dll\ReleaseDC", Ptr, this.wProperty.hwnd, Ptr, hDC)
		  	UxTheme_CloseThemeData(hTheme)

			if (HRESULTS = 0)
				Return {W: (NumGet(pExtentRect, 8)-NumGet(pExtentRect, 0)-4), H: (NumGet(pExtentRect, 12)-NumGet(pExtentRect, 4)+2)}
		}
	}

	DrawBackground(hDC, X, Y, W, H, ThemeClass:="AEROWIZARD", iPart:="AW_CONTENTAREA", iState:="0") {

		VarSetCapacity(cRect, 16, 0)
		NumPut(X, cRect, 0, "Int")
		NumPut(Y, cRect, 4, "Int")
		NumPut(W, cRect, 8, "Int")
		NumPut(Y+H, cRect, 12, "Int")

		if UxTheme_IsThemeActive()
		{
			if (UxTheme_BufferedPaintInit() = S_OK)
			{
				if hPaintBuffer := UxTheme_BeginBufferedPaint(hDC, &cRect, "BPBF_COMPATIBLEBITMAP", "", hBufferDC)
				{
					if 	hTheme := UxTheme_OpenThemeData(this.wProperty.hwnd, ThemeClass)
					{
						HRESULT := UxTheme_DrawThemeBackground(hTheme, hBufferDC, iPart, iState, &cRect, 0)

						UxTheme_CloseThemeData(hTheme)
					}
					UxTheme_EndBufferedPaint(hPaintBuffer, 1)
				}
				UxTheme_BufferedPaintUnInit()
			}
			Return HRESULT
		}
	}

	CommandLink(gLabel, X:="", Y:="", W:="", H:="", wCaption:="", Note:="", Default:=0) {

		Gui, % this.wProperty.hwnd ": Add", Custom, % "ClassButton +" (Default ? BS_DEFCOMMANDLINK : BS_COMMANDLINK) " hwndhBtn g" gLabel " x" X " y" Y " w" W " h" H, % wCaption

		Note ? this.CommandLinkSetNote(hBtn, Note) : ""

		Return hBtn
	}

	CommandLinkSetNote(hWnd, sNote="") {

		Return DllCall("SendMessage", "Ptr", hWnd, "uInt", BCM_SETNOTE, "Int", 0, "wStr", sNote)
	}

	CommandLinkSetText(hWnd, sText="") {

		Return DllCall("SendMessage", "Ptr", hWnd, "uInt", WM_SETTEXT, "Int", 0, "Str", sText)
	}

	CommandLinkGetNoteLength(hWnd) {

		Return DllCall("SendMessage", "Ptr", hWnd, "uInt", BCM_GETNOTELENGTH, "Int", 0, "Int", 0)
	}

	CommandLinkGetNote(hWnd) {

		nLen := this.CommandLinkGetNoteLength(hWnd)

		VarSetCapacity(sText, (nLen * (A_IsUnicode ? 1 : 2)), 0)
		NumPut(nLen, sText, 0, "uInt")

		DllCall("SendMessage", "Ptr", hWnd, "uInt", BCM_GETNOTE, "Ptr", &nLen, "Ptr", &sText)

		Return % StrGet(&sText, nLen, "UTF-16")
	}

	ButtonSetImage(hWnd, pIcon="", nIcon="", szIcon="") {

		hIcon := LoadPicture(pIcon, "Icon" nIcon "GDI+ h" szIcon, vType)

		Return DllCall("SendMessage", "Ptr", hWnd, "uInt", BM_SETIMAGE, "Int", IMAGE_ICON, "Ptr", hIcon)

	}

	ButtonSetElevationRequiredState(hWnd, fRequired:=1) {

		Return DllCall("SendMessage", "Ptr", hWnd, "uInt", BCM_SETSHIELD, "Int", 0, "Int", fRequired)

	}

	ProgBarSetState(hWnd, State, sMarquee:=50) {

		Style := {Normal: PBST_NORMAL, Error: PBST_ERROR, Pause: PBST_PAUSE, Marquee: PBS_MARQUEE, SetMarquee: PBM_SETMARQUEE, Smooth: PBS_SMOOTH, SetState: PBM_SETSTATE}

		if (State = "Marquee")
		{
			WinSet, Style, % "+" Style[(State)], % "ahk_id " hWnd
			Return DllCall("SendMessage", "Ptr", hWnd, "uInt", Style.SetMarquee, "Int", sMarquee, "Int", sMarquee)
		}

		Return DllCall("SendMessage", "Ptr", hWnd, "uInt", Style.SetState, "uInt", Style[(State)], "uInt", 0)
	}

	TVSetExtendedStyle(hWnd, xStyle) {

		SendMessage, % TVM_SETEXTENDEDSTYLE, % xStyle, % xStyle, , % "ahk_id " hWnd

		Return ErrorLevel
	}

	TVSetIndent(hwnd, Indent) {

		SendMessage, % TVM_SETINDENT, % Indent, 0, , % "ahk_id " hWnd

		Return ErrorLevel
	}

	TVSetTextColor(hWnd, Color) {

		SendMessage, % TVM_SETTEXTCOLOR, 0, % Color, , % "ahk_id " hWnd

		Return ErrorLevel
	}

	TVSetBKColor(hWnd, Color) {

		SendMessage, % TVM_SETBKCOLOR, 0, % Color, , % "ahk_id " hWnd

		Return ErrorLevel
	}

	SetCueBannerText(hWnd, lpcwText, fDrawFocused:=0) {

		Return DllCall("SendMessage", "Ptr", hWnd, "uInt", EM_SETCUEBANNER, "Int", fDrawFocused,  "wStr", lpcwText)
	}

	ContentLink(lAddress, wCaption:="", X:=0, Y:=0, sStyle:="HELPLINK", bgvsClass:="", bgiPart:="") {

		Static init:=0

		if ! lAddress
			Return

		if (SubStr(lAddress, 1, 1) = "g")
		{
			if ! Islabel(Label := SubStr(lAddress, 2, (StrLen(lAddress) - 1)))
				Return
			else
				lAddress := Label
		}

		if ! init
		{
			vPIs64 := (A_PtrSize=8)
			vSize  := vPIs64?80:48

			VarSetCapacity(WC, vSize, 0)
			NumPut(vSize, WC, 0, "uInt")
			NumPut((CS_VREDRAW|CS_HREDRAW|CS_PARENTDC), WC, 4, "uInt")
			NumPut(RegisterCallback("ContentLink_WndProc", "F", 4) , WC, 8, "Ptr")
			NumPut(DllCall("LoadCursor", "Ptr", 0, "Ptr", IDC_HAND, "Ptr"), WC, vPIs64?40:28, "Ptr")
			NumPut(&(cName:="ContentLink"), WC, vPIs64?64:40, "Ptr")

			if ! (init := DllCall("user32\RegisterClassEx", "Ptr", &WC, "uShort"))
				Return
		}

		ObjRelease(pcLinkInfo)

		cLinkInfo := {Caption: wCaption ? wCaption : lAddress
				  , Address: lAddress
				  ,   Style: clStyle[(sStyle)]=7||clStyle[(sStyle)]=8||clStyle[(sStyle)]=10||clStyle[(sStyle)]=11 ? clStyle[(sStyle)] : CPANEL_HELPLINK
				  , bgClass: bgvsClass ? bgvsClass : "CONTROLPANEL"
				  ,  bgPart: bgiPart ? bgiPart : CPANEL_CONTENTPANE}

		ObjAddRef(pcLinkInfo := &cLinkInfo)

		ext := this.GetTextExtent(cLinkInfo.Caption, "CONTROLPANEL", cLinkInfo.Style, CPCL_HOT, DT_CALCRECT)

		Gui, % this.wProperty.hwnd ": Add", Custom, % "ClassContentLink W" ext.W " H" ext.H " X" X " Y" Y " hWndhCntLnk", % pcLinkInfo

		Return % hCntLnk
	}

	GetErrorString(eMsg="") {

		Static FORMAT_MESSAGE_FROM_SYSTEM := 0x1000
			, LANG_SYSTEM_DEFAULT := 0x10000
			, LANG_USER_DEFAULT := 0x20000

		eMsg := "" ? eMsg := A_LastError : eMsg

		sizeOf := VarSetCapacity(eMsgStr, 1024, 0)

		DllCall("FormatMessage"
			, "uInt", FORMAT_MESSAGE_FROM_SYSTEM
			, "uInt", ""
			, "uInt", eMsg
			, "uInt", LANG_SYSTEM_DEFAULT|LANG_USER_DEFAULT
			, "Str" , eMsgStr
			, "uInt", sizeOf
			, "Str" , "")
		Return % StrReplace(eMsgStr, "`r`n", A_Space)
	}

	WM_SETCURSOR(wParam, lParam)
	{
		Static hArrow := DllCall("LoadCursor", "Ptr", 0, "uInt", 32512, "uPtr")

		HitTest := lParam & 0xFFFF

		if (HitTest > 9) && (HitTest < 19)
		{
			DllCall("SetCursor", "Ptr", hArrow)

			Return True
		}
	}

	WM_LBUTTONDOWN(wParam, lParam)
	{
		Static HTCAPTION := 2

		if (VisualStyle.DerivedObjects.HasKey(A_Gui))
			this := Object(VisualStyle.DerivedObjects[A_Gui])

		if (A_GuiControl || this.wProperty.Style != DWM_WINEXTENT)
			Return

		MouseGetPos, , , , Ctrl
		WinGetPos,,, W, H, % "ahk_id " this.wProperty.hwnd
		X := (lParam & 0xFFFF), Y := (lParam & 0xFFFF0000) >> 16

		if ((X >= 0) && (X <= W) && (Y >= 0) && (Y <= (DWM_WINEXTENT - 2)) && (Ctrl = ""))
			DllCall("user32.dll\PostMessage", "Ptr", this.wProperty.hwnd, "uInt", WM_NCLBUTTONDOWN, "Int", HTCAPTION, "Int", 0)
	}

	WM_NCACTIVATE(wParam, lParam)
	{
		if (VisualStyle.DerivedObjects.HasKey(A_Gui))
			this := Object(VisualStyle.DerivedObjects[A_Gui])

		if ! UxTheme_IsCompositionActive()
			DllCall("RedrawWindow", "Ptr", this.wProperty.hwnd, "Ptr", "", "Ptr", lParam, "uInt", (RDW_INTERNALPAINT|RDW_INVALIDATE|RDW_UPDATENOW|RDW_ALLCHILDREN))
	}

	WM_CTLCOLORBTN(wParam, lParam)
	{
		if (VisualStyle.DerivedObjects.HasKey(A_Gui))
			this := Object(VisualStyle.DerivedObjects[A_Gui])

		if UxTheme_IsThemeActive()
		{
			if hTheme := UxTheme_OpenThemeData(this.wProperty.hwnd, "WINDOW")
			{
				hBrush := UxTheme_GetThemeSysColorBrush(hTheme, ((lParam = this.wProperty.NavBtn) ? (UxTheme_IsCompositionActive() ? COLOR_BACKGROUND
				: (WinActive("ahk_id" this.wProperty.hwnd) ? COLOR_GRADIENTACTIVECAPTION : COLOR_GRADIENTINACTIVECAPTION))
				: (lParam = this.wProperty.CmdBtnNext || lParam = this.wProperty.CmdBtnCancel) ? COLOR_BTNFACE
				: ((WinActive("ahk_id" this.wProperty.hwnd) ? COLOR_WINDOW : ""))))

				UxTheme_CloseThemeData(hTheme)
			}
		}
		Return hBrush
	}

	WM_DWMCOMPOSITIONCHANGED(wParam, lParam)
	{
		Reload
	}

	WM_CTLCOLORDLG(wParam, lParam)
	{
		Static brushArray := {}

		if (brushArray.HasKey(lParam))
			Return brushArray[(lParam)]
		else
		{
			if (VisualStyle.DerivedObjects.HasKey(A_Gui))
				this := Object(VisualStyle.DerivedObjects[A_Gui])

			if UxTheme_IsThemeActive()
			{
				hdcPaint := DllCall("CreateCompatibleDC", "Ptr", wParam)

				VarSetCapacity(cRect, 16, 0)
				DllCall("user32\GetClientRect", "Ptr", this.wProperty.hwnd, "Ptr", &cRect)
				W := (NumGet(cRect, 8)-NumGet(cRect, 0)), H := (NumGet(cRect, 12)-NumGet(cRect, 4))

				VarSetCapacity(dib, 40, 0)
				NumPut(40, dib,  0)
				NumPut(W,  dib,  4)
				NumPut(-H, dib,  8)
				NumPut(1,  dib,  12, "UShort")
				NumPut(32, dib,  14, "UShort")
				NumPut(0,  dib,  16)

				hBM := DllCall("CreateDIBSection", "Ptr", wParam, "uInt" , &dib, "uInt", 0, "uIntP", "", "uInt" , 0, "uInt" , 0)

				hbmOld := DllCall("SelectObject", "Ptr", hdcPaint, "Ptr", hBM)

				if ! UxTheme_IsCompositionActive()
					this.DrawBackground(hdcPaint, 0, 0, W, this.wProperty.Style, "AEROWIZARD", AW_TITLEBAR, (WinActive("ahk_id" this.wProperty.hwnd) ? AW_S_TITLEBAR_ACTIVE : AW_S_TITLEBAR_INACTIVE))
				else
				{
					VarSetCapacity(cRect, 16, 0)
					NumPut(W, cRect, 8, "Int")
					NumPut(this.wProperty.Style, cRect, 12, "Int")

					if UxTheme_IsThemeActive()
					{
						if hTheme := UxTheme_OpenThemeData(this.wProperty.hwnd, "WINDOW")
						{
							hBrush := UxTheme_GetThemeSysColorBrush(hTheme, COLOR_BACKGROUND)

							UxTheme_CloseThemeData(hTheme)
						}
					}

					DllCall("FillRect", "Ptr", hdcPaint, "Ptr", &cRect, "Ptr", hBrush)
					DllCall("DeleteObject", "Ptr", hBrush)
				}

				this.DrawBackground(hdcPaint, -2
					, this.wProperty.Style-(UxTheme_IsCompositionActive() ? 0 : 3)
					, W+(UxTheme_IsCompositionActive() ? 0 : 2)
					, H-this.wProperty.Style-(UxTheme_IsCompositionActive() ? 45 : 40)
					, "EDIT", (UxTheme_IsCompositionActive() ? ETS_SELECTED : EBS_NORMAL))
				this.DrawBackground(hdcPaint,  0, (H-45), W, 45, "AEROWIZARD", AW_COMMANDAREA)

				DllCall("BitBlt", "Ptr", wParam, "Int", 0, "Int", 0, "Int", W, "Int", this.wProperty.Style, "Ptr", hdcPaint, "Int", 0, "Int", 0, "Int", SRCCOPY)

				DllCall("SelectObject", "Ptr", hdcPaint, "Ptr", hbmOld)
				DllCall("DeleteDC", "Ptr", hdcPaint)

				brushArray[(lParam)] := DllCall("CreatePatternBrush", "uInt", hBM)
				DllCall("DeleteObject", "Ptr" hBM)
			}
		}
		Return brushArray[(lParam)]
	}

	WM_PAINT(wParam, lParam, uMsg, hWnd)
	{
		if (VisualStyle.DerivedObjects.HasKey(A_Gui))
			this := Object(VisualStyle.DerivedObjects[A_Gui])

		if (hWnd != this.wProperty.hwnd || this.wProperty.Style != DWM_WINEXTENT)
			Return DllCall("user32\DefWindowProc", "uPtr", wParam, "uInt", lParam, "Ptr", uMsg, "Ptr", this.wProperty.hwnd, "Ptr")

		if UxTheme_IsThemeActive()
		{
			VarSetCapacity(lpPaint, 64, 0)
			if ! hDC := DllCall("BeginPaint", "Ptr", this.wProperty.hwnd, "Ptr", &lpPaint)
				Return 0

			WinGetPos,,, W, H, % "ahk_id " this.wProperty.hwnd
			ControlGetPos, iX,iY,iW,iH,, % "ahk_id " this.wProperty.NavBtn

			VarSetCapacity(cRect, 16)
			NumPut(iW, cRect, 0, "Int")
			NumPut(W, cRect, 8, "Int")
			NumPut(iH, cRect, 12, "Int")

			if (UxTheme_BufferedPaintInit() = S_OK)
			{
				sizeof := VarSetCapacity(bpPaintParams, 16, 0)
				NumPut(sizeof, bpPaintParams, 0, "uInt")
				NumPut((BPPF_NOCLIP|BPPF_ERASE), bpPaintParams, 4, "uInt")

				if hPaintBuffer := UxTheme_BeginBufferedPaint(hDC, &cRect, BPBF_TOPDOWNDIB, &bpPaintParams, hBufferDC)
				{
					if hTheme := UxTheme_OpenThemeData(this.wProperty.hwnd, "AEROWIZARD")
					{
						if ! UxTheme_IsCompositionActive()
							this.DrawBackground(hBufferDC, 0, 0, W, DWM_WINEXTENT, "AEROWIZARD", AW_TITLEBAR, (WinActive("ahk_id" this.wProperty.hwnd) ? AW_S_TITLEBAR_ACTIVE : AW_S_TITLEBAR_INACTIVE))

						if (this.wProperty.Icon != -1)
						{
							hIcon := DllCall("user32\SendMessage", "Ptr", this.wProperty.hwnd, "uInt", WM_GETICON, "uInt", 0)
							iSize := 16
							DllCall("DrawIconEx", "Ptr", hBufferDC, "Int" , (iW+7), "Int" , 7, "Ptr", hIcon, "Int", iSize, "Int", iSize, "Int", 0, "Int", 0, "Int", 3)
						}
						else
							iSize := -6

						WinGetTitle, wCaption, % "ahk_id " this.wProperty.hwnd
						pExt := this.GetTextExtent(wCaption, "WINDOW", WP_CAPTION, CS_ACTIVE, DT_CALCRECT)

						sizeof := VarSetCapacity(dttOpts,  64, 0)
						NumPut(sizeof, dttOpts, 0, "uInt")
						NumPut((DTT_GLOWSIZE|DTT_COMPOSITED), dttOpts, 4)
						NumPut(10, dttOpts, 52, "Int")		;This Changes Glowing Effect of text

						VarSetCapacity(rcPaint, 64, 0)
						DllCall("RtlMoveMemory", "Ptr", &rcPaint, "Ptr", cRect, "Int", 16)
						NumPut((pExt.H+6), NumPut((pExt.W+50), NumPut(8, NumPut(((iW+7)+(iSize+7)), rcPaint))))

						UxTheme_DrawThemeTextEx(hTheme, hBufferDC, AW_TITLEBAR, 0, wCaption, StrLen(wCaption), DT_LEFT, &rcPaint, (UxTheme_IsCompositionActive() ? &dttOpts : ""))

						UxTheme_CloseThemeData(hTheme)
					}
					UxTheme_EndBufferedPaint(hPaintBuffer, 1)
				}
				UxTheme_BufferedPaintUnInit()
			}
			DllCall("EndPaint", "Ptr", this.wProperty.hwnd, "Ptr", &lpPaint)
		}
		Return DllCall("user32\DefWindowProc", "uPtr", wParam, "uInt", lParam, "Ptr", uMsg, "Ptr", this.wProperty.hwnd, "Ptr")
	}
}

ContentLink_WndProc(hWnd, uMsg, wParam, lParam) {

	Static CONTENTLINKSTATE

	if (uMsg = WM_MOUSEFIRST)
	{
		VarSetCapacity(ET, 16)
		NumPut(16, ET,  0)
		NumPut(TME_HOVER|TME_LEAVE, ET, 4)
		NumPut(hWnd, ET, 8)
		NumPut(1, ET, 12)
		DllCall("TrackMouseEvent", "uInt", &ET)
	}

	if (uMsg = WM_MOUSEHOVER)
	{
		CONTENTLINKSTATE := CPCL_HOT
		WinSet, Redraw,, % "ahk_id " hWnd
	}

	if (uMsg = WM_MOUSELEAVE)
	{
		CONTENTLINKSTATE := CPCL_NORMAL
		WinSet, Redraw,, % "ahk_id " hWnd
	}

	if (uMsg = WM_LBUTTONUP)
	{
		WinGetTitle, pcLinkInfo, % "ahk_id " hWnd
		cLinkInfo := Object(pcLinkInfo)
		if IsObject(cLinkInfo)
			lAddress := cLinkInfo.Address

		CONTENTLINKSTATE := CPCL_PRESSED
		WinSet, Redraw,, % "ahk_id " hWnd

		if IsLabel(lAddress)
			Gosub % lAddress
		else
			Run % lAddress
	}

	if (uMsg = WM_PAINT)
	{
		if UxTheme_IsThemeActive()
		{
			VarSetCapacity(lpPaint, 64, 0)
			if hDC := DllCall("BeginPaint", "Ptr", hWnd, "Ptr", &lpPaint)
			{
				WinGetTitle, pcLinkInfo, % "ahk_id " hWnd
				cLinkInfo := Object(pcLinkInfo)
				if IsObject(cLinkInfo)
				{
					wCaption := cLinkInfo.Caption
					CONTENTLINKSTYLE := cLinkInfo.Style
					BGCLASS := cLinkInfo.bgClass
					BGPART := cLinkInfo.bgPart
				}

				VarSetCapacity(cRect, 16)
				DllCall("user32\GetClientRect", "Ptr", hWnd, "uInt", &cRect)

				if (UxTheme_BufferedPaintInit() = S_OK)
				{
					if hPaintBuffer := UxTheme_BeginBufferedPaint(hDC, &cRect, BPBF_COMPATIBLEBITMAP, "", hBufferDC)
					{
						if hTheme := UxTheme_OpenThemeData(hWnd, BGCLASS)
						{
							UxTheme_GetThemeBackgroundExtent(hTheme, hBufferDC, BGPART, "", &cRect, &cRect)

							;~ UxTheme_DrawThemeParentBackground(hWnd, hBufferDC, &cRect)

							UxTheme_DrawThemeBackground(hTheme, hBufferDC, BGPART, "", &cRect, 0)

							if (BGCLASS != "CONTROLPANEL")
							{
								UxTheme_CloseThemeData(hTheme)
								hTheme := UxTheme_OpenThemeData(hWnd, "CONTROLPANEL")
							}

							UxTheme_DrawThemeText(hTheme, hBufferDC, CONTENTLINKSTYLE, CONTENTLINKSTATE, wCaption, StrLen(wCaption), (DT_CENTER|DT_VCENTER|DT_PATH_ELLIPSIS|DT_WORDBREAK|DT_END_ELLIPSIS), 0, &cRect)

							UxTheme_CloseThemeData(hTheme)
						}
						UxTheme_EndBufferedPaint(hPaintBuffer, 1)
					}
					UxTheme_BufferedPaintUnInit()
				}
				DllCall("EndPaint", "Ptr", hWnd, "Ptr", &lpPaint)
			}
		}
	}
	Return DllCall("user32\DefWindowProc", "Ptr", hWnd, "uInt", uMsg, "uPtr", wParam, "Ptr", lParam, "Ptr")
}