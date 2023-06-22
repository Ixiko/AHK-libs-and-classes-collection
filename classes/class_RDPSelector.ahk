/*
RDP Selector

A tool to make it quicker to select, connect, and switch between VMs in a Microsoft Test Manager (MTM) environment.

* Will automatically pull a list of Projects / Environments / VMs from your TFS server.
* Handy hotkeys (eg WIN+Tab to quickly select from a list of open RDP sessions).
* Renames window titles (eg "Fred on Exchange1" rather than "VSLM-8415-46ef4c57-3eb4-4e96-8f1a-25476653e416").
* Automatically marks environments as in-use in the MTM Lab Center.
*/
OutputDebug DBGVIEWCLEAR
#SingleInstance force
#include <JSON>				; Used for serializing objects to/from disk. http://ahkscript.org/boards/viewtopic.php?f=6&t=627
;#include Lib\JSON.ahk			; Used for serializing objects to/from disk. http://ahkscript.org/boards/viewtopic.php?f=6&t=627
;#include <RDPConnect>
#include Lib\RDPConnect.ahk

; Automatically hide console windows (Used by the powershell scripts)
DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")

FileInstall, Credentials.ini, Credentials.ini
FileInstall, RDPSelector.ini, RDPSelector.ini

r := new RDPSelector()
return

GuiClose:
	ExitApp


GuiSize(GuiHwnd, EventInfo, Width, Height){
	global r
	if (EventInfo = 0){
		r.GuiSize(GuiHwnd, EventInfo, Width, Height)
	}
}


class RDPSelector {
	static version := "2.0.11"
	Domains := []
	__New(){
		IniRead, root, RDPSelector.ini, Settings, tfsroot
		if (root = "" || root = "ERROR"){
			InputBox, root, TFS URL not set, Enter the URL for your TFS server`neg: http://tfs:8080/tfs/Something, , , 150,,,,, http://tfs:8080/tfs/Something
			if (ErrorLevel){
				ExitApp
			}
			IniWrite, % root, RDPSelector.ini, Settings, tfsroot
		}
		this.tfsroot := root
		
		this.UnPackFiles()

		this.RDPConnectOptions := {DefaultSleep: 500, ShowOptions: 0, MaxLoginAttempts: 1}
		this.CredentialsList := new this.CCredentialsList()
		this.EnvironmentList := new this.CEnvironmentList(this.tfsroot)
		this.OpenSessions := {}
		
		; Create the GUI
		Gui, Margin, 10, 10
		Gui, Add, Text, Center xm w300, User to connect as.`nIf this has focus, Connect with ENTER
		;Gui, Add, ListView, hwndhLVUsers w300 h170 xm yp+30 AltSubmit -Multi, Name|Domain
		Gui, Add, ListView, hwndhLVUsers w300 h170 xm yp+30 AltSubmit -Multi, Name
		
		clickprocessor := this.ProcessClicks.Bind(this)
		GuiControl +g, % hLVUsers , % clickprocessor
		
		;LV_ModifyCol(1, 200)
		;LV_ModifyCol(2, 80)

		this.hLVUsers := hLVUsers
		
		ct := 1
		for title, creds in this.CredentialsList.Credentials {
			if (ct = 1){
				o := "Select"
			} else {
				o := ""
			}
			;LV_Add(o, title, creds.domain)
			LV_Add(o, title)
			ct++
		}
		
		IniRead, domains, RDPSelector.ini, Settings, domains
		this.Domains := StrSplit(domains, "|")
		Loop % this.Domains.length(){
			if (A_Index > 2)
				s .= "|"
			s .= this.Domains[A_Index]
			if (A_Index = 1)
				s .= "||"
		}
		Gui, Add, DDL, hwndhwnd w300, % s
		this.hDomainDDL := hwnd
		;fn := this.DomainSelected.Bind(this)
		;GuiControl +g, % this.hDomainDDL, % fn
		
		; Add TreeView to select Environment / Machine
		Gui, Add, Text, Center x320 ym w300, Project / Environment / Machine to connect to.`nIf this has focus, Connect with ENTER
		Gui, Add, TreeView, hwndhTVMachines x320 w290 h170 yp+30 AltSubmit
		this.hTVMachines := hTVMachines
		this.TVMachines:=new treeview(hTVMachines)
		
		fn := this.ProcessMachineClicks.Bind(this)
		;GuiControl +g, % hTVMachines , % clickprocessor
		GuiControl +g, % hTVMachines , % fn

		ct := 1
		for project, params in this.EnvironmentList.Environments {
			if (ct = 1){
				o := "Select"
			} else {
				o := ""
			}
			;proj := TV_Add(project,, "Expand " o)
			proj := TV_Add(project,, o)
			for environment, env_data in params {
				env := TV_Add(environment "     | ", proj)
				;Tv.Add({Label:"Purple",Back:0xff00ff,parent:top,Option:"Vis"})
				for machine, address in env_data {
					TV_Add(machine, env)
				}
			}
			ct++
		}
		
		;Gui, Add, Text, xp yp+190 
		Gui, Add, Button, xp yp+180 w290 center hwndhUpdateEnvStates, Refresh Environment States
		this.hUpdateEnvStates := hUpdateEnvStates
		
		fn := this.UpdateEnvStates.Bind(this)
		GuiControl +g, % hUpdateEnvStates, % fn
		this.UpdateEnvStates()
		
		; Add ListView that lists current open connections
		Gui, Add, Text, Center xm w610 hwndhSessionsLabel, Open RDP Sessions`nIf this has focus, Activate with ENTER, Close with DELETE
		this.hSessionsLabel := hSessionsLabel
		Gui, Add, ListView, hwndhLVSessions w600 h100 AltSubmit -Multi, Project|Environment|Machine|User|UniqueID
		this.hLVSessions := hLVSessions
		GuiControl +g, % hLVSessions , % clickprocessor
		
		LV_ModifyCol(1, 120)
		LV_ModifyCol(2, 230)
		LV_ModifyCol(3, 80)
		LV_ModifyCol(4, 150)
		LV_ModifyCol(5, 0)	; Hidden column
		
		; Help Text
		Gui, Add, Text, Center xm w610 hwndhInstructionsLabel, Tab switches fields, Arrow keys to navigate.`nWin + \ to toggle window.`nWin + Tab to focus Open Sessions list.`nConfigure Environments / Machines / Users via INI files.
		this.hInstructionsLabel := hInstructionsLabel

		Gui, Show, x0 y0, % "RDP Selector v" this.version " (RDPConnect v" RDPConnect.version ")"
		WinSet,Redraw,,A
		Gui +resize
		this.hGui := WinExist("A")
		
		; Hotkeys which only work while the GUI is active
		hotkey, IfWinActive, % "ahk_id " this.hGui
		
		; Submit form on <Enter>
		fn := this.FormSubmitted.Bind(this)
		hotkey, $Enter, % fn
		
		; Close the session on <Delete>
		fn := this.CloseSession.Bind(this)
		hotkey, $Delete, % fn

		hotkey, IfWinActive

		; Global Hotkeys
		; Open the GUI and focus the Active Sessions List
		fn := this.ActivateSessionsDialog.Bind(this)
		hotkey, $#Tab, % fn

		; Show / Hide the GUI
		fn := this.ToggleGui.Bind(this)
		hotkey, ~$#\, % fn

		;fn := this.CycleWindowsOnWheel.Bind(this, 1)
		;hotkey, *WheelUp, % fn, On
		;fn := this.CycleWindowsOnWheel.Bind(this, -1)
		;hotkey, *WheelDown, % fn, On

		; Set up app switcher
		;fn := this.WatchSwap.Bind(this)
		;SetTimer, % fn, 500
	}
	
	; An GUI item was double-clicked, or Enter was pressed with a GUI item highlighted
	FormSubmitted(){
		; Determine context of ENTER key depending on which control has focus
		ControlGetFocus, f , % "ahk_id " this.hGui
		if (f = "SysTreeView321"){
			focus := "Env"
		} else if (f = "SysListView321"){
			focus := "User"
		} else if (f = "SysListView322"){
			focus := "Win"
		} else {
			return
		}
		
		if (focus = "Env" || focus = "User"){
			; Focus is Environment or User - Connect!
			; Find parameters
			machine_idx := TV_GetSelection()
			TV_GetText(machine, machine_idx)
			machine_parent := TV_GetParent(machine_idx)
			; Do not try to connect to projects
			if (!machine_parent){
				return
			}
			TV_GetText(environment, machine_parent)
			environment := StrSplit(environment, "     | ")
			environment := environment[1]
			env_parent := TV_GetParent(machine_parent)
			
			; Do not try to connect to environments
			if (!env_parent || TV_GetParent(env_parent)){
				return
			}
			TV_GetText(project, env_parent)
			
			Gui, ListView, % this.hLVUsers
			LV_GetText(user, LV_GetNext() )
			if (!IsObject(this.CredentialsList.Credentials[user])){
				SoundBeep
				return
			}

			;login := this.CredentialsList.Credentials[user].domain "\" this.CredentialsList.Credentials[user].login
			GuiControlGet, domain, , % this.hDomainDDL
			login := domain "\" this.CredentialsList.Credentials[user].login
			password := this.CredentialsList.Credentials[user].password
			address := this.EnvironmentList.Environments[project, environment, machine]

			;r := new RDPConnect(address, login, password, this.SessionChange.Bind(this), this.RDPConnectOptions)
			r := new RDPConnect(address, login, password, this.SessionChange.Bind(this))
			r.project := project
			r.environment := environment
			r.machine := machine
			r.user := this.CredentialsList.Credentials[user].login
			;r.domain := this.CredentialsList.Credentials[user].domain
			r.domain := domain
			
			this.OpenSessions[r.pid] := r
		} else {
			; Focus is active Session list - switch to Session
			winnum := this.GetSelectedSessionIndex()
			if (winnum){
				pid := this.PIDFromLVIndex(winnum)
				WinActivate, % "ahk_id " this.OpenSessions[pid].hwnd
			}
		}
	}

	; Delete was pressed while the Open Sessions dialog had focus - Close the Session
	CloseSession(){
		winnum := this.GetSelectedSessionIndex()
		if (winnum){
			;hwnd := this.PIDFromLVIndex(winnum)
			WinClose, % "ahk_id " this.OpenSessions[this.PIDFromLVIndex(winnum)].hwnd
		}
	}

	; A double-click of a GUI item was detected
	ProcessClicks(){
		if (A_GuiEvent = "DoubleClick"){
			this.FormSubmitted()
		}
	}

	ProcessMachineClicks(){
		if (A_GuiEvent = "DoubleClick"){
			this.FormSubmitted()
		} else if (A_GuiEvent = "RightClick"){
			this.ShowMachineContextMenu()
		}
	}
	
	ShowMachineContextMenu(){
		Gui, Treeview, this.hTVMachines
		machine_idx := TV_GetSelection()
		TV_GetText(machine, machine_idx)
		machine_parent := TV_GetParent(machine_idx)
		; Do not try to connect to projects
		if (!machine_parent){
			return
		}
		TV_GetText(environment, machine_parent)
		environment := StrSplit(environment, "     | ")
		environment := environment[1]
		if (!environment)
			return
		env_parent := TV_GetParent(machine_parent)
		TV_GetText(project, env_parent)
		if (!project)
			return
		startstring := "Start " environment
		shutdownstring := "Shutdown " environment
		Menu, EnvironmentOperations, Add, Dummy, MenuHandler
		Menu, EnvironmentOperations, DeleteAll
		Menu, EnvironmentOperations, Add, % startstring, MenuHandler
		Menu, EnvironmentOperations, Add, % shutdownstring, MenuHandler
		Menu, EnvironmentOperations, Show
		return
		MenuHandler:
			if (A_ThisMenuItem == startstring){
				action := 1
			} else {
				action := 0
			}
			str := "powershell.exe -executionpolicy bypass -file powershell\startstop.ps1 """ this.tfsroot """ """ project """ """ environment """ " action
			OutputDebug % "Running powershell script " str
			RunWaitOne(str)
			Sleep 500
			
			this.UpdateEnvStates()
			return
	}
	
	; Show / Hide the GUI
	ToggleGui(forceactive := 0){
		if (forceactive || !WinActive("ahk_id " this.hGui)){
			WinRestore % "ahk_id " this.hGui
			WinActivate % "ahk_id " this.hGui
		} else {
			WinMinimize % "ahk_id " this.hGui
		}
	}
	
	; Show the GUI and set the focus to the "Open RDP Sessions" dialog
	ActivateSessionsDialog(){
		this.ToggleGui(1)
		GuiControl, focus, % this.hLVSessions
	}
	
	; An RDP session was opened or closed
	; This is the callback that RDPConnect fires
	SessionChange(e, pid, hwnd){
		if (e = 0){
			; Everything went OK
			; Login Suceeded, or Session was closed
			if (hwnd){
				; Connected
				s := this.OpenSessions[pid]
				
				ct := 0
				for key, value in this.OpenSessions {
					; Get count of number of items in array
					ct++
				}
				if (ct = 1){
					; If adding 1st item, then make sure it starts selected
					o := "Select"
				} else {
					o := ""
				}
				; Add session to "Open RDP Sessions" list
				Gui, ListView, % this.hLVSessions
				LV_Add(o, s.project, s.environment, s.machine, s.domain "\" s.user, s.pid)
				
				; Change title of RDP session
				WinSetTitle, % "ahk_id " s.hwnd, , % s.user " on " s.machine " (" s.project "\" s.environment ")"
				
				; Mark environment as in use in MTM
				found := 0
				for p, session in this.OpenSessions{
					if (p = pid){
						continue
					}
					if (this.OpenSessions[pid].environment = session.environment){
						found := 1
						break
					}
				}
				if (!found){
					str := "powershell.exe -executionpolicy bypass -file powershell\markinuse.ps1 """ this.tfsroot """ """ this.OpenSessions[pid].project """ """ this.OpenSessions[pid].environment """ " 1
					Run, % str, , Hide
				}
			} else {
				; Disconnected
				i := this.LVIndexFromPID(pid)
				if (i){
					LV_Delete(i)
				}
				
				; Unmark in use
				found := 0
				for p, session in this.OpenSessions{
					if (p = pid){
						continue
					}
					if (this.OpenSessions[pid].environment = session.environment){
						found := 1
						break
					}
				}
				if (!found){
					str := "powershell.exe -executionpolicy bypass -file powershell\markinuse.ps1 """ this.tfsroot """ """ this.OpenSessions[pid].project """ """ this.OpenSessions[pid].environment """ " 0
					Run, % str, , Hide
				}

				this.OpenSessions.Delete(pid)

			}
		} else {
			; There was a problem
			SplashTextOn, 300, 70, Connection attempt aborted! , % "`nReason: " this.OpenSessions[pid].GetErrorName(e)
			this.OpenSessions.Delete(pid)
			Sleep 1000
			SplashTextOff
		}
	}
	
	; Finds the LV Index for a given PID
	LVIndexFromPID(pid){
		Gui, ListView, % this.hLVSessions
		Loop % LV_GetCount() {
			LV_GetText(p, A_Index, 5)
			if (p = pid){
				return A_Index
			}
		}
		return 0
	}

	; Finds the PID for a given LV index
	PIDFromLVIndex(idx){
		Gui, ListView, % this.hLVSessions
		LV_GetText(p, idx, 5)
		return p
	}
	
	; Retrieves the row number for the selected Session in the Sessions Listview
	GetSelectedSessionIndex(){
		Gui, ListView, % this.hLVSessions
		return LV_GetNext()
	}
	
	UpdateEnvStates(){
		SplashTextOn, 200 , 20 , RDPSelector, Loading environment states...
		FileDelete, EnvStates.ini
		str := "powershell -executionpolicy bypass -file powershell\envstates.ps1 " this.tfsroot " > EnvStates.ini"
		OutputDebug % "Executing " str
		clipboard := str
		ret := RunWaitOne(str)
		SplashTextOff
		if (!FileExist("EnvStates.ini"))
			return
		FileRead, j, EnvStates.ini
		EnvStates := JSON.Load(j)
		Gui, Treeview, this.hTVMachines
		for project, params in EnvStates {
			for environment, env_data in params {
				
			}
		}
		project := ""
		Loop {
			project := TV_GetNext(project)
			if (!project)
				break
			TV_GetText(projname, project)
			env := TV_GetChild(project)
			Loop {
				if (env = 0)
					break
				TV_GetText(envname, env)
				envname := StrSplit(envname, "     | ")
				envname := envname[1]

				state := EnvStates[projname,envname].State
				if (state = "stopped"){
					col := 0xFFFFFF
				} else if (state = "mixed" || state = "paused" || state = "starting"){
					col := 0x0099FF
				} else if (state = "notready"){
					col := 0x0000FF
				} else if (state = "ready"){
					col := 0x00FF00
				} else {
					col := 0xFF5555
				}
				TV_Modify(env,"",envname "     | " state)
				this.TVMachines.Modify({hwnd: env, Back: col, Fore: 0})
				env := TV_GetNext(env)
			}
		}
		
	}
	
