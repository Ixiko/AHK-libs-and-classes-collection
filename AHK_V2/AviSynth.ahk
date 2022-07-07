; requires TheArkyTekt_CommandLine.ahk

Global AviSynthHwnd
Global AviSynthX86, AviSynthX64
Global AviSynthRootPath, AviSynthSettings
Global AviSynthSel, AviSynthList, AviSynthLocalInstall, AviSynthNativeInstall, AviSynthRegistry, AviSynthRegistryList
Global AviSynthInstallBtn, AviSynthUninstallX86Btn, AviSynthUninstallX64Btn

AviSynthSettings := SettingLoad("AviSynth.txt")
AviSynthRootPath := SettingRead(AviSynthSettings,"AviSynthRootPath","=")
AviSynthX86 := SettingRead(AviSynthSettings,"AviSynthX86","=")
AviSynthX64 := SettingRead(AviSynthSettings,"AviSynthX64","=")

AviSynthRegistry := SettingRead(AviSynthSettings,"AviSynthRegistry","=")
If (AviSynthRegistry = "") {
	AviSynthRegistry := "HKLM"
	AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthRegistry",AviSynthRegistry,"=")
}
	
If (AviSynthRegistry = "HKLM")
	AviSynthRegistryList := "HKLM||HKCU"
Else
	AviSynthRegistryList := "HKLM|HKCU||"
	
AviSynthLocalInstall := SettingRead(AviSynthSettings,"AviSynthLocalInstall","=")
If (AviSynthLocalInstall = "") {
	AviSynthLocalInstall := 0
	AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthLocalInstall",AviSynthLocalInstall,"=")
}
AviSynthNativeInstall := SettingRead(AviSynthSettings,"AviSynthNativeInstall","=")
If (AviSynthNativeInstall = "") {
	AviSynthNativeInstall := 0
	AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthNativeInstall",AviSynthNativeInstall,"=")
}

AviSynthGUI() {
	If (AviSynthRootPath = "") {
		isAvs := False
		Loop, Files, %A_ScriptDir%\*, D
		{
			If (InStr(A_LoopFileName,"AviSynth")) {
				isAvs := True, AviSynthRootPath := A_ScriptDir
				Break
			}
		}
	
		If (AviSynthRootPath = "") {
			FileSelectFolder, RootPath, , , Select AviSynth Root Folder:
			If (RootPath = "")
				ExitApp
			Else
				AviSynthRootPath := RootPath
		}
		
		AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthRootPath",AviSynthRootPath,"=")
	}
	
	Gui, AviSynthGui:New, +HwndAviSynthHwnd +LabelAviSynthGui +OwnDialogs, AviSynth Installer
	
	Gui, Add, Text, Section, Root Path:
	Gui, Add, Edit, x+2 yp-3 w328 vAviSynthRootPath, %AviSynthRootPath%
	Gui, Add, Button, x+0 gAviSynthRootPathSel, Browse...
	
	Gui, Add, Checkbox, xs y+3 vAviSynthLocalInstall gAviSynthLocalInstall, Attempt local install
	Gui, Add, Checkbox, x+10 vAviSynthNativeInstall gAviSynthNativeInstall, Force native install
	Gui, Add, Text, x+10, Registry:
	Gui, Add, DropDownList, x+3 yp-3 w60 vAviSynthRegistry gAviSynthRegistry, %AviSynthRegistryList%
	Gui, Add, Button, x+9 gTestInstall, Test Install
	GUi, Add, Button, x+0 gHelpBtn, ?
	
	GuiControl, , AviSynthLocalInstall, %AviSynthLocalInstall%
	GuiControl, , AviSynthNativeInstall, %AviSynthNativeInstall%
	Gui, Add, ListBox, xs w200 r5 vAviSynthSel gAviSynthSel
	
	Gui, Add, Text, x+5 yp+3 w30 Right Section, x86:
	Gui, Add, Edit, x+2 yp-3 w200 vAviSynthX86 ReadOnly, %AviSynthX86%
	Gui, Add, Text, xs y+3 w30 Right, x64:
	Gui, Add, Edit, x+2 yp-3 w200 vAviSynthX64 ReadOnly, %AviSynthX64%
	
	Gui, Add, Button, xp y+0 vAviSynthInstallBtn gAviSynthInstallBtn Disabled, Install
	Gui, Add, Button, x+0 vAviSynthUninstallX86Btn gAviSynthUninstallX86Btn, Uninstall x86
	Gui, Add, BUtton, x+0 vAviSynthUninstallX64Btn gAviSynthUninstallX64Btn, Uninstall x64
	
	AviSynthMakeList()
	
	Gui, Show
}

