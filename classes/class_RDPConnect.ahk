/*
A Class to log in via RDP to a remote computer.
Tries to automate all the windows that the RDP client (mstsc.exe) creates, including...
Address to connect to, login credentials, certificate warning, actual session window

Fires a FuncObject callback whenever the session connects or disconnects, or when a login attempt is aborted.

All windows related to one RDP session share the same PID, and each instance of the class only interacts with
windows that have the same PID.
All UI interactions (Key sending, Form filling) do not require the RDP windows to be focused.
*/

class RDPConnect {
	static version := "1.0.15"
	/*
	Instantiate this class to initiate a new RDP Session
	new RDPConnect(Address, UserName, Password, Callback)
	Address: The Address (eg IP) to connect to
	UserName: The Domain\Username to connect to
	Password: The password to use
	Callback: FuncObject to be called when session connects, disconnects, or aborts connection attempt
	Options: Associative Array of options
	
	When the callback is called, it is passed three params:
	Status: See ErrorCodes. Also see GetErrorName / GetErrorCode methods to convert codes to strings and vice versa
	PID: The PID of the created session
	HWND: The HWND of the SESSION window (The one with the desktop in), or 0 if it does not exist (eg the user disconnected)
	
	Available Options:
	DefaultSleep: The amount of time (in ms) to wait between each step of UI interaction.
	ShowOptions: Do not click OK at the options screen (Choose resolution etc stage). Allow the user to pick options and click OK.
	MaxLoginAttempts: The maximum amount of times to try logging in before giving up. Increase if it sometimes fails.
	
	Class Properties:
	All internal class properties that users of the class are not intended to interact with are prefixed with an underscore (_)
	So for maximum safety, if you wish to set properties on an instance of the class, don't prefix with an _underscore
	The following properties are not pefixed, and should NOT be set, but may be useful to read
	.hwnd - Starts as 0. Changes to the HWND of the Session Window (The one with the remote desktop in) once connectin succeeds, then to 0 on disconnect.
	.pid - The Process ID of the Session that instance is handling. Will never change for an instance.
	*/
	__New(address, username, password, callback, options := 0){
		; Save passed params for future use
		this._address := address
		this._username := username
		this._password := password
		this._callback := callback
		
		if (address = ""){
			this.CloseSession(this._ErrorCodes.BAD_ADDRESS)
			return
		}
		
		; Set Default options
		this._options := {DefaultSleep: 250, ShowOptions: 0, MaxLoginAttempts: 1, WaitForDesktopColor: 0}
		; Modify with passed options
		if (IsObject(options)){
			for option, value in options {
				this._options[option] := value
			}
		}		

		this._ErrorCodes := {OK: 0, BAD_ADDRESS: 1, LOGIN_FAILED: 2, WAIT_DESKTOP_FAILED: 3}
		this._ErrorNames := {0: "OK", 1: "Bad Address", 2: "Login Failed", 3: "Wait for desktop failed"}
		
		; These will be 0 if the relevant window does not exist, or the hwnd of the window if it exists
		this._SelectWindow := 0
		this._LoginWindow := 0
		this._CertificateWindow := 0
		this._IdentityWindow := 0
		this.hwnd := 0					; The hwnd of the Session window, or 0 if no session active
		
		; How many times we tried to log in
		this._LoginAttempts := 0
		
		; Launch RDP Client, get PID of new process
		Run, %a_windir%\Sysnative\mstsc.exe , , , pid
		this.pid := pid
		
		; Start Timer to watch for this PID creating new windows
		fn := this.WatchPID.Bind(this)
		this._WatchTimer := fn
		SetTimer % fn, 500
	}
	
	; Timer Func to watch for windows opening and closing
	WatchPID(){
		hwnd := WinExist("Remote Desktop Connection ahk_exe mstsc.exe ahk_class #32770 ahk_pid " this.pid, , , "Connecting to:")+0
		if (hwnd){
			WinGetText, t,  % "ahk_id " hwnd
			t := StrSplit(t, "`r")
			t := t[1]
			if (t = "The remote computer could not be authenticated due to problems with its security certificate. It may be unsafe to proceed."){
				if (hwnd != this._CertificateWindow){
					this.Log("Certificate Window detected")
					this.CertificateWindowChanged(hwnd)
					return
				}
			} else if (t = "This remote connection could harm your local or remote computer. Make sure that you trust the remote computer before you connect."){
				if (hwnd != this._WarningWindow){
					this.Log("Warning Window detected")
					this.WarningWindowChanged(hwnd)
					return
				}
			} else if (this.IdentityWindowExists()) {
				if (hwnd != this._IdentityWindow){
					this.Log("Identity Window detected")
					this.IdentityWindowChanged(hwnd)
					return
				}
			} else {
				if (hwnd != this._SelectWindow){
					this.Log("Select Window detected")
					this.SelectWindowChanged(hwnd)
					return
				}
			}
		}
		
		hwnd := this.LoginWindowExists()
		if (hwnd != this._LoginWindow){
			this.LoginWindowChanged(hwnd)
			return
		}

		hwnd := WinExist("ahk_exe mstsc.exe ahk_class TscShellContainerClass ahk_pid " this.pid)+0
		if (hwnd != this.hwnd){
			this.SessionWindowChanged(hwnd)
			return
		}
	}
	
	; The "Select Window" (Dialog to choose machine to log on to) opened or closed
	; This is the first window that opens
	SelectWindowChanged(hwnd){
		WinGetText, t,  % "ahk_id " hwnd
		if (t = "OK`r`n&Help`r`n"){
			this.Log("Select Window: Bad Address. Aborting")
			;this.CloseSession("Could not find remote computer!")
			this.CloseSession(this._ErrorCodes.BAD_ADDRESS)
		} else {
			this._SelectWindow := hwnd
			if (hwnd){
				this.Log("Select Window: Selecting remote machine")
				; Enter name of machine into "Computer" editbox
				ControlSetText, Edit1, % this._address, % "ahk_id " hwnd
				Sleep % this._options.DefaultSleep
				ControlSend, , % "{Enter}", % "ahk_id " hwnd
				;while (!WinExist("Remote Desktop Connection ahk_exe mstsc.exe ahk_class #32770 ahk_pid " this.pid, "Connecting to:") && !this.LoginWindowExists() && !this.IdentityWindowExists()){
					; Click "Connect"
					;ControlClick, Button5, % "ahk_id " hwnd
					;Sleep 100
				;}
				Sleep 250
			}
		}
	}
	
	LoginWindowExists(){
		return WinExist("Windows Security ahk_exe mstsc.exe ahk_class #32770 ahk_pid " this.pid)+0
	}
	
	; The "Warning Window" opened or closed
	WarningWindowChanged(hwnd){
		this._WarningWindow := hwnd
		if (hwnd){
			Sleep % this._options.DefaultSleep
			ControlClick, Button1, % "ahk_id " hwnd
			Sleep % this._options.DefaultSleep
			ControlClick, Button11, % "ahk_id " hwnd
		}
	}
	
	; The "Login Window" opened or closed
	; If the address was valid, then this is typically the second window that opens
	LoginWindowChanged(hwnd){
		;msgbox % "LoginWindowChanged`n`n New HWND = " hwnd "`nOld HWND = " this._LoginWindow
		this._LoginWindow := hwnd
		if (hwnd){
			if (this._LoginAttempts >= this._options.MaxLoginAttempts){
				this.Log("Login Window: Login Failed. Aborting")
				;this.CloseSession("Login Failed!")
				this.CloseSession(this._ErrorCodes.LOGIN_FAILED)
			} else {
				; Send Down Arrow to select "Use another account"
				this.Log("Login Window: Entering credentials...")
				;WinActivate, % "ahk_id " hwnd
				Sleep % this._options.DefaultSleep
				; This part can be unreliable if you are clicking around a lot while it happens
				Critical
				WinActivate, % "ahk_id " hwnd
				ControlSend, , {down}, % "ahk_id " hwnd
				Critical, Off
				; end problem section
				Sleep % this._options.DefaultSleep
				; Enter Username
				ControlSetText, Edit2, % this._username, % "ahk_id " hwnd
				; Enter Password
				ControlSetText, Edit3, % this._password, % "ahk_id " hwnd
				if (!this._options.ShowOptions){
					Sleep % this._options.DefaultSleep
					ControlSend, , % "{Enter}", % "ahk_id " hwnd
					; Click OK
					;while (WinExist("ahk_id " hwnd)){
						;ControlClick, Button2, % "ahk_id " hwnd
						;Sleep 100
					;}
				}
				this._LoginAttempts++
				;msgbox % this._options.ShowOptions
			}
		}
	}
	
	; The "Certificate Window" opened or closed.
	; This may appear after the "Login Window". Ticking a box and clicking OK stops it happening again for that connection.
	; Once you click OK, the choice is cached: Windows places a reg key at HKCU\Software\Microsoft\Terminal Server Client\Servers
	CertificateWindowChanged(hwnd){
		this._CertificateWindow := hwnd
		if (hwnd){
			this.Log("Certificate Window: Dismissing...")
			; Tick "Don't ask me again for connections to this computer"
			ControlClick, Button3, % "ahk_id " hwnd
			Sleep % this._options.DefaultSleep
			;ControlSend, , % "{Enter}", % "ahk_id " hwnd
			while (WinExist("ahk_id " hwnd)){
				; Click "Yes"
				ControlClick, Button5, % "ahk_id " hwnd
				Sleep 100
			}
		}
	}
	