	; Resize GUI Elements when the Gui resizes
	GuiSize(GuiHwnd, EventInfo, Width, Height){
		static w := 0, h := 0
		
		if (w && h){
			delta_w := width - w
			delta_h := height - h
			;tooltip % delta_w
			GuiControlGet, pos, pos, % this.hTVMachines
			GuiControl, Move, % this.hTVMachines, % " w" posw + delta_w " h" posh + delta_h

			GuiControlGet, pos, pos, % this.hLVUsers
			GuiControl, Move, % this.hLVUsers, % "h" posh + delta_h
			
			GuiControlGet, pos, pos, % this.hDomainDDL
			GuiControl, Move, % this.hDomainDDL, % "y" posy + delta_h
		
			GuiControlGet, pos, pos, % this.hUpdateEnvStates
			GuiControl, Move, % this.hUpdateEnvStates, % "y" posy + delta_h " w" posw + delta_w
		
						
			GuiControlGet, pos, pos, % this.hSessionsLabel
			GuiControl, Move, % this.hSessionsLabel, % " w" posw + delta_w " y" posy + delta_h
			
			GuiControlGet, pos, pos, % this.hLVSessions
			GuiControl, Move, % this.hLVSessions, % " w" posw + delta_w " y" posy + delta_h

			GuiControlGet, pos, pos, % this.hInstructionsLabel
			GuiControl, Move, % this.hInstructionsLabel, % " w" posw + delta_w " y" posy + delta_h

		}
		w := width
		h := height
	}

