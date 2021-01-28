; ================================================================================================================================================== ;
; ************************************************************************************************************************************************** ;
;
;	UX_THEME / VISUAL STYLE / AEROWIZARD
;
;	Author:		MIAMIGUY | CHESHIRECAT
;	Developed:	04/27/2008 - 11/13/2019
;	Function:		Colection of UxTheme API function wrappers for use with AHK in Windows Vista/7+
;	Tested with:	AHK 1.1.20.00+ (A32/U32)
;	Tested On:	Win Vista | Win 7 | Win 10
;	Org. Forum:	https://autohotkey.com/board/topic/28522-help-with-extending-client-area-in-vista-gui/
;
;	Changes:
;		0.1.00.00/2019-11-13 - initial release 
; ************************************************************************************************************************************************** ;
;
;	THIS CODE AND/OR INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
;	INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
;	IN NO EVENT WILL THE AUTHOR BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE OR MISUSE OF THIS SOFTWARE.
;
; ================================================================================================================================================== ;
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_Init() { 

	vOS := (StrSplit(A_OSVersion, ".")[1] = 10 ? "WIN_10" : A_OSVersion)

	if (vOS=="WIN_VISTA"||vOS=="WIN_7"||vOS=="WIN_8"||vOS=="WIN_8.1"||vOS=="WIN_10")
	{
		cchMaxNameChars  := VarSetCapacity(pszThemeFileName,(260<<1), 0)
		cchMaxColorChars := VarSetCapacity(pszColorBuff    ,(20<<1) , 0)
		cchMaxSizeChars  := VarSetCapacity(pszSizeBuff     ,(20<<1) , 0)

		UxTheme_GetCurrentThemeName(pszThemeFileName, cchMaxNameChars, pszColorBuff, cchMaxColorChars, pszSizeBuff, cchMaxSizeChars)
		
		uxPath  := StrGet(&pszThemeFileName, cchMaxNameChars, "UTF-16")
		uxColor := StrGet(&pszColorBuff, cchMaxColorChars, "UTF-16")
		uxSize  := StrGet(&pszSizeBuff , cchMaxSizeChars , "UTF-16")

		SplitPath, uxPath, fname, fdir, fext, fnNoX, fdrive
			
		if ! (hModule_DWM := DllCall("GetModuleHandle", "Str", "dwmapi"))
			 hModule_DWM := DllCall("LoadLibrary", "Str", "dwmapi")

		if ! (hModule_UxT := DllCall("GetModuleHandle", "Str", "UxTheme"))
			 hModule_UxT := DllCall("LoadLibrary", "Str", "UxTheme")		

		if ! (uxPath && hModule_DWM && hModule_UxT && UxTheme_IsThemeActive())
			Return False
		else 
			Return {uxPath: uxPath, fname: fname, fdir: fdir, fext: fext, fnNoX: fnNoX, fdrive: fdrive, uxColor: uxColor, uxSize: uxSize}
	}
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetCurrentThemeName(ByRef pszThemeFileName, cchMaxNameChars, ByRef pszColorBuff, cchMaxColorChars, ByRef pszSizeBuff, cchMaxSizeChars) {

	Return DllCall("UxTheme.dll\GetCurrentThemeName", "Ptr", &pszThemeFileName, "Int", cchMaxNameChars
				, "Ptr", &pszColorBuff, "Int", cchMaxColorChars, "Ptr", &pszSizeBuff, "Int", cchMaxSizeChars)
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_SetThemeAppProperties(dwFlags) {

	Return DllCall("UxTheme\SetThemeAppProperties", "uInt", dwFlags)
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_OpenThemeData(hWnd, pszClassIdList) {

	Return DllCall("UxTheme\OpenThemeData", "Ptr", hWnd, "wStr", pszClassIdList)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_OpenThemeDataEx(hWnd, pszClassIdList, dwFlags) {

	Return DllCall("UxTheme\OpenThemeDataEx", "Ptr", hWnd, "uInt", pszClassIdList, "uInt", dwFlags)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_CloseThemeData(hTheme) {
 
	Return DllCall("UxTheme\CloseThemeData", "Ptr" hTheme)
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_SetWindowTheme(hWnd, pszSubAppName="", pszSubIdList="") {

	Return DllCall("UxTheme\SetWindowTheme", "Ptr", hWnd, "wStr", pszSubAppName, "wStr", pszSubIdList)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetWindowTheme(hWnd) {

	Return DllCall("UxTheme\GetWindowTheme", "Ptr", hWnd)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemeSysColor(hTheme, iColorID) {

	Return DllCall("UxTheme\GetThemeSysColor", "Ptr", hTheme, "Int", iColorID)
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemePartsize(hTheme, hDC, iPartId, iStateId, prc, arg6, ByRef psz) {

	Return DllCall("UxTheme\GetThemePartsize", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "Ptr", prc, "Int", arg6, "uInt*", psz)
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemeSysColorBrush(hTheme, iColorID) {

	Return DllCall("UxTheme\GetThemeSysColorBrush", "Ptr", hTheme, "Int", iColorID, "uInt")
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemeColor(hTheme, iPartId, iStateId, iPropId, ByRef pColor) {

	Return DllCall("UxTheme.dll\GetThemeColor", "Ptr", hTheme, "Int", iPartId, "Int", iStateId, "Int", iPropId, "uInt*", pColor)
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemeTextExtent(hTheme, hDC, iPartId, iStateId, pszText, iCharCount, dwTextFlags, pBoundingRect, ByRef pExtentRect) {

	Return DllCall("uxtheme\GetThemeTextExtent", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "wStr", pszText, "Int", iCharCount
				, "uInt", dwTextFlags, "Ptr", pBoundingRect, "Ptr", pExtentRect)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemeSysFont(hTheme, iFontId, ByRef LOGFONT) {

	Return DllCall("uxtheme\GetThemeSysFont", "Ptr", hTheme, "Int", iFontId, "Ptr", LOGFONT)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemeFont(hTheme, hDC, iPartId, iStateId, iPropId, ByRef LOGFONT) {

	Return DllCall("uxtheme\GetThemeFont", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "Int", iPropId, "Ptr", LOGFONT)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_SetWindowThemeAttribute(hWnd, eAttribute, pvAttribute, cbAttribute) {

	Return DllCall("UxTheme\SetWindowThemeAttribute", "Ptr", hWnd, "uInt", eAttribute, "Ptr", pvAttribute, "uInt", cbAttribute)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_DrawThemeText(hTheme, hDC, iPartId, iStateId, pszText, iCharCount, dwFlags, dwTextFlags2, pRect) {

	Return DllCall("UxTheme\DrawThemeText", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "wStr", pszText, "Int", iCharCount
				, "uInt", dwFlags, "uInt", dwTextFlags2, "Ptr", pRect)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_DrawThemeTextEx(hTheme, hDC, iPartId, iStateId, pszText, iCharCount, dwFlags, pRect, pOptions) {

	Return DllCall("UxTheme\DrawThemeTextEx", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "wStr", pszText, "Int", iCharCount
				, "uInt", dwFlags, "Ptr", pRect, "Ptr", pOptions)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_DrawThemeBackground(hTheme, hDC, iPartId, iStateId, pRect, pClipRect) {

	Return DllCall("uxtheme\DrawThemeBackground", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "Ptr", pRect, "Ptr", pClipRect)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_DrawThemeBackgroundEx(hTheme, hDC, iPartId, iStateId, pRect, pOptions) {

	Return DllCall("uxtheme\DrawThemeBackground", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "Ptr", pRect, "Ptr", pOptions)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_DrawThemeParentBackground(hWnd, hDC, pRect) {

	Return DllCall("uxtheme\DrawThemeParentBackground", "Ptr", hWnd, "Ptr", hDC, "Ptr", pRect)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_DrawThemeParentBackgroundEx(hWnd, hDC, dwFlags, pRect) {

	Return DllCall("uxtheme\DrawThemeParentBackground", "Ptr", hWnd, "Ptr", hDC, "uInt", dwFlags, "Ptr", pRect)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_DrawThemeIcon(hTheme, hDC, iPartId, iStateId, pRect, himl, imageIndex) {

	Return DllCall("uxtheme\DrawThemeIcon", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "Ptr", pRect, "Ptr", himl, "Int", imageIndex)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_BufferedPaintInit() {

	Return DllCall("uxtheme\BufferedPaintInit", "uInt", "")

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_BufferedPaintUnInit() {

	Return DllCall("uxtheme\BufferedPaintUnInit", "uInt", "")

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_BeginBufferedPaint(hdcTarget, prcTarget, dwFormat, pPaintParams, ByRef phdc) {

	Return DllCall("uxtheme\BeginBufferedPaint", "Ptr", hdcTarget, "Ptr", prcTarget, "uInt", dwFormat, "Ptr", pPaintParams, "uInt*", phdc)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_EndBufferedPaint(hBufferedPaint, fUpdateTarget) {

	Return DllCall("uxtheme\EndBufferedPaint", "Ptr", hBufferedPaint, "Int", fUpdateTarget)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_BufferedPaintSetAlpha(hBufferedPaint, prc, alpha) {

	Return DllCall("uxtheme\BufferedPaintSetAlpha", "Ptr", hBufferedPaint, "Ptr", prc, "Int", alpha)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemeBackgroundContentRect(hTheme, hDC, iPartId, iStateId, pBoundingRect, ByRef pContentRect) {

	Return DllCall("uxtheme\GetThemeBackgroundContentRect", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "Ptr", pBoundingRect, "Ptr", pContentRect)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemeRect(hTheme, iPartId, iStateId, iPropId, ByRef pRect) {

	Return DllCall("uxtheme\GetThemeRect", "Ptr", hTheme, "Int", iPartId, "Int", iStateId, "Int", iPropId, "Ptr", pRect)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_GetThemeBackgroundExtent(hTheme, hDC, iPartId, iStateId, pContentRect, ByRef pExtentRect) {

	Return DllCall("uxtheme\GetThemeBackgroundExtent", "Ptr", hTheme, "Ptr", hDC
				, "Int", iPartId, "Int", iStateId, "Ptr", pContentRect, "Ptr", pExtentRect)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_IsThemeActive() {

	Return DllCall("UxTheme\IsThemeActive", "uInt", "")

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_IsCompositionActive() {

	Return DllCall("UxTheme\IsCompositionActive", "uInt", "")

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_IsAppThemed() {

	Return DllCall("UxTheme\IsAppThemed", "uInt", "")

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_IsThemeDialogTextureEnabled(hWnd) {

	Return DllCall("UxTheme\IsThemeDialogTextureEnabled", "Ptr", hWnd)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_IsThemeBackgroundPartiallyTransparent(hTheme, iPartId, iStateId) {

	Return DllCall("UxTheme\IsThemeBackgroundPartiallyTransparent","Ptr", hTheme, "Int", iPartId, "Int", iStateId)

}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;

UxTheme_EnableThemeDialogTexture(hWnd, dwFlags) {

	Return DllCall("UxTheme\EnableThemeDialogTexture", "Ptr", hWnd, "uInt", "dwFlags")
   
}

;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ;