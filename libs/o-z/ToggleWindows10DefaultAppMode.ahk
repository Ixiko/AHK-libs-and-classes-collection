; Title:   	ToggleWindows10DefaultAppMode()
; 				This switches between the dark theme and light theme.
; 				MS calls it the default app mode for some reason
; 				not to be confused with deafult programs.
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=62701
; Author:	fischgeek
; Date:   	12.03.2019
; for:     	AHK_L

/*

*/

ToggleWindows10DefaultAppMode() {
	RegRead, appMode, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme
	RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme, % !appMode
}