	UnPackFiles(){
		; Pack required files into compiled EXE, pull out on run of compiled exe
		FileCreateDir powershell
		FileInstall, powershell\mtmlist.ps1, powershell\mtmlist.ps1
		FileInstall, powershell\envstates.ps1, powershell\envstates.ps1
		FileInstall, powershell\markinuse.ps1, powershell\markinuse.ps1
		FileInstall, powershell\Microsoft.VisualStudio.Services.Common.dll, powershell\Microsoft.VisualStudio.Services.Common.dll
		FileInstall, powershell\Microsoft.TeamFoundation.Common.dll, powershell\Microsoft.TeamFoundation.Common.dll
		FileInstall, powershell\Microsoft.TeamFoundation.Client.dll, powershell\Microsoft.TeamFoundation.Client.dll
		FileInstall, powershell\Microsoft.TeamFoundation.Lab.Client.dll, powershell\Microsoft.TeamFoundation.Lab.Client.dll
		FileInstall, powershell\Microsoft.TeamFoundation.Lab.Common.dll, powershell\Microsoft.TeamFoundation.Lab.Common.dll
		FileInstall, powershell\Microsoft.VisualStudio.Services.Client.dll, powershell\Microsoft.VisualStudio.Services.Client.dll
		FileInstall, powershell\Microsoft.VisualStudio.Services.WebApi.dll, powershell\Microsoft.VisualStudio.Services.WebApi.dll
		FileInstall, powershell\Newtonsoft.Json.dll, powershell\Newtonsoft.Json.dll
		FileInstall, Credentials.Default.ini, Credentials.ini
	}
	