AviSynthGuiClose(hwnd) {
	If (hwnd = AviSynthHwnd) {
		AviSynthSetW()
		ExitApp
	}
}

HelpBtn() {
	msg := "-= Attempt local install =-`r`n`r`n"
	     . "    This will refrain from copying over the DLL files to the system folder.  "
		 . "The corresponding registry entries will write a full path to the DLL in the CLSID entry.  "
		 . "Normally the CLSID registry entry is simply " Chr(34) "AviSynth.dll" Chr(34) "`r`n`r`n"
		 . "-= Force native install =-`r`n`r`n"
		 . "    This will force installing a 32-bit AviSynth to the 64-bit location (applies to registry and system folders).  "
		 . "I've only seen this used in conjunction with a " Chr(34) "local" Chr(34) " install.`r`n`r`n"
		 . "======================================`r`n"
		 . "    I've added the options so people can try different configurations.  Generally speaking, these options "
		 . "will work best when only installing a single version of AviSynth.  If you want to use x86 and x64 side-by-side, "
		 . "then use the default install method.`r`n"
		 . "======================================`r`n`r`n"
		 . "-= Registry Selection =-`r`n`r`n"
		 . "    Specify wich registry key to install to, HKLM or HKCU.  This also applies when uninstalling, meaning that "
		 . "this program will only look in the specified location for the installed registry entries.`r`n`r`n"
		 . "======================================`r`n`r`n"
		 . "Reset to default options:`r`n"
		 . "    uncheck both checkboxes`r`n"
		 . "    Registry: HKLM`r`n`r`n"
		 . "The default installation will copy AviSynth DLLs to the system folders and install all registry entries.  "
		 . "The default install method will work for all applications.  "
		 . "If you use the options to change the defaults, unexpected things can happen.  Use these options at your own risk."
		 
	MsgBox, , AviSynth Installer Help, %msg%
}

TestInstall() {
	str := StdoutToVar("AvsVersion32.exe")
	str .= "`r`n`r`n" StdoutToVar("AvsVersion64.exe")
	msgbox % str
}

AvsVersion32() {
	str := StdoutToVar("AvsVersion32.exe")
	return str
}

AvsVersion64() {
	str := StdoutToVar("AvsVersion64.exe")
	return str
}

AviSynthSetW() {
	SettingWrite("AviSynth.txt",AviSynthSettings)
}

AviSynthRootPathSel() {
	FileSelectFolder, RootPath, *%AviSynthRootPath%, , Select AviSynth Root Folder:
	If (RootPath) {
		AviSynthRootPath := RootPath
		AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthRootPath",AviSynthRootPath,"=")
		GuiControl, , AviSynthRootPath, %AviSynthRootPath%
	}
}

AviSynthLocalInstall() {
	GuiControlGet, AviSynthLocalInstall
	AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthLocalInstall",AviSynthLocalInstall,"=")
}

AviSynthNativeInstall() {
	GuiControlGet, AviSynthNativeInstall
	AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthNativeInstall",AviSynthNativeInstall,"=")
}

AviSynthMakeList() {
	Loop, Files, %AviSynthRootPath%\*, D
		If (InStr(A_LoopFileName,"AviSynth") = 1 Or InStr(A_LoopFileName,"AVS") = 1)
			AviSynthList .= A_LoopFileName "|"
	
	AviSynthList := Trim(AviSynthList,OmitChars:="|")
	GuiControl, , AviSynthSel, |%AviSynthList%
}

