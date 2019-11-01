
class Accessibility {

	; use the Accessibility APi
	; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx

	; ###############
	; ##
	; ##  Set Variables
	; ##
	; ###############
	
	static SPI_GETACCESSTIMEOUT := 0x003C
	static SPI_SETACCESSTIMEOUT := 0x003D
	static SPI_GETAUDIODESCRIPTION := 0x0074
	static SPI_SETAUDIODESCRIPTION := 0x0075
	static SPI_GETCLIENTAREAANIMATION := 0x1042
	static SPI_SETCLIENTAREAANIMATION := 0x1043
	static SPI_GETDISABLEOVERLAPPEDCONTENT := 0x1040
	static SPI_SETDISABLEOVERLAPPEDCONTENT := 0x1041
	static SPI_GETFILTERKEYS := 0x0032
	static SPI_SETFILTERKEYS := 0x0033
	static SPI_GETFOCUSBORDERHEIGHT := 0x2010
	static SPI_SETFOCUSBORDERHEIGHT := 0x2011
	static SPI_GETFOCUSBORDERWIDTH := 0x200E
	static SPI_SETFOCUSBORDERWIDTH := 0x200F
	static SPI_GETHIGHCONTRAST := 0x0042
	static SPI_SETHIGHCONTRAST := 0x0043
	static SPI_GETLOGICALDPIOVERRIDE := 0x009E
	static SPI_SETLOGICALDPIOVERRIDE := 0x009F
	static SPI_GETMESSAGEDURATION := 0x2016
	static SPI_SETMESSAGEDURATION := 0x2017
	static SPI_GETMOUSECLICKLOCK := 0x101E
	static SPI_SETMOUSECLICKLOCK := 0x101F
	static SPI_GETMOUSECLICKLOCKTIME := 0x2008
	static SPI_SETMOUSECLICKLOCKTIME := 0x2009
	static SPI_GETMOUSEKEYS := 0x0036
	static SPI_SETMOUSEKEYS := 0x0037
	static SPI_GETMOUSESONAR := 0x101C
	static SPI_SETMOUSESONAR := 0x101D
	static SPI_GETMOUSEVANISH := 0x1020
	static SPI_SETMOUSEVANISH := 0x1021
	static SPI_GETSCREENREADER := 0x0046
	static SPI_SETSCREENREADER := 0x0047
	static SPI_GETSERIALKEYS := 0x003E
	static SPI_SETSERIALKEYS := 0x003F
	static SPI_GETSHOWSOUNDS := 0x0038
	static SPI_SETSHOWSOUNDS := 0x0039
	static SPI_GETSOUNDSENTRY := 0x0040
	static SPI_SETSOUNDSENTRY := 0x0041
	static SPI_GETSTICKYKEYS := 0x003A
	static SPI_SETSTICKYKEYS := 0x003B
	static SPI_GETTOGGLEKEYS := 0x0034
	static SPI_SETTOGGLEKEYS := 0x0035
	static SPIF_UPDATEINIFILE := 0x01
	static SPIF_SENDCHANGE := 0x02
	
	static AUDIODESCRIPTIONSTRUCT_SIZE := 24
	static HIGHCONTRASTSTRUCT_SIZE := 240
	
	; ###############
	; ##
	; ##  'private' methods to handle DllCalls
	; ##
	; ###############
		
	; run the DLL Call for the single param to get the value
	single_get(uiAction) {
		if !DllCall("SystemParametersInfo", Uint, uiAction, UInt, 0, UIntP, value, Uint, 0) {
			return "CALL_FAILED"
		}
		return value	
	}
	
	; run the DLL Call for the single param to set the value
	single_set(uiAction, value) {
		if !DllCall("SystemParametersInfo", UInt, uiAction, UInt, 0, Ptr, value, UInt, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE) {
			return "CALL_FAILED"
		}
		return "SUCCESS"
	}
	
	; run the Dll Call for a struct to get the values
	struct_get(uiAction, struct, struct_size) {
		DllCall("SystemParametersInfo", UInt, uiAction, UInt, struct_size, Ptr, struct[""], Uint, 0)
		;MsgBox % ErrorLevel		
		return struct
	}
	
	struct_set(uiAction, struct, struct_size) {
		DllCall("SystemParametersInfo", UInt, uiAction, UInt, struct_size, Ptr, &struct, UInt, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE)
		MsgBox % ErrorLevel
		return "SUCCESS"
	}
	
	; ###############
	; ##
	; ##  Methods that use a Boolean
	; ##
	; ###############
	
	; get Determines whether animations are enabled or disabled. 
	; set Turns client area animations on or off.
	; Windows Server 2003 and Windows XP/2000:  This parameter is not supported.
	ClientAreaAnimation {
		get {
			return this.single_get(this.SPI_GETCLIENTAREAANIMATION)
		}
		set {
			return this.single_set(this.SPI_SETCLIENTAREAANIMATION, value)
		}
	}
	
	; get Determines whether overlapped content is enabled or disabled.
	; set Turns overlapped content (such as background images and watermarks) on or off. 
	; Windows Server 2003 and Windows XP/2000:  This parameter is not supported.
	DisableOverlappedContent {
		get {
			return this.single_get(this.SPI_GETDISABLEOVERLAPPEDCONTENT)
		}
		set {
			return this.single_set(this.SPI_SETDISABLEOVERLAPPEDCONTENT, value)
		}
	}
	