	/*
	WatchSwap(){
		if (this.IsMouseAtEdgeOfWindow() && this.isWindowFullScreen( "A" )){
			fn := this.CycleWindowsOnWheel.Bind(this, 1)
			hotkey, *WheelUp, % fn, On
			fn := this.CycleWindowsOnWheel.Bind(this, -1)
			hotkey, *WheelDown, % fn, On
		} else {
			fn := this.CycleWindowsOnWheel.Bind(this, 1)
			hotkey, *WheelUp, % fn, Off
			fn := this.CycleWindowsOnWheel.Bind(this, -1)
			hotkey, *WheelDown, % fn, Off
		}
	}
	
	CycleWindowsOnWheel(dir){
		if (this.isWindowFullScreen( "A" ) && this.IsMouseAtEdgeOfWindow()){
			hwnd := WinExist("A")
			WinGet, active_pid, pid
			last_window := 0
			next_window := 0
			found_this := 0
			
			indexed := []
			this_index := 0
			i := 0
			for pid in this.OpenSessions {
				i++
				indexed.push(pid)
				if (pid = active_pid)
					this_index := i
			}
			
			max := indexed.length()
			this_index += dir
			
			if (this_index < 1){
				this_index := max
			} else if (this_index > max){
				this_index := 1
			}
			
			new_pid := indexed[this_index]
			
			hwnd := this.OpenSessions[new_pid].hwnd
			WinActivate, % "ahk_id " hwnd
			ToolTip % "User: " this.OpenSessions[new_pid].domain "\" this.OpenSessions[new_pid].user "`nMachine: " this.OpenSessions[new_pid].machine "`nEnvironment: " this.OpenSessions[new_pid].project "\" this.OpenSessions[new_pid].environment
			fn := this.RemoveToolTip.Bind(this)
			SetTimer, % fn, -3000
		} else {
			if (dir > 0){
				Send {WheelUp}
			} else {
				Send {WheelDown}
			}
		}
	}
	
	RemoveToolTip(){
		Tooltip
	}
	
	IsMouseAtEdgeOfWindow(){
		hwnd := WinExist("A")
		MouseGetPos, mx, my
		WinGetPos, wx, wy, ww, wh, % "ahk_id " hwnd
		;tooltip % "hwnd: " hwnd ", mx: " mx ", wx: " wx ", ww: " ww
		if (mx < 10){
			return 1
		} else if (mx >= ww - 10){
			return 1
		}
		return 0
	}
	
	IsWindowFullScreen( winTitle ) {
		;checks if the specified window is full screen

		winID := WinExist( winTitle )

		If ( !winID )
			Return false

		WinGet style, Style, ahk_id %WinID%
		WinGetPos ,,,winW,winH, %winTitle%
		; 0x800000 is WS_BORDER.
		; 0x20000000 is WS_MINIMIZE.
		; no border and not minimized
		Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
	}
	*/
	
	Class CCredentialsList {
		__New(){
			this.Credentials := {}
			IniRead, Users, credentials.ini
			Users := StrSplit(users, "`n")
			Loop % users.length(){
				IniRead, login, credentials.ini, % users[A_Index], login
				IniRead, password, credentials.ini, % users[A_Index], password
				;IniRead, domain, credentials.ini, % users[A_Index], domain
				;this.Credentials[users[A_Index]] := {login: login, password: password, domain: domain}
				this.Credentials[users[A_Index]] := {login: login, password: password}
			}
		}
	}

	class CEnvironmentList {
		__New(tfsroot){
			if (!FileExist("Environments.ini")){
				SplashTextOn, 200 , 20 , RDPSelector, Loading environment list...
				RunWaitOne("powershell -executionpolicy bypass -file powershell\mtmlist.ps1 " tfsroot " > Environments.ini")
				SplashTextOff
			}
			FileRead, j, Environments.ini
			try {
				this.Environments := JSON.Load(j)
			} catch {
				msgbox % "MTMlist powershell script failed.`nOutput`n`n" j
			}
		}
	}
}

RunWaitOne(command) {
	; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
	shell := ComObjCreate("WScript.Shell")
	; Execute a single command via cmd.exe
	exec := shell.Exec(ComSpec " /C " command)
	; Read and return the command's output
	return exec.StdOut.ReadAll()
}

; Maestrith's "Treeview Custom Item Colors" library
; https://autohotkey.com/boards/viewtopic.php?t=2632
class treeview{
	static list:=[]
	__New(hwnd){
		this.list[hwnd]:=this
		OnMessage(0x4e,"WM_NOTIFY")
		this.hwnd:=hwnd
	}
	add(info){
		Gui,TreeView,% this.hwnd
		hwnd:=TV_Add(info.Label,info.parent,info.option)
		if info.fore!=""
			this.control["|" hwnd,"fore"]:=info.fore
		if info.back!=""
			this.control["|" hwnd,"back"]:=info.back
		return hwnd
	}
	modify(info){
		this.control["|" info.hwnd,"fore"]:=info.fore
		this.control["|" info.hwnd,"back"]:=info.back
		WinSet,Redraw,,A
	}
	Remove(hwnd){
		this.control.Remove("|" hwnd)
	}
}
WM_NOTIFY(Param*){
	static list:=[],ll:=""
	control:=
	if (this:=treeview.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12){
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		if (stage=0x10001&&info:=this.control["|" numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")]){ ;NM_CUSTOMDRAW && Control is in the list
			if info.fore!=""
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			if info.back!=""
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
	}
}