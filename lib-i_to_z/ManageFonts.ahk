InstallFonts(runAgain=False) {
/*		Compare local and installed fonts file size
		If any font is not installed or is different, run FontReg.
*/
	global PROGRAM
	fontsFolder := PROGRAM.FONTS_FOLDER
	winFonts := A_WinDir "\Fonts"

	loc_FontFiles := []
	win_FontFiles := []

;	Get local fonts. Check if they're installed. Also check for duplicates (fontname_0.ttf)
	Loop, Files, %fontsFolder%\*.ttf
	{
		SplitPath, A_LoopFileName, , , , fileNameNoExt
		loc_FontFiles.Push(fileNameNoExt)
		if FileExist(winFonts "\" A_LoopFileName)
			win_FontFiles.Push(fileNameNoExt)
		Loop {
			fileNameDupe := fileNameNoExt "_" A_Index-1
			if !FileExist(winFonts "\" fileNameDupe ".ttf")
				break
			else
				win_FontFiles.Push(fileNameDupe)
		}
	}

;	Remove fonts that are already installed from fontsNeedInstall
	fontsNeedInstall := loc_FontFiles
	for locID, locFontFile in loc_FontFiles {
		for winID, winFontFile in win_FontFiles {
			if RegExMatch(winFontFile, locFontFile "_\d") || (locFontFile = winFontFile) {
				FileGetSize, locSize,% fontsFolder "\" locFontFile ".ttf"
				FileGetSize, winSize,% winFonts "\" winFontFile ".ttf"

				if (locSize = winSize){
					fontsNeedInstall[locID] := ""
				}
			}
		}
	}

;	Get font that need to be installed names and number
	fontsNeedInstall_Index := 0, fontsNeedsInstall_Names := ""
	for id, fontName in fontsNeedInstall {
		if (fontName)
			fontsNeedInstall_Index++, fontsNeedsInstall_Names .= fontName ","
	}
	StringTrimRight, fontsNeedsInstall_Names, fontsNeedsInstall_Names, 1 ; Remove latest comma

;	All fonts are already installed.
	if (!fontsNeedInstall_Index)
		Return

;	Not running as admin. We need UAC to install a font.
	if (!A_IsAdmin && !runAgain) {
		MsgBox(4096, PROGRAM.NAME, "Fonts need to be installed on your system for the tool to work correctly."
			. "`nThe following " fontsNeedInstall_Index " fonts will be installed: "
			. "`n" fontsNeedsInstall_Names
			. "`n"
			. "`nPlease allow the next UAC prompt if asked."
			. "`nRebooting may be neccessary afterwards.")
	}
;	Some fonts are still missing. Require user to install them manually.
	if (runAgain) {
		MsgBox(4096, PROGRAM.NAME, "These " fontsNeedInstall_Index " fonts failed to be installed on your system:"
			. "`n"  fontsNeedsInstall_Names
			. "`n"
			. "`nThe folder containing the fonts will be opening upon closing this box."
			. "`nPlease close " PROGRAM.NAME " and install the fonts manually."
			. "`nRebooting may be neccesary afterwards.")

		Run,% fontsFolder
	}

;	Run FontReg with /Copy to install fonts.
	if !(runAgain) {
		RunWait,% "*RunAs " fontsFolder "\FontReg.exe /Copy",% fontsFolder
		%A_ThisFunc%(True)
	}
}

LoadFonts() {
	Load_Or_Unload_Fonts("LOAD")
}

UnloadFonts() {
	Load_Or_Unload_Fonts("UNLOAD")
}

Load_Or_Unload_Fonts(whatDo) {
	global PROGRAM
	static hCollection
	fontsFolder := PROGRAM.FONTS_FOLDER

	if (whatDo = "LOAD") {
		PROGRAM["FONTS"] := {}
		DllCall("gdiplus\GdipNewPrivateFontCollection", "uint*", hCollection)
	}

	Loop, Files, %fontsFolder%\*.ttf
	{
		if ( whatDo="LOAD") {
			fontFile := A_LoopFileFullPath, fontTitle := FGP_Value(A_LoopFileFullPath, 21)	; 21 = Title

			DllCall( "GDI32.DLL\AddFontResourceEx", Str, fontFile,UInt,(FR_PRIVATE:=0x10), Int,0)
			DllCall("gdiplus\GdipPrivateAddFontFile", "uint", hCollection, "uint", &fontFile)
			DllCall("gdiplus\GdipCreateFontFamilyFromName", "uint", &fontTitle, "uint", hCollection, "uint*", hFamily)
			if (hFamily) {
				PROGRAM.FONTS[fontTitle] := hFamily
				AppendToLogs(A_ThisFunc "(): Loaded font file """ A_LoopFileName """ with title """ fontTitle """ inside family """ hFamily """.")
			}
			else
				AppendToLogs(A_ThisFunc "(): Couldn't load font file """ A_LoopFileName """ with title """ fontTitle """ (family=""" hFamily """)!")
		}
		else if ( whatDo="UNLOAD") {
			Gdip_DeleteFontFamily(PROGRAM.FONTS[fontTitle])
			DllCall( "GDI32.DLL\RemoveFontResourceEx",Str, A_LoopFileFullPath,UInt,(FR_PRIVATE:=0x10),Int,0)
			AppendToLogs(A_ThisFunc "(): Unloaded font with title """ fontTitle ".")
		}
	}

	if (whatDo = "UNLOAD")
		PROGRAM["FONTS"] := {}

	; SendMessage, 0x1D,,,, ahk_id 0xFFFF
	PostMessage, 0x1D,,,, ahk_id 0xFFFF
}
