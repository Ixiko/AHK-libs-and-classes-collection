; Tray Minimizer class by evilC
; Based on Skan's MinimizeToTray

; Include this file, then call TrayMinimizer.Init()
; By default, will minimize Gui on start
; To disable, initialize with TrayMinimizer.Init(false)
class TrayMinimizer {
	Init(minimizeOnStart := true){
		; Store the HWND of the main Gui
		Gui, +HwndhGui
		this.hGui := hGui
		; Create a BoundFunc for the Minimize handler
		this.MinimizeFn := this.Minimize.Bind(this)
		; Build tray menu
		this.Menu("Tray","Nostandard")
		this.Menu("Tray","Add","Restore", this.GuiShow.Bind(this))
		this.Menu("Tray","Add")
		this.Menu("Tray","Default","Restore")
		this.Menu("Tray","Click",1)
		this.Menu("Tray","Standard")
		; Listen to messages to detect minimize click
		OnMessage(0x112, this.WM_SYSCOMMAND.Bind(this))
		if (minimizeOnStart){
			this.Minimize()
		}
	}
	
	; Detects click of Minimize button
	WM_SYSCOMMAND(wParam){
		If ( wParam == 61472 ) {
			fn := this.MinimizeFn
			; Async fire off the minimze function
			SetTimer, % fn, -1
			; Swallow this message (Stop window from doing normal minimze)
			Return 0
		}
	}
	
	; Handles transition from tray minimized to restored
	GuiShow(){
		; Remove tray icon - ToDo: should we not leave this?
		this.Menu("Tray","NoIcon")
		Gui, Show
	}
	
	; Minimizes to tray
	Minimize() {
		WinHide, % "ahk_id " this.hGui
		this.Menu("Tray","Icon")
	}
	
	; Function wrapper for menu command
	Menu( MenuName, Cmd, P3 := "", P4 := "", P5 := "" ) {
		Menu, % MenuName, % Cmd, % P3, % P4, % P5
		Return errorLevel
	}
}