AviSynthRegistry() {
	GuiControlGet, AviSynthRegistry
	AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthRegistry",AviSynthRegistry,"=")
}

AviSynthSel() {
	GuiControl, Enable, AviSynthInstallBtn
}

; ========================================================
; Install / Uninstall button events
; ========================================================

AviSynthInstallBtn() {
	GuiControlGet, AviSynthSel
	dllPath := AviSynthRootPath "\" AviSynthSel
	result := AviSynthInstall(dllPath,AviSynthRegistry,AviSynthLocalInstall,AviSynthNativeInstall)
	
	If (InStr(dllPath,"x86") Or 
	  . InStr(dllPath,"win32") Or 
	  . InStr(dllPath,"win 32") Or 
	  . InStr(dllPath,"win_32") Or 
	  . InStr(dllPath,"x32") Or
	  . InStr(dllPath,"32-bit") Or
	  . InStr(dllPath,"32 bit") Or
	  . InStr(dllPath,"32bit")
	  . )
		AvsArch := "x86"
	Else If (InStr(dllPath,"x64") Or 
	       . InStr(dllPath,"win64") Or 
		   . InStr(dllPath,"win 64") Or 
		   . InStr(dllPath,"win_64") Or
		   . InStr(dllPath,"64-bit") Or
		   . InStr(dllPath,"64 bit") Or
		   . InStr(dllPath,"64bit")
		   . )
		AvsArch := "x64"
		
	If (AvsArch = "x86") {
		AviSynthX86 := AviSynthSel
		GuiControl, , AviSynthX86, %AviSynthX86%
		AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthX86",AviSynthX86,"=")
	} Else {
		AviSynthX64 := AviSynthSel
		GuiControl, , AviSynthX64, %AviSynthX64%
		AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthX64",AviSynthX64,"=")
	}
}

AviSynthUninstallX86Btn() {
	If (AviSynthX86) {
		dllPath := AviSynthRootPath "\" AviSynthX86

		result := AviSynthUninstall(dllPath,AviSynthRegistry)
		
		GuiControl, , AviSynthX86
		AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthX86","","=")
	}
}

AviSynthUninstallX64Btn() {
	If (AviSynthX64) {
		dllPath := AviSynthRootPath "\" AviSynthX64

		result := AviSynthUninstall(dllPath,AviSynthRegistry)
		
		GuiControl, , AviSynthX64
		AviSynthSettings := SettingUpdate(AviSynthSettings,"AviSynthX64","","=")
	}
}

; ========================================================
; Support Function
; ========================================================

