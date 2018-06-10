/*
	Change Log:
		v1.11 (2017-01-17) - Added an internal function Ensure_Admin_And_Compiled()
		v1.10 (2015-10-22) - Added support for sending characters that needs to press {shift} key, such as "@" or "A".
		v1.00 (2015-07-25)

	Dependency files:
		WinRing0_v1.3.1.19.zip -- https://drive.google.com/file/d/0B7yNOlCgfluzMTE2UFc2ZHp5Z1E/view?usp=sharing

	Functions:
		KeyDown(chr, delay := 5)
		KeyUp(chr, delay := 1)
		KeyPress(chr)
		SendStr(string)
		KeyCombine(arr*)

	Examples:
		WinRing0.KeyDown("a")
		WinRing0.KeyUp("a")
		WinRing0.KeyPress("a") ; Same as KeyDown + KeyUp
		WinRing0.SendStr("autohotkey")
		WinRing0.KeyCombine("Ctrl", "A")
*/

Class WinRing0 {

	static _Init := WinRing0.Init()
	static _InitDelFunc := OnExit( ObjBindMethod(WinRing0, "_Del") )

	GetDllVersion() {
		DllCall(this.dll . "\GetDllVersion", "UCharP", major, "UCharP", minor, "UCharP", revision, "UCharP", release)
		Return major . "." minor . "." . revision . "." . release
	}

	KBCWait4IBE() {
		dwVal := 0
		Loop {
			this.ReadIoPortByteEx(0x64, dwVal)
			If ((dwVal & 0x2) <= 0)
				Break
			Sleep, 10
		}
	}

	KeyDown(chr, delay := 5) {
		If this.NeedShift(chr)
			this.KeyDown("shift", 20)

		k := this.GetScancode(chr)
		this.KBCWait4IBE()
		this.WriteIoPortByte(0x64, 0xd2)
		this.KBCWait4IBE()
		this.WriteIoPortByte(0x60, k)
		Sleep, %delay%
	}

	KeyUp(chr, delay := 1) {
		k := this.GetScancode(chr)
		this.KBCWait4IBE()
		this.WriteIoPortByte(0x64, 0xd2)
		this.KBCWait4IBE()
		this.WriteIoPortByte(0x60, k|0x80)
		Sleep, %delay%

		If this.NeedShift(chr)
			this.KeyUp("shift", 5)
	}

	KeyPress(chr) {
		this.KeyDown(chr)
		this.KeyUp(chr)
	}

	SendStr(string, delay := 5) {
		Loop, Parse, string
		{
			this.KeyPress(A_LoopField)
			Sleep, % delay
		}
	}

	KeyCombine(arr*) {
		For idx, chr in arr
			this.KeyDown( Format("{:L}", chr) )
		For idx, chr in arr
			this.KeyUp( Format("{:L}", chr) )
	}

	GetScancode(char) {
		static VK := WinRing0.InitVK()
		uCode := VK.HasKey(char) ? VK[char] : DllCall("VkKeyScanA", "char", Asc(char))
		Return DllCall("MapVirtualKey", "UInt", uCode & 0xFF, "UInt", 0) ; MAPVK_VK_TO_VSC=0
	}

	NeedShift(chr) {
		static obj := { "~": 1
                      , ")": 1
                      , "!": 1
                      , "@": 1
                      , "#": 1
                      , "$": 1
                      , "%": 1
                      , "^": 1
                      , "&": 1
                      , "*": 1
                      , "(": 1
                      , "?": 1
                      , "{": 1
                      , "|": 1
                      , "}": 1
                      , """": 1
                      , "<": 1
                      , ">": 1
                      , "_": 1
                      , "+": 1
                      , ":": 1 }
		Return obj[chr] || (chr ~= "[A-Z]")
	}

	InitVK() {
		list =
		(LTrim
			LBUTTON=0x01
			RBUTTON=0x02
			CANCEL=0x03
			MBUTTON=0x04
			XBUTTON1=0x05
			XBUTTON2=0x06
			BACK=0x08
			TAB=0x09
			CLEAR=0x0C
			RETURN=0x0D
			SHIFT=0x10
			CONTROL=0x11
			Ctrl=0x11
			MENU=0x12
			Alt=0x12
			PAUSE=0x13
			CAPITAL=0x14
			KANA=0x15
			HANGUEL=0x15
			HANGUL=0x15
			JUNJA=0x17
			FINAL=0x18
			HANJA=0x19
			KANJI=0x19
			ESCAPE=0x1B
			CONVERT=0x1C
			NONCONVERT=0x1D
			ACCEPT=0x1E
			MODECHANGE=0x1F
			SPACE=0x20
			PRIOR=0x21
			NEXT=0x22
			END=0x23
			HOME=0x24
			LEFT=0x25
			UP=0x26
			RIGHT=0x27
			DOWN=0x28
			SELECT=0x29
			PRINT=0x2A
			EXECUTE=0x2B
			SNAPSHOT=0x2C
			INSERT=0x2D
			DELETE=0x2E
			HELP=0x2F
			LWIN=0x5B
			Win=0x5B
			RWIN=0x5C
			APPS=0x5D
			SLEEP=0x5F
			NUMPAD0=0x60
			NUMPAD1=0x61
			NUMPAD2=0x62
			NUMPAD3=0x63
			NUMPAD4=0x64
			NUMPAD5=0x65
			NUMPAD6=0x66
			NUMPAD7=0x67
			NUMPAD8=0x68
			NUMPAD9=0x69
			MULTIPLY=0x6A
			ADD=0x6B
			SEPARATOR=0x6C
			SUBTRACT=0x6D
			DECIMAL=0x6E
			DIVIDE=0x6F
			F1=0x70
			F2=0x71
			F3=0x72
			F4=0x73
			F5=0x74
			F6=0x75
			F7=0x76
			F8=0x77
			F9=0x78
			F10=0x79
			F11=0x7A
			F12=0x7B
			F13=0x7C
			F14=0x7D
			F15=0x7E
			F16=0x7F
			F17=0x80
			F18=0x81
			F19=0x82
			F20=0x83
			F21=0x84
			F22=0x85
			F23=0x86
			F24=0x87
			NUMLOCK=0x90
			SCROLL=0x91
			LSHIFT=0xA0
			RSHIFT=0xA1
			LCONTROL=0xA2
			RCONTROL=0xA3
			LMENU=0xA4
			RMENU=0xA5
			BROWSER_BACK=0xA6
			BROWSER_FORWARD=0xA7
			BROWSER_REFRESH=0xA8
			BROWSER_STOP=0xA9
			BROWSER_SEARCH=0xAA
			BROWSER_FAVORITES=0xAB
			BROWSER_HOME=0xAC
			VOLUME_MUTE=0xAD
			VOLUME_DOWN=0xAE
			VOLUME_UP=0xAF
			MEDIA_NEXT_TRACK=0xB0
			MEDIA_PREV_TRACK=0xB1
			MEDIA_STOP=0xB2
			MEDIA_PLAY_PAUSE=0xB3
			LAUNCH_MAIL=0xB4
			LAUNCH_MEDIA_SELECT=0xB5
			LAUNCH_APP1=0xB6
			LAUNCH_APP2=0xB7
			OEM_1=0xBA
			OEM_PLUS=0xBB
			OEM_COMMA=0xBC
			OEM_MINUS=0xBD
			OEM_PERIOD=0xBE
			OEM_2=0xBF
			OEM_3=0xC0
			OEM_4=0xDB
			OEM_5=0xDC
			OEM_6=0xDD
			OEM_7=0xDE
			OEM_8=0xDF
			OEM_102=0xE2
			PROCESSKEY=0xE5
			PACKET=0xE7
			ATTN=0xF6
			CRSEL=0xF7
			EXSEL=0xF8
			EREOF=0xF9
			PLAY=0xFA
			ZOOM=0xFB
			NONAME=0xFC
			PA1=0xFD
			OEM_CLEAR=0xFE
		)
		obj := {}
		Loop, Parse, list, `n, `r
		{
			arr := StrSplit(A_LoopField, "=")
			obj[ arr[1] ] := arr[2]
		}
		Return obj
	}

	/*
		Parameters
			port - [in] I/O port address 
			value - [out] a BYTE value 
		Return Values
			If the function succeeds, the return value is TRUE. 
			If the function fails, the return value is FALSE.
	*/
	ReadIoPortByteEx(port, ByRef value) {
		Return DllCall(this.dll . "\ReadIoPortByteEx", "UShort", port, "Ptr", value)
	}

	/*
		Parameters
			port - [in] I/O port address 
			value - [in] a BYTE value to write to the port 
		Return Values
			None
	*/
	WriteIoPortByte(port, value) {
		DllCall(this.dll . "\WriteIoPortByte", "UShort", port, "UChar", value, "Ptr")
	}

	Init() {
		this.Ensure_Admin_And_Compiled()

		this.dll := (A_PtrSize = 8) ? "WinRing0x64.dll" : "WinRing0.dll"
		this.hModule := DllCall("LoadLibrary", "Str", this.dll, "Ptr")
		If !DllCall(this.dll . "\InitializeOls") {
			MsgBox, 48, InitializeOls Error, % this.GetDllStatus()
			ExitApp
		}
		Return True
	}

	Ensure_Admin_And_Compiled() {
		if !A_IsCompiled {
			throw, "Need to run in compiled EXE!"
		}
		if !A_IsAdmin {
			Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
			ExitApp
		}
	}

	GetDllStatus() {
		obj := { 0: "No error"
		       , 1: "Unsupported Platform"
		       , 2: "Driver not loaded"
		       , 3: "Driver not found"
		       , 4: "Driver unloaded by other process"
		       , 5: "Driver not loaded because of executing on Network Drive (1.0.8 or later)"
		       , 9: "Unknown error" }
		n := DllCall(this.dll . "\GetDllStatus", "UInt")
		Return obj[n]
	}

	_Del() {
		if this.hModule {
			DllCall(this.dll . "\DeinitializeOls")
			DllCall("FreeLibrary", "Ptr", this.hModule)
		}
	}
}