	; get Retrieves the state of the Mouse ClickLock feature
	; Windows 2000:  This parameter is not supported.
	MouseClickLock {
		get {
			return this.single_get(this.SPI_GETMOUSECLICKLOCK)
		}
		set {
			return this.single_set(this.SPI_SETMOUSECLICKLOCK, value)
		}
	}
	
	; get Retrieves the state of the Mouse Sonar feature.
	; Windows 2000:  This parameter is not supported.
	MouseSonar {
		get {
			return this.single_get(this.SPI_GETMOUSESONAR)
		}
		set {
			return this.single_set(this.SPI_SETMOUSESONAR, value)
		}
	}
	
	; get Retrieves the state of the Mouse Vanish feature
	; Windows 2000:  This parameter is not supported.
	MouseVanish {
		get {
			return this.single_get(this.SPI_GETMOUSEVANISH)
		}
		set {
			return this.single_set(this.SPI_SETMOUSEVANISH, value)
		}
	}
	
	; get Determines whether a screen reviewer utility is running.
	; Note  Narrator, the screen reader that is included with Windows, 
	; does not set the SPI_SETSCREENREADER or SPI_GETSCREENREADER flags.
	ScreenReader {
		get {
			return this.single_get(this.SPI_GETSCREENREADER)
		}
		set {
			return this.single_set(this.SPI_SETSCREENREADER, value)
		}
	}
	
	; get Determines whether the Show Sounds accessibility flag is on or off
	
	ShowSounds {
		get {
			return this.single_get(this.SPI_GETSHOWSOUNDS)
		}
		set {
			return this.single_set(this.SPI_SETSHOWSOUNDS, value)
		}
	}
	
	; ###############
	; ##
	; ##  Methods that use a UInt 
	; ##
	; ###############
	
	; get Retrieves the height, in pixels, of the top and bottom edges of the focus rectangle drawn with DrawFocusRect.
	; set Sets the height of the top and bottom edges of the focus rectangle drawn with DrawFocusRect to the value of the pvParam parameter.
	; Windows 2000:  This parameter is not supported.
	FocusBorderHeight {
		get {
			return this.single_get(this.SPI_GETFOCUSBORDERHEIGHT)
		}
		set {
			return this.single_set(this.SPI_SETFOCUSBORDERHEIGHT, value)
		}
	}
	
	; get Retrieves the width, in pixels, of the left and right edges of the focus rectangle drawn with DrawFocusRect. 
	; Windows 2000:  This parameter is not supported.
	FocusBorderWidth {
		get {
			return this.single_get(this.SPI_GETFOCUSBORDERWIDTH)
		}
		set {
			return this.single_set(this.SPI_SETFOCUSBORDERWIDTH, value)
		}
	}
	
	; get Retrieves the time that notification pop-ups should be displayed, in seconds
	; Windows Server 2003 and Windows XP/2000:  This parameter is not supported.
	MessageDuration {
		get {
			return this.single_get(this.SPI_GETMESSAGEDURATION)
		}
		set {
			return this.single_set(this.SPI_SETMESSAGEDURATION, value)
		}
	}
	
	; get Retrieves the time delay before the primary mouse button is locked
	; Windows 2000:  This parameter is not supported.
	MouseClickLockTime {
		get {
			return this.single_get(this.SPI_GETMOUSECLICKLOCKTIME)
		}
		set {
			return this.single_set(this.SPI_SETMOUSECLICKLOCKTIME, value)
		}
	}
	
	; ###############
	; ##
	; ##  Methods that use a struct 
	; ##
	; ###############
	
	
	build_highcontrast_struct() {
		struct := "
		(
		UINT cbSize;
		DWORD dwFlags;
		LPTSTR lpszDefaultScheme;
		)"
		HCS := new _struct(struct)
		HCS.cbSize := sizeof(HCS)
		return HCS
	}
	
	HighContrast {
		get {
			;test := this.build_highcontrast_struct()
			;MsgBox % test.AhkType(dwFlags)
			struct := this.struct_get(this.SPI_GETHIGHCONTRAST, this.build_highcontrast_struct(), sizeof(HCS))
			MsgBox % "cbSize = " + NumGet(&struct + 0, "UInt")
			MsgBox % "dwFlags = " + NumGet(&struct + 4, "UInt")
			MsgBox % "lpszDefaultScheme = " + StrGet(&struct + 8, "UItn")
		}
		set {
		
		}
	}
	
	build_audiodescription_struct() {
		; UINT cbSize; 4
		; BOOL Enabled; 4
		; LCID Locale; 16
		VarSetCapacity(ADS, this.AUDIODESCRIPTIONSTRUCT_SIZE, 0)
		; cbSize offset = 0
		NumPut(this.AUDIODESCRIPTIONSTRUCT_SIZE, ADS, 0, "UInt")
		return ADS
	}
	
	; get Determines whether audio descriptions are enabled or disabled
	; set
	; Windows Server 2003 and Windows XP/2000:  This parameter is not supported.
	AudioDescription {
		get {
			struct := this.struct_get(this.SPI_GETAUDIODESCRIPTION, this.build_audiodescription_struct(), this.AUDIODESCRIPTIONSTRUCT_SIZE)
			;MsgBox % "cbSize = " + NumGet(&struct + 0, "UInt")
			MsgBox % "Enabled = " + NumGet(&struct + 4, "UInt")
			;MsgBox % "Locale = " + StrGet(&struct + 8, "UItn")
		}
		set {
			struct := this.build_audiodescription_struct
			NumPut(1, struct, 4, "Int")
			this.struct_set(this.SPI_SETAUDIODESCRIPTION, struct, this.AUDIODESCRIPTIONSTRUCT_SIZE)
		}
	}
		
}