AviSynthInstall(dllPath,node:="HKLM",tryLocal:=0,forceNative:=0) {
	plus := 0, p := "", oops := 0
	ServerPath := ""
	
	If (tryLocal)
		ServerPath := dllPath "\AviSynth.dll"
	Else
		ServerPath := "AviSynth.dll"
	
	If (InStr(dllPath,"x86") Or 
	  . InStr(dllPath,"win32") Or 
	  . InStr(dllPath,"win 32") Or 
	  . InStr(dllPath,"win_32") Or 
	  . InStr(dllPath,"x32") Or
	  . InStr(dllPath,"32-bit") Or
	  . InStr(dllPath,"32 bit") Or
	  . InStr(dllPath,"32bit")
	  . )
		AvsArch := "x86"
	Else If (InStr(dllPath,"x64") Or 
	       . InStr(dllPath,"win64") Or 
		   . InStr(dllPath,"win 64") Or 
		   . InStr(dllPath,"win_64") Or
		   . InStr(dllPath,"64-bit") Or
		   . InStr(dllPath,"64 bit") Or
		   . InStr(dllPath,"64bit")
		   . )
		AvsArch := "x64"
	
	If (A_Is64bitOS And forceNative = 0) {
		If (AvsArch = "x64") {
			installDir := A_WinDir "\System32"
			regPath := ""
		} Else {
			installDir := A_WinDir "\SysWOW64"
			regPath := "Wow6432Node\"
		}
	} Else {
		installDir := A_WinDir "\System32"
		regPath := ""
	}
	
	pluginDir := dllPath "\plugins" ; do it like the Universal Installer for AviSynth
	if (node = "HKCU") ; force not using Wow6432Node if node="HKCU"
		regPath := ""
	
	
	; === check for AviSynth+ (Plus) ====================
	If (InStr(dllPath,"+") Or InStr(dllPath,"plus"))
		plus := 1, p := "+"
	
	If (plus)
		iconPath := dllPath "\AviSynth.dll,1"
	Else
		iconPath := dllPath "\AviSynth.dll,0"
	staticIconPath := dllPath "\AviSynth.dll,0"
	
	
	; === Copy DLLs to system folders =============
	If (tryLocal = 0) {
		FileCopy, %dllPath%\AviSynth.dll, %installDir%\AviSynth.dll, 1
		If (ErrorLevel)
			oops += ErrorLevel
		FileCopy, %dllPath%\DevIL.dll, %installDir%\DevIL.dll, 1
		If (ErrorLevel)
			oops += ErrorLevel
		
		If (oops) {
			MsgBox Unable to copy all files to system folder(s).
			return
		}
	}
	
	
	; === Plugin Reg Entries ==================
	RegWrite, REG_SZ, %node%\Software\%regPath%AviSynth, , %dllPath%
	If (plus)
		RegWrite, REG_SZ, %node%\Software\%regPath%AviSynth, PluginDir+, %pluginDir%
	Else
		RegWrite, REG_SZ, %node%\Software\%regPath%AviSynth, PluginDir2_5, %pluginDir%
	
	; === 32/64 bit dll registration entries ===============
	RegWrite, REG_SZ, %node%\Software\%regPath%Classes\CLSID\{E6D6B700-124D-11D4-86F3-DB80AFD98778}, , AviSynth%p%
	RegWrite, REG_SZ, %node%\Software\%regPath%Classes\CLSID\{E6D6B700-124D-11D4-86F3-DB80AFD98778}\InProcServer32, , %ServerPath%
	RegWrite, REG_SZ, %node%\Software\%regPath%Classes\CLSID\{E6D6B700-124D-11D4-86F3-DB80AFD98778}\InProcServer32, ThreadingModel, Apartment
	
	; RegWrite, REG_SZ, %node%\Software\%regPath%\CLSID\{E6D6B700-124D-11D4-86F3-DB80AFD98778}\InProcHandler32, , %ServerPath%
	; RegWrite, REG_SZ, %node%\Software\%regPath%\CLSID\{E6D6B700-124D-11D4-86F3-DB80AFD98778}\InProcHandler32, ThreadingModel, Apartment
	
	RegWrite, REG_SZ, %node%\Software\%regPath%Classes\Media Type\Extensions\.avs, Source Filter, {D3588AB0-0781-11CE-B03A-0020AF0BA770}
	
	; === common entries for all systems ======================
	RegWrite, REG_SZ, %node%\Software\Classes\AVIFile\Extensions\AVS, , {E6D6B700-124D-11D4-86F3-DB80AFD98778}
	
	RegWrite, REG_SZ, %node%\Software\Classes\.avs, , avsfile
	RegWrite, REG_SZ, %node%\Software\Classes\.avsi, , avs_auto_file
	RegWrite, REG_SZ, %node%\Software\Classes\avsfile, , AviSynth Script
	RegWrite, REG_SZ, %node%\Software\Classes\avsfile\DefaultIcon, , %staticIconPath%
	
	RegWrite, REG_SZ, %node%\Software\Classes\avs_auto_file, , AviSynth Autoload Script
	RegWrite, REG_SZ, %node%\Software\Classes\avs_auto_file\DefaultIcon, , %iconPath%
	
	If (ErrorLevel) {
		MsgBox There was a problem writing registry entries.  The installation has be interrupted.
		Return
	}
	
	MsgBox AviSynth installed.
	return 1
}