	IdentityWindowExists(){
		hwnd := WinExist("Remote Desktop Connection ahk_exe mstsc.exe ahk_class #32770 ahk_pid " this.pid)+0
			WinGetText, t,  % "ahk_id " hwnd
			t := StrSplit(t, "`r")
			t := StrSplit(t[1], "`n")
			t := t[1]
			if (t = "This problem can occur if the remote computer is running a version of Windows that is earlier than Windows Vista, or if the remote computer is not configured to support server authentication."){
				return true
			} else {
				return false
			}
	}
	
	; The "Identity Window" opened or closed.
	; This may appear after the "Login Window". Ticking a box and clicking OK stops it happening again for that connection.
	; Once you click OK, the choice is cached: Windows places a reg key at HKCU\Software\Microsoft\Terminal Server Client\Servers
	IdentityWindowChanged(hwnd){
		this._IdentityWindow := hwnd
		if (hwnd){
			this.Log("Identity Window: Dismissing...")
			; Tick "Don't ask me again for connections to this computer"
			ControlClick, Button1, % "ahk_id " hwnd
			Sleep % this._options.DefaultSleep
			ControlSend, , % "{Enter}", % "ahk_id " hwnd
			;while (WinExist("ahk_id " hwnd)){
				; Click "Yes"
				;ControlClick, Button2, % "ahk_id " hwnd
				;Sleep 100
			;}
		}
	}
	
	; The actual Session Window opened or closed (The one with the remote desktop in)
	; This is the final window to open, and terminates the connection sequence.
	; If the session closed (eg the user logged off), it will be called again and the hwnd will be 0
	SessionWindowChanged(hwnd){
		this.hwnd := hwnd
		if (hwnd){
			if (this._options.WaitForDesktopColor){
				this.Log("Session Window: Connected, waiting for desktop color " this._options.WaitForDesktopColor)
				found := 0
				end := A_TickCount + 30000
				Critical, On
				while (A_TickCount < end){
					WinActivate, % "ahk_id " this.hwnd
					PixelGetColor, col, 0, 0, RGB
					if (col = this._options.WaitForDesktopColor){
						found := 1
						break
					}
				}
				Critical, Off
				if (!found){
					this._callback.Call(this._ErrorCodes.WAIT_DESKTOP_FAILED, this.pid, hwnd)
					return
				}
			} else {
				this.Log("Session Window: Connected")
			}
			Sleep 500
			this.Log("Firing connection callback...")
			; Connected
			this._callback.Call(this._ErrorCodes.OK, this.pid, hwnd)
		} else {
			this.Log("Session Window: Disconnected")
			; Went from connected to disconnected
			this.CloseSession(this._ErrorCodes.OK)
		}
	}
	
	; Session window closed
	CloseSession(e){
		this.Log("CloseSession: Firing session close callback")
		; Stop watching for window events
		if (IsObject(this._WatchTimer)){
			fn := this._WatchTimer
			SetTimer, % fn, Off
		}
		this.KillAllWindows()
		this._LoginAttempts := 0
		
		; Fire the callback with the appropriate status code
		this._callback.Call(e, this.pid, hwnd)
	}
	
	KillAllWindows(){
		; Kill all windows for this PID
		while (WinExist("ahk_pid " this.pid)){
			WinClose
		}
	}
	
	; Returns a human-friendly name for a given error number
	GetErrorName(e){
		name := this._ErrorNames[e]
		if (name)
			return name
		else
			return "Unknown Error (" e ")"
	}
	
	; Returns an error code from a string
	GetErrorCode(e){
		code := this._ErrorCodes[e]
		if (code != "")
			return code
		else
			return -1
	}
	
	; Maximizes or Restores the Session Window (turns on or off fullscreen)
	SetMaximizedState(state){
		if (this.hwnd){
			WinGet, currstate, Style, % "ahk_id " this.hwnd
			if (state && (currstate & 0x00C00000)){ ; WS_CAPTION
				Send ^!{CtrlBreak}
			} else if (!state && ((currstate & 0x00C00000) = 0)) {
				PostMessage, 0x112, 0xF120,,, % "ahk_id " this.hwnd   ; 0x112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE
			}
		}
	}
	
	; Sends keystrokes to the Session Window
	SendKeys(keys){
		if (this.hwnd){
			ControlSend, , % keys, % "ahk_id " this.hwnd
		}
	}
	
	Log(str){
		OutputDebug % "RDPConnect (PID " this.pid "): " str
	}
}