AviSynthUninstall(dllPath,node="HKLM") {
	; specify "HKCU" for HKey_Current_User key
	; default is HKey_Local_Machine
	
	If (InStr(dllPath,"x86") Or 
	  . InStr(dllPath,"win32") Or 
	  . InStr(dllPath,"win 32") Or 
	  . InStr(dllPath,"win_32") Or 
	  . InStr(dllPath,"x32") Or
	  . InStr(dllPath,"32-bit") Or
	  . InStr(dllPath,"32 bit") Or
	  . InStr(dllPath,"32bit")
	  . )
		AvsArch := "x86"
	Else If (InStr(dllPath,"x64") Or 
	       . InStr(dllPath,"win64") Or 
		   . InStr(dllPath,"win 64") Or 
		   . InStr(dllPath,"win_64") Or
		   . InStr(dllPath,"64-bit") Or
		   . InStr(dllPath,"64 bit") Or
		   . InStr(dllPath,"64bit")
		   . )
		AvsArch := "x64"
	
	r := 1
	MsgBox, 4, Uninstall AviSynth, Uninstalling %AvsArch% AviSynth`r`n`r`nContinue?
	
	IfMsgBox, No
		r := 0
	
	If (r = 0)
		return ; exit if user selects "NO"
	
	fail := 0
	If (A_Is64bitOS) { ; is a 64-bit OS
		If (AvsArch = "x64") { ; 64-bit
			regPath := ""
			
			If (FileExist(A_WinDir "\System32\AviSynth.dll")) {
				FileDelete, %A_WinDir%\System32\AviSynth.dll
				if (ErrorLevel)
					fail += ErrorLevel
			}
			If (FileExist(A_WinDir "\System32\DevIL.dll")) {
				FileDelete, %A_WinDir%\System32\DevIL.dll
				if (ErrorLevel)
					fail += ErrorLevel
			}
		} Else { ; 32-bit
			regPath := "Wow6432Node\"
			
			If (FileExist(A_WinDir "\SysWOW64\AviSynth.dll")) {
				FileDelete, %A_WinDir%\SysWOW64\AviSynth.dll
				if (ErrorLevel)
					fail := ErrorLevel
			}
			If (FileExist(A_WinDir "\SysWOW64\DevIL.dll")) {
				FileDelete, %A_WinDir%\SysWOW64\DevIL.dll
				if (ErrorLevel)
					fail += ErrorLevel
			}
		}
	} Else { ; is not 64-bit OS
		regPath := ""
		
		If (FileExist(A_WinDir "\System32\AviSynth.dll")) {
			FileDelete, %A_WinDir%\System32\AviSynth.dll
			if (ErrorLevel)
				fail += ErrorLevel
		}
		If (FileExist(A_WinDir "\System32\DevIL.dll")) {
			FileDelete, %A_WinDir%\System32\DevIL.dll
			if (ErrorLevel)
				fail += ErrorLevel
		}
	}
	
	if (node = "HKCU")
		regPath := ""
	
	If (fail) {
		MsgBox AviSynth was not able to be completely removed.  Check to make sure you don't have any running scripts.
		return
	}
	
	If (AvsArch = "x64")
		otherOne := AviSynthX86
	Else
		otherOne := AviSynthX64
	
	If (otherOne = "") { ; don't remove these keys if running 2 AviSynth versions
		RegDelete, %node%\Software\Classes\AVIFile\Extensions\AVS
		RegDelete, %node%\Software\Classes\.avs
		RegDelete, %node%\Software\Classes\.avsi
		RegDelete, %node%\Software\Classes\avsfile
		RegDelete, %node%\Software\Classes\avs_auto_file
	}
	
	RegDelete, %node%\Software\%regPath%Avisynth
	RegDelete, %node%\Software\%regPath%Classes\CLSID\{E6D6B700-124D-11D4-86F3-DB80AFD98778}
	RegDelete, %node%\Software\%regPath%Classes\Media Type\Extensions\.avs
	
	If (ErrorLevel) {
		MsgBox There was a problem removing the registry entries.  Please make sure a script is not running.
		return
	}
	
	MsgBox AviSynth uninstall complete.
	return 1
}

